import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// TODO: Add your custom nudge messages and icons for each category
/// Categories are based on % completion of focus session:
/// - Start (0-25%): Motivational kick-off messages
/// - Middle (25-50%): Keep going encouragement
/// - AlmostThere (50-75%): You're getting close
/// - End (75-100%): Final push, almost done

class NudgeItem {
  final IconData icon;
  final String text;
  const NudgeItem({required this.icon, required this.text});
}

/// Nudge categories based on focus session progress
class NudgeCategories {
  /// Start of session (0-25% complete)
  /// TODO: Add your custom start nudges
  static const List<NudgeItem> start = [
    NudgeItem(icon: Icons.bolt_rounded, text: "Let's do this!"),
    NudgeItem(
      icon: Icons.local_fire_department_rounded,
      text: "You're on fire today!",
    ),
    NudgeItem(icon: Icons.rocket_launch_rounded, text: "Focus mode: activated"),
  ];

  /// Middle of session (25-50% complete)
  /// TODO: Add your custom middle nudges
  static const List<NudgeItem> middle = [
    NudgeItem(icon: Icons.thumb_up_rounded, text: "Great progress!"),
    NudgeItem(icon: Icons.spa_rounded, text: "Stay in the zone"),
    NudgeItem(icon: Icons.trending_up_rounded, text: "You're doing great!"),
  ];

  /// Almost there (50-75% complete)
  /// TODO: Add your custom almost-there nudges
  static const List<NudgeItem> almostThere = [
    NudgeItem(icon: Icons.timer_rounded, text: "Halfway there!"),
    NudgeItem(icon: Icons.water_drop_rounded, text: "Quick sip, keep going"),
    NudgeItem(icon: Icons.self_improvement_rounded, text: "You got this!"),
  ];

  /// End of session (75-100% complete)
  /// TODO: Add your custom end nudges
  static const List<NudgeItem> end = [
    NudgeItem(icon: Icons.star_rounded, text: "Almost done!"),
    NudgeItem(icon: Icons.celebration_rounded, text: "Final stretch! 🎉"),
    NudgeItem(icon: Icons.emoji_events_rounded, text: "Victory is near!"),
  ];

  /// Break time nudges
  /// TODO: Add your custom break nudges
  static const List<NudgeItem> breakTime = [
    NudgeItem(icon: Icons.coffee_rounded, text: "Time for a break ☕"),
    NudgeItem(icon: Icons.spa_rounded, text: "Take a deep breath"),
    NudgeItem(icon: Icons.directions_walk_rounded, text: "Stretch your legs"),
  ];

  /// Suggested: Try shorter sessions (Focus > 25m, Pauses >= 4)
  static const NudgeItem shorterSession = NudgeItem(
    icon: Icons.timelapse_rounded,
    text: "Session seems volatile. Try 25m?",
  );

  /// Suggested: Take a break (Pauses >= 4)
  static const NudgeItem takeBreak = NudgeItem(
    icon: Icons.free_breakfast_rounded,
    text: "Feeling distracted? Take a break.",
  );

  /// Get nudge based on completion percentage (0.0 - 1.0)
  static NudgeItem getNudgeForProgress(
    double progress, {
    bool isBreak = false,
  }) {
    if (isBreak) {
      return _getRandomFrom(breakTime);
    }

    if (progress < 0.25) {
      return _getRandomFrom(start);
    } else if (progress < 0.50) {
      return _getRandomFrom(middle);
    } else if (progress < 0.75) {
      return _getRandomFrom(almostThere);
    } else {
      return _getRandomFrom(end);
    }
  }

  static NudgeItem _getRandomFrom(List<NudgeItem> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }
}

/// Legacy: All nudges for random selection (used by CollapsibleNudgeBox.getRandomNudge)
const List<NudgeItem> nudgeItems = [
  ...NudgeCategories.start,
  ...NudgeCategories.middle,
  ...NudgeCategories.almostThere,
  ...NudgeCategories.end,
];

/// Custom cubic bezier curve for After Effects style easing
class AEEaseInOut extends Curve {
  @override
  double transformInternal(double t) {
    // Similar to After Effects ease in/out (cubic bezier ~0.42, 0, 0.58, 1)
    return t * t * (3.0 - 2.0 * t);
  }
}

