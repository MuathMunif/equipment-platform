import 'dart:async';
import 'dart:convert';

import 'package:equipment_app/api.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/design_system/equipment_typography.dart';
import 'package:equipment_app/documents.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/localization.dart';
import 'package:equipment_app/main.dart';
import 'package:equipment_app/maintenance.dart';
import 'package:equipment_app/projects.dart';
import 'package:equipment_app/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const equipment = <String, dynamic>{
  'id': 'eq',
  'name': 'الشاحنة الأولى Volvo FH16',
  'model': 'FH 460',
  'reference': 'EQ-004',
  'archivedAt': null,
};
const entry = <String, dynamic>{
  'id': 'e1',
  'equipmentId': 'eq',
  'equipmentName': 'الشاحنة الأولى Volvo FH16',
  'entryType': 'EXPENSE',
  'expenseScope': 'SINGLE',
  'category': 'FUEL',
  'operationDate': '2026-10-01',
  'amount': '123456789.99',
  'lifecycle': 'POSTED',
  'settlementStatus': 'PARTIAL',
};
const ownerCaps = {
  'EQUIPMENT_MANAGE',
  'FINANCE_VIEW',
  'DOCUMENT_VIEW',
  'DOCUMENT_MANAGE',
  'ISSUE_VIEW',
  'ISSUE_MANAGE',
  'MAINTENANCE_VIEW',
  'MAINTENANCE_MANAGE',
  'PROJECT_VIEW',
};
http.Response response(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Api apiFor({
  List<dynamic> entries = const [entry],
  Set<String> caps = ownerCaps,
  Future<http.Response> Function(http.Request)? override,
  List<String>? requests,
}) =>
    Api(
        persistNative: false,
        client: MockClient((r) async {
          requests?.add(r.url.toString());
          if (override != null) return override(r);
          if (r.url.path.endsWith('/equipment/eq')) return response(equipment);
          if (r.url.path.endsWith('/entries')) {
            return response({'items': entries, 'total': entries.length});
          }
          if (r.url.path.endsWith('/issues') ||
              r.url.path.endsWith('/maintenance') ||
              r.url.path.endsWith('/drafts')) {
            return response({'items': [], 'total': 0});
          }
          return response([]);
        }),
      )
      ..workspace = 'w'
      ..capabilities = caps;

Widget host(Widget child, {String locale = 'ar', double scale = 1}) =>
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
      home: child,
    );
