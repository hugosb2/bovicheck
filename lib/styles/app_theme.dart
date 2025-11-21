import 'package:bovicheck/styles/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const double _cardRadius = 12.0;
  static const double _inputRadius = 12.0;

  static ThemeData _buildBaseTheme(ColorScheme colorScheme) {
    final theme = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    return theme.copyWith(
      cardTheme: theme.cardTheme.copyWith(
        elevation: 1,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        elevation: 8,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(_cardRadius)),
        ),
        elevation: 8,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: theme.textTheme.copyWith(
        displayLarge: theme.textTheme.displayLarge?.copyWith(
          letterSpacing: -0.5,
        ),
        displayMedium: theme.textTheme.displayMedium?.copyWith(
          letterSpacing: -0.5,
        ),
        displaySmall: theme.textTheme.displaySmall?.copyWith(
          letterSpacing: -0.5,
        ),
        headlineLarge: theme.textTheme.headlineLarge?.copyWith(
          letterSpacing: -0.25,
        ),
        headlineMedium: theme.textTheme.headlineMedium?.copyWith(
          letterSpacing: -0.25,
        ),
        headlineSmall: theme.textTheme.headlineSmall?.copyWith(
          letterSpacing: 0,
        ),
      ),
    );
  }

  static ThemeData buildLightTheme(ColorScheme lightDynamic) {
    return _buildBaseTheme(lightDynamic);
  }

  static ThemeData buildDarkTheme(ColorScheme darkDynamic) {
    return _buildBaseTheme(darkDynamic);
  }

  static ThemeData buildLightThemeFromSeed(Color seed) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return _buildBaseTheme(colorScheme);
  }

  static ThemeData buildDarkThemeFromSeed(Color seed) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return _buildBaseTheme(colorScheme);
  }

  static Color get defaultColor => AppColors.defaultThemeColor;
}
