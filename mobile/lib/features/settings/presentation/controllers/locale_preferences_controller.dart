import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_initializer.dart' as app_init;
import 'editor_preferences_controller.dart';

/// Controls the active app locale. Uses a manual [NotifierProvider] (no
/// riverpod codegen) so it can be added without running build_runner.
final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    // Use the locale resolved before the app started (auto-detected on first
    // run, otherwise the user's saved choice).
    return app_init.initialLocale;
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = app_init.resolveSupportedLocale(locale.languageCode);
    state = resolved;
    // Keep the out-of-widget-tree mirror in sync for the Dio interceptor.
    app_init.currentAppLocale = resolved;
    final repository = ref.read(preferencesRepositoryProvider);
    await repository.setLocale(resolved.languageCode);
  }
}
