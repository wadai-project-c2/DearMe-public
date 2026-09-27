import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class ItemFileStore {
  Future<String> saveOriginalImage(
      {required String itemId, required XFile source});
  Future<String> saveProcessedImage(
      {required String itemId, required Uint8List bytes});
  Future<String> saveAttachment(
      {required String itemId, required String mediaId, required XFile source});
  Future<void> deleteManagedFile(String path);
  Future<void> deleteItemDirectory(String itemId);
}

class LocalFileService implements ItemFileStore {
  @override
  Future<String> saveOriginalImage(
      {required String itemId, required XFile source}) async {
    final itemDirectory = await _itemDirectory(itemId);
    final destination =
        File(p.join(itemDirectory.path, 'original${_safeExtension(source)}'));
    await destination.writeAsBytes(await source.readAsBytes(), flush: true);
    return destination.path;
  }

  @override
  Future<String> saveProcessedImage(
      {required String itemId, required Uint8List bytes}) async {
    final itemDirectory = await _itemDirectory(itemId);
    final destination = File(p.join(itemDirectory.path, 'processed.png'));
    await destination.writeAsBytes(bytes, flush: true);
    return destination.path;
  }

  @override
  Future<String> saveAttachment(
      {required String itemId,
      required String mediaId,
      required XFile source}) async {
    final itemDirectory = await _itemDirectory(itemId);
    final mediaDirectory = Directory(p.join(itemDirectory.path, 'media'));
    await mediaDirectory.create(recursive: true);
    final destination =
        File(p.join(mediaDirectory.path, '$mediaId${_safeExtension(source)}'));
    await destination.writeAsBytes(await source.readAsBytes(), flush: true);
    return destination.path;
  }

  @override
  Future<void> deleteManagedFile(String path) async {
    final root = await _managedRoot();
    final file = File(path).absolute;
    // アプリ管理外のファイルを誤って削除しないよう保存領域内だけを対象にする。
    if (!p.isWithin(root.path, file.path)) return;
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> deleteItemDirectory(String itemId) async {
    final root = await _managedRoot();
    final directory = Directory(p.join(root.path, 'items', itemId)).absolute;
    if (!p.isWithin(root.path, directory.path)) return;
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<String> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedImage = await imageFile
        .copy(p.join(directory.path, p.basename(imageFile.path)));
    return savedImage.path;
  }

  Future<Directory> _itemDirectory(String itemId) async {
    final root = await _managedRoot();
    final directory = Directory(p.join(root.path, 'items', itemId));
    await directory.create(recursive: true);
    return directory;
  }

  Future<Directory> _managedRoot() async {
    final documents = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(documents.path, 'dearme'));
    await root.create(recursive: true);
    return root.absolute;
  }

  String _safeExtension(XFile source) {
    final fromName = p.extension(source.name).toLowerCase();
    final fromPath = p.extension(source.path).toLowerCase();
    final extension = fromName.isNotEmpty ? fromName : fromPath;
    return RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension)
        ? extension
        : '.bin';
  }
}
