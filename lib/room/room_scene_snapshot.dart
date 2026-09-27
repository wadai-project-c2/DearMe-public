import 'package:flutter/foundation.dart';

/// Keeps the latest avatar-free image of the home room in memory.
///
/// The registration flow uses this image instead of mounting a second
/// [RoomSceneWidget]. This prevents two GL renderers from competing while a
/// present is placed and its standalone joy animation is shown.
class RoomSceneSnapshotStore extends ChangeNotifier {
  RoomSceneSnapshotStore._();

  static final RoomSceneSnapshotStore instance = RoomSceneSnapshotStore._();

  Uint8List? _pngBytes;

  Uint8List? get pngBytes => _pngBytes;

  void update(Uint8List bytes) {
    _pngBytes = bytes;
    notifyListeners();
  }

  @visibleForTesting
  void clear() {
    _pngBytes = null;
    notifyListeners();
  }
}

/// Allows the shell to capture Home immediately before leaving it.
class HomeRoomSnapshotController {
  Future<Uint8List?> Function()? _capture;

  Future<Uint8List?> capture() async => _capture?.call();

  void attach(Future<Uint8List?> Function() capture) {
    _capture = capture;
  }

  void detach() {
    _capture = null;
  }
}
