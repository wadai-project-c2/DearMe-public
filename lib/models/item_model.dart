import 'package:flutter/foundation.dart';

import 'item_media_model.dart';

enum ItemStatus { keep, giveAway, deleting }

enum ImageProcessStatus { idle, uploading, processing, completed, failed }

enum ImageProcessFailureStage { upload, processing, download }

class ItemModel {
  static const int maxTitleLength = 50;

  final String id;
  final String ownerId;
  final String title;
  final String memo;
  final ItemStatus status;
  final bool transferable;
  final String? localImagePath;
  final String? originalImageKey;
  final String? processedImageKey;
  final String? processedLocalImagePath;
  final String outputType;
  final ImageProcessStatus processStatus;
  final String? processErrorMessage;
  final ImageProcessFailureStage? processFailureStage;
  final DateTime? usedFrom;
  final DateTime? usedUntil;
  final List<String> relatedAvatarIds;
  final List<ItemMediaModel> media;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItemModel({
    required this.id,
    this.ownerId = 'local_user',
    required this.title,
    this.memo = '',
    this.status = ItemStatus.keep,
    this.transferable = false,
    this.localImagePath,
    this.originalImageKey,
    this.processedImageKey,
    this.processedLocalImagePath,
    this.outputType = 'sticker_png',
    this.processStatus = ImageProcessStatus.idle,
    this.processErrorMessage,
    this.processFailureStage,
    this.usedFrom,
    this.usedUntil,
    this.relatedAvatarIds = const [],
    this.media = const [],
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  String? get imagePath => processedLocalImagePath ?? localImagePath;

  /// スワイプ配置演出および部屋への配置で使う画像。
  /// AI加工が完了していれば加工済み画像、未完了・失敗時は元写真へフォールバックする。
  /// バックエンド未起動などで加工に失敗しても演出をスキップしないための入口（#95）。
  String? get placementImagePath {
    final processed = processedLocalImagePath;
    if (processStatus == ImageProcessStatus.completed &&
        processed != null &&
        processed.isNotEmpty) {
      return processed;
    }
    final original = localImagePath;
    if (original != null && original.isNotEmpty) {
      return original;
    }
    return null;
  }

  String? get relatedAvatarId =>
      relatedAvatarIds.isEmpty ? null : relatedAvatarIds.first;

  ItemModel copyWith({
    String? ownerId,
    String? title,
    String? memo,
    ItemStatus? status,
    bool? transferable,
    String? localImagePath,
    String? originalImageKey,
    String? processedImageKey,
    String? processedLocalImagePath,
    String? outputType,
    ImageProcessStatus? processStatus,
    String? processErrorMessage,
    bool clearProcessError = false,
    ImageProcessFailureStage? processFailureStage,
    bool clearProcessFailureStage = false,
    DateTime? usedFrom,
    bool clearUsedFrom = false,
    DateTime? usedUntil,
    bool clearUsedUntil = false,
    List<String>? relatedAvatarIds,
    List<ItemMediaModel>? media,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      transferable: transferable ?? this.transferable,
      localImagePath: localImagePath ?? this.localImagePath,
      originalImageKey: originalImageKey ?? this.originalImageKey,
      processedImageKey: processedImageKey ?? this.processedImageKey,
      processedLocalImagePath:
          processedLocalImagePath ?? this.processedLocalImagePath,
      outputType: outputType ?? this.outputType,
      processStatus: processStatus ?? this.processStatus,
      processErrorMessage: clearProcessError
          ? null
          : processErrorMessage ?? this.processErrorMessage,
      processFailureStage: clearProcessFailureStage
          ? null
          : processFailureStage ?? this.processFailureStage,
      usedFrom: clearUsedFrom ? null : usedFrom ?? this.usedFrom,
      usedUntil: clearUsedUntil ? null : usedUntil ?? this.usedUntil,
      relatedAvatarIds: relatedAvatarIds ?? this.relatedAvatarIds,
      media: media ?? this.media,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ItemModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.title == title &&
        other.memo == memo &&
        other.status == status &&
        other.transferable == transferable &&
        other.localImagePath == localImagePath &&
        other.originalImageKey == originalImageKey &&
        other.processedImageKey == processedImageKey &&
        other.processedLocalImagePath == processedLocalImagePath &&
        other.outputType == outputType &&
        other.processStatus == processStatus &&
        other.processErrorMessage == processErrorMessage &&
        other.processFailureStage == processFailureStage &&
        other.usedFrom == usedFrom &&
        other.usedUntil == usedUntil &&
        listEquals(other.relatedAvatarIds, relatedAvatarIds) &&
        listEquals(other.media, media) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        ownerId,
        title,
        memo,
        status,
        transferable,
        localImagePath,
        originalImageKey,
        processedImageKey,
        processedLocalImagePath,
        outputType,
        processStatus,
        processErrorMessage,
        processFailureStage,
        usedFrom,
        usedUntil,
        Object.hashAll(relatedAvatarIds),
        Object.hashAll(media),
        createdAt,
        updatedAt,
      ]);
}
