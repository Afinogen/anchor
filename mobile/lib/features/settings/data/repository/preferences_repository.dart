import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Repository for managing user preferences in secure storage
class PreferencesRepository {
  final FlutterSecureStorage _storage;

  const PreferencesRepository(this._storage);

  // Editor preferences keys
  static const _sortChecklistItemsKey = 'editor_sort_checklist_items';

  // Theme preferences keys
  static const _themeModeKey = 'theme_mode';

  // Locale preferences keys
  static const _localeKey = 'app_locale';

  // Editor preferences methods
  Future<bool> getSortChecklistItems() async {
    final value = await _storage.read(key: _sortChecklistItemsKey);
    return value != 'false'; // Default to true
  }

  Future<void> setSortChecklistItems(bool value) async {
    await _storage.write(key: _sortChecklistItemsKey, value: value.toString());
  }

  // Theme preferences methods
  Future<String?> getThemeMode() async {
    return await _storage.read(key: _themeModeKey);
  }

  Future<void> setThemeMode(String mode) async {
    await _storage.write(key: _themeModeKey, value: mode);
  }

  // Locale preferences methods
  Future<String?> getLocale() async {
    return await _storage.read(key: _localeKey);
  }

  Future<void> setLocale(String languageCode) async {
    await _storage.write(key: _localeKey, value: languageCode);
  }
}
