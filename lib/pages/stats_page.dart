import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/theme_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/projects_provider.dart';
import '../providers/preferences_provider.dart';
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
    final prefs = context.watch<PreferencesProvider>();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stats',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  // Debug buttons (remove in production)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          final projects = context.read<ProjectsProvider>();
                          // Generate test projects first
                          await projects.generateTestProjects();
                          // Then generate sessions with real project IDs
                          await sessions.generateTestData(
                            projectIds: projects.projectIds,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Test projects & sessions generated!',
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.add_chart, color: colors.primary),
                        tooltip: 'Generate test data',
                      ),
                      IconButton(
                        onPressed: () async {
                          await sessions.clearAllData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All data cleared!'),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                        tooltip: 'Clear all data',
                      ),
                    ],
                  ),
                ],
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

              const SizedBox(height: 20),

              // Hourly Distribution Chart
              _HourlyDistributionChart(
                sessions: sessions,
                colors: colors,
                theme: theme,
                prefs: prefs,
              ),

              const SizedBox(height: 20),

              // Month Comparison Card
              _MonthComparisonCard(
                sessions: sessions,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // Productivity Heatmap
              _ProductivityHeatmap(
                sessions: sessions,
                colors: colors,
                theme: theme,
                prefs: prefs,
              ),

              const SizedBox(height: 20),

              // Project Breakdown Donut
              _ProjectDonutChart(
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

/// Weekly bar chart showing focus hours per day with navigation
class _WeeklyBarChart extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _WeeklyBarChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  State<_WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<_WeeklyBarChart> {
  int _weekOffset = 0; // 0 = current week, -1 = last week, etc.

  String _getWeekLabel() {
    if (_weekOffset == 0) return 'This Week';
    if (_weekOffset == -1) return 'Last Week';
    return '${-_weekOffset} weeks ago';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().subtract(Duration(days: -_weekOffset * 7));
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Get 7 days data based on offset
    final List<double> dailyHours = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final daySessions = widget.sessions.getSessionsInRange(
        startOfDay,
        endOfDay,
      );
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

    final isCurrentWeek = _weekOffset == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.colors.surface,
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
          // Header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getWeekLabel(),
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _weekOffset--),
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: widget.colors.textSecondary,
                    ),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: isCurrentWeek
                        ? null
                        : () => setState(() => _weekOffset++),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: isCurrentWeek
                          ? widget.colors.textSecondary.withValues(alpha: 0.3)
                          : widget.colors.textSecondary,
                    ),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dailyHours[index],
                        color: (index == 6 && isCurrentWeek)
                            ? widget.colors.primary
                            : widget.colors.primary.withValues(alpha: 0.4),
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
                            color: widget.colors.textSecondary,
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
                              color: (value.toInt() == 6 && isCurrentWeek)
                                  ? widget.colors.primary
                                  : widget.colors.textSecondary,
                              fontWeight: (value.toInt() == 6 && isCurrentWeek)
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
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: widget.colors.surfaceVariant,
                    strokeWidth: 1,
                  ),
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

