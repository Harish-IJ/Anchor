import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/projects_provider.dart';
import '../models/focus_session.dart';
import '../widgets/greeting_header.dart';
import '../widgets/project_pill.dart';
import '../widgets/timer_ring.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_settings_sheet.dart';
import '../widgets/project_picker_sheet.dart';
import '../widgets/nudge_box.dart';

/// Home page with timer
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _skipAnimationController;
  TimerProvider? _timerProvider;
  bool _isSkipping = false;
  bool _wasRunningBeforeSkip = false;
  bool _shouldSkipAfterAnimation = false;
  NudgeItem _currentNudge = CollapsibleNudgeBox.getRandomNudge();
  bool _isSuggestionDismissed = false;

  @override
  void initState() {
    super.initState();
    _skipAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _skipAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _shouldSkipAfterAnimation) {
        _performSkip();
      }
    });
    _skipAnimationController.addListener(() {
      if (_isSkipping &&
          _skipAnimationController.value >= 0.75 &&
          !_shouldSkipAfterAnimation) {
        _shouldSkipAfterAnimation = true;
      }
    });

    // Reset suggestion dismissal when timer state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _timerProvider = context.read<TimerProvider>();
        _timerProvider!.addListener(_onTimerChanged);
      }
    });
  }

  void _onTimerChanged() {
    if (!mounted || _timerProvider == null) return;
    // Reset dismissal if timer is no longer idle (session started)
    // capable of showing suggestions again next time we are idle
    if (!_timerProvider!.isIdle && _isSuggestionDismissed) {
      setState(() {
        _isSuggestionDismissed = false;
      });
    }
  }

  void _randomizeNudge() {
    setState(() {
      _currentNudge = CollapsibleNudgeBox.getRandomNudge();
    });
  }

  void _performSkip() {
    final timer = context.read<TimerProvider>();
    timer.skip(autoStart: _wasRunningBeforeSkip);
    _skipAnimationController.reset();
    setState(() {
      _isSkipping = false;
      _shouldSkipAfterAnimation = false;
    });
    _randomizeNudge();
  }

  @override
  void dispose() {
    _skipAnimationController.dispose();
    _timerProvider?.removeListener(_onTimerChanged);
    super.dispose();
  }

  Future<void> _showTimerSettings(
    BuildContext context,
    TimerProvider timer,
  ) async {
    // Calculate constraints based on current state
    int minFocus = 5;
    bool showMarkComplete = false;

    if (timer.phase == TimerPhase.focus &&
        (timer.isRunning || timer.isPaused)) {
      final elapsedMins = (timer.elapsedSeconds / 60).ceil();
      minFocus = elapsedMins > 5 ? elapsedMins : 5;

      // Allow marking as complete if > 50% done and total > 30 mins
      if (timer.focusMinutes > 30 &&
          timer.elapsedSeconds > (timer.focusMinutes * 30)) {
        showMarkComplete = true;
      }
    }

    await showTimerSettings(
      context: context,
      focusMinutes: timer.focusMinutes,
      breakMinutes: timer.breakMinutes,
      minFocusMinutes: minFocus,
      showMarkComplete: showMarkComplete,
      onSave: (focus, breakMins) {
        timer.setDurations(focus, breakMins);
      },
      onComplete: () {
        timer.completeSession();
        // Optional: show toast or feedback?
      },
    );
  }

  void _showProjectPicker(BuildContext context, TimerProvider timer) {
    if (timer.isRunning) return;
    showProjectPicker(
      context: context,
      currentProjectId: timer.projectId,
      onSelect: (project) => timer.setProjectId(project.id),
      onClear: timer.clearProject,
    );
  }

  void _onSkipStart(TimerProvider timer) {
    _wasRunningBeforeSkip = timer.isRunning;
    _shouldSkipAfterAnimation = false;
    setState(() => _isSkipping = true);
    _skipAnimationController.forward();
  }

  void _onSkipEnd() {
    if (_isSkipping) {
      if (_shouldSkipAfterAnimation) return;
      _skipAnimationController.reset();
      setState(() {
        _isSkipping = false;
        _shouldSkipAfterAnimation = false;
      });
    }
  }

  void _onSkipTap(TimerProvider timer) {
    if (timer.isIdle) {
      timer.skip(autoStart: false);
      _randomizeNudge();
    } else {
      final nextPhase = timer.isFocusPhase ? 'break' : 'focus';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Timer is running. Hold the button to go for a $nextPhase',
            style: const TextStyle(fontSize: 14),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final timer = context.watch<TimerProvider>();
    final projectsProvider = context.watch<ProjectsProvider>();

    final currentProject = projectsProvider.getProject(timer.projectId);
    final projectName = currentProject?.name;

    final skipCircleColor = timer.isFocusPhase
        ? const Color(0xFF059669)
        : colors.primary;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Soft accent gradient background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.35),
                    colors.primary.withValues(alpha: 0.05),
                    colors.background.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top section: Header
                          GreetingHeader(
                            userName:
                                context.watch<PreferencesProvider>().userName ??
                                'Friend',
                          ),

                          // Center section: Nudge + Timer
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              // Collapsible nudge box - slides to collapse after 10s
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    // access provider from parent context
                                    final sessionsProvider = context
                                        .watch<SessionsProvider>();
                                    // Check for volatile session (Smart Nudge)
                                    final currentSession =
                                        sessionsProvider.currentSession;
                                    NudgeItem? smartNudge;

                                    if (currentSession != null &&
                                        currentSession.type ==
                                            SessionType.focus &&
                                        currentSession.pauseCount >= 4 &&
                                        currentSession.pauseCount <= 12) {
                                      // Condition: Focus > 25m?
                                      // We check planned duration or elapsed? Usually planned.
                                      // Let's use plannedDurationSeconds.
                                      if (currentSession
                                              .plannedDurationSeconds >
                                          25 * 60) {
                                        smartNudge =
                                            NudgeCategories.shorterSession;
                                      } else {
                                        smartNudge = NudgeCategories.takeBreak;
                                      }
                                    }

                                    // Key logic:
                                    // If smart nudge active, key depends on pauseCount steps (every 2 pauses).
                                    // Triggers re-creation (and thus re-expansion) when step changes: 4, 6, 8...
                                    Key? nudgeKey;
                                    if (smartNudge != null) {
                                      final step =
                                          (currentSession!.pauseCount ~/ 2);
                                      nudgeKey = ValueKey('smart_nudge_$step');
                                    }

                                    return CollapsibleNudgeBox(
                                      key: nudgeKey,
                                      nudge: smartNudge ?? _currentNudge,
                                      onMusicTap: () {
                                        // TODO: Future white noise feature
                                      },
                                      onNudgeChange: _randomizeNudge,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Timer card
                              _buildTimerCard(
                                theme,
                                colors,
                                timer,
                                projectName,
                                skipCircleColor,
                              ),
                            ],
                          ),

                          // Bottom spacer for nav pill
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(
    ThemeData theme,
    dynamic colors,
    TimerProvider timer,
    String? projectName,
    Color skipCircleColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  // Subtle layered shadows for depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timer.phaseLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showTimerSettings(context, timer),
                        child: timer.isRunning
                            ? Icon(
                                timer.isFocusPhase
                                    ? Icons.bolt_rounded
                                    : Icons.coffee_rounded,
                                size: 24,
                                color: timer.isFocusPhase
                                    ? colors.primary
                                    : colors.textSecondary,
                              )
                            : Icon(
                                Icons.more_horiz_rounded,
                                size: 24,
                                color: colors.textSecondary,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Timer ring with project pill
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      TimerRing(
                        totalSeconds: timer.totalSeconds,
                        remainingSeconds: timer.remainingSeconds,
                        isRunning: timer.isRunning,
                        onTap: timer.isRunning
                            ? null
                            : () => _showTimerSettings(context, timer),
                      ),
                      Positioned(
                        bottom: 25,
                        child: Builder(
                          builder: (context) {
                            final sessionsProvider = context
                                .read<SessionsProvider>();
                            final projects = context.watch<ProjectsProvider>();

                            // Prediction Logic
                            String? displayProject = projectName;
                            bool isSuggested = false;

                            if (timer.isIdle &&
                                timer.isFocusPhase &&
                                timer.projectId == null &&
                                !_isSuggestionDismissed) {
                              final predictedId = sessionsProvider
                                  .getPredictedProject();
                              if (predictedId != null) {
                                final p = projects.getProject(predictedId);
                                if (p != null) {
                                  displayProject = p.name;
                                  isSuggested = true;
                                }
                              }
                            }

                            return ProjectPill(
                              projectName: displayProject,
                              isSuggested: isSuggested,
                              onClear: isSuggested
                                  ? () {
                                      setState(() {
                                        _isSuggestionDismissed = true;
                                      });
                                    }
                                  : null,
                              onTap: timer.isRunning
                                  ? null
                                  : () {
                                      if (isSuggested) {
                                        final predictedId = sessionsProvider
                                            .getPredictedProject();
                                        timer.setProjectId(predictedId);
                                      } else {
                                        _showProjectPicker(context, timer);
                                      }
                                    },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Controls
                  TimerControls(
                    isRunning: timer.isRunning,
                    isIdle: timer.isIdle,
                    canReset:
                        !timer.isIdle ||
                        timer.remainingSeconds != timer.totalSeconds,
                    onPlayPause: () {
                      if (timer.isIdle &&
                          timer.isFocusPhase &&
                          timer.projectId == null &&
                          !_isSuggestionDismissed) {
                        final sessionsProvider = context
                            .read<SessionsProvider>();
                        final predictedId = sessionsProvider
                            .getPredictedProject();
                        if (predictedId != null) {
                          timer.setProjectId(predictedId);
                        }
                      }
                      timer.togglePlayPause();
                    },
                    onReset: timer.reset,
                    onSkipTap: () => _onSkipTap(timer),
                    onSkipStart: () => _onSkipStart(timer),
                    onSkipEnd: _onSkipEnd,
                    skipProgress: _skipAnimationController.value,
                  ),
                ],
              ),
            ),

            // Growing circle overlay
            if (_isSkipping)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _skipAnimationController,
                  builder: (context, child) {
                    return IgnorePointer(
                      child: CustomPaint(
                        painter: _ExpandingCirclePainter(
                          progress: _skipAnimationController.value,
                          color: skipCircleColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Painter for expanding circle from skip button center
class _ExpandingCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ExpandingCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final centerX = size.width / 2 + 80;
    final centerY = size.height - 20 - 24;

    final center = Offset(centerX, centerY);
    final maxRadius = size.width * 1.8;
    final currentRadius = maxRadius * progress;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _ExpandingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
