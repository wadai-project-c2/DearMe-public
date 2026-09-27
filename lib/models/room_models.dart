class RoomModel {
  final String id;
  final String name;
  final String assetPath;
  final String? previewImagePath;
  final bool isEnabled;
  final int displayOrder;
  final int assetVersion;
  final String? defaultAvatarId;
  final double cameraAzimuth;
  final double cameraElevation;
  final double cameraDistance;
  final double orthographicSize;
  final double targetX;
  final double targetY;
  final double targetZ;
  final double floorY;
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
  final double walkMinX;
  final double walkMaxX;
  final double walkMinZ;
  final double walkMaxZ;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.assetPath,
    this.previewImagePath,
    this.isEnabled = true,
    this.displayOrder = 0,
    this.assetVersion = 1,
    this.defaultAvatarId,
    this.cameraAzimuth = 0,
    this.cameraElevation = 0,
    this.cameraDistance = 10,
    this.orthographicSize = 4.5,
    this.targetX = 0,
    this.targetY = 1.2,
    this.targetZ = 0,
    this.floorY = 0,
    this.gridOriginX = -3,
    this.gridOriginY = 0,
    this.gridOriginZ = -2.6,
    this.cellSizeX = 0.3,
    this.cellSizeY = 0.4,
    this.cellSizeZ = 0.28,
    this.gridCountX = 20,
    this.gridCountY = 8,
    this.gridCountZ = 20,
    this.gridVersion = 1,
    this.walkMinX = -2.5,
    this.walkMaxX = 2.5,
    this.walkMinZ = -2,
    this.walkMaxZ = 2,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UserPreferencesModel {
  final String profileId;
  final String? selectedRoomId;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOpenedAt;
  final int version;
  final String syncState;

  const UserPreferencesModel({
    required this.profileId,
    this.selectedRoomId,
    required this.onboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastOpenedAt,
    this.version = 1,
    this.syncState = 'localOnly',
  });

  UserPreferencesModel copyWith({
    String? selectedRoomId,
    bool? onboardingCompleted,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
    int? version,
    String? syncState,
  }) {
    return UserPreferencesModel(
      profileId: profileId,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
    );
  }
}

class RoomAvatarAssignmentModel {
  final String assignmentId;
  final String profileId;
  final String roomId;
  final String avatarId;
  final double posX;
  final double posY;
  final double posZ;
  final double scaleX;
  final double scaleY;
  final double scaleZ;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String syncState;

  const RoomAvatarAssignmentModel({
    String? assignmentId,
    required this.profileId,
    required this.roomId,
    required this.avatarId,
    this.posX = 0,
    this.posY = 0,
    this.posZ = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.scaleZ = 1,
    this.rotationX = 0,
    this.rotationY = 0,
    this.rotationZ = 0,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.syncState = 'localOnly',
  }) : assignmentId = assignmentId ?? '$profileId:$roomId';

  RoomAvatarAssignmentModel copyWith({
    String? avatarId,
    double? posX,
    double? posY,
    double? posZ,
    double? scaleX,
    double? scaleY,
    double? scaleZ,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    DateTime? updatedAt,
    int? version,
    String? syncState,
  }) {
    return RoomAvatarAssignmentModel(
      profileId: profileId,
      roomId: roomId,
      avatarId: avatarId ?? this.avatarId,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      scaleZ: scaleZ ?? this.scaleZ,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
    );
  }
}

enum RoomObjectSyncState { localOnly, pendingUpload, synced, failed }

enum PlacementSurface { floor, leftWall, rightWall, tabletop, rug }

extension PlacementSurfaceLabel on PlacementSurface {
  String get label => switch (this) {
        PlacementSurface.floor => '床',
        PlacementSurface.leftWall => '左の壁',
        PlacementSurface.rightWall => '右の壁',
        PlacementSurface.tabletop => 'テーブル上',
        PlacementSurface.rug => 'ラグ上',
      };

  bool get isVertical =>
      this == PlacementSurface.leftWall || this == PlacementSurface.rightWall;
}

class GridCell {
  final int x;
  final int y;
  final int z;

  const GridCell(this.x, this.y, this.z);

  @override
  bool operator ==(Object other) {
    return other is GridCell && other.x == x && other.y == y && other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}

class RoomObjectModel {
  final String objectId;
  final String profileId;
  final String roomId;
  final String? itemId;
  final String objectType;
  final String? assetKey;
  final String? localAssetPath;
  final String? storageKey;
  final PlacementSurface placementSurface;
  final int gridX;
  final int gridY;
  final int gridZ;
  final int spanX;
  final int spanY;
  final int spanZ;
  final int gridVersion;
  final double posX;
  final double posY;
  final double posZ;
  final double scale;
  final double scaleX;
  final double scaleY;
  final double scaleZ;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final bool isPlaced;
  final int? originalWidth;
  final int? originalHeight;
  final double? footprintWidth;
  final double? footprintHeight;
  final double? footprintDepth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final RoomObjectSyncState syncState;
  final List<GridCell> occupiedCells;

  const RoomObjectModel({
    required this.objectId,
    required this.profileId,
    required this.roomId,
    this.itemId,
    this.objectType = 'processedImagePlane',
    this.assetKey,
    this.localAssetPath,
    this.storageKey,
    this.placementSurface = PlacementSurface.floor,
    this.gridX = 0,
    this.gridY = 0,
    this.gridZ = 0,
    this.spanX = 1,
    this.spanY = 1,
    this.spanZ = 1,
    this.gridVersion = 1,
    this.posX = 0,
    this.posY = 0,
    this.posZ = 0,
    this.scale = 1,
    this.scaleX = 1,
    this.scaleY = 1,
    this.scaleZ = 1,
    this.rotationX = 0,
    this.rotationY = 0,
    this.rotationZ = 0,
    this.isPlaced = true,
    this.originalWidth,
    this.originalHeight,
    this.footprintWidth,
    this.footprintHeight,
    this.footprintDepth,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.version = 1,
    this.syncState = RoomObjectSyncState.localOnly,
    this.occupiedCells = const [],
  });

  bool get isFurniture => objectType == 'furniture';
  bool get isFloorCovering => isFurniture && assetKey == 'cloud_rug';

  double get aspectRatio {
    final width = originalWidth;
    final height = originalHeight;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 1;
    }
    return width / height;
  }

  double get effectiveScaleX => scaleX == 1 && scale != 1 ? scale : scaleX;
  double get effectiveScaleY => scaleY == 1 && scale != 1 ? scale : scaleY;
  double get effectiveScaleZ => scaleZ == 1 && scale != 1 ? scale : scaleZ;

  RoomObjectModel copyWith({
    String? objectId,
    String? roomId,
    String? objectType,
    String? assetKey,
    String? localAssetPath,
    String? storageKey,
    PlacementSurface? placementSurface,
    int? gridX,
    int? gridY,
    int? gridZ,
    int? spanX,
    int? spanY,
    int? spanZ,
    int? gridVersion,
    double? posX,
    double? posY,
    double? posZ,
    double? scale,
    double? scaleX,
    double? scaleY,
    double? scaleZ,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    bool? isPlaced,
    int? originalWidth,
    int? originalHeight,
    double? footprintWidth,
    double? footprintHeight,
    double? footprintDepth,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    int? version,
    RoomObjectSyncState? syncState,
    List<GridCell>? occupiedCells,
  }) {
    return RoomObjectModel(
      objectId: objectId ?? this.objectId,
      profileId: profileId,
      roomId: roomId ?? this.roomId,
      itemId: itemId,
      objectType: objectType ?? this.objectType,
      assetKey: assetKey ?? this.assetKey,
      localAssetPath: localAssetPath ?? this.localAssetPath,
      storageKey: storageKey ?? this.storageKey,
      placementSurface: placementSurface ?? this.placementSurface,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      gridZ: gridZ ?? this.gridZ,
      spanX: spanX ?? this.spanX,
      spanY: spanY ?? this.spanY,
      spanZ: spanZ ?? this.spanZ,
      gridVersion: gridVersion ?? this.gridVersion,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      posZ: posZ ?? this.posZ,
      scale: scale ?? this.scale,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      scaleZ: scaleZ ?? this.scaleZ,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      isPlaced: isPlaced ?? this.isPlaced,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      footprintWidth: footprintWidth ?? this.footprintWidth,
      footprintHeight: footprintHeight ?? this.footprintHeight,
      footprintDepth: footprintDepth ?? this.footprintDepth,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      syncState: syncState ?? this.syncState,
      occupiedCells: occupiedCells ?? this.occupiedCells,
    );
  }
}
