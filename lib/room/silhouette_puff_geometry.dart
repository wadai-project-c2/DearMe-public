import 'dart:math' as math;

import 'package:three_js/three_js.dart' as three;

import 'item_silhouette.dart';

/// A "puffy sticker" volume built directly from an item photo's alpha
/// silhouette, replacing the old fixed rounded-rectangle "puff card" shape
/// with one that follows the item's actual outline.
///
/// Both a front face (domed toward the camera) and a shallow back face are
/// height-mapped from the same [SilhouetteField.distance] data and taper to
/// zero exactly at the cutout's edge, so the two surfaces meet there with no
/// separate side-wall mesh needed. This grid-based approach (rather than
/// tracing a single outline contour and extruding it) handles concave or
/// multi-region shapes — e.g. a mug with a handle — without any special
/// topology handling.
class SilhouettePuffGeometry extends three.BufferGeometry {
  SilhouettePuffGeometry(
    SilhouetteField field,
    double width,
    double height, {
    double? frontDepth,
    double? backDepth,
  }) : super() {
    type = 'SilhouettePuffGeometry';

    final minSide = math.min(width, height);
    final resolvedFrontDepth = (frontDepth ?? minSide * 0.16).clamp(0.02, 0.14);
    final resolvedBackDepth =
        (backDepth ?? resolvedFrontDepth).clamp(0.02, 0.14);

    final gw = field.gridWidth;
    final gh = field.gridHeight;

    final xs = List<double>.generate(
      gw,
      (ix) => (gw > 1 ? ix / (gw - 1) - 0.5 : 0.0) * width,
    );
    final ys = List<double>.generate(
      gh,
      (iy) => (gh > 1 ? 0.5 - iy / (gh - 1) : 0.0) * height,
    );
    final us = List<double>.generate(gw, (ix) => gw > 1 ? ix / (gw - 1) : 0);
    final vs = List<double>.generate(gh, (iy) => gh > 1 ? iy / (gh - 1) : 0);

    double domeHeight(int ix, int iy, double depth) {
      if (ix == 0 || iy == 0 || ix == gw - 1 || iy == gh - 1) return 0;
      final d = field.distanceAt(ix, iy).clamp(0.0, 1.0);
      return depth * math.sin(d * math.pi / 2);
    }

    final positions = <double>[];
    final normals = <double>[];
    final uvs = <double>[];

    const frontBase = 0;
    for (var iy = 0; iy < gh; iy++) {
      for (var ix = 0; ix < gw; ix++) {
        positions.addAll(
          [xs[ix], ys[iy], domeHeight(ix, iy, resolvedFrontDepth)],
        );
        normals.addAll([0, 0, 1]);
        uvs.addAll([us[ix], vs[iy]]);
      }
    }
    final backBase = positions.length ~/ 3;
    for (var iy = 0; iy < gh; iy++) {
      for (var ix = 0; ix < gw; ix++) {
        positions.addAll(
          [xs[ix], ys[iy], -domeHeight(ix, iy, resolvedBackDepth)],
        );
        normals.addAll([0, 0, -1]);
        uvs.addAll([us[ix], vs[iy]]);
      }
    }

    bool quadIncluded(int ix, int iy) {
      return field.isInside(ix, iy) ||
          field.isInside(ix + 1, iy) ||
          field.isInside(ix, iy + 1) ||
          field.isInside(ix + 1, iy + 1);
    }

    final frontIndices = <int>[];
    final backIndices = <int>[];
    for (var iy = 0; iy < gh - 1; iy++) {
      for (var ix = 0; ix < gw - 1; ix++) {
        if (!quadIncluded(ix, iy)) continue;
        final a = iy * gw + ix;
        final b = iy * gw + ix + 1;
        final c = (iy + 1) * gw + ix + 1;
        final d = (iy + 1) * gw + ix;
        frontIndices.addAll([frontBase + a, frontBase + c, frontBase + b]);
        frontIndices.addAll([frontBase + a, frontBase + d, frontBase + c]);
        // Back face winding reversed so it faces -Z outward.
        backIndices.addAll([backBase + a, backBase + b, backBase + c]);
        backIndices.addAll([backBase + a, backBase + c, backBase + d]);
      }
    }

    // Degenerate silhouette (e.g. a fully-transparent or unreadable photo):
    // fall back to a single full-rect quad so the item is still visible
    // instead of an empty mesh.
    if (frontIndices.isEmpty) {
      for (var iy = 0; iy < gh - 1; iy++) {
        for (var ix = 0; ix < gw - 1; ix++) {
          final a = iy * gw + ix;
          final b = iy * gw + ix + 1;
          final c = (iy + 1) * gw + ix + 1;
          final d = (iy + 1) * gw + ix;
          frontIndices.addAll([frontBase + a, frontBase + c, frontBase + b]);
          frontIndices.addAll([frontBase + a, frontBase + d, frontBase + c]);
          backIndices.addAll([backBase + a, backBase + b, backBase + c]);
          backIndices.addAll([backBase + a, backBase + c, backBase + d]);
        }
      }
    }

    final indices = <int>[...frontIndices, ...backIndices];

    setIndex(indices);
    setAttributeFromString(
      'position',
      three.Float32BufferAttribute.fromList(positions, 3, false),
    );
    setAttributeFromString(
      'normal',
      three.Float32BufferAttribute.fromList(normals, 3, false),
    );
    setAttributeFromString(
      'uv',
      three.Float32BufferAttribute.fromList(uvs, 2, false),
    );

    // Smooth normals follow the dome, so lighting reveals its rounded volume.
    computeVertexNormals();
    // Both groups use the same photo, aligned to the same cutout silhouette.
    clearGroups();
    addGroup(0, frontIndices.length, 0);
    addGroup(frontIndices.length, backIndices.length, 1);
  }
}
