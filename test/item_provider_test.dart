import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dearme/models/avatar_model.dart';
import 'package:dearme/models/item_media_model.dart';
import 'package:dearme/models/item_model.dart';
import 'package:dearme/providers/item_provider.dart';
import 'package:dearme/repositories/item_repository.dart';
import 'package:dearme/services/local_file_service.dart';
import 'package:dearme/services/fastapi_image_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('ItemProvider saves, updates, and removes items', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(
      repository,
      imageProcessingService: _FakeImageProcessingService(),
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    await provider.fetchItems();
    final item = await provider.addItem(
      '思い出の品',
      'Providerテスト',
      'local/image.png',
      id: 'item-test-1',
      originalImageKey: 'original/item-test-1.png',
      processedImageKey: 'processed/item-test-1.png',
      processStatus: ImageProcessStatus.completed,
    );

    expect(provider.items, hasLength(1));
    expect(provider.keepItems.single.id, item.id);

    await provider.updateItem(item.copyWith(title: '更新した思い出の品'));
    expect(provider.items.single.title, '更新した思い出の品');

    await provider.removeItem(item.id);
    expect(provider.items, isEmpty);
  });

  test('removeItem deletes DB records and physical files with two-phase safety',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(repository, fileStore: fileStore);

    const itemId = 'to-delete';
    await provider.addItem('タイトル', 'メモ', null, id: itemId);
    await provider.setRelatedAvatars(itemId, ['girl1']);
    await provider.addMedia(
        itemId, [XFile.fromData(Uint8List(3), name: 'a.jpg')]);
    repository.simulateRoomObject(itemId);

    expect(provider.items, hasLength(1));
    expect(repository.hasLinksFor(itemId), isTrue);

    await provider.removeItem(itemId);

    expect(provider.items, isEmpty);
    expect(provider.mediaFor(itemId), isEmpty);
    expect(repository.hasLinksFor(itemId), isFalse);
    expect(repository.deleteItemCalls, 1);
    // 物理ファイルも消えている
    expect(fileStore.root.listSync().where((f) => f.path.contains(itemId)),
        isEmpty);
  });

  test('removeItem keeps record as deleting on file deletion failure',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = _FakeFileStore.withForcedError();
    final provider = ItemProvider(repository, fileStore: fileStore);

    const itemId = 'fail-delete';
    await provider.addItem('消せないアイテム', null, null, id: itemId);

    await expectLater(
      provider.removeItem(itemId),
      throwsA(isA<StateError>().having((e) => e.message, 'message',
          contains('一部のファイルの消去に失敗しました'))),
    );

    // Issue #152: DBからは消えず、ステータスが 'deleting' になっていること
    // これによりUIからは隠れるが、データ不整合として管理下に置ける。
    expect(provider.items, isEmpty); // UIからは消えている
    final itemInDb = await repository.getItem(itemId);
    expect(itemInDb?.status, ItemStatus.deleting);
  });

  test('save queue does not overwrite a deletion', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(repository, fileStore: fileStore);

    const itemId = 'race-condition';
    await provider.addItem('保存直前に消される', null, null, id: itemId);

    // 保存を遅延させる
    repository.delaySave = const Duration(milliseconds: 100);

    // メモ更新（保存キューに入る）
    provider.updateDetailMemo(itemId, '新しいメモ');
    final flushFuture = provider.flushPendingEdits(itemId);

    // その直後に削除実行
    await provider.removeItem(itemId);

    await flushFuture;

    // 削除されたアイテムが再保存されて復活してはいけない
    expect(provider.items.where((i) => i.id == itemId), isEmpty);
    final itemInDb = await repository.getItem(itemId);
    expect(itemInDb, isNull);
  });

  test('constructor stream triggers cleanup of orphaned deleting items',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();

    const itemId = 'orphaned-deleting';
    // 削除途中の状態をエミュレート（DBには 'deleting' で残り、ファイルも存在する）
    await repository.saveItem(ItemModel(
      id: itemId,
      title: '削除中だったアイテム',
      status: ItemStatus.deleting,
      localImagePath: 'some/path',
      createdAt: DateTime.now(),
    ));
    final file =
        File('${fileStore.root.path}${Platform.pathSeparator}$itemId.png');
    await file.writeAsBytes([1]);

    final provider = ItemProvider(repository, fileStore: fileStore);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    // fetchItemsを明示的に呼ばなくても、初回ストリーム受信で再試行される。
    await _waitUntil(() async => (await repository.getItem(itemId)) == null);

    expect(file.existsSync(), isFalse);
    expect(provider.items, isEmpty);
  });

  test('addMedia removes a file saved after item deletion', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create(delayAttachment: true);
    final provider = ItemProvider(repository, fileStore: fileStore);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    const itemId = 'delete-during-attachment';
    await provider.addItem('添付保存中に削除', null, null, id: itemId);

    final addFuture = provider.addMedia(
      itemId,
      [XFile.fromData(Uint8List(3), name: 'late.jpg')],
    );
    await fileStore.attachmentSaveStarted.future;

    await provider.removeItem(itemId);
    fileStore.completeAttachmentSave();

    await expectLater(addFuture, throwsA(isA<StateError>()));
    expect(fileStore.root.listSync().whereType<File>(), isEmpty);
    expect(await repository.getItem(itemId), isNull);
  });

  test('removeItem rolls back local tombstone when marker save fails',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(repository, fileStore: fileStore);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    const itemId = 'marker-save-failure';
    await provider.addItem('削除を取り消すアイテム', '元のメモ', null, id: itemId);
    repository.failNextSave = true;

    await expectLater(provider.removeItem(itemId), throwsA(isA<StateError>()));

    expect(provider.items.single.id, itemId);
    expect(provider.items.single.status, ItemStatus.keep);
    expect(provider.items.single.memo, '元のメモ');
    expect((await repository.getItem(itemId))?.status, ItemStatus.keep);
  });

  test('processing continues while detail input is retained', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final imageService = _FakeImageProcessingService(waitForProcess: true);
    final provider = ItemProvider(
      repository,
      imageProcessingService: imageService,
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    final itemId = await provider.startImageRegistration(
      title: '白いTシャツ',
      image: XFile.fromData(
        Uint8List.fromList([1, 2, 3, 4]),
        name: 'shirt.png',
        mimeType: 'image/png',
      ),
    );

    await imageService.processStarted.future;
    expect(provider.itemById(itemId)?.processStatus,
        ImageProcessStatus.processing);

    provider.updateDetailMemo(itemId, '加工中に入力した詳細メモ');
    await provider.setUsedFrom(itemId, DateTime.utc(2020, 4));
    await provider.setRelatedAvatar(itemId, 'avatar-daughter');
    await provider.flushPendingEdits(itemId);

    imageService.completeProcess();
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus ==
          ImageProcessStatus.completed);

    final completed = provider.itemById(itemId)!;
    expect(provider.items.where((item) => item.id == itemId), hasLength(1));
    expect(completed.memo, '加工中に入力した詳細メモ');
    expect(completed.usedFrom, DateTime.utc(2020, 4));
    expect(completed.relatedAvatarIds, ['avatar-daughter']);
    expect(imageService.lastTitle, '白いTシャツ');
  });

  test('retry reuses the same item and preserves details after AI failure',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final imageService = _FakeImageProcessingService(failFirstProcess: true);
    final provider = ItemProvider(
      repository,
      imageProcessingService: imageService,
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    final itemId = await provider.startImageRegistration(
      title: '赤いかばん',
      image: XFile.fromData(
        Uint8List.fromList([5, 6, 7, 8]),
        name: 'bag.png',
        mimeType: 'image/png',
      ),
    );
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus == ImageProcessStatus.failed);

    provider.updateDetailMemo(itemId, '失敗しても残すメモ');
    await provider.setUsedUntil(itemId, DateTime.utc(2024, 12));
    await provider.flushPendingEdits(itemId);
    await provider.retryImageProcessing(itemId);
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus ==
          ImageProcessStatus.completed);

    final completed = provider.itemById(itemId)!;
    expect(provider.items.where((item) => item.id == itemId), hasLength(1));
    expect(completed.memo, '失敗しても残すメモ');
    expect(completed.usedUntil, DateTime.utc(2024, 12));
    expect(imageService.processCalls, 2);
    expect(fileStore.originalSaveCalls, 1);
  });

  test('placement falls back to the original photo when AI processing fails',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final imageService = _FakeImageProcessingService(failFirstProcess: true);
    final provider = ItemProvider(
      repository,
      imageProcessingService: imageService,
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    final itemId = await provider.startImageRegistration(
      title: '緑の傘',
      image: XFile.fromData(
        Uint8List.fromList([9, 10, 11, 12]),
        name: 'umbrella.png',
        mimeType: 'image/png',
      ),
    );
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus == ImageProcessStatus.failed);

    // 加工に失敗しても元写真が配置画像として使えるため、
    // スワイプ配置演出をスキップしてホームへ直行してはいけない（#95）。
    final failed = provider.itemById(itemId)!;
    expect(failed.processedLocalImagePath, isNull);
    expect(failed.placementImagePath, isNotNull);
    expect(failed.placementImagePath, failed.localImagePath);

    await provider.retryImageProcessing(itemId);
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus ==
          ImageProcessStatus.completed);

    // 加工が成功したら加工済み画像を優先する。
    final completed = provider.itemById(itemId)!;
    expect(completed.placementImagePath, completed.processedLocalImagePath);
    expect(completed.placementImagePath, isNot(completed.localImagePath));
  });

  test('retry reads the saved original image from local storage', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final imageService = _FakeImageProcessingService(failFirstProcess: true);
    final provider = ItemProvider(
      repository,
      imageProcessingService: imageService,
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    final itemId = await provider.startImageRegistration(
      title: '青い帽子',
      image: XFile.fromData(
        Uint8List.fromList([9, 10, 11, 12]),
        name: 'hat.png',
        mimeType: 'image/png',
      ),
    );
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus == ImageProcessStatus.failed);

    expect(
      provider.itemById(itemId)?.processFailureStage,
      ImageProcessFailureStage.processing,
    );
    final savedOriginalPath = provider.itemById(itemId)?.localImagePath;
    expect(savedOriginalPath, isNotNull);
    expect(await File(savedOriginalPath!).exists(), isTrue);

    await provider.retryImageProcessing(itemId);
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus ==
          ImageProcessStatus.completed);

    expect(provider.items.where((item) => item.id == itemId), hasLength(1));
    expect(imageService.processCalls, 2);
    expect(fileStore.originalSaveCalls, 1);
  });

  test('addItem associates girl1 as default avatar', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(
      repository,
      imageProcessingService: _FakeImageProcessingService(),
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    final itemId = await provider.startImageRegistration(
      title: 'テストアイテム',
      image: XFile.fromData(Uint8List(0), name: 'test.png'),
    );

    // バックグラウンドでの画像加工処理が終わるまで待機し、テスト終了後の例外発生を防ぐ
    await _waitUntil(() =>
          provider.itemById(itemId)?.processStatus ==
          ImageProcessStatus.completed);

    final item = provider.itemById(itemId);
    expect(item?.relatedAvatarIds, contains('girl1'));
  });

  test('setRelatedAvatars throws on unknown avatar ID', () async {
    final repository = _FakeItemRepository();
    final provider = ItemProvider(repository);
    addTearDown(() async {
      provider.dispose();
      await repository.close();
    });

    expect(
      () => provider.setRelatedAvatars('any-id', ['unknown-avatar']),
      throwsArgumentError,
    );
  });

  test('addMedia and removeMedia manage attachments', () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final provider = ItemProvider(
      repository,
      fileStore: fileStore,
    );
    addTearDown(() async {
      provider.dispose();
      await repository.close();
      await fileStore.close();
    });

    const itemId = 'item-with-media';
    await provider.addItem('テスト', null, null, id: itemId);

    final mediaSource = XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: 'attachment.jpg',
    );
    await provider.addMedia(itemId, [mediaSource]);

    expect(provider.mediaFor(itemId), hasLength(1));
    final media = provider.mediaFor(itemId).first;
    expect(media.mediaType, ItemMediaType.image);
    expect(File(media.localPath).existsSync(), isTrue);

    await provider.removeMedia(media);
    expect(provider.mediaFor(itemId), isEmpty);
    expect(File(media.localPath).existsSync(), isFalse);
  });

  test('deletion during image processing cancels file save and DB update',
      () async {
    final repository = _FakeItemRepository();
    final fileStore = await _FakeFileStore.create();
    final imageService = _FakeImageProcessingService(waitForProcess: true);
    final provider = ItemProvider(
      repository,
      imageProcessingService: imageService,
      fileStore: fileStore,
    );

    final itemId = await provider.startImageRegistration(
      title: '加工中に消される品物',
      image: XFile.fromData(Uint8List(4), name: 'temp.png'),
    );

    await imageService.processStarted.future;
    // 加工中に削除実行
    await provider.removeItem(itemId);

    // 加工を完了させる
    imageService.completeProcess();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // 削除済みなので、加工結果がDBやファイルに保存されてはいけない
    expect(provider.items, isEmpty);
    final itemInDb = await repository.getItem(itemId);
    expect(itemInDb, isNull);
    // 加工済みファイルが生成されていないこと
    expect(fileStore.processedSaveCalls, 0);
  });
}

