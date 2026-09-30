import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../models/item_model.dart';
import '../models/room_models.dart';
import '../providers/item_provider.dart';
import '../providers/room_provider.dart';
import '../room/furniture_placement.dart';
import '../room/furniture_size_spec.dart';
import '../room/placement_rotation.dart';
import '../room/room_3d_route_visibility.dart';
import '../room/room_calibration.dart';
import '../room/room_scene_widget.dart';
import '../services/app_interaction_feedback.dart';

class RoomPlacementPage extends StatefulWidget {
  final String? itemId;
  final String roomId;

  const RoomPlacementPage({
    super.key,
    required this.itemId,
    required this.roomId,
  });

  @override
  State<RoomPlacementPage> createState() => _RoomPlacementPageState();
}

class _RoomPlacementPageState extends State<RoomPlacementPage> {
  RoomObjectModel? _draft;
  late String? _selectedItemId = widget.itemId;
  String? _selectedFurnitureAssetKey;
  RoomObjectModel? _initialDraft;
  PlacementValidation? _validation;
  final List<RoomObjectModel> _history = [];
  final ScrollController _itemPickerScrollController = ScrollController();
  final List<RoomObjectModel> _redoHistory = [];
  final GlobalKey _roomSceneKey = GlobalKey(debugLabel: 'room-placement-scene');
  Object? _error;
  bool _initializing = false;
  bool _saving = false;
  bool _isDirty = false;
  bool _fineAdjustment = false;
  bool _showFurniture = false;
  bool _storePending = false;
  double _gestureStartRotation = 0;
  Offset _dragDelta = Offset.zero;
  double _gestureStartScale = 1;

  @override
  void initState() {
    super.initState();
    roomPlacement3DVisible.value = true;
  }

