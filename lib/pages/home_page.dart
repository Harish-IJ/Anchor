import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/projects_provider.dart';
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
  bool _isSkipping = false;
  bool _wasRunningBeforeSkip = false;
  bool _shouldSkipAfterAnimation = false;
  NudgeItem _currentNudge = NudgeBox.getRandomNudge();

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
  }

  void _randomizeNudge() {
    setState(() {
      _currentNudge = NudgeBox.getRandomNudge();
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
    super.dispose();
  }

  void _showTimerSettings(BuildContext context, TimerProvider timer) {
    if (timer.isRunning) return;
    showTimerSettings(
      context: context,
      focusMinutes: timer.focusMinutes,
      breakMinutes: timer.breakMinutes,
      onSave: timer.setDurations,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section: Header
                      const GreetingHeader(userName: 'Riley'),

                      // Center section: Nudge + Timer
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Nudge box
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: NudgeBox(
                              nudge: _currentNudge,
                              onMusicTap: () {
                                // TODO: Future white noise feature
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
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
                        onTap: timer.isRunning
                            ? null
                            : () => _showTimerSettings(context, timer),
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
                        child: ProjectPill(
                          projectName: projectName,
                          onTap: timer.isRunning
                              ? null
                              : () => _showProjectPicker(context, timer),
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
                    onPlayPause: timer.togglePlayPause,
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
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _ExpandingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
