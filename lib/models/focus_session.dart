import 'package:hive/hive.dart';

part 'focus_session.g.dart';

/// The type of timer session.
///
/// - [focus]: A focused work session (e.g., 25 minutes)
/// - [shortBreak]: A short break between focus sessions (e.g., 5 minutes)
@HiveType(typeId: 0)
enum SessionType {
  @HiveField(0)
  focus,

  @HiveField(1)
  shortBreak,
}

/// The outcome status of a completed session.
///
/// - [completed]: Session ran to full planned duration
/// - [interrupted]: Session was reset/stopped before completion
/// - [skipped]: Session was skipped to move to next phase
@HiveType(typeId: 1)
enum SessionStatus {
  @HiveField(0)
  completed,

  @HiveField(1)
  interrupted,

  @HiveField(2)
  skipped,
}

/// A persisted record of a focus or break session.
///
/// This model is stored in Hive and tracks all aspects of a session:
/// - Duration (planned vs actual)
/// - Timing (start/end timestamps)
/// - Status (completed, interrupted, skipped)
/// - Associated project (optional)
/// - Pause count (for nudge suggestions)
///
/// ## State Transitions
/// Sessions are created via [SessionsProvider.startSession] and finalized
/// via [complete], [interrupt], or [skip] methods.
@HiveType(typeId: 2)
class FocusSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? projectId;

  @HiveField(2)
  final SessionType type;

  @HiveField(3)
  SessionStatus status;

  @HiveField(4)
  final DateTime startedAt;

  @HiveField(5)
  DateTime? endedAt;

  @HiveField(6)
  final int plannedDurationSeconds;

  @HiveField(7)
  int actualDurationSeconds;

  @HiveField(8)
  int pauseCount;

  @HiveField(9)
  double completionPercentage;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  bool isDurationModified;

  FocusSession({
    required this.id,
    this.projectId,
    required this.type,
    this.status = SessionStatus.completed,
    required this.startedAt,
    this.endedAt,
    required this.plannedDurationSeconds,
    this.actualDurationSeconds = 0,
    this.pauseCount = 0,
    this.completionPercentage = 0.0,
    this.notes,
    this.isDurationModified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Mark session as completed
  void complete({required int actualSeconds}) {
    endedAt = DateTime.now();
    actualDurationSeconds = actualSeconds;
    final denominator = plannedDurationSeconds <= 0
        ? 1
        : plannedDurationSeconds;
    completionPercentage = (actualSeconds / denominator).clamp(
      0.0,
      double.infinity,
    );
    status = SessionStatus.completed;
  }

  /// Mark session as interrupted
  void interrupt({required int actualSeconds}) {
    endedAt = DateTime.now();
    actualDurationSeconds = actualSeconds;
    final denominator = plannedDurationSeconds <= 0
        ? 1
        : plannedDurationSeconds;
    completionPercentage = (actualSeconds / denominator).clamp(
      0.0,
      double.infinity,
    );
    status = SessionStatus.interrupted;
  }

  /// Mark session as skipped
  void skip() {
    endedAt = DateTime.now();
    status = SessionStatus.skipped;
  }

  /// Record a pause
  void recordPause() {
    pauseCount++;
  }

  /// Reset pause count (e.g. after timer adjustment)
  void resetPauseCount() {
    pauseCount = 0;
    isDurationModified = true;
  }

  /// Check if frequent pauses suggest shorter timer
  bool get shouldSuggestShorterTimer =>
      pauseCount >= 3 && type == SessionType.focus;

  @override
  String toString() =>
      'FocusSession($id, $type, $status, ${actualDurationSeconds}s)';
}