/// Hourly distribution chart showing focus patterns by hour
class _HourlyDistributionChart extends StatelessWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;
  final PreferencesProvider prefs;

  const _HourlyDistributionChart({
    required this.sessions,
    required this.colors,
    required this.theme,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    // Get hourly focus data for last 30 days
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final allSessions = sessions
        .getSessionsInRange(startDate, now)
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();

    // Group by hour
    final hourlyMinutes = List<double>.filled(24, 0);
    for (final session in allSessions) {
      final hour = session.startedAt.hour;
      hourlyMinutes[hour] += session.actualDurationSeconds / 60;
    }

    final maxMinutes = hourlyMinutes.isEmpty
        ? 60.0
        : hourlyMinutes.reduce((a, b) => a > b ? a : b).clamp(10.0, 500.0);

    // Find peak hour
    int peakHour = 0;
    double peakValue = 0;
    for (int i = 0; i < 24; i++) {
      if (hourlyMinutes[i] > peakValue) {
        peakValue = hourlyMinutes[i];
        peakHour = i;
      }
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peak Focus Hours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (peakValue > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${prefs.formatHour(peakHour)} is your best',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxMinutes,
                barGroups: List.generate(24, (hour) {
                  return BarChartGroupData(
                    x: hour,
                    barRods: [
                      BarChartRodData(
                        toY: hourlyMinutes[hour],
                        color: hour == peakHour
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.3),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final hour = value.toInt();
                        // Show labels at 0, 6, 12, 18, 23 (adding 11pm/23:00)
                        if (hour == 0 ||
                            hour == 6 ||
                            hour == 12 ||
                            hour == 18 ||
                            hour == 23) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              prefs.formatHour(hour),
                              style: TextStyle(
                                fontSize: 9,
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'Distribution by hour of day',
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

/// Month vs month comparison card
class _MonthComparisonCard extends StatelessWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _MonthComparisonCard({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  String _formatHours(int seconds) {
    final hours = seconds / 3600;
    if (hours >= 1) {
      return '${hours.toStringAsFixed(1)}h';
    }
    return '${(seconds / 60).round()}m';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // This month
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthSessions = sessions
        .getSessionsInRange(thisMonthStart, now)
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();
    final thisMonthSeconds = thisMonthSessions.fold(
      0,
      (sum, s) => sum + s.actualDurationSeconds,
    );

    // Last month
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1);
    final lastMonthSessions = sessions
        .getSessionsInRange(lastMonthStart, lastMonthEnd)
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();
    final lastMonthSeconds = lastMonthSessions.fold(
      0,
      (sum, s) => sum + s.actualDurationSeconds,
    );

    // Calculate change
    final changePercent = lastMonthSeconds > 0
        ? ((thisMonthSeconds - lastMonthSeconds) / lastMonthSeconds * 100)
              .round()
        : 0;
    final isUp = thisMonthSeconds >= lastMonthSeconds;

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
            'Month Comparison',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // This month
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'This Month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatHours(thisMonthSeconds),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                      Text(
                        '${thisMonthSessions.length} sessions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Change indicator
              Column(
                children: [
                  Icon(
                    isUp
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: isUp ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  Text(
                    '${changePercent.abs()}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUp ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Last month
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Last Month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatHours(lastMonthSeconds),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${lastMonthSessions.length} sessions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// GitHub-style productivity heatmap with year navigation
class _ProductivityHeatmap extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;
  final PreferencesProvider prefs;

  const _ProductivityHeatmap({
    required this.sessions,
    required this.colors,
    required this.theme,
    required this.prefs,
  });

  @override
  State<_ProductivityHeatmap> createState() => _ProductivityHeatmapState();
}

class _ProductivityHeatmapState extends State<_ProductivityHeatmap> {
  late int _selectedYear;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getIntensityColor(double hours) {
    if (hours == 0) return widget.colors.surfaceVariant;
    if (hours < 0.5) return widget.colors.primary.withValues(alpha: 0.2);
    if (hours < 1) return widget.colors.primary.withValues(alpha: 0.4);
    if (hours < 2) return widget.colors.primary.withValues(alpha: 0.6);
    if (hours < 3) return widget.colors.primary.withValues(alpha: 0.8);
    return widget.colors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentYear = _selectedYear == now.year;

    // Calculate year boundaries
    final yearStart = DateTime(_selectedYear, 1, 1);
    final yearEnd = isCurrentYear ? now : DateTime(_selectedYear, 12, 31);

    // Find the first day of the week containing Jan 1
    // If weekStartsSunday: Sunday = weekday 7 in Dart, offset = weekday % 7
    // If weekStartsMonday: Monday = weekday 1 in Dart, offset = (weekday - 1) % 7
    final firstWeekStart = widget.prefs.weekStartsSunday
        ? yearStart.subtract(Duration(days: yearStart.weekday % 7))
        : yearStart.subtract(Duration(days: (yearStart.weekday - 1) % 7));

    // Get data for the selected year
    final Map<String, double> dailyHours = {};
    var currentDate = firstWeekStart;
    while (currentDate.isBefore(yearEnd.add(const Duration(days: 7)))) {
      final startOfDay = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final daySessions = widget.sessions.getSessionsInRange(
        startOfDay,
        endOfDay,
      );
      final focusSecs = daySessions
          .where(
            (s) =>
                s.type == SessionType.focus &&
                s.status == SessionStatus.completed,
          )
          .fold(0, (sum, s) => sum + s.actualDurationSeconds);

      final key = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      dailyHours[key] = focusSecs / 3600;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Build weeks for the selected year
    final weeks = <List<MapEntry<DateTime, double>>>[];
    var weekStart = firstWeekStart;
    final lastDate = isCurrentYear ? now : DateTime(_selectedYear, 12, 31);

    while (weekStart.year <= _selectedYear &&
        (weekStart.isBefore(lastDate) ||
            weekStart.isAtSameMomentAs(lastDate))) {
      final week = <MapEntry<DateTime, double>>[];
      for (int d = 0; d < 7; d++) {
        final date = weekStart.add(Duration(days: d));
        // Check if date is in the future or outside year bounds
        if (date.isAfter(now) || date.year > _selectedYear) {
          week.add(MapEntry(date, -1)); // -1 means no data/future
        } else if (date.year < _selectedYear) {
          week.add(MapEntry(date, -2)); // -2 means before year start (dim it)
        } else {
          final key = '${date.year}-${date.month}-${date.day}';
          week.add(MapEntry(date, dailyHours[key] ?? 0));
        }
      }
      weeks.add(week);
      weekStart = weekStart.add(const Duration(days: 7));

      // Stop if we've gone past the year
      if (weekStart.year > _selectedYear && !isCurrentYear) break;
    }

    final weekdayLabels = widget.prefs.weekdayLabels;

    // Scroll to end for current year
    if (isCurrentYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.colors.surface,
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
          // Header with year navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _selectedYear--),
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: widget.colors.textSecondary,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                  Text(
                    '$_selectedYear',
                    style: widget.theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: isCurrentYear
                        ? null
                        : () => setState(() => _selectedYear++),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: isCurrentYear
                          ? widget.colors.textSecondary.withValues(alpha: 0.3)
                          : widget.colors.textSecondary,
                    ),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Heatmap grid with weekday labels
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekday labels column
              Column(
                children: weekdayLabels
                    .map(
                      (label) => Container(
                        width: 28,
                        height: 14,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            color: widget.colors.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // Scrollable heatmap
              Expanded(
                child: SizedBox(
                  height: 7 * 14.0,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: weeks.length,
                    itemBuilder: (context, weekIndex) {
                      final week = weeks[weekIndex];
                      return Column(
                        children: week.map((entry) {
                          final date = entry.key;
                          final hours = entry.value;
                          final isToday =
                              date.year == now.year &&
                              date.month == now.month &&
                              date.day == now.day;
                          final isFuture = hours == -1;
                          final isBeforeYear = hours == -2;

                          return Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: isFuture || isBeforeYear
                                  ? Colors.transparent
                                  : _getIntensityColor(hours),
                              borderRadius: BorderRadius.circular(2),
                              border: isToday
                                  ? Border.all(
                                      color: widget.colors.primary,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              ...[0.0, 0.3, 0.75, 1.5, 3.0].map(
                (h) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: _getIntensityColor(h),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Project breakdown donut chart
class _ProjectDonutChart extends StatelessWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _ProjectDonutChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsProvider>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Get this month's sessions
    final monthSessions = sessions
        .getSessionsInRange(monthStart, now)
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();

    // Group by project
    final projectMinutes = <String?, int>{};
    for (final session in monthSessions) {
      final key = session.projectId;
      projectMinutes[key] =
          (projectMinutes[key] ?? 0) + session.actualDurationSeconds ~/ 60;
    }

    // Sort by minutes descending
    final sortedProjects = projectMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalMinutes = sortedProjects.fold(0, (sum, e) => sum + e.value);

    if (totalMinutes == 0) {
      // Show skeleton donut chart with proper dimensions
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
            // Header
            Text(
              'Project Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Text(
              'This Month',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Skeleton donut
            Row(
              children: [
                // Donut placeholder
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.surfaceVariant,
                            width: 20,
                          ),
                        ),
                      ),
                      // Center icon
                      Icon(
                        Icons.pie_chart_outline,
                        size: 32,
                        color: colors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Legend placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No project data this month',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete focus sessions to see your project breakdown here.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Build pie sections
    final sections = <PieChartSectionData>[];
    final projectColors = [
      const Color(0xFFFF6712),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFDC2626),
      const Color(0xFF2563EB),
    ];

    int colorIndex = 0;
    for (final entry in sortedProjects.take(6)) {
      final project = projects.getProject(entry.key);
      final color =
          project?.color ?? projectColors[colorIndex % projectColors.length];
      final percent = (entry.value / totalMinutes * 100);

      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          color: color,
          radius: 30,
          showTitle: false,
        ),
      );
      colorIndex++;
    }

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
            'Projects This Month',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 100,
                height: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sections,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sortedProjects.take(5).map((entry) {
                    final project = projects.getProject(entry.key);
                    final name = project?.name ?? 'No Project';
                    final color =
                        project?.color ??
                        projectColors[sortedProjects.indexOf(entry) %
                            projectColors.length];
                    final percent = (entry.value / totalMinutes * 100).round();
                    final hours = entry.value ~/ 60;
                    final mins = entry.value % 60;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            hours > 0 ? '${hours}h ${mins}m' : '${mins}m',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
