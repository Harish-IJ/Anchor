import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Getters
  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  TimerPhase get phase => _phase;
  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
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

    // Reset timer if idle
    if (_state == TimerState.idle) {
      _remainingSeconds = totalSeconds;
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

    _state = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _onTimerComplete();
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  /// Pause timer
  void pause() {
    _timer?.cancel();
    _state = TimerState.paused;
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
    _state = TimerState.idle;
    _remainingSeconds = totalSeconds;
    notifyListeners();
  }

  /// Skip to next phase
  /// If [autoStart] is true, automatically start the next phase timer
  void skip({bool autoStart = false}) {
    _timer?.cancel();

    // Simple flow: Focus -> Break -> Focus
    if (_phase == TimerPhase.focus) {
      _phase = TimerPhase.shortBreak;
    } else {
      _phase = TimerPhase.focus;
    }

    _remainingSeconds = totalSeconds;

    if (autoStart) {
      _state = TimerState.running;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remainingSeconds <= 0) {
          _onTimerComplete();
        } else {
          _remainingSeconds--;
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
    _state = TimerState.idle;

    // Auto-switch to next phase
    if (_phase == TimerPhase.focus) {
      _phase = TimerPhase.shortBreak;
    } else {
      _phase = TimerPhase.focus;
    }

    _remainingSeconds = totalSeconds;
    notifyListeners();

    // TODO: Play sound / vibrate / notification
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
