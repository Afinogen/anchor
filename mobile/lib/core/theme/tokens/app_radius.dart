import 'package:flutter/widgets.dart';

/// Corner radius tokens. Radii do not scale with display density.
class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;

  /// Bottom sheets' top corners.
  static const double sheet = 28;

  /// Buttons and other small pill-shaped controls.
  static const double button = 14;

  /// Sheet drag handle.
  static const double handle = 2;

  static const BorderRadius xsBorder = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlBorder = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius buttonBorder = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius sheetTopBorder = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius handleBorder = BorderRadius.all(
    Radius.circular(handle),
  );
}
