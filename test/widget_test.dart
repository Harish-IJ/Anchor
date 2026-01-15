import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anchor/main.dart';
import 'package:anchor/theme/theme_provider.dart';

void main() {
  testWidgets('App renders with navigation pill', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const AnchorApp(),
      ),
    );

    // Verify home page content is visible
    expect(find.text('Hello, User!'), findsOneWidget);

    // Verify navigation icons exist
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('Navigation switches pages', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const AnchorApp(),
      ),
    );

    // Initially on Home page
    expect(find.text('Hello, User!'), findsOneWidget);

    // Tap stats icon
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);

    // Tap settings icon
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });
}
