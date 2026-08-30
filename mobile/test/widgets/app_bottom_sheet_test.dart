import 'package:anchor/core/theme/app_theme.dart';
import 'package:anchor/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('show() presents chrome, header, and child; Done pops', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => AppBottomSheet.show(
                  context,
                  builder: (_) => const AppBottomSheet(
                    icon: LucideIcons.settings2,
                    title: 'Sheet Title',
                    subtitle: 'Sheet subtitle',
                    showDone: true,
                    child: Text('Sheet body'),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet Title'), findsOneWidget);
    expect(find.text('Sheet subtitle'), findsOneWidget);
    expect(find.text('Sheet body'), findsOneWidget);
    expect(find.byIcon(LucideIcons.settings2), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet Title'), findsNothing);
  });

  testWidgets('show() returns the value the sheet pops with', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  result = await AppBottomSheet.show<String>(
                    context,
                    builder: (_) => AppBottomSheet(
                      title: 'Pick',
                      child: Builder(
                        builder: (sheetContext) => TextButton(
                          onPressed: () =>
                              Navigator.pop(sheetContext, 'chosen'),
                          child: const Text('Choose'),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(result, 'chosen');
  });

  testWidgets('a null cancelText leaves one full-width action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SheetActionButtons(
            cancelText: null,
            confirmText: 'Got it',
            onConfirm: () {},
          ),
        ),
      ),
    );

    expect(find.text('Got it'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
