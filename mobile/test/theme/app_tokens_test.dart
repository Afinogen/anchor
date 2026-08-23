import 'package:anchor/core/theme/context_extensions.dart';
import 'package:anchor/core/theme/tokens/app_color_tokens.dart';
import 'package:anchor/core/theme/tokens/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColorTokens', () {
    test('of() picks the variant matching the brightness', () {
      expect(AppColorTokens.of(Brightness.light), AppColorTokens.light);
      expect(AppColorTokens.of(Brightness.dark), AppColorTokens.dark);
    });

    test('light and dark differ on every color', () {
      final l = AppColorTokens.light;
      final d = AppColorTokens.dark;
      expect(l.subtleBorder, isNot(d.subtleBorder));
      expect(l.cardFill, isNot(d.cardFill));
      expect(l.inputFill, isNot(d.inputFill));
      expect(l.success, isNot(d.success));
      expect(l.warning, isNot(d.warning));
      expect(l.shimmerBase, isNot(d.shimmerBase));
      expect(l.pageGradient.colors, isNot(d.pageGradient.colors));
    });

    test('the sheet gradient runs opposite to the page gradient', () {
      expect(
        AppColorTokens.dark.sheetGradient.colors,
        AppColorTokens.dark.pageGradient.colors.reversed.toList(),
      );
    });

    test('lerp returns the endpoints at t=0 and t=1', () {
      final l = AppColorTokens.light;
      final d = AppColorTokens.dark;
      expect(l.lerp(d, 0).cardFill, l.cardFill);
      expect(l.lerp(d, 1).cardFill, d.cardFill);
      expect(l.lerp(d, 0).success, l.success);
      expect(l.lerp(d, 1).warning, d.warning);
    });

    test('copyWith replaces only what it is given', () {
      final tokens = AppColorTokens.light.copyWith(success: Colors.pink);
      expect(tokens.success, Colors.pink);
      expect(tokens.warning, AppColorTokens.light.warning);
      expect(tokens.cardFill, AppColorTokens.light.cardFill);
    });
  });

  group('AppDimensions', () {
    test('of() maps each density to its own values', () {
      expect(AppDimensions.of(DisplayDensity.compact), AppDimensions.compact);
      expect(AppDimensions.of(DisplayDensity.standard), AppDimensions.standard);
    });

    test('the spacing scale grows with density', () {
      for (final read in <double Function(AppDimensions)>[
        (d) => d.xxs,
        (d) => d.xs,
        (d) => d.sm,
        (d) => d.md,
        (d) => d.lg,
        (d) => d.xl,
        (d) => d.xxl,
        (d) => d.screenGutter,
        (d) => d.pagePadding,
        (d) => d.sectionGap,
        (d) => d.searchBarHeight,
        (d) => d.appBarExpandedHeight,
        (d) => d.largeAppBarHeight,
      ]) {
        expect(
          read(AppDimensions.compact),
          lessThan(read(AppDimensions.standard)),
        );
      }
    });

    test('the spacing scale is monotonic within a density', () {
      for (final dims in [AppDimensions.compact, AppDimensions.standard]) {
        final scale = [
          dims.xxs,
          dims.xs,
          dims.sm,
          dims.md,
          dims.lg,
          dims.xl,
          dims.xxl,
        ];
        for (var i = 1; i < scale.length; i++) {
          expect(scale[i], greaterThan(scale[i - 1]));
        }
      }
    });

    test('screenInsets follows screenGutter', () {
      expect(
        AppDimensions.standard.screenInsets,
        EdgeInsets.all(AppDimensions.standard.screenGutter),
      );
    });

    test('lerp returns the endpoints at t=0 and t=1', () {
      final c = AppDimensions.compact;
      final s = AppDimensions.standard;
      expect(c.lerp(s, 0).md, c.md);
      expect(c.lerp(s, 1).md, s.md);
      expect(c.lerp(s, 0.5).md, (c.md + s.md) / 2);
    });

    test('copyWith replaces only what it is given', () {
      final dims = AppDimensions.standard.copyWith(md: 99);
      expect(dims.md, 99);
      expect(dims.lg, AppDimensions.standard.lg);
    });
  });

  group('context extensions', () {
    testWidgets('fall back to defaults under a bare MaterialApp', (
      tester,
    ) async {
      late AppDimensions dims;
      late AppColorTokens tokens;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              dims = context.dims;
              tokens = context.colorTokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(dims, AppDimensions.standard);
      expect(tokens, AppColorTokens.light);
    });

    testWidgets('fall back to the dark tokens under a dark bare theme', (
      tester,
    ) async {
      late AppColorTokens tokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              tokens = context.colorTokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tokens, AppColorTokens.dark);
    });

    testWidgets('read the registered extensions when they are present', (
      tester,
    ) async {
      late AppDimensions dims;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppDimensions.compact]),
          home: Builder(
            builder: (context) {
              dims = context.dims;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(dims, AppDimensions.compact);
    });
  });
}
