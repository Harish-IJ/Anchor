import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../providers/preferences_provider.dart';

/// Settings page with theme selection
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final prefs = context.watch<PreferencesProvider>();
    final colors = themeProvider.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 32),

              // Appearance section
              _SettingsCard(
                title: 'Appearance',
                icon: Icons.dark_mode_rounded,
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme mode (Light/Dark/System)
                    Text(
                      'Mode',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: AnchorThemeMode.values.map((mode) {
                        final isSelected = themeProvider.themeMode == mode;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: mode != AnchorThemeMode.system ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => themeProvider.setThemeMode(mode),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                      : colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  themeProvider.getThemeModeName(mode),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : colors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Color theme
                    Text(
                      'Color',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AnchorTheme>(
                          value: themeProvider.currentTheme,
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                          ),
                          items: AnchorTheme.values.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AnchorColors(t).primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    themeProvider.getThemeName(t),
                                    style: TextStyle(color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (theme) {
                            if (theme != null) {
                              themeProvider.setTheme(theme);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Display Preferences section
              _SettingsCard(
                title: 'Display',
                icon: Icons.schedule_rounded,
                colors: colors,
                child: Column(
                  children: [
                    // Time format toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Format',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Segmented time format selector
                        Row(
                          children: [
                            _WeekStartButton(
                              label: '12hr',
                              isSelected: !prefs.use24HourFormat,
                              onTap: () => prefs.setUse24HourFormat(false),
                              colors: colors,
                            ),
                            const SizedBox(width: 4),
                            _WeekStartButton(
                              label: '24hr',
                              isSelected: prefs.use24HourFormat,
                              onTap: () => prefs.setUse24HourFormat(true),
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Week start toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week Starts On',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              prefs.weekStartsSunday ? 'Sunday' : 'Monday',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        // Custom segmented button
                        Row(
                          children: [
                            _WeekStartButton(
                              label: 'Sun',
                              isSelected: prefs.weekStartsSunday,
                              onTap: () => prefs.setWeekStartsSunday(true),
                              colors: colors,
                            ),
                            const SizedBox(width: 4),
                            _WeekStartButton(
                              label: 'Mon',
                              isSelected: !prefs.weekStartsSunday,
                              onTap: () => prefs.setWeekStartsSunday(false),
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // About section
              _SettingsCard(
                title: 'About',
                icon: Icons.info_outline_rounded,
                colors: colors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anchor Focus Timer',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A calm, configurable focus timer for serious users.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom padding for navigation pill
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable settings card
class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final AnchorColors colors;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Small button for week start selection
class _WeekStartButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic colors;

  const _WeekStartButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
