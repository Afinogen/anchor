import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/app_initializer.dart' as app_init;
import '../../../../core/theme/tokens/app_dimensions.dart';
import 'editor_preferences_controller.dart';

part 'theme_preferences_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    // Use the theme loaded before app started (no flash)
    return app_init.initialThemeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final repository = ref.read(preferencesRepositoryProvider);
    await repository.setThemeMode(mode.name);
  }
}

@Riverpod(keepAlive: true)
class DisplayDensityController extends _$DisplayDensityController {
  @override
  DisplayDensity build() {
    return app_init.initialDisplayDensity;
  }

  Future<void> setDensity(DisplayDensity density) async {
    state = density;
    final repository = ref.read(preferencesRepositoryProvider);
    await repository.setDisplayDensity(density.name);
  }
}
