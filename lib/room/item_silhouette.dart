import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Grid resolution (cells on the longer side) used to sample an item photo's
/// alpha channel. Kept low on purpose: this only needs to capture a
/// recognizable, slightly blocky silhouette (per the "simple dome/bump"
/// design direction), not a precise vector outline, and keeps geometry/paint
/// cost negligible even with several items on screen at once.
const int kSilhouetteResolution = 32;

/// A coarse alpha-based silhouette of an item photo: which grid cells are
/// "inside" the cutout, and how deep inside each one is (0 = right at the
/// edge, 1 = the deepest interior point of this particular shape). It drives
/// the room's 3D puff geometry ([SilhouettePuffGeometry]); the swipe preview
/// deliberately renders the original image directly so its colors and alpha
/// are not altered by a synthetic lighting layer.
class SilhouetteField {
  final int gridWidth;
  final int gridHeight;
  final List<bool> inside;
  final List<double> distance;

  const SilhouetteField({
    required this.gridWidth,
    required this.gridHeight,
    required this.inside,
    required this.distance,
  });

  bool isInside(int x, int y) {
    if (x < 0 || y < 0 || x >= gridWidth || y >= gridHeight) return false;
    return inside[y * gridWidth + x];
  }

  double distanceAt(int x, int y) {
    if (x < 0 || y < 0 || x >= gridWidth || y >= gridHeight) return 0;
    return distance[y * gridWidth + x];
  }
}

/// Decodes [imageBytes] (typically the AI background-removal cutout PNG) at
/// a small [resolution] and builds a [SilhouetteField] from its alpha
/// channel. Images without real transparency (e.g. a fallback to the
/// original, unprocessed photo) naturally come out as a single fully-inside
/// rectangle, which degrades gracefully to a rounded blob shape downstream —
/// no special-casing needed.
Future<SilhouetteField> buildSilhouetteField({
  required Uint8List imageBytes,
  int resolution = kSilhouetteResolution,
}) async {
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: resolution,
  );
  try {
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final gridWidth = image.width;
      final gridHeight = image.height;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final inside = List<bool>.filled(gridWidth * gridHeight, false);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        const alphaThreshold = 20;
        for (var i = 0; i < gridWidth * gridHeight; i++) {
          inside[i] = bytes[i * 4 + 3] > alphaThreshold;
        }
      }
      final distance = _normalizedDistanceField(inside, gridWidth, gridHeight);
      return SilhouetteField(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        inside: inside,
        distance: distance,
      );
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

/// Two-pass chamfer distance transform: for every "inside" cell, the
/// approximate distance in grid units to the nearest outside cell,
/// normalized so the deepest point of this specific shape is 1.0. Cells
/// outside the mask are 0.
List<double> _normalizedDistanceField(
  List<bool> inside,
  int width,
  int height,
) {
  const inf = 1e9;
  const orthogonal = 1.0;
  const diagonal = 1.4142135623730951;
  final dist = List<double>.filled(width * height, inf);

  double at(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return 0;
    return dist[y * width + x];
  }

  for (var i = 0; i < width * height; i++) {
    dist[i] = inside[i] ? inf : 0;
  }

  // Forward pass (top-left to bottom-right).
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = y * width + x;
      if (dist[i] == 0) continue;
      var best = dist[i];
      best = math.min(best, at(x - 1, y) + orthogonal);
      best = math.min(best, at(x, y - 1) + orthogonal);
      best = math.min(best, at(x - 1, y - 1) + diagonal);
      best = math.min(best, at(x + 1, y - 1) + diagonal);
      dist[i] = best;
    }
  }

  // Backward pass (bottom-right to top-left).
  for (var y = height - 1; y >= 0; y--) {
    for (var x = width - 1; x >= 0; x--) {
      final i = y * width + x;
      if (dist[i] == 0) continue;
      var best = dist[i];
      best = math.min(best, at(x + 1, y) + orthogonal);
      best = math.min(best, at(x, y + 1) + orthogonal);
      best = math.min(best, at(x + 1, y + 1) + diagonal);
      best = math.min(best, at(x - 1, y + 1) + diagonal);
      dist[i] = best;
    }
  }

  var maxDist = 0.0;
  for (final d in dist) {
    if (d < inf && d > maxDist) maxDist = d;
  }
  if (maxDist <= 0) {
    return List<double>.filled(width * height, 0);
  }
  return [
    for (final d in dist) (d >= inf ? 0.0 : d / maxDist).clamp(0.0, 1.0),
  ];
}
