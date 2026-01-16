import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// A circular timer ring with arc progress indicator.
///
/// Displays the remaining time as a countdown and shows progress
/// as a filled arc around the circle with an endpoint dot.
///
/// ## Visual Components
/// - Background track (subtle gray ring)
/// - Progress arc (themed primary color)
/// - Endpoint dot (indicates current position)
/// - Centered time display (MM:SS format)
class TimerRing extends StatelessWidget {
  /// Total duration of the timer phase in seconds.
  final int totalSeconds;

  /// Remaining seconds on the countdown.
  final int remainingSeconds;

  /// Whether the timer is currently running (affects animations).
  final bool isRunning;

  /// Optional tap handler for timer interaction.
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
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  String get timeDisplay {
    final safeSeconds = remainingSeconds < 0 ? 0 : remainingSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 360,
        height: 360,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Arc painter
            CustomPaint(
              size: const Size(340, 340),
              painter: _TimerArcPainter(
                progress: progress,
                primaryColor: colors.primary,
                trackColor: colors.textSecondary.withOpacity(0.2),
                strokeWidth: 18,
              ),
            ),

            // Time display (just the time, no label) - moved up slightly
            Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                timeDisplay,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  letterSpacing: 2,
                  fontSize: 52,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the arc-style timer
class _TimerArcPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final double strokeWidth;

  _TimerArcPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    this.strokeWidth = 14,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Arc angles: start from bottom-left, sweep to bottom-right (270 degrees)
    const startAngle = 135 * (math.pi / 180); // 135 degrees (bottom-left)
    const sweepAngle = 270 * (math.pi / 180); // 270 degrees sweep

    // Track paint (background arc)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Progress paint
    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw progress arc
    final progressSweep = sweepAngle * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // Draw endpoint dot
    if (progress > 0) {
      final dotAngle = startAngle + progressSweep;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      // Outer dot (white border)
      final dotOuterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 8, dotOuterPaint);

      // Inner dot (primary color)
      final dotInnerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
