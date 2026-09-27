class ItemDetailCarouselPosition {
  List<String> _mediaKeys;
  int _originPage;

  ItemDetailCarouselPosition({
    required List<String> mediaKeys,
    required int initialPage,
  })  : _mediaKeys = List.unmodifiable(mediaKeys),
        _originPage = initialPage;

  int indexForPage(int page) {
    if (_mediaKeys.isEmpty) return 0;
    return ((page - _originPage) % _mediaKeys.length + _mediaKeys.length) %
        _mediaKeys.length;
  }

  void updateMediaKeys(List<String> nextKeys, {required int currentPage}) {
    if (_sameKeys(_mediaKeys, nextKeys)) return;
    final selectedKey =
        _mediaKeys.isEmpty ? null : _mediaKeys[indexForPage(currentPage)];
    final selectedIndex =
        selectedKey == null ? -1 : nextKeys.indexOf(selectedKey);
    _originPage = currentPage - (selectedIndex < 0 ? 0 : selectedIndex);
    _mediaKeys = List.unmodifiable(nextKeys);
  }

  static bool _sameKeys(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
