import 'dart:math' as math;

import 'package:dearme/room/placement_rotation.dart';
import 'package:dearme/room/furniture_size_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gifts use 45 degrees in both directions', () {
    expect(placementRotationStep(isFurniture: false), math.pi / 4);
    for (final direction in [-1, 1]) {
      expect(snapPlacementRotation(direction * 0.8, isFurniture: false),
          closeTo(direction * math.pi / 4, 1e-9));
    }
  });
  test('furniture also uses 45 degree steps', () {
    expect(placementRotationStep(isFurniture: true), math.pi / 4);
    expect(snapPlacementRotation(0.8, isFurniture: true), math.pi / 4);
  });
  test('diagonal furniture footprint covers corners and preserves right angles',
      () {
    final straight = FurnitureSizeSpecs.rotatedSpan('table', 1, 0);
    final quarter = FurnitureSizeSpecs.rotatedSpan('table', 1, math.pi / 2);
    final diagonal = FurnitureSizeSpecs.rotatedSpan('table', 1, math.pi / 4);
    expect(quarter.spanX, straight.spanZ);
    expect(quarter.spanZ, straight.spanX);
    final extent = ((straight.spanX + straight.spanZ) / math.sqrt(2)).ceil();
    expect(diagonal.spanX, extent);
    expect(diagonal.spanZ, extent);
  });
  test('eight gift steps make a full turn without drift', () {
    var angle = 0.0;
    for (var i = 0; i < 8; i++) {
      angle = snapPlacementRotation(angle + math.pi / 4, isFurniture: false);
    }
    expect(angle, closeTo(math.pi * 2, 1e-9));
  });
}
