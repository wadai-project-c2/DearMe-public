import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/avatar_model.dart';
import '../models/room_models.dart';
import '../room/room_calibration.dart';

abstract class RoomRepository {
  Stream<List<RoomModel>> watchRooms();

  Stream<List<AvatarModel>> watchAvatars();

  Stream<List<RoomAvatarAssignmentModel>> watchAssignments(String profileId);

  Stream<List<RoomObjectModel>> watchObjects(String profileId);

  Stream<UserPreferencesModel?> watchPreferences(String profileId);

  Future<void> savePreferences(UserPreferencesModel preferences);

  Future<void> saveAssignment(RoomAvatarAssignmentModel assignment);

  Future<RoomObjectModel> saveObject(RoomObjectModel object);

  Future<List<RoomObjectModel>> saveObjects(List<RoomObjectModel> objects);
}

class LocalRoomRepository implements RoomRepository {
  final AppDatabase database;

  LocalRoomRepository(this.database);

  @override
  Stream<List<RoomModel>> watchRooms() {
    return database.watchEnabledRooms().map(
          (rows) => rows
              .map(
                (row) => RoomModel(
                  id: row.roomId,
                  name: row.name,
                  assetPath: row.assetPath,
                  previewImagePath: row.previewImagePath,
                  isEnabled: row.isEnabled,
                  displayOrder: row.displayOrder,
                  assetVersion: row.assetVersion,
                  defaultAvatarId: row.defaultAvatarId,
                  cameraAzimuth: row.cameraAzimuth,
                  cameraElevation: row.cameraElevation,
                  cameraDistance: row.cameraDistance,
                  orthographicSize: row.orthographicSize,
                  targetX: row.targetX,
                  targetY: row.targetY,
                  targetZ: row.targetZ,
                  floorY: row.floorY,
                  gridOriginX: row.gridOriginX,
                  gridOriginY: row.gridOriginY,
                  gridOriginZ: row.gridOriginZ,
                  cellSizeX: row.cellSizeX,
                  cellSizeY: row.cellSizeY,
                  cellSizeZ: row.cellSizeZ,
                  gridCountX: row.gridCountX,
                  gridCountY: row.gridCountY,
                  gridCountZ: row.gridCountZ,
                  gridVersion: row.gridVersion,
                  walkMinX: row.walkMinX,
                  walkMaxX: row.walkMaxX,
                  walkMinZ: row.walkMinZ,
                  walkMaxZ: row.walkMaxZ,
                  createdAt: row.createdAt.toUtc(),
                  updatedAt: row.updatedAt.toUtc(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<AvatarModel>> watchAvatars() {
    return database.watchAllAvatars().map(
          (rows) => rows
              .map(
                (row) => AvatarModel(
                  id: row.avatarId,
                  displayName: row.displayName,
                  assetPath: row.assetPath,
                  previewImagePath: row.previewImagePath,
                  defaultScale: row.defaultScale,
                  assetVersion: row.assetVersion,
                  isEnabled: row.isEnabled,
                  createdAt: row.createdAt.toUtc(),
                  updatedAt: row.updatedAt?.toUtc(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<RoomAvatarAssignmentModel>> watchAssignments(String profileId) {
    return database.watchRoomAvatarAssignments(profileId).map(
          (rows) => rows
              .map(
                (row) => RoomAvatarAssignmentModel(
                  assignmentId: row.assignmentId,
                  profileId: row.profileId,
                  roomId: row.roomId,
                  avatarId: row.avatarId,
                  posX: row.posX,
                  posY: row.posY,
                  posZ: row.posZ,
                  scaleX: row.scaleX,
                  scaleY: row.scaleY,
                  scaleZ: row.scaleZ,
                  rotationX: row.rotationX,
                  rotationY: row.rotationY,
                  rotationZ: row.rotationZ,
                  createdAt: row.createdAt.toUtc(),
                  updatedAt: row.updatedAt.toUtc(),
                  version: row.version,
                  syncState: row.syncState,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<List<RoomObjectModel>> watchObjects(String profileId) {
    return database.watchRoomObjects(profileId).asyncMap((rows) async {
      final models = <RoomObjectModel>[];
      for (final row in rows) {
        final storedCells =
            await database.getRoomObjectOccupiedCells(row.objectId);
        final model = _toObjectModel(row);
        final cells = storedCells.isEmpty
            ? RoomCalibrations.forRoom(row.roomId).occupiedCellsFor(model)
            : [
                for (final cell in storedCells)
                  GridCell(cell.gridX, cell.gridY, cell.gridZ),
              ];
        models.add(model.copyWith(occupiedCells: cells));
      }
      return models;
    });
  }

  @override
  Stream<UserPreferencesModel?> watchPreferences(String profileId) {
    return database.watchUserPreference(profileId).map((row) {
      if (row == null) {
        return null;
      }
      return UserPreferencesModel(
        profileId: row.profileId,
        selectedRoomId: row.selectedRoomId,
        onboardingCompleted: row.onboardingCompleted,
        createdAt: row.createdAt.toUtc(),
        updatedAt: row.updatedAt.toUtc(),
        lastOpenedAt: row.lastOpenedAt?.toUtc(),
        version: row.version,
        syncState: row.syncState,
      );
    });
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) {
    return database.saveUserPreference(
      UserPreferencesCompanion(
        profileId: Value(preferences.profileId),
        selectedRoomId: Value(preferences.selectedRoomId),
        onboardingCompleted: Value(preferences.onboardingCompleted),
        createdAt: Value(preferences.createdAt.toUtc()),
        updatedAt: Value(preferences.updatedAt.toUtc()),
        lastOpenedAt: Value(preferences.lastOpenedAt?.toUtc()),
        version: Value(preferences.version),
        syncState: Value(preferences.syncState),
      ),
    );
  }

  @override
  Future<void> saveAssignment(RoomAvatarAssignmentModel assignment) {
    return database.saveRoomAvatarAssignment(
      RoomAvatarAssignmentsCompanion(
        assignmentId: Value(assignment.assignmentId),
        profileId: Value(assignment.profileId),
        roomId: Value(assignment.roomId),
        avatarId: Value(assignment.avatarId),
        posX: Value(assignment.posX),
        posY: Value(assignment.posY),
        posZ: Value(assignment.posZ),
        scaleX: Value(assignment.scaleX),
        scaleY: Value(assignment.scaleY),
        scaleZ: Value(assignment.scaleZ),
        rotationX: Value(assignment.rotationX),
        rotationY: Value(assignment.rotationY),
        rotationZ: Value(assignment.rotationZ),
        createdAt: Value(assignment.createdAt.toUtc()),
        updatedAt: Value(assignment.updatedAt.toUtc()),
        version: Value(assignment.version),
        syncState: Value(assignment.syncState),
      ),
    );
  }

  @override
  Future<RoomObjectModel> saveObject(RoomObjectModel object) async {
    return _saveObject(object);
  }

  @override
  Future<List<RoomObjectModel>> saveObjects(
    List<RoomObjectModel> objects,
  ) {
    return database.transaction(() async {
      final saved = <RoomObjectModel>[];
      for (final object in objects) {
        saved.add(await _saveObject(object));
      }
      return saved;
    });
  }

  Future<RoomObjectModel> _saveObject(RoomObjectModel object) async {
    var objectToSave = object;
    final itemId = object.itemId;
    if (itemId != null) {
      final existing = await database.getPlacedRoomObject(
        profileId: object.profileId,
        roomId: object.roomId,
        itemId: itemId,
      );
      if (existing != null && existing.objectId != object.objectId) {
        objectToSave = object.copyWith(objectId: existing.objectId);
      }
    }

    final calibration = RoomCalibrations.forRoom(objectToSave.roomId);
    final occupiedCells =
        !objectToSave.isPlaced || objectToSave.deletedAt != null
            ? const <GridCell>[]
            : objectToSave.occupiedCells.isNotEmpty
                ? objectToSave.occupiedCells
                : calibration.occupiedCellsFor(objectToSave);
    objectToSave = objectToSave.copyWith(occupiedCells: occupiedCells);
    await database.saveRoomObject(
      RoomObjectsCompanion(
        objectId: Value(objectToSave.objectId),
        profileId: Value(objectToSave.profileId),
        roomId: Value(objectToSave.roomId),
        itemId: Value(objectToSave.itemId),
        objectType: Value(objectToSave.objectType),
        assetKey: Value(objectToSave.assetKey),
        localAssetPath: Value(objectToSave.localAssetPath),
        storageKey: Value(objectToSave.storageKey),
        placementSurface: Value(objectToSave.placementSurface.name),
        gridX: Value(objectToSave.gridX),
        gridY: Value(objectToSave.gridY),
        gridZ: Value(objectToSave.gridZ),
        spanX: Value(objectToSave.spanX),
        spanY: Value(objectToSave.spanY),
        spanZ: Value(objectToSave.spanZ),
        gridVersion: Value(objectToSave.gridVersion),
        posX: Value(objectToSave.posX),
        posY: Value(objectToSave.posY),
        posZ: Value(objectToSave.posZ),
        scale: Value(objectToSave.scale),
        scaleX: Value(objectToSave.scaleX),
        scaleY: Value(objectToSave.scaleY),
        scaleZ: Value(objectToSave.scaleZ),
        rotationX: Value(objectToSave.rotationX),
        rotationY: Value(objectToSave.rotationY),
        rotationZ: Value(objectToSave.rotationZ),
        isPlaced: Value(objectToSave.isPlaced),
        originalWidth: Value(objectToSave.originalWidth),
        originalHeight: Value(objectToSave.originalHeight),
        footprintWidth: Value(objectToSave.footprintWidth),
        footprintHeight: Value(objectToSave.footprintHeight),
        footprintDepth: Value(objectToSave.footprintDepth),
        createdAt: Value(objectToSave.createdAt.toUtc()),
        updatedAt: Value(objectToSave.updatedAt.toUtc()),
        deletedAt: Value(objectToSave.deletedAt?.toUtc()),
        version: Value(objectToSave.version),
        syncState: Value(objectToSave.syncState.name),
      ),
      objectId: objectToSave.objectId,
      occupiedCells: [
        for (final cell in occupiedCells)
          RoomObjectOccupiedCellsCompanion.insert(
            objectId: objectToSave.objectId,
            roomId: objectToSave.roomId,
            gridX: cell.x,
            gridY: cell.y,
            gridZ: cell.z,
          ),
      ],
    );
    return objectToSave;
  }

  RoomObjectModel _toObjectModel(
    RoomObjectRow row, {
    List<GridCell> occupiedCells = const [],
  }) {
    return RoomObjectModel(
      objectId: row.objectId,
      profileId: row.profileId,
      roomId: row.roomId,
      itemId: row.itemId,
      objectType: row.objectType,
      assetKey: row.assetKey,
      localAssetPath: row.localAssetPath,
      storageKey: row.storageKey,
      placementSurface: PlacementSurface.values.firstWhere(
        (surface) => surface.name == row.placementSurface,
        orElse: () => PlacementSurface.floor,
      ),
      gridX: row.gridX,
      gridY: row.gridY,
      gridZ: row.gridZ,
      spanX: row.spanX,
      spanY: row.spanY,
      spanZ: row.spanZ,
      gridVersion: row.gridVersion,
      posX: row.posX,
      posY: row.posY,
      posZ: row.posZ,
      scale: row.scale,
      scaleX: row.scaleX,
      scaleY: row.scaleY,
      scaleZ: row.scaleZ,
      rotationX: row.rotationX,
      rotationY: row.rotationY,
      rotationZ: row.rotationZ,
      isPlaced: row.isPlaced,
      originalWidth: row.originalWidth,
      originalHeight: row.originalHeight,
      footprintWidth: row.footprintWidth,
      footprintHeight: row.footprintHeight,
      footprintDepth: row.footprintDepth,
      createdAt: (row.createdAt ?? row.updatedAt).toUtc(),
      updatedAt: row.updatedAt.toUtc(),
      deletedAt: row.deletedAt?.toUtc(),
      version: row.version,
      syncState: RoomObjectSyncState.values.firstWhere(
        (state) => state.name == row.syncState,
        orElse: () => RoomObjectSyncState.localOnly,
      ),
      occupiedCells: occupiedCells,
    );
  }
}