Future<void> _waitUntil(FutureOr<bool> Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!(await condition())) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out while waiting for asynchronous provider state.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _FakeImageProcessingService implements ImageProcessingService {
  _FakeImageProcessingService({
    this.waitForProcess = false,
    this.failFirstProcess = false,
  });

  final bool waitForProcess;
  final bool failFirstProcess;
  final Completer<void> processStarted = Completer<void>();
  final Completer<void> _processGate = Completer<void>();
  int processCalls = 0;
  String? lastTitle;

  @override
  Future<Uint8List> processImage({
    required String itemId,
    required Uint8List imageBytes,
    required String fileName,
    required String title,
    String outputType = 'sticker_png',
  }) async {
    processCalls += 1;
    lastTitle = title;
    if (!processStarted.isCompleted) {
      processStarted.complete();
    }
    if (waitForProcess) {
      await _processGate.future;
    }
    if (failFirstProcess && processCalls == 1) {
      throw const ImageServiceException('AI画像加工に失敗しました。');
    }
    return Uint8List.fromList(imageBytes);
  }

  void completeProcess() {
    if (!_processGate.isCompleted) {
      _processGate.complete();
    }
  }
}

class _FakeFileStore implements ItemFileStore {
  _FakeFileStore._(
    this.root, {
    this.forceError = false,
    Completer<void>? attachmentSaveGate,
  }) : _attachmentSaveGate = attachmentSaveGate;

