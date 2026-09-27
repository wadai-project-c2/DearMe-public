import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/room_models.dart';
import '../providers/item_provider.dart';
import '../providers/room_provider.dart';
import '../room/room_3d_route_visibility.dart';
import '../room/room_scene_widget.dart';
import '../room/room_scene_snapshot.dart';
import '../route_observer.dart';

class HomeScreen extends StatefulWidget {
  /// 部屋データと3Dシーンの読み込みが完了した最初の1回だけ呼ばれる。
  /// オンボーディング画面をどこまで表示し続けるか判断するために使う。
  final VoidCallback? onSceneReady;

  /// false の間はホームの3Dシーンのレンダーループを止める。
  ///
  /// ホーム画面はIndexedStack配下に置かれ、他のタブに切り替えても破棄
  /// されずマウントされたままになるため、呼び出し側（MainShellScreen）は
  /// ホームタブが実際に選択されている間だけ true を渡すこと。
  /// [RoomSceneWidget.active] を参照。
  final bool active;
  final HomeRoomSnapshotController? snapshotController;

  const HomeScreen({
    super.key,
    this.onSceneReady,
    this.active = true,
    this.snapshotController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  // RoomSceneWidgetから最初のonLoadingChanged通知が届くまでは
  // 読み込み中として扱い、オンボーディングが一瞬で消えないようにする。
  bool _sceneLoading = true;
  bool _readyNotified = false;
  late final Timer _poseSaveTimer;
  // dispose()の時点ではElementツリーが解体中でcontext.read()による祖先探索が
  // 安全でない（"Looking up a deactivated widget's ancestor is unsafe."）ため、
  // まだ安全なタイミングで参照を保持しておく。
  late RoomProvider _roomProvider;

  // ホーム画面はIndexedStack配下にいるため、他ルートがこの上に
  // push（例: 品物ロングタップ→配置編集、レイアウトアイコン→インテリア
  // カスタマイズ）されても破棄されない。RouteAwareでその期間だけ
  // 3Dシーンのレンダーループを止める（[[RoomSceneWidget.active]]）。
  // 止めないと、覆われている間も裏でレンダーが回り続け、上に乗った画面の
  // ThreeJSインスタンスとGL/テクスチャ層を奪い合って描画が壊れる。
  bool _obscuredByRoute = false;
  bool _roomPlacementVisible = roomPlacement3DVisible.value;
  final GlobalKey _sceneBoundaryKey = GlobalKey();
  bool _showAvatar = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomProvider = context.read<RoomProvider>();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    if (mounted) setState(() => _obscuredByRoute = true);
  }

  @override
  void didPopNext() {
    if (mounted) setState(() => _obscuredByRoute = false);
  }

  void _handleRoomPlacementVisibility() {
    // Placement routes notify during initState/dispose, when the widget tree
    // can be locked. Read the latest value after that transition completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visible = roomPlacement3DVisible.value;
      if (mounted && _roomPlacementVisible != visible) {
        setState(() => _roomPlacementVisible = visible);
      }
    });
  }

  void _notifyReadyOnce() {
    if (_readyNotified) return;
    _readyNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSceneReady?.call();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    roomPlacement3DVisible.addListener(_handleRoomPlacementVisibility);
    widget.snapshotController?.attach(_captureRoomWithoutAvatar);
    _poseSaveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        unawaited(_roomProvider.persistAvatarPose());
      }
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshotController != widget.snapshotController) {
      oldWidget.snapshotController?.detach();
      widget.snapshotController?.attach(_captureRoomWithoutAvatar);
    }
  }

  Future<Uint8List?> _captureRoomWithoutAvatar() async {
    if (!mounted || !widget.active || _sceneLoading) return null;
    final pixelRatio =
        MediaQuery.devicePixelRatioOf(context).clamp(1, 2).toDouble();
    setState(() => _showAvatar = false);
    // ThreeJS writes into an external texture after Flutter has rebuilt this
    // widget. Give that texture a full render/composite cycle before reading
    // the RepaintBoundary; otherwise the captured frame can still contain the
    // avatar from the previous GL frame.
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;
    Uint8List? bytes;
    try {
      final boundary = _sceneBoundaryKey.currentContext?.findRenderObject();
      if (boundary is RenderRepaintBoundary) {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        try {
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          bytes = data?.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      }
      if (bytes != null) RoomSceneSnapshotStore.instance.update(bytes);
      return bytes;
    } finally {
      if (mounted) {
        setState(() => _showAvatar = true);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && mounted) {
      unawaited(_roomProvider.persistAvatarPose());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        if (roomProvider.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (roomProvider.error != null) {
          _notifyReadyOnce();
          return const Scaffold(
            body: Center(child: Text('部屋データを読み込めませんでした')),
          );
        }
        final room = roomProvider.selectedRoom;
        if (room == null) {
          _notifyReadyOnce();
          return const Scaffold(body: Center(child: Text('表示できる部屋がありません')));
        }
        if (!_sceneLoading) {
          _notifyReadyOnce();
        }
        final assignment = roomProvider.assignmentForRoom(room.id);
        final avatar = roomProvider.avatarById(assignment?.avatarId);
        // `context.go('/')` replaces the foreground route instead of popping it.
        // In that case RouteAware may not deliver didPopNext(), leaving the
        // cached flag true even though the home route is current again.
        // Keep the flag for ordinary push/pop transitions, but never let a
        // stale value hide the scene while this route is actually current.
        final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        final obscuredByRoute = _obscuredByRoute && !routeIsCurrent;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: const Color(0xfff7eeea),
          // ソフトキーボードの分だけbodyを縮めない。この画面には入力欄が
          // 無いので縮める必要が無い一方、縮むとRoomSceneWidgetの高さが
          // 変わり、3Dシーンが丸ごと作り直されてしまう（詳しくは
          // main_shell_screen.dart の同じ指定のコメントを参照）。
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: const Text(
              'DEAR ME',
              style: TextStyle(
                color: Color(0xffd95f79),
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
              ),
            ),
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xfff7eeea), Color(0xfff7eeea)],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                  child: AnimatedSwitcher(
                    duration: Duration.zero,
                    child: !widget.active ||
                            obscuredByRoute ||
                            _roomPlacementVisible
                        ? const SizedBox.shrink()
                        : RepaintBoundary(
                            key: _sceneBoundaryKey,
                            child: RoomSceneWidget(
                              backgroundColor: const Color(0xfff7eeea),
                              cameraElevation:
                                  0.32, // About 18 degrees: show the face.
                              key: ValueKey('${room.id}:${avatar?.id}'),
                              room: room,
                              avatar: avatar,
                              assignment: assignment,
                              objects: roomProvider.objectsForRoom(room.id),
                              enableAvatarWander: true,
                              active: widget.active && !obscuredByRoute,
                              showAvatar: _showAvatar,
                              onAvatarPoseChanged:
                                  roomProvider.updateAvatarPose,
                              onLoadingChanged: (loading) {
                                if (mounted && _sceneLoading != loading) {
                                  setState(() => _sceneLoading = loading);
                                }
                              },
                              onObjectTap: (object) =>
                                  _openItem(context, object),
                              onObjectLongPress: (object) {
                                if (object.itemId != null) {
                                  context.push(
                                    '/room_placement',
                                    extra: {
                                      'itemId': object.itemId,
                                      'roomId': object.roomId,
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openItem(BuildContext context, RoomObjectModel object) {
    final itemId = object.itemId;
    if (itemId == null) {
      return;
    }
    final item = context.read<ItemProvider>().itemById(itemId);
    if (item != null) {
      context.push('/item_detail', extra: item);
    }
  }

  @override
  void dispose() {
    _poseSaveTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    roomPlacement3DVisible.removeListener(_handleRoomPlacementVisibility);
    widget.snapshotController?.detach();
    unawaited(_roomProvider.persistAvatarPose());
    super.dispose();
  }
}
