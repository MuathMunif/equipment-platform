import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:equipment_app/api.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class JournalFixture {
  final String locale, role, mode;
  final List<String> capabilities;
  final requests = <http.Request>[];
  JournalFixture({
    this.locale = 'ar',
    this.role = 'OWNER',
    this.mode = 'DIRECT',
    this.capabilities = const [
      'FINANCE_VIEW',
      'FINANCE_MANAGE',
      'EQUIPMENT_VIEW',
    ],
  });
  Map<String, Object> entry(int index) => {
    'id': 'entry$index',
    'entryType': 'EXPENSE',
    'amount': '1000.00',
    'currency': 'SAR',
    'category': 'FUEL',
    'equipmentId': 'eq',
    'equipmentName': 'Truck EQ-1',
    'expenseScope': 'SINGLE',
    'operationDate': '2026-10-02',
    'lifecycle': 'POSTED',
    'settlementStatus': 'PARTIAL',
    'paid': '600.00',
    'refunded': '0.00',
    'netPaid': '600.00',
    'refundable': '600.00',
    'remaining': '400.00',
    'note': '',
    'settlements': [],
    'refunds': [],
  };
  late final api = Api(
    persistNative: false,
    base: 'http://localhost/api/v1',
    client: MockClient((r) async {
      requests.add(r);
      final path = r.url.path;
      Object result;
      if (path == '/auth/me' || path.endsWith('/auth/me')) {
        result = {
          'name': 'Owner',
          'userId': 'u',
          'preferredLocale': locale,
          'lastWorkspaceId': 'workspace',
          'workspaces': [
            {
              'id': 'workspace',
              'name': 'Review workspace',
              'role': role,
              'financialMode': mode,
              'capabilities': capabilities,
            },
          ],
        };
      } else if (path.endsWith('/dashboard')) {
        result = {
          if (role == 'OWNER' || capabilities.contains('EQUIPMENT_VIEW'))
            'activeEquipmentCount': 1,
          if (role == 'OWNER' || capabilities.contains('FINANCE_VIEW')) ...{
            'summary': {
              'recordedExpenses': '1000.00',
              'recordedIncome': '4500.00',
            },
            'recentEntries': [
              {
                'entryId': 'entry0',
                'entryType': 'EXPENSE',
                'amount': '1000.00',
                'operationDate': '2026-10-02',
              },
            ],
          },
        };
      } else if (path.endsWith('/notifications/unread-count')) {
        result = {'unreadCount': 0};
      } else if (path.endsWith('/attention') ||
          path.endsWith('/incomplete') ||
          path.endsWith('/attachments')) {
        result = [];
      } else if (path.endsWith('/entries')) {
        result = {
          'items': [for (var i = 0; i < 4; i++) entry(i)],
          'total': 4,
        };
      } else if (RegExp(r'/entries/entry\d$').hasMatch(path)) {
        result = entry(int.parse(path.substring(path.length - 1)));
      } else {
        result = {'items': [], 'total': 0};
      }
      return http.Response(
        jsonEncode(result),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }),
  );
}

Future<void> mount(
  WidgetTester tester,
  JournalFixture fixture, {
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = FakeViewPadding(top: 59, bottom: 34);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  // The REAL application owns MaterialApp, Navigator, Theme and WorkspacePage.
  // No artificial test Scaffold or DefaultTextStyle is supplied to the route.
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('journalEvidence'),
      child: EquipmentApp(api: fixture.api),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations loc(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
Future<void> openShortcut(WidgetTester tester) async {
  final button = find.byKey(const Key('homeViewJournal'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void assertShell(WidgetTester tester, AppLocalizations l, {double scale = 1}) {
  final subtitle = find.text(l.uiEachEntryItsPaymentsAndAttachmentsIn);
  final element = tester.element(subtitle);
  final effective = DefaultTextStyle.of(element).style
      .merge(tester.widget<Text>(subtitle).style);
  final expected = Theme.of(element).textTheme.bodyMedium!;
  expect(effective.fontFamily, 'EquipmentAlmarai');
  expect(effective.fontFamilyFallback, ['EquipmentPlex']);
  expect(effective.fontWeight, FontWeight.w400);
  expect(effective.fontSize, expected.fontSize);
  expect(effective.height, expected.height);
  expect(effective.color, expected.color);
  expect(effective.decoration ?? TextDecoration.none, TextDecoration.none);
  expect(MediaQuery.textScalerOf(element).scale(14), closeTo(14 * scale, .001));
  expect(
    find.ancestor(of: subtitle, matching: find.byType(Scaffold)),
    findsOneWidget,
  );
  final surface = find.ancestor(of: subtitle, matching: find.byType(Material));
  expect(surface, findsOneWidget);
  expect(tester.widget<Material>(surface).color, EquipmentA.canvas);
  expect(
    tester.getTopLeft(find.byType(LedgerPage)).dy,
    greaterThanOrEqualTo(59 + kToolbarHeight),
  );
  expect(
    tester.getBottomLeft(find.byType(ListView).last).dy,
    lessThanOrEqualTo(844 - 34),
  );
  expect(find.byType(MaterialApp), findsOneWidget);
  expect(find.byType(AppBar), findsOneWidget);
}

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('JOURNAL_SHELL_EVIDENCE')) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('journalEvidence')),
    );
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '../docs/design/ui-refresh/bugfixes/journal-navigation-shell/screenshots/harness-$name.png',
    ).writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final (family, files) in [
      ('EquipmentAlmarai', ['Almarai-Regular.ttf', 'Almarai-Bold.ttf']),
      (
        'EquipmentPlex',
        ['IBMPlexSansArabic-Regular.ttf', 'IBMPlexSansArabic-Bold.ttf'],
      ),
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        loader.addFont(rootBundle.load('assets/typography_fonts/$file'));
      }
      await loader.load();
    }
  });
  for (final (locale, scale) in [('ar', 1.0), ('en', 1.0), ('ur', 2.0)]) {
    testWidgets(
      'root Home View journal has Material Almarai and safe insets $locale x$scale',
      (tester) async {
        final f = JournalFixture(locale: locale);
        await mount(tester, f, scale: scale);
        final l = loc(tester);
        await openShortcut(tester);
        assertShell(tester, l, scale: scale);
        expect(
          find.byType(EquipmentNavigationBar),
          findsNothing,
        ); // pushed page, not nested tabs
        expect(
          Directionality.of(tester.element(find.byType(LedgerPage))),
          locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
        );
        final request = f.requests.lastWhere(
          (r) => r.url.path.endsWith('/entries'),
        );
        expect(request.url.path, '/api/v1/workspaces/workspace/entries');
        expect(request.url.queryParameters, {
          'page': '0',
        }); // not implicitly a month filter
        await capture(tester, '$locale-scale$scale-inset59');
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('homeViewJournal')), findsOneWidget);
        await openShortcut(tester);
        assertShell(tester, l, scale: scale);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.byType(LedgerPage), findsNothing);
        await tester.tap(find.text(l.ledger).last);
        await tester.pumpAndSettle();
        assertShell(tester, l, scale: scale);
        expect(
          tester
              .widget<EquipmentNavigationBar>(
                find.byType(EquipmentNavigationBar),
              )
              .selectedIndex,
          2,
        );
        expect(find.byType(BackButton), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'journal detail back retains search, scroll and root back; keyboard respects viewport',
    (tester) async {
      final f = JournalFixture();
      await mount(tester, f);
      final l = loc(tester);
      await openShortcut(tester);
      final search = find.byKey(const Key('historySearch'));
      await tester.ensureVisible(search);
      await tester.pumpAndSettle();
      await tester.enterText(search, 'Truck');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(LedgerPage));
      final lastCard = find
          .widgetWithText(InkWell, '${l.categoryFuel} • Truck EQ-1')
          .last;
      await tester.ensureVisible(lastCard);
      await tester.pumpAndSettle();
      final scroll = Scrollable.of(tester.element(lastCard)).position;
      final offset = scroll.pixels;
      expect(offset, greaterThan(0));
      await tester.tap(lastCard);
      await tester.pumpAndSettle();
      expect(tester.widget<EntryDetail>(find.byType(EntryDetail)).id, 'entry3');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(LedgerPage)), same(state));
      expect(scroll.pixels, closeTo(offset, .01));
      expect(tester.widget<TextField>(search).controller!.text, 'Truck');
      expect(
        f.requests
            .lastWhere((r) => r.url.path.endsWith('/entries'))
            .url
            .queryParameters['search'],
        'Truck',
      );
      await tester.ensureVisible(search);
      await tester.pumpAndSettle();
      tester.view.viewInsets = FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(search);
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(search).dy, lessThanOrEqualTo(844 - 280));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(WorkspacePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'root monthly expense and income routes retain exact existing filters and shell',
    (tester) async {
      final f = JournalFixture();
      await mount(tester, f);
      final l = loc(tester);
      for (final (key, type) in [
        ('recordedExpenseCard', 'EXPENSE'),
        ('recordedIncomeCard', 'INCOME'),
      ]) {
        final card = find.byKey(Key(key));
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        await tester.tap(card);
        await tester.pumpAndSettle();
        assertShell(tester, l);
        final month = f.requests
            .firstWhere((r) => r.url.path.endsWith('/dashboard'))
            .url
            .queryParameters['month']!;
        final year = int.parse(month.substring(0, 4)),
            m = int.parse(month.substring(5));
        final last = DateTime(
          year,
          m + 1,
          0,
        ).toIso8601String().split('T').first;
        expect(
          f.requests
              .lastWhere((r) => r.url.path.endsWith('/entries'))
              .url
              .queryParameters,
          {
            'page': '0',
            'entryType': type,
            'fromDate': '$month-01',
            'toDate': last,
          },
        );
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    },
  );

  for (final mode in ['DIRECT', 'REVIEW']) {
    testWidgets(
      'root restricted $mode shortcut preserves finance action guards',
      (tester) async {
        final f = JournalFixture(
          role: 'ACCOUNTANT',
          mode: mode,
          capabilities: mode == 'REVIEW'
              ? ['FINANCE_VIEW', 'FINANCE_MANAGE']
              : ['FINANCE_VIEW'],
        );
        await mount(tester, f);
        final l = loc(tester);
        await openShortcut(tester);
        assertShell(tester, l);
        final body = tester.widget<LedgerPage>(find.byType(LedgerPage));
        expect(body.canManage, isFalse);
        expect(body.canSubmitReview, mode == 'REVIEW');
        expect(find.byKey(const Key('addGeneralExpense')), findsNothing);
        expect(find.byKey(const Key('openDrafts')), findsNothing);
        expect(f.requests.every((r) => r.method == 'GET'), isTrue);
      },
    );
  }
  testWidgets(
    'root user without finance sees no journal shortcut or tab and sends no entries request',
    (tester) async {
      final f = JournalFixture(
        role: 'EMPLOYEE',
        capabilities: ['EQUIPMENT_VIEW'],
      );
      await mount(tester, f);
      expect(find.byKey(const Key('homeViewJournal')), findsNothing);
      expect(find.text(loc(tester).ledger), findsNothing);
      expect(f.requests.any((r) => r.url.path.endsWith('/entries')), isFalse);
    },
  );
}
