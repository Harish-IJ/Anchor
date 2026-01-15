import 'package:flutter/material.dart';

/// Available themes for the Anchor app
enum AnchorTheme { defaultOrange, oceanBlue, forestGreen }

/// Theme-aware color definitions
class AnchorColors {
  final AnchorTheme theme;

  const AnchorColors(this.theme);

  /// Primary accent color based on selected theme
  Color get primary {
    switch (theme) {
      case AnchorTheme.defaultOrange:
        return const Color(0xFFFF6712);
      case AnchorTheme.oceanBlue:
        return const Color(0xFF0891B2);
      case AnchorTheme.forestGreen:
        return const Color(0xFF059669);
    }
  }

  /// Lighter variant of primary for backgrounds
  Color get primaryLight {
    switch (theme) {
      case AnchorTheme.defaultOrange:
        return const Color(0xFFFFF4ED);
      case AnchorTheme.oceanBlue:
        return const Color(0xFFECFEFF);
      case AnchorTheme.forestGreen:
        return const Color(0xFFECFDF5);
    }
  }

  // Shared colors (same across all themes)
  static const Color pillBackground = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF848484);
  static const Color iconInactive = Color(0xFF848484);
}

/// Typography using bundled Manrope font
class AnchorTypography {
  static const String _fontFamily = 'Manrope';

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: _style(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      displayMedium: _style(fontSize: 45, fontWeight: FontWeight.w600),
      displaySmall: _style(fontSize: 36, fontWeight: FontWeight.w600),
      headlineLarge: _style(fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: _style(fontSize: 28, fontWeight: FontWeight.w500),
      headlineSmall: _style(fontSize: 24, fontWeight: FontWeight.w500),
      titleLarge: _style(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: _style(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: _style(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: _style(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: _style(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: _style(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: _style(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: _style(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: _style(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Build ThemeData for the given AnchorTheme
ThemeData buildAnchorTheme(AnchorTheme theme) {
  final colors = AnchorColors(theme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Manrope',
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.primary,
      onSecondary: Colors.white,
      surface: AnchorColors.surface,
      onSurface: AnchorColors.textPrimary,
      error: const Color(0xFFDC2626),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AnchorColors.background,
    textTheme: AnchorTypography.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AnchorColors.surface,
      foregroundColor: AnchorColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AnchorColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
