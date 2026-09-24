import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Widget host(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: child,
);
final sampleEntry = {
  'id': 'entry',
  'equipmentId': 'eq',
  'equipmentName': 'قلاب ١',
  'entryType': 'EXPENSE',
  'amount': '350.00',
  'currency': 'SAR',
  'category': 'FUEL',
  'operationDate': '2026-09-24',
  'lifecycle': 'POSTED',
  'paid': '350.00',
  'refunded': '0.00',
  'netPaid': '350.00',
  'refundable': '350.00',
  'remaining': '0.00',
  'refunds': [],
  'note': '',
  'settlements': [
    {'id': 'settlement', 'amount': '350.00', 'paidOn': '2026-09-24'},
  ],
};
void main() {
  test(
    'exact decimal input supports Arabic digits without binary arithmetic',
    () {
      expect(exactMoney('٣٥٠٫٢'), '350.20');
      expect(exactMoney('350'), '350.00');
      expect(exactMoney('0.01'), '0.01');
      for (final invalid in ['0', '-1', '350.001', '1e2', '1000000000']) {
        expect(exactMoney(invalid), isNull);
      }
    },
  );
  test('timeout covers waiting for response headers and distinguishes read from save', () async {
    final api = Api(
      client: MockClient((_) => Completer<http.Response>().future),
      base: 'http://localhost/api/v1',
      persistNative: false,
      timeout: const Duration(milliseconds: 10),
    );
    await expectLater(
      api.json('POST', '/workspaces/w/entries', body: {}, key: 'same-key'),
      throwsA(
        isA<ApiError>()
            .having((e) => e.code, 'code', 'TIMEOUT')
            .having((e) => e.message, 'message', contains('الحفظ')),
      ),
    );
    await expectLater(
      api.json('GET', '/workspaces/w/equipment'),
      throwsA(
        isA<ApiError>().having((e) => e.message, 'message', contains('تحميل')),
      ),
    );
  });
  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'Arabic empty owner workspace has action and adapts at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = Api(
          client: MockClient((_) async => json({'items': [], 'total': 0})),
          persistNative: false,
        )..workspace = 'workspace';
        await tester.pumpWidget(
          host(WorkspacePage(api: api, user: {'name': 'معاذ'}, logout: () {})),
        );
        await tester.pumpAndSettle();
        expect(find.text('أضف أول معدة'), findsOneWidget);
        expect(find.byKey(const Key('addEquipment')), findsOneWidget);
        expect(
          find.byType(NavigationRail),
          width >= 850 ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
        expect(
          Directionality.of(tester.element(find.text('أضف أول معدة'))),
          TextDirection.rtl,
        );
      },
    );
  }
  testWidgets('new owner receives guidance for missing name', (tester) async {
    final api = Api(
      client: MockClient(
        (r) async => json(
          r.url.path.endsWith('challenges')
              ? {'challengeId': 'c'}
              : {'requiresName': true},
        ),
      ),
      persistNative: false,
    );
    await tester.pumpWidget(host(LoginPage(api: api, completed: () async {})));
    await tester.enterText(find.byKey(const Key('phone')), '0500000001');
    await tester.tap(find.byKey(const Key('loginContinue')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otp')), '123456');
    await tester.tap(find.byKey(const Key('loginContinue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('loginContinue')));
    await tester.pumpAndSettle();
    expect(find.text('اكتب الاسم للمتابعة'), findsOneWidget);
  });
  testWidgets(
    'uncertain expense save preserves exact payload and same idempotency key',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final requests = <http.Request>[];
      final first = Completer<http.Response>();
      final api = Api(
        client: MockClient((r) {
          requests.add(r);
          return requests.length == 1
              ? first.future
              : Future.value(
                  json({'code': 'NETWORK', 'message': 'انقطع الاتصال'}, 503),
                );
        }),
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(
        host(ExpenseForm(api: api, equipment: {'id': 'eq', 'name': 'قلاب ١'})),
      );
      await tester.enterText(find.byKey(const Key('expenseAmount')), '٣٥٠');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pump();
      expect(requests.length, 1);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('saveExpense')))
            .onPressed,
        isNull,
      );
      first.completeError(Exception('connection lost'));
      await tester.pumpAndSettle();
      expect(find.text('إعادة محاولة الحفظ نفسه'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(requests.length, 2);
      expect(
        requests[0].headers['Idempotency-Key'],
        requests[1].headers['Idempotency-Key'],
      );
      expect(requests[0].body, requests[1].body);
      expect(jsonDecode(requests[0].body)['amount'], '350.00');
      // A server-side 5xx can also leave the commit outcome uncertain.
      await tester.ensureVisible(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(requests.length, 3);
      expect(
        requests[0].headers['Idempotency-Key'],
        requests[2].headers['Idempotency-Key'],
      );
      expect(requests[0].body, requests[2].body);
    },
  );
  testWidgets('partial expense requires party and sends one initial payment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    http.Request? created;
    final api = Api(
      client: MockClient((r) async {
        created = r;
        return json({...sampleEntry, 'settlementStatus': 'PARTIAL'});
      }),
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(
      host(ExpenseForm(api: api, equipment: {'id': 'eq', 'name': 'قلاب ١'})),
    );
    await tester.enterText(find.byKey(const Key('expenseAmount')), '350');
    await tester.tap(find.byKey(const Key('paymentStatus')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('دفعت جزءًا').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('initialPaid')), '100');
    await tester.ensureVisible(find.byKey(const Key('saveExpense')));
    await tester.tap(find.byKey(const Key('saveExpense')));
    await tester.pumpAndSettle();
    expect(find.text('اكتب اسم الطرف'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('partyName')), 'ورشة المعدات');
    await tester.ensureVisible(find.byKey(const Key('saveExpense')));
    await tester.tap(find.byKey(const Key('saveExpense')));
    await tester.pumpAndSettle();
    final body = jsonDecode(created!.body) as Map<String, dynamic>;
    expect(body['paymentStatus'], 'PARTIAL');
    expect(body['initialPaid'], '100.00');
    expect(body['partyName'], 'ورشة المعدات');
  });
  testWidgets('partial income uses receipt wording and sends one original', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    http.Request? created;
    final api = Api(
      client: MockClient((r) async {
        created = r;
        return json({
          ...sampleEntry,
          'entryType': 'INCOME',
          'settlementStatus': 'PARTIAL',
        });
      }),
      persistNative: false,
    )..workspace = 'w';
    await tester.pumpWidget(
      host(
        ExpenseForm(
          api: api,
          equipment: {'id': 'eq', 'name': 'قلاب ١'},
          income: true,
        ),
      ),
    );
    expect(find.text('إضافة إيراد'), findsOneWidget);
    expect(find.text('حالة الاستلام'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('expenseAmount')), '3000');
    await tester.tap(find.byKey(const Key('paymentStatus')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('استلمت جزءًا').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('initialPaid')), '1000');
    await tester.enterText(find.byKey(const Key('partyName')), 'عميل اختبار');
    await tester.ensureVisible(find.byKey(const Key('saveIncome')));
    await tester.tap(find.byKey(const Key('saveIncome')));
    await tester.pumpAndSettle();
    final body = jsonDecode(created!.body) as Map<String, dynamic>;
    expect(body['entryType'], 'INCOME');
    expect(body['amount'], '3000.00');
    expect(body['initialPaid'], '1000.00');
    expect(body['partyName'], 'عميل اختبار');
    expect(body.containsKey('category'), false);
  });
  testWidgets(
    'rejected attachment can be replaced without creating another expense',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      int initializations = 0, uploads = 0, expenseCreates = 0;
      final api = Api(
        client: MockClient((r) async {
          if (r.method == 'GET' && r.url.path.endsWith('/attachments')) {
            return json([]);
          }
          if (r.method == 'GET') return json(sampleEntry);
          if (r.method == 'POST' && r.url.path.endsWith('/attachments')) {
            return json({'id': 'attachment-${++initializations}'});
          }
          if (r.method == 'POST') {
            expenseCreates++;
            return json({});
          }
          uploads++;
          return uploads == 1
              ? json({
                  'code': 'UNSUPPORTED_FILE',
                  'message': 'اختر ملفًا سليمًا',
                }, 400)
              : json({'state': 'READY'});
        }),
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(
        host(
          EntryDetail(
            api: api,
            id: 'entry',
            pickFile: () async => XFile.fromData(
              Uint8List.fromList([1, 2, 3]),
              name: 'synthetic.png',
              path: 'synthetic.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('addAttachment')));
      await tester.tap(find.byKey(const Key('addAttachment')));
      await tester.pumpAndSettle();
      expect(find.text('اختيار ملف آخر'), findsOneWidget);
      await tester.ensureVisible(find.text('اختيار ملف آخر'));
      await tester.tap(find.text('اختيار ملف آخر'));
      await tester.pumpAndSettle();
      expect(initializations, 2);
      expect(uploads, 2);
      expect(expenseCreates, 0);
      expect(find.text('حُفظ المرفق داخل العملية'), findsOneWidget);
    },
  );
  testWidgets(
    'income edit sends safe fields and preserves settlement history',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      http.Request? edited;
      final current = {
        ...sampleEntry,
        'entryType': 'INCOME',
        'amount': '3000.00',
        'paid': '1000.00',
        'remaining': '2000.00',
        'partyName': 'عميل',
        'dueDate': null,
      };
      final api = Api(
        client: MockClient((r) async {
          if (r.method == 'PUT') {
            edited = r;
            return json({
              ...current,
              'amount': '2500.00',
              'remaining': '1500.00',
            });
          }
          if (r.url.path.endsWith('/attachments')) return json([]);
          return json(current);
        }),
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(host(EntryDetail(api: api, id: 'entry')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('editEntry')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('editAmount')), '2500');
      await tester.ensureVisible(find.byKey(const Key('saveEntryEdit')));
      await tester.tap(find.byKey(const Key('saveEntryEdit')));
      await tester.pumpAndSettle();
      expect(edited, isNotNull);
      final body = jsonDecode(edited!.body) as Map<String, dynamic>;
      expect(edited!.method, 'PUT');
      expect(body['amount'], '2500.00');
      expect(body.containsKey('settlements'), false);
      expect(body.containsKey('entryType'), false);
    },
  );
  testWidgets(
    'cancellation requires reason and cancelled detail is read only',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool cancelled = false;
      int calls = 0;
      final partial = {
        ...sampleEntry,
        'paid': '100.00',
        'remaining': '250.00',
        'settlementStatus': 'PARTIAL',
        'settlements': [
          {'id': 'settlement', 'amount': '100.00', 'paidOn': '2026-09-24'},
        ],
      };
      final api = Api(
        client: MockClient((r) async {
          if (r.method == 'POST') {
            calls++;
            cancelled = true;
            return json({
              ...partial,
              'lifecycle': 'CANCELLED',
              'cancellationReason': 'قيد مكرر',
            });
          }
          if (r.url.path.endsWith('/attachments')) return json([]);
          return json({
            ...partial,
            'lifecycle': cancelled ? 'CANCELLED' : 'POSTED',
            'cancellationReason': cancelled ? 'قيد مكرر' : null,
            'cancelledAt': cancelled ? '2026-09-24T10:00:00Z' : null,
          });
        }),
        persistNative: false,
      )..workspace = 'w';
      await tester.pumpWidget(host(EntryDetail(api: api, id: 'entry')));
      await tester.pumpAndSettle();
      expect(find.text('إضافة دفعة'), findsOneWidget);
      await tester.tap(find.byKey(const Key('cancelEntry')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmCancellation')));
      await tester.pumpAndSettle();
      expect(find.text('اكتب سبب الإلغاء'), findsOneWidget);
      expect(calls, 0);
      await tester.enterText(
        find.byKey(const Key('cancellationReason')),
        'قيد مكرر',
      );
      await tester.tap(find.byKey(const Key('confirmCancellation')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('عملية ملغاة'), findsOneWidget);
      expect(find.text('السبب: قيد مكرر'), findsOneWidget);
      expect(find.byKey(const Key('editEntry')), findsNothing);
      expect(find.byKey(const Key('cancelEntry')), findsNothing);
      expect(find.text('إضافة دفعة'), findsNothing);
      expect(find.text('350.00 ريال'), findsOneWidget);
      expect(find.text('100.00 ريال سعودي'), findsOneWidget);
      expect(find.byKey(const Key('addAttachment')), findsOneWidget);
    },
  );
  testWidgets('expense refund validates form and shows dated history and net values', (tester) async {
    tester.view.physicalSize = const Size(800, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Map<String, dynamic> current = {...sampleEntry, 'settlementStatus': 'PAID'};
    http.Request? posted;
    final api = Api(client: MockClient((r) async {
      if (r.url.path.endsWith('/attachments')) return json([]);
      if (r.method == 'POST' && r.url.path.endsWith('/refunds')) {
        posted = r;
        current = {
          ...current,
          'refunded': '100.00', 'netPaid': '250.00', 'refundable': '250.00',
          'remaining': '100.00', 'settlementStatus': 'PARTIAL',
          'refunds': [{'id': 'refund', 'amount': '100.00', 'refundedOn': '2026-10-02', 'reason': 'مرتجع من المورد'}],
        };
        return json(current);
      }
      return json(current);
    }), persistNative: false)..workspace = 'w';
    await tester.pumpWidget(host(EntryDetail(api: api, id: 'entry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addRefund')), findsOneWidget);
    await tester.tap(find.byKey(const Key('addRefund')));
    await tester.pumpAndSettle();
    expect(find.textContaining('مبلغ عاد إليك'), findsOneWidget);
    await tester.tap(find.byKey(const Key('saveRefund')));
    await tester.pumpAndSettle();
    expect(find.text('اكتب مبلغ استرداد صحيحًا'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('refundAmount')), '400');
    await tester.tap(find.byKey(const Key('saveRefund')));
    await tester.pumpAndSettle();
    expect(find.text('مبلغ الاسترداد أكبر من المتاح'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('refundAmount')), '100');
    await tester.tap(find.byKey(const Key('saveRefund')));
    await tester.pumpAndSettle();
    expect(find.text('اكتب سبب الاسترداد'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('refundReason')), 'مرتجع من المورد');
    await tester.tap(find.byKey(const Key('saveRefund')));
    await tester.pumpAndSettle();
    expect(posted, isNotNull);
    final body = jsonDecode(posted!.body) as Map<String, dynamic>;
    expect(body['amount'], '100.00');
    expect(body['reason'], 'مرتجع من المورد');
    expect(body['refundedOn'], isNotNull);
    expect(posted!.headers['Idempotency-Key'], isNotNull);
    expect(find.text('المسترد'), findsOneWidget);
    expect(find.text('صافي المدفوع'), findsOneWidget);
    expect(find.text('الاستردادات'), findsOneWidget);
    expect(find.textContaining('السبب: مرتجع من المورد'), findsOneWidget);
    expect(find.text('إضافة دفعة'), findsOneWidget);
  });
  testWidgets('income refund wording and no refund action after full return or cancellation', (tester) async {
    tester.view.physicalSize = const Size(800, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final current = {...sampleEntry, 'entryType': 'INCOME', 'paid': '350.00', 'refundable': '350.00'};
    final api = Api(client: MockClient((r) async => json(r.url.path.endsWith('/attachments') ? [] : current)), persistNative: false)..workspace = 'w';
    await tester.pumpWidget(host(EntryDetail(api: api, id: 'entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addRefund')));
    await tester.pumpAndSettle();
    expect(find.textContaining('أُعيد إلى العميل'), findsOneWidget);
    await tester.tap(find.text('رجوع'));
    await tester.pumpAndSettle();
    current['refundable'] = '0.00';
    await tester.tap(find.byTooltip('تحديث الإيراد'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addRefund')), findsNothing);
    current['refundable'] = '350.00';
    current['lifecycle'] = 'CANCELLED';
    current['cancellationReason'] = 'قيد خطأ';
    current['cancelledAt'] = '2026-09-24T10:00:00Z';
    await tester.tap(find.byTooltip('تحديث الإيراد'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addRefund')), findsNothing);
  });
}
