import 'dart:math' as math;

import '../models/room_models.dart';
import 'furniture_placement.dart';
import 'furniture_size_spec.dart';
import 'presented_item_dimensions.dart';

class SceneVector3 {
  final double x;
  final double y;
  final double z;

  const SceneVector3(this.x, this.y, this.z);
}

class PlacementSlot {
  final String id;
  final String label;
  final SceneVector3 position;
  final List<double> availableRotations; // in radians

  const PlacementSlot({
    required this.id,
    required this.label,
    required this.position,
    this.availableRotations = const [0, math.pi / 2, math.pi, -math.pi / 2],
  });
}

class MovementBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double minZ;
  final double maxZ;

  const MovementBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.minZ,
    required this.maxZ,
  });
}

class ObstacleArea {
  final double minX;
  final double maxX;
  final double minZ;
  final double maxZ;

  const ObstacleArea({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
  });

  bool contains(double x, double z, {double padding = 0}) {
    return x >= minX - padding &&
        x <= maxX + padding &&
        z >= minZ - padding &&
        z <= maxZ + padding;
  }

  bool intersectsSegment(
    double startX,
    double startZ,
    double endX,
    double endZ, {
    double padding = 0,
  }) {
    for (var index = 0; index <= 16; index++) {
      final t = index / 16;
      if (contains(
        startX + (endX - startX) * t,
        startZ + (endZ - startZ) * t,
        padding: padding,
      )) {
        return true;
      }
    }
    return false;
  }
}

class RoomSceneCalibration {
  final String roomId;
  final double roomTargetExtent;
  final double cameraAzimuth;
  final double cameraElevation;
  final double cameraDistance;
  final double orthographicSize;
  final double targetX;
  final double targetY;
  final double targetZ;
  final double near;
  final double far;
  final double floorY;
  final double avatarHeightRatio;
  final double avatarWalkSpeed;
  final MovementBounds avatarBounds;
  final SceneVector3 avatarSpawn;
  final List<ObstacleArea> obstacleAreas;

  /// Leaves a small amount of clearance inside a one-cell-wide passage while
  /// accounting for the avatar's feet and walking animation.
  double get avatarCollisionPadding => math.min(cellSizeX, cellSizeZ) * 0.46;
  final double gridOriginX;
  final double gridOriginY;
  final double gridOriginZ;
  final double cellSizeX;
  final double cellSizeY;
  final double cellSizeZ;
  final int gridCountX;
  final int gridCountY;
  final int gridCountZ;
  final int gridVersion;
  final Set<GridCell> blockedCells;
  final GridCell defaultPlacementCell;

  const RoomSceneCalibration({
    required this.roomId,
    required this.roomTargetExtent,
    required this.cameraAzimuth,
    required this.cameraElevation,
    required this.cameraDistance,
    required this.orthographicSize,
    required this.targetX,
    required this.targetY,
    required this.targetZ,
    required this.near,
    required this.far,
    required this.floorY,
    required this.avatarHeightRatio,
    required this.avatarWalkSpeed,
    required this.avatarBounds,
    required this.avatarSpawn,
    required this.obstacleAreas,
    required this.gridOriginX,
    required this.gridOriginY,
    required this.gridOriginZ,
    required this.cellSizeX,
    required this.cellSizeY,
    required this.cellSizeZ,
    required this.gridCountX,
    required this.gridCountY,
    required this.gridCountZ,
    required this.gridVersion,
    this.blockedCells = const {},
    required this.defaultPlacementCell,
    this.placementSlots = const [],
  });

  final List<PlacementSlot> placementSlots;

  SceneVector3 get cameraTarget => SceneVector3(targetX, targetY, targetZ);

  SceneVector3 get cameraPosition {
    final horizontalDistance = cameraDistance * math.cos(cameraElevation);
    return SceneVector3(
      targetX + horizontalDistance * math.sin(cameraAzimuth),
      targetY + cameraDistance * math.sin(cameraElevation),
      targetZ + horizontalDistance * math.cos(cameraAzimuth),
    );
  }

