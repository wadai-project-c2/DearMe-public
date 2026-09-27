import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../audio/audio_controller.dart';
import '../providers/item_provider.dart';
import '../providers/room_provider.dart';
import '../room/room_scene_widget.dart';
import '../room/room_scene_snapshot.dart';

enum _Stage { loading, swipeUp, placed, avatarJoy, savedPopup, done }

/// プレゼント配置後に表示する、部屋とは独立した喜び演出ページ。
///
/// `hi-hi/real_ios` の確認済み構図を利用し、RoomSceneのレンダラーと
/// アニメーション用GLBを同時に扱わないようにする。
class JoyAnimationPage extends StatelessWidget {
  final String assetPath;

  const JoyAnimationPage({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xfffff8fb),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 48),
          child: ModelViewer(
            backgroundColor: Colors.transparent,
            src: assetPath,
            alt: '喜ぶアバター',
            autoPlay: true,
            scale: '0.65 0.65 0.65',
            cameraTarget: '1m 1m 0m',
            cameraOrbit: '0deg 90deg 7m',
            fieldOfView: '35deg',
            cameraControls: false,
            disableZoom: true,
            interactionPrompt: InteractionPrompt.none,
          ),
        ),
      ),
    );
  }
}

/// 品物登録フローの最後に表示する演出画面。
/// スワイプ→部屋に配置+キラキラ→アバターよろこぶ→保存ポップアップ→ホーム、の順に進む。
class ItemSwipePlacementPage extends StatefulWidget {
  final String itemId;

  const ItemSwipePlacementPage({super.key, required this.itemId});

  @override
  State<ItemSwipePlacementPage> createState() => _ItemSwipePlacementPageState();
}

