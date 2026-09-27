import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('AvatarRow')
class Avatars extends Table {
  TextColumn get avatarId => text()();
  TextColumn get displayName => text()();
  TextColumn get assetPath => text().nullable()();
  TextColumn get previewImagePath => text().nullable()();
  RealColumn get defaultScale => real().withDefault(const Constant(1.0))();
  IntColumn get assetVersion => integer().withDefault(const Constant(1))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {avatarId};
}

@DataClassName('RoomRow')
class Rooms extends Table {
  TextColumn get roomId => text()();
  TextColumn get name => text()();
  TextColumn get assetPath => text()();
  TextColumn get previewImagePath => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  IntColumn get assetVersion => integer().withDefault(const Constant(1))();
  TextColumn get defaultAvatarId => text().nullable().references(
        Avatars,
        #avatarId,
        onDelete: KeyAction.setNull,
      )();
  RealColumn get cameraAzimuth => real().withDefault(const Constant(0.70))();
  RealColumn get cameraElevation => real().withDefault(const Constant(0.63))();
  RealColumn get cameraDistance => real().withDefault(const Constant(12.0))();
  RealColumn get orthographicSize => real().withDefault(const Constant(4.7))();
  RealColumn get targetX => real().withDefault(const Constant(0.0))();
  RealColumn get targetY => real().withDefault(const Constant(1.25))();
  RealColumn get targetZ => real().withDefault(const Constant(0.0))();
  RealColumn get floorY => real().withDefault(const Constant(0.0))();
  RealColumn get gridOriginX => real().withDefault(const Constant(-3.0))();
  RealColumn get gridOriginY => real().withDefault(const Constant(0.0))();
  RealColumn get gridOriginZ => real().withDefault(const Constant(-2.65))();
  RealColumn get cellSizeX => real().withDefault(const Constant(0.30))();
  RealColumn get cellSizeY => real().withDefault(const Constant(0.40))();
  RealColumn get cellSizeZ => real().withDefault(const Constant(0.265))();
  IntColumn get gridCountX => integer().withDefault(const Constant(20))();
  IntColumn get gridCountY => integer().withDefault(const Constant(8))();
  IntColumn get gridCountZ => integer().withDefault(const Constant(20))();
  IntColumn get gridVersion => integer().withDefault(const Constant(1))();
  RealColumn get walkMinX => real().withDefault(const Constant(-2.35))();
  RealColumn get walkMaxX => real().withDefault(const Constant(2.35))();
  RealColumn get walkMinZ => real().withDefault(const Constant(-1.95))();
  RealColumn get walkMaxZ => real().withDefault(const Constant(1.95))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {roomId};
}

@DataClassName('UserPreferenceRow')
class UserPreferences extends Table {
  TextColumn get profileId => text()();
  TextColumn get selectedRoomId => text().nullable().references(
        Rooms,
        #roomId,
        onDelete: KeyAction.setNull,
      )();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column<Object>> get primaryKey => {profileId};
}

@DataClassName('RoomAvatarAssignmentRow')
class RoomAvatarAssignments extends Table {
  TextColumn get assignmentId => text().withDefault(const Constant(''))();
  TextColumn get profileId => text()();
  TextColumn get roomId => text().references(
        Rooms,
        #roomId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get avatarId => text().references(
        Avatars,
        #avatarId,
        onDelete: KeyAction.restrict,
      )();
  RealColumn get posX => real().withDefault(const Constant(0.0))();
  RealColumn get posY => real().withDefault(const Constant(0.0))();
  RealColumn get posZ => real().withDefault(const Constant(0.0))();
  RealColumn get scaleX => real().withDefault(const Constant(1.0))();
  RealColumn get scaleY => real().withDefault(const Constant(1.0))();
  RealColumn get scaleZ => real().withDefault(const Constant(1.0))();
  RealColumn get rotationX => real().withDefault(const Constant(0.0))();
  RealColumn get rotationY => real().withDefault(const Constant(0.0))();
  RealColumn get rotationZ => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column<Object>> get primaryKey => {profileId, roomId};
}

class Items extends Table {
  TextColumn get itemId => text()();
  TextColumn get ownerId => text().withDefault(const Constant('local_user'))();
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get memo => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('keep'))();
  BoolColumn get transferable => boolean().withDefault(const Constant(false))();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get originalImageKey => text().nullable()();
  TextColumn get processedImageKey => text().nullable()();
  TextColumn get processedLocalImagePath => text().nullable()();
  TextColumn get outputType =>
      text().withDefault(const Constant('sticker_png'))();
  TextColumn get processStatus => text().withDefault(const Constant('idle'))();
  TextColumn get processErrorMessage => text().nullable()();
  TextColumn get processFailureStage => text().nullable()();
  DateTimeColumn get usedFrom => dateTime().nullable()();
  DateTimeColumn get usedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

