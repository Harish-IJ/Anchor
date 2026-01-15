import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/theme_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/projects_provider.dart';
import '../models/focus_session.dart';

/// Statistics page with reports and charts
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final sessions = context.watch<SessionsProvider>();

    final todayFocus = sessions.getTodayFocusSeconds();
    final todayBreak = sessions.getTodayBreakSeconds();
    final todaySessions = sessions.getTodaySessions();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              // Today's Stats Card
              _TodayStatsCard(
                focusSeconds: todayFocus,
                breakSeconds: todayBreak,
                yesterdayFocusSeconds: sessions.getYesterdayFocusSeconds(),
                sessionsCount: todaySessions
                    .where(
                      (s) =>
                          s.type == SessionType.focus &&
                          s.status == SessionStatus.completed,
                    )
                    .length,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // Weekly Bar Chart
              _WeeklyBarChart(sessions: sessions, colors: colors, theme: theme),

              const SizedBox(height: 20),

              // Longest Session Card
              _LongestSessionCard(
                sessions: sessions,
                colors: colors,
                theme: theme,
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

/// Today's focus/break stats with relative comparison
class _TodayStatsCard extends StatelessWidget {
  final int focusSeconds;
  final int breakSeconds;
  final int yesterdayFocusSeconds;
  final int sessionsCount;
  final dynamic colors;
  final ThemeData theme;

  const _TodayStatsCard({
    required this.focusSeconds,
    required this.breakSeconds,
    required this.yesterdayFocusSeconds,
    required this.sessionsCount,
    required this.colors,
    required this.theme,
  });

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _getComparisonText() {
    if (yesterdayFocusSeconds == 0 && focusSeconds == 0) {
      return 'Start a focus session!';
    }
    if (yesterdayFocusSeconds == 0) {
      return 'First day tracking!';
    }

    final diff = focusSeconds - yesterdayFocusSeconds;
    final percentChange = ((diff.abs() / yesterdayFocusSeconds) * 100).round();

    if (diff > 0) {
      return '↑ $percentChange% more than yesterday';
    } else if (diff < 0) {
      return '↓ $percentChange% less than yesterday';
    } else {
      return 'Same as yesterday';
    }
  }

  Color _getComparisonColor() {
    if (yesterdayFocusSeconds == 0) return colors.textSecondary;

    final diff = focusSeconds - yesterdayFocusSeconds;
    if (diff > 0) return Colors.green;
    if (diff < 0) return Colors.orange;
    return colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              // Relative comparison badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getComparisonColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getComparisonText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getComparisonColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Focus',
                  value: _formatDuration(focusSeconds),
                  color: colors.primary,
                  colors: colors,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.coffee_rounded,
                  label: 'Break',
                  value: _formatDuration(breakSeconds),
                  color: colors.textSecondary,
                  colors: colors,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_rounded,
                  label: 'Sessions',
                  value: '$sessionsCount',
                  color: Colors.green,
                  colors: colors,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final dynamic colors;
  final ThemeData theme;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekly bar chart showing focus hours per day
class _WeeklyBarChart extends StatelessWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _WeeklyBarChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Get last 7 days data
    final List<double> dailyHours = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final daySessions = sessions.getSessionsInRange(startOfDay, endOfDay);
      final focusSecs = daySessions
          .where(
            (s) =>
                s.type == SessionType.focus &&
                s.status == SessionStatus.completed,
          )
          .fold(0, (sum, s) => sum + s.actualDurationSeconds);

      dailyHours.add(focusSecs / 3600);
    }

    final maxY = dailyHours.isEmpty
        ? 4.0
        : (dailyHours.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble().clamp(
            2.0,
            12.0,
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: BarChart(
              swapAnimationDuration: const Duration(milliseconds: 500),
              BarChartData(
                maxY: maxY,
                barGroups: List.generate(7, (index) {
                  final dayIndex = (now.weekday - 7 + index) % 7;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dailyHours[index],
                        color: index == 6
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.4),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final dayIndex = (now.weekday - 7 + value.toInt()) % 7;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            weekDays[dayIndex],
                            style: TextStyle(
                              fontSize: 11,
                              color: value.toInt() == 6
                                  ? colors.primary
                                  : colors.textSecondary,
                              fontWeight: value.toInt() == 6
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: colors.surfaceVariant, strokeWidth: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Longest session achievement card
class _LongestSessionCard extends StatelessWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _LongestSessionCard({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsProvider>();
    final longest = sessions.getLongestSession();

    if (longest == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Complete a focus session to see your record!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final projectName = longest.projectId != null
        ? projects.getProject(longest.projectId)?.name ?? 'Unknown'
        : 'No Project';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Longest Focus Session',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(longest.actualDurationSeconds),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              projectName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
