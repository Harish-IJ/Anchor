import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Preset timer configuration
class TimerPreset {
  final String name;
  final int focusMinutes;
  final int breakMinutes;
  final int longBreakMinutes;

  const TimerPreset({
    required this.name,
    required this.focusMinutes,
    required this.breakMinutes,
    this.longBreakMinutes = 15,
  });
}

/// Default presets
const List<TimerPreset> defaultPresets = [
  TimerPreset(name: 'Pomodoro', focusMinutes: 25, breakMinutes: 5),
  TimerPreset(name: 'Deep Work', focusMinutes: 50, breakMinutes: 10),
  TimerPreset(name: 'Quick Focus', focusMinutes: 15, breakMinutes: 3),
];

/// Bottom sheet for timer settings
class TimerSettingsSheet extends StatefulWidget {
  final int initialFocusMinutes;
  final int initialBreakMinutes;
  final int initialLongBreakMinutes;
  final void Function(int focus, int shortBreak, int longBreak) onSave;

  const TimerSettingsSheet({
    super.key,
    this.initialFocusMinutes = 25,
    this.initialBreakMinutes = 5,
    this.initialLongBreakMinutes = 15,
    required this.onSave,
  });

  @override
  State<TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<TimerSettingsSheet> {
  late int _focusMinutes;
  late int _breakMinutes;
  late int _longBreakMinutes;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.initialFocusMinutes;
    _breakMinutes = widget.initialBreakMinutes;
    _longBreakMinutes = widget.initialLongBreakMinutes;
  }

  void _selectPreset(TimerPreset preset) {
    setState(() {
      _focusMinutes = preset.focusMinutes;
      _breakMinutes = preset.breakMinutes;
      _longBreakMinutes = preset.longBreakMinutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Timer Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Duration pickers
          Row(
            children: [
              Expanded(
                child: _DurationPicker(
                  label: 'Focus',
                  value: _focusMinutes,
                  onChanged: (v) => setState(() => _focusMinutes = v),
                  primaryColor: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DurationPicker(
                  label: 'Break',
                  value: _breakMinutes,
                  onChanged: (v) => setState(() => _breakMinutes = v),
                  primaryColor: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DurationPicker(
                  label: 'Long',
                  value: _longBreakMinutes,
                  onChanged: (v) => setState(() => _longBreakMinutes = v),
                  primaryColor: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick presets
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Presets',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: defaultPresets.map((preset) {
              final isSelected =
                  _focusMinutes == preset.focusMinutes &&
                  _breakMinutes == preset.breakMinutes;
              return GestureDetector(
                onTap: () => _selectPreset(preset),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${preset.name} (${preset.focusMinutes}/${preset.breakMinutes})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Continue button
          ElevatedButton(
            onPressed: () {
              widget.onSave(_focusMinutes, _breakMinutes, _longBreakMinutes);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duration picker with increment/decrement buttons
class _DurationPicker extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final Color primaryColor;

  const _DurationPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Increment
          GestureDetector(
            onTap: () => onChanged((value + 5).clamp(5, 120)),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Value
          Text(
            '$value',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Decrement
          GestureDetector(
            onTap: () => onChanged((value - 5).clamp(5, 120)),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show timer settings as bottom sheet
Future<void> showTimerSettings({
  required BuildContext context,
  required int focusMinutes,
  required int breakMinutes,
  required int longBreakMinutes,
  required void Function(int focus, int shortBreak, int longBreak) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TimerSettingsSheet(
      initialFocusMinutes: focusMinutes,
      initialBreakMinutes: breakMinutes,
      initialLongBreakMinutes: longBreakMinutes,
      onSave: onSave,
    ),
  );
}
