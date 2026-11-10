import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class ThemePreferences {
  ThemePreferences({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'etihad.theme_mode';

  final SharedPreferencesAsync _preferences;

  Future<AppThemeMode> load() async {
    try {
      final stored = await _preferences.getString(_key);
      for (final mode in AppThemeMode.values) {
        if (mode.name == stored) return mode;
      }
    } catch (_) {
      // A damaged local preference must not prevent the app from opening.
    }
    return AppThemeMode.light;
  }

  Future<void> save(AppThemeMode mode) =>
      _preferences.setString(_key, mode.name);
}
