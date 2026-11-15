import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, highContrast }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get themeMode => switch (this) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.highContrast => ThemeMode.light,
  };

  String get label => switch (this) {
    AppThemeMode.light => 'فاتح',
    AppThemeMode.dark => 'داكن',
    AppThemeMode.highContrast => 'تباين عالٍ',
  };
}

abstract final class AppTheme {
  static const Color _seed = Color(0xFF116466);

  static ThemeData get light => _base(ColorScheme.fromSeed(seedColor: _seed));

  static ThemeData get dark => _base(
    ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
  );

  static ThemeData get highContrast {
    const colors = ColorScheme.light(
      primary: Color(0xFF003C3D),
      onPrimary: Colors.white,
      secondary: Color(0xFF7A3E00),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Color(0xFF8B0000),
      onError: Colors.white,
    );

    return _base(colors).copyWith(
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: colors.onSurface,
        displayColor: colors.onSurface,
      ),
      inputDecorationTheme: _highContrastInputDecorationTheme(colors),
    );
  }

  static InputDecorationTheme _highContrastInputDecorationTheme(
    ColorScheme colors,
  ) {
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.onSurface, width: 2),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.onSurface, width: 3),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.error, width: 2),
    );
    final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colors.error, width: 3),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
      disabledBorder: enabledBorder,
    );
  }

  static ThemeData _base(ColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
