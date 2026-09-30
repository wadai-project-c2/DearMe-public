import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as three;

import '../models/avatar_model.dart';
import '../models/room_models.dart';
import 'avatar_animation_lifecycle.dart';
import 'avatar_animation_tracks.dart';
import 'avatar_materials.dart';
import 'avatar_pose_transition.dart';
import 'avatar_wander_controller.dart';
import 'furniture_placement.dart';
import 'item_silhouette.dart';
import 'presented_item_dimensions.dart';
import 'room_calibration.dart';
import 'room_surface_elevations.dart';
import 'room_walkability.dart';
import 'silhouette_puff_geometry.dart';

class _AvatarAnimationAsset {
  final String assetPath;
  final List<String> preferredClipNames;
  final double authoredHeight;
  final double authoredMinY;

  const _AvatarAnimationAsset(
    this.assetPath,
    this.preferredClipNames, {
    required this.authoredHeight,
    required this.authoredMinY,
  });
}

const _girl1AnimationAssets = <AvatarWanderAnimation, _AvatarAnimationAsset>{
  AvatarWanderAnimation.walk: _AvatarAnimationAsset(
    'assets/animation/3d/girl1_walk_matching.glb',
    ['girl1_walk_matching'],
    authoredHeight: 2.005,
    authoredMinY: -1.0025,
  ),
  AvatarWanderAnimation.turnLeft: _AvatarAnimationAsset(
    'assets/animation/3d/girl1_left.glb',
    ['mixamo.com', 'girl1_left', 'left', 'turn_left'],
    authoredHeight: 2.005,
    authoredMinY: -1.0025,
  ),
  AvatarWanderAnimation.turnRight: _AvatarAnimationAsset(
    'assets/animation/3d/girl1_left.glb',
    ['mixamo.com', 'girl1_left', 'left', 'turn_left'],
    authoredHeight: 2.005,
    authoredMinY: -1.0025,
  ),
  AvatarWanderAnimation.lookAround: _AvatarAnimationAsset(
    'assets/animation/3d/girl1_lookaround.glb',
    ['mixamo.com', 'girl1_lookaround', 'lookaround', 'lookaroud', 'idle'],
    authoredHeight: 2.005,
    authoredMinY: -1.0025,
  ),
};

const _simpleRoomCarpetAsset =
    'assets/textures/room/original_cloud_spirits_carpet-v2.png';
const _furnitureTextureAssets = <String, String>{
  'table': 'assets/textures/furniture/light_oak.png',
  'sofa': 'assets/textures/furniture/blush_woven_fabric.png',
  'metal_chair': 'assets/textures/furniture/brushed_steel.png',
};
const _sofaCushionTextureAsset =
    'assets/textures/furniture/butter_yellow_woven_fabric.png';

class RoomSceneWidget extends StatelessWidget {
  final Color backgroundColor;
  final RoomModel room;
  final AvatarModel? avatar;
  final RoomAvatarAssignmentModel? assignment;
  final List<RoomObjectModel> objects;
  final RoomObjectModel? draftObject;
  final ValueChanged<RoomObjectModel>? onObjectTap;
  final ValueChanged<RoomObjectModel>? onObjectLongPress;
  final GestureScaleStartCallback? onSceneScaleStart;
  final ValueChanged<Offset>? onSceneDragUpdate;
  final GestureScaleUpdateCallback? onSceneScaleUpdate;
  final GestureScaleEndCallback? onSceneScaleEnd;
  final VoidCallback? onAvatarLongPress;
  final ValueChanged<bool>? onLoadingChanged;
  final bool enableAvatarWander;
  final ValueChanged<RoomAvatarAssignmentModel>? onAvatarPoseChanged;
  final bool draftPlacementValid;
  final bool showPlacementGrid;
  final double cameraDistanceScale;
  final double cameraTargetYOffset;
  final double? cameraElevation;

  /// true にすると、既存のシーンを作り直さずに（＝ローディングスピナーを出さずに）
  /// アバターを喜びポーズのアニメーション（`{avatarId}_joy.glb`）へ一時的に差し替える。
  /// この値は _RoomSceneCanvas の再構築キーには含めない。
  final bool celebrateAvatar;

  /// false の間はレンダーループ（`ThreeJS`のTicker）を止める。
  ///
  /// `RoomSceneWidget`はIndexedStack配下（例: ホーム画面）に置かれることが
  /// あり、その場合タブを切り替えても破棄されずマウントされたままになる。
  /// `ThreeJS`自身にはレンダーループを止める仕組みが無いため、非表示になった
  /// 画面のシーンがバックグラウンドで無条件に毎フレーム描画され続け、他の
  /// 画面（品物のスワイプ配置画面など）が同時に使うGL/テクスチャ層と競合して
  /// 描画が壊れる原因になっていた。呼び出し側は自分のタブ/ルートが実際に
  /// 画面に出ている間だけ true を渡すこと。
  final bool active;

  /// false hides every regular/animated avatar mesh while retaining the room.
  /// Used briefly while Home captures the static registration-flow backdrop.
  final bool showAvatar;

  const RoomSceneWidget({
    super.key,
    this.backgroundColor = const Color(0xfffff8fb),
    required this.room,
    this.avatar,
    this.assignment,
    this.objects = const [],
    this.draftObject,
    this.onObjectTap,
    this.onObjectLongPress,
    this.onSceneScaleStart,
    this.onSceneDragUpdate,
    this.onSceneScaleUpdate,
    this.onSceneScaleEnd,
    this.onAvatarLongPress,
    this.onLoadingChanged,
    this.enableAvatarWander = false,
    this.onAvatarPoseChanged,
    this.draftPlacementValid = true,
    this.showPlacementGrid = false,
    this.cameraDistanceScale = 1.0,
    this.cameraTargetYOffset = 0.0,
    this.cameraElevation,
    this.celebrateAvatar = false,
    this.active = true,
    this.showAvatar = true,
  });

  /// 次に開くルームシーンで使うGLBを先読みしておく。
  ///
  /// メモ入力中のアイドル時間などを使って、まだ画面が作られる前に
  /// GlbParsePrewarm へパースを仕込んでおくための入口。ここで挙げる
  /// 組み合わせは _setupScene / _addFurnitureForRoom が実際に
  /// _loadGlbData へ渡すものと完全に一致させる必要がある（assetPath・
  /// assetVersionの片方でもずれると先読みキャッシュキーが外れて無駄になる）。
  /// girl1の歩行等アニメーションGLB（assets/animation/3d/girl1_*.glb）は
  /// セットアップ完了後にバックグラウンドで読み込まれるものでクリティカル
  /// パース候補ではないため、ここでは先読みしない。
  static void prewarmRoomSceneAssets({
    required RoomModel room,
    AvatarModel? avatar,
  }) {
    GlbParsePrewarm.request(room.assetPath, room.assetVersion);
    for (final furniture in FurniturePlacements.forRoom(room.id)) {
      final assetPath = furniture.assetPath;
      if (assetPath != null) {
        GlbParsePrewarm.request(assetPath, furniture.assetVersion);
      }
    }
    // アバター本体GLBは、いまは意図的に先読みしない。
    //
    // 前提として、ホーム画面以外（スワイプ配置画面・インテリアカスタマイズ
    // 画面）ではアバターがそもそも正しく描画されないという既存の不具合が
    // ある（Issue #115）。実機（OPG04/OPG06）での調査で、当初の仮説
    // 「enableAvatarWander が偽の画面ではAnimationMixerが動かずSkinnedMesh
    // のボーン行列が更新されない」は誤りと判明済み： アバター本体
    // （girl1.glb の Mesh_0）はそもそもSkinnedMeshではなく通常のMesh。
    // また「ホーム画面のThreeJSがIndexedStack配下でタブ切替後も破棄されず
    // レンダーループが回り続け、他画面のGL/テクスチャ層と競合する」という
    // 仮説から active フラグ（[RoomSceneWidget.active]）でホームのレンダー
    // ループを止める修正を入れたが、それでもインテリアカスタマイズ画面での
    // アバター不在は解消しなかった。根本原因は three_js_angle_renderer
    // パッケージのGL描画コマンド発行部分に絞られているが未特定（詳細は
    // Issue #115 のコメント参照）。
    //
    // つまりアバターが壊れるのは先読みのせいではないが、「アバターが正しく
    // 描画される画面」で先読みの安全性を確認する手段が現状ないため、
    // 検証できない最適化は入れない方針でここでは対象外にしている。
    // 上記の既存不具合が解消されたら、アバターも先読み対象に加えられるか
    // を再評価すること（スワイプ配置画面の実測で、アバターを含めた場合は
    // シーン構築が0.92秒まで縮み、除いた場合は1.50秒だった）。
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final renderObjects = <RoomObjectModel>[
          ...objects.where(
            (object) => object.objectId != draftObject?.objectId,
          ),
          if (draftObject != null) draftObject!,
        ];
        // 部屋・アバター・家具の構成が変わった時だけシーンを作り直す。
        // 品物（renderObjects）の増減・差し替えは _RoomSceneCanvas.didUpdateWidget
        // が既存キャンバスへ差分適用するため、ここには含めない（含めると品物を
        // 1つ置くたびに全GLBを読み直すことになり、配置直後に長いローディング
        // スピナーが出る原因になっていた）。
        final assetIdentity = [
          backgroundColor.toARGB32(),
          room.id,
          room.assetVersion,
          avatar?.id,
          avatar?.assetVersion,
          cameraDistanceScale,
          cameraTargetYOffset,
          cameraElevation,
          showPlacementGrid,
          for (final furniture in FurniturePlacements.forRoom(room.id))
            '${furniture.id}:${furniture.assetPath}:'
                '${furniture.assetVersion}',
        ].join('|');

        return _RoomSceneCanvas(
          backgroundColor: backgroundColor,
          key: ValueKey(assetIdentity),
          size: Size(width, height),
          room: room,
          avatar: avatar,
          assignment: assignment,
          objects: renderObjects,
          draftObject: draftObject,
          onObjectTap: onObjectTap,
          onObjectLongPress: onObjectLongPress,
          onSceneScaleStart: onSceneScaleStart,
          onSceneDragUpdate: onSceneDragUpdate,
          onSceneScaleUpdate: onSceneScaleUpdate,
          onSceneScaleEnd: onSceneScaleEnd,
          onAvatarLongPress: onAvatarLongPress,
          onLoadingChanged: onLoadingChanged,
          enableAvatarWander: enableAvatarWander,
          onAvatarPoseChanged: onAvatarPoseChanged,
          draftPlacementValid: draftPlacementValid,
          showPlacementGrid: showPlacementGrid,
          cameraDistanceScale: cameraDistanceScale,
          cameraTargetYOffset: cameraTargetYOffset,
          cameraElevation: cameraElevation,
          celebrateAvatar: celebrateAvatar,
          active: active,
          showAvatar: showAvatar,
        );
      },
    );
  }
}

class _RoomSceneCanvas extends StatefulWidget {
  final double? cameraElevation;
  final Color backgroundColor;
  final Size size;
  final RoomModel room;
  final AvatarModel? avatar;
  final RoomAvatarAssignmentModel? assignment;
  final List<RoomObjectModel> objects;
  final RoomObjectModel? draftObject;
  final ValueChanged<RoomObjectModel>? onObjectTap;
  final ValueChanged<RoomObjectModel>? onObjectLongPress;
  final GestureScaleStartCallback? onSceneScaleStart;
  final ValueChanged<Offset>? onSceneDragUpdate;
  final GestureScaleUpdateCallback? onSceneScaleUpdate;
  final GestureScaleEndCallback? onSceneScaleEnd;
  final VoidCallback? onAvatarLongPress;
  final ValueChanged<bool>? onLoadingChanged;
  final bool enableAvatarWander;
  final ValueChanged<RoomAvatarAssignmentModel>? onAvatarPoseChanged;
  final bool draftPlacementValid;
  final bool showPlacementGrid;
  final double cameraDistanceScale;
  final double cameraTargetYOffset;
  final bool celebrateAvatar;
  final bool active;
  final bool showAvatar;

  const _RoomSceneCanvas({
    super.key,
    required this.backgroundColor,
    required this.size,
    required this.room,
    required this.avatar,
    required this.assignment,
    required this.objects,
    required this.draftObject,
    required this.onObjectTap,
    required this.onObjectLongPress,
    required this.onSceneScaleStart,
    required this.onSceneDragUpdate,
    required this.onSceneScaleUpdate,
    required this.onSceneScaleEnd,
    required this.onAvatarLongPress,
    required this.onLoadingChanged,
    required this.enableAvatarWander,
    required this.onAvatarPoseChanged,
    required this.draftPlacementValid,
    required this.showPlacementGrid,
    required this.cameraDistanceScale,
    required this.cameraTargetYOffset,
    required this.cameraElevation,
    required this.celebrateAvatar,
    required this.active,
    required this.showAvatar,
  });

  @override
  State<_RoomSceneCanvas> createState() => _RoomSceneCanvasState();
}

