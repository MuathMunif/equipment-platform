import 'dart:ui' as ui;

import 'package:equipment_app/design_preview/screens.dart';
import 'package:equipment_app/design_preview/tokens.dart';
import 'package:equipment_app/design_system/equipment_a.dart';
import 'package:equipment_app/localization.dart';
import 'package:equipment_app/typography_preview/fonts.dart';
import 'package:equipment_app/typography_preview/gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TextPainter sample(String family, FontWeight weight) => TextPainter(
  text: TextSpan(
    text: 'الشَّاحِنَةُ الأولى Volvo 1234.50 ٹ ڈ ڑ ں ھ ہ ے پ چ ژ گ',
    style: TextStyle(fontFamily: family, fontSize: 30, fontWeight: weight),
  ),
  textDirection: TextDirection.rtl,
)..layout();

Future<int> pixels(String family, FontWeight weight) async {
  final painter = sample(family, weight);
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), Offset.zero);
  final picture = recorder.endRecording();
  final image = await picture.toImage(1800, 100);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  var hash = 0;
  for (final byte in bytes) {
    hash = ((hash * 31) + byte) & 0x3fffffff;
  }
  painter.dispose();
  picture.dispose();
  image.dispose();
  return hash;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTypographyFonts);

  test('bundled candidates really render, with distinct Regular/Bold faces', () async {
    final fallback = await pixels('IntentionallyMissingFont', FontWeight.w400);
    final hashes = <int>{};
    for (final f in TypographyChoice.values) {
      final regular = await pixels(f.family, FontWeight.w400);
      final strong = await pixels(f.family, f.emphasis);
      expect(
        regular,
        isNot(fallback),
        reason: '${f.name} must not silently render the missing-font fallback',
      );
      expect(
        regular,
        isNot(strong),
        reason: '${f.name} emphasis must change actual glyph pixels',
      );
      hashes.add(regular);
      final p400 = sample(f.family, FontWeight.w400);
      final pStrong = sample(f.family, f.emphasis);
      // Evidence, not exact attribution of every glyph in a mixed-script run.
      debugPrint(
        'FONT_LOAD ${f.name} ${f.family} 400 width=${p400.width.toStringAsFixed(2)} ${f.emphasis.value} width=${pStrong.width.toStringAsFixed(2)} pixels=$regular/$strong',
      );
      p400.dispose();
      pStrong.dispose();
    }
    expect(hashes.length, 4);
  });

  test(
    'A palette/layout scale stay fixed; candidates request real400/700 only',
    () {
      for (final f in TypographyChoice.values.take(3)) {
        final theme = f.theme(locale: 'ar', expense: false);
        expect(theme.colorScheme, EquipmentA.theme().colorScheme);
        expect(theme.scaffoldBackgroundColor, EquipmentA.canvas);
        expect(theme.cardTheme, EquipmentA.theme().cardTheme);
        expect(theme.textTheme.headlineLarge!.fontSize, 30);
        expect(theme.textTheme.bodyMedium!.fontSize, 14);
        expect(theme.textTheme.headlineLarge!.fontWeight, FontWeight.w700);
        expect(theme.textTheme.bodyMedium!.fontWeight, FontWeight.w400);
        expect(theme.extension<DesignTokens>()!.direction, DesignDirection.a);
      }
      expect(TypographyChoice.f2.familyFor('ur'), TypographyChoice.f1.family);
      expect(TypographyChoice.f2.familyFor('en'), TypographyChoice.f2.family);
      expect(EquipmentA.family, 'EquipmentNoto');
    },
  );

  Future<void> open(
    WidgetTester tester,
    String f,
    String screen,
    String locale,
    double width, {
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TypographyPreviewApp(
        key: UniqueKey(),
        parameters: {
          'font': f,
          'screen': screen,
          'locale': locale,
          'scale': '$scale',
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final f in ['f1', 'f2', 'f3']) {
    for (final screen in ['equipment', 'expense']) {
      for (final width in [390.0, 1440.0]) {
        testWidgets('$f $screen ar $width controlled layout', (tester) async {
          await open(tester, f, screen, 'ar', width);
          expect(tester.takeException(), isNull);
          expect(
            find.byType(EquipmentIdentity),
            screen == 'equipment' ? findsOneWidget : findsNothing,
          );
          final context = tester.element(find.byType(Scaffold).first);
          for (final value in ['0.00', '1234.50', '-125.25']) {
            expect(find.text(localizedMoney(context, value)), findsOneWidget);
          }
          final specimen = find.byKey(const Key('urduGlyphSpecimen'));
          await tester.ensureVisible(specimen);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
    for (final locale in ['ar', 'en', 'ur']) {
      testWidgets('$f $locale 320 text160%, both layouts and Urdu specimen', (
        tester,
      ) async {
        for (final screen in ['equipment', 'expense']) {
          await open(tester, f, screen, locale, 320, scale: 1.6);
          expect(tester.takeException(), isNull, reason: screen);
          final context = tester.element(find.byType(Scaffold).first);
          expect(
            Directionality.of(context),
            locale == 'en' ? TextDirection.ltr : TextDirection.rtl,
          );
          final specimen = find.byKey(const Key('urduGlyphSpecimen'));
          await tester.ensureVisible(specimen);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$screen specimen');
        }
      });
    }
  }

  testWidgets(
    'preview multiplier preserves device accessibility text scaling',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await open(tester, 'f3', 'equipment', 'ar', 390, scale: 1.6);
      final context = tester.element(find.byType(Scaffold).first);
      expect(MediaQuery.textScalerOf(context).scale(14), closeTo(29.12, .001));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'font switching retains typed expense amount; preview never saves',
    (tester) async {
      await open(tester, 'f1', 'expense', 'en', 1440);
      await tester.enterText(find.byKey(const Key('previewAmount')), '125.25');
      await tester.tap(find.byKey(const Key('typographyControls')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('font-f2')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Return to comparison'));
      await tester.tap(find.text('Return to comparison'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('previewAmount')))
            .controller!
            .text,
        '125.25',
      );
      final target = find.byKey(const Key('previewSave'));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      final loc = l10n(tester.element(find.byType(ExpensePreview)));
      expect(find.text(loc.previewNoWrite), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
