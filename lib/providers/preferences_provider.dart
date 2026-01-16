import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User display preferences provider
class PreferencesProvider extends ChangeNotifier {
  static const String _use24HourKey = 'use_24_hour_format';
  static const String _weekStartsSundayKey = 'week_starts_sunday';

  bool _use24HourFormat = true; // Default: 24-hour
  bool _weekStartsSunday = true; // Default: Sunday

  bool get use24HourFormat => _use24HourFormat;
  bool get weekStartsSunday => _weekStartsSunday;

  /// Initialize from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _use24HourFormat = prefs.getBool(_use24HourKey) ?? true;
    _weekStartsSunday = prefs.getBool(_weekStartsSundayKey) ?? true;
    notifyListeners();
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
