import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Provider for managing theme state with persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'anchor_theme';

  AnchorTheme _currentTheme = AnchorTheme.defaultOrange;

  AnchorTheme get currentTheme => _currentTheme;

  AnchorColors get colors => AnchorColors(_currentTheme);

  ThemeData get themeData => buildAnchorTheme(_currentTheme);

  /// Initialize theme from stored preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme =
        AnchorTheme.values[themeIndex.clamp(0, AnchorTheme.values.length - 1)];
    notifyListeners();
  }

  /// Set new theme and persist
  Future<void> setTheme(AnchorTheme theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  /// Get display name for a theme
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
}