  /// Returns the shared camera pose used by home and placement screens.
  ///
  /// Viewport aspect belongs to the projection matrix; it must not change the
  /// world-space target or fit a different subset such as the placement grid.
  ({SceneVector3 position, SceneVector3 target}) cameraPose({
    double distanceScale = 1,
    double targetYOffset = 0,
    double? elevation,
  }) {
    final scale = distanceScale.clamp(0.32, 1.5);
    final angle = elevation ?? cameraElevation;
    final horizontalDistance = cameraDistance * math.cos(angle);
    final base = SceneVector3(
      targetX + horizontalDistance * math.sin(cameraAzimuth),
      targetY + cameraDistance * math.sin(angle),
      targetZ + horizontalDistance * math.cos(cameraAzimuth),
    );
    return (
      position: SceneVector3(
        targetX + (base.x - targetX) * scale,
        targetY + (base.y - targetY) * scale,
        targetZ + (base.z - targetZ) * scale,
      ),
      target: SceneVector3(targetX, targetY + targetYOffset, targetZ),
    );
  }

  /// 画面（カメラ）の方を向く Y 軸回転角。
  ///
  /// 写真プレーン([SilhouettePuffGeometry])の表面法線は +Z なので、回転 0 のままだと
  /// 部屋のワールド軸を向いてしまい、画面からは [cameraAzimuth] の分だけ斜めに見える。
  /// カメラの方位角をそのまま Y 回転に使うと法線がカメラ方向へ向く。
  double get screenFacingYaw => cameraAzimuth;

  SceneVector3 cellCenter(GridCell cell) {
    return SceneVector3(
      gridOriginX + (cell.x + 0.5) * cellSizeX,
      gridOriginY + (cell.y + 0.5) * cellSizeY,
      gridOriginZ + (cell.z + 0.5) * cellSizeZ,
    );
  }

  bool containsCell(GridCell cell) {
    return cell.x >= 0 &&
        cell.x < gridCountX &&
        cell.y >= 0 &&
        cell.y < gridCountY &&
        cell.z >= 0 &&
        cell.z < gridCountZ;
  }

  bool isBlockedCell(GridCell cell) {
    if (!containsCell(cell) || blockedCells.contains(cell)) {
      return true;
    }
    final center = cellCenter(cell);
    return obstacleAreas.any(
      (area) => area.contains(
        center.x,
        center.z,
        padding: math.min(cellSizeX, cellSizeZ) * 0.35,
      ),
    );
  }

