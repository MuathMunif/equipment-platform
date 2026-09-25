import 'dart:convert';
import 'dart:typed_data';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/documents.dart' show DocumentUpload;
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/maintenance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response answer(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);
Api fake(Future<http.Response> Function(http.Request) handler) =>
    Api(client: MockClient(handler), persistNative: false)..workspace = 'w';
Widget host(Widget child, {String locale = 'ar'}) => MaterialApp(
  locale: Locale(locale),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: child,
);
final equipment = <String, dynamic>{
  'id': 'eq',
  'name': 'قلاب ١',
  'archivedAt': null,
};
final issue = <String, dynamic>{
  'id': 'i',
  'reference': 'IS-000001',
  'equipmentId': 'eq',
  'equipmentName': 'قلاب ١',
  'description': 'تهريب زيت',
  'type': null,
  'equipmentStopped': true,
  'status': 'OPEN',
  'resolution': null,
  'closedAt': null,
  'createdAt': '2026-09-25T05:00:00Z',
  'equipmentArchived': false,
  'closures': <Object>[],
  'maintenance': <Object>[],
};
final maintenance = <String, dynamic>{
  'id': 'm',
  'equipmentId': 'eq',
  'equipmentName': 'قلاب ١',
  'issueId': null,
  'description': 'تغيير زيت',
  'maintenanceDate': '2026-09-25',
  'type': null,
  'workshop': null,
  'cancelledAt': null,
  'createdAt': '2026-09-25T05:00:00Z',
  'equipmentArchived': false,
  'expenses': <Object>[],
  'financialSummary': {
    'linkedExpenseCount': 0,
    'activeExpenseCount': 0,
    'totalActiveExpenseAmount': '0.00',
    'netPaid': '0.00',
    'remaining': '0.00',
  },
};

