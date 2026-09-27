class AvatarModel {
  final String id;
  final String displayName;
  final String? assetPath;
  final String? previewImagePath;
  final double defaultScale;
  final int assetVersion;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AvatarModel({
    required this.id,
    required this.displayName,
    this.assetPath,
    this.previewImagePath,
    this.defaultScale = 1,
    this.assetVersion = 1,
    this.isEnabled = true,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get canRender => isEnabled && (assetPath?.isNotEmpty ?? false);
}