  final Directory root;
  final bool forceError;
  final Completer<void>? _attachmentSaveGate;
  final Completer<void> attachmentSaveStarted = Completer<void>();
  int originalSaveCalls = 0;
  int processedSaveCalls = 0;

  static Future<_FakeFileStore> create({bool delayAttachment = false}) async {
    return _FakeFileStore._(
      await Directory.systemTemp.createTemp('dearme_provider_test_'),
      attachmentSaveGate: delayAttachment ? Completer<void>() : null,
    );
  }

  factory _FakeFileStore.withForcedError() {
    return _FakeFileStore._(Directory('/nonexistent/path'), forceError: true);
  }

  @override
  Future<String> saveOriginalImage({
    required String itemId,
    required XFile source,
  }) async {
    originalSaveCalls += 1;
    final file =
        File('${root.path}${Platform.pathSeparator}$itemId-original.png');
    await file.writeAsBytes(await source.readAsBytes());
    return file.path;
  }

  @override
  Future<String> saveProcessedImage({
    required String itemId,
    required Uint8List bytes,
  }) async {
    processedSaveCalls += 1;
    final file =
        File('${root.path}${Platform.pathSeparator}$itemId-processed.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<String> saveAttachment({
    required String itemId,
    required String mediaId,
    required XFile source,
  }) async {
    if (!attachmentSaveStarted.isCompleted) {
      attachmentSaveStarted.complete();
    }
    await _attachmentSaveGate?.future;
    final file = File('${root.path}${Platform.pathSeparator}$mediaId.bin');
    await file.writeAsBytes(await source.readAsBytes());
    return file.path;
  }

