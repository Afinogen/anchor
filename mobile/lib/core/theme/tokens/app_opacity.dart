/// Emphasis scale for colors layered over a surface.
class AppOpacity {
  AppOpacity._();

  /// Hairline borders and the faintest dividers.
  static const double hairline = 0.06;

  /// Tinted fill behind an icon chip or a selected row.
  static const double subtleFill = 0.1;

  /// Selected-state fill, one step above [subtleFill].
  static const double activeFill = 0.15;

  /// Visible borders and outlines.
  static const double border = 0.2;

  /// Disabled controls and de-emphasised trailing icons.
  static const double disabled = 0.4;

  /// Secondary text and subtitles.
  static const double secondary = 0.6;

  /// Near-full emphasis — body text that is not quite primary.
  static const double strong = 0.8;
}
