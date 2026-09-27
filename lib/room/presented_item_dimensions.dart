import 'dart:math' as math;

const double kPresentedItemMinAspectRatio = 0.4;
const double kPresentedItemMaxAspectRatio = 2.5;

/// Base margin used before applying the home display multiplier.
const double kPresentedItemCellFill = 0.85;

/// Increase the previous 2x visual baseline by 10%. Shared rendering and
/// support-height calculations stay aligned; gift occupancy remains one cell.
const double kPresentedItemDisplayMultiplier = 2.2;

class PresentedItemDimensions {
  final double width;
  final double height;

  const PresentedItemDimensions({required this.width, required this.height});
}

/// Returns dimensions that preserve the source aspect ratio while keeping the
/// longer side near 187% of the smallest grid edge (85% base × 2.2 display).
/// The visual dimensions are independent of the fixed one-cell occupancy.
PresentedItemDimensions presentedItemDimensions(
  double sourceAspectRatio, {
  required double cellSizeX,
  required double cellSizeY,
  required double cellSizeZ,
}) {
  assert(cellSizeX > 0);
  assert(cellSizeY > 0);
  assert(cellSizeZ > 0);

  final aspect = sourceAspectRatio
      .clamp(kPresentedItemMinAspectRatio, kPresentedItemMaxAspectRatio)
      .toDouble();
  final longestSide = math.min(cellSizeX, math.min(cellSizeY, cellSizeZ)) *
      kPresentedItemCellFill *
      kPresentedItemDisplayMultiplier;

  return aspect >= 1
      ? PresentedItemDimensions(
          width: longestSide,
          height: longestSide / aspect,
        )
      : PresentedItemDimensions(
          width: longestSide * aspect,
          height: longestSide,
        );
}
