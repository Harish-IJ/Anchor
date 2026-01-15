import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/project_pill.dart';
import '../widgets/timer_ring.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_settings_sheet.dart';

/// Home page with timer
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showTimerSettings(BuildContext context, TimerProvider timer) {
    showTimerSettings(
      context: context,
      focusMinutes: timer.focusMinutes,
      breakMinutes: timer.breakMinutes,
      longBreakMinutes: timer.longBreakMinutes,
      onSave: timer.setDurations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final timer = context.watch<TimerProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting header
            const GreetingHeader(userName: 'Riley'),

            // Project pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  ProjectPill(
                    projectName: timer.projectName,
                    onTap: () {
                      // TODO: Open project picker
                      if (timer.projectName == null) {
                        timer.setProject('My Project');
                      } else {
                        timer.setProject(null);
                      }
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Timer card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timer.phaseLabel == 'Focus'
                            ? 'Focus Progress'
                            : timer.phaseLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showTimerSettings(context, timer),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Timer ring
                  TimerRing(
                    totalSeconds: timer.totalSeconds,
                    remainingSeconds: timer.remainingSeconds,
                    isRunning: timer.isRunning,
                    onTap: () => _showTimerSettings(context, timer),
                  ),
                  const SizedBox(height: 16),

                  // Motivational text
                  Text(
                    timer.isRunning
                        ? 'Stay focused...'
                        : 'Tap to customize timer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Controls
                  TimerControls(
                    isRunning: timer.isRunning,
                    canReset:
                        !timer.isIdle ||
                        timer.remainingSeconds != timer.totalSeconds,
                    onPlayPause: timer.togglePlayPause,
                    onReset: timer.reset,
                    onSkip: timer.skip,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom padding for nav pill
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
