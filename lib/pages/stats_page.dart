import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/theme_provider.dart';
import '../theme/app_theme.dart';
import '../providers/sessions_provider.dart';
import '../providers/projects_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/focus_session.dart';

/// Statistics page with reports and charts
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.watch<ThemeProvider>().colors;
    final sessions = context.watch<SessionsProvider>();
    final projects = context.watch<ProjectsProvider>();
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

              // Weekly Stacked Bar Chart
              _WeeklyStackedBarChart(
                sessions: sessions,
                projects: projects,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // 3/6 Month Trend
              _TrendAreaChart(sessions: sessions, colors: colors, theme: theme),

              const SizedBox(height: 20),

              // Monthly Completion Rate
              _CompletionRateChart(
                sessions: sessions,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // Session Quality Summary
              _SessionQualityCard(
                sessions: sessions,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // Longest Session Card
              _LongestSessionCard(
                sessions: sessions,
                colors: colors,
                theme: theme,
              ),

              const SizedBox(height: 20),

              // Distracted Sessions Card
              _DistractedSessionsCard(
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
                  color: _getComparisonColor().withValues(alpha: 0.1),
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
        color: color.withValues(alpha: 0.08),
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

/// Weekly Stacked Bar Chart (Last 7 days)
class _WeeklyStackedBarChart extends StatefulWidget {
  final SessionsProvider sessions;
  final ProjectsProvider projects;
  final dynamic colors;
  final ThemeData theme;

  const _WeeklyStackedBarChart({
    required this.sessions,
    required this.projects,
    required this.colors,
    required this.theme,
  });

  @override
  State<_WeeklyStackedBarChart> createState() => _WeeklyStackedBarChartState();
}

class _WeeklyStackedBarChartState extends State<_WeeklyStackedBarChart> {
  int _periodOffset = 0; // 0 = current 1 week

  String _getPeriodLabel() {
    if (_periodOffset == 0) return 'Last 7 Days';
    return '${-_periodOffset} weeks ago';
  }

  @override
  Widget build(BuildContext context) {
    // 7 days window
    final now = DateTime.now().subtract(Duration(days: -_periodOffset * 7));

    // Prepare data: List of 7 days
    final List<Map<String, double>> dailyData = [];
    final Set<String> allProjectIds = {};

    // Iterate 6 down to 0
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final sessions = widget.sessions.getSessionsInRange(startOfDay, endOfDay);
      final Map<String, double> dayProjectHours = {};

      double incompleteHours = 0;

      for (final s in sessions) {
        if (s.type == SessionType.focus) {
          if (s.status == SessionStatus.completed) {
            final pid = s.projectId ?? 'none';
            dayProjectHours[pid] =
                (dayProjectHours[pid] ?? 0) + (s.actualDurationSeconds / 3600);
            allProjectIds.add(pid);
          } else {
            // Incomplete session duration
            incompleteHours += (s.actualDurationSeconds / 3600);
          }
        }
      }
      dailyData.add({...dayProjectHours, 'incomplete': incompleteHours});
    }

    final projectColorsList = [
      const Color(0xFFFF6712),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFDC2626),
      const Color(0xFF2563EB),
    ];

    Color getProjectColor(String pid) {
      if (pid == 'none') return widget.colors.surfaceVariant;
      final proj = widget.projects.getProject(pid);
      if (proj != null) return proj.color;
      return projectColorsList[pid.hashCode.abs() % projectColorsList.length];
    }

    final maxY = dailyData.isEmpty
        ? 5.0
        : (dailyData
                      .map((d) => d.values.fold(0.0, (sum, v) => sum + v))
                      .reduce((a, b) => a > b ? a : b) +
                  1)
              .ceilToDouble();

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPeriodLabel(),
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily focus hours',
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: widget.colors.textSecondary,
                    ),
                    onPressed: () => setState(() => _periodOffset--),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: _periodOffset == 0
                          ? widget.colors.textSecondary.withValues(alpha: 0.3)
                          : widget.colors.textSecondary,
                    ),
                    onPressed: _periodOffset == 0
                        ? null
                        : () => setState(() => _periodOffset++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 5,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => widget.colors.surfaceVariant,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final total = rod.rodStackItems.fold(
                        0.0,
                        (s, i) => s + (i.toY - i.fromY),
                      );
                      return BarTooltipItem(
                        '${total.toStringAsFixed(1)}h',
                        TextStyle(
                          color: widget.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) return const SizedBox();

                        final dayDate = now.subtract(Duration(days: 6 - index));
                        final weekday = [
                          'M',
                          'T',
                          'W',
                          'T',
                          'F',
                          'S',
                          'S',
                        ][dayDate.weekday - 1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${dayDate.day}\n$weekday',
                            textAlign: TextAlign.center,
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxY > 5 ? maxY / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.colors.textSecondary,
                            fontSize: 10,
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 5 ? maxY / 5 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: widget.colors.surfaceVariant,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final data = dailyData[index];
                  final incomplete = data['incomplete'] ?? 0.0;

                  // Rod 1: Stacked Projects
                  final rods = <BarChartRodStackItem>[];
                  double currentY = 0;
                  // Sort projects for consistent stacking? Or simply iterate
                  // We only need keys that are project IDs
                  final projectKeys = data.keys.where((k) => k != 'incomplete');

                  for (final pid in projectKeys) {
                    final val = data[pid]!;
                    if (val > 0) {
                      rods.add(
                        BarChartRodStackItem(
                          currentY,
                          currentY + val,
                          getProjectColor(pid),
                        ),
                      );
                      currentY += val;
                    }
                  }

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4, // Space between the two bars
                    barRods: [
                      // Bar 1: Incomplete Sessions (Red) - LEFT
                      BarChartRodData(
                        toY: incomplete,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFDC2626),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY > 0 ? maxY : 5,
                          color: widget.colors.surfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      // Bar 2: Focus Time (Stacked) - RIGHT
                      BarChartRodData(
                        toY: currentY,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        color:
                            Colors.transparent, // Color handled by stack items
                        rodStackItems: rods,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY > 0 ? maxY : 5,
                          color: widget.colors.surfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          // Legend for Incomplete
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Incomplete Sessions',
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: widget.colors.textSecondary,
                  ),
                ),
              ],
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

/// Distracted Sessions Card - tracks sessions with high pause counts
///
/// A session is considered "distracted" if it has 4+ pauses and the
/// duration wasn't manually modified (to exclude intentional adjustments).
class _DistractedSessionsCard extends StatelessWidget {
  final SessionsProvider sessions;
  final AnchorColors colors;
  final ThemeData theme;

  const _DistractedSessionsCard({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Get last 30 days of focus sessions
    final startDate = now.subtract(const Duration(days: 30));
    final allSessions = sessions
        .getSessionsInRange(startDate, now.add(const Duration(days: 1)))
        .where(
          (s) =>
              s.type == SessionType.focus &&
              s.status == SessionStatus.completed,
        )
        .toList();

    // Distracted = 4+ pauses and not manually modified
    final distractedSessions = allSessions
        .where((s) => s.pauseCount >= 4 && !s.isDurationModified)
        .toList();

    // Get this week's stats
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekSessions = allSessions
        .where(
          (s) => !s.startedAt.isBefore(
            DateTime(weekStart.year, weekStart.month, weekStart.day),
          ),
        )
        .toList();
    final thisWeekDistracted = thisWeekSessions
        .where((s) => s.pauseCount >= 4 && !s.isDurationModified)
        .length;

    // Calculate distraction rate
    final distractionRate = allSessions.isEmpty
        ? 0.0
        : (distractedSessions.length / allSessions.length * 100);

    // Average pause count in distracted sessions
    final avgPauses = distractedSessions.isEmpty
        ? 0.0
        : distractedSessions.fold<int>(0, (sum, s) => sum + s.pauseCount) /
              distractedSessions.length;

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.running_with_errors_rounded,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Quality',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Last 30 days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              // Distracted count
              Expanded(
                child: _QualityStatTile(
                  label: 'Distracted',
                  value: '${distractedSessions.length}',
                  subtitle: 'of ${allSessions.length} sessions',
                  colors: colors,
                  theme: theme,
                  valueColor: distractedSessions.isEmpty
                      ? colors.primary
                      : Colors.orange,
                ),
              ),

              // Distraction rate
              Expanded(
                child: _QualityStatTile(
                  label: 'Rate',
                  value: '${distractionRate.toStringAsFixed(0)}%',
                  subtitle: distractionRate < 20
                      ? 'Great focus!'
                      : distractionRate < 40
                      ? 'Could improve'
                      : 'Needs attention',
                  colors: colors,
                  theme: theme,
                  valueColor: distractionRate < 20
                      ? colors.primary
                      : distractionRate < 40
                      ? Colors.orange
                      : Colors.redAccent,
                ),
              ),

              // This week
              Expanded(
                child: _QualityStatTile(
                  label: 'This Week',
                  value: '$thisWeekDistracted',
                  subtitle: avgPauses > 0
                      ? '~${avgPauses.toStringAsFixed(1)} pauses'
                      : 'avg pauses',
                  colors: colors,
                  theme: theme,
                  valueColor: thisWeekDistracted == 0
                      ? colors.primary
                      : Colors.orange,
                ),
              ),
            ],
          ),

          // Tip if there are distracted sessions
          if (distractedSessions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      avgPauses >= 6
                          ? 'Try shorter focus sessions to maintain concentration'
                          : 'Consider removing distractions before starting',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat tile for the quality card
class _QualityStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final AnchorColors colors;
  final ThemeData theme;
  final Color? valueColor;

  const _QualityStatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.colors,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
  bool _hasAutoScrolled = false;

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

    // Scroll to end for current year (only once per year view)
    if (isCurrentYear && !_hasAutoScrolled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          _hasAutoScrolled = true;
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
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                        _hasAutoScrolled = false;
                      });
                    },
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
                        : () {
                            setState(() {
                              _selectedYear++;
                              _hasAutoScrolled = false;
                            });
                          },
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
class _ProjectDonutChart extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _ProjectDonutChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  State<_ProjectDonutChart> createState() => _ProjectDonutChartState();
}

class _ProjectDonutChartState extends State<_ProjectDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ProjectsProvider>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Get this month's sessions
    final monthSessions = widget.sessions
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

    // Prepare data for "Center Text"
    String centerTopText = 'Total';
    String centerBottomText = '${totalMinutes ~/ 60}h';
    Color? centerColor;

    if (_touchedIndex != -1 && _touchedIndex < sortedProjects.length) {
      final entry = sortedProjects[_touchedIndex];
      final project = projects.getProject(entry.key);
      centerTopText = project?.name ?? 'No Project';

      final hrs = entry.value ~/ 60;
      final mins = entry.value % 60;
      centerBottomText = hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
      centerColor = project?.color;
    }

    if (totalMinutes == 0) {
      // Show skeleton donut chart with proper dimensions
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
            // Header
            Text(
              'Projects This Month',
              style: widget.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.colors.textPrimary,
              ),
            ),
            Text(
              'This Month',
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: widget.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Skeleton donut
            Row(
              children: [
                // Donut placeholder
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.colors.surfaceVariant,
                            width: 20,
                          ),
                        ),
                      ),
                      // Center icon
                      Icon(
                        Icons.pie_chart_outline,
                        size: 48,
                        color: widget.colors.textSecondary.withValues(
                          alpha: 0.5,
                        ),
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
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete focus sessions to see your project breakdown here.',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: widget.colors.textSecondary.withValues(
                            alpha: 0.7,
                          ),
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
    for (
      int i = 0;
      i < sortedProjects.take(ProjectsProvider.maxProjects).length;
      i++
    ) {
      final entry = sortedProjects[i];
      final project = projects.getProject(entry.key);
      final color =
          project?.color ?? projectColors[colorIndex % projectColors.length];

      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 35.0 : 30.0;

      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          color: color,
          radius: radius,
          showTitle: false,
        ),
      );
      colorIndex++;
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
          Text(
            'Projects This Month',
            style: widget.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Chart + Legend Column
          Column(
            children: [
              // Centered Donut chart
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: sections,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          centerTopText,
                          textAlign: TextAlign.center,
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            color: widget.colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          centerBottomText,
                          textAlign: TextAlign.center,
                          style: widget.theme.textTheme.titleLarge?.copyWith(
                            color: centerColor ?? widget.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // GRID Legend
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: sortedProjects
                        .take(ProjectsProvider.maxProjects)
                        .map((entry) {
                          final project = projects.getProject(entry.key);
                          final name = project?.name ?? 'No Project';
                          final index = sortedProjects.indexOf(entry);
                          final color =
                              project?.color ??
                              projectColors[index % projectColors.length];

                          final hours = entry.value ~/ 60;
                          final mins = entry.value % 60;

                          // approx width for 2 columns (minus spacing)
                          final itemWidth = (constraints.maxWidth - 16) / 2;
                          // If this item is 'touched', we could highlight it, but for now standard display
                          final isSelected = index == _touchedIndex;

                          return SizedBox(
                            width: itemWidth,
                            child: Opacity(
                              opacity: (_touchedIndex == -1 || isSelected)
                                  ? 1.0
                                  : 0.4,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: widget.theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: widget.colors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hours > 0
                                        ? '${hours}h ${mins}m'
                                        : '${mins}m',
                                    style: widget.theme.textTheme.bodySmall
                                        ?.copyWith(
                                          color: widget.colors.textSecondary,
                                          fontSize: 10,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3/6 Month Trend Area Chart
class _TrendAreaChart extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _TrendAreaChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  State<_TrendAreaChart> createState() => _TrendAreaChartState();
}

class _TrendAreaChartState extends State<_TrendAreaChart> {
  int _selectedMonths = 3;

  @override
  Widget build(BuildContext context) {
    final months = _selectedMonths;
    final now = DateTime.now();
    // Start from 1st of month X months ago
    final startMonth = DateTime(now.year, now.month - months + 1, 1);

    final List<FlSpot> spots = [];
    double maxHours = 0;
    final List<String> monthLabels = [];

    for (int i = 0; i < months; i++) {
      final d = DateTime(startMonth.year, startMonth.month + i, 1);
      final nextM = DateTime(startMonth.year, startMonth.month + i + 1, 1);

      final sessions = widget.sessions.getSessionsInRange(d, nextM);
      final totalSecs = sessions
          .where(
            (s) =>
                s.type == SessionType.focus &&
                s.status == SessionStatus.completed,
          )
          .fold(0, (sum, s) => sum + s.actualDurationSeconds);

      final hours = totalSecs / 3600.0;
      if (hours > maxHours) maxHours = hours;

      spots.add(FlSpot(i.toDouble(), hours));

      const mNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      monthLabels.add(mNames[d.month - 1]);
    }

    // Gradient below the line
    final List<Color> gradientColors = [
      widget.colors.primary.withValues(alpha: 0.3),
      widget.colors.primary.withValues(alpha: 0.0),
    ];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Trend',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMonths,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.colors.textSecondary,
                      size: 20,
                    ),
                    dropdownColor: widget.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      color: widget.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Months')),
                      DropdownMenuItem(value: 6, child: Text('6 Months')),
                      DropdownMenuItem(value: 9, child: Text('9 Months')),
                      DropdownMenuItem(value: 12, child: Text('1 Year')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedMonths = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxHours * 1.2,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthLabels.length) {
                          return const SizedBox();
                        }

                        // Sparse labels for 9 and 12 months
                        // Show at least 5 labels. For 12 months, every 2nd is 6 labels.
                        if (_selectedMonths > 6) {
                          if (index % 2 != 0) return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthLabels[index],
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: widget.colors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: widget.colors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => widget.colors.surfaceVariant,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}h',
                          TextStyle(
                            color: widget.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
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

/// Monthly Completion Rate Chart
class _CompletionRateChart extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _CompletionRateChart({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  State<_CompletionRateChart> createState() => _CompletionRateChartState();
}

class _CompletionRateChartState extends State<_CompletionRateChart> {
  int _selectedMonths = 3;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = _selectedMonths;
    final List<Map<String, dynamic>> data = [];

    // Loop for selected months (reverse order: oldest to newest)
    for (int i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final nextM = DateTime(now.year, now.month - i + 1, 1);

      final monthSessions = widget.sessions
          .getSessionsInRange(d, nextM)
          .where((s) => s.type == SessionType.focus)
          .toList();

      final completed = monthSessions
          .where((s) => s.status == SessionStatus.completed)
          .length;
      final total = monthSessions.length;
      final rate = total > 0 ? (completed / total) * 100 : 0.0;

      const mNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      data.add({
        'label': mNames[d.month - 1],
        'rate': rate,
        'total': total,
        'completed': completed,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completion Rate',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.colors.textPrimary,
                ),
              ),
              // Custom Toggle for Completion Rate
              Container(
                decoration: BoxDecoration(
                  color: widget.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    for (final val in [3, 6])
                      GestureDetector(
                        onTap: () => setState(() => _selectedMonths = val),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedMonths == val
                                ? widget.colors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${val}M',
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: _selectedMonths == val
                                  ? Colors.white
                                  : widget.colors.textSecondary,
                              fontWeight: _selectedMonths == val
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => widget.colors.surfaceVariant,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = data[group.x.toInt()];
                      final rate = item['rate'] as double;
                      final completed = item['completed'] as int;
                      final total = item['total'] as int;

                      return BarTooltipItem(
                        '${rate.toStringAsFixed(0)}%\n',
                        TextStyle(
                          color: widget.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '$completed/$total sessions',
                            style: TextStyle(
                              color: widget.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[index]['label'] as String,
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.colors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 25,
                      getTitlesWidget: (v, m) => Text(
                        '${v.toInt()}%',
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: widget.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: widget.colors.surfaceVariant,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (index) {
                  final rate = data[index]['rate'] as double;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: rate,
                        color: rate >= 80
                            ? const Color(0xFF059669)
                            : (rate >= 50
                                  ? const Color(0xFFFF6712)
                                  : const Color(0xFFDC2626)),
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: widget.colors.surfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Session Quality Summary (Focused vs Distracted vs Incomplete)
class _SessionQualityCard extends StatefulWidget {
  final SessionsProvider sessions;
  final dynamic colors;
  final ThemeData theme;

  const _SessionQualityCard({
    required this.sessions,
    required this.colors,
    required this.theme,
  });

  @override
  State<_SessionQualityCard> createState() => _SessionQualityCardState();
}

class _SessionQualityCardState extends State<_SessionQualityCard> {
  int _monthOffset = 0; // 0 = current month

  String _getPeriodLabel(DateTime d) {
    const mNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${mNames[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Calculate start/end of the selected month
    final targetMonth = DateTime(now.year, now.month - _monthOffset, 1);
    final nextMonth = DateTime(now.year, now.month - _monthOffset + 1, 1);

    final relevantSessions = widget.sessions
        .getSessionsInRange(targetMonth, nextMonth)
        .where((s) => s.type == SessionType.focus)
        .toList();

    int focusedCount = 0;
    int distractedCount = 0;
    int incompleteCount = 0;

    for (final s in relevantSessions) {
      if (s.status == SessionStatus.completed) {
        if (s.pauseCount >= 4 && !s.isDurationModified) {
          distractedCount++;
        } else {
          focusedCount++;
        }
      } else {
        incompleteCount++;
      }
    }

    final total = focusedCount + distractedCount + incompleteCount;

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
          // Header with Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPeriodLabel(targetMonth),
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session Quality',
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: widget.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: widget.colors.textSecondary,
                    ),
                    onPressed: () => setState(() => _monthOffset++),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: _monthOffset == 0
                          ? widget.colors.textSecondary.withValues(alpha: 0.3)
                          : widget.colors.textSecondary,
                    ),
                    onPressed: _monthOffset == 0
                        ? null
                        : () => setState(() => _monthOffset--),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No sessions recorded',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                _buildQualityRow(
                  label: 'Deep Focus',
                  count: focusedCount,
                  total: total,
                  color: const Color(0xFF059669), // Green
                  icon: Icons.psychology_rounded,
                  desc: 'Completed with < 4 pauses',
                ),
                const SizedBox(height: 16),
                _buildQualityRow(
                  label: 'Distracted',
                  count: distractedCount,
                  total: total,
                  color: const Color(0xFFFF6712), // Orange
                  icon: Icons.notifications_active_rounded,
                  desc: 'Completed but frequent pauses',
                ),
                const SizedBox(height: 16),
                _buildQualityRow(
                  label: 'Incomplete',
                  count: incompleteCount,
                  total: total,
                  color: const Color(0xFFDC2626), // Red
                  icon: Icons.cancel_rounded,
                  desc: 'Interrupted or skipped',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQualityRow({
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
    required String desc,
  }) {
    final percent = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '$count',
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: widget.colors.surfaceVariant,
                        color: color,
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: widget.colors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
