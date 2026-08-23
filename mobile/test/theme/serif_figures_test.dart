import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anchor/core/theme/app_theme.dart';
import 'package:anchor/core/theme/app_typography.dart';

void main() {
  testWidgets('serif styles use lining figures', (tester) async {
    final styles = <String, TextStyle?>{
      'serif': AppTypography.serif(fontSize: 20),
      'displayLarge': AppTheme.light().textTheme.displayLarge,
      'displayMedium': AppTheme.light().textTheme.displayMedium,
      'headlineMedium': AppTheme.light().textTheme.headlineMedium,
    };

    for (final entry in styles.entries) {
      expect(
        entry.value?.fontFeatures,
        contains(const FontFeature.liningFigures()),
        reason: '${entry.key} would render "Note 4" with a descending 4',
      );
    }
  });
}
