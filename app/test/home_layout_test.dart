import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:equipment_app/api.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/documents.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/main.dart';
import 'package:equipment_app/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response reply(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

class HomeFixture {
  final requests = <Uri>[];
  int count = 4, status = 200, attentionStatus = 200;
  bool finance = true, equipment = true, longNames = false;
  List<Map<String, Object>> attention = [], incomplete = [];
  late final api = Api(
    base: 'http://localhost/api/v1',
    persistNative: false,
    client: MockClient((r) async {
      requests.add(r.url);
      final path = r.url.path;
      if (path.endsWith('/dashboard')) {
        return reply({
          if (equipment) 'activeEquipmentCount': count,
          if (finance)
            'summary': {
              'recordedExpenses': count == 0
                  ? '0.00'
                  : r.url.queryParameters['month']!.endsWith('-01')
                  ? '2200.00'
                  : '1000.00',
              'recordedIncome': count == 0 ? '0.00' : '4500.00',
            },
          if (finance)
            'recentEntries': [
              for (var i = 0; i < (count == 0 ? 0 : 5); i++)
                {
                  'entryId': 'entry$i',
                  'entryType': i == 1 ? 'INCOME' : 'EXPENSE',
                  'amount': '${1000 + i}.00',
                  'operationDate': '2026-09-0${i + 1}',
                },
            ],
        }, status);
      }
      if (path.endsWith('/attention')) return reply(attention, attentionStatus);
      if (path.endsWith('/documents/incomplete')) return reply(incomplete);
      if (path.endsWith('/notifications/unread-count')) {
        return reply({'unreadCount': 0});
      }
      if (path.endsWith('/equipment')) {
        return reply({
          'items': [
            for (var i = 0; i < count; i++)
              {
                'id': 'eq$i',
                'name': longNames
                    ? 'شاحنة النقل للمعدات الثقيلة في الموقع الشرقي ذات الاسم الطويل $i'
                    : 'Truck $i',
                'reference': 'EQ-00000$i',
                'model': 'FH 460',
              },
          ],
          'total': count,
        });
      }
      if (path.contains('/entries/')) {
        return reply({'code': 'UNAVAILABLE'}, 503);
      }
      return reply({'items': [], 'total': 0});
    }),
  )..workspace = 'w';

  Widget page() => WorkspacePage(
    api: api,
    user: {
      'name': longNames
          ? 'اسم مالك طويل لاختبار التفاف التحية في المساحة الضيقة'
          : 'Test owner',
      'workspaces': [
        {
          'id': 'w',
          'name': 'Test workspace',
          'role': finance && equipment ? 'OWNER' : 'ACCOUNTANT',
          'financialMode': 'DIRECT',
          'capabilities': [
            if (finance) 'FINANCE_VIEW',
            if (equipment) 'EQUIPMENT_VIEW',
            'DOCUMENT_VIEW',
          ],
        },
      ],
    },
    logout: () {},
  );
}

