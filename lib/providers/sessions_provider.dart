import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/focus_session.dart';

/// Provider for managing focus session data
class SessionsProvider extends ChangeNotifier {
  static const String _boxName = 'focus_sessions';
  Box<FocusSession>? _box;
  FocusSession? _currentSession;
  final _uuid = const Uuid();

  /// Current active session (if timer is running)
  FocusSession? get currentSession => _currentSession;

  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox<FocusSession>(_boxName);
  }

  /// Start a new focus session
  FocusSession startSession({
    required SessionType type,
    required int plannedDurationSeconds,
    String? projectId,
  }) {
    final session = FocusSession(
      id: _uuid.v4(),
      type: type,
      plannedDurationSeconds: plannedDurationSeconds,
      projectId: projectId,
      startedAt: DateTime.now(),
    );
    _currentSession = session;
    notifyListeners();
    return session;
  }

  /// Record a pause in current session
  void recordPause() {
    if (_currentSession != null) {
      _currentSession!.recordPause();
      notifyListeners();
    }
  }

  /// Complete current session
  Future<void> completeSession({required int actualSeconds}) async {
    if (_currentSession != null) {
      _currentSession!.complete(actualSeconds: actualSeconds);
      await _saveSession(_currentSession!);
      _currentSession = null;
      notifyListeners();
    }
  }

  /// Interrupt current session (reset while running)
  Future<void> interruptSession({required int actualSeconds}) async {
    if (_currentSession != null) {
      _currentSession!.interrupt(actualSeconds: actualSeconds);
      await _saveSession(_currentSession!);
      _currentSession = null;
      notifyListeners();
    }
  }

  /// Skip current session
  Future<void> skipSession() async {
    if (_currentSession != null) {
      _currentSession!.skip();
      await _saveSession(_currentSession!);
      _currentSession = null;
      notifyListeners();
    }
  }

  /// Abandon session without saving (e.g., app restart while idle)
  void abandonSession() {
    _currentSession = null;
    notifyListeners();
  }

  /// Save session to Hive
  Future<void> _saveSession(FocusSession session) async {
    await _box?.put(session.id, session);
  }

  /// Get all sessions
  List<FocusSession> getAllSessions() {
    return _box?.values.toList() ?? [];
  }

  /// Get sessions for today
  List<FocusSession> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return getAllSessions()
        .where((s) => s.startedAt.isAfter(startOfDay))
        .toList();
  }

  /// Get sessions for date range
  List<FocusSession> getSessionsInRange(DateTime start, DateTime end) {
    return getAllSessions()
        .where((s) => s.startedAt.isAfter(start) && s.startedAt.isBefore(end))
        .toList();
  }

  /// Get sessions for a specific hour in last N days (for project prediction)
  List<FocusSession> getSessionsAtHour(int hour, {int lastDays = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: lastDays));
    return getAllSessions()
        .where(
          (s) =>
              s.startedAt.isAfter(startDate) &&
              s.startedAt.hour == hour &&
              s.type == SessionType.focus,
        )
        .toList();
  }

  /// Get predicted project for current hour based on history
  String? getPredictedProject() {
    final hour = DateTime.now().hour;
    final sessions = getSessionsAtHour(hour);

    if (sessions.isEmpty) return null;

    // Count projects
    final projectCounts = <String, int>{};
    for (final session in sessions) {
      if (session.projectId != null) {
        projectCounts[session.projectId!] =
            (projectCounts[session.projectId!] ?? 0) + 1;
      }
    }

    if (projectCounts.isEmpty) return null;

    // Find most frequent
    String? topProject;
    int topCount = 0;
    projectCounts.forEach((projectId, count) {
      if (count > topCount) {
        topCount = count;
        topProject = projectId;
      }
    });

    // Only suggest if >60% confidence
    final confidence = topCount / sessions.length;
    return confidence > 0.6 ? topProject : null;
  }

  /// Get total focus time today (seconds)
  int getTodayFocusSeconds() {
    return getTodaySessions()
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .fold(0, (sum, s) => sum + s.actualDurationSeconds);
  }

  /// Get total break time today (seconds)
  int getTodayBreakSeconds() {
    return getTodaySessions()
        .where(
          (s) =>
              s.type == SessionType.shortBreak &&
              s.status == SessionStatus.completed,
        )
        .fold(0, (sum, s) => sum + s.actualDurationSeconds);
  }

  /// Get yesterday's focus time (seconds)
  int getYesterdayFocusSeconds() {
    final now = DateTime.now();
    final startOfYesterday = DateTime(now.year, now.month, now.day - 1);
    final endOfYesterday = DateTime(now.year, now.month, now.day);
    return getSessionsInRange(startOfYesterday, endOfYesterday)
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .fold(0, (sum, s) => sum + s.actualDurationSeconds);
  }

  /// Get longest session ever
  FocusSession? getLongestSession() {
    final sessions = getAllSessions()
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();
    if (sessions.isEmpty) return null;
    sessions.sort(
      (a, b) => b.actualDurationSeconds.compareTo(a.actualDurationSeconds),
    );
    return sessions.first;
  }

  /// Check if last session should trigger shorter timer suggestion
  bool shouldSuggestShorterTimer() {
    final sessions = getTodaySessions()
        .where((s) => s.type == SessionType.focus)
        .toList();
    if (sessions.isEmpty) return false;
    return sessions.last.shouldSuggestShorterTimer;
  }

  /// Generate test data for debugging charts (DEBUG ONLY)
  Future<void> generateTestData({List<String>? projectIds}) async {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch;

    // Use provided project IDs or default to null
    final ids = projectIds ?? <String?>[];
    final projectIdOptions = [null, ...ids];

    // Generate sessions for last 400 days (covers previous year for heatmap)
    for (int day = 0; day < 400; day++) {
      // Skip some days randomly (20% chance of empty day)
      if ((random + day * 3) % 5 == 0) continue;

      // 1-5 sessions per day (varying)
      final sessionsPerDay = 1 + (random + day) % 5;

      for (int s = 0; s < sessionsPerDay; s++) {
        // Random hour between 8am and 10pm
        final hour = 8 + ((random + day + s) % 14);
        final sessionDate = DateTime(
          now.year,
          now.month,
          now.day - day,
          hour,
          (random + s) % 60,
        );

        // Focus duration: 15-50 minutes
        final focusDuration = (15 + ((random + day + s) % 35)) * 60;

        // 80% completed, 15% interrupted, 5% skipped
        SessionStatus status;
        final statusRoll = (random + day + s) % 100;
        if (statusRoll < 80) {
          status = SessionStatus.completed;
        } else if (statusRoll < 95) {
          status = SessionStatus.interrupted;
        } else {
          status = SessionStatus.skipped;
        }

        final session = FocusSession(
          id: _uuid.v4(),
          type: SessionType.focus,
          plannedDurationSeconds: focusDuration,
          projectId:
              projectIdOptions[(random + day + s) % projectIdOptions.length],
          startedAt: sessionDate,
          createdAt: sessionDate,
        );

        if (status == SessionStatus.completed) {
          session.complete(actualSeconds: focusDuration);
        } else if (status == SessionStatus.interrupted) {
          session.interrupt(actualSeconds: focusDuration ~/ 2);
        } else {
          session.skip();
        }

        session.pauseCount = (random + s) % 4;

        await _box?.put(session.id, session);
      }

      // Add 1-2 break sessions per day
      final breakDate = DateTime(now.year, now.month, now.day - day, 12, 30);
      final breakSession = FocusSession(
        id: _uuid.v4(),
        type: SessionType.shortBreak,
        plannedDurationSeconds: 5 * 60,
        startedAt: breakDate,
        createdAt: breakDate,
      );
      breakSession.complete(actualSeconds: 5 * 60);
      await _box?.put(breakSession.id, breakSession);
    }

    notifyListeners();
  }

  /// Clear all session data (DEBUG ONLY)
  Future<void> clearAllData() async {
    await _box?.clear();
    notifyListeners();
  }
}
