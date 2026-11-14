import 'dart:async';

import 'package:etihad_omlak/app/etihad_app.dart';
import 'package:etihad_omlak/app/theme/app_theme.dart';
import 'package:etihad_omlak/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  testWidgets('login is Arabic RTL and exposes recovery controls', (
    tester,
  ) async {
    await tester.pumpWidget(const EtihadApp());

    expect(find.text('اتحاد الملاك'), findsOneWidget);
    expect(find.byKey(const Key('identityField')), findsOneWidget);
    expect(find.byKey(const Key('forgotPasswordButton')), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('password visibility control toggles obscuring', (tester) async {
    await tester.pumpWidget(const EtihadApp());

    TextField password = tester.widget(find.byKey(const Key('passwordField')));
    expect(password.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('passwordVisibilityButton')));
    await tester.pump();

    password = tester.widget(find.byKey(const Key('passwordField')));
    expect(password.obscureText, isFalse);
  });

  testWidgets('sign in opens the resident dashboard', (tester) async {
    await tester.pumpWidget(const EtihadApp());

    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();

    expect(find.text('عمارة النخيل'), findsOneWidget);
    expect(find.text('المستحق على وحدتك'), findsOneWidget);
    expect(find.text('لا توجد أخبار منشورة بعد'), findsOneWidget);
    expect(find.text('إعلان مهم'), findsNothing);

    final dashboardContext = tester.element(find.text('عمارة النخيل'));
    expect(ModalRoute.of(dashboardContext)?.settings.name, '/dashboard');

    await tester.tap(find.byTooltip('تسجيل الخروج'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('identityField')), findsOneWidget);
    final loginContext = tester.element(find.byKey(const Key('identityField')));
    expect(ModalRoute.of(loginContext)?.settings.name, '/login');
  });

  testWidgets('high contrast option applies the high contrast palette', (
    tester,
  ) async {
    await tester.pumpWidget(const EtihadApp());

    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تباين عالٍ'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, const Color(0xFF003C3D));
    expect(theme.colorScheme.onSurface, Colors.black);
  });

  testWidgets('high contrast login fields keep a visible outline', (
    tester,
  ) async {
    await tester.pumpWidget(const EtihadApp());

    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تباين عالٍ'));
    await tester.pumpAndSettle();

    final fieldContext = tester.element(
      find.byKey(const Key('identityField')),
    );
    final inputTheme = Theme.of(fieldContext).inputDecorationTheme;
    final enabledBorder = inputTheme.enabledBorder;
    final focusedBorder = inputTheme.focusedBorder;

    expect(enabledBorder, isA<OutlineInputBorder>());
    expect(focusedBorder, isA<OutlineInputBorder>());
    if (enabledBorder is! OutlineInputBorder ||
        focusedBorder is! OutlineInputBorder) {
      return;
    }

    expect(
      enabledBorder.borderSide,
      const BorderSide(color: Colors.black, width: 2),
    );
    expect(
      focusedBorder.borderSide,
      const BorderSide(color: Colors.black, width: 3),
    );
  });

  testWidgets('theme survives restart after changes on both app screens', (
    tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    await app.main();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await app.main();
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تباين عالٍ'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await app.main();
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme.primary,
      const Color(0xFF003C3D),
    );
  });

  testWidgets('failed theme save tells the user without closing the app', (
    tester,
  ) async {
    await tester.pumpWidget(
      EtihadApp(
        persistThemeMode: (_) async => throw StateError('storage unavailable'),
      ),
    );

    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داكن'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('تعذر حفظ المظهر. يمكنك اختياره مجددًا.'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('rapid changes save the last selected theme last', (
    tester,
  ) async {
    final firstSave = Completer<void>();
    final savedModes = <AppThemeMode>[];
    await tester.pumpWidget(
      EtihadApp(
        persistThemeMode: (mode) async {
          if (mode == AppThemeMode.dark) await firstSave.future;
          savedModes.add(mode);
        },
      ),
    );

    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('داكن'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('تغيير مظهر التطبيق'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تباين عالٍ'));
    await tester.pumpAndSettle();

    expect(savedModes, isEmpty);
    firstSave.complete();
    await tester.pump();
    expect(savedModes, [AppThemeMode.dark, AppThemeMode.highContrast]);
  });
}