  List<GridCell> occupiedCellsFor(RoomObjectModel object) {
    if (!object.isFurniture) {
      return [
        switch (object.placementSurface) {
          PlacementSurface.leftWall => GridCell(object.gridX, object.gridY, 0),
          PlacementSurface.rightWall => GridCell(0, object.gridY, object.gridZ),
          _ => GridCell(object.gridX, 0, object.gridZ),
        }
      ];
    }
    if (object.isFurniture &&
        !FurniturePlacements.isWallMounted(object.assetKey)) {
      final span = FurnitureSizeSpecs.rotatedSpan(
        object.assetKey,
        object.effectiveScaleX,
        object.rotationY,
      );
      final startX = object.gridX - (span.spanX - 1) ~/ 2;
      final startZ = object.gridZ - (span.spanZ - 1) ~/ 2;
      return [
        for (var x = startX; x < startX + span.spanX; x++)
          for (var z = startZ; z < startZ + span.spanZ; z++) GridCell(x, 0, z),
      ];
    }
    if (object.placementSurface.isVertical) {
      final dimensions = presentedItemDimensions(
        object.aspectRatio,
        cellSizeX: cellSizeX,
        cellSizeY: cellSizeY,
        cellSizeZ: cellSizeZ,
      );
      final wallFurnitureStage = object.isFurniture
          ? FurnitureSizeSpecs.nearest(
              object.assetKey,
              object.effectiveScaleX,
            )
          : null;
      var width = dimensions.width * object.effectiveScaleX;
      var height = dimensions.height * object.effectiveScaleY;
      final horizontalCellSize =
          object.placementSurface == PlacementSurface.leftWall
              ? cellSizeX
              : cellSizeZ;
      if (wallFurnitureStage != null) {
        width = wallFurnitureStage.spanX * horizontalCellSize;
        height = wallFurnitureStage.spanZ * cellSizeY;
      }
      final c = math.cos(object.rotationZ).abs();
      final s = math.sin(object.rotationZ).abs();
      final horizontalSpan = math.max(
          1, ((width * c + height * s) / horizontalCellSize - 1e-9).ceil());
      final verticalSpan =
          math.max(1, ((width * s + height * c) / cellSizeY - 1e-9).ceil());
      final horizontalAnchor =
          object.placementSurface == PlacementSurface.leftWall
              ? object.gridX
              : object.gridZ;
      final startHorizontal = horizontalAnchor - (horizontalSpan - 1) ~/ 2;
      final startY = object.gridY - (verticalSpan - 1) ~/ 2;
      return [
        for (var horizontal = startHorizontal;
            horizontal < startHorizontal + horizontalSpan;
            horizontal++)
          for (var y = startY; y < startY + verticalSpan; y++)
            object.placementSurface == PlacementSurface.leftWall
                ? GridCell(horizontal, y, 0)
                : GridCell(0, y, horizontal),
      ];
    }
    final dimensions = presentedItemDimensions(
      object.aspectRatio,
      cellSizeX: cellSizeX,
      cellSizeY: cellSizeY,
      cellSizeZ: cellSizeZ,
    );
    final halfX = object.footprintWidth != null
        ? object.footprintWidth! / 2
        : dimensions.width * object.effectiveScaleX / 2;
    final halfY = object.footprintHeight != null
        ? object.footprintHeight! / 2
        : dimensions.height * object.effectiveScaleY / 2;
    final halfZ = object.footprintDepth != null
        ? object.footprintDepth! / 2
        : 0.04 * object.effectiveScaleZ;

    final a = math.cos(object.rotationX);
    final b = math.sin(object.rotationX);
    final c = math.cos(object.rotationY);
    final d = math.sin(object.rotationY);
    final e = math.cos(object.rotationZ);
    final f = math.sin(object.rotationZ);

    final m00 = c * e;
    final m01 = -c * f;
    final m02 = d;
    final m10 = a * f + b * e * d;
    final m11 = a * e - b * f * d;
    final m12 = -b * c;
    final m20 = b * f - a * e * d;
    final m21 = b * e + a * f * d;
    final m22 = a * c;

    final extentX = m00.abs() * halfX + m01.abs() * halfY + m02.abs() * halfZ;
    final extentY = m10.abs() * halfX + m11.abs() * halfY + m12.abs() * halfZ;
    final extentZ = m20.abs() * halfX + m21.abs() * halfY + m22.abs() * halfZ;

    final minX = ((object.posX - extentX - gridOriginX) / cellSizeX).floor();
    final maxX =
        ((object.posX + extentX - gridOriginX - 1e-7) / cellSizeX).floor();
    final minY = ((object.posY - extentY - gridOriginY) / cellSizeY).floor();
    final maxY =
        ((object.posY + extentY - gridOriginY - 1e-7) / cellSizeY).floor();
    final minZ = ((object.posZ - extentZ - gridOriginZ) / cellSizeZ).floor();
    final maxZ =
        ((object.posZ + extentZ - gridOriginZ - 1e-7) / cellSizeZ).floor();

    return [
      for (var x = minX; x <= maxX; x++)
        for (var y = minY; y <= maxY; y++)
          for (var z = minZ; z <= maxZ; z++) GridCell(x, y, z),
    ];
  }

  List<GridCell> supportCellsForSurface(
    RoomObjectModel support,
    PlacementSurface surface,
  ) {
    final cells = occupiedCellsFor(support);
    if (surface != PlacementSurface.tabletop || support.assetKey != 'table') {
      return cells;
    }
    final angle = support.rotationY;
    if (math.sin(angle * 2).abs() > 1e-6) {
      // The diagonal bounding box includes empty corners. Test cell centers
      // in the table's local frame, not an axis-aligned strip through that box.
      final stage =
          FurnitureSizeSpecs.nearest(support.assetKey, support.effectiveScaleX);
      if (stage == null) return const [];
      final halfX = math.min(stage.spanX, 3) * cellSizeX / 2;
      final halfZ = math.min(stage.spanZ, 1) * cellSizeZ / 2;
      final c = math.cos(angle);
      final s = math.sin(angle);
      return cells.where((cell) {
        final center = cellCenter(cell);
        final dx = center.x - support.posX;
        final dz = center.z - support.posZ;
        final localX = c * dx - s * dz;
        final localZ = s * dx + c * dz;
        return localX.abs() <= halfX + 1e-7 && localZ.abs() <= halfZ + 1e-7;
      }).toList(growable: false);
    }
    final xs = cells.map((cell) => cell.x).toSet().toList()..sort();
    final zs = cells.map((cell) => cell.z).toSet().toList()..sort();
    final alongX = xs.length >= zs.length;
    final targetX = math.min(xs.length, alongX ? 3 : 1);
    final targetZ = math.min(zs.length, alongX ? 1 : 3);
    final keptX = xs
        .sublist(
            (xs.length - targetX) ~/ 2, (xs.length - targetX) ~/ 2 + targetX)
        .toSet();
    final keptZ = zs
        .sublist(
            (zs.length - targetZ) ~/ 2, (zs.length - targetZ) ~/ 2 + targetZ)
        .toSet();
    return cells
        .where((cell) => keptX.contains(cell.x) && keptZ.contains(cell.z))
        .toList(growable: false);
  }
}

