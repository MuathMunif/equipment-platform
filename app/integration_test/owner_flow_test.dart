import 'package:equipment_app/api.dart';
import 'package:equipment_app/main.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<Api> loginOwner(String phone) async {
    final api = Api(persistNative: false);
    final challenge = await api.json(
      'POST',
      '/auth/challenges',
      body: {'phone': phone},
    );
    final login = await api.json(
      'POST',
      '/auth/verify',
      body: {
        'challengeId': challenge['challengeId'],
        'code': '123456',
        'name': 'مالك اختبار القبول',
        'client': 'NATIVE',
      },
    );
    await api.setToken(login['accessToken']);
    await api.me();
    return api;
  }

  Future<void> rejects(int status, Future<dynamic> Function() action) async {
    await expectLater(
      action(),
      throwsA(isA<ApiError>().having((e) => e.status, 'status', status)),
    );
  }

  testWidgets(
    'native owner creates equipment paid expense and persistent attachment',
    (tester) async {
      // Real local API/PostgreSQL and OS secure storage. Synthetic phone only.
      final api = Api();
      final challenge = await api.json(
        'POST',
        '/auth/challenges',
        body: {'phone': '0500000002'},
      );
      final login = await api.json(
        'POST',
        '/auth/verify',
        body: {
          'challengeId': challenge['challengeId'],
          'code': '123456',
          'name': 'مالك اختبار iOS',
          'client': 'NATIVE',
        },
      );
      await api.setToken(login['accessToken']);
      await api.me();
      await tester.pumpWidget(EquipmentApp(api: api));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addEquipment')));
      await tester.pumpAndSettle();
      final name = 'قلاب اختبار iOS ${DateTime.now().millisecondsSinceEpoch}';
      await tester.enterText(find.byKey(const Key('equipmentName')), name);
      await tester.enterText(find.byKey(const Key('equipmentModel')), 'FH16');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('saveEquipment')));
      await tester.tap(find.byKey(const Key('saveEquipment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addExpense')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('expenseAmount')), '350.00');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('saveExpense')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(find.text('تفاصيل المصروف'), findsOneWidget);
      expect(find.text('350.00 ريال'), findsNWidgets(2));
      final equipmentPage = await api.json(
        'GET',
        api.scoped('/equipment?search=${Uri.encodeQueryComponent(name)}'),
      );
      final equipment = equipmentPage['items'].single;
      final entries = await api.json(
        'GET',
        api.scoped('/entries?equipmentId=${equipment['id']}'),
      );
      expect(entries['total'], 1);
      final entry = entries['items'].single;
      expect(entry['settlements'].length, 1);
      expect(entry['remaining'], '0.00');
      final fixture = (await rootBundle.load(
        'integration_test/fixtures/synthetic-receipt.png',
      )).buffer.asUint8List();
      // The platform file picker is intentionally injected here; picker UI remains a manual platform check.
      final context = tester.element(find.text('تفاصيل المصروف'));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => EntryDetail(
            api: api,
            id: entry['id'],
            pickFile: () async => XFile.fromData(
              fixture,
              path: 'synthetic-receipt.png',
              name: 'synthetic-receipt.png',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('addAttachment')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addAttachment')));
      await tester.pumpAndSettle();
      final files = await api.json(
        'GET',
        api.scoped('/entries/${entry['id']}/attachments'),
      );
      expect(files.length, 1);
      expect(files.single['state'], 'READY');
      final downloaded = await api.send(
        'GET',
        api.scoped('/attachments/${files.single['id']}/content'),
      );
      expect(downloaded.bodyBytes, orderedEquals(fixture));
      // A fresh API instance retrieves the native session from the real OS keychain.
      final restored = Api();
      await restored.restore();
      await restored.me();
      final persisted = await restored.json(
        'GET',
        restored.scoped('/entries/${entry['id']}'),
      );
      expect(persisted['amount'], '350.00');
      expect(persisted['settlements'].length, 1);
      await tester.pumpWidget(
        EquipmentApp(key: const ValueKey('restored-app'), api: restored),
      );
      await tester.pumpAndSettle();
      expect(find.text(name), findsOneWidget);
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addExpense')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('expenseAmount')), '350');
      await tester.tap(find.byKey(const Key('paymentStatus')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('دفعت جزءًا').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('initialPaid')), '100');
      await tester.enterText(
        find.byKey(const Key('partyName')),
        'مورد اختبار iOS',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('saveExpense')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(find.text('مدفوع جزئيًا'), findsOneWidget);
      final afterPartial = await restored.json(
        'GET',
        restored.scoped('/entries?equipmentId=${equipment['id']}'),
      );
      expect(afterPartial['total'], 2);
      final partial = afterPartial['items'].first;
      expect(partial['paid'], '100.00');
      expect(partial['remaining'], '250.00');
      expect(partial['settlements'].length, 1);
      await tester.scrollUntilVisible(
        find.text('إضافة دفعة'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('إضافة دفعة'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'مبلغ الدفعة'),
        '250',
      );
      await tester.tap(find.text('حفظ الدفعة'));
      await tester.pumpAndSettle();
      expect(find.text('مدفوع كاملًا'), findsOneWidget);
      final afterSettlement = await restored.json(
        'GET',
        restored.scoped('/entries/${partial['id']}'),
      );
      expect(afterSettlement['paid'], '350.00');
      expect(afterSettlement['remaining'], '0.00');
      expect(afterSettlement['settlements'].length, 2);
      Navigator.of(tester.element(find.text('تفاصيل المصروف'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addIncome')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('expenseAmount')), '3000');
      await tester.tap(find.byKey(const Key('paymentStatus')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('استلمت جزءًا').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('initialPaid')), '1000');
      await tester.enterText(
        find.byKey(const Key('partyName')),
        'عميل اختبار iOS',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('saveIncome')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('saveIncome')));
      await tester.pumpAndSettle();
      expect(find.text('مستلم جزئيًا'), findsOneWidget);
      final afterIncome = await restored.json(
        'GET',
        restored.scoped('/entries?equipmentId=${equipment['id']}'),
      );
      expect(afterIncome['total'], 3);
      final income = afterIncome['items'].first;
      expect(income['entryType'], 'INCOME');
      expect(income['paid'], '1000.00');
      expect(income['remaining'], '2000.00');
      await tester.scrollUntilVisible(
        find.text('إضافة تحصيل'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('إضافة تحصيل'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'مبلغ التحصيل'),
        '2000',
      );
      await tester.tap(find.text('حفظ التحصيل'));
      await tester.pumpAndSettle();
      expect(find.text('مستلم كاملًا'), findsOneWidget);
      final received = await restored.json(
        'GET',
        restored.scoped('/entries/${income['id']}'),
      );
      expect(received['amount'], '3000.00');
      expect(received['paid'], '3000.00');
      expect(received['remaining'], '0.00');
      expect(received['settlements'].length, 2);
    },
  );
  testWidgets('connected M2 finance journeys C through J', (tester) async {
    Api owner = Api();
    try {
      await owner.restore();
      await owner.me();
    } catch (_) {
      // The journey also works when run alone, without the preceding keychain test.
      owner = await loginOwner('0500000002');
    }
    final other = await loginOwner('0500000001');
    final day = todayRiyadh();
    final marker = 'قبول مالي ${DateTime.now().microsecondsSinceEpoch}';
    final equipmentA = await owner.json(
      'POST',
      owner.scoped('/equipment'),
      key: requestKey(),
      body: {'name': 'قلاب قبول أ $marker', 'model': 'FH16'},
    );
    final equipmentB = await owner.json(
      'POST',
      owner.scoped('/equipment'),
      key: requestKey(),
      body: {'name': 'قلاب قبول ب $marker', 'model': 'FH16'},
    );
    final a = equipmentA['id'] as String;
    final b = equipmentB['id'] as String;

    // C: refund keeps the original settlement and increases the outstanding amount.
    final paid = await owner.json(
      'POST',
      owner.scoped('/entries'),
      key: requestKey(),
      body: {
        'equipmentId': a,
        'amount': '1000.00',
        'category': 'FUEL',
        'operationDate': day,
        'paymentStatus': 'PARTIAL',
        'initialPaid': '600.00',
        'paidOn': day,
        'partyName': 'مورد اختبار القبول',
        'note': '$marker استرداد',
      },
    );
    final paidId = paid['id'] as String;
    final originalSettlement = paid['settlements'][0]['id'];
    final returned = await owner.json(
      'POST',
      owner.scoped('/entries/$paidId/refunds'),
      key: requestKey(),
      body: {
        'amount': '200.00',
        'refundedOn': day,
        'reason': 'عودة جزء من المبلغ',
      },
    );
    expect(returned['paid'], '600.00');
    expect(returned['refunded'], '200.00');
    expect(returned['netPaid'], '400.00');
    expect(returned['remaining'], '600.00');
    expect(returned['settlements'][0]['id'], originalSettlement);
    final settledAgain = await owner.json(
      'POST',
      owner.scoped('/entries/$paidId/settlements'),
      key: requestKey(),
      body: {'amount': '600.00', 'paidOn': day},
    );
    expect(settledAgain['netPaid'], '1000.00');
    expect(settledAgain['remaining'], '0.00');
    expect(settledAgain['settlements'].length, 2);

    // D and E: edit preserves cash history; cancellation preserves detail but removes active totals.
    final editable = await owner.json(
      'POST',
      owner.scoped('/entries'),
      key: requestKey(),
      body: {
        'equipmentId': a,
        'amount': '3000.00',
        'category': 'MAINTENANCE',
        'operationDate': day,
        'paymentStatus': 'PARTIAL',
        'initialPaid': '1000.00',
        'paidOn': day,
        'partyName': 'ورشة اختبار القبول',
        'note': '$marker تعديل',
      },
    );
    final editId = editable['id'] as String;
    final editSettlement = editable['settlements'][0]['id'];
    final changed = await owner.json(
      'PUT',
      owner.scoped('/entries/$editId'),
      body: {
        'amount': '2500.00',
        'category': 'MAINTENANCE',
        'operationDate': day,
        'partyName': 'ورشة اختبار القبول',
        'note': '$marker بعد التعديل',
      },
    );
    expect(changed['remaining'], '1500.00');
    expect(changed['settlements'][0]['id'], editSettlement);
    await rejects(
      400,
      () => owner.json(
        'PUT',
        owner.scoped('/entries/$editId'),
        body: {
          'amount': '500.00',
          'category': 'MAINTENANCE',
          'operationDate': day,
          'partyName': 'ورشة اختبار القبول',
        },
      ),
    );
    final beforeCancel = await owner.json(
      'GET',
      owner.scoped('/entries/totals'),
    );
    final cancelled = await owner.json(
      'POST',
      owner.scoped('/entries/$editId/cancellation'),
      body: {'reason': 'قيد اختبار أُلغي'},
    );
    expect(cancelled['lifecycle'], 'CANCELLED');
    expect(cancelled['settlements'][0]['id'], editSettlement);
    final afterCancel = await owner.json(
      'GET',
      owner.scoped('/entries/totals'),
    );
    int cents(dynamic amount) =>
        int.parse((amount as String).replaceAll('.', ''));
    expect(
      cents(beforeCancel['expenseTotal']) - cents(afterCancel['expenseTotal']),
      250000,
    );
    await rejects(
      400,
      () => owner.json(
        'POST',
        owner.scoped('/entries/$editId/settlements'),
        key: requestKey(),
        body: {'amount': '1.00', 'paidOn': day},
      ),
    );
    await rejects(
      400,
      () => owner.json(
        'POST',
        owner.scoped('/entries/$editId/refunds'),
        key: requestKey(),
        body: {'amount': '1.00', 'refundedOn': day, 'reason': 'غير مسموح'},
      ),
    );

    // F: one shared original, two explicit allocations, no double count.
    final shared = await owner.json(
      'POST',
      owner.scoped('/entries'),
      key: requestKey(),
      body: {
        'expenseScope': 'SHARED',
        'amount': '1200.00',
        'category': 'OTHER',
        'operationDate': day,
        'paymentStatus': 'UNPAID',
        'partyName': 'مورد مشترك',
        'note': '$marker مشترك',
        'allocations': [
          {'equipmentId': a, 'amount': '700.00'},
          {'equipmentId': b, 'amount': '500.00'},
        ],
      },
    );
    expect(shared['allocations'].length, 2);
    expect(shared['allocations'].map((part) => part['amount']).toSet(), {
      '700.00',
      '500.00',
    });
    final sharedResults = await owner.json(
      'GET',
      owner.scoped(
        '/entries?search=${Uri.encodeQueryComponent('$marker مشترك')}',
      ),
    );
    expect(sharedResults['total'], 1);
    expect(sharedResults['items'][0]['id'], shared['id']);
    final aTotals = await owner.json(
      'GET',
      owner.scoped('/entries/totals?equipmentId=$a'),
    );
    final bTotals = await owner.json(
      'GET',
      owner.scoped('/entries/totals?equipmentId=$b'),
    );
    expect(aTotals['expenseTotal'], '1700.00');
    expect(bTotals['expenseTotal'], '500.00');

    // G: general expense affects workspace totals only.
    final beforeGeneral = await owner.json(
      'GET',
      owner.scoped('/entries/totals'),
    );
    final general = await owner.json(
      'POST',
      owner.scoped('/entries'),
      key: requestKey(),
      body: {
        'expenseScope': 'GENERAL',
        'amount': '100.00',
        'category': 'OTHER',
        'operationDate': day,
        'paidOn': day,
        'note': '$marker عام',
      },
    );
    expect(general['equipmentId'], isNull);
    final afterGeneral = await owner.json(
      'GET',
      owner.scoped('/entries/totals'),
    );
    expect(
      cents(afterGeneral['expenseTotal']) -
          cents(beforeGeneral['expenseTotal']),
      10000,
    );
    expect(
      cents(afterGeneral['generalExpenseTotal']) -
          cents(beforeGeneral['generalExpenseTotal']),
      10000,
    );
    final aAfterGeneral = await owner.json(
      'GET',
      owner.scoped('/entries/totals?equipmentId=$a'),
    );
    expect(aAfterGeneral['expenseTotal'], aTotals['expenseTotal']);

    // H and I: a draft keeps the same attachment identity and remains tenant-scoped.
    final draft = await owner.json(
      'POST',
      owner.scoped('/drafts'),
      key: requestKey(),
      body: {'equipmentId': a, 'note': '$marker فاتورة مؤجلة'},
    );
    final draftId = draft['id'] as String;
    expect(draft['lifecycle'], 'DRAFT');
    final fixture = (await rootBundle.load(
      'integration_test/fixtures/synthetic-receipt.png',
    )).buffer.asUint8List();
    final attachment = await owner.json(
      'POST',
      owner.scoped('/entries/$draftId/attachments'),
      key: requestKey(),
      body: {
        'filename': 'synthetic-receipt.png',
        'mediaType': 'image/png',
        'size': fixture.length,
      },
    );
    final attachmentId = attachment['id'] as String;
    await owner.send(
      'PUT',
      owner.scoped('/attachments/$attachmentId/content'),
      bytes: fixture,
      type: 'image/png',
    );
    final whileDraft = await owner.json('GET', owner.scoped('/entries/totals'));
    expect(whileDraft['expenseTotal'], afterGeneral['expenseTotal']);
    await rejects(
      404,
      () => other.json('GET', other.scoped('/drafts/$draftId')),
    );
    await rejects(
      404,
      () =>
          other.send('GET', other.scoped('/attachments/$attachmentId/content')),
    );
    await rejects(
      404,
      () => other.json(
        'POST',
        other.scoped('/drafts/$draftId/completion'),
        key: requestKey(),
        body: {
          'equipmentId': a,
          'amount': '75.00',
          'category': 'OTHER',
          'operationDate': day,
          'paidOn': day,
        },
      ),
    );
    final completed = await owner.json(
      'POST',
      owner.scoped('/drafts/$draftId/completion'),
      key: requestKey(),
      body: {
        'equipmentId': a,
        'amount': '75.00',
        'category': 'OTHER',
        'operationDate': day,
        'paidOn': day,
      },
    );
    expect(completed['id'], draftId);
    expect(completed['lifecycle'], 'POSTED');
    final files = await owner.json(
      'GET',
      owner.scoped('/entries/$draftId/attachments'),
    );
    expect(files.length, 1);
    expect(files[0]['id'], attachmentId);
    final downloaded = await owner.send(
      'GET',
      owner.scoped('/attachments/$attachmentId/content'),
    );
    expect(downloaded.bodyBytes, orderedEquals(fixture));
    final afterDraft = await owner.json('GET', owner.scoped('/entries/totals'));
    expect(
      cents(afterDraft['expenseTotal']) - cents(afterGeneral['expenseTotal']),
      7500,
    );
    final pending = await owner.json('GET', owner.scoped('/drafts'));
    expect(pending['items'].where((item) => item['id'] == draftId), isEmpty);
    final originals = await owner.json(
      'GET',
      owner.scoped(
        '/entries?search=${Uri.encodeQueryComponent('$marker فاتورة مؤجلة')}',
      ),
    );
    expect(originals['total'], 1);
    await rejects(
      404,
      () => other.json('GET', other.scoped('/entries/$draftId')),
    );
    await rejects(
      404,
      () => other.json(
        'PUT',
        other.scoped('/entries/$draftId'),
        body: {'amount': '75.00', 'category': 'OTHER', 'operationDate': day},
      ),
    );
    await rejects(
      404,
      () => other.json(
        'POST',
        other.scoped('/entries/$draftId/cancellation'),
        body: {'reason': 'محاولة من مساحة أخرى'},
      ),
    );

    // J: server filters and the Arabic UI distinguish no matches from an empty ledger.
    final filtered = await owner.json(
      'GET',
      owner.scoped(
        '/entries?entryType=EXPENSE&lifecycle=POSTED&equipmentId=$a&search=${Uri.encodeQueryComponent('$marker فاتورة مؤجلة')}',
      ),
    );
    expect(filtered['total'], 1);
    expect(filtered['items'][0]['id'], draftId);
    await tester.pumpWidget(EquipmentApp(api: owner));
    await tester.pumpAndSettle();
    await tester.tap(find.text('السجل').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('historySearch')));
    await tester.enterText(
      find.byKey(const Key('historySearch')),
      'لا توجد عملية بهذا النص $marker',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.textContaining('لا توجد عمليات تطابق البحث'), findsOneWidget);
    await tester.tap(find.byKey(const Key('historyFilters')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('clearHistoryFilters')));
    await tester.tap(find.byKey(const Key('clearHistoryFilters')));
    await tester.pumpAndSettle();
    expect(find.textContaining('لا توجد عمليات تطابق البحث'), findsNothing);
  });
}
