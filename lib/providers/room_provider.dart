import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/avatar_model.dart';
import '../models/item_model.dart';
import '../models/room_models.dart';
import '../repositories/room_repository.dart';
import '../room/furniture_placement.dart';
import '../room/furniture_size_spec.dart';
import '../room/presented_item_dimensions.dart';
import '../room/room_calibration.dart';
import '../room/room_surface_elevations.dart';
import '../room/room_walkability.dart';

class RoomProvider extends ChangeNotifier {
  static const String localProfileId = 'local_profile';
  static const String simpleRoomId = 'simple_room';
  static const String defaultAvatarId = 'girl1';

  final RoomRepository _repository;
  final Uuid _uuid;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  List<RoomModel> _rooms = const [];
  List<AvatarModel> _avatars = const [];
  Map<String, RoomAvatarAssignmentModel> _assignments = const {};
  List<RoomObjectModel> _objects = const [];
  UserPreferencesModel? _preferences;
  RoomAvatarAssignmentModel? _editingAssignment;
  final Set<String> _dirtyAvatarRooms = {};
  Object? _error;
  bool _hasRooms = false;
  bool _hasAvatars = false;
  bool _hasAssignments = false;
  bool _hasPreferences = false;
  bool _hasObjects = false;
  bool _fixedStateInitializing = false;
  bool _fixedStateReady = false;

