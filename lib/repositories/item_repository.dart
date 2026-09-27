import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/avatar_model.dart';
import '../models/item_media_model.dart';
import '../models/item_model.dart';

abstract class ItemRepository {
  Stream<List<ItemModel>> watchItems();

  Stream<List<ItemMediaModel>> watchItemMedia();

  Stream<List<AvatarModel>> watchAvatars();

  Stream<Map<String, List<String>>> watchRelatedAvatarIds();

  Future<ItemModel?> getItem(String itemId);

  Future<void> saveItem(ItemModel item);

  Future<void> saveMedia(ItemMediaModel media);

  Future<void> deleteMedia(String mediaId);

  Future<void> setRelatedAvatar(String itemId, String? avatarId);

  Future<void> setRelatedAvatars(String itemId, List<String> avatarIds);

  Future<void> deleteItem(String itemId);
}

class LocalItemRepository implements ItemRepository {
  final AppDatabase database;

  LocalItemRepository(this.database);

  @override
  Stream<List<ItemModel>> watchItems() {
    return database.watchAllItems().map(
          (rows) => rows.map(_toModel).toList(growable: false),
        );
  }

  @override
  Stream<List<ItemMediaModel>> watchItemMedia() {
    return database.watchAllItemMedia().map(
          (rows) => rows.map(_toMediaModel).toList(growable: false),
        );
  }

  @override
  Stream<List<AvatarModel>> watchAvatars() {
    return database.watchAllAvatars().map(
          (rows) => rows
              .map(
                (row) => AvatarModel(
                  id: row.avatarId,
                  displayName: row.displayName,
                  assetPath: row.assetPath,
                  previewImagePath: row.previewImagePath,
                  defaultScale: row.defaultScale,
                  assetVersion: row.assetVersion,
                  isEnabled: row.isEnabled,
                  createdAt: row.createdAt.toUtc(),
                  updatedAt: row.updatedAt?.toUtc(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Stream<Map<String, List<String>>> watchRelatedAvatarIds() {
    return database.watchAllItemAvatarLinks().map((rows) {
      final result = <String, List<String>>{};
      for (final row in rows) {
        result.putIfAbsent(row.itemId, () => <String>[]).add(row.avatarId);
      }
      return result;
    });
  }

  @override
  Future<ItemModel?> getItem(String itemId) async {
    final row = await database.getItemById(itemId);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> saveItem(ItemModel item) async {
    final companion = ItemsCompanion(
      itemId: Value(item.id),
      ownerId: Value(item.ownerId),
      title: Value(item.title),
      memo: Value(item.memo),
      status: Value(item.status.name),
      transferable: Value(item.transferable),
      localImagePath: Value(item.localImagePath),
      originalImageKey: Value(item.originalImageKey),
      processedImageKey: Value(item.processedImageKey),
      processedLocalImagePath: Value(item.processedLocalImagePath),
      outputType: Value(item.outputType),
      processStatus: Value(item.processStatus.name),
      processErrorMessage: Value(item.processErrorMessage),
      processFailureStage: Value(item.processFailureStage?.name),
      usedFrom: Value(item.usedFrom?.toUtc()),
      usedUntil: Value(item.usedUntil?.toUtc()),
      createdAt: Value(item.createdAt.toUtc()),
      updatedAt: Value(item.updatedAt.toUtc()),
    );

    await database.saveItem(companion);
  }

  @override
  Future<void> saveMedia(ItemMediaModel media) async {
    await database.saveItemMedia(
      ItemMediaCompanion(
        mediaId: Value(media.mediaId),
        itemId: Value(media.itemId),
        mediaType: Value(media.mediaType.name),
        localPath: Value(media.localPath),
        storageKey: Value(media.storageKey),
        createdAt: Value(media.createdAt.toUtc()),
      ),
    );
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    await database.deleteItemMediaById(mediaId);
  }

  @override
  Future<void> setRelatedAvatar(String itemId, String? avatarId) {
    return database.replaceRelatedAvatar(itemId, avatarId);
  }

  @override
  Future<void> setRelatedAvatars(String itemId, List<String> avatarIds) {
    return database.replaceRelatedAvatars(itemId, avatarIds);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await database.deleteItemById(itemId);
  }

  ItemModel _toModel(Item row) {
    return ItemModel(
      id: row.itemId,
      ownerId: row.ownerId,
      title: row.title,
      memo: row.memo,
      status: _parseItemStatus(row.status),
      transferable: row.transferable,
      localImagePath: row.localImagePath,
      originalImageKey: row.originalImageKey,
      processedImageKey: row.processedImageKey,
      processedLocalImagePath: row.processedLocalImagePath,
      outputType: row.outputType,
      processStatus: _parseProcessStatus(row.processStatus),
      processErrorMessage: row.processErrorMessage,
      processFailureStage: _parseFailureStage(row.processFailureStage),
      usedFrom: row.usedFrom?.toUtc(),
      usedUntil: row.usedUntil?.toUtc(),
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
    );
  }

  ItemMediaModel _toMediaModel(ItemMediaRow row) {
    return ItemMediaModel(
      mediaId: row.mediaId,
      itemId: row.itemId,
      mediaType: ItemMediaType.values.firstWhere(
        (type) => type.name == row.mediaType,
        orElse: () => ItemMediaType.image,
      ),
      localPath: row.localPath,
      storageKey: row.storageKey,
      createdAt: row.createdAt.toUtc(),
    );
  }

  ItemStatus _parseItemStatus(String value) {
    return ItemStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ItemStatus.keep,
    );
  }

  ImageProcessStatus _parseProcessStatus(String value) {
    if (value == 'pending') {
      return ImageProcessStatus.idle;
    }
    return ImageProcessStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ImageProcessStatus.idle,
    );
  }

  ImageProcessFailureStage? _parseFailureStage(String? value) {
    if (value == null) {
      return null;
    }
    for (final stage in ImageProcessFailureStage.values) {
      if (stage.name == value) {
        return stage;
      }
    }
    return null;
  }
}
