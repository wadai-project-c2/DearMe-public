import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:dearme/database/app_database.dart';
import 'package:dearme/models/item_model.dart';
import 'package:dearme/models/room_models.dart';
import 'package:dearme/providers/room_provider.dart';
import 'package:dearme/repositories/item_repository.dart';
import 'package:dearme/repositories/room_repository.dart';
import 'package:dearme/room/presented_item_dimensions.dart';
import 'package:dearme/room/room_calibration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('room persistence', () {
    late AppDatabase database;
    late LocalRoomRepository roomRepository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      roomRepository = LocalRoomRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('fresh database seeds rooms, avatars, preferences, and assignments',
        () async {
      final rooms = await roomRepository.watchRooms().first;
      final avatars = await roomRepository.watchAvatars().first;
      final preferences = await roomRepository
          .watchPreferences(RoomProvider.localProfileId)
          .first;
      final assignments = await roomRepository
          .watchAssignments(RoomProvider.localProfileId)
          .first;

      expect(rooms.map((room) => room.id), ['simple_room', 'pink_room']);
      expect(
        rooms.firstWhere((room) => room.id == 'simple_room').assetPath,
        'assets/models/furniture/room.glb',
      );
      expect(
        rooms.firstWhere((room) => room.id == 'simple_room').defaultAvatarId,
        'girl1',
      );
      expect(
        avatars.where((avatar) => avatar.canRender).map((avatar) => avatar.id),
        containsAll(['boy', 'girl1', 'girl2', 'youtienzi']),
      );
      expect(
        avatars.firstWhere((avatar) => avatar.id == 'boy').assetPath,
        'assets/models/avatar/boy.glb',
      );
      expect(preferences?.selectedRoomId, 'simple_room');
      expect(preferences?.onboardingCompleted, isTrue);
      expect(assignments, hasLength(2));
      final furniture =
          (await roomRepository.watchObjects(RoomProvider.localProfileId).first)
              .where((object) => object.isFurniture)
              .toList(growable: false);
      expect(furniture, hasLength(5));
      final wallClock =
          furniture.singleWhere((object) => object.assetKey == 'wall_clock');
      expect(wallClock.placementSurface, PlacementSurface.leftWall);
      expect(wallClock.isPlaced, isFalse);
      final simpleRoom = rooms.singleWhere((room) => room.id == 'simple_room');
      expect(simpleRoom.gridCountX, RoomCalibrations.simple.gridCountX);
      expect(simpleRoom.gridCountZ, RoomCalibrations.simple.gridCountZ);
      expect(simpleRoom.gridVersion, RoomCalibrations.simple.gridVersion);
      expect(simpleRoom.gridOriginX, RoomCalibrations.simple.gridOriginX);
      expect(simpleRoom.gridOriginZ, RoomCalibrations.simple.gridOriginZ);

      final regularFurniture = furniture
          .where((object) =>
              !object.isFloorCovering &&
              object.placementSurface == PlacementSurface.floor)
          .toList();
      for (var first = 0; first < regularFurniture.length; first++) {
        final firstFootprint = {
          for (final cell in regularFurniture[first].occupiedCells)
            (cell.x, cell.z),
        };
        for (var second = first + 1;
            second < regularFurniture.length;
            second++) {
          final secondFootprint = {
            for (final cell in regularFurniture[second].occupiedCells)
              (cell.x, cell.z),
          };
          expect(
            firstFootprint.intersection(secondFootprint),
            isEmpty,
            reason:
                '${regularFurniture[first].assetKey} and ${regularFurniture[second].assetKey} must not overlap',
          );
        }
      }
      final sofa = furniture.singleWhere((object) => object.assetKey == 'sofa');
      expect(sofa.localAssetPath, 'assets/models/furniture/chair.glb');
      expect(sofa.footprintWidth, closeTo(2.296, 0.001));
      expect(sofa.footprintHeight, closeTo(2.1, 0.001));
      expect(sofa.footprintDepth, closeTo(1.554, 0.001));
      await roomRepository.saveObject(
        sofa.copyWith(
          posX: 0.75,
          rotationY: 1.25,
          scale: 0.8,
          scaleX: 0.8,
          scaleY: 0.8,
          scaleZ: 0.8,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      final restoredFurniture = await roomRepository
          .watchObjects(RoomProvider.localProfileId)
          .firstWhere((objects) => objects.any((object) =>
              object.objectId == sofa.objectId && object.posX == 0.75));
      final restoredSofa = restoredFurniture
          .singleWhere((object) => object.objectId == sofa.objectId);
      expect(restoredSofa.posX, 0.75);
      expect(restoredSofa.rotationY, 1.25);
      expect(restoredSofa.effectiveScaleX, 0.8);
    });

    test('provider saves setup, room switch, avatar movement, and item plane',
        () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      expect(provider.rooms.map((room) => room.id), ['simple_room']);
      expect(provider.selectedRoomId, RoomProvider.simpleRoomId);
      expect(provider.onboardingCompleted, isTrue);

      await provider.completeOnboarding(
        roomId: 'pink_room',
        avatarId: 'girl2',
      );
      expect(provider.selectedRoomId, 'simple_room');
      expect(provider.onboardingCompleted, isTrue);

      await provider.setAvatarForRoom('simple_room', 'girl2');
      provider.beginAvatarMovement('simple_room');
      provider.nudgeAvatar(x: 0.36, z: 0.18);
      await provider.saveAvatarMovement();

      final savedAssignments = await roomRepository
          .watchAssignments(RoomProvider.localProfileId)
          .firstWhere(
            (assignments) => assignments.any(
              (assignment) =>
                  assignment.roomId == 'simple_room' &&
                  assignment.avatarId == 'girl2' &&
                  assignment.posX > -0.6,
            ),
          );
      final simpleAssignment = savedAssignments.firstWhere(
        (assignment) => assignment.roomId == 'simple_room',
      );
      expect(simpleAssignment.avatarId, 'girl2');
      expect(simpleAssignment.posX, closeTo(-0.24, 0.001));
      expect(simpleAssignment.posZ, closeTo(0.68, 0.001));

      final now = DateTime.now().toUtc();
      final item = ItemModel(
        id: 'item_for_room',
        title: '思い出の品',
        processedLocalImagePath: r'C:\local\processed.png',
        processStatus: ImageProcessStatus.completed,
        createdAt: now,
      );
      await LocalItemRepository(database).saveItem(item);
      final draft = provider.createPlacementDraft(
        item: item,
        roomId: 'simple_room',
        originalWidth: 1200,
        originalHeight: 800,
      );
      final saved = await provider.saveRoomObject(
        draft.copyWith(gridX: 4, gridY: 3, gridZ: 6, rotationY: 0.5),
      );

      final restored = await roomRepository
          .watchObjects(RoomProvider.localProfileId)
          .firstWhere(
              (objects) => objects.any((object) => object.itemId == item.id));
      final restoredPlane =
          restored.firstWhere((object) => object.itemId == item.id);
      expect(restoredPlane.objectId, saved.objectId);
      expect(restoredPlane.localAssetPath, item.processedLocalImagePath);
      expect(restoredPlane.aspectRatio, 1.5);
      final expectedCenter = RoomCalibrations.simple.cellCenter(
        const GridCell(4, 0, 6),
      );
      expect(restoredPlane.posX, closeTo(expectedCenter.x, 0.001));
      expect(restoredPlane.gridY, 0);
      expect(restoredPlane.effectiveScaleX, 1);
      expect(restoredPlane.effectiveScaleY, 1);
      expect(restoredPlane.effectiveScaleZ, 1);
      final itemHeight = presentedItemDimensions(
            restoredPlane.aspectRatio,
            cellSizeX: RoomCalibrations.simple.cellSizeX,
            cellSizeY: RoomCalibrations.simple.cellSizeY,
            cellSizeZ: RoomCalibrations.simple.cellSizeZ,
          ).height *
          restoredPlane.effectiveScaleY;
      expect(restoredPlane.posY, closeTo(itemHeight / 2, 0.001));
      expect(restoredPlane.occupiedCells, isNotEmpty);

      final duplicateAttempt = await roomRepository.saveObject(
        restoredPlane.copyWith(objectId: 'duplicate_object', posX: 1.3),
      );
      expect(duplicateAttempt.objectId, restoredPlane.objectId);

      final savedPreferences = await roomRepository
          .watchPreferences(RoomProvider.localProfileId)
          .firstWhere(
              (preferences) => preferences?.selectedRoomId == 'simple_room');
      expect(savedPreferences?.onboardingCompleted, isTrue);
    });

    test('furniture models are centered on their occupied cells', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      const calibration = RoomCalibrations.simple;

      for (final assetKey in ['table', 'sofa', 'metal_chair']) {
        final source = provider.furnitureByAssetKey(
          RoomProvider.simpleRoomId,
          assetKey,
        )!;
        final snapped = provider.snapRoomObjectToGrid(source);
        final centers = snapped.occupiedCells
            .map(calibration.cellCenter)
            .toList(growable: false);
        final centerX =
            centers.map((center) => center.x).reduce((a, b) => a + b) /
                centers.length;
        final centerZ =
            centers.map((center) => center.z).reduce((a, b) => a + b) /
                centers.length;
        expect(snapped.posX, closeTo(centerX, 0.0001), reason: assetKey);
        expect(snapped.posZ, closeTo(centerZ, 0.0001), reason: assetKey);
      }
    });
    test('placement collision follows the moved furniture X/Z footprint',
        () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);

      final table = provider.furnitureByAssetKey(
        RoomProvider.simpleRoomId,
        'table',
      );
      expect(table, isNotNull);
      final now = DateTime.now().toUtc();

      RoomObjectModel itemAt(int gridX, int gridZ) {
        return provider.snapRoomObjectToGrid(
          RoomObjectModel(
            objectId: 'collision_item_${gridX}_$gridZ',
            profileId: RoomProvider.localProfileId,
            roomId: RoomProvider.simpleRoomId,
            itemId: 'collision_item_${gridX}_$gridZ',
            objectType: 'processedImagePlane',
            localAssetPath: r'C:\local\collision.png',
            gridX: gridX,
            gridY: 2,
            gridZ: gridZ,
            gridVersion: RoomCalibrations.simple.gridVersion,
            footprintWidth: 0.1,
            footprintHeight: 0.1,
            footprintDepth: 0.1,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final oldPositionItem = itemAt(table!.gridX, table.gridZ);
      expect(provider.validatePlacement(oldPositionItem).isValid, isFalse);

      final movedTable = await provider.saveRoomObject(
        table.copyWith(gridX: 2, gridZ: 2),
      );
      expect(provider.validatePlacement(oldPositionItem).isValid, isTrue);

      final newPositionItem = itemAt(movedTable.gridX, movedTable.gridZ);
      expect(provider.validatePlacement(newPositionItem).isValid, isFalse);
      expect(newPositionItem.gridY, 0);
    });
    test('wall surfaces snap, collide per surface, and persist', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      final now = DateTime.now().toUtc();
      final base = RoomObjectModel(
        objectId: 'wall_surface_item',
        profileId: RoomProvider.localProfileId,
        roomId: RoomProvider.simpleRoomId,
        objectType: 'processedImagePlane',
        placementSurface: PlacementSurface.leftWall,
        gridX: 4,
        gridY: 6,
        gridZ: 4,
        gridVersion: RoomCalibrations.simple.gridVersion,
        footprintWidth: 0.3,
        footprintHeight: 0.3,
        footprintDepth: 0.03,
        createdAt: now,
        updatedAt: now,
      );

      final leftWall = provider.snapRoomObjectToGrid(base);
      expect(leftWall.rotationY, 0);
      expect(leftWall.posZ,
          closeTo(RoomCalibrations.simple.gridOriginZ + 0.025, 1e-9));
      expect(provider.validatePlacement(leftWall).isValid, isTrue);

      final onWindow = provider.snapRoomObjectToGrid(
        base.copyWith(objectId: 'window_item', gridX: 2, gridY: 3),
      );
      final windowValidation = provider.validatePlacement(onWindow);
      expect(windowValidation.isValid, isFalse);
      expect(windowValidation.message, contains('重な'));

      await provider.saveRoomObject(leftWall);

      final sameWall = provider.snapRoomObjectToGrid(
        base.copyWith(objectId: 'same_wall_item'),
      );
      expect(provider.validatePlacement(sameWall).isValid, isFalse);

      final otherWall = provider.snapRoomObjectToGrid(
        base.copyWith(
          objectId: 'right_wall_item',
          placementSurface: PlacementSurface.rightWall,
        ),
      );
      expect(provider.validatePlacement(otherWall).isValid, isTrue);

      final restored =
          (await roomRepository.watchObjects(RoomProvider.localProfileId).first)
              .singleWhere((object) => object.objectId == leftWall.objectId);
      expect(restored.placementSurface, PlacementSurface.leftWall);
      expect(restored.gridX, leftWall.gridX);
      expect(restored.gridY, leftWall.gridY);
    });

    test('wall furniture snaps to wall cells and rejects floor placement',
        () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);

      final now = DateTime.now().toUtc();
      final wallClock = provider.snapRoomObjectToGrid(
        RoomObjectModel(
          objectId: 'wall_clock_test',
          profileId: RoomProvider.localProfileId,
          roomId: RoomProvider.simpleRoomId,
          objectType: 'furniture',
          assetKey: 'wall_clock',
          placementSurface: PlacementSurface.leftWall,
          gridX: 4,
          gridY: 6,
          gridZ: 0,
          gridVersion: RoomCalibrations.simple.gridVersion,
          footprintWidth: 1.4,
          footprintHeight: 1.4,
          footprintDepth: 0.16,
          isPlaced: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(wallClock.occupiedCells, hasLength(4));
      final occupiedCenters = wallClock.occupiedCells
          .map(RoomCalibrations.simple.cellCenter)
          .toList(growable: false);
      final occupiedCenterX = occupiedCenters
              .map((center) => center.x)
              .reduce((left, right) => left + right) /
          occupiedCenters.length;
      final occupiedCenterY = occupiedCenters
              .map((center) => center.y)
              .reduce((left, right) => left + right) /
          occupiedCenters.length;
      expect(wallClock.posX, closeTo(occupiedCenterX, 1e-9));
      expect(wallClock.posY, closeTo(occupiedCenterY, 1e-9));
      expect(provider.validatePlacement(wallClock).isValid, isTrue);

      final floorClock = provider.snapRoomObjectToGrid(
        wallClock.copyWith(placementSurface: PlacementSurface.floor),
      );
      expect(provider.validatePlacement(floorClock).isValid, isFalse);
    });

    test('windows can move, resize and stay stored after provider restart',
        () async {
      final provider = RoomProvider(roomRepository);
      await _waitUntil(() => !provider.isLoading);
      final window = provider.furnitureByAssetKey(
        RoomProvider.simpleRoomId,
        'window_back_left',
      )!;
      final moved = await provider.saveRoomObject(window.copyWith(
        gridX: 1,
        gridY: 6,
        scale: 0.75,
        scaleX: 0.75,
        scaleY: 0.75,
        scaleZ: 0.75,
      ));
      expect(moved.gridY, 6);
      expect(moved.spanX, 2);
      expect(moved.spanY, 2);
      await provider.removeRoomObject(moved);
      provider.dispose();
      final reopened = RoomProvider(roomRepository);
      addTearDown(reopened.dispose);
      await _waitUntil(() => !reopened.isLoading);
      final restored = reopened.furnitureRecordByAssetKey(
        RoomProvider.simpleRoomId,
        'window_back_left',
      )!;
      expect(restored.isPlaced, isFalse);
      expect(restored.gridY, 6);
      expect(restored.effectiveScaleX, 0.75);
      final records =
          await roomRepository.watchObjects(RoomProvider.localProfileId).first;
      expect(
          records.where(
              (object) => object.assetKey?.startsWith('window_') == true),
          hasLength(4));
    });

    test('tabletop and rug placements stay supported and persist', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      final now = DateTime.now().toUtc();

      RoomObjectModel supported(
        String id,
        PlacementSurface surface,
        String supportKey,
      ) {
        final support = provider.furnitureByAssetKey(
          RoomProvider.simpleRoomId,
          supportKey,
        )!;
        return provider.snapRoomObjectToGrid(
          RoomObjectModel(
            objectId: id,
            profileId: RoomProvider.localProfileId,
            roomId: RoomProvider.simpleRoomId,
            objectType: 'processedImagePlane',
            placementSurface: surface,
            gridX: support.gridX,
            gridY: 2,
            gridZ: support.gridZ,
            gridVersion: RoomCalibrations.simple.gridVersion,
            footprintWidth: 0.1,
            footprintHeight: 0.1,
            footprintDepth: 0.02,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final tabletop = supported(
        'tabletop_item',
        PlacementSurface.tabletop,
        'table',
      );
      expect(provider.validatePlacement(tabletop).isValid, isTrue);
      expect(tabletop.gridY, 0);
      expect(tabletop.posY, closeTo(0.90, 1e-9));

      // At 45 degrees, usable tabletop cells must follow the diagonal,
      // rather than the enlarged furniture bounding box's horizontal strip.
      const calibration = RoomCalibrations.simple;
      final diagonalTable = provider.snapRoomObjectToGrid(
        provider
            .furnitureByAssetKey(RoomProvider.simpleRoomId, 'table')!
            .copyWith(rotationY: 0.7853981633974483, gridX: 5, gridZ: 5),
      );
      final diagonalTop = calibration.supportCellsForSurface(
          diagonalTable, PlacementSurface.tabletop);
      expect(diagonalTop, isNotEmpty);
      expect(diagonalTop.length,
          lessThan(calibration.occupiedCellsFor(diagonalTable).length));
      for (final cell in diagonalTop) {
        final center = calibration.cellCenter(cell);
        final localDepth = ((center.x - diagonalTable.posX) +
                (center.z - diagonalTable.posZ)) *
            0.7071067811865476;
        expect(localDepth.abs(),
            lessThanOrEqualTo(calibration.cellSizeZ / 2 + 1e-7));
      }

      final rug = supported('rug_item', PlacementSurface.rug, 'cloud_rug');
      final carpet = provider.furnitureByAssetKey(
        RoomProvider.simpleRoomId,
        'cloud_rug',
      )!;
      expect(provider.snapRoomObjectToGrid(carpet).posY,
          RoomCalibrations.simple.floorY);
      expect(provider.validatePlacement(rug).isValid, isTrue);
      expect(rug.posY, greaterThan(0.04));
      expect(rug.placementSurface, PlacementSurface.rug);
      expect(rug.gridY, 0);
      expect(rug.posY, closeTo(0.09, 1e-9));

      final savedRug = await provider.saveRoomObject(rug);
      expect(savedRug.placementSurface, PlacementSurface.rug);
      final restoredRug =
          (await roomRepository.watchObjects(RoomProvider.localProfileId).first)
              .singleWhere((object) => object.objectId == rug.objectId);
      expect(restoredRug.placementSurface, PlacementSurface.rug);

      final outsideRug = provider.snapRoomObjectToGrid(
        rug.copyWith(objectId: 'outside_rug', gridX: 8, gridZ: 8),
      );
      expect(provider.validatePlacement(outsideRug).isValid, isFalse);
      expect(
        provider.validatePlacement(outsideRug).message,
        contains('ラグ'),
      );

      final outsideTable = provider.snapRoomObjectToGrid(
        tabletop.copyWith(objectId: 'outside_table', gridX: 8, gridZ: 8),
      );
      expect(provider.validatePlacement(outsideTable).isValid, isFalse);
      expect(
        provider.validatePlacement(outsideTable).message,
        contains('天板'),
      );
    });
    test('moving and storing a rug updates supported item surfaces', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      final rug = provider.furnitureByAssetKey(
        RoomProvider.simpleRoomId,
        'cloud_rug',
      )!;
      const calibration = RoomCalibrations.simple;
      final supportCells = calibration
          .supportCellsForSurface(rug, PlacementSurface.rug)
          .toList()
        ..sort((a, b) => a.x.compareTo(b.x));
      final now = DateTime.now().toUtc();

      RoomObjectModel rugItem(String id, GridCell cell) =>
          provider.snapRoomObjectToGrid(RoomObjectModel(
            objectId: id,
            profileId: RoomProvider.localProfileId,
            roomId: RoomProvider.simpleRoomId,
            placementSurface: PlacementSurface.rug,
            gridX: cell.x,
            gridZ: cell.z,
            gridVersion: calibration.gridVersion,
            footprintWidth: 0.1,
            footprintHeight: 0.1,
            footprintDepth: 0.02,
            createdAt: now,
            updatedAt: now,
          ));

      final leaves = await provider.saveRoomObject(
        rugItem('rug_item_leaves', supportCells.first),
      );
      final stays = await provider.saveRoomObject(
        rugItem('rug_item_stays', supportCells.last),
      );
      expect(leaves.placementSurface, PlacementSurface.rug);
      expect(stays.placementSurface, PlacementSurface.rug);

      final movedRug = await provider.saveRoomObject(
        rug.copyWith(gridX: rug.gridX + 1),
      );
      var restored =
          await roomRepository.watchObjects(RoomProvider.localProfileId).first;
      expect(
        restored
            .singleWhere((item) => item.objectId == leaves.objectId)
            .placementSurface,
        PlacementSurface.floor,
      );
      expect(
        restored
            .singleWhere((item) => item.objectId == stays.objectId)
            .placementSurface,
        PlacementSurface.rug,
      );

      await provider.removeRoomObject(movedRug);
      restored = await roomRepository
          .watchObjects(RoomProvider.localProfileId)
          .firstWhere((objects) => objects
              .where((item) => item.objectId == stays.objectId)
              .any((item) => item.placementSurface == PlacementSurface.floor));
      expect(
        restored
            .singleWhere((item) => item.objectId == stays.objectId)
            .placementSurface,
        PlacementSurface.floor,
      );
      expect(
        provider.objects
            .singleWhere((item) => item.objectId == stays.objectId)
            .placementSurface,
        PlacementSurface.floor,
      );
    });
    test('rug items collide with regular floor furniture', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      final rug = provider.furnitureByAssetKey(
        RoomProvider.simpleRoomId,
        'cloud_rug',
      )!;
      const calibration = RoomCalibrations.simple;
      final supportCell =
          calibration.supportCellsForSurface(rug, PlacementSurface.rug).first;
      final now = DateTime.now().toUtc();
      final rugItem = provider.snapRoomObjectToGrid(RoomObjectModel(
        objectId: 'rug_collision_item',
        profileId: RoomProvider.localProfileId,
        roomId: RoomProvider.simpleRoomId,
        placementSurface: PlacementSurface.rug,
        gridX: supportCell.x,
        gridZ: supportCell.z,
        gridVersion: calibration.gridVersion,
        footprintWidth: 0.1,
        footprintHeight: 0.1,
        footprintDepth: 0.02,
        createdAt: now,
        updatedAt: now,
      ));
      expect(provider.validatePlacement(rugItem).isValid, isTrue);
      await provider.saveRoomObject(rugItem);

      final floorFurniture = provider.snapRoomObjectToGrid(RoomObjectModel(
        objectId: 'floor_furniture_on_rug_item',
        profileId: RoomProvider.localProfileId,
        roomId: RoomProvider.simpleRoomId,
        objectType: 'furniture',
        assetKey: 'metal_chair',
        placementSurface: PlacementSurface.floor,
        gridX: supportCell.x,
        gridZ: supportCell.z,
        gridVersion: calibration.gridVersion,
        scale: 0.714,
        scaleX: 0.714,
        scaleY: 0.714,
        scaleZ: 0.714,
        createdAt: now,
        updatedAt: now,
      ));
      expect(provider.validatePlacement(floorFurniture).isValid, isFalse);
    });
    test('stored avatar selection is normalized to the fixed avatar', () async {
      expect(RoomProvider.defaultAvatarId, 'girl1');

      final now = DateTime.now().toUtc();
      await roomRepository.savePreferences(
        UserPreferencesModel(
          profileId: RoomProvider.localProfileId,
          selectedRoomId: 'pink_room',
          onboardingCompleted: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await roomRepository.saveAssignment(
        RoomAvatarAssignmentModel(
          profileId: RoomProvider.localProfileId,
          roomId: 'pink_room',
          avatarId: 'girl2',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      await _waitUntil(
        () =>
            provider.assignmentForRoom(RoomProvider.simpleRoomId)?.avatarId ==
            RoomProvider.defaultAvatarId,
      );

      expect(provider.selectedRoomId, RoomProvider.simpleRoomId);
      expect(
        provider.assignmentForRoom(RoomProvider.simpleRoomId)?.avatarId,
        RoomProvider.defaultAvatarId,
      );
      final preferences = await roomRepository
          .watchPreferences(RoomProvider.localProfileId)
          .firstWhere(
            (value) => value?.selectedRoomId == RoomProvider.simpleRoomId,
          );
      expect(preferences?.onboardingCompleted, isTrue);
    });
  });

  test('legacy 20x20 database reopens on the 9x9 grid without clamping',
      () async {
    final tempDirectory =
        await Directory.systemTemp.createTemp('dearme_legacy_grid_');
    final file =
        File('${tempDirectory.path}${Platform.pathSeparator}db.sqlite');

    AppDatabase? initialDatabase;
    AppDatabase? reopenedDatabase;
    RoomProvider? reopenedProvider;
    try {
      initialDatabase = AppDatabase(NativeDatabase(file));
      final initialRepository = LocalRoomRepository(initialDatabase);
      final now = DateTime.now().toUtc();
      await LocalItemRepository(initialDatabase).saveItem(
        ItemModel(
          id: 'legacy_grid_item',
          title: '旧グリッドの品物',
          processedLocalImagePath: r'C:\local\legacy-grid.png',
          processStatus: ImageProcessStatus.completed,
          createdAt: now,
        ),
      );
      await initialRepository.saveObject(
        RoomObjectModel(
          objectId: 'legacy_grid_object',
          profileId: RoomProvider.localProfileId,
          roomId: RoomProvider.simpleRoomId,
          itemId: 'legacy_grid_item',
          objectType: 'processedImagePlane',
          localAssetPath: r'C:\local\legacy-grid.png',
          gridX: 19,
          gridY: 2,
          gridZ: 19,
          gridVersion: 1,
          posX: -2.0,
          posY: 1.0,
          posZ: 1.0,
          scale: 0.72,
          scaleX: 0.72,
          scaleY: 0.72,
          scaleZ: 0.72,
          originalWidth: 1200,
          originalHeight: 800,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await initialDatabase.close();
      initialDatabase = null;

      final legacy = sqlite3.open(file.path);
      legacy.execute('''
        UPDATE rooms
        SET grid_origin_x = -3.0,
            grid_origin_z = -2.65,
            cell_size_x = 0.30,
            cell_size_z = 0.265,
            grid_count_x = 20,
            grid_count_z = 20,
            grid_version = 1
        WHERE room_id = 'simple_room';
      ''');
      legacy.dispose();

      reopenedDatabase = AppDatabase(NativeDatabase(file));
      final reopenedRepository = LocalRoomRepository(reopenedDatabase);
      reopenedProvider = RoomProvider(reopenedRepository);
      await _waitUntil(() => !reopenedProvider!.isLoading);
      await _waitUntil(() async {
        final objects = await reopenedRepository
            .watchObjects(RoomProvider.localProfileId)
            .first;
        return objects.any(
          (object) =>
              object.objectId == 'legacy_grid_object' &&
              object.gridVersion == RoomCalibrations.simple.gridVersion,
        );
      });

      final room = (await reopenedRepository.watchRooms().first)
          .singleWhere((room) => room.id == RoomProvider.simpleRoomId);
      expect(room.gridCountX, 9);
      expect(room.gridCountZ, 9);
      expect(room.gridVersion, RoomCalibrations.simple.gridVersion);

      final migrated = (await reopenedRepository
              .watchObjects(RoomProvider.localProfileId)
              .first)
          .singleWhere((object) => object.objectId == 'legacy_grid_object');
      expect(migrated.gridX, 1);
      expect(migrated.gridZ, 5);
      expect(migrated.gridX, isNot(8));
      expect(migrated.gridZ, isNot(8));
      expect(migrated.isPlaced, isTrue);
    } finally {
      reopenedProvider?.dispose();
      await reopenedDatabase?.close();
      await initialDatabase?.close();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  });
  test('storing every furniture item survives database reopen', () async {
    final tempDirectory =
        await Directory.systemTemp.createTemp('dearme_store_all_');
    final file =
        File('${tempDirectory.path}${Platform.pathSeparator}db.sqlite');

    AppDatabase? firstDatabase;
    AppDatabase? reopenedDatabase;
    RoomProvider? firstProvider;
    RoomProvider? reopenedProvider;
    try {
      firstDatabase = AppDatabase(NativeDatabase(file));
      firstProvider = RoomProvider(LocalRoomRepository(firstDatabase));
      await _waitUntil(() => !firstProvider!.isLoading);

      final furniture = firstProvider.furnitureForRoom(
        RoomProvider.simpleRoomId,
      );
      expect(furniture, hasLength(8));
      for (final object in furniture) {
        await firstProvider.removeRoomObject(object);
      }
      await _waitUntil(
        () =>
            firstProvider!.furnitureForRoom(RoomProvider.simpleRoomId).isEmpty,
      );
      expect(
        firstProvider.furnitureForRoom(RoomProvider.simpleRoomId),
        isEmpty,
      );

      firstProvider.dispose();
      firstProvider = null;
      await firstDatabase.close();
      firstDatabase = null;

      reopenedDatabase = AppDatabase(NativeDatabase(file));
      final reopenedRepository = LocalRoomRepository(reopenedDatabase);
      reopenedProvider = RoomProvider(reopenedRepository);
      await _waitUntil(() => !reopenedProvider!.isLoading);

      expect(
        reopenedProvider.furnitureForRoom(RoomProvider.simpleRoomId),
        isEmpty,
      );
      final records = await reopenedRepository
          .watchObjects(RoomProvider.localProfileId)
          .first;
      final furnitureRecords =
          records.where((object) => object.isFurniture).toList();
      expect(furnitureRecords, hasLength(9));
      expect(furnitureRecords.every((object) => !object.isPlaced), isTrue);
    } finally {
      reopenedProvider?.dispose();
      firstProvider?.dispose();
      await reopenedDatabase?.close();
      await firstDatabase?.close();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  });
  test('saved item placement survives database reopen', () async {
    final tempDirectory =
        await Directory.systemTemp.createTemp('dearme_restart_');
    final file =
        File('${tempDirectory.path}${Platform.pathSeparator}db.sqlite');

    AppDatabase? firstDatabase;
    AppDatabase? reopenedDatabase;
    RoomProvider? firstProvider;
    RoomProvider? reopenedProvider;
    try {
      firstDatabase = AppDatabase(NativeDatabase(file));
      final firstRepository = LocalRoomRepository(firstDatabase);
      firstProvider = RoomProvider(firstRepository);
      await _waitUntil(() => !firstProvider!.isLoading);

      final now = DateTime.now().toUtc();
      final item = ItemModel(
        id: 'restart_item',
        title: '再起動確認用アイテム',
        processedLocalImagePath: r'C:\local\restart-item.png',
        processStatus: ImageProcessStatus.completed,
        createdAt: now,
      );
      await LocalItemRepository(firstDatabase).saveItem(item);
      final draft = firstProvider.findFreePlacementDraft(
        item: item,
        roomId: RoomProvider.simpleRoomId,
        originalWidth: 900,
        originalHeight: 600,
      );
      expect(draft, isNotNull);
      final saved = await firstProvider.saveRoomObject(
        draft!.copyWith(rotationY: 1.5707963267948966),
      );

      firstProvider.dispose();
      firstProvider = null;
      await firstDatabase.close();
      firstDatabase = null;

      reopenedDatabase = AppDatabase(NativeDatabase(file));
      final reopenedRepository = LocalRoomRepository(reopenedDatabase);
      reopenedProvider = RoomProvider(reopenedRepository);
      await _waitUntil(() => !reopenedProvider!.isLoading);

      final restored = reopenedProvider.objectForItem(
        RoomProvider.simpleRoomId,
        item.id,
      );
      expect(restored, isNotNull);
      expect(restored!.objectId, saved.objectId);
      expect(restored.gridX, saved.gridX);
      expect(restored.gridY, saved.gridY);
      expect(restored.gridZ, saved.gridZ);
      expect(restored.rotationY, closeTo(saved.rotationY, 0.000001));
      expect(restored.localAssetPath, item.processedLocalImagePath);
      expect(restored.occupiedCells, saved.occupiedCells);
    } finally {
      reopenedProvider?.dispose();
      firstProvider?.dispose();
      await reopenedDatabase?.close();
      await firstDatabase?.close();
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    }
  });

  test('schema version 3 room object is preserved by version 5 migration',
      () async {
    final tempDirectory = await Directory.systemTemp.createTemp('dearme_v3_');
    final file =
        File('${tempDirectory.path}${Platform.pathSeparator}db.sqlite');
    final legacy = sqlite3.open(file.path);
    legacy.execute('''
      CREATE TABLE avatars (
        avatar_id TEXT NOT NULL PRIMARY KEY,
        display_name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
      CREATE TABLE room_objects (
        object_id TEXT NOT NULL PRIMARY KEY,
        item_id TEXT,
        object_type TEXT NOT NULL DEFAULT 'item',
        asset_key TEXT,
        pos_x REAL NOT NULL DEFAULT 0.0,
        pos_y REAL NOT NULL DEFAULT 0.0,
        pos_z REAL NOT NULL DEFAULT 0.0,
        scale REAL NOT NULL DEFAULT 1.0,
        rotation_x REAL NOT NULL DEFAULT 0.0,
        rotation_y REAL NOT NULL DEFAULT 0.0,
        rotation_z REAL NOT NULL DEFAULT 0.0,
        is_placed INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL
      );
      INSERT INTO avatars (avatar_id, display_name, created_at)
      VALUES ('local_user', '自分', 1700000000);
      INSERT INTO room_objects (
        object_id, object_type, asset_key, pos_x, pos_y, pos_z,
        scale, rotation_x, rotation_y, rotation_z, is_placed, updated_at
      ) VALUES (
        'legacy_object', 'item', 'legacy_asset', 0.2, 0.4, 0.6,
        1.0, 0.0, 0.0, 0.0, 1, 1700000000
      );
      PRAGMA user_version = 3;
    ''');
    legacy.dispose();

    final migratedDatabase = AppDatabase(NativeDatabase(file));
    try {
      final rooms = await migratedDatabase.watchEnabledRooms().first;
      final objects = await migratedDatabase
          .watchPlacedRoomObjects(RoomProvider.localProfileId)
          .first;

      expect(rooms, hasLength(2));
      final legacyObject =
          objects.singleWhere((object) => object.objectId == 'legacy_object');
      expect(objects.where((object) => object.objectType == 'furniture'),
          hasLength(4));
      expect(legacyObject.roomId, 'simple_room');
      expect(legacyObject.createdAt, isNotNull);
      expect(legacyObject.syncState, 'localOnly');
      expect(legacyObject.gridVersion, 1);
      expect(legacyObject.placementSurface, 'floor');
    } finally {
      await migratedDatabase.close();
      await tempDirectory.delete(recursive: true);
    }
  });

  test('complete room schema with a stale version is migrated idempotently',
      () async {
    final tempDirectory =
        await Directory.systemTemp.createTemp('dearme_stale_');
    final file =
        File('${tempDirectory.path}${Platform.pathSeparator}db.sqlite');
    final initialDatabase = AppDatabase(NativeDatabase(file));
    final now = DateTime.now().toUtc();
    await initialDatabase.saveItem(
      ItemsCompanion.insert(
        itemId: 'preserved-item',
        title: '残す品物',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await initialDatabase.watchEnabledRooms().first;
    await initialDatabase.close();

    final stale = sqlite3.open(file.path);
    stale.execute('PRAGMA user_version = 3');
    stale.dispose();

    final reopened = AppDatabase(NativeDatabase(file));
    try {
      final rooms = await reopened.watchEnabledRooms().first;
      final item = await reopened.getItemById('preserved-item');
      expect(rooms.map((room) => room.roomId), contains('simple_room'));
      expect(item?.title, '残す品物');
    } finally {
      await reopened.close();
      await tempDirectory.delete(recursive: true);
    }
  });
}

Future<void> _waitUntil(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final stopwatch = Stopwatch()..start();
  while (!await condition()) {
    if (stopwatch.elapsed > timeout) {
      throw TimeoutException('Condition was not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
