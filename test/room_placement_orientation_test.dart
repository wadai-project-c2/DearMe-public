import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dearme/database/app_database.dart';
import 'package:dearme/models/item_model.dart';
import 'package:dearme/models/room_models.dart';
import 'package:dearme/providers/room_provider.dart';
import 'package:dearme/repositories/item_repository.dart';
import 'package:dearme/repositories/room_repository.dart';
import 'package:dearme/room/room_calibration.dart';

/// 部屋に置くアイテムの向きを画面基準にする対応 (#97) の回帰テスト。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const calibration = RoomCalibrations.simple;
  final screenFacingYaw = calibration.screenFacingYaw;

  late AppDatabase database;
  late LocalRoomRepository roomRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    roomRepository = LocalRoomRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<ItemModel> seedItem(String id) async {
    final item = ItemModel(
      id: id,
      title: '思い出の品',
      processedLocalImagePath: r'C:\local\processed.png',
      processStatus: ImageProcessStatus.completed,
      createdAt: DateTime.now().toUtc(),
    );
    await LocalItemRepository(database).saveItem(item);
    return item;
  }

  group('automatic placement', () {
    test('placement draft faces the screen instead of the room axis', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);

      final item = await seedItem('item_draft');
      final draft = provider.createPlacementDraft(
        item: item,
        roomId: RoomProvider.simpleRoomId,
        originalWidth: 1200,
        originalHeight: 800,
      );

      expect(draft.rotationY, closeTo(screenFacingYaw, 1e-9));
      // Yaw のみ。写真は床に対して直立を維持する。
      expect(draft.rotationX, 0);
      expect(draft.rotationZ, 0);
      // 回転込みで占有セルが計算されている。
      expect(draft.occupiedCells, isNotEmpty);
      expect(draft.gridVersion, calibration.gridVersion);
    });

    test('free placement search keeps the screen facing yaw', () async {
      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);

      // 既定セルを埋めて、リング探索の分岐を通す。
      final first = await seedItem('item_first');
      final blocking = provider.findFreePlacementDraft(
        item: first,
        roomId: RoomProvider.simpleRoomId,
        originalWidth: 1200,
        originalHeight: 800,
      );
      expect(blocking, isNotNull);
      expect(blocking!.placementSurface, PlacementSurface.rug);
      await provider.saveRoomObject(blocking);

      final second = await seedItem('item_second');
      final shifted = provider.findFreePlacementDraft(
        item: second,
        roomId: RoomProvider.simpleRoomId,
        originalWidth: 1200,
        originalHeight: 800,
      );
      final repeated = provider.findFreePlacementDraft(
        item: second,
        roomId: RoomProvider.simpleRoomId,
        originalWidth: 1200,
        originalHeight: 800,
      );

      expect(shifted, isNotNull);
      expect(repeated, isNotNull);
      expect(
          (repeated!.gridX, repeated.gridZ), (shifted!.gridX, shifted.gridZ));
      // 既定セルとは別のセルへ逃げたうえで、向きは維持される。
      expect(
        shifted.gridX != blocking.gridX || shifted.gridZ != blocking.gridZ,
        isTrue,
      );
      expect(shifted.rotationY, closeTo(screenFacingYaw, 1e-9));
    });
  });

  group('startup migration', () {
    /// 画面向き対応より前に保存された状態（旧 gridVersion・回転なし）を作る。
    Future<RoomObjectModel> seedLegacyObject({
      required String objectId,
      required String itemId,
      double rotationY = 0,
      double posX = -2.0,
      double posZ = 1.0,
    }) async {
      await seedItem(itemId);
      final now = DateTime.now().toUtc();
      final centerY = calibration.cellCenter(const GridCell(0, 2, 0)).y;
      return roomRepository.saveObject(
        RoomObjectModel(
          objectId: objectId,
          profileId: RoomProvider.localProfileId,
          roomId: RoomProvider.simpleRoomId,
          itemId: itemId,
          localAssetPath: r'C:\local\processed.png',
          objectType: 'processedImagePlane',
          gridX: 19,
          gridY: 2,
          gridZ: 19,
          gridVersion: 1,
          posX: posX,
          posY: centerY,
          posZ: posZ,
          scale: 0.72,
          scaleX: 0.72,
          scaleY: 0.72,
          scaleZ: 0.72,
          rotationY: rotationY,
          isPlaced: true,
          originalWidth: 1200,
          originalHeight: 800,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    Future<RoomObjectModel> readObject(String objectId) async {
      final objects =
          await roomRepository.watchObjects(RoomProvider.localProfileId).first;
      return objects.firstWhere((object) => object.objectId == objectId);
    }

    test('legacy objects are turned to face the screen on startup', () async {
      final legacy = await seedLegacyObject(
        objectId: 'legacy_object',
        itemId: 'item_legacy',
      );
      expect(legacy.rotationY, 0);
      expect(legacy.gridVersion, 1);

      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      await _waitUntil(() async {
        final migrated = await readObject('legacy_object');
        return migrated.gridVersion == calibration.gridVersion;
      });

      final migrated = await readObject('legacy_object');
      expect(migrated.rotationY, closeTo(screenFacingYaw, 1e-9));
      expect(migrated.rotationX, 0);
      expect(migrated.rotationZ, 0);
      expect(migrated.gridX, 1);
      expect(migrated.gridZ, 5);
      expect(migrated.gridX, isNot(8), reason: '旧gridX=19をclampしてはいけない');
      expect(migrated.gridZ, isNot(8), reason: '旧gridZ=19をclampしてはいけない');
      expect(migrated.occupiedCells, isNotEmpty);
      // 移行後も配置済みのまま部屋の中に収まっている。
      expect(migrated.isPlaced, isTrue);
      for (final cell in migrated.occupiedCells) {
        expect(calibration.containsCell(cell), isTrue);
      }
    });

    test('manually rotated objects are left untouched', () async {
      const manualYaw = 1.25;
      await seedLegacyObject(
        objectId: 'manual_object',
        itemId: 'item_manual',
        rotationY: manualYaw,
      );

      final provider = RoomProvider(roomRepository);
      addTearDown(provider.dispose);
      await _waitUntil(() => !provider.isLoading);
      // 移行が走りきるだけの猶予を与えてから確認する。
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final untouched = await readObject('manual_object');
      expect(untouched.rotationY, closeTo(manualYaw, 1e-9));
      expect(untouched.gridVersion, calibration.gridVersion);
      expect(untouched.gridX, 1);
      expect(untouched.gridZ, 5);
    });

    test('migration is idempotent across restarts', () async {
      await seedLegacyObject(
        objectId: 'restart_object',
        itemId: 'item_restart',
      );

      final first = RoomProvider(roomRepository);
      await _waitUntil(() => !first.isLoading);
      await _waitUntil(() async {
        final migrated = await readObject('restart_object');
        return migrated.gridVersion == calibration.gridVersion;
      });
      final afterFirstRun = await readObject('restart_object');
      first.dispose();

      final second = RoomProvider(roomRepository);
      addTearDown(second.dispose);
      await _waitUntil(() => !second.isLoading);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final afterSecondRun = await readObject('restart_object');
      // 二重に回っていない。バージョンも据え置き。
      expect(afterSecondRun.rotationY, closeTo(screenFacingYaw, 1e-9));
      expect(afterSecondRun.rotationY, closeTo(afterFirstRun.rotationY, 1e-9));
      expect(afterSecondRun.version, afterFirstRun.version);
    });
  });
}

Future<void> _waitUntil(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final stopwatch = Stopwatch()..start();
  while (!await condition()) {
    if (stopwatch.elapsed > timeout) {
      throw TimeoutException('Condition was not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
