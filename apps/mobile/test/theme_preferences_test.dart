import 'package:etihad_omlak/app/theme/app_theme.dart';
import 'package:etihad_omlak/app/theme/theme_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('loads light when no theme has been saved', () async {
    expect(await ThemePreferences().load(), AppThemeMode.light);
  });

  test('persists all theme choices across preference instances', () async {
    final preferences = ThemePreferences();

    for (final mode in AppThemeMode.values) {
      await preferences.save(mode);
      expect(await ThemePreferences().load(), mode);
    }
  });

  test('ignores an unknown or invalid stored value', () async {
    const key = 'etihad.theme_mode';
    final rawPreferences = SharedPreferencesAsync();

    await rawPreferences.setString(key, 'removed-theme');
    expect(await ThemePreferences().load(), AppThemeMode.light);

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({key: 42});
    expect(await ThemePreferences().load(), AppThemeMode.light);
  });
}