/// Collapsible nudge box with sliding animation
class CollapsibleNudgeBox extends StatefulWidget {
  final NudgeItem nudge;
  final VoidCallback? onMusicTap;
  final VoidCallback? onNudgeChange;

  const CollapsibleNudgeBox({
    super.key,
    required this.nudge,
    this.onMusicTap,
    this.onNudgeChange,
  });

  static NudgeItem getRandomNudge() {
    final random = Random();
    return nudgeItems[random.nextInt(nudgeItems.length)];
  }

  @override
  State<CollapsibleNudgeBox> createState() => CollapsibleNudgeBoxState();
}

class CollapsibleNudgeBoxState extends State<CollapsibleNudgeBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  Timer? _autoHideTimer;
  Timer? _periodicNudgeTimer;
  bool _isExpanded = true;

  // Animation durations
  static const Duration _fastDuration = Duration(
    milliseconds: 400,
  ); // User tap - smooth
  static const Duration _slowDuration = Duration(
    milliseconds: 1500,
  ); // Auto timer

  // Collapsed width = just the icon button
  static const double _collapsedWidth = 48.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: _slowDuration, vsync: this);

    // After Effects style ease in/out curve
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic, // Smooth S-curve like AE
      reverseCurve: Curves.easeInOutCubic,
    );

    _animController.value = 1.0; // Start expanded
    _startAutoHideTimer();
    _startPeriodicNudgeTimer();
  }

  @override
  void didUpdateWidget(CollapsibleNudgeBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nudge != oldWidget.nudge) {
      _expandSlow(); // Slow animation for new nudge
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isExpanded) {
        _collapseSlow(); // Slow animation for timer
      }
    });
  }

  void _startPeriodicNudgeTimer() {
    _periodicNudgeTimer?.cancel();
    final random = Random();
    final baseMinutes = 5;
    final randomExtra = random.nextInt(120);
    final interval = Duration(minutes: baseMinutes, seconds: randomExtra);

    _periodicNudgeTimer = Timer(interval, () {
      if (mounted) {
        widget.onNudgeChange?.call();
        _startPeriodicNudgeTimer();
      }
    });
  }

  // Fast expand for user tap
  void _expandFast() {
    setState(() => _isExpanded = true);
    _animController.duration = _fastDuration;
    _animController.forward();
    _startAutoHideTimer();
  }

  // Slow expand for new nudge
  void _expandSlow() {
    setState(() => _isExpanded = true);
    _animController.duration = _slowDuration;
    _animController.forward();
    _startAutoHideTimer();
  }

  // Fast collapse for user tap
  void _collapseFast() {
    _autoHideTimer?.cancel();
    setState(() => _isExpanded = false);
    _animController.duration = _fastDuration;
    _animController.reverse();
  }

  // Slow collapse for timer
  void _collapseSlow() {
    _autoHideTimer?.cancel();
    setState(() => _isExpanded = false);
    _animController.duration = _slowDuration;
    _animController.reverse();
  }

  void _toggle() {
    if (_isExpanded) {
      _collapseFast(); // Fast when user taps
    } else {
      _expandFast(); // Fast when user taps
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _autoHideTimer?.cancel();
    _periodicNudgeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final theme = Theme.of(context);

    return Row(
      children: [
        // Nudge box - animates width
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  // Calculate current width with eased animation
                  final currentWidth =
                      _collapsedWidth +
                      (maxWidth - _collapsedWidth) * _slideAnimation.value;

                  return GestureDetector(
                    onTap: _toggle,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: currentWidth,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Stack(
                            children: [
                              // Text (behind, gets masked)
                              Positioned(
                                left: 48,
                                right: 6,
                                top: 0,
                                bottom: 0,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.nudge.text,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),

                              // Icon button
                              Positioned(
                                left: 6,
                                top: 6,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colors.surfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.nudge.icon,
                                    size: 18,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        // Separate headphone button
        GestureDetector(
          onTap: widget.onMusicTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.headphones_rounded,
              size: 22,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
