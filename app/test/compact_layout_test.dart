import 'dart:io';
import 'dart:ui' as ui;

import 'package:equipment_app/api.dart';
import 'package:equipment_app/compact_workspace_layout.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:equipment_app/localization.dart';
import 'package:equipment_app/main.dart';
import 'package:equipment_app/maintenance.dart';
import 'package:equipment_app/projects.dart';
import 'package:equipment_app/reports.dart';
import 'package:equipment_app/team.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'home_layout_test.dart' as home;

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('COMPACT_LAYOUT_EVIDENCE')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('homeEvidence')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(
      '../docs/design/ui-refresh/compact-layout-review/screenshots/harness-$name.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
  });
}

AppLocalizations loc(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(WorkspacePage)))!;
Finder menu() => find.byKey(const Key('compactMoreMenu'));

void assertFonts(WidgetTester tester, Finder scope, double scale) {
  for (final element
      in find.descendant(of: scope, matching: find.byType(Text)).evaluate()) {
    final widget = element.widget as Text;
    final style = DefaultTextStyle.of(element).style.merge(widget.style);
    expect(style.fontFamily, 'EquipmentAlmarai');
    expect(style.fontFamilyFallback, ['EquipmentPlex']);
    expect([FontWeight.w400, FontWeight.w700], contains(style.fontWeight));
    expect(
      MediaQuery.textScalerOf(element).scale(14),
      closeTo(14 * scale, .001),
    );
    expect(widget.textScaler, isNull);
  }
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

  testWidgets(
    'compact home retains amount roles, order, source values and references',
    (tester) async {
      final f = home.HomeFixture();
      await home.mount(tester, f.page());
      expect(
        tester.getRect(find.byKey(const Key('dashboardMonth'))).top,
        lessThan(
          tester.getRect(find.byKey(const Key('recordedExpenseCard'))).top,
        ),
      );
      expect(
        tester.getRect(find.byKey(const Key('recordedExpenseCard'))).bottom,
        lessThan(
          tester.getRect(find.byKey(const Key('homeCurrentEquipment'))).top,
        ),
      );
      final entry = find.byKey(const Key('homeRecent-entry0'));
      final money = find.descendant(
        of: entry,
        matching: find.textContaining('1,000.00'),
      );
      expect(money, findsOneWidget);
      expect(
        tester.widget<Text>(money).style,
        Theme.of(tester.element(money)).textTheme.titleMedium,
      );
      final date = find.descendant(
        of: entry,
        matching: find.text(localizedDate(tester.element(entry), '2026-09-01')),
      );
      expect(
        tester.getRect(date).center.dx,
        greaterThan(tester.getRect(money).center.dx),
      );
      expect(find.byKey(const Key('homeRecent-entry3')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('homeEquipment-eq0')));
      final row = find.byKey(const Key('homeEquipment-eq0'));
      final reference = find.descendant(
        of: row,
        matching: find.text('EQ-000000'),
      );
      final name = find.descendant(of: row, matching: find.text('Truck 0'));
      expect(
        tester.getRect(reference).right,
        closeTo(tester.getRect(name).right, .1),
      );
      assertFonts(tester, row, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'equipment has one explicit scoped search, keyboard submit, pagination, detail and add',
    (tester) async {
      final requests = <http.Request>[];
      final api = Api(
        persistNative: false,
        client: MockClient((r) async {
          requests.add(r);
          if (r.url.path.endsWith('/equipment')) {
            final page = r.url.queryParameters['page'];
            return home.reply({
              'items': [
                {
                  'id': 'eq$page',
                  'name': 'Truck $page',
                  'model': 'FH 460',
                  'reference': 'EQ-00000$page',
                },
              ],
              'total': 31,
            });
          }
          return home.reply({'items': [], 'total': 0});
        }),
      )..workspace = 'scope-one';
      await home.mount(
        tester,
        Scaffold(
          body: EquipmentList(api: api, home: false, name: 'Owner'),
        ),
      );
      final search = find.byKey(const Key('equipmentSearch'));
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('عرض السجل والعمليات ←'), findsNothing);
      expect(requests.length, 1);
      await tester.enterText(search, 'Volvo');
      await tester.pump();
      expect(requests.length, 1); // no per-keystroke/rebuild query
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(requests.last.url.path, '/api/v1/workspaces/scope-one/equipment');
      expect(requests.last.url.queryParameters, {
        'page': '0',
        'search': 'Volvo',
      });
      await tester.tap(find.byKey(const Key('equipmentSearchSubmit')));
      await tester.pumpAndSettle();
      expect(
        requests.where((r) => r.url.path.endsWith('/equipment')).length,
        3,
      );
      final l = AppLocalizations.of(tester.element(search))!;
      await tester.tap(find.text(l.next));
      await tester.pumpAndSettle();
      expect(requests.last.url.queryParameters, {
        'page': '1',
        'search': 'Volvo',
      });
      final row = find.byKey(const Key('equipmentRow-eq1'));
      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(row).label,
        contains(l.uiViewRecordsAndEntries),
      );
      semantics.dispose();
      await tester.tap(row);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EquipmentDetail>(find.byType(EquipmentDetail))
            .equipment['id'],
        'eq1',
      );
      Navigator.of(tester.element(find.byType(EquipmentDetail))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addEquipment')));
      await tester.pumpAndSettle();
      expect(find.byType(EquipmentForm), findsOneWidget);
      expect(requests.every((r) => r.method == 'GET'), isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'equipment empty, failure retry and read-only creation gate remain truthful',
    (tester) async {
      var status = 503;
      final api = Api(
        persistNative: false,
        client: MockClient(
          (r) async => home.reply({'items': [], 'total': 0}, status),
        ),
      )..workspace = 'w';
      await home.mount(
        tester,
        Scaffold(
          body: EquipmentList(
            api: api,
            home: false,
            name: 'Reader',
            canManage: false,
          ),
        ),
      );
      expect(find.byType(ErrorPanel), findsOneWidget);
      expect(find.byType(CompactEquipmentRow), findsNothing);
      status = 200;
      final l = AppLocalizations.of(tester.element(find.byType(ErrorPanel)))!;
      await tester.tap(find.text(l.retry));
      await tester.pumpAndSettle();
      expect(find.text(l.noEquipmentMatches), findsOneWidget);
      expect(find.byKey(const Key('addEquipment')), findsNothing);
      expect(find.byKey(const Key('equipmentSearchSubmit')), findsOneWidget);
    },
  );

  testWidgets(
    'more owner destinations preserve order, routes, back and selection',
    (tester) async {
      final f = home.HomeFixture();
      await home.mount(tester, f.page());
      final l = loc(tester);
      await tester.tap(find.text(l.m7More));
      await tester.pumpAndSettle();
      final labels = [
        l.m7Reports,
        l.m4Hub,
        l.m6Organizations,
        l.m6ProjectsContracts,
        l.m5Team,
        l.m5ReviewQueue,
        l.settings,
      ];
      final rows = find.descendant(of: menu(), matching: find.byType(ListTile));
      expect(
        tester.widgetList<ListTile>(rows).map((w) => (w.title as Text).data),
        labels,
      );
      expect(tester.getSize(menu()).height, lessThanOrEqualTo(450));
      final types = [
        ReportsPage,
        MaintenanceHub,
        OrganizationsPage,
        ProjectsPage,
        TeamPage,
        ReviewQueuePage,
      ];
      for (var i = 0; i < labels.length; i++) {
        final target = find.descendant(
          of: menu(),
          matching: find.text(labels[i]),
        );
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
        if (i < types.length) {
          expect(find.byType(types[i]), findsOneWidget);
        } else {
          expect(find.text(l.m7AccountInfo), findsOneWidget);
        }
        Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
        await tester.pumpAndSettle();
        expect(menu(), findsOneWidget);
        expect(
          tester
              .widget<EquipmentNavigationBar>(
                find.byType(EquipmentNavigationBar),
              )
              .selectedIndex,
          3,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'more restricted user has only permitted rows without blank slots',
    (tester) async {
      final f = home.HomeFixture()
        ..finance = false
        ..equipment = false;
      await home.mount(tester, f.page());
      final l = loc(tester);
      await tester.tap(find.text(l.m7More));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: menu(), matching: find.byType(ListTile)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: menu(), matching: find.text(l.settings)),
        findsOneWidget,
      );
      expect(tester.getSize(menu()).height, lessThanOrEqualTo(64));
      expect(find.byType(Divider), findsNothing);
      expect(
        tester
            .widget<EquipmentNavigationBar>(find.byType(EquipmentNavigationBar))
            .selectedIndex,
        1,
      );
    },
  );

  for (final locale in ['ar', 'en', 'ur']) {
    for (final (width, scale) in [
      (390.0, 1.0),
      (320.0, 1.6),
      (320.0, 2.0),
      (1440.0, 1.0),
    ]) {
      testWidgets(
        'three compact screens $locale $width x$scale inherit fonts and remain scrollable',
        (tester) async {
          final f = home.HomeFixture()..longNames = true;
          await home.mount(
            tester,
            f.page(),
            width: width,
            scale: scale,
            locale: locale,
          );
          final l = loc(tester);
          assertFonts(
            tester,
            find.byKey(const Key('homeRecentEntries')),
            scale,
          );
          await capture(tester, 'home-$locale-${width.toInt()}-$scale');
          await tester.ensureVisible(
            find.byKey(const Key('homeEquipment-eq2')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('homeEquipment-eq2')).hitTestable(),
            findsOneWidget,
          );
          await tester.ensureVisible(
            find.byKey(const Key('homeViewEquipment')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('homeViewEquipment')));
          await tester.pumpAndSettle();
          final row = find.byKey(const Key('equipmentRow-eq0'));
          assertFonts(tester, row, scale);
          final name = find.descendant(
            of: row,
            matching: find.textContaining('شاحنة'),
          );
          expect(
            tester.widget<Text>(name).style,
            Theme.of(tester.element(name)).textTheme.titleLarge,
          );
          expect(tester.widget<Text>(name).maxLines, isNull);
          await capture(tester, 'equipment-$locale-${width.toInt()}-$scale');
          await tester.ensureVisible(find.byKey(const Key('equipmentRow-eq3')));
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('equipmentRow-eq3')).hitTestable(),
            findsOneWidget,
          );
          await tester.tap(find.text(l.m7More).last);
          await tester.pumpAndSettle();
          assertFonts(tester, menu(), scale);
          expect(
            Directionality.of(tester.element(menu())),
            locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
          await capture(tester, 'more-$locale-${width.toInt()}-$scale');
          await tester.ensureVisible(
            find.descendant(of: menu(), matching: find.text(l.settings)),
          );
          await tester.pumpAndSettle();
          expect(
            find
                .descendant(of: menu(), matching: find.text(l.settings))
                .hitTestable(),
            findsOneWidget,
          );
          if (width == 1440) {
            expect(tester.getSize(menu()).width, lessThanOrEqualTo(720));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