  void completeAttachmentSave() {
    final gate = _attachmentSaveGate;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }

  @override
  Future<void> deleteManagedFile(String path) async {
    if (forceError) throw const FileSystemException('Forced error');
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteItemDirectory(String itemId) async {
    if (forceError) throw const FileSystemException('Forced error');
    // フェイク実装では個別のファイルを削除する簡易的な対応とする
    final files = root.listSync().where((f) => f.path.contains(itemId));
    for (final file in files) {
      if (file is File) await file.delete();
    }
  }

  Future<void> close() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }
}

class _FakeItemRepository implements ItemRepository {
  final List<ItemModel> _items = [];
  final List<ItemMediaModel> _media = [];
  final List<AvatarModel> _avatars = [
    AvatarModel(
      id: 'girl1',
      displayName: 'あなた',
      createdAt: DateTime.utc(2024),
    ),
    AvatarModel(
      id: 'avatar-daughter',
      displayName: '娘',
      createdAt: DateTime.utc(2024),
    ),
  ];
  final Map<String, List<String>> _links = {};
  final Set<String> _roomObjectItemIds = {};
  int deleteItemCalls = 0;
  Duration? delaySave;
  bool failNextSave = false;

  final StreamController<List<ItemModel>> _itemChanges =
      StreamController<List<ItemModel>>.broadcast();
  final StreamController<List<ItemMediaModel>> _mediaChanges =
      StreamController<List<ItemMediaModel>>.broadcast();
  final StreamController<List<AvatarModel>> _avatarChanges =
      StreamController<List<AvatarModel>>.broadcast();
  final StreamController<Map<String, List<String>>> _linkChanges =
      StreamController<Map<String, List<String>>>.broadcast();

