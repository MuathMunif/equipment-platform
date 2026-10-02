import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/documents.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/design_system/equipment_typography.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/main.dart';
import 'package:equipment_app/maintenance.dart';
import 'package:equipment_app/reports.dart';
import 'package:equipment_app/projects.dart';
import 'package:equipment_app/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  setUpAll(() async {
    for (final entry in {
      EquipmentTypography.family: 'Almarai',
      EquipmentTypography.fallbackFamily: 'IBMPlexSansArabic',
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final weight in ['Regular', 'Bold']) {
        loader.addFont(
          rootBundle.load('assets/typography_fonts/${entry.value}-$weight.ttf'),
        );
      }
      await loader.load();
    }
  });

  for (final locale in ['ar', 'en', 'ur']) {
    testWidgets('project filters and optional form fit320/200% $locale', (
      tester,
    ) async {
      viewport(tester, 320, 800);
      final api = Api(
        persistNative: false,
        client: MockClient((_) async => response([])),
      )..workspace = 'w';
      await tester.pumpWidget(
        host(
          ProjectsPage(api: api, canManage: true, canFinance: true),
          locale: locale,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        host(ProjectForm(api: api), locale: locale, scale: 2),
      );
      await tester.pumpAndSettle();
      final name = find.byKey(const Key('projectName'));
      await tester.ensureVisible(name);
      await tester.enterText(name, 'مشروع الاختبار / Project A');
      tester.view.physicalSize = const Size(1440, 800);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(name).controller!.text,
        'مشروع الاختبار / Project A',
      );
      tester.view.physicalSize = const Size(320, 800);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('saveProject')));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('saveProject'))).bottom,
        lessThanOrEqualTo(520),
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in ['ar', 'en', 'ur']) {
    testWidgets(
      'team, driver submission and approval retain controls at320/200% $locale',
      (tester) async {
        viewport(tester, 320, 800);
        var writes = 0;
        final api = Api(
          persistNative: false,
          client: MockClient((r) async {
            if (r.method != 'GET') writes++;
            return response(
              r.url.path.endsWith('/organizations')
                  ? []
                  : {'items': [], 'total': 0},
            );
          }),
        )..workspace = 'w';
        await tester.pumpWidget(
          host(TeamEditorPage(api: api), locale: locale, scale: 2),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('saveTeamMember')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          host(
            SubmissionFormPage(api: api, equipment: equipment),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('submissionAmount')),
          '250',
        );
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('submissionAmount')))
              .controller!
              .text,
          '250',
        );
        tester.view.physicalSize = const Size(320, 800);
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('sendSubmission')));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(const Key('sendSubmission'))).bottom,
          lessThanOrEqualTo(520),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          host(
            ApprovalPage(
              api: api,
              submission: {
                'id': 's',
                'equipmentId': 'eq',
                'amount': '250.00',
                'transactionDate': '2026-10-02',
              },
            ),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('confirmApproval')));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(const Key('confirmApproval'))).bottom,
          lessThanOrEqualTo(520),
        );
        expect(tester.takeException(), isNull);
        expect(writes, 0);
      },
    );
  }

  for (final locale in ['ar', 'en', 'ur']) {
    testWidgets('maintenance form and issue actions fit320/200% $locale', (
      tester,
    ) async {
      viewport(tester, 320, 800);
      final api = Api(
        persistNative: false,
        client: MockClient(
          (r) async => response(
            r.url.path.endsWith('/attachments')
                ? []
                : {
                    'id': 'i',
                    'equipmentId': 'eq',
                    'equipmentName': 'شاحنة اختبار Volvo FH460',
                    'reference': 'IS-000037',
                    'description': 'وصف بلاغ طويل / engine inspection',
                    'status': 'OPEN',
                    'equipmentStopped': true,
                    'createdAt': '2026-10-02',
                    'maintenance': [],
                    'closures': [],
                  },
          ),
        ),
      )..workspace = 'w';
      await tester.pumpWidget(
        host(
          IssueDetailPage(api: api, id: 'i'),
          locale: locale,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('m4Close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('m4Close')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('m4Resolution')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        host(
          MaintenanceFormPage(api: api, equipment: equipment),
          locale: locale,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('m4SaveMaintenance')));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const Key('m4SaveMaintenance'))).bottom,
        lessThanOrEqualTo(520),
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final locale in ['ar', 'en', 'ur']) {
    testWidgets(
      'document renewal keeps date and validation at320/200% $locale',
      (tester) async {
        viewport(tester, 320, 800);
        final api = Api(
          persistNative: false,
          client: MockClient((_) async => response([])),
        )..workspace = 'w';
        await tester.pumpWidget(
          host(
            DocumentFormPage(
              api: api,
              equipment: equipment,
              renewal: true,
              document: {
                'id': 'd',
                'type': 'INSURANCE',
                'currentVersionId': 'v1',
                'documentNumber': 'POL-1',
                'expiryDate': '2026-10-15',
              },
            ),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        final expiry = find.byKey(const Key('documentExpiryDate'));
        await tester.ensureVisible(expiry);
        await tester.enterText(expiry, '2027-10-15');
        tester.view.physicalSize = const Size(900, 800);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextFormField>(expiry).controller!.text,
          '2027-10-15',
        );
        tester.view.physicalSize = const Size(320, 800);
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        final save = find.byKey(const Key('saveDocument'));
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        expect(tester.getRect(save).bottom, lessThanOrEqualTo(520));
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final locale in ['ar', 'en', 'ur']) {
    testWidgets(
      'financial value and refund modal fit320 with real fonts and keyboard $locale',
      (tester) async {
        viewport(tester, 320, 800);
        final api = Api(
          persistNative: false,
          client: MockClient(
            (r) async => response(
              r.url.path.endsWith('/attachments')
                  ? []
                  : {
                      'id': 'e',
                      'entryType': 'EXPENSE',
                      'category': 'FUEL',
                      'equipmentName': 'معدات الاختبار Volvo 460',
                      'expenseScope': 'SINGLE',
                      'operationDate': '2026-10-02',
                      'amount': '999999999.99',
                      'paid': '600.00',
                      'netPaid': '400.00',
                      'refunded': '200.00',
                      'remaining': '999999599.99',
                      'refundable': '400.00',
                      'settlementStatus': 'PARTIAL',
                      'lifecycle': 'POSTED',
                      'partyName': 'مورد اختبار',
                      'note': '',
                      'settlements': [],
                      'refunds': [],
                    },
            ),
          ),
        )..workspace = 'w';
        await tester.pumpWidget(
          host(
            EntryDetail(api: api, id: 'e'),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        final amount = find.textContaining('999,999,999.99');
        expect(amount, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(amount);
        for (final box in paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: paragraph.text.toPlainText().length,
          ),
        )) {
          expect(box.left, greaterThanOrEqualTo(-1));
          expect(box.right, lessThanOrEqualTo(paragraph.size.width + 1));
        }
        await tester.ensureVisible(find.byKey(const Key('addRefund')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('addRefund')));
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await tester.enterText(find.byKey(const Key('refundAmount')), '200');
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('refundReason')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('refundReason')),
          'اختبار فقط',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('saveRefund')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('saveRefund')).hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('month picker keeps every month reachable at320 and200%', (
    tester,
  ) async {
    viewport(tester, 320, 800);
    final api = Api(
      persistNative: false,
      client: MockClient(
        (_) async => response({
          'activeEquipmentCount': 1,
          'summary': {'recordedExpenses': '1000.00', 'recordedIncome': '0.00'},
          'recentEntries': [],
        }),
      ),
    )..workspace = 'w';
    await tester.pumpWidget(
      host(
        Scaffold(
          body: EquipmentPageBody(
            children: [
              DashboardSection(
                api: api,
                canFinance: true,
                canManage: true,
                canSubmitReview: false,
              ),
            ],
          ),
        ),
        scale: 2,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboardMonth')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('ديسمبر'),
      200,
      scrollable: find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('ديسمبر').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    'owner equipment page resize preserves search and does not repeat fetches',
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
      await tester.tap(find.text('المعدات').last);
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

  testWidgets(
    'uncertain shared save freezes allocations and project and retries identical request',
    (tester) async {
      viewport(tester, 1440, 1400);
      final writes = <http.Request>[];
      final api = Api(
        persistNative: false,
        client: MockClient((r) async {
          if (r.method == 'GET') {
            return response({
              'items': [
                equipment,
                {'id': 'eq2', 'name': 'الثانية'},
              ],
              'total': 2,
            });
          }
          writes.add(r);
          return http.Response(
            '{"code":"NETWORK","message":"unavailable"}',
            503,
          );
        }),
      )..workspace = 'w';
      await tester.pumpWidget(
        host(ExpenseForm(api: api, equipment: equipment)),
      );
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('expenseScope')),
          )
          .onChanged!('SHARED');
      await tester.pumpAndSettle();
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('allocationEquipment1')),
          )
          .onChanged!('eq2');
      await tester.enterText(find.byKey(const Key('expenseAmount')), '1000');
      await tester.enterText(find.byKey(const Key('allocationAmount0')), '600');
      await tester.enterText(find.byKey(const Key('allocationAmount1')), '400');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(writes.length, 1);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('allocationAmount0')))
            .enabled,
        isFalse,
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('allocationAmount1')))
            .enabled,
        isFalse,
      );
      await tester.ensureVisible(find.text('تفاصيل إضافية'));
      await tester.tap(find.text('تفاصيل إضافية'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('financeProject')))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveExpense')));
      await tester.pumpAndSettle();
      expect(writes.length, 2);
      expect(writes[1].body, writes[0].body);
      expect(
        writes[1].headers['Idempotency-Key'],
        writes[0].headers['Idempotency-Key'],
      );
      expect(tester.takeException(), isNull);
    },
  );
}
