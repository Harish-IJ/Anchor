import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Random nudge messages for motivation
const List<NudgeItem> nudgeItems = [
  NudgeItem(
    icon: Icons.local_fire_department_rounded,
    text: "You're on fire today!",
  ),
  NudgeItem(icon: Icons.spa_rounded, text: "Take a deep breath"),
  NudgeItem(icon: Icons.water_drop_rounded, text: "Drink some water"),
  NudgeItem(icon: Icons.bolt_rounded, text: "Stay focused!"),
  NudgeItem(icon: Icons.thumb_up_rounded, text: "Great progress!"),
  NudgeItem(icon: Icons.music_note_rounded, text: "Groove Tunes"),
  NudgeItem(icon: Icons.self_improvement_rounded, text: "You got this!"),
  NudgeItem(icon: Icons.star_rounded, text: "Keep shining!"),
];

class NudgeItem {
  final IconData icon;
  final String text;
  const NudgeItem({required this.icon, required this.text});
}

/// Styled nudge box widget with icon and music button
class NudgeBox extends StatelessWidget {
  final NudgeItem nudge;
  final VoidCallback? onMusicTap;

  const NudgeBox({super.key, required this.nudge, this.onMusicTap});

  static NudgeItem getRandomNudge() {
    final random = Random();
    return nudgeItems[random.nextInt(nudgeItems.length)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icon in circular container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(nudge.icon, size: 18, color: colors.textSecondary),
          ),
          const SizedBox(width: 12),
          // Text - fills remaining space
          Expanded(
            child: Text(
              nudge.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Music button (for future white noise feature)
          GestureDetector(
            onTap: onMusicTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.headphones_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
