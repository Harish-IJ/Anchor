import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Preset timer configuration
class TimerPreset {
  final String name;
  final int focusMinutes;
  final int breakMinutes;

  const TimerPreset({
    required this.name,
    required this.focusMinutes,
    required this.breakMinutes,
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
  final void Function(int focus, int breakMins) onSave;

  const TimerSettingsSheet({
    super.key,
    this.initialFocusMinutes = 25,
    this.initialBreakMinutes = 5,
    required this.onSave,
  });

  @override
  State<TimerSettingsSheet> createState() => _TimerSettingsSheetState();
}

class _TimerSettingsSheetState extends State<TimerSettingsSheet> {
  late int _focusMinutes;
  late int _breakMinutes;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.initialFocusMinutes;
    _breakMinutes = widget.initialBreakMinutes;
  }

  void _selectPreset(TimerPreset preset) {
    setState(() {
      _focusMinutes = preset.focusMinutes;
      _breakMinutes = preset.breakMinutes;
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

          // Duration pickers (just Focus and Break)
          Row(
            children: [
              Expanded(
                child: _DurationPicker(
                  label: 'Focus',
                  value: _focusMinutes,
                  minValue: 5,
                  maxValue: 90,
                  step: 5,
                  onChanged: (v) => setState(() => _focusMinutes = v),
                  primaryColor: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DurationPicker(
                  label: 'Break',
                  value: _breakMinutes,
                  minValue: 3,
                  maxValue: 30,
                  step: 5,
                  useBreakValues: true,
                  onChanged: (v) => setState(() => _breakMinutes = v),
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

          // Save button
          ElevatedButton(
            onPressed: () {
              widget.onSave(_focusMinutes, _breakMinutes);
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
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Duration picker with increment/decrement buttons and long-press fast mode
class _DurationPicker extends StatefulWidget {
  final String label;
  final int value;
  final int minValue;
  final int maxValue;
  final int step;
  final bool useBreakValues;
  final ValueChanged<int> onChanged;
  final Color primaryColor;

  const _DurationPicker({
    required this.label,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.step,
    this.useBreakValues = false,
    required this.onChanged,
    required this.primaryColor,
  });

  @override
  State<_DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<_DurationPicker> {
  Timer? _timer;
  int _incrementCount = 0;

  // Break values: 3, 5, 10, 15, 20, 25, 30
  static const List<int> _breakValues = [3, 5, 10, 15, 20, 25, 30];

  int _getNextBreakValue(int current, bool increment) {
    final currentIndex = _breakValues.indexOf(current);
    if (currentIndex == -1) {
      // Find closest value
      for (int i = 0; i < _breakValues.length; i++) {
        if (_breakValues[i] >= current) {
          return increment
              ? _breakValues[i]
              : _breakValues[(i - 1).clamp(0, _breakValues.length - 1)];
        }
      }
      return increment ? _breakValues.last : _breakValues.first;
    }

    if (increment) {
      return currentIndex < _breakValues.length - 1
          ? _breakValues[currentIndex + 1]
          : _breakValues.last;
    } else {
      return currentIndex > 0
          ? _breakValues[currentIndex - 1]
          : _breakValues.first;
    }
  }

  void _increment() {
    _incrementCount++;
    if (widget.useBreakValues) {
      widget.onChanged(_getNextBreakValue(widget.value, true));
    } else {
      widget.onChanged(
        (widget.value + widget.step).clamp(widget.minValue, widget.maxValue),
      );
    }
  }

  void _decrement() {
    _incrementCount++;
    if (widget.useBreakValues) {
      widget.onChanged(_getNextBreakValue(widget.value, false));
    } else {
      widget.onChanged(
        (widget.value - widget.step).clamp(widget.minValue, widget.maxValue),
      );
    }
  }

  void _startLongPress(bool increment) {
    _incrementCount = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (increment) {
        _increment();
      } else {
        _decrement();
      }
      // Speed up after 3 increments
      if (_incrementCount >= 3 && _timer != null) {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
          if (increment) {
            _increment();
          } else {
            _decrement();
          }
        });
      }
    });
  }

  void _stopLongPress() {
    _timer?.cancel();
    _timer = null;
    _incrementCount = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Increment button - larger touch area
          GestureDetector(
            onTap: _increment,
            onLongPressStart: (_) => _startLongPress(true),
            onLongPressEnd: (_) => _stopLongPress(),
            onLongPressCancel: _stopLongPress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                Icons.keyboard_arrow_up_rounded,
                size: 32,
                color: colors.textSecondary,
              ),
            ),
          ),

          // Value display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${widget.value}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.primaryColor,
                fontSize: 36,
              ),
            ),
          ),

          // Label
          Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Decrement button - larger touch area
          GestureDetector(
            onTap: _decrement,
            onLongPressStart: (_) => _startLongPress(false),
            onLongPressEnd: (_) => _stopLongPress(),
            onLongPressCancel: _stopLongPress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 32,
                color: colors.textSecondary,
              ),
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
  required void Function(int focus, int breakMins) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TimerSettingsSheet(
      initialFocusMinutes: focusMinutes,
      initialBreakMinutes: breakMinutes,
      onSave: onSave,
    ),
  );
}
