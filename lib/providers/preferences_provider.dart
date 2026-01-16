import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user display preferences and onboarding state.
///
/// This provider handles:
/// - Time format preference (12-hour vs 24-hour display)
/// - Week start day preference (Sunday vs Monday)
/// - User name storage (from onboarding)
/// - Onboarding completion tracking
///
/// ## Persistence
/// All preferences are stored in SharedPreferences and loaded via `init()`.
///
/// ## Usage
/// ```dart
/// final prefs = context.watch<PreferencesProvider>();
/// prefs.formatHour(14); // Returns "14:00" or "2PM" based on setting
/// ```
class PreferencesProvider extends ChangeNotifier {
  static const String _use24HourKey = 'use_24_hour_format';
  static const String _weekStartsSundayKey = 'week_starts_sunday';
  static const String _userNameKey = 'user_name';
  static const String _onboardingKey = 'onboarding_completed';

  bool _use24HourFormat = true; // Default: 24-hour
  bool _weekStartsSunday = true; // Default: Sunday
  String? _userName;
  bool _isOnboardingCompleted = false;

  bool get use24HourFormat => _use24HourFormat;
  bool get weekStartsSunday => _weekStartsSunday;
  String? get userName => _userName;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _use24HourFormat = prefs.getBool(_use24HourKey) ?? true;
    _weekStartsSunday = prefs.getBool(_weekStartsSundayKey) ?? true;
    _userName = prefs.getString(_userNameKey);
    _isOnboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
    notifyListeners();
  }

  /// Set user name and complete onboarding
  Future<void> setUserName(String name) async {
    _userName = name;
    _isOnboardingCompleted = true; // Implicitly complete onboarding
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setBool(_onboardingKey, true);
  }

  /// Toggle 12/24 hour format
  Future<void> setUse24HourFormat(bool value) async {
    _use24HourFormat = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_use24HourKey, value);
  }

  /// Toggle week start day
  Future<void> setWeekStartsSunday(bool value) async {
    _weekStartsSunday = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weekStartsSundayKey, value);
  }

  /// Format hour for display based on preference
  String formatHour(int hour) {
    if (_use24HourFormat) {
      return '${hour.toString().padLeft(2, '0')}:00';
    } else {
      final h = hour % 12;
      final suffix = hour < 12 ? 'AM' : 'PM';
      return '${h == 0 ? 12 : h}$suffix';
    }
  }

  /// Get weekday labels based on preference
  List<String> get weekdayLabels {
    if (_weekStartsSunday) {
      return ['Sun', '', 'Tue', '', 'Thu', '', 'Sat'];
    } else {
      return ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'];
    }
  }

  /// Get weekday index offset for heatmap calculation
  /// Returns 0 for Sunday-start, 1 for Monday-start
  int get weekdayOffset => _weekStartsSunday ? 0 : 1;
}
