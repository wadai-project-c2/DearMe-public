enum ItemMediaType { image, video }

class ItemMediaModel {
  final String mediaId;
  final String itemId;
  final ItemMediaType mediaType;
  final String localPath;
  final String? storageKey;
  final DateTime createdAt;

  const ItemMediaModel({
    required this.mediaId,
    required this.itemId,
    required this.mediaType,
    required this.localPath,
    this.storageKey,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ItemMediaModel &&
        other.mediaId == mediaId &&
        other.itemId == itemId &&
        other.mediaType == mediaType &&
        other.localPath == localPath &&
        other.storageKey == storageKey &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        mediaId,
        itemId,
        mediaType,
        localPath,
        storageKey,
        createdAt,
      );
}
