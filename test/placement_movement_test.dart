import 'package:flutter_test/flutter_test.dart';
import 'package:dearme/models/room_models.dart';
import 'package:dearme/room/placement_movement.dart';

void main() {
  test('left wall follows screen left and right', () {
    expect(placementMoveDelta(PlacementSurface.leftWall, x: 1, y: 0, z: 0),
        (x: 1, y: 0, z: 0));
    expect(placementMoveDelta(PlacementSurface.leftWall, x: -1, y: 0, z: 0),
        (x: -1, y: 0, z: 0));
  });

  test('right wall reverses world Z to follow screen left and right', () {
    expect(placementMoveDelta(PlacementSurface.rightWall, x: 1, y: 0, z: 0),
        (x: 0, y: 0, z: -1));
    expect(placementMoveDelta(PlacementSurface.rightWall, x: -1, y: 0, z: 0),
        (x: 0, y: 0, z: 1));
  });

  test('vertical wall movement stays unchanged', () {
    expect(placementMoveDelta(PlacementSurface.rightWall, x: 0, y: 0, z: 1),
        (x: 0, y: -1, z: 0));
  });
}
