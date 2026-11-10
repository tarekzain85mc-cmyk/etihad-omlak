import 'package:flutter/material.dart';

import 'app/etihad_app.dart';
import 'app/theme/theme_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = ThemePreferences();
  final initialThemeMode = await preferences.load();
  runApp(
    EtihadApp(
      initialThemeMode: initialThemeMode,
      persistThemeMode: preferences.save,
    ),
  );
}
