import 'package:flutter/widgets.dart';

/// Raw brand colors — "Deep Ocean & Sand".
class AppPalette {
  AppPalette._();

  static const slate = Color(0xFF2D3142); // primary, light mode
  static const offWhite = Color(0xFFEAEAEA); // primary, dark mode
  static const slateBlue = Color(0xFF4F5D75); // secondary, and the seed color
  static const burntOrange = Color(0xFFEF8354); // accent

  // Light surfaces.
  static const bgLight = Color(0xFFF0F4F8);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const gradientLightTop = Color(0xFFF8F9FC);
  static const gradientLightBottom = Color(0xFFEEF1F8);

  // Dark surfaces. The page gradient runs between these two.
  static const bgDark = Color(0xFF1C1E26);
  static const surfaceDark = Color(0xFF262A36);

  // Status colors with no ColorScheme equivalent.
  static const successLight = Color(0xFF2E7D32);
  static const successDark = Color(0xFF4CAF50);
  static const warningLight = Color(0xFFE65100);
  static const warningDark = Color(0xFFFF9800);

  static const shimmerBaseLight = Color(0xFFE5E9EE);
  static const shimmerHighlightLight = Color(0xFFF2F4F8);
  static const shimmerBaseDark = Color(0xFF3A3E4A);
  static const shimmerHighlightDark = Color(0xFF484D5A);
}
