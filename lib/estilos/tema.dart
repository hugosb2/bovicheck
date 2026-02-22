import 'package:flutter/material.dart';

class TemaApp {
  static const double _raioBorda = 16.0;

  static ThemeData _construirTemaBase(ColorScheme esquemaCores) {
    final base = ThemeData(
      colorScheme: esquemaCores,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: esquemaCores.primary,
        foregroundColor: esquemaCores.onPrimary,
        iconTheme: IconThemeData(color: esquemaCores.onPrimary),
        titleTextStyle: TextStyle(
          color: esquemaCores.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: esquemaCores.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          side: BorderSide(
            color: esquemaCores.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
          borderSide: BorderSide(
            color: esquemaCores.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: TextStyle(
          color: esquemaCores.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: esquemaCores.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 2,
          shadowColor: esquemaCores.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_raioBorda),
        ),
        backgroundColor: esquemaCores.primaryContainer,
        foregroundColor: esquemaCores.onPrimaryContainer,
        elevation: 4,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      dividerTheme: DividerThemeData(
        color: esquemaCores.outlineVariant.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dialogTheme: base.dialogTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          color: esquemaCores.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: esquemaCores.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_raioBorda),
          ),
        ),
      ),
    );
  }

  static ThemeData criarTemaClaro(Color corSemente) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corSemente,
      brightness: Brightness.light,
    );
    return _construirTemaBase(esquema);
  }

  static ThemeData criarTemaEscuro(Color corSemente) {
    final esquema = ColorScheme.fromSeed(
      seedColor: corSemente,
      brightness: Brightness.dark,
    );
    return _construirTemaBase(esquema);
  }
}
