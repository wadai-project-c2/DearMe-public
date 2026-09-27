import 'package:dearme/pages/item_detail_carousel_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial physical page selects processed image for every media count',
      () {
    for (var count = 1; count <= 5; count++) {
      final position = ItemDetailCarouselPosition(
        mediaKeys: List.generate(count, (index) => 'media-$index'),
        initialPage: count == 1 ? 0 : 1000,
      );
      expect(position.indexForPage(count == 1 ? 0 : 1000), 0);
    }
  });

  test('processed image stays selected when related media loads', () {
    final position = ItemDetailCarouselPosition(
      mediaKeys: const ['processed', 'original'],
      initialPage: 1000,
    );
    position.updateMediaKeys(
      const ['processed', 'original', 'related-1'],
      currentPage: 1000,
    );
    expect(position.indexForPage(1000), 0);
    expect(position.indexForPage(1001), 1);
  });

  test('user-selected media stays selected when the list changes', () {
    final position = ItemDetailCarouselPosition(
      mediaKeys: const ['processed', 'original', 'related-1'],
      initialPage: 1000,
    );
    expect(position.indexForPage(1002), 2);
    position.updateMediaKeys(
      const ['processed', 'original', 'related-1', 'related-2'],
      currentPage: 1002,
    );
    expect(position.indexForPage(1002), 2);
    expect(position.indexForPage(1003), 3);
  });

  test('removed selected media falls back to processed image', () {
    final position = ItemDetailCarouselPosition(
      mediaKeys: const ['processed', 'original', 'related-1'],
      initialPage: 1000,
    );
    position.updateMediaKeys(
      const ['processed', 'original'],
      currentPage: 1002,
    );
    expect(position.indexForPage(1002), 0);
  });

  test('infinite pages wrap in both directions', () {
    final position = ItemDetailCarouselPosition(
      mediaKeys: const ['processed', 'original', 'related-1'],
      initialPage: 1000,
    );
    expect(position.indexForPage(999), 2);
    expect(position.indexForPage(1000), 0);
    expect(position.indexForPage(1003), 0);
  });
}