abstract final class RoomCalibrations {
  static const simple = RoomSceneCalibration(
    roomId: 'simple_room',
    roomTargetExtent: 7.0,
    cameraAzimuth: 0.785, // 45 degrees
    cameraElevation: 0.45, // Shallower angle for wall thickness
    cameraDistance: 40.0,
    orthographicSize: 4.8,
    targetX: 0,
    targetY: 3.0,
    targetZ: 0,
    near: 0.1,
    far: 100,
    floorY: 0,
    avatarHeightRatio: 1.44,
    avatarWalkSpeed: 0.45,
    avatarBounds: MovementBounds(
      minX: -2.35,
      maxX: 2.35,
      minY: 0,
      maxY: 0,
      minZ: -2.35,
      maxZ: 2.35,
    ),
    avatarSpawn: SceneVector3(-0.6, 0, 0.5),
    obstacleAreas: [
      ObstacleArea(minX: -3.25, maxX: -2.20, minZ: -0.85, maxZ: 2.15),
      ObstacleArea(minX: -0.15, maxX: 2.40, minZ: -3.50, maxZ: -1.75),
      ObstacleArea(minX: 1.95, maxX: 3.45, minZ: -0.65, maxZ: 0.85),
    ],
    gridOriginX: -3.5,
    gridOriginY: 0,
    gridOriginZ: -3.5,
    cellSizeX: 0.7777777778,
    cellSizeY: 0.7777777778,
    cellSizeZ: 0.7777777778,
    gridCountX: 9,
    gridCountY: 8,
    gridCountZ: 9,
    // v7: 見た目のサイズは維持して、プレゼントの占有判定を1セルへ更新。
    gridVersion: 7,
    defaultPlacementCell: GridCell(4, 2, 7),
    placementSlots: [
      PlacementSlot(
        id: 'table_center',
        label: '机の上',
        position: SceneVector3(-2.85, 0.85, 0.65),
      ),
      PlacementSlot(
        id: 'floor_left',
        label: '床 (左手前)',
        position: SceneVector3(-1.8, 0.0, -1.5),
      ),
      PlacementSlot(
        id: 'floor_right',
        label: '床 (右奥)',
        position: SceneVector3(1.5, 0.0, 1.0),
      ),
    ],
  );

  static const pink = RoomSceneCalibration(
    roomId: 'pink_room',
    roomTargetExtent: 7.0,
    cameraAzimuth: 0.785, // 45 degrees
    cameraElevation: 0.45, // Shallower angle
    cameraDistance: 40.0, // Increased from 30.0 to fit room in frame
    orthographicSize: 4.6,
    targetX: 0,
    targetY: 0.5, // Slightly lowered from 0.8
    targetZ: 0.05,
    near: 0.1,
    far: 100,
    floorY: 0.35,
    avatarHeightRatio: 0.768,
    avatarWalkSpeed: 0.42,
    avatarBounds: MovementBounds(
      minX: -2.25,
      maxX: 2.25,
      minY: 0,
      maxY: 0,
      minZ: -1.85,
      maxZ: 1.85,
    ),
    avatarSpawn: SceneVector3(-0.65, 0, 1.15),
    obstacleAreas: [
      ObstacleArea(minX: -2.25, maxX: -1.10, minZ: 1.55, maxZ: 1.85),
      ObstacleArea(minX: -0.75, maxX: 0.95, minZ: -2.3, maxZ: -1.2),
      ObstacleArea(minX: 0.65, maxX: 2.25, minZ: -1.85, maxZ: -0.45),
      ObstacleArea(minX: -0.20, maxX: 1.85, minZ: -0.35, maxZ: 1.70),
    ],
    gridOriginX: -2.9,
    gridOriginY: 0.30,
    gridOriginZ: -2.55,
    cellSizeX: 0.6444444444,
    cellSizeY: 0.6055555556,
    cellSizeZ: 0.5666666667,
    gridCountX: 9,
    gridCountY: 8,
    gridCountZ: 9,
    // v2: 既存オブジェクトを画面向き([screenFacingYaw])へ一度だけ移行するためのマーカー (#97)
    gridVersion: 3,
    defaultPlacementCell: GridCell(5, 2, 7),
  );

  static RoomSceneCalibration forRoom(String roomId) {
    return roomId == pink.roomId ? pink : simple;
  }
}
