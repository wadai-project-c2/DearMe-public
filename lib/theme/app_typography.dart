import 'package:flutter/material.dart';

class AppTypography {
  static const String latinFontFamily = 'PilcrowRounded';
  static const List<String> fontFamilyFallback = ['NotoSansJP'];

  /// Materialの役割名をアプリ全体の文字仕様として使う。
  ///
  /// 画面側ではサイズを直接指定せず、原則として
  /// `Theme.of(context).textTheme` から用途に合う役割を選ぶ。
  static TextTheme get textTheme => TextTheme(
        displayLarge: _bold(57),
        displayMedium: _bold(45),
        displaySmall: _bold(36),
        headlineLarge: _bold(32),
        headlineMedium: _bold(28),
        headlineSmall: _bold(24),
        titleLarge: _bold(22),
        titleMedium: _bold(16),
        titleSmall: _bold(14),
        bodyLarge: _regular(16),
        bodyMedium: _regular(14),
        bodySmall: _regular(12),
        labelLarge: _bold(14),
        labelMedium: _regular(12),
        labelSmall: _regular(11),
      );

  static TextStyle _bold(double size) => TextStyle(
        fontFamily: latinFontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: FontWeight.w700,
      );

  static TextStyle _regular(double size) => TextStyle(
        fontFamily: latinFontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        fontWeight: FontWeight.w400,
      );
}
