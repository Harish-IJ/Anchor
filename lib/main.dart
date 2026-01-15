import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/theme_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/projects_provider.dart';
import 'providers/sessions_provider.dart';
import 'models/focus_session.dart';
import 'models/daily_summary.dart';
import 'widgets/navigation_pill.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(SessionTypeAdapter());
  Hive.registerAdapter(SessionStatusAdapter());
  Hive.registerAdapter(FocusSessionAdapter());
  Hive.registerAdapter(DailySummaryAdapter());

  // Initialize providers
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final timerProvider = TimerProvider();
  await timerProvider.initialize();

  final projectsProvider = ProjectsProvider();
  await projectsProvider.initialize();

  final sessionsProvider = SessionsProvider();
  await sessionsProvider.init();

  // Connect timer to sessions for tracking
  timerProvider.setSessionsProvider(sessionsProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: timerProvider),
        ChangeNotifierProvider.value(value: projectsProvider),
        ChangeNotifierProvider.value(value: sessionsProvider),
      ],
      child: const AnchorApp(),
    ),
  );
}

class AnchorApp extends StatelessWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anchor',
      theme: themeProvider.themeData,
      home: const AppShell(),
    );
  }
}

/// Main app shell with navigation pill overlay
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomePage(), StatsPage(), SettingsPage()];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      body: Stack(
        children: [
          // Page content
          IndexedStack(index: _currentIndex, children: _pages),

          // Floating navigation pill
          NavigationPill(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
            primaryColor: colors.primary,
          ),
        ],
      ),
    );
  }
}
