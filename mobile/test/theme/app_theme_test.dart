import 'package:anchor/core/theme/app_theme.dart';
import 'package:anchor/core/theme/tokens/app_color_tokens.dart';
import 'package:anchor/core/theme/tokens/app_dimensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme', () {
    for (final (name, build) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      group(name, () {
        testWidgets('registers both theme extensions', (tester) async {
          final theme = build();
          expect(theme.extension<AppDimensions>(), isNotNull);
          expect(theme.extension<AppColorTokens>(), isNotNull);
        });

        testWidgets('color scheme brightness matches the theme', (
          tester,
        ) async {
          final theme = build();
          expect(theme.colorScheme.brightness, theme.brightness);
        });

        testWidgets('page background is the scaffold background', (
          tester,
        ) async {
          final theme = build();
          expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
        });

        testWidgets('the seed tonal ramp is left intact', (tester) async {
          final theme = build();
          final cs = theme.colorScheme;
          final ramp = {
            cs.surfaceContainerLowest,
            cs.surfaceContainerLow,
            cs.surfaceContainer,
            cs.surfaceContainerHigh,
            cs.surfaceContainerHighest,
          };
          expect(ramp.length, 5);
          expect(ramp, isNot(contains(cs.surface)));
          expect(cs.surfaceContainerHighest, isNot(theme.cardTheme.color));
          expect(cs.surfaceContainerHighest, isNot(cs.surface));
        });

        testWidgets('cards sit on an opaque surface, not the page color', (
          tester,
        ) async {
          final theme = build();
          expect(theme.cardTheme.color, isNotNull);
          expect(theme.cardTheme.color, isNot(theme.colorScheme.surface));
          expect(theme.snackBarTheme.backgroundColor, theme.cardTheme.color);
        });

        testWidgets('carries component defaults so call sites stay thin', (
          tester,
        ) async {
          final theme = build();
          expect(theme.filledButtonTheme.style, isNotNull);
          expect(theme.outlinedButtonTheme.style, isNotNull);
          expect(theme.textButtonTheme.style, isNotNull);
          expect(theme.dividerTheme.color, isNotNull);
          expect(theme.dialogTheme.shape, isNotNull);
          expect(theme.bottomSheetTheme.shape, isNotNull);
          expect(theme.snackBarTheme.shape, isNotNull);
          expect(theme.inputDecorationTheme.fillColor, isNotNull);
        });

        testWidgets('divider color comes from the color tokens', (
          tester,
        ) async {
          final theme = build();
          expect(
            theme.dividerTheme.color,
            theme.extension<AppColorTokens>()!.subtleBorder,
          );
        });

        testWidgets('input fill comes from the color tokens', (tester) async {
          final theme = build();
          expect(
            theme.inputDecorationTheme.fillColor,
            theme.extension<AppColorTokens>()!.inputFill,
          );
        });
      });
    }

    testWidgets('light and dark are actually different', (tester) async {
      expect(
        AppTheme.light().scaffoldBackgroundColor,
        isNot(AppTheme.dark().scaffoldBackgroundColor),
      );
    });

    testWidgets('each brightness/density pair is built once and cached', (
      tester,
    ) async {
      expect(identical(AppTheme.light(), AppTheme.light()), isTrue);
      expect(
        identical(
          AppTheme.light(DisplayDensity.compact),
          AppTheme.light(DisplayDensity.compact),
        ),
        isTrue,
      );
      expect(
        identical(AppTheme.light(), AppTheme.light(DisplayDensity.compact)),
        isFalse,
      );
    });

    testWidgets('density selects the matching dimensions', (tester) async {
      for (final density in DisplayDensity.values) {
        expect(
          AppTheme.light(density).extension<AppDimensions>(),
          AppDimensions.of(density),
        );
      }
    });
  });
}