  @override
  void dispose() {
    roomPlacement3DVisible.value = false;
    _itemPickerScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedItemId != null &&
        _draft == null &&
        !_initializing &&
        _error == null) {
      _initializing = true;
      _initializeDraft();
    }
  }

  Future<void> _initializeDraft() async {
    final itemId = _selectedItemId;
    if (itemId == null) return;
    try {
      final roomProvider = context.read<RoomProvider>();
      final item = context.read<ItemProvider>().itemById(itemId);
      if (item == null) {
        throw StateError('Item not found');
      }
      final existing = roomProvider.objectRecordForItem(widget.roomId, itemId);
      RoomObjectModel draft;
      var isNew = false;
      if (existing != null) {
        draft = roomProvider.snapRoomObjectToGrid(existing);
        isNew = !existing.isPlaced;
      } else {
        final dimensions = await _imageDimensions(item);
        draft = roomProvider.createPlacementDraft(
          item: item,
          roomId: widget.roomId,
          originalWidth: dimensions.$1,
          originalHeight: dimensions.$2,
        );
        isNew = true;
      }
      final validation = roomProvider.validatePlacement(draft);
      if (mounted && _selectedItemId == itemId) {
        setState(() {
          _draft = validation.object;
          _initialDraft = validation.object;
          _validation = validation;
          _isDirty = isNew;
          _storePending = false;
        });
      }
    } catch (error) {
      if (mounted && _selectedItemId == itemId) {
        setState(() => _error = error);
      }
    } finally {
      if (_selectedItemId == itemId) {
        _initializing = false;
      }
    }
  }

  Future<(int, int)> _imageDimensions(ItemModel item) async {
    final path = item.processedLocalImagePath;
    if (path == null || path.isEmpty) {
      throw StateError('Processed local image is missing');
    }
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_saving) _returnToCreate();
      },
      child: _buildPage(context),
    );
  }

  void _returnToCreate() {
    if (!_saving) context.go('/?tab=create');
  }

  Widget _buildPage(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final room = roomProvider.roomById(widget.roomId);
    final draft = _draft;
    if (room == null) {
      return const Scaffold(body: Center(child: Text('部屋が見つかりません')));
    }
    if (_error != null) {
      if (!_hasSelection) {
        return _buildItemSelection(roomProvider, room);
      }
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              onPressed: AppInteractionFeedback.wrap(context, _returnToCreate)),
          title: const Text('部屋に置く'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('加工済み画像を読み込めませんでした'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  AppInteractionFeedback.tap(context);
                  setState(() {
                    _error = null;
                    _initializing = true;
                  });
                  _initializeDraft();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_hasSelection || draft == null) {
      return _buildItemSelection(roomProvider, room);
    }

    final validation = _validation ?? roomProvider.validatePlacement(draft);
    final canSave =
        _isDirty && (_storePending || validation.isValid) && !_saving;
    final placementPanel = _PlacementPanel(
      draft: draft,
      validation: validation,
      fineAdjustment: _fineAdjustment,
      canUndo: _history.isNotEmpty,
      canRedo: _redoHistory.isNotEmpty,
      canStore: _isPlacedObject(roomProvider, room.id, draft) && !_saving,
      onStore: _toggleStorePending,
      onFineChanged: (value) => setState(() => _fineAdjustment = value),
      onMove: _move,
      onRotationYChanged: (value) => _setRotation(y: value),
      onRotationXChanged: (value) => _setRotation(x: value),
      onRotationZChanged: (value) => _setRotation(z: value),
      onFlip: () => _setRotation(x: draft.rotationX + math.pi),
      onResetRotation: () => _updateDraft(
        draft.copyWith(rotationX: 0, rotationY: 0, rotationZ: 0),
      ),
      onUndo: _undo,
      onRedo: _redo,
      onReset: _reset,
    );

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: const Color(0xfffff8fb),
        appBar: AppBar(
          leading: BackButton(
              onPressed: AppInteractionFeedback.wrap(context, _returnToCreate)),
          backgroundColor: const Color(0xfffff8fb),
          title: Text(room.name),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: canSave ? () => _save(roomProvider, draft) : null,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: const Text('保存'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: _roomViewportHeight(context),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: RoomSceneWidget(
                          key: _roomSceneKey,
                          showPlacementGrid: true,
                          cameraDistanceScale: _roomCameraDistanceScale(
                            context,
                          ),
                          cameraTargetYOffset: 0.0,
                          room: room,
                          objects: _storePending
                              ? roomProvider
                                  .objectsForRoom(room.id)
                                  .where(
                                    (object) =>
                                        object.objectId != draft.objectId,
                                  )
                                  .toList(growable: false)
                              : roomProvider.objectsForRoom(room.id),
                          draftObject: _storePending ? null : draft,
                          draftPlacementValid: validation.isValid,
                          onObjectLongPress: (object) =>
                              _selectRoomObject(roomProvider, object),
                          onSceneScaleStart: _handleSceneScaleStart,
                          onSceneDragUpdate: _handleSceneDragUpdate,
                          onSceneScaleUpdate: _handleSceneScaleUpdate,
                          onSceneScaleEnd: _handleSceneScaleEnd,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _PlacementStatusBadge(
                              key: ValueKey(draft.placementSurface),
                              draft: draft,
                              validation: validation,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_fineAdjustment)
                  placementPanel
                else ...[
                  _buildItemPicker(roomProvider, room),
                  placementPanel,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSceneScaleStart(ScaleStartDetails details) {
    final draft = _draft;
    if (draft == null) return;
    _gestureStartScale = draft.effectiveScaleX;
    _gestureStartRotation =
        draft.placementSurface.isVertical ? draft.rotationZ : draft.rotationY;
    _dragDelta = Offset.zero;
  }

  void _handleSceneDragUpdate(Offset delta) {
    _dragDelta += delta;
    final draft = _draft;
    if (draft == null) return;
    const threshold = 28.0;
    if (_dragDelta.distance < threshold) return;

    if (draft.placementSurface.isVertical) {
      if (_dragDelta.dx.abs() >= _dragDelta.dy.abs()) {
        if (_move(_dragDelta.dx > 0 ? 1 : -1, 0, 0)) {
          AppInteractionFeedback.tap(context);
        }
      } else {
        // Wall Y increases upward while screen Y increases downward.
        if (_move(0, 0, _dragDelta.dy > 0 ? 1 : -1)) {
          AppInteractionFeedback.tap(context);
        }
      }
      _dragDelta = Offset.zero;
      return;
    }

    final angle =
        (math.atan2(_dragDelta.dy, _dragDelta.dx) * 180 / math.pi + 360) % 360;
    const directions = [
      (angle: 45.0, x: 1, z: 0),
      (angle: 135.0, x: 0, z: 1),
      (angle: 225.0, x: -1, z: 0),
      (angle: 315.0, x: 0, z: -1),
    ];
    var nearest = directions.first;
    var nearestDistance = 360.0;
    for (final direction in directions) {
      final rawDistance = (angle - direction.angle).abs();
      final circularDistance = math.min(rawDistance, 360 - rawDistance);
      if (circularDistance < nearestDistance) {
        nearest = direction;
        nearestDistance = circularDistance;
      }
    }

    // 床軸と平行な斜め4方向だけを受け付ける。上下左右に近い曖昧な
    // ジェスチャーは移動させず、次の指の区間から改めて判定する。
    if (nearestDistance <= 30) {
      if (_move(nearest.x, 0, nearest.z)) {
        AppInteractionFeedback.tap(context);
      }
    }
    _dragDelta = Offset.zero;
  }

  void _handleSceneScaleUpdate(ScaleUpdateDetails details) {
    final draft = _draft;
    if (draft == null || details.pointerCount <= 1) return;

    var scale =
        (_gestureStartScale * details.scale).clamp(0.25, 3.0).toDouble();
    if (draft.isFurniture) {
      scale = FurnitureSizeSpecs.nearest(draft.assetKey, scale)?.scale ?? scale;
    }
    _updateDraft(
      draft.copyWith(
        scale: scale,
        scaleX: scale,
        scaleY: scale,
        scaleZ: scale,
        rotationY: draft.placementSurface.isVertical
            ? draft.rotationY
            : _normalizeAngle(_gestureStartRotation + details.rotation),
        rotationZ: draft.placementSurface.isVertical
            ? _normalizeAngle(_gestureStartRotation + details.rotation)
            : draft.rotationZ,
      ),
    );
  }

  void _handleSceneScaleEnd(ScaleEndDetails details) {
    final draft = _draft;
    if (draft == null) return;
    final currentRotation =
        draft.placementSurface.isVertical ? draft.rotationZ : draft.rotationY;
    final snapped = snapPlacementRotation(
      currentRotation,
      isFurniture: draft.isFurniture,
    );
    if ((snapped - currentRotation).abs() > 1e-6) {
      if (draft.placementSurface.isVertical) {
        _setRotation(z: snapped);
      } else {
        _setRotation(y: snapped);
      }
    }
    _dragDelta = Offset.zero;
  }

  void _updateDraft(
    RoomObjectModel next, {
    bool addHistory = true,
    bool clearRedo = true,
  }) {
    final current = _draft;
    if (current == null) {
      return;
    }
    if (addHistory) {
      _history.add(current);
      if (_history.length > 60) {
        _history.removeAt(0);
      }
    }
    if (clearRedo) {
      _redoHistory.clear();
    }
    final validation = context.read<RoomProvider>().validatePlacement(next);
    final surfaceChanged =
        current.placementSurface != validation.object.placementSurface;
    setState(() {
      _draft = validation.object;
      _validation = validation;
      _isDirty = true;
    });
    _storePending = false;
    if (surfaceChanged) {
      HapticFeedback.mediumImpact();
      final message = switch (validation.object.placementSurface) {
        PlacementSurface.tabletop => '机の上に載せました',
        PlacementSurface.floor => '床に下ろしました',
        PlacementSurface.leftWall => '左の壁に移動しました',
        PlacementSurface.rightWall => '右の壁に移動しました',
        PlacementSurface.rug => 'ラグの上に移動しました',
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(milliseconds: 1200),
          ),
        );
    }
  }

  /// Returns whether the draft actually moved to a different cell/surface.
  bool _move(int x, int y, int z) {
    final draft = _draft;
    if (draft == null) return false;
    final calibration = RoomCalibrations.forRoom(draft.roomId);
    final provider = context.read<RoomProvider>();

    final table = provider.furnitureByAssetKey(draft.roomId, 'table');
    final tableCells = table == null
        ? <(int, int)>{}
        : {
            for (final cell in calibration.supportCellsForSurface(
              table,
              PlacementSurface.tabletop,
            ))
              (cell.x, cell.z),
          };
    final rug = provider.furnitureByAssetKey(draft.roomId, 'cloud_rug');
    final rugCells = rug == null
        ? <(int, int)>{}
        : {
            for (final cell in calibration.supportCellsForSurface(
              rug,
              PlacementSurface.rug,
            ))
              (cell.x, cell.z),
          };
    var surface = draft.placementSurface;
    final surfaceDelta = switch (surface) {
      PlacementSurface.leftWall => (x: x, y: y - z, z: 0),
      PlacementSurface.rightWall => (x: 0, y: y - z, z: x),
      _ => (x: x, y: y, z: z),
    };
    var rawX = draft.gridX + surfaceDelta.x;
    var rawY = draft.gridY + surfaceDelta.y;
    var rawZ = draft.gridZ + surfaceDelta.z;

    bool fitsHorizontalSurface(
      PlacementSurface candidateSurface,
      Set<(int, int)> supportCells,
    ) {
      if (supportCells.isEmpty) return false;
      final candidate = provider.snapRoomObjectToGrid(
        draft.copyWith(
          placementSurface: candidateSurface,
          gridX: rawX,
          gridY: rawY,
          gridZ: rawZ,
        ),
      );
      return candidate.occupiedCells.isNotEmpty &&
          candidate.occupiedCells.every(
            (cell) => supportCells.contains((cell.x, cell.z)),
          );
    }

    final canUseRaisedSurfaces =
        !draft.isFurniture || FurniturePlacements.isWallMounted(draft.assetKey);
    if (canUseRaisedSurfaces) {
      if (surface == PlacementSurface.floor) {
        if (rawZ < 0) {
          surface = PlacementSurface.leftWall;
          rawZ = 0;
          rawY = 0;
        } else if (rawX < 0) {
          surface = PlacementSurface.rightWall;
          rawX = 0;
          rawY = 0;
        } else if (!draft.isFurniture && tableCells.contains((rawX, rawZ))) {
          surface = PlacementSurface.tabletop;
        } else if (!draft.isFurniture &&
            fitsHorizontalSurface(PlacementSurface.rug, rugCells)) {
          surface = PlacementSurface.rug;
        }
      } else if (surface == PlacementSurface.tabletop &&
          !tableCells.contains((rawX, rawZ))) {
        surface = PlacementSurface.floor;
      } else if (surface == PlacementSurface.rug &&
          !fitsHorizontalSurface(PlacementSurface.rug, rugCells)) {
        surface = PlacementSurface.floor;
      } else if (surface.isVertical && rawY < 0) {
        surface = PlacementSurface.floor;
        rawY = 2;
      }
    }

    final nextX = rawX.clamp(0, calibration.gridCountX - 1);
    final nextY = rawY.clamp(0, calibration.gridCountY - 1);
    final nextZ = rawZ.clamp(0, calibration.gridCountZ - 1);
    if (nextX == draft.gridX &&
        nextY == draft.gridY &&
        nextZ == draft.gridZ &&
        surface == draft.placementSurface) {
      return false;
    }
    HapticFeedback.selectionClick();
    _updateDraft(
      draft.copyWith(
        placementSurface: surface,
        gridX: nextX,
        gridY: nextY,
        gridZ: nextZ,
        rotationZ: surface != draft.placementSurface ? 0 : draft.rotationZ,
      ),
    );
    return true;
  }

  void _setRotation({double? x, double? y, double? z}) {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    final wallRotationZ = draft.placementSurface.isVertical && y != null
        ? draft.rotationZ + (y - draft.rotationY)
        : z ?? draft.rotationZ;
    _updateDraft(
      draft.copyWith(
        rotationX: _normalizeAngle(x ?? draft.rotationX),
        rotationY: draft.placementSurface.isVertical
            ? draft.rotationY
            : _normalizeAngle(y ?? draft.rotationY),
        rotationZ: _normalizeAngle(wallRotationZ),
      ),
    );
  }

  double _normalizeAngle(double value) {
    var result = value % (math.pi * 2);
    if (result < 0) {
      result += math.pi * 2;
    }
    return result;
  }

  void _undo() {
    final current = _draft;
    if (_history.isEmpty || current == null) {
      return;
    }
    final previous = _history.removeLast();
    _redoHistory.add(current);
    _updateDraft(previous, addHistory: false, clearRedo: false);
  }

  void _redo() {
    final current = _draft;
    if (_redoHistory.isEmpty || current == null) {
      return;
    }
    final next = _redoHistory.removeLast();
    _history.add(current);
    if (_history.length > 60) _history.removeAt(0);
    _updateDraft(next, addHistory: false, clearRedo: false);
  }

  void _reset() {
    final initial = _initialDraft;
    if (initial != null) {
      _updateDraft(initial);
    }
  }

  void _playSaveComplete() {
    unawaited(
      context.read<AudioController>().playEffect(SoundEffect.saveComplete),
    );
  }

  Future<void> _save(RoomProvider provider, RoomObjectModel draft) async {
    if (_storePending) {
      setState(() => _saving = true);
      try {
        await provider.removeRoomObject(draft);
        if (mounted) {
          setState(() {
            _selectedItemId = null;
            _selectedFurnitureAssetKey = null;
            _draft = null;
            _initialDraft = null;
            _validation = null;
            _history.clear();
            _redoHistory.clear();
            _error = null;
            _initializing = false;
            _isDirty = false;
            _saving = false;
            _fineAdjustment = false;
            _storePending = false;
          });
          _playSaveComplete();
        }
      } catch (_) {
        if (mounted) {
          setState(() => _saving = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('部屋から収納できませんでした')));
        }
      }
      return;
    }

    final validation = provider.validatePlacement(draft);
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation.message ?? 'この状態では配置できません')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await provider.saveRoomObject(validation.object);
      if (mounted) {
        final savedValidation = provider.validatePlacement(saved);
        setState(() {
          _draft = savedValidation.object;
          _initialDraft = savedValidation.object;
          _validation = savedValidation;
          _history.clear();
          _redoHistory.clear();
          _isDirty = false;
          _saving = false;
          _fineAdjustment = false;
          _storePending = false;
        });
        _playSaveComplete();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'.replaceFirst('Bad state: ', ''))),
        );
      }
    }
  }

  void _toggleStorePending() {
    setState(() {
      _storePending = !_storePending;
      _isDirty = _storePending || _draft != _initialDraft;
    });
  }

  // ignore: unused_element
  Future<void> _remove(RoomProvider provider, RoomObjectModel object) async {
    setState(() => _saving = true);
    try {
      await provider.removeRoomObject(object);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('部屋から取り除けませんでした')));
      }
    }
  }

  Widget _buildItemSelection(RoomProvider roomProvider, RoomModel room) {
    return Scaffold(
      backgroundColor: const Color(0xfffff8fb),
      appBar: AppBar(
        leading: BackButton(
            onPressed: AppInteractionFeedback.wrap(context, _returnToCreate)),
        backgroundColor: const Color(0xfffff8fb),
        title: Text('${room.name}を編集中'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: _roomViewportHeight(context),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RoomSceneWidget(
                        key: _roomSceneKey,
                        showPlacementGrid: true,
                        cameraDistanceScale: _roomCameraDistanceScale(context),
                        cameraTargetYOffset: 0.0,
                        room: room,
                        objects: roomProvider.objectsForRoom(room.id),
                        onObjectLongPress: (object) =>
                            _selectRoomObject(roomProvider, object),
                      ),
                    ),
                  ],
                ),
              ),
              _buildItemPicker(roomProvider, room),
            ],
          ),
        ),
      ),
    );
  }

  double _roomViewportHeight(BuildContext context) {
    final height =
        (MediaQuery.sizeOf(context).height * 0.60).clamp(360.0, 680.0);
    // Reserve space for the always-visible rotation row. The camera distance
    // below follows this viewport height, preserving the room's visual scale.
    return _hasSelection && !_fineAdjustment
        ? (height - 64).clamp(320.0, 680.0)
        : height;
  }

  double _roomCameraDistanceScale(BuildContext context) {
    final previousHeight = (MediaQuery.sizeOf(context).height * 0.68).clamp(
      420.0,
      760.0,
    );
    return _roomViewportHeight(context) / previousHeight;
  }

  void _scrollItemPickerBy(double dragDelta) {
    if (!_itemPickerScrollController.hasClients) return;
    final position = _itemPickerScrollController.position;
    final target = (position.pixels - dragDelta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((target - position.pixels).abs() < 0.5) return;
    _itemPickerScrollController.jumpTo(target);
  }

  Widget _buildItemPicker(RoomProvider roomProvider, RoomModel room) {
    final items = context
        .watch<ItemProvider>()
        .items
        .where((item) => item.placementImagePath?.isNotEmpty == true)
        .toList(growable: false);
    final furniture = FurniturePlacements.forRoom(room.id);
    return Material(
      color: const Color(0xfffff8fb),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    expandedInsets: EdgeInsets.zero,
                    segments: const [
                      ButtonSegment(value: false, label: Text('思い出')),
                      ButtonSegment(value: true, label: Text('家具')),
                    ],
                    selected: {_showFurniture},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) {
                      AppInteractionFeedback.tap(context);
                      setState(() => _showFurniture = value.first);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: _hasSelection
                      ? AppInteractionFeedback.wrap(
                          context, () => setState(() => _fineAdjustment = true))
                      : null,
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text('微調整'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 77,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.expand(),
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: AppInteractionFeedback.wrap(
                          context, () => _scrollItemPickerBy(80)),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) =>
                          _scrollItemPickerBy(details.delta.dx),
                      child: ListView.separated(
                        controller: _itemPickerScrollController,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: _showFurniture
                            ? furniture.length
                            : items.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          if (_showFurniture) {
                            final choice = furniture[index];
                            return _FurnitureChoiceCard(
                              furniture: choice,
                              selected: _selectedFurnitureAssetKey == choice.id,
                              onTap: () =>
                                  _selectFurniture(roomProvider, choice.id),
                            );
                          }
                          if (index == 0) {
                            return _UnselectedChoiceCard(
                              selected: _selectedItemId == null,
                              onTap: _clearItemSelection,
                            );
                          }
                          final item = items[index - 1];
                          return _ItemChoiceCard(
                            item: item,
                            selected: _selectedItemId == item.id,
                            placed:
                                roomProvider.objectForItem(room.id, item.id) !=
                                    null,
                            onTap: () => _selectItem(item.id),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.expand(),
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: AppInteractionFeedback.wrap(
                          context, () => _scrollItemPickerBy(-80)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectRoomObject(RoomProvider provider, RoomObjectModel object) {
    if (object.isFurniture) {
      final assetKey = object.assetKey;
      if (assetKey == null || assetKey == _selectedFurnitureAssetKey) return;
      HapticFeedback.selectionClick();
      AppInteractionFeedback.tap(context);
      _selectFurniture(provider, assetKey);
      return;
    }
    final itemId = object.itemId;
    if (itemId == null || itemId == _selectedItemId) return;
    HapticFeedback.selectionClick();
    AppInteractionFeedback.tap(context);
    _selectItem(itemId);
  }

  void _selectItem(String itemId) {
    setState(() {
      _selectedItemId = itemId;
      _selectedFurnitureAssetKey = null;
      _draft = null;
      _initialDraft = null;
      _validation = null;
      _history.clear();
      _redoHistory.clear();
      _error = null;
      _initializing = true;
    });
    _initializeDraft();
  }

  void _clearItemSelection() {
    setState(() {
      _selectedItemId = null;
      _selectedFurnitureAssetKey = null;
      _draft = null;
      _initialDraft = null;
      _validation = null;
      _history.clear();
      _redoHistory.clear();
      _error = null;
      _initializing = false;
    });
  }

  bool get _hasSelection =>
      _selectedItemId != null || _selectedFurnitureAssetKey != null;

  bool _isPlacedObject(
    RoomProvider provider,
    String roomId,
    RoomObjectModel draft,
  ) {
    if (draft.isFurniture) {
      return provider.furnitureByAssetKey(roomId, draft.assetKey ?? '') != null;
    }
    final itemId = draft.itemId;
    return itemId != null && provider.objectForItem(roomId, itemId) != null;
  }

  void _selectFurniture(RoomProvider provider, String assetKey) {
    final existing = provider.furnitureRecordByAssetKey(
      widget.roomId,
      assetKey,
    );
    if (existing == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('この家具の配置データがありません')));
      return;
    }
    final stage = FurnitureSizeSpecs.nearest(
      existing.assetKey,
      existing.effectiveScaleX,
    );
    final rotationY =
        snapPlacementRotation(existing.rotationY, isFurniture: true);
    final normalized = existing.copyWith(
      gridY: FurniturePlacements.isWallMounted(existing.assetKey)
          ? existing.isPlaced
              ? existing.gridY
              : 6
          : 0,
      rotationY: rotationY,
      scale: stage?.scale ?? existing.effectiveScaleX,
      scaleX: stage?.scale ?? existing.effectiveScaleX,
      scaleY: stage?.scale ?? existing.effectiveScaleX,
      scaleZ: stage?.scale ?? existing.effectiveScaleX,
      isPlaced: true,
    );
    final draft = provider.snapRoomObjectToGrid(normalized);
    final validation = provider.validatePlacement(draft);
    setState(() {
      _selectedItemId = null;
      _selectedFurnitureAssetKey = assetKey;
      _draft = validation.object;
      _initialDraft = validation.object;
      _validation = validation;
      _history.clear();
      _redoHistory.clear();
      _error = null;
      _initializing = false;
      _isDirty = !existing.isPlaced;
      _fineAdjustment = false;
      _storePending = false;
    });
  }
}

class _FurnitureChoiceCard extends StatelessWidget {
  final FurniturePlacement furniture;
  final bool selected;
  final VoidCallback onTap;

  const _FurnitureChoiceCard({
    required this.furniture,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (furniture.id) {
      'table' => '木のテーブル',
      'sofa' => 'ピンクのソファ',
      'cloud_rug' => '雲のラグ',
      'wall_clock' => '壁掛け時計',
      'window_back_left' => '奥の窓①',
      'window_back_right' => '奥の窓②',
      'window_left_back' => '左の窓①',
      'window_left_front' => '左の窓②',
      _ => '黒いスツール',
    };
    final thumbnailAsset = furniture.thumbnailAssetPath;
    return InkWell(
      onTap: AppInteractionFeedback.wrap(context, onTap),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 74,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffffedf2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xffff6f91) : const Color(0xffffccd6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: FurniturePlacements.isWindow(furniture.id)
                  ? const Icon(
                      Icons.window_outlined,
                      size: 36,
                      color: Color(0xff997451),
                    )
                  : Image.asset(
                      thumbnailAsset,
                      fit: BoxFit.contain,
                      cacheWidth: 96,
                      cacheHeight: 96,
                      filterQuality: FilterQuality.medium,
                    ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnselectedChoiceCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _UnselectedChoiceCard({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: AppInteractionFeedback.wrap(context, onTap),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 74,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffffedf1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xffff6f91) : const Color(0xffffccd6),
            width: selected ? 2 : 1,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pan_tool_alt_outlined, size: 29),
            SizedBox(height: 4),
            Text('未選択', style: TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _ItemChoiceCard extends StatelessWidget {
  final ItemModel item;
  final bool selected;
  final bool placed;
  final VoidCallback onTap;
  const _ItemChoiceCard({
    required this.item,
    required this.selected,
    required this.placed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: AppInteractionFeedback.wrap(context, onTap),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 74,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffffedf2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xffff6f91) : const Color(0xffffccd6),
            width: selected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Image.file(
                    File(item.placementImagePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9),
                ),
              ],
            ),
            if (placed)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xff53bd69),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlacementStatusBadge extends StatelessWidget {
  final RoomObjectModel draft;
  final PlacementValidation validation;

  const _PlacementStatusBadge({
    super.key,
    required this.draft,
    required this.validation,
  });

  @override
  Widget build(BuildContext context) {
    final isWallFurniture =
        draft.isFurniture && FurniturePlacements.isWallMounted(draft.assetKey);
    final wallStage = isWallFurniture
        ? FurnitureSizeSpecs.nearest(draft.assetKey, draft.effectiveScaleX)
        : null;

    final validMessage = draft.isFurniture
        ? isWallFurniture
            ? '現在：壁面 • 使用セル ${wallStage?.spanX ?? 1} × ${wallStage?.spanZ ?? 1}'
            : '現在：床 • 使用セル ${draft.spanX} × ${draft.spanZ}'
        : switch (draft.placementSurface) {
            PlacementSurface.floor => '現在：床\n机の色付きセルへ動かすと、自動で机の上に載ります',
            PlacementSurface.tabletop => '机の外へ動かすと、自動で床に下ります',
            _ =>
              '現在：${draft.placementSurface.label} • 使用セル ${draft.spanX} × ${draft.spanY} × ${draft.spanZ}',
          };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: validation.isValid
            ? const Color(0xe6e3f3ee)
            : const Color(0xf2ffe6e6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: validation.isValid
              ? const Color(0xffb9ded3)
              : const Color(0xffffb8c2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          validation.isValid
              ? draft.placementSurface == PlacementSurface.tabletop &&
                      !draft.isFurniture
                  ? '現在：テーブル上\n$validMessage'
                  : validMessage
              : validation.message ?? 'この状態では配置できません',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: validation.isValid
                ? const Color(0xff317665)
                : const Color(0xffa84444),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PlacementPanel extends StatelessWidget {
  final RoomObjectModel draft;
  final PlacementValidation validation;
  final bool fineAdjustment;
  final bool canUndo;
  final bool canRedo;

  final bool canStore;
  final VoidCallback onStore;
  final ValueChanged<bool> onFineChanged;
  final void Function(int x, int y, int z) onMove;
  final ValueChanged<double> onRotationYChanged;
  final ValueChanged<double> onRotationXChanged;
  final ValueChanged<double> onRotationZChanged;
  final VoidCallback onFlip;
  final VoidCallback onResetRotation;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onReset;

  const _PlacementPanel({
    required this.draft,
    required this.validation,
    required this.fineAdjustment,
    required this.canUndo,
    required this.canRedo,
    required this.canStore,
    required this.onStore,
    required this.onFineChanged,
    required this.onMove,
    required this.onRotationYChanged,
    required this.onRotationXChanged,
    required this.onRotationZChanged,
    required this.onFlip,
    required this.onResetRotation,
    required this.onUndo,
    required this.onRedo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final step = placementRotationStep(isFurniture: draft.isFurniture);
    const stepDegrees = 45;
    final angle =
        draft.placementSurface.isVertical ? draft.rotationZ : draft.rotationY;
    final degrees = ((angle * 180 / math.pi).round() % 360 + 360) % 360;
    void rotate(int direction) {
      final next = snapPlacementRotation(
        angle + direction * step,
        isFurniture: draft.isFurniture,
      );
      if (draft.placementSurface.isVertical) {
        onRotationZChanged(next);
      } else {
        onRotationYChanged(next);
      }
    }

    return Material(
      color: const Color(0xfffff8fb),
      elevation: 10,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, fineAdjustment ? 0 : 2, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fineAdjustment)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: AppInteractionFeedback.wrap(
                        context, () => onFineChanged(false)),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('通常操作に戻る'),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  fineAdjustment
                      ? '矢印で位置を微調整できます'
                      : 'ドラッグで移動 · 長押しで選択',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _FineMoveButton(
                      icon: Icons.rotate_left_rounded,
                      label: '左に$stepDegrees°',
                      onPressed: () => rotate(-1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Semantics(
                      label: '現在の角度 $degrees度',
                      child: Text('$degrees°',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  Expanded(
                    child: _FineMoveButton(
                      icon: Icons.rotate_right_rounded,
                      label: '右に$stepDegrees°',
                      onPressed: () => rotate(1),
                    ),
                  ),
                ],
              ),
              if (fineAdjustment) ...[
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _FineMoveButton(
                            icon: Icons.north_west_rounded,
                            label: '左奥',
                            onPressed: () => onMove(-1, 0, -1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _FineMoveButton(
                            icon: Icons.north_east_rounded,
                            label: '右奥',
                            onPressed: () => onMove(1, 0, -1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _FineMoveButton(
                            icon: Icons.south_west_rounded,
                            label: '左手前',
                            onPressed: () => onMove(-1, 0, 1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _FineMoveButton(
                            icon: Icons.south_east_rounded,
                            label: '右手前',
                            onPressed: () => onMove(1, 0, 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              if (!fineAdjustment) ...[
                const SizedBox.shrink(),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _HistoryButton(
                            tooltip: '元に戻す',
                            onPressed: canUndo ? onUndo : null,
                            icon: Icons.undo,
                          ),
                          _HistoryButton(
                            tooltip: 'やり直す',
                            onPressed: canRedo ? onRedo : null,
                            icon: Icons.redo,
                          ),
                          _HistoryButton(
                            tooltip: '初期状態へ戻す',
                            onPressed: onReset,
                            icon: Icons.restart_alt,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: canStore
                            ? AppInteractionFeedback.wrap(context, onStore)
                            : null,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('収納', maxLines: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  const _HistoryButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final callback = onPressed;
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 44, height: 40),
      tooltip: tooltip,
      onPressed: callback == null
          ? null
          : AppInteractionFeedback.wrap(context, callback),
      icon: Icon(icon),
    );
  }
}

class _FineMoveButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _FineMoveButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.9,
      transformHitTests: false,
      child: OutlinedButton.icon(
        onPressed: AppInteractionFeedback.wrap(context, onPressed),
        icon: Icon(icon, color: const Color(0xffef7891)),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          side: const BorderSide(color: Color(0xffffd2da)),
        ),
      ),
    );
  }
}
