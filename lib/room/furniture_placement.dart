enum FurniturePlacementKind { floor, wall }

class FurniturePlacement {
  final String id;
  final String thumbnailAssetPath;
  final String? assetPath;
  final int assetVersion;
  final double x;
  final double y;
  final double z;
  final double scale;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double footprintWidth;
  final double footprintDepth;
  final List<String> helperNodeNames;
  final FurniturePlacementKind placementKind;

  const FurniturePlacement({
    required this.id,
    required this.thumbnailAssetPath,
    this.assetPath,
    this.assetVersion = 1,
    required this.x,
    this.y = 0,
    required this.z,
    required this.scale,
    this.rotationX = 0,
    this.rotationY = 0,
    this.rotationZ = 0,
    required this.footprintWidth,
    required this.footprintDepth,
    this.helperNodeNames = const [],
    this.placementKind = FurniturePlacementKind.floor,
  });

  double get minX => x - footprintWidth / 2;
  double get maxX => x + footprintWidth / 2;
  double get minZ => z - footprintDepth / 2;
  double get maxZ => z + footprintDepth / 2;

  bool overlaps(FurniturePlacement other) {
    return minX < other.maxX &&
        maxX > other.minX &&
        minZ < other.maxZ &&
        maxZ > other.minZ;
  }
}

abstract final class FurniturePlacements {
  static const simpleRoom = <FurniturePlacement>[
    FurniturePlacement(
      id: 'table',
      thumbnailAssetPath: 'assets/icon/furniture/table.png',
      assetPath: 'assets/models/furniture/table.glb',
      x: -2.85,
      z: 0.65,
      scale: 0.55,
      rotationY: 1.5707963267948966,
      footprintWidth: 0.82,
      footprintDepth: 2.37,
      helperNodeNames: ['Plane'],
    ),
    FurniturePlacement(
      id: 'sofa',
      thumbnailAssetPath: 'assets/icon/furniture/sofa.png',
      assetPath: 'assets/models/furniture/chair.glb',
      x: 1.12,
      z: -2.65,
      scale: 0.728,
      footprintWidth: 2.296,
      footprintDepth: 1.554,
      helperNodeNames: ['Plane'],
    ),
    FurniturePlacement(
      id: 'metal_chair',
      thumbnailAssetPath: 'assets/icon/furniture/metal_chair.png',
      x: 2.70,
      z: 0.10,
      scale: 0.952,
      rotationY: 0.8245329251994329,
      footprintWidth: 1.40,
      footprintDepth: 1.40,
    ),
    FurniturePlacement(
      id: 'cloud_rug',
      thumbnailAssetPath: 'assets/icon/furniture/cloud_rug.png',
      x: 0,
      z: 0.30,
      scale: 1,
      footprintWidth: 5.44,
      footprintDepth: 3.6266666667,
    ),
    FurniturePlacement(
      id: 'wall_clock',
      thumbnailAssetPath: 'assets/icon/furniture/wall_clock.png',
      x: 0,
      y: 2.4,
      z: 0,
      scale: 1,
      footprintWidth: 1.4,
      footprintDepth: 0.16,
      placementKind: FurniturePlacementKind.wall,
    ),
    FurniturePlacement(
      id: 'window_back_left',
      thumbnailAssetPath: '',
      x: 0,
      y: 2.65,
      z: 0,
      scale: 1,
      footprintWidth: 1.72,
      footprintDepth: 0.11,
      placementKind: FurniturePlacementKind.wall,
    ),
    FurniturePlacement(
      id: 'window_back_right',
      thumbnailAssetPath: '',
      x: 0,
      y: 2.65,
      z: 0,
      scale: 1,
      footprintWidth: 1.72,
      footprintDepth: 0.11,
      placementKind: FurniturePlacementKind.wall,
    ),
    FurniturePlacement(
      id: 'window_left_back',
      thumbnailAssetPath: '',
      x: 0,
      y: 2.65,
      z: 0,
      scale: 1,
      footprintWidth: 1.72,
      footprintDepth: 0.11,
      placementKind: FurniturePlacementKind.wall,
    ),
    FurniturePlacement(
      id: 'window_left_front',
      thumbnailAssetPath: '',
      x: 0,
      y: 2.65,
      z: 0,
      scale: 1,
      footprintWidth: 1.72,
      footprintDepth: 0.11,
      placementKind: FurniturePlacementKind.wall,
    ),
  ];

  static bool isWindow(String? assetKey) =>
      assetKey?.startsWith('window_') == true;

  static List<FurniturePlacement> forRoom(String roomId) {
    return roomId == 'simple_room' ? simpleRoom : const [];
  }

  static FurniturePlacementKind kindFor(String? assetKey) {
    for (final placement in simpleRoom) {
      if (placement.id == assetKey) return placement.placementKind;
    }
    return FurniturePlacementKind.floor;
  }

  static bool isWallMounted(String? assetKey) =>
      kindFor(assetKey) == FurniturePlacementKind.wall;
}