class _ItemSwipePlacementPageState extends State<ItemSwipePlacementPage>
    with TickerProviderStateMixin {
  static const double _cardSize = 220;
  static const double _commitThresholdDy = -90;
  static const double _commitThresholdVelocity = -700;
  static const double _maxDragUp = -260;
  static const double _maxDragDown = 40;
  static const Alignment _sparkleAlignment = Alignment(0.05, 0.22);

  late final AnimationController _cardMotionController;

  ItemModel? _item;
  String? _joyAssetPath;
  _Stage _stage = _Stage.loading;

  double _dragDy = 0;
  double _cardScale = 1;
  double _cardOpacity = 1;
  bool _dragActive = false;

  bool _showSparkle = false;
  bool _showPopup = false;
  bool _popupVisible = false;

  @override
  void initState() {
    super.initState();
    _cardMotionController = AnimationController(vsync: this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => unawaited(_bootstrap()));
  }

  @override
  void dispose() {
    // メモ入力画面で先読みしたGLBのうち、この画面で消費されなかったもの
    // （例: アバター未割当でavatarがnull、シーン構築前に離脱した等）が
    // 宙に浮いたままにならないよう、画面を離れる時点で確実に破棄する。
    GlbParsePrewarm.clear();
    _cardMotionController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final item = context.read<ItemProvider>().itemById(widget.itemId);
    // 加工済み画像が無くても元写真で演出できるため、画像が一切無い場合のみホームへ戻す（#95）。
    if (item == null || item.placementImagePath == null) {
      if (mounted) {
        context.go('/');
      }
      return;
    }

    final roomProvider = context.read<RoomProvider>();
    final assignment =
        roomProvider.assignmentForRoom(RoomProvider.simpleRoomId);
    final avatar = roomProvider.avatarById(assignment?.avatarId);
    if (avatar != null) {
      final candidatePath = 'assets/animation/3d/${avatar.id}_joy.glb';
      try {
        await rootBundle.load(candidatePath);
        _joyAssetPath = candidatePath;
      } catch (_) {
        _joyAssetPath = null;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _item = item;
      _stage = _Stage.swipeUp;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_stage != _Stage.swipeUp) {
      return;
    }
    setState(() {
      _dragActive = true;
      _dragDy = (_dragDy + details.delta.dy).clamp(_maxDragUp, _maxDragDown);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (_stage != _Stage.swipeUp) {
      return;
    }
    _dragActive = false;
    final velocity = details.velocity.pixelsPerSecond.dy;
    final committed =
        _dragDy <= _commitThresholdDy || velocity <= _commitThresholdVelocity;
    if (committed) {
      unawaited(
        context.read<AudioController>().playEffect(SoundEffect.swipePlacement),
      );
      setState(() => _stage = _Stage.placed);
      await _playCommitAnimation();
      await _runSequence();
    } else {
      await _playBounceBack();
    }
  }

  Future<void> _playBounceBack() async {
    final start = _dragDy;
    _cardMotionController
      ..duration = const Duration(milliseconds: 320)
      ..value = 0;
    final animation = CurvedAnimation(
      parent: _cardMotionController,
      curve: Curves.easeOutBack,
    );
    void listener() {
      if (!mounted) return;
      setState(() => _dragDy = ui.lerpDouble(start, 0, animation.value)!);
    }

    animation.addListener(listener);
    await _cardMotionController.forward();
    animation.removeListener(listener);
    if (mounted) {
      setState(() => _dragDy = 0);
    }
  }

  Future<void> _playCommitAnimation() async {
    final startDy = _dragDy;
    _cardMotionController
      ..duration = const Duration(milliseconds: 380)
      ..value = 0;
    final animation = CurvedAnimation(
      parent: _cardMotionController,
      curve: Curves.easeIn,
    );
    void listener() {
      if (!mounted) return;
      setState(() {
        _dragDy = ui.lerpDouble(startDy, startDy - 260, animation.value)!;
        _cardScale = ui.lerpDouble(1, 0.35, animation.value)!;
        _cardOpacity = ui.lerpDouble(1, 0, animation.value)!;
      });
    }

    animation.addListener(listener);
    await _cardMotionController.forward();
    animation.removeListener(listener);
  }

  Future<void> _runSequence() async {
    await _placeInRoom();
    if (!mounted) return;
    setState(() => _stage = _Stage.avatarJoy);
    await _playAvatarJoy();
    if (!mounted) return;
    setState(() => _stage = _Stage.savedPopup);
    await _playSavedPopup();
    if (!mounted) return;
    setState(() => _stage = _Stage.done);
    context.go('/');
  }

  Future<void> _placeInRoom() async {
    final item = _item;
    if (item == null) {
      return;
    }
    final roomProvider = context.read<RoomProvider>();
    final dimensions = await _imageDimensions(item);
    final draft = roomProvider.findFreePlacementDraft(
      item: item,
      roomId: RoomProvider.simpleRoomId,
      originalWidth: dimensions.$1,
      originalHeight: dimensions.$2,
    );
    if (draft == null) {
      // 品物自体は保存済みなので、ROOM編集から家具を動かした後に配置できる。
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アバターの通り道を確保できる場所がありません。ROOM編集から配置を調整してください'),
          ),
        );
      }
      return;
    }
    try {
      await roomProvider.saveRoomObject(draft);
    } catch (_) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _showSparkle = true);
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    if (!mounted) {
      return;
    }
    setState(() => _showSparkle = false);
  }

  Future<(int, int)> _imageDimensions(ItemModel item) async {
    final path = item.placementImagePath;
    if (path == null || path.isEmpty) {
      return (0, 0);
    }
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        final dimensions = (frame.image.width, frame.image.height);
        frame.image.dispose();
        return dimensions;
      } finally {
        codec.dispose();
      }
    } catch (_) {
      return (0, 0);
    }
  }

  Future<void> _playAvatarJoy() async {
    if (_joyAssetPath == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    unawaited(
      context
          .read<AudioController>()
          .playEffect(SoundEffect.presentCelebration),
    );
    // `hi-hi/real_ios` と同じ専用ModelViewerで、joy GLBの1回分と
    // 初期ロードの余白を表示する。RoomSceneのGLコンテキストとは共有しない。
    await Future<void>.delayed(const Duration(milliseconds: 3200));
  }

  Future<void> _playSavedPopup() async {
    final item = _item;
    if (item == null || !mounted) {
      return;
    }
    setState(() => _showPopup = true);
    unawaited(
      context.read<AudioController>().playEffect(SoundEffect.saveComplete),
    );
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;
    setState(() => _popupVisible = true);
    await Future<void>.delayed(const Duration(milliseconds: 450 + 1600));
    if (!mounted) return;
    setState(() => _popupVisible = false);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _showPopup = false);
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.roomById(RoomProvider.simpleRoomId);
    final item = _item;
    final joyAssetPath = _joyAssetPath;
    final showJoyPage = joyAssetPath != null &&
        (_stage == _Stage.avatarJoy || _stage == _Stage.savedPopup);

    if (room == null || item == null) {
      return const Scaffold(
        backgroundColor: Color(0xfffffbf7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imagePath = item.placementImagePath!;
    final showCard = _stage == _Stage.swipeUp || _dragActive;
    final roomSnapshot = RoomSceneSnapshotStore.instance.pngBytes;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xfffffbf7),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (showJoyPage)
              Positioned.fill(
                child: JoyAnimationPage(assetPath: joyAssetPath),
              )
            else if (roomSnapshot != null)
              Image.memory(roomSnapshot,
                  fit: BoxFit.cover, gaplessPlayback: true)
            else
              const ColoredBox(color: Color(0xfffff8fb)),
            if (_showSparkle && !showJoyPage)
              Align(
                alignment: _sparkleAlignment,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: lottie.Lottie.asset(
                      'assets/animation/2d/sparkle.json',
                      repeat: false,
                    ),
                  ),
                ),
              ),
            if (showCard)
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _dragActive ? 0 : 1,
                      child: const _SwipeHint(),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: (details) =>
                          unawaited(_onDragEnd(details)),
                      child: Transform.translate(
                        offset: Offset(0, _dragDy),
                        child: Opacity(
                          opacity: _cardOpacity,
                          child: Transform.scale(
                            scale: _cardScale,
                            child: _SwipeCard(imagePath: imagePath),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_showPopup)
              Positioned(
                left: 24,
                right: 24,
                bottom: 90,
                child: Center(
                  child: _SavedPopup(
                    title: item.title,
                    visible: _popupVisible,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Color(0xffd95f79),
          size: 26,
        ),
        Text(
          '上にスワイプして部屋へ',
          style: TextStyle(
            color: Color(0xff8a6d73),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final String imagePath;

  const _SwipeCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    const size = _ItemSwipePlacementPageState._cardSize;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 実際の形はアイテムごとに違う（丸とは限らない）ので、影は形に
          // 追従させず、床に落ちるような淡い楕円ぼかしとして下に敷く。
          Positioned(
            bottom: 8,
            child: Container(
              width: size * 0.6,
              height: size * 0.22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x407a4a52),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          // Keep the processed PNG's original pixels and alpha intact. The
          // floor shadow above provides depth without compositing a white
          // highlight layer over the image.
          Image.file(
            File(imagePath),
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xfffdeef1),
              child: Icon(Icons.image_outlined, size: 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPopup extends StatelessWidget {
  final String title;
  final bool visible;

  const _SavedPopup({required this.title, required this.visible});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 450),
      curve: visible ? Curves.easeOutBack : Curves.easeIn,
      offset: visible ? Offset.zero : const Offset(0, 0.12),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: visible ? 450 : 350),
        opacity: visible ? 1 : 0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutBack,
          scale: visible ? 1 : 0.85,
          child: _GlowText(title: title),
        ),
      ),
    );
  }
}

class _GlowText extends StatefulWidget {
  final String title;

  const _GlowText({required this.title});

  @override
  State<_GlowText> createState() => _GlowTextState();
}

class _GlowTextState extends State<_GlowText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _moteController;

  @override
  void initState() {
    super.initState();
    _moteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    if (!reduceMotion) {
      _moteController.repeat();
    }
  }

  @override
  void dispose() {
    _moteController.dispose();
    super.dispose();
  }

  static const _moteAlignments = [
    Alignment(-0.65, -0.35),
    Alignment(0.55, 0.05),
    Alignment(-0.15, -0.75),
    Alignment(0.75, -0.45),
  ];
  static const _moteSizes = [5.0, 3.0, 4.0, 3.0];
  static const _moteDelays = [0.0, 0.19, 0.38, 0.59];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          // Container.marginは負の値を許容しない（isNonNegativeアサーションで
          // 例外になる）ため、グローをテキストの外側までにじませる分だけ
          // Positionedのオフセットを負にして表現する。
          left: -32,
          right: -32,
          top: -40,
          bottom: -40,
          child: IgnorePointer(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x8Effd282),
                      Color(0x4Fff96b8),
                      Color(0x00ff96b8),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
        ),
        for (var index = 0; index < _moteAlignments.length; index++)
          IgnorePointer(
            child: _Mote(
              animation: CurvedAnimation(
                parent: _moteController,
                curve: Interval(
                  _moteDelays[index],
                  (_moteDelays[index] + 0.6).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              ),
              alignment: _moteAlignments[index],
              size: _moteSizes[index],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            '「${widget.title}」を保存しました',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff6b2c42),
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
              height: 1.5,
              shadows: [
                Shadow(color: Color(0x8cffffff), blurRadius: 1),
                Shadow(color: Color(0x8cffd282), blurRadius: 16),
                Shadow(
                  color: Color(0x2e782837),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Mote extends StatelessWidget {
  final Animation<double> animation;
  final Alignment alignment;
  final double size;

  const _Mote({
    required this.animation,
    required this.alignment,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final opacity =
            (t < 0.3 ? t / 0.3 : (1 - (t - 0.3) / 0.7)).clamp(0.0, 1.0);
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, -t * 22),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xfffff3d6), Color(0x00ffd98a)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
