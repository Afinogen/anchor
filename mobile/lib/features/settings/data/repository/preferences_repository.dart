import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure-storage keys for user preferences, shared with `initializeApp`,
/// which reads some of them before Riverpod exists.
class PreferenceKeys {
  PreferenceKeys._();

  static const sortChecklistItems = 'editor_sort_checklist_items';
  static const themeMode = 'theme_mode';
  static const displayDensity = 'display_density';
  static const locale = 'app_locale';
}

/// Repository for managing user preferences in secure storage
class PreferencesRepository {
  final FlutterSecureStorage _storage;

  const PreferencesRepository(this._storage);

  // Editor preferences methods
  Future<bool> getSortChecklistItems() async {
    final value = await _storage.read(key: PreferenceKeys.sortChecklistItems);
    return value != 'false'; // Default to true
  }

  Future<void> setSortChecklistItems(bool value) async {
    await _storage.write(
      key: PreferenceKeys.sortChecklistItems,
      value: value.toString(),
    );
  }

  // Theme preferences methods
  Future<void> setThemeMode(String mode) async {
    await _storage.write(key: PreferenceKeys.themeMode, value: mode);
  }

  Future<void> setDisplayDensity(String density) async {
    await _storage.write(key: PreferenceKeys.displayDensity, value: density);
  }

  // Locale preferences methods
  Future<String?> getLocale() async {
    return await _storage.read(key: PreferenceKeys.locale);
  }

  Future<void> setLocale(String languageCode) async {
    await _storage.write(key: PreferenceKeys.locale, value: languageCode);
  }
}
