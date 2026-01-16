import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Manages application theming with persistence and system theme detection.
///
/// This provider handles:
/// - Color theme selection (Orange, Blue, Green)
/// - Theme mode (Light, Dark, System)
/// - Automatic system brightness change detection via [WidgetsBindingObserver]
/// - Persistence to SharedPreferences
///
/// ## Reactive Updates
/// When in system mode, the provider listens for platform brightness changes
/// and automatically rebuilds the UI when the OS theme toggles.
///
/// ## Usage
/// ```dart
/// final colors = context.watch<ThemeProvider>().colors;
/// final theme = context.watch<ThemeProvider>().themeData;
/// ```
class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'anchor_theme';
  static const String _themeModeKey = 'anchor_theme_mode';

  AnchorTheme _currentTheme = AnchorTheme.defaultOrange;
  AnchorThemeMode _themeMode = AnchorThemeMode.system;

  AnchorTheme get currentTheme => _currentTheme;
  AnchorThemeMode get themeMode => _themeMode;

  /// Check if currently in dark mode
  bool get isDarkMode {
    switch (_themeMode) {
      case AnchorThemeMode.light:
        return false;
      case AnchorThemeMode.dark:
        return true;
      case AnchorThemeMode.system:
        return SchedulerBinding
                .instance
                .platformDispatcher
                .platformBrightness ==
            Brightness.dark;
    }
  }

  AnchorColors get colors => AnchorColors(_currentTheme, isDark: isDarkMode);

  ThemeData get themeData =>
      buildAnchorTheme(_currentTheme, isDark: isDarkMode);

  /// Initialize theme from stored preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme =
        AnchorTheme.values[themeIndex.clamp(0, AnchorTheme.values.length - 1)];

    final modeIndex = prefs.getInt(_themeModeKey) ?? 2; // default to system
    _themeMode = AnchorThemeMode
        .values[modeIndex.clamp(0, AnchorThemeMode.values.length - 1)];

    // Register for platform brightness changes
    WidgetsBinding.instance.addObserver(this);

    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Only rebuild when in system mode
    if (_themeMode == AnchorThemeMode.system) {
      notifyListeners();
    }
  }

  /// Set new color theme and persist
  Future<void> setTheme(AnchorTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  /// Set theme mode (light/dark/system) and persist
  Future<void> setThemeMode(AnchorThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  /// Get display name for a color theme
  String getThemeName(AnchorTheme theme) {
    switch (theme) {
      case AnchorTheme.defaultOrange:
        return 'Default Orange';
      case AnchorTheme.oceanBlue:
        return 'Ocean Blue';
      case AnchorTheme.forestGreen:
        return 'Forest Green';
    }
  }

  /// Get display name for theme mode
  String getThemeModeName(AnchorThemeMode mode) {
    switch (mode) {
      case AnchorThemeMode.light:
        return 'Light';
      case AnchorThemeMode.dark:
        return 'Dark';
      case AnchorThemeMode.system:
        return 'System';
    }
  }
}
