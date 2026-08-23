import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font choices for the app: DM Sans for UI text, Playfair Display for
/// display/headline styles, JetBrains Mono for code.
///
/// GoogleFonts styles are built at runtime, so everything here is a
/// function or getter rather than a const.
class AppTypography {
  AppTypography._();

  /// Playfair's default figures are old-style — `4` and `7` hang below the
  /// baseline. Every Playfair style here uses lining figures instead.
  static const List<FontFeature> _liningFigures = [FontFeature.liningFigures()];

  // Editor type scale — the editor renders note content, so these are
  // fixed and independent of the UI theme.
  static const double editorBodySize = 18;
  static const double editorBodyHeight = 1.48;
  static const double editorH1Size = 28;
  static const double editorH2Size = 24;
  static const double editorH3Size = 20;

  static TextTheme buildTextTheme(TextTheme base) {
    return GoogleFonts.dmSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.bold,
        fontFeatures: _liningFigures,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.bold,
        fontFeatures: _liningFigures,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w600,
        fontFeatures: _liningFigures,
      ),
      titleLarge: GoogleFonts.dmSans(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Editor body text. Built directly from the font (no TextTheme
  /// inheritance) so editor metrics never shift with UI theme tweaks.
  static TextStyle editorBody({Color? color}) => GoogleFonts.dmSans(
    color: color,
    fontSize: editorBodySize,
    height: editorBodyHeight,
  );

  /// Serif display style outside the standard scale (drawer header,
  /// sheet titles).
  static TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) => GoogleFonts.playfairDisplay(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    fontFeatures: _liningFigures,
  );

  /// Monospace style for code blocks and log output.
  static TextStyle code({
    double? fontSize,
    Color? color,
    double? height,
    FontWeight? fontWeight,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    color: color,
    height: height,
    fontWeight: fontWeight,
  );
}
