import 'dart:io';
import 'dart:math' as math;

import 'package:dearme/models/room_models.dart';
import 'package:dearme/room/avatar_wander_controller.dart';
import 'package:dearme/room/furniture_placement.dart';
import 'package:dearme/room/furniture_size_spec.dart';
import 'package:dearme/room/room_calibration.dart';
import 'package:dearme/room/room_surface_elevations.dart';
import 'package:dearme/room/room_walkability.dart';
import 'package:flutter_test/flutter_test.dart';

class _SequenceRandom implements math.Random {
  final List<double> values;
  var _index = 0;

  _SequenceRandom(this.values);

  @override
  bool nextBool() => nextDouble() >= 0.5;

  @override
  double nextDouble() {
    final value = values[_index % values.length];
    _index++;
    return value;
  }

  @override
  int nextInt(int max) => (nextDouble() * max).floor().clamp(0, max - 1);
}

void main() {
  test('carpet stays flush with floor below rug-supported objects', () {
    expect(RoomSurfaceElevations.carpetRenderOffset, lessThan(0.01));
    expect(
      RoomSurfaceElevations.carpetRenderOffset,
      lessThan(RoomSurfaceElevations.rugObjectSupport),
    );
    expect(
      RoomSurfaceElevations.avatarGroundClearance,
      greaterThanOrEqualTo(RoomSurfaceElevations.rugObjectSupport),
    );
    expect(RoomSurfaceElevations.animatedFootClearanceRatio, greaterThan(0));
  });
  test('home and placement use the same calibrated camera pose', () {
    const calibration = RoomCalibrations.simple;
    final home = calibration.cameraPose();
    final placement = calibration.cameraPose(distanceScale: 1);

    expect(placement.position.x, home.position.x);
    expect(placement.position.y, home.position.y);
    expect(placement.position.z, home.position.z);
    expect(placement.target.x, home.target.x);
    expect(placement.target.y, home.target.y);
    expect(placement.target.z, home.target.z);
  });

  test('floor placement grid is 9 by 9', () {
    const calibration = RoomCalibrations.simple;
    expect(calibration.gridCountX, 9);
    expect(calibration.gridCountZ, 9);
  });

  test('home can lower its camera without changing editor or distance', () {
    const calibration = RoomCalibrations.simple;
    final editor = calibration.cameraPose();
    final home = calibration.cameraPose(elevation: 0.32);
    expect(home.position.y, lessThan(editor.position.y));
    expect(home.target.y, editor.target.y);
    final dx = home.position.x - home.target.x;
    final dy = home.position.y - home.target.y;
    final dz = home.position.z - home.target.z;
    expect(math.sqrt(dx * dx + dy * dy + dz * dz),
        closeTo(calibration.cameraDistance, 1e-9));
    expect(editor.position.y, calibration.cameraPosition.y);
  });

  test('cell center uses the middle of each invisible cell', () {
    const calibration = RoomCalibrations.simple;
    final center = calibration.cellCenter(const GridCell(3, 0, 5));

    expect(
      center.x,
      calibration.gridOriginX + 3.5 * calibration.cellSizeX,
    );
    expect(
      center.y,
      calibration.gridOriginY + 0.5 * calibration.cellSizeY,
    );
    expect(
      center.z,
      calibration.gridOriginZ + 5.5 * calibration.cellSizeZ,
    );
  });

  test('legacy scaled and rotated gifts occupy one floor cell', () {
    const calibration = RoomCalibrations.simple;
    final center = calibration.cellCenter(const GridCell(10, 3, 14));
    final now = DateTime.utc(2026, 7, 15);
    final object = RoomObjectModel(
      objectId: 'object',
      profileId: 'profile',
      roomId: calibration.roomId,
      posX: center.x,
      posY: center.y,
      posZ: center.z,
      gridX: 10,
      gridY: 3,
      gridZ: 14,
      scale: 1.6,
      scaleX: 1.6,
      scaleY: 1.6,
      scaleZ: 1.6,
      rotationY: math.pi / 4,
      originalWidth: 1200,
      originalHeight: 800,
      createdAt: now,
      updatedAt: now,
    );

    final cells = calibration.occupiedCellsFor(object);

    expect(cells.length, 1);
    expect(cells.toSet().length, cells.length);
    expect(cells, contains(const GridCell(10, 0, 14)));
    expect(object.effectiveScaleX, 1.6);
    expect(object.effectiveScaleY, 1.6);
    expect(object.effectiveScaleZ, 1.6);
  });

  test('wall placement rotates occupied width and height by quarter turns', () {
    const calibration = RoomCalibrations.simple;
    final now = DateTime.utc(2026, 8, 25);
    final object = RoomObjectModel(
      objectId: 'wall-object',
      profileId: 'profile',
      roomId: calibration.roomId,
      placementSurface: PlacementSurface.leftWall,
      gridX: 4,
      gridY: 4,
      gridZ: 0,
      scale: 0.4,
      scaleX: 0.4,
      scaleY: 0.4,
      scaleZ: 0.4,
      originalWidth: 1200,
      originalHeight: 400,
      createdAt: now,
      updatedAt: now,
    );

    final upright = calibration.occupiedCellsFor(object);
    final uprightWidth = upright.map((cell) => cell.x).toSet().length;
    final uprightHeight = upright.map((cell) => cell.y).toSet().length;

    final rotated = calibration.occupiedCellsFor(
      object.copyWith(rotationZ: math.pi / 2),
    );
    final rotatedWidth = rotated.map((cell) => cell.x).toSet().length;
    final rotatedHeight = rotated.map((cell) => cell.y).toSet().length;
    expect(rotatedWidth, uprightHeight);
    expect(rotatedHeight, uprightWidth);
  });

  test('tabletop support is exactly three centered cells', () {
    const calibration = RoomCalibrations.simple;
    final now = DateTime.utc(2026, 8, 25);
    final table = RoomObjectModel(
      objectId: 'large-table',
      profileId: 'profile',
      roomId: calibration.roomId,
      objectType: 'furniture',
      assetKey: 'table',
      gridX: 4,
      gridZ: 4,
      scale: 0.6875,
      scaleX: 0.6875,
      scaleY: 0.6875,
      scaleZ: 0.6875,
      createdAt: now,
      updatedAt: now,
    );

    for (final candidate in [table, table.copyWith(rotationY: math.pi / 2)]) {
      final cells = calibration.supportCellsForSurface(
        candidate,
        PlacementSurface.tabletop,
      );
      final width = cells.map((cell) => cell.x).toSet().length;
      final depth = cells.map((cell) => cell.z).toSet().length;
      expect(cells.length, 3);
      expect(math.min(width, depth), 1);
      expect(math.max(width, depth), 3);
    }
  });
  test('furniture size stages occupy floor cells only and never exceed 12', () {
    const calibration = RoomCalibrations.simple;
    final now = DateTime.utc(2026, 8, 22);

    for (final assetKey in ['table', 'sofa', 'metal_chair']) {
      for (final stage in FurnitureSizeSpecs.stagesFor(assetKey)) {
        final object = RoomObjectModel(
          objectId: '$assetKey-${stage.label}',
          profileId: 'profile',
          roomId: calibration.roomId,
          objectType: 'furniture',
          assetKey: assetKey,
          gridX: 4,
          gridY: 5,
          gridZ: 4,
          scale: stage.scale,
          scaleX: stage.scale,
          scaleY: stage.scale,
          scaleZ: stage.scale,
          footprintHeight: 100,
          createdAt: now,
          updatedAt: now,
        );

        final cells = calibration.occupiedCellsFor(object);
        expect(cells, hasLength(stage.spanX * stage.spanZ));
        expect(cells.length, lessThanOrEqualTo(12));
        expect(cells.every((cell) => cell.y == 0), isTrue);

        final rotated = calibration.occupiedCellsFor(
          object.copyWith(rotationY: math.pi / 2),
        );
        final xs = rotated.map((cell) => cell.x).toSet();
        final zs = rotated.map((cell) => cell.z).toSet();
        expect(xs, hasLength(stage.spanZ));
        expect(zs, hasLength(stage.spanX));
      }
    }
  });

  test('rug stages cover the complete rendered rug footprint', () {
    const rugWidth = 5.44;
    const rugDepth = 3.6266666667;
    const calibration = RoomCalibrations.simple;
    for (final stage in FurnitureSizeSpecs.stagesFor('cloud_rug')) {
      expect(
        stage.spanX * calibration.cellSizeX,
        greaterThanOrEqualTo(rugWidth * stage.scale),
      );
      expect(
        stage.spanZ * calibration.cellSizeZ,
        greaterThanOrEqualTo(rugDepth * stage.scale),
      );
      expect(
        (stage.spanX - 1) * calibration.cellSizeX,
        lessThan(rugWidth * stage.scale),
      );
      expect(
        (stage.spanZ - 1) * calibration.cellSizeZ,
        lessThan(rugDepth * stage.scale),
      );
    }
  });

  test('screen facing yaw points the plane normal at the camera', () {
    for (final calibration in [
      RoomCalibrations.simple,
      RoomCalibrations.pink,
    ]) {
      // 写真プレーンの表面法線は +Z。Y 回転 yaw を掛けると (sin yaw, 0, cos yaw)。
      final yaw = calibration.screenFacingYaw;
      final normalX = math.sin(yaw);
      final normalZ = math.cos(yaw);

      // カメラが部屋を見る向きの逆ベクトル（水平成分）を正規化して比べる。
      final position = calibration.cameraPosition;
      final target = calibration.cameraTarget;
      final towardCameraX = position.x - target.x;
      final towardCameraZ = position.z - target.z;
      final length = math.sqrt(
        towardCameraX * towardCameraX + towardCameraZ * towardCameraZ,
      );

      expect(normalX, closeTo(towardCameraX / length, 1e-9));
      expect(normalZ, closeTo(towardCameraZ / length, 1e-9));
    }
  });

  test('room-axis rotation of zero does not face the camera', () {
    // 修正前の既定値 0 は部屋のワールド +Z を向くため、画面正面からずれる。
    const calibration = RoomCalibrations.simple;
    expect(calibration.screenFacingYaw, isNot(closeTo(0, 1e-6)));
  });

  test('screen facing yaw still resolves to occupied cells', () {
    const calibration = RoomCalibrations.simple;
    final center = calibration.cellCenter(const GridCell(10, 2, 15));
    final now = DateTime.utc(2026, 8, 1);
    final upright = RoomObjectModel(
      objectId: 'object',
      profileId: 'profile',
      roomId: calibration.roomId,
      posX: center.x,
      posY: center.y,
      posZ: center.z,
      gridX: 10,
      gridY: 2,
      gridZ: 15,
      scale: 0.72,
      scaleX: 0.72,
      scaleY: 0.72,
      scaleZ: 0.72,
      originalWidth: 1200,
      originalHeight: 800,
      createdAt: now,
      updatedAt: now,
    );
    final facingScreen = upright.copyWith(
      rotationY: calibration.screenFacingYaw,
    );

    final cells = calibration.occupiedCellsFor(facingScreen);

    expect(cells, isNotEmpty);
    expect(cells.toSet().length, cells.length);
    expect(cells, contains(const GridCell(10, 0, 15)));
    // 向きが変わってもプレゼントの占有は1マスに固定する。
    final xs = cells.map((cell) => cell.x);
    final zs = cells.map((cell) => cell.z);
    final baseCells = calibration.occupiedCellsFor(upright);
    final baseZs = baseCells.map((cell) => cell.z);
    expect(
      zs.reduce(math.max) - zs.reduce(math.min),
      equals(baseZs.reduce(math.max) - baseZs.reduce(math.min)),
    );
    expect(xs.reduce(math.min), lessThanOrEqualTo(10));
  });

  test('avatar wandering stays inside bounds and outside obstacles', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );
    const obstacle = ObstacleArea(
      minX: 0.2,
      maxX: 0.7,
      minZ: 0.2,
      maxZ: 0.7,
    );
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [obstacle],
      floorY: 0,
      speed: 0.3,
      avatarHeight: 1,
      initialX: -0.8,
      initialZ: -0.8,
      initialRotationY: 0,
      random: math.Random(7),
    );

    var movingFrames = 0;
    var stoppedFrames = 0;
    for (var frame = 0; frame < 3600; frame++) {
      final pose = controller.update(1 / 60);
      expect(pose.x, inInclusiveRange(bounds.minX, bounds.maxX));
      expect(pose.z, inInclusiveRange(bounds.minZ, bounds.maxZ));
      expect(pose.x, inInclusiveRange(bounds.minX + 0.20, bounds.maxX - 0.20));
      expect(pose.z, inInclusiveRange(bounds.minZ + 0.20, bounds.maxZ - 0.20));
      expect(
        obstacle.contains(
          pose.x,
          pose.z,
          padding: AvatarWanderController.defaultCollisionPadding - 0.01,
        ),
        isFalse,
      );
      expect((pose.y).abs(), lessThanOrEqualTo(0.011));
      if (pose.isMoving) {
        movingFrames++;
      } else {
        stoppedFrames++;
      }
    }
    expect(movingFrames, greaterThan(0));
    expect(stoppedFrames, greaterThan(0));
  });

  test('avatar only changes position while the walk animation is active', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [],
      floorY: 0,
      speed: 0.4,
      avatarHeight: 1,
      initialX: 0,
      initialZ: 0,
      initialRotationY: 0,
      random: math.Random(11),
    );

    final animations = <AvatarWanderAnimation>{};
    var previous = controller.pose;
    for (var frame = 0; frame < 7200; frame++) {
      final pose = controller.update(1 / 60);
      animations.add(pose.animation);
      final positionChanged = (pose.x - previous.x).abs() > 1e-9 ||
          (pose.z - previous.z).abs() > 1e-9;
      if (positionChanged) {
        expect(pose.animation, AvatarWanderAnimation.walk);
      }
      if (pose.animation != AvatarWanderAnimation.walk) {
        expect(pose.x, previous.x);
        expect(pose.z, previous.z);
      }
      previous = pose;
    }

    expect(
      animations,
      containsAll(AvatarWanderAnimation.values),
    );
  });

  test('every turn is a fixed 90 degrees in either direction', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );

    double firstTurnDuration(List<double> randomValues) {
      final controller = AvatarWanderController(
        bounds: bounds,
        obstacles: const [],
        floorY: 0,
        speed: 0.4,
        avatarHeight: 1,
        initialX: 0,
        initialZ: 0,
        initialRotationY: 0,
        random: _SequenceRandom(randomValues),
      );
      const dt = 1 / 120;
      var enteredTurn = false;
      var duration = 0.0;
      for (var frame = 0; frame < 1200; frame++) {
        final pose = controller.update(dt);
        if (pose.animation == AvatarWanderAnimation.turnLeft ||
            pose.animation == AvatarWanderAnimation.turnRight) {
          enteredTurn = true;
          duration += dt;
        } else if (enteredTurn) {
          return duration;
        }
      }
      fail('Avatar did not finish its first turn');
    }

    // Regardless of direction, each turn uses one 90-degree clip.
    expect(firstTurnDuration([0, 0.9, 0.9]), closeTo(1.2, 0.02));
    expect(firstTurnDuration([0, 0.1, 0.9]), closeTo(1.2, 0.02));
  });

  test('avatar heading rotates by exactly 90 degrees left or right', () {
    const bounds = MovementBounds(
      minX: -2,
      maxX: 2,
      minY: 0,
      maxY: 0,
      minZ: -2,
      maxZ: 2,
    );
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [],
      floorY: 0,
      speed: 0.6,
      avatarHeight: 1,
      initialX: 0,
      initialZ: 0,
      initialRotationY: 0,
      random: math.Random(3),
    );

    double wrapAngle(double value) {
      var angle = value;
      while (angle > math.pi) {
        angle -= math.pi * 2;
      }
      while (angle < -math.pi) {
        angle += math.pi * 2;
      }
      return angle;
    }

    var rotationBeforeTurn = controller.pose.rotationY;
    var wasTurning = false;
    var turnsObserved = 0;
    for (var frame = 0; frame < 36000 && turnsObserved < 6; frame++) {
      final pose = controller.update(1 / 60);
      final isTurning = pose.animation == AvatarWanderAnimation.turnLeft ||
          pose.animation == AvatarWanderAnimation.turnRight;
      if (isTurning) {
        // The turn clip itself bakes in the 90-degree rotation, so the
        // wrapper's rotationY must hold still until the clip finishes.
        expect(pose.rotationY, rotationBeforeTurn);
      }
      if (wasTurning && !isTurning) {
        expect(
          wrapAngle(pose.rotationY - rotationBeforeTurn),
          anyOf(closeTo(math.pi / 2, 0.01), closeTo(-math.pi / 2, 0.01)),
        );
        turnsObserved++;
      }
      if (!isTurning) {
        rotationBeforeTurn = pose.rotationY;
      }
      wasTurning = isTurning;
    }
    expect(turnsObserved, greaterThanOrEqualTo(6));
  });

  test('avatar starting at a diagonal heading still finds a destination', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );
    // A stray diagonal rotation (e.g. saved by an older build) must be
    // snapped to face parallel to a wall so the avatar can still pick a
    // walkable, axis-aligned destination instead of getting stuck forever.
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [],
      floorY: 0,
      speed: 0.4,
      avatarHeight: 1,
      initialX: 0,
      initialZ: 0,
      initialRotationY: math.pi / 4,
      random: math.Random(5),
    );

    final ratio = controller.pose.rotationY / (math.pi / 2);
    expect(ratio, closeTo(ratio.roundToDouble(), 1e-9));

    var moved = false;
    for (var frame = 0; frame < 600 && !moved; frame++) {
      final pose = controller.update(1 / 60);
      if (pose.isMoving) {
        moved = true;
      }
    }
    expect(moved, isTrue);
  });

  test('rug does not create a walking collision or height boundary', () {
    final rug = RoomObjectModel(
      objectId: 'rug-1',
      profileId: 'profile-1',
      roomId: 'simple_room',
      itemId: null,
      assetKey: 'cloud_rug',
      objectType: 'furniture',
      placementSurface: PlacementSurface.floor,
      gridX: 4,
      gridY: 0,
      gridZ: 4,
      posX: 0,
      posY: 0,
      posZ: 0,
      rotationX: 0,
      rotationY: 0,
      rotationZ: 0,
      scaleX: 1,
      scaleY: 1,
      scaleZ: 1,
      isPlaced: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(RoomWalkability.blocksWalking(rug), isFalse);
  });

  test('room calibrations keep avatars readable and away from wall edges', () {
    expect(
        RoomCalibrations.simple.avatarCollisionPadding, closeTo(0.358, 0.001));
    expect(RoomCalibrations.pink.avatarCollisionPadding, closeTo(0.261, 0.001));
    expect(
      RoomCalibrations.simple.avatarCollisionPadding * 2,
      lessThan(RoomCalibrations.simple.cellSizeZ),
    );
    expect(
      RoomCalibrations.pink.avatarCollisionPadding * 2,
      lessThan(RoomCalibrations.pink.cellSizeZ),
    );
    expect(
      RoomCalibrations.simple.avatarBounds.minZ,
      RoomCalibrations.simple.avatarBounds.minX,
    );
    expect(
      RoomCalibrations.simple.avatarBounds.maxZ,
      RoomCalibrations.simple.avatarBounds.maxX,
    );
    expect(
      RoomCalibrations.simple.avatarHeightRatio,
      greaterThanOrEqualTo(1.4),
    );
    expect(
      RoomCalibrations.pink.avatarHeightRatio,
      greaterThanOrEqualTo(0.75),
    );
  });

  test('avatar starts from the safe fallback when saved pose is blocked', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );
    const obstacle = ObstacleArea(
      minX: -0.2,
      maxX: 0.2,
      minZ: -0.2,
      maxZ: 0.2,
    );
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [obstacle],
      floorY: 0,
      speed: 0.3,
      avatarHeight: 1,
      initialX: 0,
      initialZ: 0,
      initialRotationY: 0,
      fallbackX: -0.8,
      fallbackZ: 0.8,
    );

    expect(controller.pose.x, closeTo(-0.8, 1e-9));
    expect(controller.pose.z, closeTo(0.8, 1e-9));
  });

  test('avatar moves to fallback when a placed object blocks its pose', () {
    const bounds = MovementBounds(
      minX: -1,
      maxX: 1,
      minY: 0,
      maxY: 0,
      minZ: -1,
      maxZ: 1,
    );
    final controller = AvatarWanderController(
      bounds: bounds,
      obstacles: const [],
      floorY: 0,
      speed: 0.3,
      avatarHeight: 1,
      initialX: 0,
      initialZ: 0,
      initialRotationY: 0,
      fallbackX: -0.8,
      fallbackZ: 0.8,
    );

    controller.updateObstacles(const [
      ObstacleArea(
        minX: -0.2,
        maxX: 0.2,
        minZ: -0.2,
        maxZ: 0.2,
      ),
    ]);

    expect(controller.pose.x, closeTo(-0.8, 1e-9));
    expect(controller.pose.z, closeTo(0.8, 1e-9));
    expect(controller.pose.isMoving, isFalse);
  });

  test('simple room carpet asset keeps its original RGBA dimensions', () {
    final file = File(
      'assets/textures/room/original_cloud_spirits_carpet-v2.png',
    );
    expect(file.existsSync(), isTrue);

    final bytes = file.readAsBytesSync();
    expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

    int readUint32(int offset) =>
        bytes[offset] << 24 |
        bytes[offset + 1] << 16 |
        bytes[offset + 2] << 8 |
        bytes[offset + 3];

    expect(readUint32(16), 1536);
    expect(readUint32(20), 1024);
    expect(bytes[25], 6, reason: 'PNG must remain RGBA for transparency');
  });

  test('generated furniture textures are bundled as square RGB PNGs', () {
    for (final assetPath in [
      'assets/textures/furniture/light_oak.png',
      'assets/textures/furniture/blush_woven_fabric.png',
      'assets/textures/furniture/butter_yellow_woven_fabric.png',
      'assets/textures/furniture/brushed_steel.png',
    ]) {
      final bytes = File(assetPath).readAsBytesSync();
      expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(bytes[25], 2, reason: '$assetPath must remain RGB');
    }
  });

  test('fixed furniture stays inside simpleRoom and does not overlap', () {
    const placements = FurniturePlacements.simpleRoom;
    final halfRoomExtent = RoomCalibrations.simple.roomTargetExtent / 2;

    expect(
      placements.map((placement) => placement.id),
      [
        'table',
        'sofa',
        'metal_chair',
        'cloud_rug',
        'wall_clock',
        'window_back_left',
        'window_back_right',
        'window_left_back',
        'window_left_front'
      ],
    );
    final regularFurniture = placements
        .where((placement) =>
            placement.placementKind == FurniturePlacementKind.floor &&
            placement.id != 'cloud_rug')
        .toList();
    final rug =
        placements.singleWhere((placement) => placement.id == 'cloud_rug');
    final clock =
        placements.singleWhere((placement) => placement.id == 'wall_clock');
    expect(clock.placementKind, FurniturePlacementKind.wall);

    for (final placement in regularFurniture) {
      final assetPath = placement.assetPath;
      if (assetPath != null) {
        expect(File(assetPath).existsSync(), isTrue);
      }
      expect(placement.minX, greaterThanOrEqualTo(-halfRoomExtent));
      expect(placement.maxX, lessThanOrEqualTo(halfRoomExtent));
      expect(placement.minZ, greaterThanOrEqualTo(-halfRoomExtent));
      expect(placement.maxZ, lessThanOrEqualTo(halfRoomExtent));
      expect(
        RoomCalibrations.simple.obstacleAreas.any(
          (obstacle) => obstacle.contains(placement.x, placement.z),
        ),
        isTrue,
      );
    }
    for (var first = 0; first < regularFurniture.length; first++) {
      for (var second = first + 1; second < regularFurniture.length; second++) {
        expect(regularFurniture[first].overlaps(regularFurniture[second]),
            isFalse);
      }
    }

    expect(rug.minX, greaterThanOrEqualTo(-halfRoomExtent));
    expect(rug.maxX, lessThanOrEqualTo(halfRoomExtent));
    expect(rug.minZ, greaterThanOrEqualTo(-halfRoomExtent));
    expect(rug.maxZ, lessThanOrEqualTo(halfRoomExtent));
    expect(regularFurniture.any(rug.overlaps), isTrue);

    final sofa = placements.firstWhere((placement) => placement.id == 'sofa');
    expect(sofa.x, closeTo(1.12, 1e-9));
    expect(sofa.z, lessThan(-2));
    expect(sofa.scale, closeTo(0.728, 1e-9));
    expect(sofa.rotationY, closeTo(0, 1e-9));

    final chair =
        placements.firstWhere((placement) => placement.id == 'metal_chair');
    expect(chair.scale, closeTo(0.952, 1e-9));
    expect(chair.rotationY, closeTo(0.8245329251994329, 1e-9));
  });
}
