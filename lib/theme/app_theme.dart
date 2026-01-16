import 'package:flutter/material.dart';

/// Available color themes for the Anchor app
enum AnchorTheme { defaultOrange, oceanBlue, forestGreen }

/// Theme mode (light/dark)
enum AnchorThemeMode { light, dark, system }

/// Theme-aware color definitions with dark mode support
class AnchorColors {
  final AnchorTheme theme;
  final bool isDark;

  const AnchorColors(this.theme, {this.isDark = false});

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
    if (isDark) {
      return primary.withValues(alpha: 0.15);
    }
    switch (theme) {
      case AnchorTheme.defaultOrange:
        return const Color(0xFFFFF4ED);
      case AnchorTheme.oceanBlue:
        return const Color(0xFFECFEFF);
      case AnchorTheme.forestGreen:
        return const Color(0xFFECFDF5);
    }
  }

  // Mode-aware colors
  Color get surface =>
      isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get surfaceVariant =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8);
  Color get background =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get textSecondary =>
      isDark ? const Color(0xFFB0B0B0) : const Color(0xFF848484);
  Color get iconInactive =>
      isDark ? const Color(0xFF808080) : const Color(0xFF848484);

  // Always dark (for nav pill)
  static const Color pillBackground = Color(0xFF1A1A1A);
  static const Color pillBackgroundLight = Color(0xFF2D2D2D);
}

/// Typography using bundled Manrope font
class AnchorTypography {
  static const String fontFamily = 'Manrope';

  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
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

/// Build ThemeData for the given AnchorTheme and brightness
ThemeData buildAnchorTheme(AnchorTheme theme, {bool isDark = false}) {
  final colors = AnchorColors(theme, isDark: isDark);
  final brightness = isDark ? Brightness.dark : Brightness.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: AnchorTypography.fontFamily,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            onPrimary: Colors.white,
            secondary: colors.primary,
            onSecondary: Colors.white,
            surface: colors.surface,
            onSurface: colors.textPrimary,
            error: const Color(0xFFEF4444),
            onError: Colors.white,
          )
        : ColorScheme.light(
            primary: colors.primary,
            onPrimary: Colors.white,
            secondary: colors.primary,
            onSecondary: Colors.white,
            surface: colors.surface,
            onSurface: colors.textPrimary,
            error: const Color(0xFFDC2626),
            onError: Colors.white,
          ),
    scaffoldBackgroundColor: colors.background,
    textTheme: AnchorTypography.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AnchorTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
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
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
