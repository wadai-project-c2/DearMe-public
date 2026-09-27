import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xffdf758c),
      primary: const Color(0xffd95f79),
      secondary: const Color(0xff8fcfbe),
      surface: const Color(0xfffffbf7),
    );
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: const Color(0xff51494b),
      displayColor: const Color(0xff51494b),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.latinFontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xfffff8fb),
        foregroundColor: const Color(0xff5f5356),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: const Color(0xff5f5356),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xff8b8285),
        ),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: textTheme.labelLarge,
          enableFeedback: true,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          enableFeedback: true,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          enableFeedback: true,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          enableFeedback: true,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
      ),
      scaffoldBackgroundColor: const Color(0xfffffbf7),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xffdf758c),
        thumbColor: Color(0xffd95f79),
        inactiveTrackColor: Color(0xfff0d7dd),
      ),
    );
  }
}
