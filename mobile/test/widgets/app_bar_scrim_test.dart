import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anchor/core/theme/app_theme.dart';
import 'package:anchor/core/widgets/app_bar_scrim.dart';
import 'package:anchor/core/widgets/app_page_bar.dart';
import 'package:anchor/core/widgets/app_page_scaffold.dart';

LinearGradient _scrimGradient(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(AppBarScrim),
      matching: find.byType(Container),
    ),
  );
  return (container.decoration as BoxDecoration).gradient as LinearGradient;
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('the scrim ends fully transparent in $brightness', (
      tester,
    ) async {
      // GoogleFonts loads asynchronously, so build the theme in the test.
      final theme = brightness == Brightness.dark
          ? AppTheme.dark()
          : AppTheme.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SizedBox(height: 80, child: AppBarScrim()),
          ),
        ),
      );

      final gradient = _scrimGradient(tester);

      expect(gradient.colors.last.a, 0);
      expect(gradient.colors.first.a, 1);
      expect(gradient.colors.first, theme.colorScheme.surface);
    });
  }

  testWidgets('an AppPageBar paints no colour of its own', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(appBar: AppPageBar(title: Text('Archive'))),
      ),
    );

    final bar = tester.widget<AppBar>(find.byType(AppBar));
    expect(bar.backgroundColor, Colors.transparent);
    expect(find.byType(AppBarScrim), findsOneWidget);
  });

  testWidgets('AppPageScaffold runs its wash behind the bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const AppPageScaffold(title: Text('History'), body: SizedBox()),
      ),
    );

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).extendBodyBehindAppBar,
      isTrue,
    );
  });
}
