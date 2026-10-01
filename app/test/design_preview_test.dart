import 'package:equipment_app/design_preview/gallery.dart';
import 'package:equipment_app/design_preview/fixtures.dart';
import 'package:equipment_app/design_preview/tokens.dart';
import 'package:equipment_app/design_preview/screens.dart';
import 'package:equipment_app/main_design_preview.dart' show loadPreviewFonts;
import 'package:equipment_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadPreviewFonts);

  Future<void> open(
    WidgetTester tester, {
    String direction = 'a',
    String screen = 'home',
    String locale = 'ar',
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      DesignPreviewApp(
        key: UniqueKey(),
        parameters: {
          'direction': direction,
          'screen': screen,
          'locale': locale,
          'scale': '$scale',
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final direction in ['a', 'b', 'c']) {
    for (final screen in ['home', 'equipment', 'expense']) {
      for (final width in [390.0, 1440.0]) {
        testWidgets(
          '$direction $screen Arabic ${width.toInt()} renders without overflow',
          (tester) async {
            await open(
              tester,
              direction: direction,
              screen: screen,
              width: width,
            );
            expect(tester.takeException(), isNull);
            expect(find.text(PreviewFixtures.equipment), findsWidgets);
          },
        );
      }
    }
    for (final locale in ['ar', 'en', 'ur']) {
      testWidgets('$direction $locale narrow 320 large 1.6 text', (
        tester,
      ) async {
        for (final screen in ['home', 'equipment', 'expense', 'states']) {
          await open(
            tester,
            direction: direction,
            screen: screen,
            locale: locale,
            width: 320,
            scale: 1.6,
          );
          expect(tester.takeException(), isNull, reason: screen);
          final context = tester.element(find.byType(Scaffold).first);
          expect(
            Directionality.of(context),
            locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
        }
      });
    }
  }

  testWidgets(
    'full settlement visible; partial validates amount and party; preview never claims save',
    (tester) async {
      await open(tester, screen: 'expense', locale: 'en', width: 1440);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const Key('payment-FULL')))
            .selected,
        isTrue,
      );
      await tap(tester, 'payment-PARTIAL');
      await tester.enterText(
        find.byKey(const Key('previewInitialPaid')),
        '400',
      );
      await tap(tester, 'previewSave');
      final loc = lookupAppLocalizations(const Locale('en'));
      expect(find.text(loc.uiEnterAnAmountAboveZeroAndBelow), findsOneWidget);
      expect(find.text(loc.uiEnterPartyName), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('previewInitialPaid')),
        '100.00',
      );
      await tester.enterText(
        find.byKey(const Key('previewParty')),
        'Synthetic supplier',
      );
      await tap(tester, 'previewSave');
      expect(find.text(loc.previewNoWrite), findsOneWidget);
    },
  );

  testWidgets(
    'unpaid hides initial payment and requires party; cancel guards edited input',
    (tester) async {
      await open(tester, screen: 'expense', locale: 'en', width: 1440);
      await tap(tester, 'payment-UNPAID');
      expect(find.byKey(const Key('previewInitialPaid')), findsNothing);
      await tap(tester, 'previewSave');
      final loc = lookupAppLocalizations(const Locale('en'));
      expect(find.text(loc.uiEnterPartyName), findsOneWidget);
      await tap(tester, 'previewCancel');
      expect(find.text(loc.previewDiscardTitle), findsOneWidget);
      await tester.tap(find.text(loc.previewKeepEditing));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('previewAmount')), findsOneWidget);
    },
  );

  testWidgets(
    'attachment retry keeps entered amount and does not create another record',
    (tester) async {
      await open(tester, screen: 'expense', locale: 'en', width: 1440);
      await tester.enterText(find.byKey(const Key('previewAmount')), '125.25');
      await tap(tester, 'failAttachment');
      expect(
        find.text(
          lookupAppLocalizations(const Locale('en')).uiAttachmentUploadFailed,
        ),
        findsOneWidget,
      );
      await tap(tester, 'retryAttachment');
      expect(find.text('synthetic-receipt.png'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('previewAmount')))
            .controller!
            .text,
        '125.25',
      );
    },
  );

  testWidgets(
    'load failure and denied states never present zero; retry restores fixture',
    (tester) async {
      await open(tester, screen: 'states', locale: 'en', width: 1440);
      final loc = lookupAppLocalizations(const Locale('en'));
      for (final state in ['error', 'denied']) {
        await tap(tester, 'state-$state');
        expect(find.text(loc.previewNotAvailable), findsOneWidget);
        expect(find.textContaining('1,000.00'), findsNothing);
        expect(find.textContaining('0.00 SAR'), findsNothing);
      }
      await tap(tester, 'state-error');
      await tap(tester, 'retryState');
      expect(find.textContaining('1,000.00'), findsOneWidget);
      expect(find.textContaining('400.00'), findsOneWidget);
      expect(find.textContaining('600.00'), findsNWidgets(2));
    },
  );

  testWidgets(
    'Arabic owner home has labeled 48px tap targets and readable contrast',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await open(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantics.dispose();
    },
  );

  test('interactive outlines have at least 3:1 contrast on white', () {
    for (final direction in DesignDirection.values) {
      final color = DesignTokens.forDirection(direction).controlBorder;
      expect(1.05 / (color.computeLuminance() + .05), greaterThanOrEqualTo(3));
    }
  });

  testWidgets(
    'shared allocations sum exactly; general scope clears equipment context',
    (tester) async {
      await open(tester, screen: 'expense', locale: 'en', width: 1440);
      await tap(tester, 'previewOptional');
      await tap(tester, 'previewScope');
      final loc = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(loc.uiMultipleEquipment).last);
      await tester.pumpAndSettle();
      Finder allocation(String label) => find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == label,
      );
      await tester.enterText(allocation(PreviewFixtures.equipment), '200.00');
      await tester.enterText(
        allocation(PreviewFixtures.secondEquipment),
        '140.00',
      );
      await tap(tester, 'previewSave');
      expect(
        find.text(loc.uiAdjustEachEquipmentAmountToMatchThe),
        findsNWidgets(2),
      );
      await tester.enterText(
        allocation(PreviewFixtures.secondEquipment),
        '150.00',
      );
      await tap(tester, 'previewSave');
      expect(find.text(loc.previewNoWrite), findsOneWidget);
      await tester.tap(find.text(loc.back));
      await tester.pumpAndSettle();
      await tap(tester, 'previewScope');
      await tester.tap(find.text(loc.generalExpense).last);
      await tester.pumpAndSettle();
      expect(find.text(PreviewFixtures.equipment), findsNothing);
      expect(find.text(loc.uiAWorkspaceExpenseItIsNotAssigned), findsOneWidget);
    },
  );

  testWidgets(
    'narrow home finance cards use the full available content width',
    (tester) async {
      await open(tester, width: 320, locale: 'en');
      final loc = lookupAppLocalizations(const Locale('en'));
      for (final title in [
        loc.previewRecordedExpenses,
        loc.previewRecordedIncome,
      ]) {
        final card = find.ancestor(
          of: find.text(title),
          matching: find.byType(PreviewSurface),
        );
        expect(tester.getSize(card).width, 280);
      }
    },
  );

  testWidgets('keyboard inset and tab focus do not overflow expense', (
    tester,
  ) async {
    await open(tester, screen: 'expense');
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.tap(find.byKey(const Key('previewAmount')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, isNotNull);
    await tester.ensureVisible(find.byKey(const Key('previewAmount')));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const Key('previewAmount'))).bottom,
      lessThanOrEqualTo(680),
    );
    await tester.ensureVisible(find.byKey(const Key('previewSave')));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const Key('previewSave'))).bottom,
      lessThanOrEqualTo(680),
    );
    expect(tester.takeException(), isNull);
  });
}
