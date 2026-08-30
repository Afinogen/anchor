import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anchor/core/theme/app_theme.dart';
import 'package:anchor/core/theme/tokens/app_dimensions.dart';
import 'package:anchor/features/notes/presentation/widgets/notes_search_bar.dart';

Future<double> _heightAt(
  WidgetTester tester,
  DisplayDensity density, {
  String query = '',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(density),
      home: Scaffold(
        body: NotesSearchBar(
          controller: TextEditingController(text: query),
          query: query,
          onChanged: (_) {},
          onClear: () {},
        ),
      ),
    ),
  );
  // MaterialApp lerps theme changes, and AppDimensions lerps with it.
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(SearchBar)).height;
}

void main() {
  testWidgets('the bar tracks the display density', (tester) async {
    final standard = await _heightAt(tester, DisplayDensity.standard);
    final compact = await _heightAt(tester, DisplayDensity.compact);

    expect(standard, AppDimensions.standard.searchBarHeight);
    expect(compact, AppDimensions.compact.searchBarHeight);
    expect(compact, lessThan(standard));
  });

  testWidgets('the clear button does not stretch the bar', (tester) async {
    for (final density in DisplayDensity.values) {
      final empty = await _heightAt(tester, density);
      final typed = await _heightAt(tester, density, query: 'note');

      expect(find.byTooltip('Clear search'), findsOneWidget);
      expect(typed, empty, reason: 'a 48px IconButton would force it taller');
    }
  });
}
