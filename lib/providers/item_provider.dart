import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../models/avatar_model.dart';
import '../models/item_media_model.dart';
import '../models/item_model.dart';
import '../repositories/item_repository.dart';
import '../services/local_file_service.dart';
import '../services/fastapi_image_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemRepository _repository;
  final ImageProcessingService _imageProcessingService;
  final ItemFileStore _fileStore;
  final Uuid _uuid;

  List<ItemModel> _items = const [];
  List<ItemMediaModel> _media = const [];
  List<AvatarModel> _avatars = const [];
  Map<String, List<String>> _relatedAvatarIds = const {};
  final Map<String, ItemModel> _localOverrides = {};
  final Map<String, Future<void>> _saveQueues = {};
  final Map<String, Timer> _memoSaveTimers = {};
  final Set<String> _processingItemIds = {};
  final Set<String> _deletedItemIds = {};
  bool _initialDeletingCleanupStarted = false;

  Object? _error;
  bool _isLoading = true;
  late final StreamSubscription<List<ItemModel>> _itemSubscription;
  late final StreamSubscription<List<ItemMediaModel>> _mediaSubscription;
  late final StreamSubscription<List<AvatarModel>> _avatarSubscription;
  late final StreamSubscription<Map<String, List<String>>>
      _avatarLinkSubscription;

  ItemProvider(
    this._repository, {
    ImageProcessingService? imageProcessingService,
    ItemFileStore? fileStore,
    Uuid? uuid,
  })  : _imageProcessingService =
            imageProcessingService ?? FastApiImageService(),
        _fileStore = fileStore ?? LocalFileService(),
        _uuid = uuid ?? const Uuid() {
    _itemSubscription = _repository.watchItems().listen(
      (items) {
        _items = items;
        _error = null;
        _isLoading = false;
        notifyListeners();
        if (!_initialDeletingCleanupStarted) {
          _initialDeletingCleanupStarted = true;
          unawaited(_cleanupDeletingItems());
        }
      },
      onError: _handleStreamError,
    );
    _mediaSubscription = _repository.watchItemMedia().listen(
      (media) {
        _media = media;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
    _avatarSubscription = _repository.watchAvatars().listen(
      (avatars) {
        _avatars = avatars;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
    _avatarLinkSubscription = _repository.watchRelatedAvatarIds().listen(
      (links) {
        _relatedAvatarIds = links;
        notifyListeners();
      },
      onError: _handleStreamError,
    );
  }

  List<ItemModel> get items {
    final merged = <ItemModel>[];
    final includedIds = <String>{};
    for (final storedItem in _items) {
      if (storedItem.status == ItemStatus.deleting) continue;
      final item = _localOverrides[storedItem.id] ?? storedItem;
      if (item.status == ItemStatus.deleting) continue;
      merged.add(_decorateItem(item));
      includedIds.add(item.id);
    }
    for (final item in _localOverrides.values) {
      if (item.status == ItemStatus.deleting) continue;
      if (includedIds.add(item.id)) {
        merged.add(_decorateItem(item));
      }
    }
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(merged);
  }

  List<ItemModel> get keepItems =>
      items.where((item) => item.status == ItemStatus.keep).toList();
  List<ItemModel> get giveAwayItems =>
      items.where((item) => item.status == ItemStatus.giveAway).toList();
  List<ItemModel> get transferableItems =>
      items.where((item) => item.transferable).toList();
  List<AvatarModel> get avatars => List.unmodifiable(_avatars);
  Object? get error => _error;
  bool get isLoading => _isLoading;

  ItemModel? itemById(String itemId) {
    final local = _localOverrides[itemId];
    if (local != null) {
      return _decorateItem(local);
    }
    for (final item in _items) {
      if (item.id == itemId) {
        return _decorateItem(item);
      }
    }
    return null;
  }

  List<ItemMediaModel> mediaFor(String itemId) {
    return List.unmodifiable(
      _media.where((media) => media.itemId == itemId),
    );
  }

  Future<void> fetchItems() async {
    try {
      _items = await _repository.watchItems().first;
      _error = null;
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cleanupDeletingItems() async {
    final deletingItems =
        _items.where((item) => item.status == ItemStatus.deleting).toList();
    for (final item in deletingItems) {
      try {
        await removeItem(item.id);
      } catch (e) {
        debugPrint('[ItemProvider] Background cleanup failed for ${item.id}: $e');
      }
    }
  }

  Future<ItemModel> addItem(
    String title,
    String? memo,
    String? imagePath, {
    String? id,
    ItemStatus status = ItemStatus.keep,
    bool transferable = false,
    String? originalImageKey,
    String? processedImageKey,
    String? processedLocalImagePath,
    String outputType = 'sticker_png',
    ImageProcessStatus processStatus = ImageProcessStatus.idle,
  }) async {
    final normalizedTitle = _validateTitle(title);
    final now = DateTime.now().toUtc();
    final item = ItemModel(
      id: id ?? _uuid.v4(),
      title: normalizedTitle,
      memo: memo ?? '',
      status: status,
      transferable: transferable,
      localImagePath: imagePath,
      originalImageKey: originalImageKey,
      processedImageKey: processedImageKey,
      processedLocalImagePath: processedLocalImagePath,
      outputType: outputType,
      processStatus: processStatus,
      createdAt: now,
    );

    await _queueSave(item);
    return _decorateItem(item);
  }

  Future<String> startImageRegistration({
    required String title,
    required XFile image,
  }) async {
    final normalizedTitle = _validateTitle(title);
    final itemId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final originalImagePath = await _fileStore.saveOriginalImage(
      itemId: itemId,
      source: image,
    );
    final item = ItemModel(
      id: itemId,
      title: normalizedTitle,
      localImagePath: originalImagePath,
      processStatus: ImageProcessStatus.processing,
      createdAt: now,
    );

    await _queueSave(item);
    try {
      await setRelatedAvatar(itemId, 'girl1');
    } catch (e) {
      debugPrint('Failed to set default related avatar: $e');
    }
    unawaited(_runImageProcessing(itemId));
    return itemId;
  }

  Future<void> retryImageProcessing(String itemId) async {
    final item = itemById(itemId);
    if (item == null || _processingItemIds.contains(itemId)) {
      return;
    }
    await _mutateAndSave(
      itemId,
      (current) => current.copyWith(
        processStatus: ImageProcessStatus.processing,
        clearProcessError: true,
        clearProcessFailureStage: true,
      ),
    );
    unawaited(_runImageProcessing(itemId));
  }

  void updateDetailMemo(String itemId, String memo) {
    final current = _rawItemById(itemId);
    if (current == null) {
      return;
    }
    // メモ欄はTextEditingControllerが表示を担うため、キー入力のたびに
    // notifyListeners()すると無関係なウィジェット(画像・添付一覧等)まで
    // 毎回再構築されて入力がカクつく。ここでは状態のみ更新し、通知は
    // 下のデバウンスタイマー経由(_saveCurrentItem→_queueSave)に一本化する。
    _localOverrides[itemId] = current.copyWith(
      memo: memo,
      updatedAt: DateTime.now().toUtc(),
    );
    _memoSaveTimers[itemId]?.cancel();
    _memoSaveTimers[itemId] = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_saveCurrentItem(itemId)),
    );
  }

  Future<void> setUsedFrom(String itemId, DateTime? value) {
    return _mutateAndSave(
      itemId,
      (item) => item.copyWith(
        usedFrom: value == null ? null : _monthOnly(value),
        clearUsedFrom: value == null,
      ),
    );
  }

  Future<void> setUsedUntil(String itemId, DateTime? value) {
    return _mutateAndSave(
      itemId,
      (item) => item.copyWith(
        usedUntil: value == null ? null : _monthOnly(value),
        clearUsedUntil: value == null,
      ),
    );
  }

  Future<void> setRelatedAvatar(String itemId, String? avatarId) async {
    await setRelatedAvatars(itemId, avatarId == null ? const [] : [avatarId]);
  }

  Future<void> setRelatedAvatars(String itemId, List<String> avatarIds) async {
    for (final avatarId in avatarIds) {
      if (!_avatars.any((avatar) => avatar.id == avatarId)) {
        throw ArgumentError.value(avatarId, 'avatarId', 'Unknown avatar ID');
      }
    }
    final previous = _relatedAvatarIds[itemId] ?? const <String>[];
    _relatedAvatarIds = {
      ..._relatedAvatarIds,
      itemId: avatarIds,
    };
    notifyListeners();
    try {
      await _repository.setRelatedAvatars(itemId, avatarIds);
    } catch (error) {
      _relatedAvatarIds = {
        ..._relatedAvatarIds,
        itemId: previous,
      };
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addMedia(
    String itemId,
    List<XFile> sources, {
    ItemMediaType? mediaType,
  }) async {
    for (final source in sources) {
      if (_isDeleting(itemId)) {
        throw StateError('Cannot add media to deleting item: $itemId');
      }
      final mediaId = _uuid.v4();
      String? savedPath;
      try {
        final attachmentPath = await _fileStore.saveAttachment(
          itemId: itemId,
          mediaId: mediaId,
          source: source,
        );
        savedPath = attachmentPath;
        if (_isDeleting(itemId)) {
          await _fileStore.deleteManagedFile(attachmentPath);
          savedPath = null;
          throw StateError('Cannot add media to deleting item: $itemId');
        }
        final media = ItemMediaModel(
          mediaId: mediaId,
          itemId: itemId,
          mediaType: mediaType ?? _detectMediaType(source),
          localPath: savedPath,
          createdAt: DateTime.now().toUtc(),
        );
        _media = [..._media, media];
        notifyListeners();
        await _repository.saveMedia(media);
        if (_isDeleting(itemId)) {
          await _repository.deleteMedia(mediaId);
          _media = _media
              .where((current) => current.mediaId != mediaId)
              .toList(growable: false);
          await _fileStore.deleteManagedFile(attachmentPath);
          savedPath = null;
          notifyListeners();
          throw StateError('Cannot add media to deleting item: $itemId');
        }
      } catch (_) {
        if (savedPath != null) {
          await _fileStore.deleteManagedFile(savedPath);
        }
        rethrow;
      }
    }
  }

  ItemMediaType _detectMediaType(XFile file) {
    final ext = p.extension(file.name).toLowerCase();
    final videoExtensions = {
      '.mp4',
      '.mov',
      '.avi',
      '.wmv',
      '.flv',
      '.mkv',
      '.webm',
      '.3gp'
    };
    if (videoExtensions.contains(ext)) {
      return ItemMediaType.video;
    }
    return ItemMediaType.image;
  }

  Future<void> removeMedia(ItemMediaModel media) async {
    await _repository.deleteMedia(media.mediaId);
    _media = _media
        .where((current) => current.mediaId != media.mediaId)
        .toList(growable: false);
    notifyListeners();
    await _fileStore.deleteManagedFile(media.localPath);
  }

  Future<void> flushPendingEdits(String itemId) async {
    _memoSaveTimers.remove(itemId)?.cancel();
    await _saveCurrentItem(itemId);
    final queued = _saveQueues[itemId];
    if (queued != null) {
      await queued;
    }
  }

  Future<void> updateItem(ItemModel item) async {
    await _queueSave(
      item.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }

  Future<void> removeItem(String id) async {
    _memoSaveTimers.remove(id)?.cancel();
    final item = _rawItemById(id);
    if (item == null) return;

    final previousOverride = _localOverrides[id];
    _deletedItemIds.add(id);

    // 1段階目: ステータスを 'deleting' に変更してDBへ保存。
    // これによりUI（一覧）からは即座に消えるが、レコードは残る。
    // 先行する保存の完了後にマーカーを保存し、古い内容が後から復活するのを防ぐ。
    final deletingItem = item.copyWith(
      status: ItemStatus.deleting,
      updatedAt: DateTime.now().toUtc(),
    );
    try {
      await _queueSave(deletingItem, allowDeleting: true);
    } catch (_) {
      _deletedItemIds.remove(id);
      if (previousOverride == null) {
        _localOverrides.remove(id);
      } else {
        _localOverrides[id] = previousOverride;
      }
      notifyListeners();
      rethrow;
    }

    // 2段階目: 物理ファイルの削除。
    // ここで失敗しても、レコードが 'deleting' で残っているため
    // 次回のアプリ起動時等にクリーンアップを再試行できる。
    try {
      await _fileStore.deleteItemDirectory(id);
    } catch (error) {
      debugPrint('[ItemProvider] Failed to delete item files: $error');
      // ファイル削除失敗時はDBレコードを残したまま例外を投げる。
      // これにより、UI側で失敗を知ることができ、かつゴミファイルが
      // 「管理外」になるのを防ぐ。
      throw StateError('アイテムのデータは削除されましたが、一部のファイルの消去に失敗しました。');
    }

    // 3段階目: DBレコードの完全削除。
    await _repository.deleteItem(id);
    _localOverrides.remove(id);
    _items = _items.where((item) => item.id != id).toList(growable: false);
    _media =
        _media.where((media) => media.itemId != id).toList(growable: false);
    notifyListeners();
  }

  Future<void> _runImageProcessing(String itemId) async {
    if (!_processingItemIds.add(itemId)) {
      return;
    }

    try {
      if (_deletedItemIds.contains(itemId)) return;

      var item = _rawItemById(itemId);
      if (item == null || item.status == ItemStatus.deleting) {
        return;
      }
      item = await _mutateAndSave(
        itemId,
        (current) => current.copyWith(
          processStatus: ImageProcessStatus.processing,
          clearProcessError: true,
          clearProcessFailureStage: true,
        ),
      );
      final originalImagePath = item.localImagePath;
      if (originalImagePath == null || originalImagePath.isEmpty) {
        throw const ImageServiceException('元画像を読み込めませんでした。');
      }
      final originalFile = File(originalImagePath);
      if (!await originalFile.exists()) {
        throw const ImageServiceException('元画像が端末内に見つかりませんでした。');
      }
      final imageBytes = await originalFile.readAsBytes();
      final processedBytes = await _imageProcessingService.processImage(
        itemId: itemId,
        imageBytes: imageBytes,
        fileName: originalImagePath,
        title: item.title,
        outputType: item.outputType,
      );

      if (_deletedItemIds.contains(itemId)) return;
      final currentAfterAi = _rawItemById(itemId);
      if (currentAfterAi == null ||
          currentAfterAi.status == ItemStatus.deleting) {
        return;
      }

      final processedLocalImagePath = await _fileStore.saveProcessedImage(
        itemId: itemId,
        bytes: processedBytes,
      );

      // 保存完了直後に削除された場合のケア
      if (_deletedItemIds.contains(itemId) ||
          (_rawItemById(itemId)?.status == ItemStatus.deleting)) {
        unawaited(_fileStore.deleteManagedFile(processedLocalImagePath));
        return;
      }

      await _mutateAndSave(
        itemId,
        (current) => current.copyWith(
          processedLocalImagePath: processedLocalImagePath,
          processStatus: ImageProcessStatus.completed,
          clearProcessError: true,
          clearProcessFailureStage: true,
        ),
      );
    } on ImageServiceException catch (error) {
      if (!_deletedItemIds.contains(itemId) &&
          _rawItemById(itemId)?.status != ItemStatus.deleting) {
        await _markProcessingFailed(
          itemId,
          ImageProcessFailureStage.processing,
          error.toString(),
        );
      }
    } catch (error) {
      debugPrint(
        '[ItemProvider][image_processing] failed '
        'type=${error.runtimeType}',
      );
      if (!_deletedItemIds.contains(itemId) &&
          _rawItemById(itemId)?.status != ItemStatus.deleting) {
        await _markProcessingFailed(
          itemId,
          ImageProcessFailureStage.processing,
          '画像加工に失敗しました。',
        );
      }
    } finally {
      _processingItemIds.remove(itemId);
    }
  }

  Future<void> _markProcessingFailed(
    String itemId,
    ImageProcessFailureStage stage,
    String message,
  ) async {
    final item = _rawItemById(itemId);
    if (item == null) {
      return;
    }
    await _mutateAndSave(
      itemId,
      (current) => current.copyWith(
        processStatus: ImageProcessStatus.failed,
        processErrorMessage: message,
        processFailureStage: stage,
      ),
    );
  }

  Future<ItemModel> _mutateAndSave(
    String itemId,
    ItemModel Function(ItemModel item) transform,
  ) async {
    final current = _rawItemById(itemId);
    if (current == null) {
      throw StateError('Item not found: $itemId');
    }
    if (_deletedItemIds.contains(itemId) ||
        current.status == ItemStatus.deleting) {
      // 削除中のアイテムに対する変更は拒否する。
      // ただしステータス自体を 'deleting' に変える呼び出しだけは許容する必要がある
      // （removeItem自体がこのメソッドを呼ぶため）。
      final updated = transform(current);
      if (updated.status != ItemStatus.deleting) {
        throw StateError('Cannot mutate deleting item: $itemId');
      }
    }
    final updated = transform(current).copyWith(
      updatedAt: DateTime.now().toUtc(),
    );
    await _queueSave(updated);
    return _rawItemById(itemId) ?? updated;
  }

  Future<void> _saveCurrentItem(String itemId) async {
    final item = _rawItemById(itemId);
    if (item == null) {
      return;
    }
    try {
      await _queueSave(item);
    } catch (error) {
      _error = error;
      notifyListeners();
    }
  }

  Future<void> _queueSave(
    ItemModel item, {
    bool allowDeleting = false,
  }) async {
    _localOverrides[item.id] = item;
    notifyListeners();

    final previous = _saveQueues[item.id] ?? Future<void>.value();
    final ready = previous.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    final next = ready.then<void>((_) async {
      final latest = _localOverrides[item.id];
      if (latest != null &&
          (allowDeleting ||
              (!_deletedItemIds.contains(item.id) &&
                  latest.status != ItemStatus.deleting))) {
        await _repository.saveItem(latest);
      }
    });
    _saveQueues[item.id] = next;
    await next;
  }

  ItemModel? _rawItemById(String itemId) {
    final local = _localOverrides[itemId];
    if (local != null) {
      return local;
    }
    for (final item in _items) {
      if (item.id == itemId) {
        return item;
      }
    }
    return null;
  }

  bool _isDeleting(String itemId) {
    return _deletedItemIds.contains(itemId) ||
        _rawItemById(itemId)?.status == ItemStatus.deleting;
  }

  ItemModel _decorateItem(ItemModel item) {
    return item.copyWith(
      relatedAvatarIds:
          List.unmodifiable(_relatedAvatarIds[item.id] ?? const <String>[]),
      media: mediaFor(item.id),
    );
  }

  String _validateTitle(String title) {
    final normalized = title.trim();
    final hasControlCharacters =
        RegExp(r'[\u0000-\u001F\u007F]').hasMatch(normalized);
    if (normalized.isEmpty ||
        normalized.runes.length > ItemModel.maxTitleLength ||
        hasControlCharacters) {
      throw ArgumentError('タイトルは1文字以上50文字以内で入力してください。');
    }
    return normalized;
  }

  DateTime _monthOnly(DateTime value) {
    return DateTime.utc(value.year, value.month);
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _memoSaveTimers.values) {
      timer.cancel();
    }
    _itemSubscription.cancel();
    _mediaSubscription.cancel();
    _avatarSubscription.cancel();
    _avatarLinkSubscription.cancel();
    super.dispose();
  }
}
