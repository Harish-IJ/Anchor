import 'package:hive/hive.dart';

part 'daily_summary.g.dart';

/// Aggregated daily statistics for efficient storage of old data
@HiveType(typeId: 3)
class DailySummary extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  int totalFocusSeconds;

  @HiveField(3)
  int totalBreakSeconds;

  @HiveField(4)
  int sessionsCompleted;

  @HiveField(5)
  int sessionsInterrupted;

  @HiveField(6)
  int sessionsSkipped;

  @HiveField(7)
  int longestSessionSeconds;

  @HiveField(8)
  Map<String, int> projectSeconds;

  DailySummary({
    required this.id,
    required this.date,
    this.totalFocusSeconds = 0,
    this.totalBreakSeconds = 0,
    this.sessionsCompleted = 0,
    this.sessionsInterrupted = 0,
    this.sessionsSkipped = 0,
    this.longestSessionSeconds = 0,
    Map<String, int>? projectSeconds,
  }) : projectSeconds = projectSeconds ?? {};

  /// Get date key for lookup (yyyy-MM-dd format)
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Total sessions count
  int get totalSessions =>
      sessionsCompleted + sessionsInterrupted + sessionsSkipped;

  /// Completion rate (0.0 to 1.0)
  double get completionRate =>
      totalSessions > 0 ? sessionsCompleted / totalSessions : 0.0;

  /// Total focus hours
  double get focusHours => totalFocusSeconds / 3600;

  @override
  String toString() =>
      'DailySummary($dateKey, ${focusHours.toStringAsFixed(1)}h)';
}
