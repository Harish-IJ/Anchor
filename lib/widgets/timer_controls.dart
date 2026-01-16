import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../providers/timer_provider.dart';

/// Timer control buttons: Reset, Play/Pause, and Skip.
///
/// Displays three circular buttons for controlling the timer:
/// - **Reset**: Resets timer to beginning (with confirmation dialog)
/// - **Play/Pause**: Toggles timer running state
/// - **Skip**: Long-press to skip to next phase (with progress indicator)
///
/// ## Skip Gesture
/// The skip button uses a long-press gesture with visual progress
/// feedback to prevent accidental skips.
class TimerControls extends StatelessWidget {
  /// Whether the timer is currently running.
  final bool isRunning;

  /// Whether the timer is in idle state (not started).
  final bool isIdle;

  /// Whether the reset button should be enabled.
  final bool canReset;

  /// Callback for play/pause button press.
  final VoidCallback? onPlayPause;

  /// Callback for reset confirmation.
  final VoidCallback? onReset;

  /// Callback for skip tap (not long-press).
  final VoidCallback? onSkipTap;

  /// Callback when skip long-press starts.
  final VoidCallback? onSkipStart;

  /// Callback when skip long-press ends.
  final VoidCallback? onSkipEnd;

  /// Progress of skip long-press (0.0 to 1.0).
  final double skipProgress;

  const TimerControls({
    super.key,
    required this.isRunning,
    this.isIdle = true,
    this.canReset = true,
    this.onPlayPause,
    this.onReset,
    this.onSkipTap,
    this.onSkipStart,
    this.onSkipEnd,
    this.skipProgress = 0,
  });

  void _confirmReset(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Timer?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'This will reset the timer to the beginning.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReset?.call();
            },
            child: Text('Reset', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final timer = context.watch<TimerProvider>();
    final canResetEffective = canReset && onReset != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        _ControlButton(
          icon: Icons.refresh_rounded,
          onTap: canResetEffective ? () => _confirmReset(context) : null,
          color: colors.textSecondary,
          backgroundColor: colors.surfaceVariant,
        ),

        const SizedBox(width: 24),

        // Play/Pause button
        _ControlButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onTap: onPlayPause,
          color: isRunning ? colors.textSecondary : Colors.white,
          backgroundColor: isRunning ? colors.surfaceVariant : colors.primary,
          size: 64,
          iconSize: 32,
        ),

        const SizedBox(width: 24),

        // Skip button
        _SkipButton(
          isIdle: isIdle,
          onTap: onSkipTap,
          onLongPressStart: onSkipStart,
          onLongPressEnd: onSkipEnd,
          progress: skipProgress,
          fillColor: timer.isFocusPhase
              ? const Color(0xFF059669)
              : colors.primary,
          backgroundColor: colors.surfaceVariant,
          iconColor: colors.textSecondary,
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.color,
    required this.backgroundColor,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// Skip button - tap when idle, long-press when running
class _SkipButton extends StatelessWidget {
  final bool isIdle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final double progress;
  final Color fillColor;
  final Color backgroundColor;
  final Color iconColor;

  const _SkipButton({
    required this.isIdle,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.progress = 0,
    required this.fillColor,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isPressed = progress > 0;

    return GestureDetector(
      // Tap: works when idle (instant skip), or shows toast when running
      onTap: onTap,
      // Long press: only for when timer is running/paused
      onLongPressStart: isIdle ? null : (_) => onLongPressStart?.call(),
      onLongPressEnd: isIdle ? null : (_) => onLongPressEnd?.call(),
      onLongPressCancel: isIdle ? null : onLongPressEnd,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.skip_next_rounded,
          color: isPressed ? fillColor : iconColor,
          size: 24,
        ),
      ),
    );
  }
}