  RoomProvider(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid() {
    _subscriptions.add(
      _repository.watchRooms().listen(
        (rooms) {
          _rooms = rooms;
          _hasRooms = true;
          _error = null;
          notifyListeners();
          _scheduleFixedStateInitialization();
        },
        onError: _handleError,
      ),
    );
    _subscriptions.add(
      _repository.watchAvatars().listen(
        (avatars) {
          _avatars = avatars;
          _hasAvatars = true;
          notifyListeners();
          _scheduleFixedStateInitialization();
        },
        onError: _handleError,
      ),
    );
    _subscriptions.add(
      _repository.watchAssignments(localProfileId).listen(
        (assignments) {
          _assignments = {
            for (final assignment in assignments) assignment.roomId: assignment,
          };
          _hasAssignments = true;
          notifyListeners();
          _scheduleFixedStateInitialization();
        },
        onError: _handleError,
      ),
    );
    _subscriptions.add(
      _repository.watchObjects(localProfileId).listen(
        (objects) {
          _objects = objects;
          _hasObjects = true;
          notifyListeners();
          _scheduleFixedStateInitialization();
        },
        onError: _handleError,
      ),
    );
    _subscriptions.add(
      _repository.watchPreferences(localProfileId).listen(
        (preferences) {
          _preferences = preferences;
          _hasPreferences = true;
          notifyListeners();
          _scheduleFixedStateInitialization();
        },
        onError: _handleError,
      ),
    );
  }

  List<RoomModel> get rooms => List.unmodifiable(
        _rooms.where((room) => room.id == simpleRoomId),
      );
  List<AvatarModel> get avatars =>
      List.unmodifiable(_avatars.where((avatar) => avatar.canRender));
  List<RoomObjectModel> get objects => objectsForRoom(simpleRoomId);
  UserPreferencesModel? get preferences => _preferences;
  Object? get error => _error;
  bool get isLoading =>
      !_hasRooms ||
      !_hasAvatars ||
      !_hasAssignments ||
      !_hasPreferences ||
      !_fixedStateReady;
  bool get onboardingCompleted => true;
  bool get isMovingAvatar => _editingAssignment != null;

  String? get selectedRoomId {
    return _rooms.any((room) => room.id == simpleRoomId) ? simpleRoomId : null;
  }

  RoomModel? get selectedRoom => roomById(selectedRoomId);

  RoomModel? roomById(String? roomId) {
    if (roomId == null) return null;
    for (final room in _rooms) {
      if (room.id == roomId) {
        return room;
      }
    }
    return null;
  }

  AvatarModel? avatarById(String? avatarId) {
    for (final avatar in _avatars) {
      if (avatar.id == avatarId) {
        return avatar;
      }
    }
    return null;
  }

  RoomAvatarAssignmentModel? assignmentForRoom(String roomId) {
    if (_editingAssignment?.roomId == roomId) {
      return _editingAssignment;
    }
    return _assignments[roomId];
  }

  List<RoomObjectModel> objectsForRoom(String roomId) {
    return List.unmodifiable(
      _objects
          .where(
            (object) =>
                object.roomId == roomId &&
                object.isPlaced &&
                object.deletedAt == null,
          )
          .map(_safeSimpleRoomObject),
    );
  }

  List<RoomObjectModel> furnitureForRoom(String roomId) {
    return List.unmodifiable(
      objectsForRoom(roomId).where((object) => object.isFurniture),
    );
  }

  RoomObjectModel? furnitureByAssetKey(String roomId, String assetKey) {
    for (final object in furnitureForRoom(roomId)) {
      if (object.assetKey == assetKey) return object;
    }
    return null;
  }

  RoomObjectModel? furnitureRecordByAssetKey(String roomId, String assetKey) {
    for (final object in _objects) {
      if (object.roomId == roomId &&
          object.isFurniture &&
          object.assetKey == assetKey &&
          object.deletedAt == null) {
        return _safeSimpleRoomObject(object);
      }
    }
    return null;
  }

  RoomObjectModel? objectForItem(String roomId, String itemId) {
    for (final object in _objects) {
      if (object.roomId == roomId &&
          object.itemId == itemId &&
          object.isPlaced &&
          object.deletedAt == null) {
        return _safeSimpleRoomObject(object);
      }
    }
    return null;
  }

  RoomObjectModel? objectRecordForItem(String roomId, String itemId) {
    for (final object in _objects) {
      if (object.roomId == roomId &&
          object.itemId == itemId &&
          object.deletedAt == null) {
        return _safeSimpleRoomObject(object);
      }
    }
    return null;
  }

  Future<void> completeOnboarding({
    required String roomId,
    required String avatarId,
  }) async {
    await setAvatarForRoom(simpleRoomId, avatarId);
    await _saveFixedPreferences();
  }

  Future<void> selectRoom(String roomId) async {
    if (roomById(roomId) == null) {
      return;
    }
    await _saveFixedPreferences();
  }

  Future<void> setAvatarForRoom(String roomId, String avatarId) async {
    final avatar = avatarById(avatarId);
    if (roomById(roomId) == null || avatar == null || !avatar.canRender) {
      throw ArgumentError('Unknown room or avatar');
    }
    final now = DateTime.now().toUtc();
    final current = _assignments[roomId];
    final next = RoomAvatarAssignmentModel(
      profileId: localProfileId,
      roomId: roomId,
      avatarId: avatarId,
      posX: current?.posX ?? 0,
      posY: current?.posY ?? 0,
      posZ: current?.posZ ?? 0,
      scaleX: avatar.defaultScale,
      scaleY: avatar.defaultScale,
      scaleZ: avatar.defaultScale,
      rotationX: current?.rotationX ?? 0,
      rotationY: current?.rotationY ?? 0,
      rotationZ: current?.rotationZ ?? 0,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
      version: (current?.version ?? 0) + 1,
      syncState: 'localOnly',
    );
    _assignments = {..._assignments, roomId: next};
    if (_editingAssignment?.roomId == roomId) {
      _editingAssignment = next;
    }
    notifyListeners();
    await _repository.saveAssignment(next);
  }

  void beginAvatarMovement(String roomId) {
    final assignment = _assignments[roomId];
    if (assignment == null) {
      return;
    }
    _editingAssignment = assignment;
    notifyListeners();
  }

  void nudgeAvatar({required double x, required double z}) {
    final current = _editingAssignment;
    if (current == null) {
      return;
    }
    final bounds = RoomCalibrations.forRoom(current.roomId).avatarBounds;
    final rotation = x > 0
        ? math.pi / 2
        : x < 0
            ? -math.pi / 2
            : z < 0
                ? math.pi
                : 0.0;
    _editingAssignment = current.copyWith(
      posX: (current.posX + x).clamp(bounds.minX, bounds.maxX).toDouble(),
      posY: current.posY.clamp(bounds.minY, bounds.maxY).toDouble(),
      posZ: (current.posZ + z).clamp(bounds.minZ, bounds.maxZ).toDouble(),
      rotationY: rotation,
      updatedAt: DateTime.now().toUtc(),
    );
    notifyListeners();
  }

  Future<void> saveAvatarMovement() async {
    final edited = _editingAssignment;
    if (edited == null) {
      return;
    }
    _assignments = {..._assignments, edited.roomId: edited};
    _editingAssignment = null;
    notifyListeners();
    await _repository.saveAssignment(edited);
  }

  Future<void> placeItemAtSlot({
    required String itemId,
    required String roomId,
    required double posX,
    required double posY,
    required double posZ,
    required double rotationY,
  }) async {
    final existing = _objects.firstWhere(
      (o) => o.itemId == itemId && o.roomId == roomId,
      orElse: () => RoomObjectModel(
        objectId: _uuid.v4(),
        profileId: localProfileId,
        itemId: itemId,
        roomId: roomId,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );

    final updated = existing.copyWith(
      posX: posX,
      posY: posY,
      posZ: posZ,
      rotationY: rotationY,
      isPlaced: true,
      updatedAt: DateTime.now().toUtc(),
    );

    _objects = [
      ..._objects.where((o) => o.objectId != updated.objectId),
      updated,
    ];
    notifyListeners();
    await _repository.saveObject(updated);
  }

  Future<void> removeItemAtSlot({
    required String roomId,
    required double posX,
    required double posZ,
  }) async {
    final toRemove = _objects
        .where((o) =>
            o.roomId == roomId &&
            (o.posX - posX).abs() < 0.1 &&
            (o.posZ - posZ).abs() < 0.1)
        .toList();

    for (final object in toRemove) {
      final updated = object.copyWith(
        isPlaced: false,
        updatedAt: DateTime.now().toUtc(),
      );
      _objects = [
        ..._objects.where((o) => o.objectId != updated.objectId),
        updated,
      ];
      await _repository.saveObject(updated);
    }
    notifyListeners();
  }

  void updateAvatarPose(RoomAvatarAssignmentModel pose) {
    final current = _assignments[pose.roomId];
    if (current == null || current.avatarId != pose.avatarId) {
      return;
    }
    _assignments = {..._assignments, pose.roomId: pose};
    _dirtyAvatarRooms.add(pose.roomId);
  }

  Future<void> persistAvatarPose([String? roomId]) async {
    final roomsToSave = roomId == null
        ? _dirtyAvatarRooms.toList(growable: false)
        : _dirtyAvatarRooms.contains(roomId)
            ? [roomId]
            : const <String>[];
    for (final id in roomsToSave) {
      final assignment = _assignments[id];
      if (assignment != null) {
        final saved = assignment.copyWith(
          updatedAt: DateTime.now().toUtc(),
          version: assignment.version + 1,
          syncState: 'localOnly',
        );
        _assignments = {..._assignments, id: saved};
        await _repository.saveAssignment(saved);
      }
      _dirtyAvatarRooms.remove(id);
    }
  }

  RoomObjectModel createPlacementDraft({
    required ItemModel item,
    required String roomId,
    int? originalWidth,
    int? originalHeight,
  }) {
    if (roomId != simpleRoomId) {
      throw ArgumentError('Only simpleRoom is currently available');
    }
    final existing = objectForItem(roomId, item.id);
    if (existing != null) {
      return existing;
    }
    // 加工済み画像を優先しつつ、AI加工が失敗した場合は元写真で配置する（#95）。
    final localPath = item.placementImagePath;
    if (localPath == null || localPath.isEmpty) {
      throw StateError('Local image is required for placement');
    }
    final now = DateTime.now().toUtc();
    final calibration = RoomCalibrations.forRoom(roomId);
    final cell = calibration.defaultPlacementCell;
    final center = calibration.cellCenter(cell);
    final draft = RoomObjectModel(
      objectId: _uuid.v4(),
      profileId: localProfileId,
      roomId: roomId,
      itemId: item.id,
      localAssetPath: localPath,
      objectType: 'processedImagePlane',
      gridX: cell.x,
      gridY: cell.y,
      gridZ: cell.z,
      gridVersion: calibration.gridVersion,
      posX: center.x,
      posY: center.y,
      posZ: center.z,
      // 部屋の軸ではなく画面の方を向けて置く（#97）。
      rotationY: calibration.screenFacingYaw,
      // サイズは表示ジオメトリ側で縦横比とreal_ios基準倍率へ正規化する。
      scale: 1,
      scaleX: 1,
      scaleY: 1,
      scaleZ: 1,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      createdAt: now,
      updatedAt: now,
    );
    return snapRoomObjectToGrid(draft);
  }

  /// [createPlacementDraft] は常に固定の既定セルを返すため、既に埋まっている場合は
  /// [defaultPlacementCell] を中心にリング状（最大 [maxRadius] セル）へ空きを探す。
  /// 見つからなければ null を返す（呼び出し側は配置自体をスキップする想定）。
  RoomObjectModel? findFreePlacementDraft({
    required ItemModel item,
    required String roomId,
    int? originalWidth,
    int? originalHeight,
    int maxRadius = 8,
  }) {
    final base = createPlacementDraft(
      item: item,
      roomId: roomId,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
    );
    final calibration = RoomCalibrations.forRoom(roomId);
    final rug = furnitureByAssetKey(roomId, 'cloud_rug');
    if (rug != null) {
      final rugCells = calibration
          .supportCellsForSurface(rug, PlacementSurface.rug)
          .toList(growable: false)
        ..sort((a, b) {
          final aDistance = (a.x - base.gridX).abs() + (a.z - base.gridZ).abs();
          final bDistance = (b.x - base.gridX).abs() + (b.z - base.gridZ).abs();
          return aDistance.compareTo(bDistance);
        });
      for (final cell in rugCells) {
        final candidate = base.copyWith(
          placementSurface: PlacementSurface.rug,
          gridX: cell.x,
          gridZ: cell.z,
        );
        final validation = validatePlacement(candidate);
        if (validation.isValid) {
          return validation.object;
        }
      }
    }
    final baseValidation = validatePlacement(base);
    if (baseValidation.isValid) {
      return baseValidation.object;
    }
    final centerX = base.gridX;
    final centerZ = base.gridZ;
    for (var radius = 1; radius <= maxRadius; radius++) {
      for (var dx = -radius; dx <= radius; dx++) {
        for (var dz = -radius; dz <= radius; dz++) {
          if (math.max(dx.abs(), dz.abs()) != radius) {
            continue;
          }
          final x = centerX + dx;
          final z = centerZ + dz;
          if (x < 0 ||
              x >= calibration.gridCountX ||
              z < 0 ||
              z >= calibration.gridCountZ) {
            continue;
          }
          final candidate = base.copyWith(gridX: x, gridZ: z);
          final validation = validatePlacement(candidate);
          if (validation.isValid) {
            return validation.object;
          }
        }
      }
    }
    return null;
  }

  RoomObjectModel snapRoomObjectToGrid(RoomObjectModel object) {
    final calibration = RoomCalibrations.forRoom(object.roomId);
    final needsGridConversion = object.gridVersion <
        (object.roomId == simpleRoomId ? 5 : calibration.gridVersion);
    final migratedGridX = needsGridConversion
        ? ((object.posX - calibration.gridOriginX) / calibration.cellSizeX)
            .floor()
            .clamp(0, calibration.gridCountX - 1)
        : object.gridX;
    final migratedGridZ = needsGridConversion
        ? ((object.posZ - calibration.gridOriginZ) / calibration.cellSizeZ)
            .floor()
            .clamp(0, calibration.gridCountZ - 1)
        : object.gridZ;

    final isWallFurniture = object.isFurniture &&
        FurniturePlacements.isWallMounted(object.assetKey);
    if (object.placementSurface.isVertical &&
        (!object.isFurniture || isWallFurniture)) {
      return _snapWallObjectToGrid(object, calibration);
    }
    var gridX = migratedGridX;
    // Floor/tabletop objects use X/Z cells only. Keeping the wall-oriented
    // default gridY (currently 2) here used to lift image planes by multiple
    // vertical cells before the surface elevation was added.
    var gridY = object.placementSurface.isVertical ? object.gridY : 0;
    var gridZ = migratedGridZ;
    ({int spanX, int spanZ})? furnitureSpan;
    if (object.isFurniture && !isWallFurniture) {
      final span = FurnitureSizeSpecs.rotatedSpan(
        object.assetKey,
        object.effectiveScaleX,
        object.rotationY,
      );
      furnitureSpan = span;
      final left = (span.spanX - 1) ~/ 2;
      final right = span.spanX - 1 - left;
      final back = (span.spanZ - 1) ~/ 2;
      final front = span.spanZ - 1 - back;
      gridX = gridX.clamp(left, calibration.gridCountX - 1 - right);
      gridZ = gridZ.clamp(back, calibration.gridCountZ - 1 - front);
    }

    final anchorCenter = calibration.cellCenter(GridCell(gridX, gridY, gridZ));
    final centerX = anchorCenter.x +
        (furnitureSpan?.spanX.isEven == true ? calibration.cellSizeX / 2 : 0);
    final centerZ = anchorCenter.z +
        (furnitureSpan?.spanZ.isEven == true ? calibration.cellSizeZ / 2 : 0);
    final positioned = object.copyWith(
      posX: centerX,
      gridX: gridX,
      gridY: gridY,
      gridZ: gridZ,
      posY: object.isFloorCovering
          ? calibration.floorY
          : object.isFurniture
              ? anchorCenter.y + _surfaceElevation(object.placementSurface)
              : _horizontalSurfaceObjectCenterY(object),
      posZ: centerZ,
      gridVersion: calibration.gridVersion,
    );
    final cells = calibration.occupiedCellsFor(positioned);
    if (cells.isEmpty) {
      return positioned.copyWith(occupiedCells: const []);
    }
    final xs = cells.map((cell) => cell.x);
    final ys = cells.map((cell) => cell.y);
    final zs = cells.map((cell) => cell.z);
    return positioned.copyWith(
      spanX: xs.reduce(math.max) - xs.reduce(math.min) + 1,
      spanY: ys.reduce(math.max) - ys.reduce(math.min) + 1,
      spanZ: zs.reduce(math.max) - zs.reduce(math.min) + 1,
      occupiedCells: cells,
    );
  }

  double _surfaceElevation(PlacementSurface surface) => switch (surface) {
        PlacementSurface.tabletop => 0.85,
        PlacementSurface.rug => RoomSurfaceElevations.rugObjectSupport,
        _ => 0.0,
      };

  double _horizontalSurfaceObjectCenterY(RoomObjectModel object) {
    final calibration = RoomCalibrations.forRoom(object.roomId);
    final dimensions = presentedItemDimensions(
      object.aspectRatio,
      cellSizeX: calibration.cellSizeX,
      cellSizeY: calibration.cellSizeY,
      cellSizeZ: calibration.cellSizeZ,
    );
    final displayedHeight =
        object.footprintHeight ?? dimensions.height * object.effectiveScaleY;
    return calibration.floorY +
        _surfaceElevation(object.placementSurface) +
        displayedHeight / 2;
  }

  RoomObjectModel _snapWallObjectToGrid(
    RoomObjectModel object,
    RoomSceneCalibration calibration,
  ) {
    final rotationY = object.placementSurface == PlacementSurface.leftWall
        ? 0.0
        : math.pi / 2;
    var candidate = object.copyWith(
      gridX: object.gridX.clamp(0, calibration.gridCountX - 1),
      gridY: object.gridY.clamp(0, calibration.gridCountY - 1),
      gridZ: object.gridZ.clamp(0, calibration.gridCountZ - 1),
      gridVersion: calibration.gridVersion,
      rotationX: 0,
      rotationY: rotationY,
    );
    var cells = calibration.occupiedCellsFor(candidate);
    final minX = cells.map((cell) => cell.x).reduce(math.min);
    final maxX = cells.map((cell) => cell.x).reduce(math.max);
    final minY = cells.map((cell) => cell.y).reduce(math.min);
    final maxY = cells.map((cell) => cell.y).reduce(math.max);
    final minZ = cells.map((cell) => cell.z).reduce(math.min);
    final maxZ = cells.map((cell) => cell.z).reduce(math.max);
    final gridX = (candidate.gridX - math.min(0, minX))
        .clamp(
            0, calibration.gridCountX - 1 - math.max(0, maxX - candidate.gridX))
        .toInt();
    final gridY = (candidate.gridY - math.min(0, minY))
        .clamp(
            0, calibration.gridCountY - 1 - math.max(0, maxY - candidate.gridY))
        .toInt();
    final gridZ = (candidate.gridZ - math.min(0, minZ))
        .clamp(
            0, calibration.gridCountZ - 1 - math.max(0, maxZ - candidate.gridZ))
        .toInt();
    final horizontalCenter = calibration.cellCenter(
      GridCell(gridX, gridY, gridZ),
    );
    final isLeftWall = object.placementSurface == PlacementSurface.leftWall;
    final horizontalSpan = isLeftWall ? maxX - minX + 1 : maxZ - minZ + 1;
    final verticalSpan = maxY - minY + 1;
    final horizontalOffset = horizontalSpan.isEven
        ? (isLeftWall ? calibration.cellSizeX : calibration.cellSizeZ) / 2
        : 0.0;
    final verticalOffset =
        verticalSpan.isEven ? calibration.cellSizeY / 2 : 0.0;
    candidate = candidate.copyWith(
      gridX: gridX,
      gridY: gridY,
      gridZ: gridZ,
      posX: isLeftWall
          ? horizontalCenter.x + horizontalOffset
          : calibration.gridOriginX + 0.025,
      posY: horizontalCenter.y + verticalOffset,
      posZ: isLeftWall
          ? calibration.gridOriginZ + 0.025
          : horizontalCenter.z + horizontalOffset,
    );
    cells = calibration.occupiedCellsFor(candidate);
    final xs = cells.map((cell) => cell.x);
    final ys = cells.map((cell) => cell.y);
    final zs = cells.map((cell) => cell.z);
    return candidate.copyWith(
      spanX: xs.reduce(math.max) - xs.reduce(math.min) + 1,
      spanY: ys.reduce(math.max) - ys.reduce(math.min) + 1,
      spanZ: zs.reduce(math.max) - zs.reduce(math.min) + 1,
      occupiedCells: cells,
    );
  }

  PlacementValidation validatePlacement(RoomObjectModel object) {
    final snapped = snapRoomObjectToGrid(object);
    final calibration = RoomCalibrations.forRoom(snapped.roomId);
    if (snapped.occupiedCells.any((cell) => !calibration.containsCell(cell))) {
      return PlacementValidation.invalid(snapped, '部屋の外には配置できません');
    }
    if (snapped.isFurniture && snapped.assetKey == 'table') {
      final supportCells = {
        for (final cell in calibration.supportCellsForSurface(
          snapped,
          PlacementSurface.tabletop,
        ))
          (cell.x, cell.z),
      };
      final leavesSupport = _objects
          .where((other) =>
              other.roomId == snapped.roomId &&
              other.isPlaced &&
              other.deletedAt == null &&
              other.placementSurface == PlacementSurface.tabletop)
          .expand(calibration.occupiedCellsFor)
          .any((cell) => !supportCells.contains((cell.x, cell.z)));
      if (leavesSupport) {
        return PlacementValidation.invalid(
          snapped,
          '天板上のアイテムを床へ戻してから移動してください',
        );
      }
    }
    final isWallFurniture = snapped.isFurniture &&
        FurniturePlacements.isWallMounted(snapped.assetKey);
    if (snapped.isFurniture &&
        ((!isWallFurniture &&
                snapped.placementSurface != PlacementSurface.floor) ||
            (isWallFurniture && !snapped.placementSurface.isVertical))) {
      return PlacementValidation.invalid(
        snapped,
        isWallFurniture ? '壁掛け家具は壁面にのみ配置できます' : '家具は床にのみ配置できます',
      );
    }
    if (snapped.placementSurface == PlacementSurface.tabletop) {
      final support = _objects
          .where((other) =>
              other.roomId == snapped.roomId &&
              other.assetKey == 'table' &&
              other.isPlaced &&
              other.deletedAt == null)
          .firstOrNull;
      if (support == null) {
        return PlacementValidation.invalid(snapped, 'テーブルが配置されていません');
      }
      final supportCells = {
        for (final cell in calibration.supportCellsForSurface(
          support,
          PlacementSurface.tabletop,
        ))
          (cell.x, cell.z),
      };
      if (snapped.occupiedCells
          .any((cell) => !supportCells.contains((cell.x, cell.z)))) {
        return PlacementValidation.invalid(
          snapped,
          'テーブルの天板からはみ出しています',
        );
      }
    }
    if (snapped.placementSurface == PlacementSurface.rug) {
      final support = _objects
          .where((other) =>
              other.roomId == snapped.roomId &&
              other.assetKey == 'cloud_rug' &&
              other.isPlaced &&
              other.deletedAt == null)
          .firstOrNull;
      if (support == null) {
        return PlacementValidation.invalid(snapped, 'ラグが配置されていません');
      }
      final supportCells = {
        for (final cell in calibration.supportCellsForSurface(
          support,
          PlacementSurface.rug,
        ))
          (cell.x, cell.z),
      };
      if (snapped.occupiedCells
          .any((cell) => !supportCells.contains((cell.x, cell.z)))) {
        return PlacementValidation.invalid(
          snapped,
          'ラグからはみ出しています',
        );
      }
    }

    String cellKey(PlacementSurface surface, GridCell cell) =>
        switch (surface) {
          PlacementSurface.leftWall => '${cell.x}:${cell.y}',
          PlacementSurface.rightWall => '${cell.z}:${cell.y}',
          _ => '${cell.x}:${cell.z}',
        };
    String collisionGroup(RoomObjectModel object) {
      if (object.isFloorCovering) return 'floorCovering';
      return switch (object.placementSurface) {
        PlacementSurface.floor || PlacementSurface.rug => 'groundObjects',
        _ => object.placementSurface.name,
      };
    }

    final occupiedByOthers = <String>{
      for (final other in _objects)
        if (other.roomId == snapped.roomId &&
            other.objectId != snapped.objectId &&
            other.isPlaced &&
            other.deletedAt == null &&
            collisionGroup(other) == collisionGroup(snapped))
          for (final cell in calibration.occupiedCellsFor(other))
            cellKey(other.placementSurface, cell),
    };
    if (snapped.occupiedCells.any((cell) =>
        occupiedByOthers.contains(cellKey(snapped.placementSurface, cell)))) {
      final message = snapped.isFloorCovering
          ? 'ほかの敷物と重なっています'
          : snapped.isFurniture
              ? 'ほかの家具・アイテムと重なっています'
              : 'ほかの思い出の品と重なっています';
      return PlacementValidation.invalid(snapped, message);
    }
    if (!RoomWalkability.preservesReachableFloor(
      calibration: calibration,
      existingObjects: _objects,
      candidate: snapped,
    )) {
      return PlacementValidation.invalid(
        snapped,
        'アバターの通り道をふさぐため配置できません',
      );
    }
    return PlacementValidation.valid(snapped);
  }

  Future<RoomObjectModel> saveRoomObject(RoomObjectModel object) async {
    final now = DateTime.now().toUtc();
    final validation = validatePlacement(object);
    if (!validation.isValid) {
      throw StateError(validation.message ?? 'この状態では配置できません');
    }
    final prepared = validation.object.copyWith(
      isPlaced: true,
      updatedAt: now,
      clearDeletedAt: true,
      version: object.version + 1,
      syncState: RoomObjectSyncState.localOnly,
    );
    final rugItemsToFloor = prepared.isFloorCovering
        ? await _unsupportedRugItemsAsFloor(prepared.roomId, prepared, now)
        : const <RoomObjectModel>[];
    final savedObjects = rugItemsToFloor.isEmpty
        ? [await _repository.saveObject(prepared)]
        : await _repository.saveObjects([
            prepared,
            ...rugItemsToFloor,
          ]);
    final saved = savedObjects.first;
    final savedRugItems = savedObjects.skip(1).toList(growable: false);
    final updatedIds = {
      saved.objectId,
      for (final item in savedRugItems) item.objectId,
    };
    _objects = [
      ..._objects.where((current) => !updatedIds.contains(current.objectId)),
      saved,
      ...savedRugItems,
    ];
    notifyListeners();
    return saved;
  }

  Future<List<RoomObjectModel>> _unsupportedRugItemsAsFloor(
    String roomId,
    RoomObjectModel? rug,
    DateTime now,
  ) async {
    final supportCells = rug == null
        ? const <(int, int)>{}
        : {
            for (final cell
                in RoomCalibrations.forRoom(rug.roomId).supportCellsForSurface(
              rug,
              PlacementSurface.rug,
            ))
              (cell.x, cell.z),
          };
    final storedObjects = await _repository.watchObjects(localProfileId).first;
    final converted = <RoomObjectModel>[];
    for (final item in storedObjects.where((candidate) =>
        candidate.roomId == roomId &&
        candidate.isPlaced &&
        candidate.deletedAt == null &&
        candidate.placementSurface == PlacementSurface.rug)) {
      final calibration = RoomCalibrations.forRoom(item.roomId);
      final staysSupported = rug != null &&
          calibration
              .occupiedCellsFor(item)
              .every((cell) => supportCells.contains((cell.x, cell.z)));
      if (staysSupported) continue;
      final floorItem = snapRoomObjectToGrid(
        item.copyWith(placementSurface: PlacementSurface.floor),
      );
      final validation = validatePlacement(floorItem);
      if (!validation.isValid) {
        throw StateError(
          'ラグ上のアイテムを床へ戻せません。先にアイテムを移動してください',
        );
      }
      converted.add(validation.object.copyWith(
        updatedAt: now,
        version: item.version + 1,
        syncState: RoomObjectSyncState.localOnly,
      ));
    }
    return converted;
  }

  Future<void> removeRoomObject(RoomObjectModel object) async {
    if (object.assetKey == 'table' &&
        _objects.any((other) =>
            other.roomId == object.roomId &&
            other.isPlaced &&
            other.deletedAt == null &&
            other.placementSurface == PlacementSurface.tabletop)) {
      throw StateError('天板上のアイテムを床へ戻してから収納してください');
    }
    final now = DateTime.now().toUtc();
    final rugItemsToFloor = object.isFloorCovering
        ? await _unsupportedRugItemsAsFloor(object.roomId, null, now)
        : const <RoomObjectModel>[];
    final removed = object.copyWith(
      isPlaced: false,
      clearDeletedAt: true,
      updatedAt: now,
      version: object.version + 1,
      syncState: RoomObjectSyncState.localOnly,
    );
    final savedObjects = rugItemsToFloor.isEmpty
        ? [await _repository.saveObject(removed)]
        : await _repository.saveObjects([
            removed,
            ...rugItemsToFloor,
          ]);
    final saved = savedObjects.first;
    final savedRugItems = savedObjects.skip(1).toList(growable: false);
    final updatedIds = {
      object.objectId,
      for (final item in savedRugItems) item.objectId,
    };
    _objects = [
      ..._objects.where((current) => !updatedIds.contains(current.objectId)),
      saved,
      ...savedRugItems,
    ];
    notifyListeners();
  }

  void _scheduleFixedStateInitialization() {
    if (_fixedStateReady ||
        _fixedStateInitializing ||
        !_hasRooms ||
        !_hasAvatars ||
        !_hasAssignments ||
        !_hasPreferences ||
        !_hasObjects) {
      return;
    }
    _fixedStateInitializing = true;
    unawaited(_ensureFixedRoomState());
  }

  Future<void> _ensureFixedRoomState() async {
    try {
      RoomModel? room;
      for (final candidate in _rooms) {
        if (candidate.id == simpleRoomId) {
          room = candidate;
          break;
        }
      }
      if (room == null) {
        throw StateError('simpleRoom is not available');
      }

      final currentAssignment = _assignments[simpleRoomId];
      final currentAvatar = avatarById(currentAssignment?.avatarId);
      final fallbackAvatar = avatarById(defaultAvatarId);
      final selectedAvatar = fallbackAvatar?.canRender == true
          ? fallbackAvatar
          : avatars.isEmpty
              ? null
              : avatars.first;
      if (selectedAvatar == null) {
        throw StateError('No renderable avatar is available');
      }

      if (currentAssignment == null ||
          currentAssignment.avatarId != selectedAvatar.id ||
          currentAvatar?.canRender != true) {
        final now = DateTime.now().toUtc();
        const calibration = RoomCalibrations.simple;
        final bounds = calibration.avatarBounds;
        final next = RoomAvatarAssignmentModel(
          profileId: localProfileId,
          roomId: simpleRoomId,
          avatarId: selectedAvatar.id,
          posX: (currentAssignment?.posX ?? calibration.avatarSpawn.x)
              .clamp(bounds.minX, bounds.maxX)
              .toDouble(),
          posY: (currentAssignment?.posY ?? calibration.avatarSpawn.y)
              .clamp(bounds.minY, bounds.maxY)
              .toDouble(),
          posZ: (currentAssignment?.posZ ?? calibration.avatarSpawn.z)
              .clamp(bounds.minZ, bounds.maxZ)
              .toDouble(),
          scaleX: selectedAvatar.defaultScale,
          scaleY: selectedAvatar.defaultScale,
          scaleZ: selectedAvatar.defaultScale,
          rotationX: currentAssignment?.rotationX ?? 0,
          rotationY: currentAssignment?.rotationY ?? 0,
          rotationZ: currentAssignment?.rotationZ ?? 0,
          createdAt: currentAssignment?.createdAt ?? now,
          updatedAt: now,
          version: (currentAssignment?.version ?? 0) + 1,
          syncState: 'localOnly',
        );
        _assignments = {..._assignments, simpleRoomId: next};
        await _repository.saveAssignment(next);
      }

      await _saveFixedPreferences();
      await _migrateRoomObjectsToCurrentGrid();
      await _ensureEditableWindows();
      _error = null;
    } catch (error, stackTrace) {
      debugPrint(
        '[RoomProvider][fixed_room] failed '
        'type=${error.runtimeType}',
      );
      _error = error;
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    } finally {
      _fixedStateInitializing = false;
      _fixedStateReady = true;
      notifyListeners();
    }
  }

  Future<void> _ensureEditableWindows() async {
    final stored = await _repository.watchObjects(localProfileId).first;
    final now = DateTime.now().toUtc();
    const defaults = [
      ('window_back_left', PlacementSurface.leftWall, 2),
      ('window_back_right', PlacementSurface.leftWall, 6),
      ('window_left_back', PlacementSurface.rightWall, 2),
      ('window_left_front', PlacementSurface.rightWall, 6),
    ];
    for (final (key, surface, cell) in defaults) {
      final id = 'furniture:simple_room:$key';
      if (stored.any((object) => object.objectId == id)) continue;
      final window = snapRoomObjectToGrid(RoomObjectModel(
        objectId: id,
        profileId: localProfileId,
        roomId: simpleRoomId,
        objectType: 'furniture',
        assetKey: key,
        placementSurface: surface,
        gridX: surface == PlacementSurface.leftWall ? cell : 0,
        gridY: 3,
        gridZ: surface == PlacementSurface.rightWall ? cell : 0,
        gridVersion: RoomCalibrations.simple.gridVersion,
        createdAt: now,
        updatedAt: now,
      ));
      final saved = await _repository.saveObject(window);
      _objects = [..._objects.where((object) => object.objectId != id), saved];
    }
  }

  Future<void> _saveFixedPreferences() async {
    final current = _preferences;
    if (current?.selectedRoomId == simpleRoomId &&
        current?.onboardingCompleted == true) {
      return;
    }
    final now = DateTime.now().toUtc();
    final next = UserPreferencesModel(
      profileId: localProfileId,
      selectedRoomId: simpleRoomId,
      onboardingCompleted: true,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
      lastOpenedAt: now,
      version: (current?.version ?? 0) + 1,
      syncState: current?.syncState ?? 'localOnly',
    );
    _preferences = next;
    notifyListeners();
    await _repository.savePreferences(next);
  }

  /// 旧グリッドの配置をワールド座標から現行グリッドへ一度だけ移行する。
  ///
  /// 同時に画面向き配置(#97)より前の未回転アイテムだけを
  /// [RoomSceneCalibration.screenFacingYaw] へ向き直す。手動回転と家具の向きは保持する。
  Future<void> _migrateRoomObjectsToCurrentGrid() async {
    for (final object in _objects.toList(growable: false)) {
      final calibration = RoomCalibrations.forRoom(object.roomId);
      if (object.gridVersion >= calibration.gridVersion) {
        continue;
      }
      final oriented =
          object.gridVersion < 5 && !object.isFurniture && object.rotationY == 0
              ? object.copyWith(rotationY: calibration.screenFacingYaw)
              : object;
      // Versions before v5 stored the default gift multiplier as 0.72.
      // Only normalize that exact legacy default; any user-adjusted scale is
      // preserved as an intentional override.
      final resized =
          object.gridVersion < 5 && _usesLegacyPresentedItemScale(oriented)
              ? oriented.copyWith(scale: 1, scaleX: 1, scaleY: 1, scaleZ: 1)
              : oriented;
      final migrated = _safeSimpleRoomObject(resized).copyWith(
        updatedAt: DateTime.now().toUtc(),
        version: object.version + 1,
        syncState: RoomObjectSyncState.localOnly,
      );
      final saved = await _repository.saveObject(migrated);
      _objects = [
        ..._objects.where((current) => current.objectId != saved.objectId),
        saved,
      ];
    }
  }

  bool _usesLegacyPresentedItemScale(RoomObjectModel object) {
    const legacyScale = 0.72;
    bool isLegacyAxis(double value) =>
        (value - legacyScale).abs() < 1e-9 || (value - 1).abs() < 1e-9;
    return !object.isFurniture &&
        object.objectType == 'processedImagePlane' &&
        (object.scale - legacyScale).abs() < 1e-9 &&
        isLegacyAxis(object.scaleX) &&
        isLegacyAxis(object.scaleY) &&
        isLegacyAxis(object.scaleZ);
  }

  RoomObjectModel _safeSimpleRoomObject(RoomObjectModel object) {
    const calibration = RoomCalibrations.simple;
    var candidate = object;
    var snapped = snapRoomObjectToGrid(candidate);
    final isUnsafe = snapped.occupiedCells.any(
      (cell) => !calibration.containsCell(cell),
    );
    if (isUnsafe) {
      final fallback = calibration.defaultPlacementCell;
      candidate = candidate.copyWith(
        gridX: fallback.x,
        gridY: fallback.y,
        gridZ: fallback.z,
        gridVersion: calibration.gridVersion,
      );
      snapped = snapRoomObjectToGrid(candidate);
    }
    return snapped;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _error = error;
    _hasRooms = true;
    _hasAvatars = true;
    _hasAssignments = true;
    _hasPreferences = true;
    _fixedStateReady = true;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_dirtyAvatarRooms.isNotEmpty) {
      unawaited(persistAvatarPose());
    }
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class PlacementValidation {
  final RoomObjectModel object;
  final bool isValid;
  final String? message;

  const PlacementValidation._(this.object, this.isValid, this.message);

  factory PlacementValidation.valid(RoomObjectModel object) {
    return PlacementValidation._(object, true, null);
  }

  factory PlacementValidation.invalid(RoomObjectModel object, String message) {
    return PlacementValidation._(object, false, message);
  }
}
