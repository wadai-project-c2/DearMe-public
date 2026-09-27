import 'package:dearme/models/room_models.dart';
import 'package:dearme/room/room_calibration.dart';
import 'package:dearme/room/room_walkability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calibration = RoomSceneCalibration(
    roomId: 'walkability_test',
    roomTargetExtent: 5,
    cameraAzimuth: 0,
    cameraElevation: 0,
    cameraDistance: 10,
    orthographicSize: 5,
    targetX: 0,
    targetY: 0,
    targetZ: 0,
    near: 0.1,
    far: 100,
    floorY: 0,
    avatarHeightRatio: 1,
    avatarWalkSpeed: 1,
    avatarBounds: MovementBounds(
      minX: 0.5,
      maxX: 4.5,
      minY: 0,
      maxY: 0,
      minZ: 0.5,
      maxZ: 4.5,
    ),
    avatarSpawn: SceneVector3(0.5, 0, 2.5),
    obstacleAreas: [],
    gridOriginX: 0,
    gridOriginY: 0,
    gridOriginZ: 0,
    cellSizeX: 1,
    cellSizeY: 1,
    cellSizeZ: 1,
    gridCountX: 5,
    gridCountY: 2,
    gridCountZ: 5,
    gridVersion: 1,
    defaultPlacementCell: GridCell(2, 0, 2),
  );

  RoomObjectModel floorObject({
    required String id,
    required double x,
    required double z,
    double width = 0.8,
    double depth = 0.8,
  }) {
    final now = DateTime.utc(2026);
    return RoomObjectModel(
      objectId: id,
      profileId: 'profile',
      roomId: calibration.roomId,
      posX: x,
      posY: 0.5,
      posZ: z,
      gridX: x.floor(),
      gridZ: z.floor(),
      footprintWidth: width,
      footprintHeight: 0.8,
      footprintDepth: depth,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('empty room accepts a placement away from the avatar spawn', () {
    final candidate = floorObject(id: 'center', x: 2.5, z: 2.5);

    expect(
      RoomWalkability.preservesReachableFloor(
        calibration: calibration,
        existingObjects: const [],
        candidate: candidate,
      ),
      isTrue,
    );
  });

  test('room edge remains a deterministic valid candidate', () {
    final candidate = floorObject(id: 'edge', x: 4.5, z: 4.5);

    for (var attempt = 0; attempt < 3; attempt++) {
      expect(
        RoomWalkability.preservesReachableFloor(
          calibration: calibration,
          existingObjects: const [],
          candidate: candidate,
        ),
        isTrue,
      );
    }
  });

  test('avatar spawn may be occupied when the remaining floor stays joined',
      () {
    final candidate = floorObject(id: 'spawn', x: 0.5, z: 2.5);

    expect(
      RoomWalkability.preservesReachableFloor(
        calibration: calibration,
        existingObjects: const [],
        candidate: candidate,
      ),
      isTrue,
    );
  });

  test('multiple existing items can keep a one-cell passage', () {
    final existing = [
      floorObject(id: 'top', x: 2.5, z: 0.5),
      floorObject(id: 'bottom', x: 2.5, z: 4.5),
    ];
    final candidate = floorObject(id: 'side', x: 4.5, z: 2.5);

    expect(
      RoomWalkability.preservesReachableFloor(
        calibration: calibration,
        existingObjects: existing,
        candidate: candidate,
      ),
      isTrue,
    );
  });

  test('near-full placement cannot split the reachable floor', () {
    final existing = [
      for (final z in [0.5, 1.5, 3.5, 4.5])
        floorObject(id: 'barrier-$z', x: 2.5, z: z),
    ];
    final candidate = floorObject(
      id: 'barrier',
      x: 2.5,
      z: 2.5,
      width: 0.8,
      depth: 0.8,
    );

    expect(
      RoomWalkability.preservesReachableFloor(
        calibration: calibration,
        existingObjects: existing,
        candidate: candidate,
      ),
      isFalse,
    );
  });

  test('tabletop, wall, and floor covering do not block walking', () {
    final now = DateTime.utc(2026);
    for (final candidate in [
      floorObject(id: 'tabletop', x: 2.5, z: 2.5)
          .copyWith(placementSurface: PlacementSurface.tabletop),
      floorObject(id: 'wall', x: 2.5, z: 2.5)
          .copyWith(placementSurface: PlacementSurface.leftWall),
      RoomObjectModel(
        objectId: 'rug',
        profileId: 'profile',
        roomId: calibration.roomId,
        objectType: 'furniture',
        assetKey: 'cloud_rug',
        createdAt: now,
        updatedAt: now,
      ),
    ]) {
      expect(
        RoomWalkability.preservesReachableFloor(
          calibration: calibration,
          existingObjects: const [],
          candidate: candidate,
        ),
        isTrue,
      );
    }
  });
}
