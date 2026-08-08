import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_typography.dart';
import 'tokens/app_color_tokens.dart';
import 'tokens/app_dimensions.dart';
import 'tokens/app_radius.dart';

class AppTheme {
  // A unique, sophisticated palette
  // Deep Ocean & Sand theme
  static const _primaryLight = Color(0xFF2D3142); // Dark Slate
  static const _primaryDark = Color(0xFFEAEAEA); // Off-white text for dark mode

  static const _bgLight = Color(0xFFF0F4F8); // Cool Gray/Blue tint
  static const _bgDark = Color(0xFF1C1E26); // Deep Blue-Black

  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _surfaceDark = Color(0xFF262A36);

  static const _accent = Color(0xFFEF8354); // Burnt Orange for interaction
  static const _secondary = Color(0xFF4F5D75); // Slate Blue

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final primary = isDark ? _primaryDark : _primaryLight;
    final surface = isDark ? _surfaceDark : _surfaceLight;
    final dims = AppDimensions.comfortable;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _secondary,
        primary: primary,
        secondary: _secondary,
        tertiary: _accent,
        surface: isDark ? _bgDark : _bgLight,
        onSurface: primary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: isDark ? _bgDark : _bgLight,
      textTheme: AppTypography.buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: Platform.isIOS,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: brightness, // iOS
          statusBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark, // Android
          statusBarColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: BorderSide.none,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? _accent : _primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(dims.lg),
        hintStyle: TextStyle(color: _secondary.withValues(alpha: 0.5)),
      ),
      extensions: [dims, AppColorTokens.of(brightness)],
    );
  }
}
