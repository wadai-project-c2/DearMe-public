import '../models/room_models.dart';
import 'room_calibration.dart';

/// UIや3D描画に依存しない、アバターの床動線判定。
abstract final class RoomWalkability {
  /// 現在のROOMではアバター1体が通れる1セルを最低通路幅とする。
  static const int minimumPassageCells = 1;

  static bool preservesReachableFloor({
    required RoomSceneCalibration calibration,
    required Iterable<RoomObjectModel> existingObjects,
    required RoomObjectModel candidate,
  }) {
    if (!blocksWalking(candidate)) return true;

    final baselineBlocked = blockingCells(
      calibration,
      existingObjects.where((object) => object.objectId != candidate.objectId),
    );
    final start = _nearestFreeCell(
      calibration,
      baselineBlocked,
      calibration.avatarSpawn,
    );
    if (start == null) return false;
    final baselineReachable = _reachable(calibration, start, baselineBlocked);
    final candidateBlocked = {
      ...baselineBlocked,
      ...calibration.occupiedCellsFor(candidate).map(_floorCell),
    };
    final remaining = baselineReachable.difference(candidateBlocked);
    if (remaining.isEmpty) return false;
    final startAfter = _nearestFreeCell(
      calibration,
      candidateBlocked,
      calibration.avatarSpawn,
    );
    if (startAfter == null) return false;
    final reachableAfter =
        _reachable(calibration, startAfter, candidateBlocked);
    return reachableAfter.containsAll(remaining);
  }

  static Set<GridCell> blockingCells(
    RoomSceneCalibration calibration,
    Iterable<RoomObjectModel> objects,
  ) =>
      {
        for (final object in objects)
          if (blocksWalking(object))
            for (final cell in calibration.occupiedCellsFor(object))
              _floorCell(cell),
      };

  static List<ObstacleArea> obstacleAreasForObjects(
    RoomSceneCalibration calibration,
    Iterable<RoomObjectModel> objects,
  ) =>
      [
        for (final cell in blockingCells(calibration, objects))
          ObstacleArea(
            minX: calibration.gridOriginX + cell.x * calibration.cellSizeX,
            maxX:
                calibration.gridOriginX + (cell.x + 1) * calibration.cellSizeX,
            minZ: calibration.gridOriginZ + cell.z * calibration.cellSizeZ,
            maxZ:
                calibration.gridOriginZ + (cell.z + 1) * calibration.cellSizeZ,
          ),
      ];

  static bool blocksWalking(RoomObjectModel object) =>
      object.isPlaced &&
      object.deletedAt == null &&
      !object.isFloorCovering &&
      (object.placementSurface == PlacementSurface.floor ||
          object.placementSurface == PlacementSurface.rug);

  static GridCell _floorCell(GridCell cell) => GridCell(cell.x, 0, cell.z);

  static bool _insideAvatarBounds(
    RoomSceneCalibration calibration,
    GridCell cell,
  ) {
    if (!calibration.containsCell(cell)) return false;
    final center = calibration.cellCenter(cell);
    return center.x >= calibration.avatarBounds.minX &&
        center.x <= calibration.avatarBounds.maxX &&
        center.z >= calibration.avatarBounds.minZ &&
        center.z <= calibration.avatarBounds.maxZ;
  }

  static GridCell? _nearestFreeCell(
    RoomSceneCalibration calibration,
    Set<GridCell> blocked,
    SceneVector3 point,
  ) {
    final cells = <GridCell>[
      for (var x = 0; x < calibration.gridCountX; x++)
        for (var z = 0; z < calibration.gridCountZ; z++) GridCell(x, 0, z),
    ]
      ..removeWhere(
        (cell) =>
            !_insideAvatarBounds(calibration, cell) || blocked.contains(cell),
      )
      ..sort((a, b) {
        final ac = calibration.cellCenter(a);
        final bc = calibration.cellCenter(b);
        final ad = (ac.x - point.x) * (ac.x - point.x) +
            (ac.z - point.z) * (ac.z - point.z);
        final bd = (bc.x - point.x) * (bc.x - point.x) +
            (bc.z - point.z) * (bc.z - point.z);
        return ad.compareTo(bd);
      });
    return cells.firstOrNull;
  }

  static Set<GridCell> _reachable(
    RoomSceneCalibration calibration,
    GridCell start,
    Set<GridCell> blocked,
  ) {
    final reached = <GridCell>{start};
    final queue = <GridCell>[start];
    for (var index = 0; index < queue.length; index++) {
      final cell = queue[index];
      for (final next in [
        GridCell(cell.x - 1, 0, cell.z),
        GridCell(cell.x + 1, 0, cell.z),
        GridCell(cell.x, 0, cell.z - 1),
        GridCell(cell.x, 0, cell.z + 1),
      ]) {
        if (_insideAvatarBounds(calibration, next) &&
            !blocked.contains(next) &&
            reached.add(next)) {
          queue.add(next);
        }
      }
    }
    return reached;
  }
}
