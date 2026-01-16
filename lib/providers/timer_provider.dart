import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/focus_session.dart';
import 'sessions_provider.dart';

/// Timer phases (simplified - no long break)
enum TimerPhase { focus, shortBreak }

/// Timer states
enum TimerState { idle, running, paused }

/// Provider for managing timer state
class TimerProvider extends ChangeNotifier {
  static const String _focusKey = 'timer_focus_minutes';
  static const String _breakKey = 'timer_break_minutes';

  // Configuration
  int _focusMinutes = 25;
  int _breakMinutes = 5;

  // State
  TimerPhase _phase = TimerPhase.focus;
  TimerState _state = TimerState.idle;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;

  // Optional project
  String? _projectId;

  // Sessions provider reference (set externally)
  SessionsProvider? _sessionsProvider;

  // Session tracking
  int _elapsedSecondsThisSession = 0;

  // Getters
  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  TimerPhase get phase => _phase;
  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _elapsedSecondsThisSession;
  String? get projectId => _projectId;

  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isIdle => _state == TimerState.idle;
  bool get isFocusPhase => _phase == TimerPhase.focus;

  int get totalSeconds {
    switch (_phase) {
      case TimerPhase.focus:
        return _focusMinutes * 60;
      case TimerPhase.shortBreak:
        return _breakMinutes * 60;
    }
  }

  String get phaseLabel {
    switch (_phase) {
      case TimerPhase.focus:
        return 'Focus';
      case TimerPhase.shortBreak:
        return 'Break';
    }
  }

  /// Set sessions provider reference
  void setSessionsProvider(SessionsProvider provider) {
    _sessionsProvider = provider;
  }

  /// Initialize from stored preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _focusMinutes = prefs.getInt(_focusKey) ?? 25;
    _breakMinutes = prefs.getInt(_breakKey) ?? 5;
    _remainingSeconds = _focusMinutes * 60;
    notifyListeners();
  }

  /// Update timer configuration
  Future<void> setDurations(int focus, int breakMins) async {
    _focusMinutes = focus;
    _breakMinutes = breakMins;

    // Reset timer if idle, or adjust remaining if running/paused
    if (_state == TimerState.idle) {
      _remainingSeconds = totalSeconds;
    } else {
      // Live update: Recalculate remaining seconds based on new total
      // Only meaningful if we are updating the current phase's duration
      // If we are in Focus, and update Focus, we adjust.
      // If we are in Focus, and update Break, no change to running timer.

      // We already updated _focusMinutes/_breakMinutes above.
      // So totalSeconds returns the NEW total.

      if ((_phase == TimerPhase.focus) || (_phase == TimerPhase.shortBreak)) {
        final newTotal = totalSeconds;
        _remainingSeconds = newTotal - _elapsedSecondsThisSession;
        if (_remainingSeconds < 0) _remainingSeconds = 0;

        // If updating active focus session, reset pause count
        if (_state != TimerState.idle && _phase == TimerPhase.focus) {
          _sessionsProvider?.resetPauseCount();
        }
      }
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusKey, focus);
    await prefs.setInt(_breakKey, breakMins);
  }

  /// Set project for session
  void setProjectId(String? id) {
    _projectId = id;
    notifyListeners();
  }

  /// Clear project
  void clearProject() {
    _projectId = null;
    notifyListeners();
  }

  /// Start or resume timer
  void start() {
    if (_state == TimerState.running) return;

    // Start new session if starting from idle
    if (_state == TimerState.idle) {
      _elapsedSecondsThisSession = 0;
      _sessionsProvider?.startSession(
        type: _phase == TimerPhase.focus
            ? SessionType.focus
            : SessionType.shortBreak,
        plannedDurationSeconds: totalSeconds,
        projectId: _projectId,
      );
    }

    _state = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      _elapsedSecondsThisSession++;
      if (_remainingSeconds <= 0) {
        _onTimerComplete();
      } else {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Pause timer
  void pause() {
    _timer?.cancel();
    _state = TimerState.paused;

    // Record pause (only for focus sessions)
    if (_phase == TimerPhase.focus) {
      _sessionsProvider?.recordPause();
    }

    notifyListeners();
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (isRunning) {
      pause();
    } else {
      start();
    }
  }

  /// Reset timer to beginning of current phase
  void reset() {
    _timer?.cancel();

    // If was running/paused, mark as interrupted
    if (_state != TimerState.idle && _elapsedSecondsThisSession > 0) {
      _sessionsProvider?.interruptSession(
        actualSeconds: _elapsedSecondsThisSession,
      );
    }

    _state = TimerState.idle;
    _remainingSeconds = totalSeconds;
    _elapsedSecondsThisSession = 0;
    notifyListeners();
  }

  /// Skip to next phase
  /// If [autoStart] is true, automatically start the next phase timer
  void skip({bool autoStart = false}) {
    _timer?.cancel();

    // Save current session as skipped if there was one
    if (_elapsedSecondsThisSession > 0) {
      _sessionsProvider?.skipSession();
    }

    // Simple flow: Focus -> Break -> Focus
    if (_phase == TimerPhase.focus) {
      _phase = TimerPhase.shortBreak;
    } else {
      _phase = TimerPhase.focus;
    }

    _remainingSeconds = totalSeconds;
    _elapsedSecondsThisSession = 0;

    if (autoStart) {
      // Start new session for the new phase
      _sessionsProvider?.startSession(
        type: _phase == TimerPhase.focus
            ? SessionType.focus
            : SessionType.shortBreak,
        plannedDurationSeconds: totalSeconds,
        projectId: _projectId,
      );

      _state = TimerState.running;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingSeconds <= 0) {
          _onTimerComplete();
        } else {
          _remainingSeconds--;
          _elapsedSecondsThisSession++;
          notifyListeners();
        }
      });
    } else {
      _state = TimerState.idle;
    }

    notifyListeners();
  }

  /// Called when timer reaches zero
  void _onTimerComplete() {
    _timer?.cancel();

    // Complete the session
    _sessionsProvider?.completeSession(actualSeconds: totalSeconds);

    _state = TimerState.idle;

    // Auto-switch to next phase
    if (_phase == TimerPhase.focus) {
      _phase = TimerPhase.shortBreak;
    } else {
      _phase = TimerPhase.focus;
    }

    _remainingSeconds = totalSeconds;
    _elapsedSecondsThisSession = 0;
    notifyListeners();
  }

  // Manual completion
  void completeSession() {
    _onTimerComplete();
  }

  /// Check if should suggest shorter timer (based on pause count)
  bool get shouldSuggestShorterTimer =>
      _sessionsProvider?.shouldSuggestShorterTimer() ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
