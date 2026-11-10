import 'package:etihad_omlak/app/theme/app_theme.dart';
import 'package:etihad_omlak/features/announcements/domain/announcement.dart';
import 'package:etihad_omlak/features/announcements/presentation/announcements_screen.dart';
import 'package:etihad_omlak/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _a(
  String id,
  int day, {
  bool pinned = false,
  bool important = false,
}) => Announcement(
  id: id,
  title: 'عنوان $id',
  body: 'نص $id',
  publishedAt: DateTime(2026, 1, day, 9),
  isPinned: pinned,
  isImportant: important,
);

Widget _dashboard(List<Announcement> items) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: DashboardScreen(
    themeMode: AppThemeMode.light,
    onThemeChanged: (_) {},
    onSignOut: () {},
    announcements: items,
  ),
);

void main() {
  test('sort: pinned, newest, then id; important does not affect order', () {
    final sorted = sortAnnouncements([
      _a('c', 5),
      _a('b', 5, important: true),
      _a('a', 9),
      _a('p', 1, pinned: true),
    ]);
    expect(sorted.map((e) => e.id), ['p', 'a', 'b', 'c']);
  });

  testWidgets('empty state shows exact text and no fake news', (tester) async {
    await tester.pumpWidget(_dashboard(const []));
    expect(find.text('لا توجد أخبار منشورة بعد'), findsOneWidget);
    expect(find.text('إعلان مهم'), findsNothing);
  });

  testWidgets('list shows ordered items with badges, opens and goes back', (
    tester,
  ) async {
    await tester.pumpWidget(
      _dashboard([
        _a('c', 5),
        _a('b', 5, important: true),
        _a('p', 1, pinned: true),
      ]),
    );
    expect(find.text('عنوان p'), findsOneWidget);

    await tester.tap(find.byKey(const Key('announcementsCard')));
    await tester.pumpAndSettle();

    expect(find.text('أخبار العمارة'), findsOneWidget);
    final top = <double>[
      for (final id in ['p', 'b', 'c'])
        tester.getTopLeft(find.text('عنوان $id')).dy,
    ];
    expect(top[0] < top[1] && top[1] < top[2], isTrue);
    expect(find.text('مثبت'), findsOneWidget);
    expect(find.text('مهم'), findsOneWidget);
    expect(find.bySemanticsLabel('خبر مثبت'), findsOneWidget);
    expect(find.bySemanticsLabel('خبر مهم'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('عمارة النخيل'), findsOneWidget);
  });

  testWidgets('Arabic news list is RTL with accessible title and badges', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _dashboard([_a('p', 1, pinned: true, important: true)]),
    );

    await tester.tap(find.byKey(const Key('announcementsCard')));
    await tester.pumpAndSettle();

    final screen = tester.element(find.byType(AnnouncementsScreen));
    expect(Directionality.of(screen), TextDirection.rtl);
    expect(
      tester.getSemantics(find.text('عنوان p')),
      matchesSemantics(label: 'عنوان p', isHeader: true),
    );
    expect(find.bySemanticsLabel('خبر مثبت'), findsOneWidget);
    expect(find.bySemanticsLabel('خبر مهم'), findsOneWidget);
    semantics.dispose();
  });
}
