import 'dart:typed_data';

import 'package:dearme/room/room_scene_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('snapshot store retains only the latest room image', () {
    final store = RoomSceneSnapshotStore.instance;
    addTearDown(store.clear);

    final first = Uint8List.fromList([1, 2, 3]);
    final latest = Uint8List.fromList([4, 5, 6]);

    store.update(first);
    store.update(latest);

    expect(store.pngBytes, same(latest));
    expect(store.pngBytes, isNot(same(first)));
  });

  test('snapshot controller captures only while attached', () async {
    final controller = HomeRoomSnapshotController();
    final bytes = Uint8List.fromList([7]);
    var captures = 0;

    controller.attach(() async {
      captures++;
      return bytes;
    });
    expect(await controller.capture(), same(bytes));

    controller.detach();
    expect(await controller.capture(), isNull);
    expect(captures, 1);
  });
}
