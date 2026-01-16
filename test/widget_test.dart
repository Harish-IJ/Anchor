import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anchor/main.dart';
import 'package:anchor/theme/theme_provider.dart';
import 'package:anchor/providers/timer_provider.dart';
import 'package:anchor/providers/sessions_provider.dart';
import 'package:anchor/providers/projects_provider.dart';
import 'package:anchor/providers/preferences_provider.dart';

void main() {
  testWidgets('App renders AppShell with navigation', (
    WidgetTester tester,
  ) async {
    // Create all required providers
    final themeProvider = ThemeProvider();
    final sessionsProvider = SessionsProvider();
    final timerProvider = TimerProvider();
    final projectsProvider = ProjectsProvider();
    final preferencesProvider = PreferencesProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: sessionsProvider),
          ChangeNotifierProvider.value(value: timerProvider),
          ChangeNotifierProvider.value(value: projectsProvider),
          ChangeNotifierProvider.value(value: preferencesProvider),
        ],
        // Test AppShell directly to bypass splash screen
        child: MaterialApp(
          home: const AppShell(),
          theme: themeProvider.themeData,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify navigation icons exist
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('Navigation switches pages', (WidgetTester tester) async {
    // Create all required providers
    final themeProvider = ThemeProvider();
    final sessionsProvider = SessionsProvider();
    final timerProvider = TimerProvider();
    final projectsProvider = ProjectsProvider();
    final preferencesProvider = PreferencesProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: sessionsProvider),
          ChangeNotifierProvider.value(value: timerProvider),
          ChangeNotifierProvider.value(value: projectsProvider),
          ChangeNotifierProvider.value(value: preferencesProvider),
        ],
        child: MaterialApp(
          home: const AppShell(),
          theme: themeProvider.themeData,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap stats icon
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();

    // Tap settings icon
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}
