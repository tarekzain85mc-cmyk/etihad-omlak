import 'package:etihad_omlak/app/etihad_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.text('إعلان مهم'), findsOneWidget);

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
}
