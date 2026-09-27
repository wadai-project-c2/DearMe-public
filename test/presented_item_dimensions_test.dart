import 'package:dearme/room/presented_item_dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('presentedItemDimensions', () {
    const cellSizeX = 1.0;
    const cellSizeY = 0.8;
    const cellSizeZ = 0.6;
    const expectedLongestSide =
        cellSizeZ * kPresentedItemCellFill * kPresentedItemDisplayMultiplier;

    PresentedItemDimensions dimensions(double aspectRatio) =>
        presentedItemDimensions(
          aspectRatio,
          cellSizeX: cellSizeX,
          cellSizeY: cellSizeY,
          cellSizeZ: cellSizeZ,
        );

    test('applies the real_ios display multiplier to a square gift', () {
      final square = dimensions(1);

      expect(square.width, closeTo(expectedLongestSide, 1e-9));
      expect(square.height, closeTo(expectedLongestSide, 1e-9));
    });

    test('keeps source aspect ratio at the enlarged display size', () {
      final portrait = dimensions(0.5);
      final landscape = dimensions(2);

      expect(portrait.width / portrait.height, closeTo(0.5, 1e-9));
      expect(landscape.width / landscape.height, closeTo(2, 1e-9));
      expect(portrait.height, closeTo(expectedLongestSide, 1e-9));
      expect(landscape.width, closeTo(expectedLongestSide, 1e-9));
      expect(portrait.width, lessThanOrEqualTo(expectedLongestSide));
      expect(landscape.height, lessThanOrEqualTo(expectedLongestSide));
    });

    test('bounds pathological aspect ratios at a consistent long side', () {
      final veryTall = dimensions(0.01);
      final veryWide = dimensions(100);

      expect(
        veryTall.width / veryTall.height,
        closeTo(kPresentedItemMinAspectRatio, 1e-9),
      );
      expect(
        veryWide.width / veryWide.height,
        closeTo(kPresentedItemMaxAspectRatio, 1e-9),
      );
      expect(veryTall.height, closeTo(expectedLongestSide, 1e-9));
      expect(veryWide.width, closeTo(expectedLongestSide, 1e-9));
    });
  });
}