@DataClassName('ItemMediaRow')
class ItemMedia extends Table {
  TextColumn get mediaId => text()();
  TextColumn get itemId => text().references(
        Items,
        #itemId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get mediaType => text()();
  TextColumn get localPath => text()();
  TextColumn get storageKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('ItemAvatarLinkRow')
class ItemAvatarLinks extends Table {
  TextColumn get itemId => text().references(
        Items,
        #itemId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get avatarId => text().references(
        Avatars,
        #avatarId,
        onDelete: KeyAction.cascade,
      )();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId, avatarId};
}

@DataClassName('RoomObjectRow')
class RoomObjects extends Table {
  TextColumn get objectId => text()();
  TextColumn get profileId =>
      text().withDefault(const Constant('local_profile'))();
  TextColumn get roomId => text()
      .withDefault(const Constant('simple_room'))
      .references(Rooms, #roomId, onDelete: KeyAction.cascade)();
  TextColumn get itemId => text().nullable().references(
        Items,
        #itemId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get objectType =>
      text().withDefault(const Constant('item_plane'))();
  TextColumn get assetKey => text().nullable()();
  TextColumn get localAssetPath => text().nullable()();
  TextColumn get storageKey => text().nullable()();
  TextColumn get placementSurface =>
      text().withDefault(const Constant('floor'))();
  IntColumn get gridX => integer().withDefault(const Constant(0))();
  IntColumn get gridY => integer().withDefault(const Constant(0))();
  IntColumn get gridZ => integer().withDefault(const Constant(0))();
  IntColumn get spanX => integer().withDefault(const Constant(1))();
  IntColumn get spanY => integer().withDefault(const Constant(1))();
  IntColumn get spanZ => integer().withDefault(const Constant(1))();
  IntColumn get gridVersion => integer().withDefault(const Constant(1))();
  RealColumn get posX => real().withDefault(const Constant(0.0))();
  RealColumn get posY => real().withDefault(const Constant(0.0))();
  RealColumn get posZ => real().withDefault(const Constant(0.0))();
  RealColumn get scale => real().withDefault(const Constant(1.0))();
  RealColumn get scaleX => real().withDefault(const Constant(1.0))();
  RealColumn get scaleY => real().withDefault(const Constant(1.0))();
  RealColumn get scaleZ => real().withDefault(const Constant(1.0))();
  RealColumn get rotationX => real().withDefault(const Constant(0.0))();
  RealColumn get rotationY => real().withDefault(const Constant(0.0))();
  RealColumn get rotationZ => real().withDefault(const Constant(0.0))();
  BoolColumn get isPlaced => boolean().withDefault(const Constant(false))();
  IntColumn get originalWidth => integer().nullable()();
  IntColumn get originalHeight => integer().nullable()();
  RealColumn get footprintWidth => real().nullable()();
  RealColumn get footprintHeight => real().nullable()();
  RealColumn get footprintDepth => real().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column<Object>> get primaryKey => {objectId};
}

@DataClassName('RoomObjectOccupiedCellRow')
class RoomObjectOccupiedCells extends Table {
  TextColumn get objectId => text().references(
        RoomObjects,
        #objectId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get roomId => text().references(
        Rooms,
        #roomId,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get gridX => integer()();
  IntColumn get gridY => integer()();
  IntColumn get gridZ => integer()();

  @override
  Set<Column<Object>> get primaryKey => {objectId, gridX, gridY, gridZ};
}

@DriftDatabase(
  tables: [
    Avatars,
    Rooms,
    UserPreferences,
    RoomAvatarAssignments,
    Items,
    ItemMedia,
    ItemAvatarLinks,
    RoomObjects,
    RoomObjectOccupiedCells,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await _migrateVersion1To2(migrator);
          }
          if (from < 3) {
            await _migrateToVersion3(migrator, addItemColumns: from >= 2);
          }
          if (from < 4) {
            await _migrateToVersion4(
              migrator,
              addAvatarColumns: from >= 3,
              addRoomObjectColumns: from >= 2,
            );
          }
          if (from < 5) {
            await _migrateToVersion5(
              migrator,
              addRoomColumns: from >= 4,
              addPreferenceAndAssignmentColumns: from >= 4,
              addRoomObjectColumns: from >= 2,
            );
          }
          if (from < 6) {
            await _migrateToVersion6(migrator);
          }
          if (from < 7) {
            await _migrateToVersion7(migrator);
          }
        },
        beforeOpen: (details) async {
          // 外部キー制約と初期カタログを、既存DBを開いた場合にも確実に有効化する。
          await customStatement('PRAGMA foreign_keys = ON');
          await _seedRoomData();
          await _createRoomIndexes();
        },
      );

  Stream<List<Item>> watchAllItems() {
    return (select(items)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  Stream<List<ItemMediaRow>> watchAllItemMedia() {
    return (select(itemMedia)
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch();
  }

  Stream<List<AvatarRow>> watchAllAvatars() {
    return (select(avatars)
          ..where((table) => table.isEnabled.equals(true))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch();
  }

  Stream<List<ItemAvatarLinkRow>> watchAllItemAvatarLinks() {
    return select(itemAvatarLinks).watch();
  }

  Stream<List<RoomRow>> watchEnabledRooms() {
    return (select(rooms)
          ..where((table) => table.isEnabled.equals(true))
          ..orderBy([(table) => OrderingTerm.asc(table.displayOrder)]))
        .watch();
  }

  Stream<List<RoomAvatarAssignmentRow>> watchRoomAvatarAssignments(
    String profileId,
  ) {
    return (select(roomAvatarAssignments)
          ..where((table) => table.profileId.equals(profileId)))
        .watch();
  }

  Stream<List<RoomObjectRow>> watchPlacedRoomObjects(String profileId) {
    return (select(roomObjects)
          ..where(
            (table) =>
                table.profileId.equals(profileId) &
                table.isPlaced.equals(true) &
                table.deletedAt.isNull(),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch();
  }

  Stream<List<RoomObjectRow>> watchRoomObjects(String profileId) {
    return (select(roomObjects)
          ..where(
            (table) =>
                table.profileId.equals(profileId) & table.deletedAt.isNull(),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .watch();
  }

  Stream<UserPreferenceRow?> watchUserPreference(String profileId) {
    return (select(userPreferences)
          ..where((table) => table.profileId.equals(profileId)))
        .watchSingleOrNull();
  }

  Future<List<Item>> getAllItems() => select(items).get();

  Future<Item?> getItemById(String itemId) {
    return (select(items)..where((table) => table.itemId.equals(itemId)))
        .getSingleOrNull();
  }

  Future<RoomObjectRow?> getPlacedRoomObject({
    required String profileId,
    required String roomId,
    required String itemId,
  }) {
    return (select(roomObjects)
          ..where(
            (table) =>
                table.profileId.equals(profileId) &
                table.roomId.equals(roomId) &
                table.itemId.equals(itemId) &
                table.isPlaced.equals(true) &
                table.deletedAt.isNull(),
          ))
        .getSingleOrNull();
  }

  Future<List<RoomObjectOccupiedCellRow>> getRoomObjectOccupiedCells(
    String objectId,
  ) {
    return (select(roomObjectOccupiedCells)
          ..where((table) => table.objectId.equals(objectId)))
        .get();
  }

  Future<int> addItem(ItemsCompanion entry) => into(items).insert(entry);

  Future<void> saveItem(ItemsCompanion item) async {
    await into(items).insertOnConflictUpdate(item);
  }

  Future<void> saveItemMedia(ItemMediaCompanion media) async {
    await into(itemMedia).insertOnConflictUpdate(media);
  }

  Future<void> saveUserPreference(UserPreferencesCompanion preference) async {
    await into(userPreferences).insertOnConflictUpdate(preference);
  }

  Future<void> saveRoomAvatarAssignment(
    RoomAvatarAssignmentsCompanion assignment,
  ) async {
    await into(roomAvatarAssignments).insertOnConflictUpdate(assignment);
  }

  Future<void> saveRoomObject(
    RoomObjectsCompanion object, {
    required String objectId,
    required List<RoomObjectOccupiedCellsCompanion> occupiedCells,
  }) async {
    // 配置本体と占有セルを同時に更新し、衝突判定用データとの不整合を防ぐ。
    await transaction(() async {
      await into(roomObjects).insertOnConflictUpdate(object);
      await (delete(roomObjectOccupiedCells)
            ..where((table) => table.objectId.equals(objectId)))
          .go();
      if (occupiedCells.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(roomObjectOccupiedCells, occupiedCells);
        });
      }
    });
  }

  Future<int> deleteItemMediaById(String mediaId) {
    return (delete(itemMedia)..where((table) => table.mediaId.equals(mediaId)))
        .go();
  }

  Future<void> replaceRelatedAvatars(
      String itemId, List<String> avatarIds) async {
    await transaction(() async {
      await (delete(itemAvatarLinks)
            ..where((table) => table.itemId.equals(itemId)))
          .go();
      for (final avatarId in avatarIds) {
        await into(itemAvatarLinks).insert(
          ItemAvatarLinksCompanion(
            itemId: Value(itemId),
            avatarId: Value(avatarId),
            createdAt: Value(DateTime.now().toUtc()),
          ),
        );
      }
    });
  }

  Future<void> replaceRelatedAvatar(String itemId, String? avatarId) async {
    await replaceRelatedAvatars(
        itemId, avatarId == null ? const [] : [avatarId]);
  }

  Future<int> deleteItemById(String itemId) {
    return (delete(items)..where((table) => table.itemId.equals(itemId))).go();
  }

  Future<void> _migrateToVersion5(
    Migrator migrator, {
    required bool addRoomColumns,
    required bool addPreferenceAndAssignmentColumns,
    required bool addRoomObjectColumns,
  }) async {
    if (addRoomColumns && !await _columnExists('rooms', 'camera_azimuth')) {
      await migrator.addColumn(rooms, rooms.cameraAzimuth);
      await migrator.addColumn(rooms, rooms.cameraElevation);
      await migrator.addColumn(rooms, rooms.cameraDistance);
      await migrator.addColumn(rooms, rooms.orthographicSize);
      await migrator.addColumn(rooms, rooms.targetX);
      await migrator.addColumn(rooms, rooms.targetY);
      await migrator.addColumn(rooms, rooms.targetZ);
      await migrator.addColumn(rooms, rooms.floorY);
      await migrator.addColumn(rooms, rooms.gridOriginX);
      await migrator.addColumn(rooms, rooms.gridOriginY);
      await migrator.addColumn(rooms, rooms.gridOriginZ);
      await migrator.addColumn(rooms, rooms.cellSizeX);
      await migrator.addColumn(rooms, rooms.cellSizeY);
      await migrator.addColumn(rooms, rooms.cellSizeZ);
      await migrator.addColumn(rooms, rooms.gridCountX);
      await migrator.addColumn(rooms, rooms.gridCountY);
      await migrator.addColumn(rooms, rooms.gridCountZ);
      await migrator.addColumn(rooms, rooms.gridVersion);
      await migrator.addColumn(rooms, rooms.walkMinX);
      await migrator.addColumn(rooms, rooms.walkMaxX);
      await migrator.addColumn(rooms, rooms.walkMinZ);
      await migrator.addColumn(rooms, rooms.walkMaxZ);
    }

    if (addPreferenceAndAssignmentColumns) {
      if (!await _columnExists('user_preferences', 'last_opened_at')) {
        await migrator.addColumn(userPreferences, userPreferences.lastOpenedAt);
        await migrator.addColumn(userPreferences, userPreferences.version);
        await migrator.addColumn(userPreferences, userPreferences.syncState);
      }
      if (!await _columnExists(
        'room_avatar_assignments',
        'assignment_id',
      )) {
        await migrator.addColumn(
          roomAvatarAssignments,
          roomAvatarAssignments.assignmentId,
        );
        await migrator.addColumn(
          roomAvatarAssignments,
          roomAvatarAssignments.version,
        );
        await migrator.addColumn(
          roomAvatarAssignments,
          roomAvatarAssignments.syncState,
        );
      }
    }

    if (addRoomObjectColumns &&
        !await _columnExists('room_objects', 'grid_x')) {
      await migrator.addColumn(roomObjects, roomObjects.gridX);
      await migrator.addColumn(roomObjects, roomObjects.gridY);
      await migrator.addColumn(roomObjects, roomObjects.gridZ);
      await migrator.addColumn(roomObjects, roomObjects.spanX);
      await migrator.addColumn(roomObjects, roomObjects.spanY);
      await migrator.addColumn(roomObjects, roomObjects.spanZ);
      await migrator.addColumn(roomObjects, roomObjects.gridVersion);
    }

    if (!await _tableExists('room_object_occupied_cells')) {
      await migrator.createTable(roomObjectOccupiedCells);
    }
    await customStatement(
      "UPDATE room_avatar_assignments SET assignment_id = "
      "profile_id || ':' || room_id WHERE assignment_id = ''",
    );
    await customStatement(
      "UPDATE room_objects SET object_type = 'processedImagePlane' "
      "WHERE object_type IN ('item', 'item_plane')",
    );
    await customStatement('''
      UPDATE room_objects SET
        grid_x = CAST((pos_x - CASE room_id
          WHEN 'pink_room' THEN -2.9 ELSE -3.0 END) /
          CASE room_id WHEN 'pink_room' THEN 0.29 ELSE 0.30 END AS INTEGER),
        grid_y = CAST(pos_y /
          CASE room_id WHEN 'pink_room' THEN 0.39 ELSE 0.40 END AS INTEGER),
        grid_z = CAST((pos_z - CASE room_id
          WHEN 'pink_room' THEN -2.55 ELSE -2.65 END) /
          CASE room_id WHEN 'pink_room' THEN 0.255 ELSE 0.265 END AS INTEGER)
      WHERE is_placed = 1
    ''');
  }

  Future<void> _migrateToVersion4(
    Migrator migrator, {
    required bool addAvatarColumns,
    required bool addRoomObjectColumns,
  }) async {
    if (addAvatarColumns && !await _columnExists('avatars', 'asset_path')) {
      await migrator.addColumn(avatars, avatars.assetPath);
      await migrator.addColumn(avatars, avatars.previewImagePath);
      await migrator.addColumn(avatars, avatars.defaultScale);
      await migrator.addColumn(avatars, avatars.assetVersion);
      await migrator.addColumn(avatars, avatars.isEnabled);
      await migrator.addColumn(avatars, avatars.updatedAt);
    }

    if (!await _tableExists('rooms')) {
      await migrator.createTable(rooms);
    }
    await _seedAvatarCatalog();
    await _seedRoomCatalog();

    if (addRoomObjectColumns &&
        !await _columnExists('room_objects', 'profile_id')) {
      await migrator.addColumn(roomObjects, roomObjects.profileId);
      await migrator.addColumn(roomObjects, roomObjects.roomId);
      await migrator.addColumn(roomObjects, roomObjects.localAssetPath);
      await migrator.addColumn(roomObjects, roomObjects.storageKey);
      await migrator.addColumn(roomObjects, roomObjects.scaleX);
      await migrator.addColumn(roomObjects, roomObjects.scaleY);
      await migrator.addColumn(roomObjects, roomObjects.scaleZ);
      await migrator.addColumn(roomObjects, roomObjects.originalWidth);
      await migrator.addColumn(roomObjects, roomObjects.originalHeight);
      await migrator.addColumn(roomObjects, roomObjects.createdAt);
      await migrator.addColumn(roomObjects, roomObjects.deletedAt);
      await migrator.addColumn(roomObjects, roomObjects.version);
      await migrator.addColumn(roomObjects, roomObjects.syncState);
    }

    if (!await _tableExists('user_preferences')) {
      await migrator.createTable(userPreferences);
    }
    if (!await _tableExists('room_avatar_assignments')) {
      await migrator.createTable(roomAvatarAssignments);
    }
    await customStatement(
      'UPDATE room_objects SET created_at = updated_at '
      'WHERE created_at IS NULL',
    );
  }

  Future<void> _migrateToVersion3(
    Migrator migrator, {
    required bool addItemColumns,
  }) async {
    if (addItemColumns) {
      await migrator.addColumn(items, items.processedLocalImagePath);
      await migrator.addColumn(items, items.processErrorMessage);
      await migrator.addColumn(items, items.processFailureStage);
      await migrator.addColumn(items, items.usedFrom);
      await migrator.addColumn(items, items.usedUntil);
    }

    await migrator.createTable(avatars);
    await migrator.createTable(itemMedia);
    await migrator.createTable(itemAvatarLinks);
    await customStatement(
      "UPDATE items SET process_status = 'idle' "
      "WHERE process_status = 'pending'",
    );
  }

  Future<bool> _tableExists(String tableName) async {
    final row = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable<String>(tableName)],
    ).getSingleOrNull();
    return row != null;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    if (!await _tableExists(tableName)) {
      return false;
    }
    final rows = await customSelect('PRAGMA table_info("$tableName")').get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<void> _migrateVersion1To2(Migrator migrator) async {
    await customStatement('ALTER TABLE room_objects RENAME TO room_objects_v1');
    await customStatement('ALTER TABLE items RENAME TO items_v1');

    await migrator.createTable(items);
    await migrator.createTable(roomObjects);

    await customStatement('''
      INSERT INTO items (
        item_id,
        owner_id,
        title,
        memo,
        status,
        transferable,
        local_image_path,
        original_image_key,
        processed_image_key,
        output_type,
        process_status,
        created_at,
        updated_at
      )
      SELECT
        'legacy_' || id,
        'local_user',
        title,
        COALESCE(memo, ''),
        'keep',
        0,
        image_path,
        NULL,
        NULL,
        'sticker_png',
        'idle',
        COALESCE(created_at, CAST(strftime('%s', 'now') AS INTEGER)),
        COALESCE(created_at, CAST(strftime('%s', 'now') AS INTEGER))
      FROM items_v1
    ''');

    await customStatement('''
      INSERT INTO room_objects (
        object_id,
        item_id,
        object_type,
        asset_key,
        pos_x,
        pos_y,
        pos_z,
        scale,
        rotation_x,
        rotation_y,
        rotation_z,
        is_placed,
        updated_at
      )
      SELECT
        'legacy_room_' || id,
        CASE
          WHEN item_id IS NULL THEN NULL
          WHEN EXISTS (
            SELECT 1 FROM items_v1 WHERE items_v1.id = room_objects_v1.item_id
          ) THEN 'legacy_' || item_id
          ELSE NULL
        END,
        'item_plane',
        name,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        0,
        CAST(strftime('%s', 'now') AS INTEGER)
      FROM room_objects_v1
    ''');

    await customStatement('DROP TABLE room_objects_v1');
    await customStatement('DROP TABLE items_v1');
  }

  Future<void> _migrateToVersion6(Migrator migrator) async {
    if (!await _columnExists('room_objects', 'footprint_width')) {
      await migrator.addColumn(roomObjects, roomObjects.footprintWidth);
    }
    if (!await _columnExists('room_objects', 'footprint_height')) {
      await migrator.addColumn(roomObjects, roomObjects.footprintHeight);
    }
    if (!await _columnExists('room_objects', 'footprint_depth')) {
      await migrator.addColumn(roomObjects, roomObjects.footprintDepth);
    }
  }

  Future<void> _migrateToVersion7(Migrator migrator) async {
    if (!await _columnExists('room_objects', 'placement_surface')) {
      await migrator.addColumn(roomObjects, roomObjects.placementSurface);
    }
  }

  Future<void> _seedRoomData() async {
    await _seedAvatarCatalog();
    await _seedRoomCatalog();
    final now = _unixNow();
    await _seedFurnitureObjects(now);
    await customStatement(
      'INSERT OR IGNORE INTO user_preferences '
      '(profile_id, selected_room_id, onboarding_completed, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?)',
      ['local_profile', 'simple_room', 1, now, now],
    );
    await _seedAssignment(
      profileId: 'local_profile',
      roomId: 'simple_room',
      avatarId: 'girl1',
      posX: -0.6,
      posZ: 0.5,
      now: now,
    );
    await _seedAssignment(
      profileId: 'local_profile',
      roomId: 'pink_room',
      avatarId: 'girl1',
      posX: 0.5,
      posZ: 0.4,
      now: now,
    );
  }

  Future<void> _seedFurnitureObjects(int now) async {
    const furniture = [
      (
        'table',
        'assets/models/furniture/table.glb',
        -2.85,
        0.0,
        0.65,
        0.55,
        0.0,
        1.5707963267948966,
        0.0,
        0.82,
        1.10,
        2.37
      ),
      (
        'sofa',
        'assets/models/furniture/chair.glb',
        1.12,
        0.0,
        -2.65,
        0.728,
        0.0,
        0.0,
        0.0,
        2.296,
        2.10,
        1.554
      ),
      (
        'metal_chair',
        null,
        2.70,
        0.0,
        0.10,
        0.952,
        0.0,
        0.8245329251994329,
        0.0,
        1.40,
        1.90,
        1.40
      ),
    ];
    for (final entry in furniture) {
      final gridX = switch (entry.$1) {
        'table' => 0,
        'sofa' => 5,
        'metal_chair' => 7,
        _ => 4,
      };
      final gridZ = switch (entry.$1) {
        'table' => 5,
        'sofa' => 1,
        'metal_chair' => 4,
        _ => 4,
      };
      await customStatement(
        'INSERT OR IGNORE INTO room_objects '
        '(object_id, profile_id, room_id, item_id, object_type, asset_key, '
        'local_asset_path, grid_x, grid_y, grid_z, grid_version, '
        'pos_x, pos_y, pos_z, scale, scale_x, scale_y, scale_z, '
        'rotation_x, rotation_y, rotation_z, is_placed, '
        'footprint_width, footprint_height, footprint_depth, '
        'created_at, updated_at, version, sync_state) '
        'VALUES (?, ?, ?, NULL, ?, ?, ?, ?, 0, ?, 4, ?, ?, ?, ?, ?, ?, ?, '
        '?, ?, ?, 1, ?, ?, ?, ?, ?, 1, ?)',
        [
          'furniture:simple_room:${entry.$1}',
          'local_profile',
          'simple_room',
          'furniture',
          entry.$1,
          entry.$2,
          gridX,
          gridZ,
          entry.$3,
          entry.$4,
          entry.$5,
          entry.$6,
          entry.$6,
          entry.$6,
          entry.$6,
          entry.$7,
          entry.$8,
          entry.$9,
          entry.$10,
          entry.$11,
          entry.$12,
          now,
          now,
          'localOnly',
        ],
      );
    }
    await customStatement(
      'INSERT OR IGNORE INTO room_objects '
      '(object_id, profile_id, room_id, item_id, object_type, asset_key, '
      'local_asset_path, grid_x, grid_y, grid_z, grid_version, '
      'pos_x, pos_y, pos_z, scale, scale_x, scale_y, scale_z, '
      'rotation_x, rotation_y, rotation_z, is_placed, '
      'footprint_width, footprint_height, footprint_depth, '
      'created_at, updated_at, version, sync_state) '
      'VALUES (?, ?, ?, NULL, ?, ?, NULL, 4, 0, 4, 4, '
      '0, 0, 0.30, 1, 1, 1, 1, 0, 0, 0, 1, '
      '5.44, 0.025, 3.6266666667, ?, ?, 1, ?)',
      [
        'furniture:simple_room:cloud_rug',
        'local_profile',
        'simple_room',
        'furniture',
        'cloud_rug',
        now,
        now,
        'localOnly',
      ],
    );
    await customStatement(
      'INSERT OR IGNORE INTO room_objects '
      '(object_id, profile_id, room_id, item_id, object_type, asset_key, '
      'local_asset_path, placement_surface, '
      'grid_x, grid_y, grid_z, grid_version, '
      'pos_x, pos_y, pos_z, scale, scale_x, scale_y, scale_z, '
      'rotation_x, rotation_y, rotation_z, is_placed, '
      'footprint_width, footprint_height, footprint_depth, '
      'created_at, updated_at, version, sync_state) '
      'VALUES (?, ?, ?, NULL, ?, ?, NULL, ?, 4, 6, 0, 4, '
      '0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, '
      '1.4, 1.4, 0.16, ?, ?, 1, ?)',
      [
        'furniture:simple_room:wall_clock',
        'local_profile',
        'simple_room',
        'furniture',
        'wall_clock',
        'leftWall',
        now,
        now,
        'localOnly',
      ],
    );
  }

  Future<void> _seedAvatarCatalog() async {
    final now = _unixNow();
    await _seedAvatar('local_user', '自分', null, now);
    await _seedAvatar(
      'boy',
      'しゅんすけ',
      'assets/models/avatar/boy.glb',
      now,
    );
    await _seedAvatar(
      'girl1',
      'あなた',
      'assets/models/avatar/girl1.glb',
      now,
    );
    await _seedAvatar(
      'girl2',
      'みか',
      'assets/models/avatar/girl2.glb',
      now,
    );
    await _seedAvatar(
      'youtienzi',
      'はるか',
      'assets/models/avatar/youtienzi.glb',
      now,
    );
  }

  Future<void> _seedAvatar(
    String avatarId,
    String displayName,
    String? assetPath,
    int now,
  ) async {
    await customStatement(
      'INSERT OR IGNORE INTO avatars '
      '(avatar_id, display_name, asset_path, preview_image_path, default_scale, '
      'asset_version, is_enabled, created_at, updated_at) '
      'VALUES (?, ?, ?, NULL, 1.0, 1, 1, ?, ?)',
      [avatarId, displayName, assetPath, now, now],
    );
    await customStatement(
      'UPDATE avatars SET display_name = ?, asset_path = ?, is_enabled = 1, '
      'updated_at = COALESCE(updated_at, ?) WHERE avatar_id = ?',
      [displayName, assetPath, now, avatarId],
    );
  }

  Future<void> _seedRoomCatalog() async {
    final now = _unixNow();
    await _seedRoom(
      'simple_room',
      'シンプルルーム',
      'assets/models/furniture/room.glb',
      0,
      'girl1',
      now,
    );
    await _seedRoom(
      'pink_room',
      'ピンクルーム',
      'assets/models/furniture/pinkroom.glb',
      1,
      'girl1',
      now,
    );
  }

  Future<void> _seedRoom(
    String roomId,
    String name,
    String assetPath,
    int displayOrder,
    String defaultAvatarId,
    int now,
  ) async {
    final isPink = roomId == 'pink_room';
    final cameraAzimuth = isPink ? 0.64 : 0.70;
    final cameraElevation = isPink ? 0.66 : 0.63;
    final cameraDistance = isPink ? 11.8 : 12.0;
    final orthographicSize = isPink ? 4.55 : 4.7;
    final targetY = isPink ? 1.18 : 1.25;
    final targetZ = isPink ? 0.05 : 0.0;
    final floorY = isPink ? 0.35 : 0.0;
    final gridOriginX = isPink ? -2.9 : -3.5;
    final gridOriginY = isPink ? 0.30 : 0.0;
    final gridOriginZ = isPink ? -2.55 : -3.5;
    final cellSizeX = isPink ? 0.6444444444 : 0.7777777778;
    final cellSizeY = isPink ? 0.39 : 0.40;
    final cellSizeZ = isPink ? 0.5666666667 : 0.7777777778;
    // simple_room v5 normalizes legacy presented-item scale values (#149).
    final gridVersion = isPink ? 3 : 7;
    final walkMinX = isPink ? -2.25 : -2.35;
    final walkMaxX = isPink ? 2.25 : 2.35;
    final walkMinZ = isPink ? -1.85 : -1.95;
    final walkMaxZ = isPink ? 1.85 : 1.95;
    await customStatement(
      'INSERT OR IGNORE INTO rooms '
      '(room_id, name, asset_path, preview_image_path, is_enabled, display_order, '
      'asset_version, default_avatar_id, created_at, updated_at) '
      'VALUES (?, ?, ?, NULL, 1, ?, 1, ?, ?, ?)',
      [roomId, name, assetPath, displayOrder, defaultAvatarId, now, now],
    );
    await customStatement(
      'UPDATE rooms SET name = ?, asset_path = ?, is_enabled = 1, '
      'display_order = ?, default_avatar_id = ?, camera_azimuth = ?, '
      'camera_elevation = ?, camera_distance = ?, orthographic_size = ?, '
      'target_x = 0.0, target_y = ?, target_z = ?, floor_y = ?, '
      'grid_origin_x = ?, grid_origin_y = ?, grid_origin_z = ?, '
      'cell_size_x = ?, cell_size_y = ?, cell_size_z = ?, '
      'grid_count_x = 9, grid_count_y = 8, grid_count_z = 9, '
      'grid_version = ?, walk_min_x = ?, walk_max_x = ?, '
      'walk_min_z = ?, walk_max_z = ?, updated_at = ? WHERE room_id = ?',
      [
        name,
        assetPath,
        displayOrder,
        defaultAvatarId,
        cameraAzimuth,
        cameraElevation,
        cameraDistance,
        orthographicSize,
        targetY,
        targetZ,
        floorY,
        gridOriginX,
        gridOriginY,
        gridOriginZ,
        cellSizeX,
        cellSizeY,
        cellSizeZ,
        gridVersion,
        walkMinX,
        walkMaxX,
        walkMinZ,
        walkMaxZ,
        now,
        roomId,
      ],
    );
  }

  Future<void> _seedAssignment({
    required String profileId,
    required String roomId,
    required String avatarId,
    required double posX,
    required double posZ,
    required int now,
  }) async {
    await customStatement(
      'INSERT OR IGNORE INTO room_avatar_assignments '
      '(assignment_id, profile_id, room_id, avatar_id, pos_x, pos_y, pos_z, '
      'scale_x, scale_y, scale_z, rotation_x, rotation_y, rotation_z, '
      'created_at, updated_at, version, sync_state) '
      'VALUES (?, ?, ?, ?, ?, 0.0, ?, 1.0, 1.0, 1.0, '
      '0.0, 0.0, 0.0, ?, ?, 1, ?)',
      [
        '$profileId:$roomId',
        profileId,
        roomId,
        avatarId,
        posX,
        posZ,
        now,
        now,
        'localOnly',
      ],
    );
  }

  Future<void> _createRoomIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_room_objects_room '
      'ON room_objects(profile_id, room_id, deleted_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_room_objects_item '
      'ON room_objects(item_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_room_avatar_assignments_avatar '
      'ON room_avatar_assignments(avatar_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_room_avatar_assignments_id '
      'ON room_avatar_assignments(assignment_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_room_occupied_cells_room '
      'ON room_object_occupied_cells(room_id, grid_x, grid_y, grid_z)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_room_objects_active_item_room '
      'ON room_objects(profile_id, room_id, item_id) '
      'WHERE item_id IS NOT NULL AND deleted_at IS NULL AND is_placed = 1',
    );
  }

  int _unixNow() => DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
