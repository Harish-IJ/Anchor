import 'package:hive/hive.dart';

part 'focus_session.g.dart';

/// Type of timer session
@HiveType(typeId: 0)
enum SessionType {
  @HiveField(0)
  focus,

  @HiveField(1)
  shortBreak,
}

/// Status of a completed session
@HiveType(typeId: 1)
enum SessionStatus {
  @HiveField(0)
  completed,

  @HiveField(1)
  interrupted,

  @HiveField(2)
  skipped,
}

/// A focus or break session record
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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Mark session as completed
  void complete({required int actualSeconds}) {
    endedAt = DateTime.now();
    actualDurationSeconds = actualSeconds;
    completionPercentage = actualSeconds / plannedDurationSeconds;
    status = SessionStatus.completed;
  }

  /// Mark session as interrupted
  void interrupt({required int actualSeconds}) {
    endedAt = DateTime.now();
    actualDurationSeconds = actualSeconds;
    completionPercentage = actualSeconds / plannedDurationSeconds;
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

  /// Check if frequent pauses suggest shorter timer
  bool get shouldSuggestShorterTimer =>
      pauseCount >= 3 && type == SessionType.focus;

  @override
  String toString() =>
      'FocusSession($id, $type, $status, ${actualDurationSeconds}s)';
}