void main() {
  testWidgets(
    'issue form requires description, has no title or priority, and defaults stopped to false',
    (tester) async {
      Map<String, dynamic>? sent;
      final api = fake((request) async {
        if (request.method == 'POST') {
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return answer({
            ...issue,
            ...sent!,
            'equipmentStopped': sent!['equipmentStopped'],
          });
        }
        return answer({});
      });
      await tester.pumpWidget(
        host(IssueFormPage(api: api, equipment: equipment)),
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.textContaining('الأولوية'), findsNothing);
      await tester.tap(find.byKey(const Key('m4SaveIssue')));
      await tester.pumpAndSettle();
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('m4IssueDescription')),
        'حرارة المكينة مرتفعة',
      );
      await tester.tap(find.byKey(const Key('m4SaveIssue')));
      await tester.pumpAndSettle();
      expect(sent?['description'], 'حرارة المكينة مرتفعة');
      expect(sent?['equipmentStopped'], false);
      expect(sent?.containsKey('title'), false);
      expect(sent?.containsKey('priority'), false);
    },
  );
  testWidgets(
    'issue detail starts, requires resolution, closes and preserves reopen action',
    (tester) async {
      var state = Map<String, dynamic>.from(issue);
      final calls = <String>[];
      final api = fake((request) async {
        calls.add(request.url.path);
        if (request.method == 'GET' && request.url.path.endsWith('/issues/i')) {
          return answer(state);
        }
        if (request.url.path.endsWith('/start')) {
          state = {...state, 'status': 'IN_PROGRESS'};
          return answer(state);
        }
        if (request.url.path.endsWith('/close')) {
          state = {
            ...state,
            'status': 'CLOSED',
            'resolution': (jsonDecode(request.body) as Map)['resolution'],
            'closures': [
              {
                'resolution': 'تم إصلاح الخرطوم',
                'closedAt': '2026-09-25T05:00:00Z',
              },
            ],
          };
          return answer(state);
        }
        if (request.url.path.endsWith('/reopen')) {
          state = {...state, 'status': 'OPEN', 'resolution': null};
          return answer(state);
        }
        if (request.url.path.endsWith('/attachments')) return answer([]);
        return answer({});
      });
      await tester.pumpWidget(host(IssueDetailPage(api: api, id: 'i')));
      await tester.pumpAndSettle();
      expect(find.text('المعدة متوقفة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('m4Start')));
      await tester.pumpAndSettle();
      expect(state['status'], 'IN_PROGRESS');
      await tester.tap(find.byKey(const Key('m4Close')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'إغلاق البلاغ').last);
      await tester.pumpAndSettle();
      expect(state['status'], 'IN_PROGRESS');
      await tester.tap(find.byKey(const Key('m4Close')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('m4Resolution')),
        'تم إصلاح الخرطوم',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'إغلاق البلاغ').last);
      await tester.pumpAndSettle();
      expect(state['status'], 'CLOSED');
      expect(find.byKey(const Key('m4Reopen')), findsOneWidget);
      await tester.tap(find.byKey(const Key('m4Reopen')));
      await tester.pumpAndSettle();
      expect(state['status'], 'OPEN');
      expect(calls.any((p) => p.endsWith('/reopen')), true);
    },
  );
  testWidgets('direct maintenance form submits date without cost or meter', (
    tester,
  ) async {
    Map<String, dynamic>? sent;
    final api = fake((request) async {
      if (request.method == 'POST') {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        return answer({...maintenance, ...sent!});
      }
      return answer({});
    });
    await tester.pumpWidget(
      host(MaintenanceFormPage(api: api, equipment: equipment)),
    );
    await tester.enterText(
      find.byKey(const Key('m4MaintenanceDescription')),
      'تغيير زيت وفلاتر',
    );
    await tester.tap(find.byKey(const Key('m4SaveMaintenance')));
    await tester.pumpAndSettle();
    expect(sent?['description'], 'تغيير زيت وفلاتر');
    expect(sent?['maintenanceDate'], isNotNull);
    expect(sent?['issueId'], isNull);
    expect(sent?.containsKey('cost'), false);
    expect(sent?.containsKey('meter'), false);
  });
  for (final language in ['ar', 'en', 'ur']) {
    testWidgets(
      '$language maintenance and issue lists use correct direction at phone width',
      (tester) async {
        tester.view.physicalSize = const Size(390, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = fake(
          (request) async => answer({
            'items': request.url.path.endsWith('/issues')
                ? [issue]
                : [maintenance],
            'page': 0,
            'pageSize': 30,
            'total': 1,
          }),
        );
        await tester.pumpWidget(
          host(
            MaintenanceHub(api: api, equipment: equipment),
            locale: language,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          Directionality.of(tester.element(find.byType(MaintenanceHub))),
          language == 'en' ? TextDirection.ltr : TextDirection.rtl,
        );
        expect(find.text('تهريب زيت'), findsOneWidget);
        await tester.tap(
          find.text(
            language == 'ar'
                ? 'سجلات الصيانة'
                : language == 'en'
                ? 'Maintenance records'
                : 'مرمت کے ریکارڈ',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('تغيير زيت'), findsOneWidget);
      },
    );
  }
  testWidgets(
    'equipment picker reaches a second server page and selects item 31',
    (tester) async {
      final pages = <int>[];
      Map<String, dynamic>? chosen;
      final api = fake((request) async {
        final page = int.parse(request.url.queryParameters['page'] ?? '0');
        pages.add(page);
        return answer({
          'items': page == 0
              ? List.generate(
                  30,
                  (i) => {'id': 'eq$i', 'name': 'معدة $i', 'archivedAt': null},
                )
              : [
                  {'id': 'eq31', 'name': 'المعدة المطلوبة', 'archivedAt': null},
                ],
          'page': page,
          'pageSize': 30,
          'total': 31,
        });
      });
      await tester.pumpWidget(
        host(
          Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  chosen = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => M4Picker(api: api, issues: false),
                  );
                },
                child: const Text('picker'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('picker'));
      await tester.pumpAndSettle();
      expect(find.text('المعدة المطلوبة'), findsNothing);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('المعدة المطلوبة'), findsOneWidget);
      await tester.tap(find.text('المعدة المطلوبة'));
      await tester.pumpAndSettle();
      expect(chosen?['id'], 'eq31');
      expect(pages, contains(1));
    },
  );
  testWidgets(
    'linked issue picker searches the second page for same equipment',
    (tester) async {
      final urls = <Uri>[];
      Map<String, dynamic>? chosen;
      final api = fake((request) async {
        urls.add(request.url);
        final page = int.parse(request.url.queryParameters['page'] ?? '0');
        return answer({
          'items': page == 0
              ? List.generate(
                  30,
                  (i) => {
                    'id': 'i$i',
                    'reference': 'IS-$i',
                    'description': 'بلاغ $i',
                  },
                )
              : [
                  {
                    'id': 'i31',
                    'reference': 'IS-31',
                    'description': 'البلاغ المطلوب',
                  },
                ],
          'page': page,
          'pageSize': 30,
          'total': 31,
        });
      });
      await tester.pumpWidget(
        host(
          Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  chosen = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) =>
                        M4Picker(api: api, issues: true, equipmentId: 'eq'),
                  );
                },
                child: const Text('picker'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('picker'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('البلاغ المطلوب'));
      await tester.pumpAndSettle();
      expect(chosen?['id'], 'i31');
      expect(
        urls.every((url) => url.queryParameters['equipmentId'] == 'eq'),
        true,
      );
    },
  );
  testWidgets('global empty copy and stopped in-progress badge stay visible', (
    tester,
  ) async {
    final inProgress = {...issue, 'status': 'IN_PROGRESS'};
    var items = <Object>[];
    final api = fake(
      (request) async => answer({
        'items': items,
        'page': 0,
        'pageSize': 30,
        'total': items.length,
      }),
    );
    await tester.pumpWidget(host(MaintenanceHub(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد بلاغات بعد'), findsOneWidget);
    expect(find.text('لا توجد بلاغات لهذه المعدة'), findsNothing);
    items = [inProgress];
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text('المعدة متوقفة'), findsOneWidget);
  });
  testWidgets(
    'attachment state is localized and pending failed file remains named',
    (tester) async {
      final api = fake((request) async {
        if (request.method == 'POST') return answer({'id': 'attachment'});
        if (request.method == 'PUT') {
          return answer({'code': 'UPLOAD_FAILED', 'message': 'فشل'}, 503);
        }
        return answer([
          {
            'id': 'existing',
            'filename': 'old.png',
            'state': 'FAILED',
            'mediaType': 'image/png',
          },
        ]);
      });
      await tester.pumpWidget(
        host(
          Scaffold(
            body: ListView(
              children: [
                OperationalAttachments(
                  api: api,
                  id: 'i',
                  issue: true,
                  readOnly: false,
                  pickFile: () async => DocumentUpload(
                    'new.png',
                    'image/png',
                    Uint8List.fromList([1, 2, 3]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('FAILED'), findsNothing);
      expect(find.text('تعثر الرفع'), findsOneWidget);
      await tester.tap(find.text('إضافة مرفق'));
      await tester.pumpAndSettle();
      expect(find.textContaining('new.png'), findsOneWidget);
      expect(find.text('إعادة محاولة رفع الملف'), findsOneWidget);
    },
  );
  testWidgets('issue detail shows stopped marker during processing', (
    tester,
  ) async {
    final api = fake(
      (request) async => request.url.path.endsWith('/attachments')
          ? answer([])
          : answer({...issue, 'status': 'IN_PROGRESS'}),
    );
    await tester.pumpWidget(host(IssueDetailPage(api: api, id: 'i')));
    await tester.pumpAndSettle();
    expect(find.text('المعدة متوقفة'), findsOneWidget);
    expect(find.text('جارٍ العمل'), findsOneWidget);
  });
  testWidgets(
    'maintenance form keeps desktop reading column within 760 pixels',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = fake(
        (request) async =>
            answer({'items': [], 'page': 0, 'pageSize': 30, 'total': 0}),
      );
      await tester.pumpWidget(
        host(MaintenanceFormPage(api: api, equipment: equipment)),
      );
      await tester.pumpAndSettle();
      final fieldRect = tester.getRect(
        find.byKey(const Key('m4MaintenanceDescription')),
      );
      expect(fieldRect.width, lessThanOrEqualTo(760));
      expect(fieldRect.left, greaterThanOrEqualTo(340));
    },
  );
}
