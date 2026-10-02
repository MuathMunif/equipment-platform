import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/design_system/equipment_typography.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget host(Widget page, {String locale = 'ar', double scale = 1}) =>
    MaterialApp(
      theme: EquipmentA.theme(),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: page,
    );

http.Response response(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void viewport(WidgetTester tester, double width, [double height = 1000]) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const equipment = {'id': 'eq', 'name': 'شاحنة الاختبار Volvo FH 460'};

void main() {
  testWidgets('navigation wraps at 200% with keyboard access', (tester) async {
    viewport(tester, 320);
    int selected = 0;
    await tester.pumpWidget(
      host(
        Scaffold(
          bottomNavigationBar: EquipmentNavigationBar(
            selectedIndex: selected,
            onDestinationSelected: (value) => selected = value,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                label: 'المعدات',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'طلباتي',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                label: 'المزيد',
              ),
            ],
          ),
        ),
        scale: 2,
      ),
    );
    final label = tester.element(find.text('الرئيسية'));
    expect(MediaQuery.textScalerOf(label).scale(12), 24);
    await tester.tap(find.text('طلباتي'));
    expect(selected, 2);
    selected = -1;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, inInclusiveRange(0, 3));
    expect(find.text('المزيد').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('selected real faces reach root roles and common overlays', () {
    final t = EquipmentA.theme();
    expect(t.colorScheme.primary, EquipmentA.accent);
    expect(t.textTheme.bodyMedium!.fontWeight, FontWeight.w400);
    expect(t.textTheme.headlineLarge!.fontWeight, FontWeight.w700);
    for (final style in [
      t.textTheme.bodyMedium,
      t.textTheme.titleLarge,
      t.dialogTheme.titleTextStyle,
      t.dialogTheme.contentTextStyle,
      t.snackBarTheme.contentTextStyle,
      t.popupMenuTheme.textStyle,
      t.datePickerTheme.dayStyle,
      t.datePickerTheme.yearStyle,
      t.datePickerTheme.headerHeadlineStyle,
      t.inputDecorationTheme.errorStyle,
      t.dropdownMenuTheme.textStyle,
      t.navigationBarTheme.labelTextStyle!.resolve({}),
    ]) {
      expect(style!.fontFamily, EquipmentTypography.family);
      expect(style.fontFamilyFallback, [EquipmentTypography.fallbackFamily]);
      expect([FontWeight.w400, FontWeight.w700], contains(style.fontWeight));
    }
  });

  testWidgets('real app root selects A and Almarai at unauthenticated entry', (
    tester,
  ) async {
    final api = Api(
      persistNative: false,
      client: MockClient(
        (_) async => http.Response('{"code":"UNAUTHENTICATED"}', 401),
      ),
    );
    await tester.pumpWidget(EquipmentApp(api: api));
    await tester.pumpAndSettle();
    final root = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(
      root.theme!.textTheme.bodyMedium!.fontFamily,
      EquipmentTypography.family,
    );
    expect(root.theme!.colorScheme.primary, EquipmentA.accent);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'expense focus and values survive breakpoint, locale and date dialog without requests',
    (tester) async {
      viewport(tester, 390);
      final requests = <http.Request>[];
      final api = Api(
        persistNative: false,
        client: MockClient((r) async {
          requests.add(r);
          return response({'items': [], 'total': 0});
        }),
      )..workspace = 'w';
      final page = ExpenseForm(api: api, equipment: equipment);
      await tester.pumpWidget(host(page));
      await tester.enterText(find.byKey(const Key('expenseAmount')), '١٠٠٠٫٢٥');
      final editable = find.descendant(
        of: find.byKey(const Key('expenseAmount')),
        matching: find.byType(EditableText),
      );
      final focus = tester.widget<EditableText>(editable).focusNode;
      expect(focus.hasFocus, isTrue);
      tester.view.physicalSize = const Size(1440, 1000);
      await tester.pumpAndSettle();
      await tester.pumpWidget(host(page, locale: 'ur'));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(editable).focusNode, same(focus));
      expect(focus.hasFocus, isTrue);
      expect(tester.widget<EditableText>(editable).controller.text, '١٠٠٠٫٢٥');
      expect(requests, isEmpty);
      final date = find.widgetWithIcon(
        OutlinedButton,
        Icons.calendar_month_outlined,
      );
      await tester.ensureVisible(date);
      await tester.tap(date);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      final theme = Theme.of(tester.element(find.byType(DatePickerDialog)));
      expect(
        theme.datePickerTheme.dayStyle!.fontFamily,
        EquipmentTypography.family,
      );
      Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(editable).controller.text, '١٠٠٠٫٢٥');
      expect(requests, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  for (final locale in ['ar', 'en', 'ur']) {
    for (final scale in [1.6, 2.0]) {
      testWidgets(
        'shared partial expense stays usable at320 $locale / $scale',
        (tester) async {
          viewport(tester, 320);
          final requests = <http.Request>[];
          final api = Api(
            persistNative: false,
            client: MockClient((r) async {
              requests.add(r);
              return response({
                'items': [
                  equipment,
                  {'id': 'eq2', 'name': 'معدة ثانية باسم طويل Mixed'},
                ],
                'total': 2,
              });
            }),
          )..workspace = 'w';
          await tester.pumpWidget(
            host(
              ExpenseForm(api: api, equipment: equipment),
              locale: locale,
              scale: scale,
            ),
          );
          await tester.enterText(
            find.byKey(const Key('expenseAmount')),
            '1000',
          );
          tester
              .widget<DropdownButtonFormField<String>>(
                find.byKey(const Key('expenseScope')),
              )
              .onChanged!('SHARED');
          await tester.pumpAndSettle();
          tester
              .widget<DropdownButtonFormField<String>>(
                find.byKey(const Key('paymentStatus')),
              )
              .onChanged!('PARTIAL');
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('allocationAmount0')),
            '600',
          );
          await tester.enterText(
            find.byKey(const Key('allocationAmount1')),
            '400',
          );
          await tester.enterText(find.byKey(const Key('initialPaid')), '600');
          await tester.enterText(
            find.byKey(const Key('partyName')),
            'المورد التجريبي',
          );
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byKey(const Key('saveExpense')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('saveExpense')).hitTestable(),
            findsOneWidget,
          );
          // All validators remain mounted, including amount above the viewport.
          expect(find.byKey(const Key('expenseAmount')), findsOneWidget);
          expect(requests.where((r) => r.method != 'GET'), isEmpty);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'owner shell resize preserves search and does not repeat fetches',
    (tester) async {
      viewport(tester, 390);
      final reads = <String>[];
      final api = Api(
        persistNative: false,
        client: MockClient((r) async {
          reads.add(r.url.path);
          return response({'items': [], 'total': 0});
        }),
      )..workspace = 'w';
      final page = WorkspacePage(
        api: api,
        user: const {'name': 'تجربة'},
        logout: () {},
      );
      await tester.pumpWidget(host(page));
      await tester.pumpAndSettle();
      final search = find.byType(TextField).first;
      await tester.enterText(search, 'Volvo');
      final count = reads.length;
      for (final width in [900.0, 1440.0, 390.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(search).controller!.text, 'Volvo');
        expect(reads.length, count);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
