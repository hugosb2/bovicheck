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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(100),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(_cardRadius)),
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
