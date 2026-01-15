import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Timer control buttons: Reset, Play/Pause, Skip
class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool canReset;
  final VoidCallback? onPlayPause;
  final VoidCallback? onReset;
  final VoidCallback? onSkip;

  const TimerControls({
    super.key,
    required this.isRunning,
    this.canReset = true,
    this.onPlayPause,
    this.onReset,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        _ControlButton(
          icon: Icons.refresh_rounded,
          onTap: canReset ? onReset : null,
          color: colors.textSecondary,
          backgroundColor: colors.surfaceVariant,
        ),

        const SizedBox(width: 24),

        // Play/Pause button (primary)
        _ControlButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onTap: onPlayPause,
          color: Colors.white,
          backgroundColor: colors.primary,
          size: 64,
          iconSize: 32,
        ),

        const SizedBox(width: 24),

        // Skip button
        _ControlButton(
          icon: Icons.skip_next_rounded,
          onTap: onSkip,
          color: colors.textSecondary,
          backgroundColor: colors.surfaceVariant,
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
