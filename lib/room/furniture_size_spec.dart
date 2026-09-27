import 'dart:math' as math;

class FurnitureSizeStage {
  final String label;
  final double scale;
  final int spanX;
  final int spanZ;

  const FurnitureSizeStage({
    required this.label,
    required this.scale,
    required this.spanX,
    required this.spanZ,
  });
}

abstract final class FurnitureSizeSpecs {
  static const _stages = <String, List<FurnitureSizeStage>>{
    'table': [
      FurnitureSizeStage(label: '小', scale: 0.4125, spanX: 3, spanZ: 1),
      FurnitureSizeStage(label: '標準', scale: 0.55, spanX: 4, spanZ: 2),
      FurnitureSizeStage(label: '大', scale: 0.6875, spanX: 4, spanZ: 2),
    ],
    'sofa': [
      FurnitureSizeStage(label: '小', scale: 0.546, spanX: 2, spanZ: 1),
      FurnitureSizeStage(label: '標準', scale: 0.728, spanX: 3, spanZ: 2),
      FurnitureSizeStage(label: '大', scale: 0.91, spanX: 4, spanZ: 3),
    ],
    'metal_chair': [
      FurnitureSizeStage(label: '小', scale: 0.714, spanX: 1, spanZ: 1),
      FurnitureSizeStage(label: '標準', scale: 0.952, spanX: 2, spanZ: 2),
      FurnitureSizeStage(label: '大', scale: 1.19, spanX: 3, spanZ: 3),
    ],
    'cloud_rug': [
      FurnitureSizeStage(label: '小', scale: 0.75, spanX: 6, spanZ: 4),
      FurnitureSizeStage(label: '標準', scale: 1, spanX: 7, spanZ: 5),
      FurnitureSizeStage(label: '大', scale: 1.25, spanX: 9, spanZ: 6),
    ],
    'wall_clock': [
      FurnitureSizeStage(label: '小', scale: 0.75, spanX: 1, spanZ: 1),
      FurnitureSizeStage(label: '標準', scale: 1, spanX: 2, spanZ: 2),
      FurnitureSizeStage(label: '大', scale: 1.25, spanX: 3, spanZ: 3),
    ],
  };

  static List<FurnitureSizeStage> stagesFor(String? assetKey) =>
      assetKey?.startsWith('window_') == true
          ? const [
              FurnitureSizeStage(label: '小', scale: 0.75, spanX: 2, spanZ: 2),
              FurnitureSizeStage(label: '標準', scale: 1, spanX: 3, spanZ: 3),
              FurnitureSizeStage(label: '大', scale: 1.25, spanX: 3, spanZ: 3),
            ]
          : _stages[assetKey] ?? const [];

  static FurnitureSizeStage? nearest(String? assetKey, double scale) {
    final stages = stagesFor(assetKey);
    if (stages.isEmpty) return null;
    return stages.reduce(
      (best, candidate) =>
          (candidate.scale - scale).abs() < (best.scale - scale).abs()
              ? candidate
              : best,
    );
  }

  static FurnitureSizeStage? step(
    String? assetKey,
    double currentScale,
    int direction,
  ) {
    final stages = stagesFor(assetKey);
    if (stages.isEmpty) return null;
    final current = nearest(assetKey, currentScale)!;
    final index = stages.indexOf(current);
    return stages[(index + direction).clamp(0, stages.length - 1)];
  }

  static ({int spanX, int spanZ}) rotatedSpan(
    String? assetKey,
    double scale,
    double rotationY,
  ) {
    final stage = nearest(assetKey, scale);
    if (stage == null) return (spanX: 1, spanZ: 1);
    // Conservatively cover the rotated rectangle, including diagonal corners.
    // Subtract floating point noise so exact quarter turns keep existing spans.
    final c = math.cos(rotationY).abs();
    final s = math.sin(rotationY).abs();
    return (
      spanX: (stage.spanX * c + stage.spanZ * s - 1e-9).ceil(),
      spanZ: (stage.spanX * s + stage.spanZ * c - 1e-9).ceil(),
    );
  }
}
