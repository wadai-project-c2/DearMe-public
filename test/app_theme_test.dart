import 'package:dearme/theme/app_theme.dart';
import 'package:dearme/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('text roles use the shared Latin and Japanese font families', () {
    final theme = AppTheme.lightTheme;

    for (final style in [
      theme.textTheme.headlineSmall,
      theme.textTheme.titleLarge,
      theme.textTheme.titleMedium,
      theme.textTheme.bodyMedium,
      theme.textTheme.labelLarge,
    ]) {
      expect(style?.fontFamily, AppTypography.latinFontFamily);
      expect(style?.fontFamilyFallback, AppTypography.fontFamilyFallback);
    }
  });

  test('component typography points to the matching text role', () {
    final theme = AppTheme.lightTheme;

    expect(theme.appBarTheme.titleTextStyle?.fontSize,
        theme.textTheme.titleLarge?.fontSize);
    expect(theme.dialogTheme.titleTextStyle?.fontSize,
        theme.textTheme.titleLarge?.fontSize);
    expect(theme.dialogTheme.contentTextStyle?.fontSize,
        theme.textTheme.bodyMedium?.fontSize);
    expect(theme.snackBarTheme.contentTextStyle?.fontSize,
        theme.textTheme.bodyMedium?.fontSize);
    expect(
      theme.filledButtonTheme.style?.textStyle?.resolve({})?.fontWeight,
      theme.textTheme.labelLarge?.fontWeight,
    );
  });
}
