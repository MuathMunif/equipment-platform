import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_preview/tokens.dart';
import '../design_system/equipment_a.dart';

enum TypographyChoice {
  f1('IBM Plex Sans Arabic', 'ComparisonPlex'),
  f2('Tajawal', 'ComparisonTajawal'),
  f3('Almarai', 'ComparisonAlmarai'),
  baseline('Noto Sans Arabic · rejected baseline', 'EquipmentNoto');

  final String label, family;
  const TypographyChoice(this.label, this.family);

  // Tajawal's bundled cmap lacks 10 of the requested Urdu letters. Use one
  // verified companion for the entire Urdu locale, avoiding mixed word shapes.
  String familyFor(String locale) =>
      this == f2 && locale == 'ur' ? f1.family : family;
  String labelFor(String locale) =>
      this == f2 && locale == 'ur' ? '${f1.label} (Urdu companion)' : label;

  FontWeight get emphasis =>
      this == baseline ? FontWeight.w600 : FontWeight.w700;

  ThemeData theme({required String locale, required bool expense}) {
    final family = familyFor(locale);
    final a = DesignTokens.forDirection(DesignDirection.a);
    final tokens = DesignTokens(
      direction: a.direction,
      canvas: a.canvas,
      ink: a.ink,
      muted: a.muted,
      line: a.line,
      accent: a.accent,
      tint: a.tint,
      radius: a.radius,
      gap: a.gap,
      family: family,
      headingFamily: family,
      emphasis: emphasis,
    );
    final base = expense ? tokens.theme() : EquipmentA.referenceTheme();
    TextStyle face(TextStyle? style) {
      final original = style ?? const TextStyle();
      return original.copyWith(
        fontFamily: family,
        fontFamilyFallback: [TypographyChoice.f1.family],
        // Every candidate uses real Regular400 and Bold700 files. No invented
        // 500/600 face or per-option layout/size adjustment.
        fontWeight: this == baseline
            ? original.fontWeight
            : (original.fontWeight ?? FontWeight.w400).value >= 500
            ? FontWeight.w700
            : FontWeight.w400,
      );
    }

    final t = base.textTheme;
    final text = TextTheme(
      displayLarge: face(t.displayLarge),
      displayMedium: face(t.displayMedium),
      displaySmall: face(t.displaySmall),
      headlineLarge: face(t.headlineLarge),
      headlineMedium: face(t.headlineMedium),
      headlineSmall: face(t.headlineSmall),
      titleLarge: face(t.titleLarge),
      titleMedium: face(t.titleMedium),
      titleSmall: face(t.titleSmall),
      bodyLarge: face(t.bodyLarge),
      bodyMedium: face(t.bodyMedium),
      bodySmall: face(t.bodySmall),
      labelLarge: face(t.labelLarge),
      labelMedium: face(t.labelMedium),
      labelSmall: face(t.labelSmall),
    );
    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      extensions: [tokens],
      appBarTheme: base.appBarTheme.copyWith(titleTextStyle: text.titleLarge),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        labelStyle: face(base.inputDecorationTheme.labelStyle),
        floatingLabelStyle: face(base.inputDecorationTheme.floatingLabelStyle),
        hintStyle: face(base.inputDecorationTheme.hintStyle),
        errorStyle: face(base.inputDecorationTheme.errorStyle),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: base.filledButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: base.outlinedButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: base.textButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: text.bodySmall?.copyWith(color: EquipmentA.ink),
      ),
      tooltipTheme: base.tooltipTheme.copyWith(
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }
}

const comparisonFontAssets = <String, List<String>>{
  'ComparisonPlex': [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ],
  'ComparisonTajawal': ['Tajawal-Regular.ttf', 'Tajawal-Bold.ttf'],
  'ComparisonAlmarai': ['Almarai-Regular.ttf', 'Almarai-Bold.ttf'],
};

Future<void> loadTypographyFonts() async {
  for (final entry in comparisonFontAssets.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/typography_fonts/$file'));
    }
    await loader.load();
  }
  // Explicit load also makes the rejected baseline measurable in widget tests.
  final baseline = FontLoader('EquipmentNoto');
  baseline.addFont(
    rootBundle.load('assets/design_fonts/NotoSansArabic[wdth,wght].ttf'),
  );
  await baseline.load();
}
