import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import 'theme/app_theme.dart';

class EtihadApp extends StatefulWidget {
  const EtihadApp({
    this.initialThemeMode = AppThemeMode.light,
    this.persistThemeMode,
    super.key,
  });

  final AppThemeMode initialThemeMode;
  final Future<void> Function(AppThemeMode)? persistThemeMode;

  @override
  State<EtihadApp> createState() => _EtihadAppState();
}

class _EtihadAppState extends State<EtihadApp> {
  static const _loginRoute = '/login';
  static const _dashboardRoute = '/dashboard';

  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  Future<void> _pendingThemeSave = Future<void>.value();
  late AppThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

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
      scaffoldMessengerKey: _scaffoldMessengerKey,
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
    final persist = widget.persistThemeMode;
    if (persist == null) return;
    _pendingThemeSave = _pendingThemeSave.then(
      (_) => _persistTheme(persist, value),
    );
  }

  Future<void> _persistTheme(
    Future<void> Function(AppThemeMode) persist,
    AppThemeMode value,
  ) async {
    try {
      await persist(value);
    } catch (_) {
      if (!mounted) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('تعذر حفظ المظهر. يمكنك اختياره مجددًا.')),
      );
    }
  }

  void _replaceRoute(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }
}
