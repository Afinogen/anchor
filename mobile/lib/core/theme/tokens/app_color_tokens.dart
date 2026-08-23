import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Semantic colors that aren't part of [ColorScheme]: page and sheet
/// gradients, status colors, and the shared card/sheet chrome.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.pageGradient,
    required this.sheetGradient,
    required this.success,
    required this.warning,
    required this.subtleBorder,
    required this.cardFill,
    required this.inputFill,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cardShadow,
    required this.sheetShadow,
  });

  /// Full-screen background behind scrollable pages and the drawer.
  final LinearGradient pageGradient;

  /// Modal bottom sheet background. The dark colors run in the opposite
  /// order to [pageGradient] so sheets read as raised surfaces.
  final LinearGradient sheetGradient;

  final Color success;
  final Color warning;

  /// Hairline border used on glassy cards.
  final Color subtleBorder;

  /// Glassy card fill used by SettingsCard.
  final Color cardFill;

  /// Glassy fill for text fields and search bars.
  final Color inputFill;

  final Color shimmerBase;
  final Color shimmerHighlight;

  final BoxShadow cardShadow;
  final BoxShadow sheetShadow;

  static const light = AppColorTokens(
    pageGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppPalette.gradientLightTop, AppPalette.gradientLightBottom],
    ),
    sheetGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppPalette.surfaceLight, AppPalette.gradientLightTop],
    ),
    success: AppPalette.successLight,
    warning: AppPalette.warningLight,
    subtleBorder: Color(0x0F2D3142), // slate at ~6%
    cardFill: Color(0xCCFFFFFF),
    inputFill: Color(0x99FFFFFF),
    shimmerBase: AppPalette.shimmerBaseLight,
    shimmerHighlight: AppPalette.shimmerHighlightLight,
    cardShadow: BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    sheetShadow: BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      offset: Offset(0, -5),
    ),
  );

  static const dark = AppColorTokens(
    pageGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppPalette.bgDark, AppPalette.surfaceDark],
    ),
    sheetGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppPalette.surfaceDark, AppPalette.bgDark],
    ),
    success: AppPalette.successDark,
    warning: AppPalette.warningDark,
    subtleBorder: Color(0x0FEAEAEA), // offWhite at ~6%
    cardFill: Color(0x0DFFFFFF),
    inputFill: Color(0x1AFFFFFF),
    shimmerBase: AppPalette.shimmerBaseDark,
    shimmerHighlight: AppPalette.shimmerHighlightDark,
    cardShadow: BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    sheetShadow: BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      offset: Offset(0, -5),
    ),
  );

  factory AppColorTokens.of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  AppColorTokens copyWith({
    LinearGradient? pageGradient,
    LinearGradient? sheetGradient,
    Color? success,
    Color? warning,
    Color? subtleBorder,
    Color? cardFill,
    Color? inputFill,
    Color? shimmerBase,
    Color? shimmerHighlight,
    BoxShadow? cardShadow,
    BoxShadow? sheetShadow,
  }) {
    return AppColorTokens(
      pageGradient: pageGradient ?? this.pageGradient,
      sheetGradient: sheetGradient ?? this.sheetGradient,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      cardFill: cardFill ?? this.cardFill,
      inputFill: inputFill ?? this.inputFill,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      cardShadow: cardShadow ?? this.cardShadow,
      sheetShadow: sheetShadow ?? this.sheetShadow,
    );
  }

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      pageGradient:
          LinearGradient.lerp(pageGradient, other.pageGradient, t) ??
          pageGradient,
      sheetGradient:
          LinearGradient.lerp(sheetGradient, other.sheetGradient, t) ??
          sheetGradient,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
      sheetShadow: BoxShadow.lerp(sheetShadow, other.sheetShadow, t)!,
    );
  }
}
