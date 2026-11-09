import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import 'theme/app_theme.dart';

class EtihadApp extends StatefulWidget {
  const EtihadApp({super.key});

  @override
  State<EtihadApp> createState() => _EtihadAppState();
}

class _EtihadAppState extends State<EtihadApp> {
  static const _loginRoute = '/login';
  static const _dashboardRoute = '/dashboard';

  final _navigatorKey = GlobalKey<NavigatorState>();
  AppThemeMode _themeMode = AppThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'اتحاد الملاك',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: _themeMode == AppThemeMode.highContrast
          ? AppTheme.highContrast
          : AppTheme.light,
      darkTheme: AppTheme.dark,
      highContrastTheme: AppTheme.highContrast,
      themeMode: _themeMode.themeMode,
      navigatorKey: _navigatorKey,
      initialRoute: _loginRoute,
      routes: {
        _loginRoute: (_) => LoginScreen(
          themeMode: _themeMode,
          onThemeChanged: _setTheme,
          onSignedIn: () => _replaceRoute(_dashboardRoute),
        ),
        _dashboardRoute: (_) => DashboardScreen(
          themeMode: _themeMode,
          onThemeChanged: _setTheme,
          onSignOut: () => _replaceRoute(_loginRoute),
        ),
      },
    );
  }

  void _setTheme(AppThemeMode value) {
    setState(() => _themeMode = value);
  }

  void _replaceRoute(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }
}
