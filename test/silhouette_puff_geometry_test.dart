import 'package:dearme/room/item_silhouette.dart';
import 'package:dearme/room/silhouette_puff_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'photo cutout has two rounded faces with outward normals and matching UVs',
      () {
    final field = SilhouetteField(
      gridWidth: 5,
      gridHeight: 5,
      inside: List.generate(
          25, (i) => i % 5 > 0 && i % 5 < 4 && i ~/ 5 > 0 && i ~/ 5 < 4),
      distance: List.generate(
          25,
          (i) => i == 12
              ? 1
              : (i % 5 > 0 && i % 5 < 4 && i ~/ 5 > 0 && i ~/ 5 < 4 ? 0.5 : 0)),
    );
    final geometry = SilhouettePuffGeometry(field, 1, 1);
    addTearDown(geometry.dispose);
    final p = geometry.getAttributeFromString('position');
    final n = geometry.getAttributeFromString('normal');
    final uv = geometry.getAttributeFromString('uv');
    expect(p.getZ(12), greaterThan(0));
    expect(p.getZ(37), closeTo(-p.getZ(12), 1e-6));
    expect(n.getZ(12), greaterThan(0));
    expect(n.getZ(37), lessThan(0));
    expect(n.getX(11).abs(), greaterThan(0.01));
    for (var i = 0; i < 25; i++) {
      expect(uv.getX(i), uv.getX(i + 25));
      expect(uv.getY(i), uv.getY(i + 25));
      if (i % 5 == 0 || i % 5 == 4 || i ~/ 5 == 0 || i ~/ 5 == 4) {
        expect(p.getZ(i), 0);
        expect(p.getZ(i + 25), 0);
      }
    }
  });
}
