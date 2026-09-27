import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/item_media_model.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../services/app_interaction_feedback.dart';
import 'item_detail_carousel_position.dart';

class ItemDetailPage extends StatefulWidget {
  final ItemModel? item;

  const ItemDetailPage({super.key, this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryController;
  late Animation<double> _entryAnimation;
  late double _currentPage;
  late ItemDetailCarouselPosition _carouselPosition;
  bool _isControllerInitialized = false;

  // コラージュ用のアニメーション初期値
  List<Offset>? _collageOffsets;
  List<double>? _collageRotations;
  List<double>? _collageScales;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // 集束時間を 2.5秒に延長
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeInOutQuart, // より優雅に減速する曲線に変更
    );

    // コラージュを鑑賞するため、1.5秒待機してからアニメーションを開始
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  /// 写真の枚数に応じてコラージュの初期配置を生成
  void _initCollageParams(int count) {
    if (_collageOffsets != null) return;

    final random = math.Random();
    _collageOffsets = [];
    _collageRotations = [];
    _collageScales = [];

    if (count == 1) {
      // 1枚の場合: 中央でわずかに小さく配置
      _collageOffsets = [Offset.zero];
      _collageRotations = [-0.05];
      _collageScales = [0.95];
    } else if (count == 2) {
      // 2枚の場合: 左右に大きく並べて重ねる
      _collageOffsets = [const Offset(-55, 10), const Offset(55, -10)];
      _collageRotations = [-0.14, 0.14];
      _collageScales = [0.65, 0.65];
    } else if (count == 3) {
      // 3枚の場合: 1枚目を手前中央、2枚を後ろ左右に扇状配置
      _collageOffsets = [
        const Offset(0, 80), // メイン
        const Offset(-100, -30), // 左奥
        const Offset(100, -30), // 右奥
      ];
      _collageRotations = [0.0, -0.25, 0.25];
      _collageScales = [0.72, 0.58, 0.58];
    } else if (count == 4) {
      // 4枚の場合: 上下左右にバランスよく
      _collageOffsets = [
        const Offset(-70, -100), // 左上
        const Offset(70, -100), // 右上
        const Offset(-70, 100), // 左下
        const Offset(70, 100), // 右下
      ];
      _collageRotations = [-0.15, 0.15, 0.1, -0.1];
      _collageScales = [0.55, 0.55, 0.55, 0.55];
    } else {
      // 5枚以上の場合: 画面全体に散らす（スロット制）
      final slots = [
        const Offset(-20, 20),
        const Offset(-130, -180),
        const Offset(120, -150),
        const Offset(-110, 160),
        const Offset(100, 190),
        const Offset(-150, 0),
        const Offset(140, 40),
      ];
      for (int i = 0; i < math.max(count, 10); i++) {
        final base = slots[i % slots.length];
        _collageOffsets!.add(Offset(
          base.dx + (random.nextDouble() - 0.5) * 40,
          base.dy + (random.nextDouble() - 0.5) * 40,
        ));
        _collageRotations!
            .add(i == 0 ? -0.15 : (random.nextDouble() - 0.5) * 0.4);
        _collageScales!.add(i == 0 ? 0.5 : 0.4 + (random.nextDouble() * 0.1));
      }
    }

    // 安全のため、足りない分はデフォルトで埋める
    while (_collageOffsets!.length < 10) {
      _collageOffsets!.add(Offset.zero);
      _collageRotations!.add(0.0);
      _collageScales!.add(1.0);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, ItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('思い出の削除'),
        content: Text('「${item.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ItemProvider>().removeItem(item.id);
        if (context.mounted) {
          Navigator.pop(context); // 詳細画面を閉じる
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「${item.title}」を削除しました')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  void _synchronizeController(List<_MediaItem> mediaList) {
    final mediaKeys =
        mediaList.map((media) => media.key).toList(growable: false);
    if (_isControllerInitialized) {
      _carouselPosition.updateMediaKeys(
        mediaKeys,
        currentPage: _currentPage.round(),
      );
      return;
    }

    // 1枚のみの場合は無限スクロール無効、複数枚なら有効
    final initialPage = mediaList.length > 1 ? 1000 : 0;
    _currentPage = initialPage.toDouble();
    _carouselPosition = ItemDetailCarouselPosition(
      mediaKeys: mediaKeys,
      initialPage: initialPage,
    );

    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: initialPage,
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });

    _isControllerInitialized = true;
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _pageController.dispose();
    }
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemId = widget.item?.id;
    final currentItem = itemId == null
        ? null
        : context.watch<ItemProvider>().itemById(itemId) ?? widget.item;

    if (currentItem == null) {
      return const Scaffold(body: Center(child: Text('品物が見つかりません')));
    }

    final mediaList = [
      // AI加工後の画像（ステッカー）があれば追加
      if (currentItem.processedLocalImagePath != null)
        _MediaItem(
            key: 'processed:${currentItem.processedLocalImagePath!}',
            path: currentItem.processedLocalImagePath!,
            type: ItemMediaType.image),
      // 元の写真を追加
      if (currentItem.localImagePath != null)
        _MediaItem(
            key: 'original:${currentItem.localImagePath!}',
            path: currentItem.localImagePath!,
            type: ItemMediaType.image),
      // 追加されたメディア（動画・追加写真）
      ...currentItem.media.map((m) => _MediaItem(
            key: 'media:${m.mediaId}',
            path: m.localPath,
            type: m.mediaType,
          )),
    ];

    if (mediaList.isEmpty) {
      return const Scaffold(body: Center(child: Text('メディアがありません')));
    }

    // コントローラーの初期化（メディア数確定後に行う）
    _synchronizeController(mediaList);
    _initCollageParams(mediaList.length); // コラージュ配置を初期化

    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entryAnimation,
          builder: (context, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ① ヘッダー（右上操作エリア）: フェードイン
                  Opacity(
                    opacity: (_entryAnimation.value - 0.4).clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showDeleteDialog(context, currentItem),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.redAccent),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.push('/memo_input',
                                extra: currentItem.id),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.edit,
                                  size: 20, color: Colors.black54),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.close,
                                  size: 20, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ② メディアカルーセル（高さを固定して縦スクロール時に縮まないようにする）
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.55,
                    child: Column(
                      children: [
                        Expanded(
                          child: AvatarOrbitWidget(
                            avatarIds: currentItem.relatedAvatarIds,
                            entryProgress: _entryAnimation.value,
                            child: _buildCollageOrPageView(mediaList),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ページインジケーター: フェードイン
                        Opacity(
                          opacity:
                              (_entryAnimation.value - 0.5).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(mediaList.length, (index) {
                              final isActive = index ==
                                  _carouselPosition
                                      .indexForPage(_currentPage.round());
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Colors.black26
                                      : Colors.black12,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ③ 詳細テキスト（下部エリア）: フェードイン & 下からスライド
                  Opacity(
                    opacity: (_entryAnimation.value - 0.4).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1.0 - _entryAnimation.value)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '「${currentItem.title}」',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentItem.memo.isEmpty
                                  ? 'メモはありません'
                                  : currentItem.memo,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (currentItem.usedFrom != null)
                              Text(
                                '使用期間：${currentItem.usedFrom!.year}/${currentItem.usedFrom!.month}'
                                '${currentItem.usedUntil != null ? ' 〜 ${currentItem.usedUntil!.year}/${currentItem.usedUntil!.month}' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black45,
                                ),
                              ),
                            const SizedBox(height: 40), // 下部の余白
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// コラージュ状態から1枚目へフォーカスするレイアウトを構築
  Widget _buildCollageOrPageView(List<_MediaItem> mediaList) {
    if (_entryAnimation.value >= 1.0) {
      // アニメーション完了後は通常の PageView を表示
      return PageView.builder(
        controller: _pageController,
        itemCount: mediaList.length > 1 ? null : 1,
        itemBuilder: (context, index) {
          final actualIndex = _carouselPosition.indexForPage(index);
          final diff = (index - _currentPage).abs();
          final scale = (1 - (diff * 0.15)).clamp(0.8, 1.0);
          final opacity = (1 - (diff * 0.5)).clamp(0.4, 1.0);
          final blur = (diff * 10).clamp(0.0, 15.0);
          final media = mediaList[actualIndex];

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Center(
                child: _CarouselCard(media: media, blur: blur),
              ),
            ),
          );
        },
      );
    }

    // アニメーション中は複数のカードが飛び出すコラージュスタックを表示
    return Stack(
      alignment: Alignment.center,
      children: [
        // 重なり順のため、インデックスの大きい（後ろの）カードから描画
        for (int i = math.min(mediaList.length - 1, 4); i >= 0; i--)
          _buildAnimatedCollageItem(i, mediaList[i]),
      ],
    );
  }

  Widget _buildAnimatedCollageItem(int index, _MediaItem media) {
    final progress = _entryAnimation.value;
    final startOffset = _collageOffsets![index];
    final startRotate = _collageRotations![index];
    final startScale = _collageScales![index];

    // 1枚目とそれ以外で着地点を変える
    const targetOffset = Offset.zero;
    const targetRotate = 0.0;
    final targetScale = index == 0 ? 1.0 : 0.5; // 2枚目以降は小さくなって消える
    final targetOpacity = index == 0 ? 1.0 : 0.0; // 2枚目以降はフェードアウト

    final currentOffset = Offset.lerp(startOffset, targetOffset, progress)!;
    final currentRotate = lerpDouble(startRotate, targetRotate, progress)!;
    final currentScale = lerpDouble(startScale, targetScale, progress)!;
    final currentOpacity =
        index == 0 ? 1.0 : lerpDouble(1.0, targetOpacity, progress)!;

    return Transform.translate(
      offset: currentOffset,
      child: Transform.rotate(
        angle: currentRotate,
        child: Transform.scale(
          scale: currentScale,
          child: Opacity(
            opacity: currentOpacity,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width *
                  0.75, // PageViewのviewportFractionに合わせる
              child: _CarouselCard(media: media, blur: 0),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaItem {
  final String key;
  final String path;
  final ItemMediaType type;
  _MediaItem({required this.key, required this.path, required this.type});
}

class _CarouselCard extends StatelessWidget {
  final _MediaItem media;
  final double blur;

  const _CarouselCard({required this.media, required this.blur});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: _MediaContent(media: media),
        ),
      ),
    );
  }
}

class _MediaContent extends StatelessWidget {
  final _MediaItem media;

  const _MediaContent({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.type == ItemMediaType.video) {
      return _VideoPlayerWidget(videoPath: media.path);
    }
    return Image.file(
      File(media.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  const _VideoPlayerWidget({required this.videoPath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        AppInteractionFeedback.tap();
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            Icon(
              Icons.play_arrow,
              size: 64,
              color: Colors.white.withValues(alpha: 0.7),
            ),
        ],
      ),
    );
  }
}

/// 登場メンバーのアバターが中央のWidgetの周りを公転するWidget
class AvatarOrbitWidget extends StatefulWidget {
  final List<String> avatarIds;
  final Widget child;
  final double entryProgress; // 初期集束アニメーションの進捗 (0.0 -> 1.0)

  const AvatarOrbitWidget({
    super.key,
    required this.avatarIds,
    required this.child,
    required this.entryProgress,
  });

  @override
  State<AvatarOrbitWidget> createState() => _AvatarOrbitWidgetState();
}

class _AvatarOrbitWidgetState extends State<AvatarOrbitWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _randomOffsets;
  late List<Offset> _startPositions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 3), // 3分で1周 (超々低速)
    )..repeat();

    final random = math.Random();
    // アバターごとにランダムな角度オフセットを生成
    _randomOffsets = List.generate(
      10,
      (_) => (random.nextDouble() - 0.5) * (math.pi / 4.5),
    );

    // 初期出現位置を写真の枚数や配置に合わせて「隙間」へ調整
    _startPositions = List.generate(
      10,
      (i) => Offset(
        (random.nextDouble() - 0.5) * 400, // 散らばり幅を写真に合わせる
        (random.nextDouble() - 0.5) * 500,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _getAvatarAssetPath(String id) {
    switch (id) {
      case 'girl1':
        return 'assets/avatarphoto/you.png';
      case 'girl2':
        return 'assets/avatarphoto/mika.png';
      case 'youtienzi':
        return 'assets/avatarphoto/haruka.png';
      case 'boy':
        return 'assets/avatarphoto/shunsuke.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.avatarIds.isEmpty) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewPortWidth = constraints.maxWidth;
        final viewPortHeight = constraints.maxHeight;

        final cardWidth = viewPortWidth * 0.75;
        final cardHeight = viewPortHeight * 0.92;

        // 楕円軌道の半径
        final rx = (cardWidth * 0.5) + 38;
        final ry = (cardHeight * 0.5) + 25;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 中央のコンテンツ（PageView）
            widget.child,

            // 公転するアバターたち
            ...List.generate(widget.avatarIds.length, (index) {
              final avatarId = widget.avatarIds[index];
              final assetPath = _getAvatarAssetPath(avatarId);

              if (assetPath == null) return const SizedBox.shrink();

              final initialAngle =
                  ((2 * math.pi / widget.avatarIds.length) * index) +
                      (_randomOffsets[index % _randomOffsets.length]);

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // 現在の回転角 (公転用)
                  final currentAngle =
                      initialAngle + (_controller.value * 2 * math.pi);

                  // 目標地点 (楕円軌道上の現在位置)
                  final targetX = math.cos(currentAngle) * rx;
                  final targetY = math.sin(currentAngle) * ry;

                  // 初期位置からの集束計算
                  final startPos =
                      _startPositions[index % _startPositions.length];
                  final currentX =
                      lerpDouble(startPos.dx, targetX, widget.entryProgress)!;
                  final currentY =
                      lerpDouble(startPos.dy, targetY, widget.entryProgress)!;

                  return Transform.translate(
                    offset: Offset(currentX, currentY),
                    child: Opacity(
                      // 最初からコラージュの一部として表示するため不透明度を 1.0 に固定
                      opacity: 1.0,
                      child: Transform.rotate(
                        angle: -0.1,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                // シャドウも最初から表示
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Transform.scale(
                              scale: 1.4,
                              child: Image.asset(
                                assetPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}