  bool hasLinksFor(String itemId) =>
      (_links[itemId]?.isNotEmpty ?? false) ||
      _media.any((m) => m.itemId == itemId) ||
      _roomObjectItemIds.contains(itemId);

  void simulateRoomObject(String itemId) => _roomObjectItemIds.add(itemId);

  @override
  Stream<List<ItemModel>> watchItems() async* {
    yield List.unmodifiable(_items);
    yield* _itemChanges.stream;
  }

  @override
  Stream<List<ItemMediaModel>> watchItemMedia() async* {
    yield List.unmodifiable(_media);
    yield* _mediaChanges.stream;
  }

  @override
  Stream<List<AvatarModel>> watchAvatars() async* {
    yield List.unmodifiable(_avatars);
    yield* _avatarChanges.stream;
  }

  @override
  Stream<Map<String, List<String>>> watchRelatedAvatarIds() async* {
    yield Map.unmodifiable(_links);
    yield* _linkChanges.stream;
  }

  @override
  Future<ItemModel?> getItem(String itemId) async {
    for (final item in _items) {
      if (item.id == itemId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> saveItem(ItemModel item) async {
    if (failNextSave) {
      failNextSave = false;
      throw StateError('Forced save failure');
    }
    if (delaySave != null) {
      await Future<void>.delayed(delaySave!);
    }
    final index = _items.indexWhere((current) => current.id == item.id);
    if (index == -1) {
      _items.insert(0, item);
    } else {
      _items[index] = item;
    }
    _itemChanges.add(List.unmodifiable(_items));
  }

  @override
  Future<void> saveMedia(ItemMediaModel media) async {
    _media.add(media);
    _mediaChanges.add(List.unmodifiable(_media));
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    _media.removeWhere((media) => media.mediaId == mediaId);
    _mediaChanges.add(List.unmodifiable(_media));
  }

  @override
  Future<void> setRelatedAvatar(String itemId, String? avatarId) async {
    _links[itemId] = avatarId == null ? [] : [avatarId];
    _linkChanges.add(Map.unmodifiable(_links));
  }

  @override
  Future<void> setRelatedAvatars(String itemId, List<String> avatarIds) async {
    _links[itemId] = List.from(avatarIds);
    _linkChanges.add(Map.unmodifiable(_links));
  }

  @override
  Future<void> deleteItem(String itemId) async {
    deleteItemCalls++;
    _items.removeWhere((item) => item.id == itemId);
    _itemChanges.add(List.unmodifiable(_items));
    // Simulate cascade delete
    _media.removeWhere((media) => media.itemId == itemId);
    _mediaChanges.add(List.unmodifiable(_media));
    _links.remove(itemId);
    _linkChanges.add(Map.unmodifiable(_links));
    _roomObjectItemIds.remove(itemId);
  }

  Future<void> close() async {
    await _itemChanges.close();
    await _mediaChanges.close();
    await _avatarChanges.close();
    await _linkChanges.close();
  }
}