Future<void> mount(
  WidgetTester tester,
  Widget page, {
  double width = 390,
  double height = 844,
  double scale = 1,
  String locale = 'ar',
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: EquipmentA.theme(),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(key: const Key('homeEvidence'), child: child!),
      ),
      home: page,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> evidence(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('HOME_LAYOUT_EVIDENCE')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('homeEvidence')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(
      '../docs/design/ui-refresh/home-layout-review/screenshots/harness-$name.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
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

  testWidgets(
    'home truthful three metrics, two finance columns and no empty attention',
    (tester) async {
      final f = HomeFixture();
      await mount(tester, f.page());
      final expense = tester.getRect(
        find.byKey(const Key('recordedExpenseCard')),
      );
      final income = tester.getRect(
        find.byKey(const Key('recordedIncomeCard')),
      );
      expect(expense.top, income.top);
      expect(expense.overlaps(income), isFalse);
      expect(find.byKey(const Key('homeCurrentEquipment')), findsOneWidget);
      expect(find.byType(HomeDocumentAttention), findsOneWidget);
      expect(tester.getSize(find.byType(HomeDocumentAttention)).height, 0);
      expect(find.byKey(const Key('homeAttentionCard')), findsNothing);
      expect(find.byKey(const Key('openIncompleteDocuments')), findsNothing);
      expect(
        find.byType(TextField),
        findsNothing,
      ); // Search stays on Equipment.
      expect(find.byKey(const Key('homeRecent-entry2')), findsOneWidget);
      expect(find.byKey(const Key('homeRecent-entry3')), findsNothing);
      expect(find.byKey(const Key('homeEquipment-eq2')), findsOneWidget);
      expect(find.byKey(const Key('homeEquipment-eq3')), findsNothing);
      expect(f.requests.where((r) => r.path.endsWith('/dashboard')).length, 1);
      expect(f.requests.where((r) => r.path.endsWith('/entries')), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'home journal and all equipment retain real navigation and search',
    (tester) async {
      final f = HomeFixture();
      await mount(tester, f.page());
      await tester.ensureVisible(find.byKey(const Key('homeViewJournal')));
      await tester.tap(find.byKey(const Key('homeViewJournal')));
      await tester.pumpAndSettle();
      expect(find.byType(LedgerPage), findsOneWidget);
      final request = f.requests.lastWhere((r) => r.path.endsWith('/entries'));
      expect(
        request.queryParameters['fromDate'],
        isNull,
      ); // Latest is across months.
      Navigator.of(tester.element(find.byType(LedgerPage))).pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('homeViewEquipment')));
      await tester.tap(find.byKey(const Key('homeViewEquipment')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EquipmentList>(find.byType(EquipmentList)).home,
        isFalse,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Truck 3'), findsOneWidget);
    },
  );

  testWidgets('home recent logical row opens its source entry', (tester) async {
    final f = HomeFixture();
    await mount(tester, f.page());
    await tester.ensureVisible(find.byKey(const Key('homeRecent-entry1')));
    await tester.tap(find.byKey(const Key('homeRecent-entry1')));
    await tester.pumpAndSettle();
    expect(find.byType(EntryDetail), findsOneWidget);
    expect(f.requests.any((r) => r.path.endsWith('/entries/entry1')), isTrue);
  });

  testWidgets(
    'home compact attention keeps priority aggregate and independent incomplete link',
    (tester) async {
      final f = HomeFixture()
        ..attention = [
          {'entityType': 'FINANCIAL_REVIEW', 'pendingCount': 7},
          {
            'entityType': 'ISSUE',
            'issueId': 'i1',
            'equipmentName': 'Truck A',
            'description': 'Inspection needed',
            'equipmentStopped': true,
          },
          {
            'entityType': 'ISSUE',
            'issueId': 'i2',
            'equipmentName': 'Truck B',
            'description': 'Service needed',
            'equipmentStopped': false,
          },
          {
            'entityType': 'ISSUE',
            'issueId': 'hidden',
            'equipmentName': 'Hidden fourth',
            'description': 'Later',
            'equipmentStopped': false,
          },
        ]
        ..incomplete = [
          {'id': 'd1'},
          {'id': 'd2'},
        ];
      await mount(tester, f.page());
      final loc = AppLocalizations.of(
        tester.element(find.byType(WorkspacePage)),
      )!;
      expect(find.text(loc.m5PendingReviewsCount('7')), findsOneWidget);
      expect(find.textContaining('Hidden fourth'), findsNothing);
      expect(find.byKey(const Key('openIncompleteDocuments')), findsOneWidget);
      await evidence(tester, 'attention-ar-390');
      await tester.ensureVisible(
        find.byKey(const Key('openIncompleteDocuments')),
      );
      await evidence(tester, 'attention-lower-ar-390');
      await tester.tap(find.byKey(const Key('openIncompleteDocuments')));
      await tester.pumpAndSettle();
      expect(find.byType(IncompleteDocumentsPage), findsOneWidget);
      Navigator.of(tester.element(find.byType(IncompleteDocumentsPage))).pop();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(loc.m5PendingReviewsCount('7')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(loc.m5PendingReviewsCount('7')));
      await tester.pumpAndSettle();
      expect(find.byType(ReviewQueuePage), findsOneWidget);
    },
  );

  testWidgets('home failed or denied metrics never become zero', (
    tester,
  ) async {
    final f = HomeFixture()
      ..status = 503
      ..attentionStatus = 503;
    await mount(tester, f.page());
    expect(find.byKey(const Key('recordedExpenseCard')), findsNothing);
    expect(find.byKey(const Key('homeCurrentEquipment')), findsNothing);
    expect(find.byType(EquipmentError), findsOneWidget);
    expect(find.byType(HomeDocumentAttention), findsOneWidget);
    expect(
      tester.getSize(find.byType(HomeDocumentAttention)).height,
      greaterThan(0),
    );
    f.status = 200;
    f.attentionStatus = 200;
    final loc = AppLocalizations.of(
      tester.element(find.byType(WorkspacePage)),
    )!;
    await tester.tap(find.text(loc.retry));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recordedExpenseCard')), findsOneWidget);
    final limited = HomeFixture()..finance = false;
    await mount(tester, limited.page());
    expect(find.byKey(const Key('recordedExpenseCard')), findsNothing);
    expect(find.byKey(const Key('homeRecentEntries')), findsNothing);
  });

  testWidgets(
    'home month refresh preserves current attention and current equipment',
    (tester) async {
      final f = HomeFixture()
        ..attention = [
          {'entityType': 'FINANCIAL_REVIEW', 'pendingCount': 7},
        ];
      await mount(tester, f.page(), locale: 'en');
      final attentionCalls = f.requests
          .where((r) => r.path.endsWith('/attention'))
          .length;
      await tester.tap(find.byKey(const Key('dashboardMonth')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('January'));
      await tester.pumpAndSettle();
      expect(
        f.requests
            .lastWhere((r) => r.path.endsWith('/dashboard'))
            .queryParameters['month'],
        endsWith('-01'),
      );
      expect(
        f.requests.where((r) => r.path.endsWith('/attention')).length,
        attentionCalls,
      );
      expect(find.textContaining('2,200.00'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.byKey(const Key('homeRecent-entry0')), findsOneWidget);
    },
  );

  testWidgets('new owner has immediately reachable add first equipment', (
    tester,
  ) async {
    final f = HomeFixture()..count = 0;
    await mount(tester, f.page());
    expect(find.byKey(const Key('addEquipment')).hitTestable(), findsOneWidget);
    expect(find.byKey(const Key('homeAttentionCard')), findsNothing);
    await evidence(tester, 'new-owner-ar-390');
    await tester.tap(find.byKey(const Key('addEquipment')));
    await tester.pumpAndSettle();
    expect(find.byType(EquipmentForm), findsOneWidget);
  });

  testWidgets('home discards all prior-workspace in-flight data', (
    tester,
  ) async {
    final pending = <String, Completer<http.Response>>{};
    final api = Api(
      persistNative: false,
      client: MockClient((r) async {
        final endpoint = r.url.path.split('/').last;
        if (r.url.path.contains('/old/')) {
          return (pending[endpoint] = Completer<http.Response>()).future;
        }
        if (endpoint == 'dashboard') return reply({'activeEquipmentCount': 2});
        if (endpoint == 'equipment') return reply({'items': [], 'total': 0});
        if (endpoint == 'unread-count') return reply({'unreadCount': 0});
        return reply([]);
      }),
    )..workspace = 'old';
    Widget page(String w) => WorkspacePage(
      key: ValueKey(w),
      api: api,
      user: {
        'name': 'Owner',
        'workspaces': [
          {'id': w, 'name': w, 'role': 'OWNER', 'capabilities': []},
        ],
      },
      logout: () {},
    );
    // Do not settle while the previous workspace intentionally remains pending.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Widget host(String w) => MaterialApp(
      theme: EquipmentA.theme(),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: page(w),
    );
    await tester.pumpWidget(host('old'));
    await tester.pump();
    api.workspace = 'new';
    await tester.pumpWidget(host('new'));
    await tester.pumpAndSettle();
    for (final item in pending.entries.toList()) {
      item.value.complete(
        reply(switch (item.key) {
          'dashboard' => {'activeEquipmentCount': 999},
          'equipment' => {
            'items': [
              {
                'id': 'old',
                'name': 'OLD WORKSPACE',
                'reference': 'OLD',
                'model': 'Old',
              },
            ],
            'total': 1,
          },
          'unread-count' => {'unreadCount': 999},
          _ => <Object>[],
        }),
      );
    }
    await tester.pumpAndSettle();
    expect(find.textContaining('OLD WORKSPACE'), findsNothing);
    expect(find.text('999'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in ['ar', 'en', 'ur']) {
    for (final (width, scale) in [(390.0, 1.0), (320.0, 2.0), (1440.0, 1.0)]) {
      testWidgets(
        'home $locale width $width scale $scale wraps long names without overflow',
        (tester) async {
          final f = HomeFixture()..longNames = true;
          await mount(
            tester,
            f.page(),
            width: width,
            scale: scale,
            locale: locale,
          );
          expect(
            Directionality.of(tester.element(find.byType(WorkspacePage))),
            locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
          if (scale == 2) {
            final expense = tester.getRect(
              find.byKey(const Key('recordedExpenseCard')),
            );
            final income = tester.getRect(
              find.byKey(const Key('recordedIncomeCard')),
            );
            expect(income.top, greaterThan(expense.bottom));
          }
          if (locale == 'ur' && scale == 2) {
            await evidence(tester, 'ur-320-text200-top');
          }
          await tester.ensureVisible(
            find.byKey(const Key('homeEquipment-eq2')),
          );
          await tester.pumpAndSettle();
          if (locale == 'ur' && scale == 2) {
            await evidence(tester, 'ur-320-text200-lower');
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