void size(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    // Flutter widget tests normally substitute Ahem. Load the actual pilot faces
    // so wrapping checks exercise Almarai and its approved local fallback.
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

  test('Direction A tonal search button has readable icon contrast', () {
    final colors = EquipmentA.theme().colorScheme;
    final contrast =
        (colors.secondaryContainer.computeLuminance() + .05) /
        (colors.onSecondaryContainer.computeLuminance() + .05);
    expect(contrast, greaterThanOrEqualTo(4.5));
  });

  for (final locale in ['ar', 'en', 'ur']) {
    for (final width in [320.0, 390.0, 1440.0]) {
      testWidgets(
        'real detail widgets $locale/$width, mixed long name, expanded text',
        (tester) async {
          size(tester, width);
          final requests = <String>[];
          await tester.pumpWidget(
            host(
              EquipmentDetail(
                api: apiFor(requests: requests),
                equipment: {
                  ...equipment,
                  'name':
                      '${equipment['name']} — معدة نقل المعدات الثقيلة طويلة الاسم ٹ ڈ ڑ ں ھ ہ ے پ چ ژ گ',
                },
                canAssignDrivers: true,
              ),
              locale: locale,
              scale: width == 320 ? 1.6 : 1,
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(
            find.byKey(const Key('pilotEquipmentName')),
          );
          expect(
            Directionality.of(context),
            locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
          expect(Theme.of(context).colorScheme.primary, EquipmentA.accent);
          final typography = Theme.of(context).textTheme;
          expect(
            typography.headlineLarge!.fontFamily,
            EquipmentTypography.family,
          );
          expect(typography.headlineLarge!.fontWeight, FontWeight.w700);
          expect(typography.bodyMedium!.fontFamily, EquipmentTypography.family);
          expect(typography.bodyMedium!.fontWeight, FontWeight.w400);
          expect(typography.bodySmall!.fontWeight, FontWeight.w400);
          expect(typography.bodyMedium!.fontFamilyFallback, [
            EquipmentTypography.fallbackFamily,
          ]);
          expect(
            MediaQuery.textScalerOf(context).scale(14),
            closeTo(width == 320 ? 22.4 : 14, .001),
          );
          expect(find.text('EQ-004'), findsOneWidget);
          expect(find.byKey(const Key('addExpense')), findsOneWidget);
          expect(find.byKey(const Key('addIncome')), findsOneWidget);
          expect(find.byKey(const Key('quickCapture')), findsOneWidget);
          expect(
            find.byKey(const Key('openEquipmentDriverAssignment')),
            findsOneWidget,
          );
          expect(find.byType(EquipmentDocumentsCard), findsOneWidget);
          expect(find.byType(EquipmentMaintenanceCard), findsOneWidget);
          final money = find.text(localizedMoney(context, entry['amount']));
          await reveal(tester, money);
          expect(money, findsOneWidget);
          await reveal(
            tester,
            find.byKey(const Key('pilotOptionalConnections')),
          );
          await tester.tap(find.byKey(const Key('pilotOptionalConnections')));
          await tester.pumpAndSettle();
          expect(find.byType(EquipmentM6Context), findsOneWidget);
          expect(
            requests.any(
              (s) =>
                  s.contains('/workspaces/w/entries?') &&
                  s.contains('equipmentId=eq'),
            ),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'restricted member exposes no finance, team controls, documents, or counts',
    (tester) async {
      size(tester, 390);
      final requests = <String>[];
      await tester.pumpWidget(
        host(
          EquipmentDetail(
            api: apiFor(caps: {}, requests: requests),
            equipment: equipment,
            canManage: false,
            canFinance: false,
            canFinanceManage: false,
            canDocuments: false,
            canMaintenance: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final key in [
        'addExpense',
        'addIncome',
        'openEquipmentDrafts',
        'quickCapture',
        'openEquipmentDriverAssignment',
        'toggleEquipmentArchive',
      ]) {
        expect(find.byKey(Key(key)), findsNothing);
      }
      expect(find.byType(LedgerPage), findsNothing);
      expect(find.byType(EquipmentDocumentsCard), findsNothing);
      expect(find.byType(EquipmentMaintenanceCard), findsNothing);
      expect(
        find.byType(EquipmentBadge),
        findsOneWidget,
      ); // equipment reference only
      expect(requests, hasLength(1));
      expect(requests.single, endsWith('/workspaces/w/equipment/eq'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('REVIEW mode keeps submission route and omits direct writes', (
    tester,
  ) async {
    size(tester, 390);
    await tester.pumpWidget(
      host(
        EquipmentDetail(
          api: apiFor(caps: {}),
          equipment: equipment,
          canManage: false,
          canFinanceManage: false,
          canSubmitReview: true,
          canDocuments: false,
          canMaintenance: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('addExpense')), findsNothing);
    expect(find.byKey(const Key('quickCapture')), findsNothing);
    await tester.tap(find.byKey(const Key('submitExpenseForReview')));
    await tester.pumpAndSettle();
    expect(find.byType(SubmissionFormPage), findsOneWidget);
  });

  testWidgets(
    'history loading, recoverable failure and empty response remain distinct',
    (tester) async {
      size(tester, 1440);
      final pending = Completer<http.Response>();
      var attempts = 0;
      final api = apiFor(
        caps: {},
        override: (r) async {
          if (r.url.path.endsWith('/entries')) {
            attempts++;
            if (attempts == 1) return pending.future;
            return response({'items': [], 'total': 0});
          }
          return response(equipment);
        },
      );
      await tester.pumpWidget(
        host(
          EquipmentDetail(
            api: api,
            equipment: equipment,
            canDocuments: false,
            canMaintenance: false,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(EquipmentLoading), findsOneWidget);
      expect(find.byType(EquipmentEmpty), findsNothing);
      pending.complete(response({'code': 'NETWORK'}, 503));
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentError), findsOneWidget);
      expect(find.byType(EquipmentEmpty), findsNothing);
      expect(find.textContaining('0.00'), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(EquipmentError),
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.byType(EquipmentError), findsNothing);
      expect(find.byType(EquipmentEmpty), findsOneWidget);
      expect(find.byKey(const Key('addExpense')), findsOneWidget);
    },
  );

  testWidgets(
    'optional connections failure never claims no organization or projects',
    (tester) async {
      size(tester, 1440);
      var attempts = 0;
      await tester.pumpWidget(
        host(
          EquipmentDetail(
            api: apiFor(
              caps: {},
              override: (r) async {
                attempts++;
                return attempts == 1
                    ? response({'code': 'NETWORK'}, 503)
                    : response(equipment);
              },
            ),
            equipment: equipment,
            canFinance: false,
            canManage: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final loc = l10n(tester.element(find.byType(EquipmentIdentity)));
      expect(find.byType(EquipmentError), findsOneWidget);
      expect(find.text(loc.m6NoOrganization), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(EquipmentError),
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(loc.m6NoOrganization), findsOneWidget);
    },
  );

  for (final action in [
    'addExpense',
    'addIncome',
    'quickCapture',
    'openEquipmentDrafts',
    'openEquipmentDocuments',
    'openEquipmentDriverAssignment',
  ]) {
    testWidgets(
      '$action retains existing route, equipment context and root theme',
      (tester) async {
        size(tester, 1440);
        final api = apiFor();
        await tester.pumpWidget(
          host(
            EquipmentDetail(
              api: api,
              equipment: equipment,
              canAssignDrivers: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        final target = find.byKey(Key(action));
        await reveal(tester, target);
        await tester.tap(target);
        await tester.pumpAndSettle();
        final type = switch (action) {
          'addExpense' || 'addIncome' => ExpenseForm,
          'quickCapture' => DraftCapturePage,
          'openEquipmentDrafts' => DraftListPage,
          'openEquipmentDocuments' => DocumentListPage,
          _ => EquipmentDriverAssignmentPage,
        };
        final route = find.byType(type);
        expect(route, findsOneWidget);
        expect(
          Theme.of(tester.element(route)).colorScheme.primary,
          EquipmentA.accent,
        );
        expect(
          Theme.of(tester.element(route)).textTheme.bodyMedium!.fontFamily,
          EquipmentTypography.family,
          reason: 'Normal routes inherit the approved root typography',
        );
        if (type == ExpenseForm) {
          final form = tester.widget<ExpenseForm>(route);
          expect(form.api, same(api));
          expect(form.equipment['id'], 'eq');
          expect(form.income, action == 'addIncome');
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
