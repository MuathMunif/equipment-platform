import 'package:equipment_app/api.dart';
import 'package:equipment_app/main.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
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
    },
  );
}