class _RoomSceneCanvasState extends State<_RoomSceneCanvas>
    with WidgetsBindingObserver {
  late three.ThreeJS _threeJs;
  final three.Raycaster _raycaster = three.Raycaster();
  final List<three.Object3D> _pickableObjects = [];
  final Map<String, three.Object3D> _objectMeshes = {};
  final Map<String, RoomObjectModel> _objectModels = {};
  final Map<String, three.Object3D> _furnitureRootsByAssetKey = {};
  final Set<int> _scenePointers = <int>{};
  // _reconcileObjects は品物と無関係な理由（他プロパティの変更等）でも
  // 再入されうる。_addImagePlane の完了前は _objectMeshes にまだ現れない
  // ため、進行中の読込を別途ここで追跡し、同じ品物の二重読込
  // （孤立した重複メッシュの原因になる）を防ぐ。
  final Set<String> _pendingObjectLoads = {};
  three.Object3D? _avatarRoot;
  double _avatarHeight = 0;
  three.Object3D? _idleAvatarScene;
  final Map<AvatarWanderAnimation, three.Object3D> _avatarAnimationScenes = {};
  final Map<AvatarWanderAnimation, three.AnimationMixer>
      _avatarAnimationMixers = {};
  final Map<AvatarWanderAnimation, three.AnimationAction>
      _avatarAnimationActions = {};
  AvatarWanderAnimation? _activeAvatarAnimation;
  final _avatarPoseTransition = AvatarPoseTransition();
  AvatarWanderController? _wanderController;
  AvatarWanderPose? _lastWanderPose;
  double _poseCallbackElapsed = 0;
  three.Group? _validCellsGroup;
  final List<three.Object3D> _placementGridMeshes = [];
  three.Group? _invalidCellsGroup;
  three.Group? _draftMoveArrows;
  bool _isLoading = true;
  bool _firstFrameRendered = false;
  bool _animationsPaused = false;
  bool _appIsResumed = true;
  bool _isDisposed = false;
  bool _renderScheduled = false;
  bool _renderInProgress = false;
  bool _renderAgain = false;
  Object? _error;

  three.AnimationMixer? _celebrationMixer;
  three.AnimationAction? _celebrationAction;
  bool _celebrationRequested = false;
  int _celebrationGeneration = 0;

  bool get _usesEventDrivenRendering =>
      widget.showPlacementGrid && widget.avatar == null;

  void _requestRender() {
    if (_renderInProgress) {
      _renderAgain = true;
      return;
    }
    if (!_usesEventDrivenRendering ||
        _renderScheduled ||
        _isDisposed ||
        _isLoading ||
        !mounted ||
        !_threeJs.mounted) {
      return;
    }
    _renderScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _renderScheduled = false;
      if (_isDisposed || !mounted || !_threeJs.mounted || !widget.active) {
        return;
      }
      _renderInProgress = true;
      try {
        await _threeJs.render();
      } catch (error) {
        debugPrint(
          '[RoomScene] event-driven render failed '
          'type=${error.runtimeType}',
        );
      } finally {
        _renderInProgress = false;
        if (_renderAgain) {
          _renderAgain = false;
          _requestRender();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createRenderer();
  }

  @override
  void didUpdateWidget(covariant _RoomSceneCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _syncSceneActivity();
    }
    if (widget.showAvatar != oldWidget.showAvatar) {
      _syncAvatarVisibility();
    }
    if (_wanderController == null) {
      _applyAvatarTransform(widget.assignment);
    }
    _reconcileObjects();
    _updateDraftCellIndicator();
    _requestRender();
    if (widget.celebrateAvatar != oldWidget.celebrateAvatar) {
      if (widget.celebrateAvatar) {
        if (!_celebrationRequested) {
          _celebrationRequested = true;
          unawaited(_startAvatarCelebration());
        }
      } else {
        _stopAvatarCelebration();
      }
    }
  }

  /// `widget.objects` の増減・変更を、シーンを作り直さずに既存キャンバスへ
  /// 反映する。`_isLoading` の間は `_threeJs.scene` がまだ準備できていない
  /// 可能性があるため何もせず、`_setupScene` 側の初期ロードに委ねる
  /// （そちらの完了後に一度呼び直して取りこぼしを拾う）。
  void _reconcileObjects() {
    if (_isLoading) {
      return;
    }
    final incomingObjects = widget.objects;
    final incomingIds =
        incomingObjects.map((object) => object.objectId).toSet();

    final removedIds = _objectMeshes.keys
        .where((objectId) => !incomingIds.contains(objectId))
        .toList(growable: false);
    for (final objectId in removedIds) {
      final mesh = _objectMeshes.remove(objectId);
      _objectModels.remove(objectId);
      if (mesh != null) {
        _pickableObjects.remove(mesh);
        mesh.removeFromParent();
      }
    }

    for (final object in incomingObjects) {
      var mesh = _objectMeshes[object.objectId];
      final previous = _objectModels[object.objectId];
      if (mesh == null && object.isFurniture && object.assetKey != null) {
        mesh = _furnitureRootsByAssetKey[object.assetKey!];
        if (mesh != null) {
          mesh.userData['roomObjectId'] = object.objectId;
          _objectMeshes[object.objectId] = mesh;
          _objectModels[object.objectId] = object;
          if (!_pickableObjects.contains(mesh)) {
            _pickableObjects.add(mesh);
          }
          _threeJs.scene.add(mesh);
        }
      }
      if (mesh == null) {
        _loadRoomObject(object);
        continue;
      }
      final needsReload = previous != null &&
          (previous.objectType != object.objectType ||
              previous.assetKey != object.assetKey ||
              previous.localAssetPath != object.localAssetPath ||
              previous.originalWidth != object.originalWidth ||
              previous.originalHeight != object.originalHeight);
      if (needsReload) {
        _pickableObjects.remove(mesh);
        mesh.removeFromParent();
        _objectMeshes.remove(object.objectId);
        _objectModels.remove(object.objectId);
        _loadRoomObject(object);
        continue;
      }
      // Provider records are immutable. Do not traverse unchanged furniture
      // geometry on every drag tick; tabletop items also depend on the table.
      if (identical(previous, object) &&
          object.placementSurface != PlacementSurface.tabletop) {
        continue;
      }
      _applyObjectTransform(mesh, object);
      _objectModels[object.objectId] = object;
    }
    _wanderController?.updateObstacles(_avatarObstacleAreas(incomingObjects));
  }

  List<ObstacleArea> _avatarObstacleAreas(
    Iterable<RoomObjectModel> objects,
  ) {
    final calibration = RoomCalibrations.forRoom(widget.room.id);
    final dynamicAreas = <ObstacleArea>[];
    for (final object in objects.where(RoomWalkability.blocksWalking)) {
      final rendered = _objectMeshes[object.objectId];
      if (rendered != null) {
        rendered.updateMatrixWorld(true);
        final bounds = three.BoundingBox().setFromObject(rendered, true);
        if (bounds.min.x.isFinite &&
            bounds.max.x.isFinite &&
            bounds.min.z.isFinite &&
            bounds.max.z.isFinite) {
          dynamicAreas.add(
            ObstacleArea(
              minX: bounds.min.x,
              maxX: bounds.max.x,
              minZ: bounds.min.z,
              maxZ: bounds.max.z,
            ),
          );
          continue;
        }
      }
      dynamicAreas.addAll(
        RoomWalkability.obstacleAreasForObjects(calibration, [object]),
      );
    }
    return calibration.roomId == 'simple_room'
        ? dynamicAreas
        : [...calibration.obstacleAreas, ...dynamicAreas];
  }

  void _loadRoomObject(RoomObjectModel object) {
    if (!_pendingObjectLoads.add(object.objectId)) return;
    if (object.isFurniture) {
      unawaited(
        _addFurnitureObject(object)
            .whenComplete(() => _pendingObjectLoads.remove(object.objectId)),
      );
    } else {
      unawaited(_addImagePlane(object));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    _syncSceneActivity(emitPoseWhenPaused: true);
  }

  void _syncSceneActivity({bool emitPoseWhenPaused = false}) {
    final shouldRun = shouldRunRoomScene(
      isAppResumed: _appIsResumed,
      isWidgetActive: widget.active,
    );
    debugPrint(
      '[RoomScene][lifecycle] appResumed=$_appIsResumed '
      'active=${widget.active} shouldRun=$shouldRun',
    );
    _animationsPaused = !shouldRun;
    _threeJs.visible = shouldRun;
    if (shouldRun) {
      _wanderController?.resume();
      _requestRender();
    } else {
      _wanderController?.pause();
      if (emitPoseWhenPaused) {
        _emitAvatarPose(force: true);
      }
      // アプリ全体が裏に回っている間（カメラアプリ起動中など）も
      // レンダーループ（Ticker）は止まらず毎フレームGPUに描画コマンドを
      // 発行し続けていた。カメラ撮影中にGPUバッファのタイムアウトや
      // フレーム落ちが発生し、OSのLOW_MEMORYキルの引き金の一つになって
      // いたため、フォアグラウンドに戻るまで描画を止める。
    }
  }

  void _syncAvatarVisibility() {
    final root = _avatarRoot;
    if (root == null) return;
    root.visible = widget.showAvatar &&
        shouldRestoreRegularAvatar(
          celebrationRequested: widget.celebrateAvatar,
          hasCelebrationMixer: _celebrationMixer != null,
        );
    _requestRender();
  }

  void _createRenderer() {
    debugPrint(
      '[RoomScene][timing] _createRenderer start '
      'room=${widget.room.id} avatarId=${widget.avatar?.id} '
      'assignmentAvatarId=${widget.assignment?.avatarId} '
      'objects=${widget.objects.length} '
      'at=${DateTime.now().toIso8601String()}',
    );
    _isLoading = true;
    _firstFrameRendered = false;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onLoadingChanged?.call(true);
      }
    });
    _threeJs = three.ThreeJS(
      size: widget.size,
      settings: three.Settings(
        clearColor: widget.backgroundColor.toARGB32() & 0xffffff,
        antialias: true,
        enableShadowMap: false, // 負荷軽減のためオフ
        screenResolution: widget.showPlacementGrid ? 0.75 : 1.5,
      ),
      loadingWidget: ColoredBox(
        color: widget.backgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      ),
      setup: _setupScene,
      onSetupComplete: _handleSetupComplete,
    );
    _threeJs.visible = widget.active;
  }

  // three_jsのloadingWidget（クルクル）は、GLテクスチャに最初の1フレームが
  // 描画されるまで画面に残る。onSetupCompleteはGLBのロードとシーン構築が
  // 終わった時点で呼ばれるだけなので、ここで完了扱いにするとクルクルが
  // 出たままオンボーディングが消えてしまう。
  // レンダーループのイベントは1フレーム描画し終えた後に呼ばれるため、
  // それを1回だけ拾って「本当に3Dが見えた」タイミングを検知する。
  void _handleSetupComplete() {
    if (!mounted || !context.mounted) {
      return;
    }
    if (_error != null) {
      // 描画は始まらないのでエラー表示に切り替えて即座に完了扱いにする。
      _finishLoading();
      return;
    }
    _threeJs.addAnimationEvent(_handleFirstRenderedFrame);
  }

  void _handleFirstRenderedFrame(double _) {
    if (_firstFrameRendered) {
      return;
    }
    _firstFrameRendered = true;
    if (_usesEventDrivenRendering) {
      _threeJs.settings.animate = false;
    }
    // テクスチャの更新がFlutter側で合成されるのは次のフレームなので、
    // 1フレーム待ってからクルクルを外す。
    WidgetsBinding.instance.addPostFrameCallback((_) => _finishLoading());
  }

  void _finishLoading() {
    if (_isDisposed || !mounted || !_isLoading) {
      return;
    }
    setState(() => _isLoading = false);
    widget.onLoadingChanged?.call(false);
    // セットアップの非同期処理中に widget.objects が更新されていた場合に
    // 取りこぼしがないよう、ロード完了後に一度だけ差分を拾い直す。
    // _reconcileObjects は _isLoading が真の間は何もしないため、必ず
    // _isLoading を false にした後に呼ぶ必要がある。
    _reconcileObjects();
  }

  Future<void> _setupScene() async {
    final calibration = RoomCalibrations.forRoom(widget.room.id);
    _threeJs.scene = three.Scene();
    final aspect = widget.size.width / widget.size.height;
    // 望遠効果（低FOV + 遠距離）により、平行投影に近い見た目を実現しつつ自然な立体感を出す
    _threeJs.camera = three.PerspectiveCamera(
      25, // FOVを絞って歪みを抑制
      aspect,
      calibration.near,
      calibration.far,
    );
    // The room, furniture, windows and carpets share one world transform, so
    // every screen must also share the same calibrated camera. Fitting only
    // the placement grid changed both distance and target and made the room
    // appear stretched/cropped even though its model transform was identical.
    // This retains real_ios's single-camera behavior; placement controls may
    // opt into an explicit distance/target offset without changing the base.
    final cameraPose = calibration.cameraPose(
      distanceScale: widget.cameraDistanceScale,
      targetYOffset: widget.cameraTargetYOffset,
      elevation: widget.cameraElevation,
    );
    _threeJs.camera.position.setValues(
      cameraPose.position.x,
      cameraPose.position.y,
      cameraPose.position.z,
    );
    _threeJs.camera.lookAt(
      three.Vector3(
        cameraPose.target.x,
        cameraPose.target.y,
        cameraPose.target.z,
      ),
    );

    final hemisphere = three.HemisphereLight(0xffffff, 0xebf2ff, 0.65);
    _threeJs.scene.add(hemisphere);

    final keyLight = three.DirectionalLight(0xffffff, 0.8);
    keyLight.position.setValues(-5, 10, 5);
    _threeJs.scene.add(keyLight);

    final fillLight = three.DirectionalLight(0xffeee8, 0.25);
    fillLight.position.setValues(4, 4, -2);
    _threeJs.scene.add(fillLight);

    // 影なしでもディテールが見えるよう環境光を調整
    final ambientLight = three.AmbientLight(0xffffff, 0.2);
    _threeJs.scene.add(ambientLight);

    try {
      final avatar = widget.avatar;
      final assignment = widget.assignment;
      // アバター本体GLBのパースが最も重い（実測で約1.9秒、部屋・家具の
      // 合計より長い）。パース自体はthree_jsのGLTFLoaderがcompute()で
      // 別Isolateへ逃がすため、部屋・家具の読込を待たずに今すぐ並行して
      // 読み始めておく。実際に使うのは高さ正規化のタイミング（roomBounds
      // が要る）まで待つが、読込自体はその間ずっとバックグラウンドで
      // 進んでいる。
      final avatarLoadStart = DateTime.now();
      final avatarSceneFuture = avatar?.assetPath != null && assignment != null
          ? _loadGlb(avatar!.assetPath!, avatar.assetVersion)
          : null;

      final roomScene = await _loadGlb(
        widget.room.assetPath,
        widget.room.assetVersion,
      );
      // pinkroom.glb contains a preview avatar in addition to the room.
      // The selected avatar is loaded separately below, so do not render both.
      if (widget.room.id == RoomCalibrations.pink.roomId) {
        roomScene.getObjectByName('Mesh_0')?.removeFromParent();
      }
      final roomBounds = _normalizeToExtent(
        roomScene,
        calibration.roomTargetExtent,
        const SceneVector3(0, 0, 0),
      );
      _threeJs.scene.add(roomScene);

      if (widget.room.id == RoomCalibrations.simple.roomId) {
        _addWallThickness(
            roomBounds, roomScene.getObjectByName('Cube')?.material);
      }
      await _addFurnitureForRoom(widget.room.id);

      if (avatarSceneFuture != null && assignment != null) {
        final avatarScene = await avatarSceneFuture;
        debugPrint(
          '[RoomScene][timing] avatar body ready '
          '${DateTime.now().difference(avatarLoadStart).inMilliseconds}ms '
          'after setup started (loaded concurrently with room/furniture)',
        );
        final roomSize = roomBounds.getSize(three.Vector3());
        final avatarHeight = (roomSize.y * calibration.avatarHeightRatio)
            .clamp(0.40, 2.76)
            .toDouble();
        _avatarHeight = avatarHeight;
        _normalizeToHeight(avatarScene, avatarHeight);
        final avatarRoot = three.Group();
        avatarRoot.userData['sceneType'] = 'avatar';
        avatarRoot.add(avatarScene);
        _idleAvatarScene = avatarScene;
        _avatarRoot = avatarRoot;
        avatarRoot.visible = widget.showAvatar;
        _applyAvatarTransform(assignment);
        _threeJs.scene.add(avatarRoot);
        if (widget.enableAvatarWander) {
          if (avatar!.id == 'girl1') {
            // Complete first-use GPU work behind the loading screen, not on
            // the first visible transition from lookAround to turn/walk.
            await _loadGirl1Animations(avatarRoot, avatarHeight);
            if (_isDisposed || !mounted) return;
            _warmAvatarAnimationRendering();
          }
          _wanderController = AvatarWanderController(
            bounds: calibration.avatarBounds,
            obstacles: _avatarObstacleAreas(widget.objects),
            floorY: calibration.floorY,
            speed: calibration.avatarWalkSpeed,
            avatarHeight: avatarHeight,
            collisionPadding: calibration.avatarCollisionPadding,
            initialX: assignment.posX,
            initialZ: assignment.posZ,
            initialRotationY: assignment.rotationY,
            fallbackX: calibration.avatarSpawn.x,
            fallbackZ: calibration.avatarSpawn.z,
          );
          _activateAvatarAnimation(
            _wanderController!.pose.animation,
            _wanderController!.pose.rotationY,
          );
          _avatarAnimationMixers[_wanderController!.pose.animation]?.update(0);
          _threeJs.addAnimationEvent(_updateAvatarWander);
        }
        _threeJs.addAnimationEvent(_updateCelebrationMixer);
        if (widget.celebrateAvatar && !_celebrationRequested) {
          _celebrationRequested = true;
          unawaited(_startAvatarCelebration());
        }
      }

      // 思い出画像はここでは読み込みを開始しない。
      // awaitしなくてもTextureLoaderがthree_js共通のLoadingManagerへ登録され、
      // onSetupComplete（ひいては初回描画）を止めるためである。
      // 初回描画後に_finishLoadingから呼ばれる_reconcileObjectsが遅延追加する。
      _addDraftCellIndicator(calibration);
    } catch (error, stackTrace) {
      debugPrint(
        '[RoomScene] setup failed type=${error.runtimeType}\n$stackTrace',
      );
      _error = error;
    }
  }

  Future<three.Object3D> _loadGlb(String assetPath, int assetVersion) async {
    return (await _loadGlbData(assetPath, assetVersion)).scene;
  }

  Future<three.GLTFData> _loadGlbData(
    String assetPath,
    int assetVersion,
  ) async {
    // メモ入力画面などのアイドル時間中に先読みが仕込まれていれば、それを
    // 待つだけで済ませる（＝譲渡してもらう）。無ければ通常通りその場で
    // パースする。GlbParsePrewarm.take() は呼んだ瞬間にMapから取り除かれる
    // ため、この _RoomSceneCanvas 以外がこのGLTFDataを使うことはない。
    final prewarmed = GlbParsePrewarm.take(assetPath, assetVersion);
    if (prewarmed != null) {
      final waitStart = DateTime.now();
      final data = await prewarmed;
      debugPrint(
        '[RoomScene][timing] $assetPath: prewarmed (waited '
        '${DateTime.now().difference(waitStart).inMilliseconds}ms)',
      );
      return data;
    }
    return _parseGlb(assetPath, assetVersion, source: 'on-demand');
  }

  void _updateCelebrationMixer(double deltaTime) {
    if (_isDisposed || _animationsPaused || !widget.active) {
      return;
    }
    _celebrationMixer?.update(deltaTime.clamp(0, 0.05));
  }

  /// アバターを喜びポーズ（`{avatarId}_joy.glb`、スキン付きボーンアニメーション）に
  /// 一時的に差し替える。既存の ThreeJS/Scene インスタンスは作り直さない
  /// （＝ローディングスピナーを出さない）。対応アセットが無いアバターでは
  /// 何も起きず静かにスキップする。
  Future<void> _startAvatarCelebration() async {
    final avatar = widget.avatar;
    final avatarRoot = _avatarRoot;
    final assignment = widget.assignment;
    if (avatar == null || avatarRoot == null || assignment == null) {
      _celebrationRequested = false;
      return;
    }
    _stopAvatarCelebration();
    _celebrationRequested = true;
    final generation = ++_celebrationGeneration;

    final assetPath = 'assets/animation/3d/${avatar.id}_joy.glb';
    try {
      final data = await _loadGlbData(assetPath, avatar.assetVersion);
      if (!mounted ||
          !widget.celebrateAvatar ||
          generation != _celebrationGeneration) {
        return;
      }
      final animations = data.animations;
      if (animations == null || animations.isEmpty) {
        return;
      }
      final celebrationScene = data.scene;
      _normalizeToHeight(celebrationScene, _avatarHeight);

      final celebrationRoot = three.Group();
      celebrationRoot.name = 'avatarCelebrationRoot';
      celebrationRoot.userData['sceneType'] = 'avatarCelebration';
      celebrationRoot.add(celebrationScene);
      celebrationRoot.position.setValues(
        avatarRoot.position.x,
        avatarRoot.position.y,
        avatarRoot.position.z,
      );
      celebrationRoot.scale.setValues(
        assignment.scaleX,
        assignment.scaleY,
        assignment.scaleZ,
      );
      celebrationRoot.rotation.set(
        assignment.rotationX,
        assignment.rotationY,
        assignment.rotationZ,
      );
      celebrationRoot.updateMatrixWorld(true);

      final mixer = three.AnimationMixer(celebrationScene);
      final sourceClip = animations.first as three.AnimationClip;
      final inPlaceTracks = sourceClip.tracks
          .where((track) => isInPlaceAvatarAnimationTrack(track.name))
          .toList(growable: false);
      if (inPlaceTracks.isEmpty) {
        return;
      }
      final inPlaceClip = three.AnimationClip(
        sourceClip.name,
        sourceClip.duration,
        inPlaceTracks,
      );
      final action = mixer.clipAction(inPlaceClip);
      if (action == null) {
        return;
      }
      action.play();

      if (!mounted ||
          !widget.celebrateAvatar ||
          generation != _celebrationGeneration) {
        _releaseMixerAction(mixer, action);
        return;
      }

      avatarRoot.visible = false;
      _threeJs.scene.add(celebrationRoot);
      _celebrationMixer = mixer;
      _celebrationAction = action;
    } catch (error) {
      debugPrint(
        '[RoomScene][celebration] skipped asset=$assetPath '
        'type=${error.runtimeType}',
      );
    }
  }

  void _stopAvatarCelebration() {
    _celebrationRequested = false;
    _celebrationGeneration++;
    try {
      _threeJs.scene
          .getObjectByName('avatarCelebrationRoot')
          ?.removeFromParent();
    } catch (_) {
      // setup完了前はsceneがまだ初期化されていない場合がある。
    }
    final mixer = _celebrationMixer;
    final action = _celebrationAction;
    if (mixer != null && action != null) {
      _releaseMixerAction(mixer, action);
    }
    _celebrationAction = null;
    _celebrationMixer = null;
    _avatarRoot?.visible = widget.showAvatar;
    _requestRender();
  }

  void _warmAvatarAnimationRendering() {
    final renderer = _threeJs.renderer;
    final root = _avatarRoot;
    if (renderer == null || root == null) return;
    final target = three.RenderTarget(64, 64);
    final previousTarget = renderer.getRenderTarget();
    final wasVisible = root.visible;
    final idleWasVisible = _idleAvatarScene?.visible;
    try {
      root.visible = true;
      _idleAvatarScene?.visible = false;
      renderer.setRenderTarget(target);
      for (final entry in _avatarAnimationScenes.entries) {
        final action = _avatarAnimationActions[entry.key];
        if (action == null) continue;
        entry.value.visible = true;
        action.reset().play();
        _avatarAnimationMixers[entry.key]?.update(0);
        try {
          // A real offscreen draw uploads skinning buffers and textures as
          // well as compiling shaders. Never publish this target to Flutter.
          renderer.render(_threeJs.scene, _threeJs.camera);
        } finally {
          action.stop();
          entry.value.visible = false;
        }
      }
      debugPrint('[RoomScene][avatar-animation] GPU warm-up complete');
    } finally {
      root.visible = wasVisible;
      if (idleWasVisible != null) _idleAvatarScene?.visible = idleWasVisible;
      renderer.setRenderTarget(previousTarget);
      target.dispose();
    }
  }

  Future<void> _loadGirl1Animations(
    three.Object3D avatarRoot,
    double avatarHeight,
  ) async {
    // 3本は互いに独立しているので、順番にawaitせず並行して読み込む
    // （家具・アバター本体と同じ理由：GLTFLoaderがcompute()で別Isolateへ
    // パースを逃がすため、束ねて投げるとCPUコアをまたいで並列に進む）。
    await Future.wait(
      _girl1AnimationAssets.entries.map(
        (entry) => _loadSingleGirl1Animation(avatarRoot, avatarHeight, entry),
      ),
    );
  }

  Future<void> _loadSingleGirl1Animation(
    three.Object3D avatarRoot,
    double avatarHeight,
    MapEntry<AvatarWanderAnimation, _AvatarAnimationAsset> entry,
  ) async {
    if (!mounted) {
      return;
    }
    try {
      final data = await _loadGlbData(entry.value.assetPath, 1);
      if (_isDisposed || !mounted || _avatarRoot != avatarRoot) {
        return;
      }
      final clips = (data.animations ?? const [])
          .whereType<three.AnimationClip>()
          .toList(growable: false);
      final sourceClip = _resolveAnimationClip(
        clips,
        entry.value.preferredClipNames,
      );
      if (sourceClip == null) {
        debugPrint(
          '[RoomScene][avatar-animation] no clip '
          'asset=${entry.value.assetPath}',
        );
        return;
      }

      final scene = data.scene;
      _normalizeAnimatedAvatar(scene, avatarHeight, entry.value);
      if (entry.key == AvatarWanderAnimation.turnRight) {
        // 右折専用素材がないため、左折クリップの描画を左右反転する。
        scene.scale.x = -scene.scale.x;
        scene.updateMatrixWorld(true);
      }
      _makeAvatarMaterialsOpaque(scene);
      scene.visible = false;
      avatarRoot.add(scene);

      // These Mixamo exports contain translation and scale tracks for every
      // bone. Applying those tracks with the current renderer can introduce
      // unit-scale jumps and authored root motion. Bone rotations preserve
      // the visible gesture, while the room controller remains the single
      // owner of world position, scale, bounds, and obstacle avoidance.
      final inPlaceTracks = sourceClip.tracks
          .where(
            (track) => track.name.toLowerCase().endsWith('.quaternion'),
          )
          .toList(growable: false);
      final clip = three.AnimationClip(
        sourceClip.name,
        sourceClip.duration,
        inPlaceTracks,
      );
      final mixer = three.AnimationMixer(scene);
      final action = mixer.clipAction(clip);
      if (action == null) {
        return;
      }
      _avatarAnimationScenes[entry.key] = scene;
      _avatarAnimationMixers[entry.key] = mixer;
      _avatarAnimationActions[entry.key] = action;
      debugPrint(
        '[RoomScene][avatar-animation] loaded '
        'state=${entry.key.name} clip=${sourceClip.name} '
        'duration=${sourceClip.duration}',
      );
    } catch (error) {
      debugPrint(
        '[RoomScene][avatar-animation] failed '
        'asset=${entry.value.assetPath} type=${error.runtimeType}',
      );
    }
  }

  void _normalizeAnimatedAvatar(
    three.Object3D scene,
    double targetHeight,
    _AvatarAnimationAsset asset,
  ) {
    // BoundingBox reports the armature's 0.01 root scale for these skinned
    // Mixamo files, while the rendered vertices use the authored mesh units.
    // Normalizing from the accessor dimensions avoids a 100x scale jump.
    final factor = targetHeight / asset.authoredHeight;
    scene.scale.setScalar(factor);
    scene.position.setValues(
      0,
      -asset.authoredMinY * factor +
          targetHeight * RoomSurfaceElevations.animatedFootClearanceRatio,
      0,
    );
    scene.updateMatrixWorld(true);
  }

  void _makeAvatarMaterialsOpaque(three.Object3D scene) {
    normalizeAvatarAnimationMaterials(scene);
  }

  three.AnimationClip? _resolveAnimationClip(
    List<three.AnimationClip> clips,
    List<String> preferredNames,
  ) {
    if (clips.isEmpty) {
      return null;
    }
    String normalize(String value) =>
        value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    for (final preferredName in preferredNames) {
      final preferred = normalize(preferredName);
      for (final clip in clips) {
        if (normalize(clip.name) == preferred) {
          return clip;
        }
      }
    }
    for (final preferredName in preferredNames) {
      final preferred = normalize(preferredName);
      for (final clip in clips) {
        final actual = normalize(clip.name);
        if (actual.contains(preferred) || preferred.contains(actual)) {
          return clip;
        }
      }
    }
    return clips.first;
  }

  Future<void> _addFurnitureForRoom(String roomId) async {
    final storedFurniture = widget.objects
        .where((object) =>
            object.roomId == roomId && object.isFurniture && object.isPlaced)
        .toList(growable: false);
    await Future.wait(storedFurniture.map(_addFurnitureObject));
  }

  ({double x, double z}) _furnitureCellCenter(RoomObjectModel object) {
    final calibration = RoomCalibrations.forRoom(object.roomId);
    final cells = calibration.occupiedCellsFor(object);
    if (cells.isEmpty) return (x: object.posX, z: object.posZ);
    final centers = cells.map(calibration.cellCenter).toList(growable: false);
    return (
      x: centers.map((center) => center.x).reduce((a, b) => a + b) /
          centers.length,
      z: centers.map((center) => center.z).reduce((a, b) => a + b) /
          centers.length,
    );
  }

  List<
      ({
        GridCell cell,
        double x,
        double y,
        double z,
        double width,
        double depth
      })> _tabletopSlots(String roomId) {
    final calibration = RoomCalibrations.forRoom(roomId);
    final table = widget.objects
        .where(
            (candidate) => candidate.assetKey == 'table' && candidate.isPlaced)
        .firstOrNull;
    final tableRoot = _furnitureRootsByAssetKey['table'];
    if (table == null || tableRoot == null) return const [];
    final surfaceCells = calibration.supportCellsForSurface(
      table,
      PlacementSurface.tabletop,
    );
    if (surfaceCells.isEmpty) return const [];
    tableRoot.updateMatrixWorld(true);
    final bounds = three.BoundingBox().setFromObject(tableRoot, true);
    final size = bounds.getSize(three.Vector3());
    if (!bounds.min.x.isFinite ||
        !bounds.max.y.isFinite ||
        !bounds.min.z.isFinite ||
        size.x <= 0 ||
        size.z <= 0) {
      return const [];
    }
    final alongX = size.x >= size.z;
    final sorted = [...surfaceCells]
      ..sort((a, b) => alongX ? a.x.compareTo(b.x) : a.z.compareTo(b.z));
    const edgeInsetRatio = 0.08;
    final usableMin = alongX
        ? bounds.min.x + size.x * edgeInsetRatio
        : bounds.min.z + size.z * edgeInsetRatio;
    final usableLength = (alongX ? size.x : size.z) * (1 - 2 * edgeInsetRatio);
    final slotLength = usableLength / sorted.length;
    final minorLength = (alongX ? size.z : size.x) * (1 - 2 * edgeInsetRatio);
    final centerX = (bounds.min.x + bounds.max.x) / 2;
    final centerZ = (bounds.min.z + bounds.max.z) / 2;
    return [
      for (var index = 0; index < sorted.length; index++)
        (
          cell: sorted[index],
          x: alongX ? usableMin + slotLength * (index + 0.5) : centerX,
          y: bounds.max.y,
          z: alongX ? centerZ : usableMin + slotLength * (index + 0.5),
          width: alongX ? slotLength : minorLength,
          depth: alongX ? minorLength : slotLength,
        ),
    ];
  }

  ({GridCell cell, double x, double y, double z, double width, double depth})?
      _tabletopSlotFor(RoomObjectModel object) {
    if (object.placementSurface != PlacementSurface.tabletop) return null;
    final slots = _tabletopSlots(object.roomId);
    if (slots.isEmpty) return null;
    return slots
        .where((slot) =>
            slot.cell.x == object.gridX && slot.cell.z == object.gridZ)
        .firstOrNull;
  }

  Future<void> _addFurnitureObject(RoomObjectModel object) async {
    if (object.isFloorCovering) {
      await _addCarpet(0, object: object);
      return;
    }
    final id = object.assetKey ?? object.objectId;
    final isWallMounted = FurniturePlacements.isWallMounted(object.assetKey);
    final cellCenter = isWallMounted
        ? (x: object.posX, z: object.posZ)
        : _furnitureCellCenter(object);
    final placement = FurniturePlacement(
      id: id,
      thumbnailAssetPath: 'assets/icon/furniture/$id.png',
      assetPath: object.localAssetPath,
      x: cellCenter.x,
      y: object.posY,
      z: cellCenter.z,
      scale: object.effectiveScaleX,
      rotationX: object.rotationX,
      rotationY: object.rotationY,
      rotationZ: object.rotationZ,
      footprintWidth: object.footprintWidth ?? 1,
      footprintDepth: object.footprintDepth ?? 1,
      helperNodeNames:
          id == 'table' || id == 'sofa' ? const ['Plane'] : const [],
    );
    await _addSingleFurniture(placement, 0, object: object);
  }

  Future<void> _addSingleFurniture(
    FurniturePlacement placement,
    double floorY, {
    RoomObjectModel? object,
  }) async {
    if (placement.id == 'cloud_rug') {
      await _addCarpet(floorY, object: object);
      return;
    }
    try {
      final assetPath = placement.assetPath;
      final furnitureScene = FurniturePlacements.isWindow(placement.id)
          ? _buildWindow(placement.id)
          : placement.id == 'wall_clock'
              ? _buildWallClock()
              : assetPath == null
                  ? _buildMetalChair()
                  : await _loadGlb(assetPath, placement.assetVersion);
      for (final helperNodeName in placement.helperNodeNames) {
        furnitureScene.getObjectByName(helperNodeName)?.removeFromParent();
      }
      if (placement.id != 'wall_clock' &&
          !FurniturePlacements.isWindow(placement.id)) {
        await _applyFurnitureMaterials(furnitureScene, placement.id);
      }
      final isWallMounted =
          object != null && FurniturePlacements.isWallMounted(object.assetKey);
      if (!isWallMounted) {
        _centerFurnitureOnFloor(furnitureScene);
      }

      final furnitureRoot = three.Group();
      furnitureRoot.userData['sceneType'] = 'furniture';
      furnitureRoot.userData['furnitureId'] = placement.id;
      _furnitureRootsByAssetKey[placement.id] = furnitureRoot;
      furnitureRoot.add(furnitureScene);
      furnitureRoot.position.setValues(
        placement.x,
        floorY + placement.y,
        placement.z,
      );
      furnitureRoot.scale.setScalar(placement.scale);
      furnitureRoot.rotation.set(
        placement.rotationX,
        placement.rotationY,
        placement.rotationZ,
      );
      furnitureRoot.updateMatrixWorld(true);
      if (object != null && !isWallMounted) {
        _alignFurnitureBoundsToCellCenter(furnitureRoot, object);
      }
      if (object != null) {
        if (!mounted ||
            !widget.objects
                .any((current) => current.objectId == object.objectId)) {
          return;
        }
        furnitureRoot.userData['roomObjectId'] = object.objectId;
        _objectMeshes[object.objectId] = furnitureRoot;
        _objectModels[object.objectId] = object;
        if (!_pickableObjects.contains(furnitureRoot)) {
          _pickableObjects.add(furnitureRoot);
        }
      }
      _threeJs.scene.add(furnitureRoot);
      // Loading assets can outlive a drag/resize. Reconcile with the latest
      // draft instead of leaving the object at the load-start position.
      if (!_isLoading) _reconcileObjects();
      _wanderController?.updateObstacles(_avatarObstacleAreas(widget.objects));
      _requestRender();
      debugPrint(
        '[RoomScene][furniture] loaded '
        'id=${placement.id} asset=${assetPath ?? 'procedural'}',
      );
    } catch (error) {
      debugPrint(
        '[RoomScene][furniture] failed '
        'id=${placement.id} asset=${placement.assetPath ?? 'procedural'} '
        'type=${error.runtimeType}',
      );
    }
  }

  Future<three.Texture> _loadRepeatingTexture(
    String assetPath,
    double repeat,
  ) async {
    final texture =
        await three.TextureLoader(flipY: false).fromAsset(assetPath);
    if (texture == null) {
      throw StateError('Furniture texture could not be decoded: $assetPath');
    }
    texture
      ..colorSpace = three.SRGBColorSpace
      ..wrapS = three.RepeatWrapping
      ..wrapT = three.RepeatWrapping
      ..needsUpdate = true;
    texture.repeat.setValues(repeat, repeat);
    return texture;
  }

  Future<void> _applyFurnitureMaterials(
    three.Object3D scene,
    String id,
  ) async {
    if (id == 'sofa') {
      final textureStart = DateTime.now();
      // 3枚のテクスチャはTextureLoaderの内部でImageLoaderがcompute()を使い
      // デコードを別Isolateへ逃がすため、束ねて投げるとCPUコアをまたいで
      // 並列に進む（three_js_core_loaders-0.3.0/lib/ImageLoader/
      // image_loader_app.dart:35）。実機計測でも逐次読込より約120ms
      // （約16%）速かったため、常にFuture.waitでまとめて読み込む。
      final textures = await Future.wait([
        _loadRepeatingTexture(_furnitureTextureAssets['sofa']!, 3),
        _loadRepeatingTexture(_sofaCushionTextureAsset, 3),
        _loadRepeatingTexture(_furnitureTextureAssets['table']!, 2),
      ]);
      debugPrint(
        '[RoomScene][timing] sofa textures(3) loaded in '
        '${DateTime.now().difference(textureStart).inMilliseconds}ms',
      );
      final bodyTexture = textures[0];
      final cushionTexture = textures[1];
      final woodTexture = textures[2];
      final bodyMaterial = three.MeshStandardMaterial({
        three.MaterialProperty.map: bodyTexture,
        three.MaterialProperty.color: 0x7c2f4b,
        three.MaterialProperty.roughness: 0.94,
        three.MaterialProperty.metalness: 0.0,
      });
      final cushionMaterial = three.MeshStandardMaterial({
        three.MaterialProperty.map: cushionTexture,
        three.MaterialProperty.color: 0x98721f,
        three.MaterialProperty.roughness: 0.96,
        three.MaterialProperty.metalness: 0.0,
      });
      final supportMaterial = three.MeshStandardMaterial({
        three.MaterialProperty.map: woodTexture,
        three.MaterialProperty.color: 0x85552d,
        three.MaterialProperty.roughness: 0.72,
        three.MaterialProperty.metalness: 0.0,
      });
      scene.traverse((object) {
        if (object.material == null) {
          return;
        }
        final sourceName = object.userData['name'] as String? ?? object.name;
        object.material = switch (sourceName) {
          'Cube.003' => cushionMaterial,
          'Cylinder' => supportMaterial,
          _ => bodyMaterial,
        };
      });
      return;
    }

    final material = await _loadFurnitureMaterial(id);
    scene.traverse((object) {
      if (object.material != null) {
        object.material = material;
      }
    });
  }

  Future<three.Material> _loadFurnitureMaterial(String id) async {
    final assetPath = _furnitureTextureAssets[id];
    if (assetPath == null) {
      throw StateError('Missing furniture texture for $id');
    }
    final repeat = switch (id) {
      'metal_chair' => 2.5,
      _ => 2.0,
    };
    final texture = await _loadRepeatingTexture(assetPath, repeat);

    if (id == 'table') {
      // Keep the generated wood grain independent from the intentionally
      // strong room lights, which otherwise clip its pale tones.
      return three.MeshBasicMaterial({
        three.MaterialProperty.map: texture,
        three.MaterialProperty.color: 0xd4a060,
      });
    }

    return three.MeshStandardMaterial({
      three.MaterialProperty.map: texture,
      three.MaterialProperty.color: 0xaeb5bc,
      three.MaterialProperty.roughness: 0.42,
      three.MaterialProperty.metalness: 0.58,
    });
  }

  three.Group _buildMetalChair() {
    final chair = three.Group();
    final brushedMetal = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x8d98a3,
      three.MaterialProperty.roughness: 0.28,
      three.MaterialProperty.metalness: 0.88,
    });
    final darkMetal = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x303840,
      three.MaterialProperty.roughness: 0.22,
      three.MaterialProperty.metalness: 0.92,
    });

    void addPart(
      double width,
      double height,
      double depth,
      double x,
      double y,
      double z,
      three.Material material,
    ) {
      final part = three.Mesh(
        three.BoxGeometry(width, height, depth),
        material,
      );
      part.position.setValues(x, y, z);
      chair.add(part);
    }

    addPart(1.05, 0.12, 0.92, 0, 0.72, 0, brushedMetal);
    addPart(1.05, 0.78, 0.10, 0, 1.13, 0.41, brushedMetal);
    for (final x in [-0.43, 0.43]) {
      for (final z in [-0.34, 0.34]) {
        addPart(0.09, 0.72, 0.09, x, 0.36, z, darkMetal);
      }
    }
    chair.userData['sceneType'] = 'proceduralMetalChair';
    return chair;
  }

  three.Group _buildWallClock() {
    final clock = three.Group();
    clock.userData['sceneType'] = 'proceduralWallClock';

    final rimMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xff8fa8,
      three.MaterialProperty.roughness: 0.42,
      three.MaterialProperty.metalness: 0.18,
    });
    final faceMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xfffaf5,
      three.MaterialProperty.roughness: 0.88,
      three.MaterialProperty.metalness: 0.0,
    });
    final handMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x5b4a4f,
      three.MaterialProperty.roughness: 0.55,
      three.MaterialProperty.metalness: 0.05,
    });

    final rim = three.Mesh(
      three.CylinderGeometry(0.72, 0.72, 0.14, 48),
      rimMaterial,
    )..rotation.x = math.pi / 2;
    clock.add(rim);

    final face = three.Mesh(
      three.CylinderGeometry(0.63, 0.63, 0.03, 48),
      faceMaterial,
    )
      ..rotation.x = math.pi / 2
      ..position.z = 0.08;
    clock.add(face);

    void addHand(double width, double length, double angle) {
      final hand = three.Mesh(
        three.BoxGeometry(width, length, 0.035),
        handMaterial,
      )
        ..position.setValues(
          -math.sin(angle) * length * 0.22,
          math.cos(angle) * length * 0.22,
          0.11,
        )
        ..rotation.z = angle;
      clock.add(hand);
    }

    addHand(0.055, 0.44, math.pi / 6);
    addHand(0.045, 0.58, -math.pi / 3);
    final center = three.Mesh(
      three.SphereGeometry(0.07, 16, 12),
      rimMaterial,
    )..position.z = 0.14;
    clock.add(center);
    return clock;
  }

  void _addWallThickness(
      three.BoundingBox roomBounds, three.Material? wallMaterial) {
    final min = roomBounds.min;
    final max = roomBounds.max;
    final size = roomBounds.getSize(three.Vector3());
    final thickness = size.x * 0.075;
    final wallHeight = size.y;
    final centerY = (min.y + max.y) / 2;
    final material = wallMaterial?.clone() ??
        three.MeshStandardMaterial({
          // Match the light trim already used along the room's wall edges.
          three.MaterialProperty.color: 0xfff7f2,
          three.MaterialProperty.roughness: 0.5,
          three.MaterialProperty.metalness: 0.0,
        });
    final group = three.Group()..userData['sceneType'] = 'wallThickness';

    final backWall = three.Mesh(
      three.BoxGeometry(size.x + thickness, wallHeight, thickness),
      material,
    )..position.setValues(
        (min.x - thickness + max.x) / 2,
        centerY,
        min.z - thickness / 2 - 0.005,
      );
    group.add(backWall);

    final leftWall = three.Mesh(
      three.BoxGeometry(thickness, wallHeight, size.z + thickness),
      material,
    )..position.setValues(
        min.x - thickness / 2 - 0.005,
        centerY,
        (min.z - thickness + max.z) / 2,
      );
    group.add(leftWall);
    _threeJs.scene.add(group);
  }

  three.Group _buildWindow(String id) {
    const width = 1.72;
    const height = 1.58;
    const outerFrameThickness = 0.13;
    const gridThickness = 0.075;
    const depth = 0.11;

    final frameMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0x754126,
      three.MaterialProperty.roughness: 0.58,
      three.MaterialProperty.metalness: 0.0,
    });
    final glassMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: 0xbfe8f2,
      three.MaterialProperty.roughness: 0.12,
      three.MaterialProperty.metalness: 0.02,
    });

    three.Group buildWindow(String id) {
      final window = three.Group();
      window.userData['sceneType'] = 'window';
      window.userData['windowId'] = id;

      final glass = three.Mesh(
        three.BoxGeometry(
          width - outerFrameThickness * 2,
          height - outerFrameThickness * 2,
          depth * 0.35,
        ),
        glassMaterial,
      );
      window.add(glass);

      void addFrame(
        double frameX,
        double frameY,
        double frameWidth,
        double frameHeight,
      ) {
        final frame = three.Mesh(
          three.BoxGeometry(frameWidth, frameHeight, depth),
          frameMaterial,
        );
        frame.position.setValues(frameX, frameY, 0);
        window.add(frame);
      }

      // Wooden outer frame.
      addFrame(
        -width / 2 + outerFrameThickness / 2,
        0,
        outerFrameThickness,
        height,
      );
      addFrame(
        width / 2 - outerFrameThickness / 2,
        0,
        outerFrameThickness,
        height,
      );
      addFrame(
        0,
        height / 2 - outerFrameThickness / 2,
        width,
        outerFrameThickness,
      );
      addFrame(
        0,
        -height / 2 + outerFrameThickness / 2,
        width,
        outerFrameThickness,
      );

      // A wooden cross divides the glass into four equal panes.
      addFrame(0, 0, gridThickness, height - outerFrameThickness * 2);
      addFrame(0, 0, width - outerFrameThickness * 2, gridThickness);

      return window;
    }

    return buildWindow(id)..position.z = 0.065;
  }

  Future<void> _addCarpet(
    double floorY, {
    RoomObjectModel? object,
  }) async {
    final texture = await three.TextureLoader(flipY: false)
        .fromAsset(_simpleRoomCarpetAsset);
    if (texture == null) {
      throw StateError('Carpet texture could not be decoded');
    }
    texture.colorSpace = three.SRGBColorSpace;

    final carpet = three.Group();
    carpet
      ..userData['sceneType'] = 'floorCovering'
      ..userData['carpetId'] = 'cloud_rug';
    final material = three.MeshBasicMaterial({
      three.MaterialProperty.map: texture,
      three.MaterialProperty.side: three.DoubleSide,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.alphaTest: 0.06,
      three.MaterialProperty.depthWrite: true,
    });
    final mesh = three.Mesh(
      three.PlaneGeometry(5.44, 3.6266666667),
      material,
    );
    mesh
      ..renderOrder = -1
      ..rotation.x = -math.pi / 2
      ..position.setValues(0, RoomSurfaceElevations.carpetRenderOffset, 0);
    carpet.add(mesh);

    final current = object;
    final cellCenter = current == null ? null : _furnitureCellCenter(current);
    carpet
      ..position.setValues(
        cellCenter?.x ?? 0,
        current == null
            ? floorY
            : RoomCalibrations.forRoom(current.roomId).floorY,
        cellCenter?.z ?? 0.30,
      )
      ..rotation.set(
        current?.rotationX ?? 0,
        current?.rotationY ?? math.pi,
        current?.rotationZ ?? 0,
      )
      ..scale.setScalar(current?.effectiveScaleX ?? 1);
    carpet.updateMatrixWorld(true);
    if (current != null) {
      _alignFurnitureBoundsToCellCenter(carpet, current);
    }

    if (current != null) {
      if (!mounted ||
          !widget.objects.any(
            (candidate) => candidate.objectId == current.objectId,
          )) {
        return;
      }
      carpet.userData['roomObjectId'] = current.objectId;
      _furnitureRootsByAssetKey['cloud_rug'] = carpet;
      _objectMeshes[current.objectId] = carpet;
      _objectModels[current.objectId] = current;
      if (!_pickableObjects.contains(carpet)) {
        _pickableObjects.add(carpet);
      }
    }
    _threeJs.scene.add(carpet);
    _requestRender();
  }

  void _centerFurnitureOnFloor(three.Object3D furnitureScene) {
    furnitureScene.position.setValues(0, 0, 0);
    furnitureScene.scale.setScalar(1);
    furnitureScene.updateMatrixWorld(true);
    final bounds = three.BoundingBox().setFromObject(furnitureScene, true);
    final size = bounds.getSize(three.Vector3());
    if (!size.x.isFinite ||
        !size.y.isFinite ||
        !size.z.isFinite ||
        size.x <= 0 ||
        size.y <= 0 ||
        size.z <= 0) {
      throw StateError('Furniture GLB has no measurable geometry');
    }
    final center = bounds.getCenter(three.Vector3());
    furnitureScene.position.setValues(
      -center.x,
      -bounds.min.y,
      -center.z,
    );
    furnitureScene.updateMatrixWorld(true);
  }

  void _alignFurnitureBoundsToCellCenter(
    three.Object3D furnitureRoot,
    RoomObjectModel object,
  ) {
    final target = _furnitureCellCenter(object);
    furnitureRoot.updateMatrixWorld(true);
    final bounds = three.BoundingBox().setFromObject(furnitureRoot, true);
    final actual = bounds.getCenter(three.Vector3());
    if (!actual.x.isFinite || !actual.z.isFinite) return;

    if (object.isFloorCovering) {
      furnitureRoot.position.x += target.x - actual.x;
      furnitureRoot.position.z += target.z - actual.z;
      furnitureRoot.updateMatrixWorld(true);
      return;
    }

    // A tall object is visually displaced from its floor footprint by the
    // perspective camera even when both centers have identical world X/Z.
    // Match their projected centers instead, then convert that screen-space
    // difference back to a translation on the floor plane.
    three.Vector3 projected(double x, double y, double z) =>
        three.Vector3(x, y, z).project(_threeJs.camera);

    final floorY = RoomCalibrations.forRoom(object.roomId).floorY + object.posY;
    final targetProjected = projected(target.x, floorY, target.z);
    final actualProjected = projected(actual.x, actual.y, actual.z);
    final xBasis = projected(target.x + 1, floorY, target.z)
      ..sub(targetProjected);
    final zBasis = projected(target.x, floorY, target.z + 1)
      ..sub(targetProjected);
    final screenX = targetProjected.x - actualProjected.x;
    final screenY = targetProjected.y - actualProjected.y;
    final determinant = xBasis.x * zBasis.y - xBasis.y * zBasis.x;
    if (!determinant.isFinite || determinant.abs() < 1e-8) return;
    final rawOffsetX = (screenX * zBasis.y - screenY * zBasis.x) / determinant;
    final rawOffsetZ = (xBasis.x * screenY - xBasis.y * screenX) / determinant;
    final calibration = RoomCalibrations.forRoom(object.roomId);
    final offsetX = rawOffsetX
        .clamp(-calibration.cellSizeX / 2, calibration.cellSizeX / 2)
        .toDouble();
    final offsetZ = rawOffsetZ
        .clamp(-calibration.cellSizeZ / 2, calibration.cellSizeZ / 2)
        .toDouble();
    if (!offsetX.isFinite || !offsetZ.isFinite) return;
    furnitureRoot.position.x += offsetX;
    furnitureRoot.position.z += offsetZ;
    furnitureRoot.updateMatrixWorld(true);
    debugPrint(
      '[RoomScene][furniture-center] id=${object.assetKey} '
      'offset=(${offsetX.toStringAsFixed(4)}, ${offsetZ.toStringAsFixed(4)})',
    );
  }

  Future<void> _addImagePlane(RoomObjectModel object) async {
    try {
      final localPath = object.localAssetPath;
      if (localPath == null || localPath.isEmpty) {
        return;
      }
      final file = File(localPath);
      if (!await file.exists()) {
        debugPrint(
            '[RoomScene] local image missing objectId=${object.objectId}');
        return;
      }

      final texture = await three.TextureLoader().fromFile(file);
      if (texture == null) {
        throw StateError('Image texture could not be decoded');
      }
      texture.colorSpace = three.SRGBColorSpace;
      final dimensions = presentedItemDimensions(
        object.aspectRatio,
        cellSizeX: RoomCalibrations.forRoom(object.roomId).cellSizeX,
        cellSizeY: RoomCalibrations.forRoom(object.roomId).cellSizeY,
        cellSizeZ: RoomCalibrations.forRoom(object.roomId).cellSizeZ,
      );
      final imageBytes = await file.readAsBytes();
      final silhouette = await buildSilhouetteField(imageBytes: imageBytes);
      final geometry = SilhouettePuffGeometry(
        silhouette,
        dimensions.width,
        dimensions.height,
      );
      final frontMaterial = three.MeshStandardMaterial({
        three.MaterialProperty.map: texture,
        three.MaterialProperty.side: three.FrontSide,
        three.MaterialProperty.roughness: 0.85,
        three.MaterialProperty.metalness: 0.0,
        three.MaterialProperty.transparent: false,
        three.MaterialProperty.alphaTest: 0.04,
      });
      final material = three.GroupMaterial([frontMaterial, frontMaterial]);
      final mesh = three.Mesh(geometry, material);
      mesh.userData['roomObjectId'] = object.objectId;
      _applyObjectTransform(mesh, object);

      // 読込中に品物が消えていたら（削除・disposeされていたら）採用しない。
      // ここでチェックしないと、_reconcileObjects が別の理由で先に呼ばれて
      // この品物を除去した後に、遅れて完了したこの読込がゴーストメッシュ
      // として追加されてしまう。
      if (!mounted ||
          !widget.objects
              .any((current) => current.objectId == object.objectId)) {
        return;
      }

      _objectMeshes[object.objectId] = mesh;
      _objectModels[object.objectId] = object;

      // 確実に判定リストに追加し、ログを出力
      _pickableObjects.add(mesh);
      debugPrint(
          '[RoomScene] Added pickable object: ${object.objectId}. Total: ${_pickableObjects.length}');

      _threeJs.scene.add(mesh);
      if (!_isLoading) _reconcileObjects();
      _requestRender();
    } catch (error) {
      debugPrint(
        '[RoomScene] image plane failed objectId=${object.objectId} '
        'type=${error.runtimeType}. Item will not be pickable.',
      );
    } finally {
      _pendingObjectLoads.remove(object.objectId);
    }
  }

  void _updateAvatarWander(double deltaTime) {
    if (_isDisposed || _animationsPaused) {
      return;
    }
    final root = _avatarRoot;
    final controller = _wanderController;
    final assignment = widget.assignment;
    if (root == null || controller == null || assignment == null) {
      return;
    }
    // The standalone gift celebration must never own RoomScene's regular
    // avatar visibility. Recover it defensively on the normal update path so
    // a completed or aborted asynchronous celebration cannot leave it hidden.
    if (shouldRestoreRegularAvatar(
      celebrationRequested: widget.celebrateAvatar,
      hasCelebrationMixer: _celebrationMixer != null,
    )) {
      root.visible = widget.showAvatar;
    }
    final pose = controller.update(deltaTime);
    _activateAvatarAnimation(pose.animation, pose.rotationY);
    _avatarPoseTransition.restoreSampledPose();
    _avatarAnimationMixers[pose.animation]?.update(
      deltaTime.clamp(0, 0.05),
    );
    _avatarPoseTransition.update(deltaTime);
    _lastWanderPose = pose;
    root.position.setValues(
      pose.x,
      pose.y + RoomSurfaceElevations.avatarGroundClearance,
      pose.z,
    );
    root.rotation.set(
      assignment.rotationX,
      pose.rotationY,
      assignment.rotationZ,
    );
    root.updateMatrixWorld(true);
    _poseCallbackElapsed += deltaTime;
    if (_poseCallbackElapsed >= 0.75) {
      _emitAvatarPose();
    }
  }

  void _activateAvatarAnimation(AvatarWanderAnimation animation, double yaw) {
    final scene = _avatarAnimationScenes[animation];
    final action = _avatarAnimationActions[animation];
    if (!shouldActivateAvatarAnimation(
      isRecordedAsActive: _activeAvatarAnimation == animation,
      hasScene: scene != null && action != null,
      isSceneVisible: scene?.visible ?? false,
      isActionRunning: action?.isRunning() ?? false,
      isHoldingFinalPose: action != null &&
          action.loop == three.LoopOnce &&
          action.clampWhenFinished &&
          action.paused,
    )) {
      return;
    }
    final previousScene = _avatarAnimationScenes[_activeAvatarAnimation];
    if (previousScene != null &&
        scene != null &&
        action != null &&
        shouldBlendAvatarPose(
          isSceneVisible: previousScene.visible,
          isActionRunning:
              _avatarAnimationActions[_activeAvatarAnimation]?.isRunning() ??
                  false,
          isHoldingFinalPose: _avatarAnimationActions[_activeAvatarAnimation]
                      ?.clampWhenFinished ==
                  true &&
              _avatarAnimationActions[_activeAvatarAnimation]?.paused == true,
        )) {
      _avatarPoseTransition.begin(
        source: previousScene,
        destination: scene,
        changeMirror:
            (_activeAvatarAnimation == AvatarWanderAnimation.turnRight) !=
                (animation == AvatarWanderAnimation.turnRight),
        yawDelta: (_lastWanderPose?.rotationY ?? yaw) - yaw,
        destinationMirrored: animation == AvatarWanderAnimation.turnRight,
      );
    } else {
      _avatarPoseTransition.clear();
    }
    // Keep exactly one opaque mesh visible; blend its bone pose instead of
    // cross-fading actions belonging to separate complete meshes.
    for (final animationAction in _avatarAnimationActions.values) {
      animationAction.stop();
    }
    for (final animationScene in _avatarAnimationScenes.values) {
      animationScene.visible = false;
    }

    _idleAvatarScene?.visible = scene == null || action == null;
    if (scene != null && action != null) {
      scene.visible = true;
      final isTurn = animation == AvatarWanderAnimation.turnLeft ||
          animation == AvatarWanderAnimation.turnRight;
      action
        ..reset()
        ..clampWhenFinished = isTurn
        ..setLoop(isTurn ? three.LoopOnce : three.LoopRepeat,
            isTurn ? 1 : double.infinity)
        ..play();
    }
    _activeAvatarAnimation = animation;
  }

  void _disposeAvatarAnimations() {
    _avatarPoseTransition.clear();
    for (final entry in _avatarAnimationMixers.entries.toList()) {
      final action = _avatarAnimationActions[entry.key];
      if (action != null) {
        _releaseMixerAction(entry.value, action);
      }
    }
    final celebrationMixer = _celebrationMixer;
    final celebrationAction = _celebrationAction;
    if (celebrationMixer != null && celebrationAction != null) {
      _releaseMixerAction(celebrationMixer, celebrationAction);
    }
    _celebrationAction = null;
    _celebrationMixer = null;
    _avatarAnimationActions.clear();
    _avatarAnimationMixers.clear();
    _avatarAnimationScenes.clear();
    _activeAvatarAnimation = null;
    _idleAvatarScene = null;
  }

  void _releaseMixerAction(
    three.AnimationMixer mixer,
    three.AnimationAction action,
  ) {
    try {
      action.stop();
      // three_js 0.3.0's uncacheRoot mutates actionsByClip while iterating it,
      // which throws ConcurrentModificationError. Each mixer used here owns a
      // single action, so releasing that action directly is sufficient.
      mixer.uncacheAction(action.clip);
    } catch (error) {
      debugPrint(
        '[RoomScene][avatar-animation] dispose failed '
        'type=${error.runtimeType}',
      );
    }
  }

  void _emitAvatarPose({bool force = false}) {
    final pose = _lastWanderPose;
    final assignment = widget.assignment;
    if (pose == null ||
        assignment == null ||
        (!force && _poseCallbackElapsed < 0.75)) {
      return;
    }
    _poseCallbackElapsed = 0;
    widget.onAvatarPoseChanged?.call(
      assignment.copyWith(
        posX: pose.x,
        posY: 0,
        posZ: pose.z,
        rotationY: pose.rotationY,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  void _addDraftCellIndicator(RoomSceneCalibration calibration) {
    if (widget.showPlacementGrid) {
      final gridMaterial = three.LineBasicMaterial({
        three.MaterialProperty.color: 0xf3b7c4,
        three.MaterialProperty.depthTest: true,
        three.MaterialProperty.depthWrite: true,
      });
      final floorMaxX = calibration.gridOriginX +
          calibration.cellSizeX * calibration.gridCountX;
      final supportGridMaterial = three.LineBasicMaterial({
        three.MaterialProperty.color: 0xff6f91,
        three.MaterialProperty.transparent: true,
        three.MaterialProperty.opacity: 1.0,
        three.MaterialProperty.depthTest: false,
        three.MaterialProperty.depthWrite: false,
      });
      final floorMaxZ = calibration.gridOriginZ +
          calibration.cellSizeZ * calibration.gridCountZ;
      final wallMaxY = calibration.gridOriginY +
          calibration.cellSizeY * calibration.gridCountY;

      void addLineGrid(
        List<three.Vector3> points, [
        three.Material? material,
      ]) {
        if (points.isEmpty) return;
        final geometry = three.BufferGeometry().setFromPoints(points);
        final grid = three.LineSegments(geometry, material ?? gridMaterial);
        grid.updateMatrixWorld(true);
        _placementGridMeshes.add(grid);
        _threeJs.scene.add(grid);
      }

      List<three.Vector3> tabletopSlotLines() {
        final lines = <three.Vector3>[];
        for (final slot in _tabletopSlots(widget.room.id)) {
          final minX = slot.x - slot.width / 2;
          final maxX = slot.x + slot.width / 2;
          final minZ = slot.z - slot.depth / 2;
          final maxZ = slot.z + slot.depth / 2;
          final y = slot.y + 0.008;
          lines
            ..add(three.Vector3(minX, y, minZ))
            ..add(three.Vector3(maxX, y, minZ))
            ..add(three.Vector3(maxX, y, minZ))
            ..add(three.Vector3(maxX, y, maxZ))
            ..add(three.Vector3(maxX, y, maxZ))
            ..add(three.Vector3(minX, y, maxZ))
            ..add(three.Vector3(minX, y, maxZ))
            ..add(three.Vector3(minX, y, minZ));
        }
        return lines;
      }

      final lines = <three.Vector3>[];
      for (var x = 0; x <= calibration.gridCountX; x++) {
        final worldX = calibration.gridOriginX + x * calibration.cellSizeX;
        lines
          ..add(three.Vector3(
              worldX, calibration.floorY + 0.012, calibration.gridOriginZ))
          ..add(three.Vector3(worldX, calibration.floorY + 0.012, floorMaxZ));
      }
      for (var z = 0; z <= calibration.gridCountZ; z++) {
        final worldZ = calibration.gridOriginZ + z * calibration.cellSizeZ;
        lines
          ..add(three.Vector3(
              calibration.gridOriginX, calibration.floorY + 0.012, worldZ))
          ..add(three.Vector3(floorMaxX, calibration.floorY + 0.012, worldZ));
      }
      for (var x = 0; x <= calibration.gridCountX; x++) {
        final worldX = calibration.gridOriginX + x * calibration.cellSizeX;
        lines
          ..add(three.Vector3(
              worldX, calibration.gridOriginY, calibration.gridOriginZ + 0.012))
          ..add(
              three.Vector3(worldX, wallMaxY, calibration.gridOriginZ + 0.012));
      }
      for (var y = 0; y <= calibration.gridCountY; y++) {
        final worldY = calibration.gridOriginY + y * calibration.cellSizeY;
        lines
          ..add(three.Vector3(
              calibration.gridOriginX, worldY, calibration.gridOriginZ + 0.012))
          ..add(three.Vector3(
              floorMaxX, worldY, calibration.gridOriginZ + 0.012));
      }
      for (var z = 0; z <= calibration.gridCountZ; z++) {
        final worldZ = calibration.gridOriginZ + z * calibration.cellSizeZ;
        lines
          ..add(three.Vector3(
              calibration.gridOriginX + 0.012, calibration.gridOriginY, worldZ))
          ..add(
              three.Vector3(calibration.gridOriginX + 0.012, wallMaxY, worldZ));
      }
      for (var y = 0; y <= calibration.gridCountY; y++) {
        final worldY = calibration.gridOriginY + y * calibration.cellSizeY;
        lines
          ..add(three.Vector3(
              calibration.gridOriginX + 0.012, worldY, calibration.gridOriginZ))
          ..add(three.Vector3(
              calibration.gridOriginX + 0.012, worldY, floorMaxZ));
      }
      addLineGrid(lines);
      addLineGrid(
        tabletopSlotLines(),
        supportGridMaterial,
      );
    }

    three.Group buildCellGroup(int color) {
      final group = three.Group();
      group.userData['sceneType'] = 'occupiedCells';
      group.userData['cellColor'] = color;
      return group;
    }

    _validCellsGroup = buildCellGroup(0x86d9c2);
    _invalidCellsGroup = buildCellGroup(0xff8faa);
    _threeJs.scene.add(_validCellsGroup!);
    _threeJs.scene.add(_invalidCellsGroup!);
    _draftMoveArrows = _buildDraftMoveArrows(calibration);
    _threeJs.scene.add(_draftMoveArrows!);
    _updateDraftCellIndicator();
  }

  three.Group _buildDraftMoveArrows(RoomSceneCalibration calibration) {
    final arrows = three.Group();
    arrows.userData['sceneType'] = 'draftMoveArrows';
    final cell = math.min(calibration.cellSizeX, calibration.cellSizeZ);
    final length = cell * 0.62;
    final width = cell * 0.54;
    final material = three.MeshBasicMaterial({
      three.MaterialProperty.color: 0xff6f91,
      three.MaterialProperty.transparent: true,
      three.MaterialProperty.opacity: 1.0,
      three.MaterialProperty.depthTest: true,
      three.MaterialProperty.depthWrite: false,
      three.MaterialProperty.side: three.DoubleSide,
    });

    three.Mesh arrow(double directionX, double directionZ) {
      final perpendicularX = -directionZ;
      final perpendicularZ = directionX;
      final geometry = three.BufferGeometry()
        ..setIndex([0, 1, 2])
        ..setAttributeFromString(
          'position',
          three.Float32BufferAttribute.fromList(
            [
              directionX * length / 2,
              0,
              directionZ * length / 2,
              -directionX * length / 2 + perpendicularX * width / 2,
              0,
              -directionZ * length / 2 + perpendicularZ * width / 2,
              -directionX * length / 2 - perpendicularX * width / 2,
              0,
              -directionZ * length / 2 - perpendicularZ * width / 2,
            ],
            3,
            false,
          ),
        );
      return three.Mesh(geometry, material);
    }

    three.Mesh wallArrow(
      double horizontal,
      double vertical, {
      required bool rightWall,
    }) {
      final perpendicularHorizontal = -vertical;
      final perpendicularVertical = horizontal;
      List<double> vertex(double along, double across) {
        final h = horizontal * along + perpendicularHorizontal * across;
        final v = vertical * along + perpendicularVertical * across;
        return rightWall ? [0, v, h] : [h, v, 0];
      }

      final geometry = three.BufferGeometry()
        ..setIndex([0, 1, 2])
        ..setAttributeFromString(
          'position',
          three.Float32BufferAttribute.fromList(
            [
              ...vertex(length / 2, 0),
              ...vertex(-length / 2, width / 2),
              ...vertex(-length / 2, -width / 2),
            ],
            3,
            false,
          ),
        );
      return three.Mesh(geometry, material);
    }

    arrows.add(arrow(1, 0)..userData['direction'] = 'right');
    arrows.add(arrow(-1, 0)..userData['direction'] = 'left');
    arrows.add(arrow(0, -1)..userData['direction'] = 'back');
    arrows.add(arrow(0, 1)..userData['direction'] = 'front');
    arrows.add(wallArrow(1, 0, rightWall: false));
    arrows.add(wallArrow(-1, 0, rightWall: false));
    arrows.add(wallArrow(0, 1, rightWall: false));
    arrows.add(wallArrow(0, -1, rightWall: false));
    arrows.add(wallArrow(1, 0, rightWall: true));
    arrows.add(wallArrow(-1, 0, rightWall: true));
    arrows.add(wallArrow(0, 1, rightWall: true));
    arrows.add(wallArrow(0, -1, rightWall: true));
    return arrows;
  }

  void _updateDraftCellIndicator() {
    final draft = widget.draftObject;
    final validGroup = _validCellsGroup;
    final invalidGroup = _invalidCellsGroup;
    final arrows = _draftMoveArrows;
    if (validGroup == null || invalidGroup == null || arrows == null) return;
    if (draft == null) {
      validGroup.visible = false;
      invalidGroup.visible = false;
      arrows.visible = false;
      return;
    }

    final calibration = RoomCalibrations.forRoom(widget.room.id);
    final activeGroup = widget.draftPlacementValid ? validGroup : invalidGroup;
    final inactiveGroup =
        widget.draftPlacementValid ? invalidGroup : validGroup;
    inactiveGroup.visible = false;
    activeGroup.visible = true;
    final surfaceCells = draft.placementSurface.isVertical
        ? draft.occupiedCells
        : <GridCell>[
            ...{
              for (final cell in draft.occupiedCells)
                '${cell.x}:${cell.z}': GridCell(cell.x, 0, cell.z),
            }.values,
          ];
    final color = activeGroup.userData['cellColor'] as int;
    while (activeGroup.children.length < surfaceCells.length) {
      final cellMesh = three.Mesh(
        three.PlaneGeometry(
          calibration.cellSizeX * 0.90,
          calibration.cellSizeZ * 0.90,
        ),
        three.MeshBasicMaterial({
          three.MaterialProperty.color: color,
          three.MaterialProperty.transparent: true,
          three.MaterialProperty.opacity: 0.55,
          three.MaterialProperty.depthTest: true,
          three.MaterialProperty.depthWrite: false,
          three.MaterialProperty.side: three.DoubleSide,
        }),
      );
      // Draw the placement color after furniture surfaces, but before the
      // selected image item. This keeps the tabletop cell visible without
      // painting over the item itself.
      cellMesh.renderOrder = 1;
      activeGroup.add(cellMesh);
    }
    for (var index = 0; index < activeGroup.children.length; index++) {
      final cellMesh = activeGroup.children[index];
      final visible = index < surfaceCells.length;
      cellMesh.visible = visible;
      if (!visible) continue;
      final center = calibration.cellCenter(surfaceCells[index]);
      cellMesh.rotation.set(0, 0, 0);
      cellMesh.scale.setValues(1, 1, 1);
      switch (draft.placementSurface) {
        case PlacementSurface.leftWall:
          cellMesh.scale.y = calibration.cellSizeY / calibration.cellSizeZ;
          cellMesh.position.setValues(
            center.x,
            center.y,
            calibration.gridOriginZ + 0.014,
          );
        case PlacementSurface.rightWall:
          cellMesh.rotation.y = math.pi / 2;
          cellMesh.scale.setValues(
            calibration.cellSizeZ / calibration.cellSizeX,
            calibration.cellSizeY / calibration.cellSizeZ,
            1,
          );
          cellMesh.position.setValues(
            calibration.gridOriginX + 0.014,
            center.y,
            center.z,
          );
        case PlacementSurface.tabletop:
          final slot = _tabletopSlotFor(draft);
          cellMesh.rotation.x = -math.pi / 2;
          if (slot != null) {
            cellMesh.scale.setValues(
              slot.width / (calibration.cellSizeX * 0.90),
              slot.depth / (calibration.cellSizeZ * 0.90),
              1,
            );
          }
          cellMesh.position.setValues(
            slot?.x ?? center.x,
            (slot?.y ?? calibration.floorY + 0.85) + 0.014,
            slot?.z ?? center.z,
          );
        case PlacementSurface.rug:
          cellMesh.rotation.x = -math.pi / 2;
          cellMesh.position.setValues(
            center.x,
            calibration.floorY + 0.054,
            center.z,
          );
        case PlacementSurface.floor:
          cellMesh.rotation.x = -math.pi / 2;
          cellMesh.position.setValues(
            center.x,
            calibration.floorY + 0.014,
            center.z,
          );
      }
    }

    final arrowChildren = arrows.children;
    if (draft.placementSurface.isVertical) {
      final centers = surfaceCells.map(calibration.cellCenter).toList();
      final centerY =
          centers.map((center) => center.y).reduce((a, b) => a + b) /
              centers.length;
      final minY = centers.map((center) => center.y).reduce(math.min);
      final maxY = centers.map((center) => center.y).reduce(math.max);
      final isLeftWall = draft.placementSurface == PlacementSurface.leftWall;
      for (var index = 0; index < arrowChildren.length; index++) {
        arrowChildren[index].visible =
            isLeftWall ? index >= 4 && index < 8 : index >= 8 && index < 12;
      }
      final start = isLeftWall ? 4 : 8;
      if (isLeftWall) {
        final centerX =
            centers.map((center) => center.x).reduce((a, b) => a + b) /
                centers.length;
        final minX = centers.map((center) => center.x).reduce(math.min);
        final maxX = centers.map((center) => center.x).reduce(math.max);
        final z = calibration.gridOriginZ + 0.018;
        arrowChildren[start]
            .position
            .setValues(maxX + calibration.cellSizeX, centerY, z);
        arrowChildren[start + 1]
            .position
            .setValues(minX - calibration.cellSizeX, centerY, z);
        arrowChildren[start + 2]
            .position
            .setValues(centerX, maxY + calibration.cellSizeY, z);
        arrowChildren[start + 3]
            .position
            .setValues(centerX, minY - calibration.cellSizeY, z);
      } else {
        final centerZ =
            centers.map((center) => center.z).reduce((a, b) => a + b) /
                centers.length;
        final minZ = centers.map((center) => center.z).reduce(math.min);
        final maxZ = centers.map((center) => center.z).reduce(math.max);
        final x = calibration.gridOriginX + 0.018;
        arrowChildren[start]
            .position
            .setValues(x, centerY, maxZ + calibration.cellSizeZ);
        arrowChildren[start + 1]
            .position
            .setValues(x, centerY, minZ - calibration.cellSizeZ);
        arrowChildren[start + 2]
            .position
            .setValues(x, maxY + calibration.cellSizeY, centerZ);
        arrowChildren[start + 3]
            .position
            .setValues(x, minY - calibration.cellSizeY, centerZ);
      }
      arrows.visible = true;
      arrows.updateMatrixWorld(true);
      activeGroup.updateMatrixWorld(true);
      return;
    }
    for (var index = 0; index < arrowChildren.length; index++) {
      arrowChildren[index].visible = index < 4;
    }
    final fallbackCenter = calibration.cellCenter(
      GridCell(draft.gridX, draft.gridY, draft.gridZ),
    );
    final occupiedCenters = surfaceCells.map(calibration.cellCenter).toList();
    final centerX = occupiedCenters.isEmpty
        ? fallbackCenter.x
        : occupiedCenters.map((center) => center.x).reduce((a, b) => a + b) /
            occupiedCenters.length;
    final centerZ = occupiedCenters.isEmpty
        ? fallbackCenter.z
        : occupiedCenters.map((center) => center.z).reduce((a, b) => a + b) /
            occupiedCenters.length;
    final minX = occupiedCenters.isEmpty
        ? centerX
        : occupiedCenters.map((point) => point.x).reduce(math.min);
    final maxX = occupiedCenters.isEmpty
        ? centerX
        : occupiedCenters.map((point) => point.x).reduce(math.max);
    final minZ = occupiedCenters.isEmpty
        ? centerZ
        : occupiedCenters.map((point) => point.z).reduce(math.min);
    final maxZ = occupiedCenters.isEmpty
        ? centerZ
        : occupiedCenters.map((point) => point.z).reduce(math.max);
    final arrowY = calibration.floorY +
        switch (draft.placementSurface) {
          PlacementSurface.tabletop => 0.868,
          PlacementSurface.rug => 0.058,
          _ => 0.018,
        };
    arrows.visible = true;
    final children = arrowChildren;
    children[0].position.setValues(
          maxX + calibration.cellSizeX,
          arrowY,
          centerZ,
        );
    children[1].position.setValues(
          minX - calibration.cellSizeX,
          arrowY,
          centerZ,
        );
    children[2].position.setValues(
          centerX,
          arrowY,
          minZ - calibration.cellSizeZ,
        );
    children[3].position.setValues(
          centerX,
          arrowY,
          maxZ + calibration.cellSizeZ,
        );
    arrows.updateMatrixWorld(true);
    activeGroup.updateMatrixWorld(true);
  }

  three.BoundingBox _normalizeToExtent(
    three.Object3D object,
    double targetExtent,
    SceneVector3 anchor,
  ) {
    object.position.setValues(0, 0, 0);
    object.scale.setScalar(1);
    object.updateMatrixWorld(true);
    final box = three.BoundingBox().setFromObject(object, true);
    final size = box.getSize(three.Vector3());
    final maxExtent = math.max(size.x, math.max(size.y, size.z));
    if (!maxExtent.isFinite || maxExtent <= 0) {
      throw StateError('GLB has no measurable geometry');
    }
    final factor = targetExtent / maxExtent;
    object.scale.setScalar(factor);
    object.updateMatrixWorld(true);
    final normalizedBox = three.BoundingBox().setFromObject(object, true);
    final center = normalizedBox.getCenter(three.Vector3());
    object.position.setValues(
      anchor.x - center.x,
      anchor.y - normalizedBox.min.y,
      anchor.z - center.z,
    );
    object.updateMatrixWorld(true);
    return three.BoundingBox().setFromObject(object, true);
  }

  double _normalizeToHeight(three.Object3D object, double targetHeight) {
    object.position.setValues(0, 0, 0);
    object.scale.setScalar(1);
    object.updateMatrixWorld(true);
    final box = three.BoundingBox().setFromObject(object, true);
    final size = box.getSize(three.Vector3());
    if (!size.y.isFinite || size.y <= 0) {
      throw StateError('Avatar GLB has no measurable height');
    }
    final factor = targetHeight / size.y;
    object.scale.setScalar(factor);
    object.updateMatrixWorld(true);
    final normalizedBox = three.BoundingBox().setFromObject(object, true);
    final center = normalizedBox.getCenter(three.Vector3());
    object.position.setValues(
      -center.x,
      -normalizedBox.min.y,
      -center.z,
    );
    object.updateMatrixWorld(true);
    return factor;
  }

  void _applyAvatarTransform(RoomAvatarAssignmentModel? assignment) {
    final avatarRoot = _avatarRoot;
    if (avatarRoot == null || assignment == null) {
      return;
    }
    final floorY = RoomCalibrations.forRoom(widget.room.id).floorY;
    avatarRoot.position.setValues(
      assignment.posX,
      floorY + assignment.posY,
      assignment.posZ,
    );
    avatarRoot.scale.setValues(
      assignment.scaleX,
      assignment.scaleY,
      assignment.scaleZ,
    );
    avatarRoot.rotation.set(
      assignment.rotationX,
      assignment.rotationY,
      assignment.rotationZ,
    );
    avatarRoot.updateMatrixWorld(true);
  }

  void _applyObjectTransform(three.Object3D mesh, RoomObjectModel object) {
    final usesFloorFurnitureCenter = object.isFurniture &&
        !FurniturePlacements.isWallMounted(object.assetKey);
    final cellCenter =
        usesFloorFurnitureCenter ? _furnitureCellCenter(object) : null;
    final tabletopSlot = _tabletopSlotFor(object);
    final calibration = RoomCalibrations.forRoom(object.roomId);
    final tabletopYCorrection = tabletopSlot == null
        ? 0.0
        : tabletopSlot.y - (calibration.floorY + 0.85);
    mesh.position.setValues(
      tabletopSlot?.x ?? cellCenter?.x ?? object.posX,
      object.isFloorCovering
          ? calibration.floorY
          : object.posY + tabletopYCorrection,
      tabletopSlot?.z ?? cellCenter?.z ?? object.posZ,
    );
    mesh.scale.setValues(
      object.effectiveScaleX,
      object.effectiveScaleY,
      object.effectiveScaleZ,
    );
    mesh.rotation.set(
      object.rotationX,
      object.rotationY,
      object.rotationZ,
    );
    mesh.renderOrder = object.placementSurface == PlacementSurface.tabletop &&
            !object.isFurniture
        ? 2
        : 0;
    mesh.visible = object.isPlaced && object.deletedAt == null;
    mesh.updateMatrixWorld(true);
    if (usesFloorFurnitureCenter) {
      _alignFurnitureBoundsToCellCenter(mesh, object);
    }
  }

  RoomObjectModel? _pickObject(Offset localPosition) {
    String? roomObjectIdFor(three.Object3D? object) {
      var current = object;
      while (current != null) {
        final objectId = current.userData['roomObjectId'] as String?;
        if (objectId != null) {
          return objectId;
        }
        current = current.parent;
      }
      return null;
    }

    if (_pickableObjects.isEmpty) {
      debugPrint('[RoomScene] No pickable objects available');
      return null;
    }
    if (_isLoading) {
      debugPrint('[RoomScene] Hit-test blocked by loading state');
      return null;
    }
    final pointer = three.Vector2(
      (localPosition.dx / widget.size.width) * 2 - 1,
      -(localPosition.dy / widget.size.height) * 2 + 1,
    );
    _raycaster.setFromCamera(pointer, _threeJs.camera);

    final camPos = _threeJs.camera.position;
    debugPrint(
        '[RoomScene] Raycast pointer=$pointer CamPos=(${camPos.x}, ${camPos.y}, ${camPos.z})');

    final intersections = _raycaster.intersectObjects(_pickableObjects, true);
    if (intersections.isEmpty) {
      debugPrint('[RoomScene] Raycast: no intersection at $pointer');
    }
    for (final intersection in intersections) {
      final objectId = roomObjectIdFor(intersection.object);
      if (objectId != null) {
        debugPrint('[RoomScene] Raycast: hit object $objectId');
        return _objectModels[objectId];
      }
    }
    return null;
  }

  void _retry() {
    _stopAvatarCelebration();
    _disposeAvatarAnimations();
    _threeJs.dispose();
    _pickableObjects.clear();
    _objectMeshes.clear();
    _objectModels.clear();
    _pendingObjectLoads.clear();
    _avatarRoot = null;
    _wanderController = null;
    _validCellsGroup = null;
    _invalidCellsGroup = null;
    _draftMoveArrows = null;
    _celebrationRequested = false;
    setState(_createRenderer);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => _scenePointers.add(event.pointer),
          onPointerMove: (event) {
            if (_scenePointers.length == 1) {
              widget.onSceneDragUpdate?.call(event.delta);
            }
          },
          onPointerUp: (event) => _scenePointers.remove(event.pointer),
          onPointerCancel: (event) => _scenePointers.remove(event.pointer),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.onObjectTap == null
                ? null
                : (details) {
                    final object = _pickObject(details.localPosition);
                    if (object != null) {
                      widget.onObjectTap!(object);
                    }
                  },
            onLongPressStart: (details) {
              final object = _pickObject(details.localPosition);
              if (object != null && widget.onObjectLongPress != null) {
                widget.onObjectLongPress!(object);
              } else {
                widget.onAvatarLongPress?.call();
              }
            },
            // The placement scene reads raw pointer deltas in the Listener
            // above. Claim vertical drags here so the enclosing page does not
            // scroll at the same time as an object is being moved.
            onVerticalDragUpdate: widget.onSceneDragUpdate == null
                ? null
                : (_) {},
            onScaleStart: widget.onSceneScaleStart,
            onScaleUpdate: widget.onSceneScaleUpdate,
            onScaleEnd: widget.onSceneScaleEnd,
            child: _threeJs.build(),
          ),
        ),
        if (_isLoading)
          const IgnorePointer(
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error != null)
          ColoredBox(
            color: widget.backgroundColor,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.view_in_ar_outlined, size: 42),
                    const SizedBox(height: 12),
                    const Text(
                      '3Dモデルを読み込めませんでした',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _emitAvatarPose(force: true);
    WidgetsBinding.instance.removeObserver(this);
    // 破棄されるキャンバスは「読み込みが終わった」とは名乗れない。
    // アイテム一覧が後から届くとassetIdentityが変わってキャンバスが作り直され、
    // 新しいキャンバスのonLoadingChanged(true)の後に古い方のfalseが流れて、
    // まだクルクルが回っているのに読み込み完了と誤検知していた。

    try {
      _stopAvatarCelebration();
      _disposeAvatarAnimations();
      _threeJs.dispose();
    } catch (e) {
      debugPrint('[RoomScene] Error during dispose: $e');
      // setup()完了前(scene/cameraが未初期化)にウィジェットが破棄されると
      // ThreeJS.dispose()内部でLateInitializationErrorが発生し、GLリソース
      // (texture/angle)の解放処理まで到達できない。ここで個別に解放しておく。
      _threeJs.angle?.dispose([_threeJs.texture]);
    }
    _pickableObjects.clear();
    _objectMeshes.clear();
    _objectModels.clear();
    _furnitureRootsByAssetKey.clear();
    _scenePointers.clear();
    super.dispose();
  }
}

abstract final class GlbAssetByteCache {
  static final Map<String, Future<Uint8List>> _cache = {};

  static Future<Uint8List> load(String assetPath, int assetVersion) {
    final cacheKey = '$assetPath@$assetVersion';
    return _cache.putIfAbsent(cacheKey, () async {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    });
  }

  static void invalidate(String assetPath) {
    _cache.removeWhere((key, value) => key.startsWith('$assetPath@'));
  }
}

/// GLBの読込（io）＋パースの実処理。バイト列自体は GlbAssetByteCache が
/// 保持しているため2回目以降のioはほぼ0msだが、パース結果（GLTFData）は
/// キャッシュしない。呼び出し元が _RoomSceneCanvas の通常読込・
/// GlbParsePrewarm の先読みのどちらであっても、この関数を経由することで
/// 実装を1箇所に保つ。[source] はログ上で先読み経由か即時読込かを
/// 区別するためだけのマーカー。
Future<three.GLTFData> _parseGlb(
  String assetPath,
  int assetVersion, {
  required String source,
}) async {
  final ioStart = DateTime.now();
  final bytes = await GlbAssetByteCache.load(assetPath, assetVersion);
  final ioMs = DateTime.now().difference(ioStart).inMilliseconds;
  final loader = three.GLTFLoader(flipY: true);
  try {
    final parseStart = DateTime.now();
    final data = await loader.fromBytes(bytes);
    final parseMs = DateTime.now().difference(parseStart).inMilliseconds;
    debugPrint(
      '[RoomScene][timing] $assetPath: io=${ioMs}ms parse=${parseMs}ms '
      'source=$source',
    );
    if (data == null) {
      throw StateError('GLB could not be decoded');
    }
    return data;
  } finally {
    loader.dispose();
  }
}

/// ルームシーンが使うGLBのパースを、実際にシーンを組み立てる前に
/// 前倒しで始めておくための「先読み→譲渡」の仕組み。
///
/// 名前の通り、ここが肝心な点として「共有」ではなく「譲渡」である。
/// GlbAssetByteCache（生バイト列のキャッシュ）と違い、パース済みの
/// `GLTFData`（Object3Dツリー）はキャッシュとして持ち回すことができない。
/// 理由は three_js 側にある次の2つの制約：
///
/// 1. `SkinnedMesh.clone()` が壊れている。three_js_core-0.3.0の
///    skinned_mesh.dart:126-131 のドキュメントコメントに "This method does
///    currently not clone an instance of SkinnedMesh correctly. Please use
///    SkeletonUtils.clone in the meanwhile" と明記されているが、その
///    `SkeletonUtils` はこの依存関係の中のどこにも存在しない。
///    `copy()`（同ファイル133-146行目）も元の `Skeleton` を参照共有する
///    だけ（143行目）。アバターはスキン付き＋AnimationMixer駆動なので、
///    cloneするとアニメーションが壊れる。
/// 2. `ThreeJS.dispose()` は `scene.dispose()` を呼び
///    （three_viewer.dart:191）、これが再帰的に `Material.dispose()` →
///    `Texture.dispose()` を呼ぶ。どちらも冪等性ガードを持たない
///    （material.dart:1002-1029, texture.dart:274-282）上、`Mesh.copy()`
///    はテクスチャを複製せず参照共有する。つまり複数シーンが同じパース
///    結果（＝同じTexture/Materialインスタンス）を共有していると、
///    一方のシーンをdisposeしただけで他方が使っているテクスチャの
///    ピクセルデータやGLハンドルまで解放されてしまう。
///
/// この2点により「パース済みツリーをキャッシュして複数シーンで使い回す」
/// という素直な最適化は選べない。そこで代わりに、パース結果は必ず
/// ちょうど1つのシーンへ「譲渡」する設計にしている。[take] で取り出した
/// 時点でMapから消えるため、以後は誰も同じ `GLTFData` を再利用できず、
/// 複数シーンが同じツリーを共有する状況は構造的に発生しない。
///
/// 効果の源泉は計算量の削減ではなくタイミングの工夫。ユーザーは
/// 写真撮影→AI画像処理待ち→メモ入力、という数秒〜数十秒のアイドル時間を
/// 経てからスワイプ配置画面に辿り着くため、そのアイドル時間の間に
/// パースを始めておけば、実際にシーンを組み立てる頃には既に完了している。
abstract final class GlbParsePrewarm {
  static final Map<String, Future<three.GLTFData>> _pending = {};

  /// まだ先読み中/先読み済みでなければパースを開始する。既に同じキーで
  /// 進行中または完了済みなら何もしない（二重パースの防止）。
  static void request(String assetPath, int assetVersion) {
    final key = '$assetPath@$assetVersion';
    if (_pending.containsKey(key)) {
      return;
    }
    final future = _parseGlb(assetPath, assetVersion, source: 'prewarm');
    _pending[key] = future;
    // 先読み結果は take() されるまで誰にも await されない可能性がある。
    // その間に失敗すると「unhandled exception」としてクラッシュレポートに
    // 出てしまうため、観測用の別ハンドラをぶら下げてもみ消す。
    // 元のfutureはMapにそのまま残しているので、後で take() して await
    // する本来の消費者にはエラーが通常通り伝播する（＝ここで握り潰しては
    // いない）。
    unawaited(future.then((_) {}, onError: (Object _) {}));
  }

  /// 先読み結果の所有権を呼び出し元へ譲渡する。取り出した時点でMapから
  /// 除かれるため、以後は誰も同じ `GLTFData` を参照できない
  /// （＝共有ではなく譲渡）。先読みが無ければnullを返し、呼び出し元は
  /// 通常のその場パースにフォールバックする。
  static Future<three.GLTFData>? take(String assetPath, int assetVersion) {
    final key = '$assetPath@$assetVersion';
    return _pending.remove(key);
  }

  /// 先読み中/未消費の全エントリを破棄する。スワイプ配置画面へ進まずに
  /// 途中離脱した場合など、宙に浮いた先読み結果（とそれが握るメモリ）を
  /// 保持し続けないために呼ぶ。
  static void clear() {
    _pending.clear();
  }
}
