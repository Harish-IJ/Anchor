import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Circular timer ring with progress indicator
class TimerRing extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final VoidCallback? onTap;

  const TimerRing({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.onTap,
  });

  double get progress {
    if (totalSeconds == 0) return 0;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  String get timeDisplay {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.08),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            SizedBox(
              width: 240,
              height: 240,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 10,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                  colors.textSecondary.withOpacity(0.15),
                ),
                strokeCap: StrokeCap.round,
              ),
            ),

            // Progress ring
            SizedBox(
              width: 240,
              height: 240,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
            ),

            // Time display
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeDisplay,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRunning ? 'Focus' : 'Start',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
