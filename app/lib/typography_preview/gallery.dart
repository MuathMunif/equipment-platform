import 'package:flutter/material.dart';

import '../design_preview/screens.dart';
import '../design_system/equipment_a.dart';
import '../l10n/app_localizations.dart';
import '../localization.dart';
import 'equipment.dart';
import 'fonts.dart';

// The lab multiplier composes with the device's accessibility scaler.
// It must not replace a user's larger-text preference, including nonlinear scaling.
class _PreviewTextScaler extends TextScaler {
  final TextScaler device;
  final double multiplier;
  const _PreviewTextScaler(this.device, this.multiplier);

  @override
  double scale(double fontSize) => device.scale(fontSize) * multiplier;

  @override
  double get textScaleFactor => scale(14) / 14;
}

class TypographyPreviewApp extends StatefulWidget {
  final Map<String, String> parameters;
  const TypographyPreviewApp({super.key, this.parameters = const {}});
  @override
  State<TypographyPreviewApp> createState() => _TypographyPreviewAppState();
}

class _TypographyPreviewAppState extends State<TypographyPreviewApp> {
  late TypographyChoice choice;
  late String screen, language;
  late double scale;
  final expenseKey = GlobalKey<ExpensePreviewState>();
  @override
  void initState() {
    super.initState();
    choice = TypographyChoice.values.firstWhere(
      (f) => f.name == widget.parameters['font'],
      orElse: () => TypographyChoice.f1,
    );
    screen = widget.parameters['screen'] == 'expense' ? 'expense' : 'equipment';
    language = ['ar', 'en', 'ur'].contains(widget.parameters['locale'])
        ? widget.parameters['locale']!
        : 'ar';
    scale = (double.tryParse(widget.parameters['scale'] ?? '') ?? 1).clamp(
      1,
      2,
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Direction A · Typography preview',
    locale: Locale(language),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: choice.theme(locale: language, expense: screen == 'expense'),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: _PreviewTextScaler(MediaQuery.textScalerOf(context), scale),
      ),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(
            screen == 'expense'
                ? l10n(context).addExpense
                : l10n(context).equipment,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n(context).back,
            onPressed: () => setState(
              () => screen = screen == 'expense' ? 'equipment' : 'expense',
            ),
          ),
          actions: [
            IconButton(
              key: const Key('typographyControls'),
              tooltip: 'Font preview controls',
              onPressed: () => controls(context),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: Column(
          children: [
            // Developer caption, never product copy or a production font setting.
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF202B33),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'A / ${choice.name.toUpperCase()} · ${choice.labelFor(language)}\n${l10n(context).previewSynthetic} · assets loaded · ${choice == TypographyChoice.baseline ? '400/600 baseline' : '400/700'} · $language · ${scale}x',
                  style: const TextStyle(
                    fontFamily: 'ComparisonPlex',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: EquipmentCanvas(
                children: [
                  if (screen == 'equipment')
                    TypographyEquipment(
                      addExpense: () => setState(() => screen = 'expense'),
                    )
                  else
                    ExpensePreview(
                      key: expenseKey,
                      onCancel: () => setState(() => screen = 'equipment'),
                    ),
                  const SizedBox(height: EquipmentA.gap),
                  const TypographySpecimen(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> controls(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, localSetState) {
        void change(VoidCallback update) {
          setState(update);
          localSetState(() {});
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DIRECTION A · TYPOGRAPHY ONLY'),
                  const Text('Synthetic data · no API · no saves'),
                  for (final font in TypographyChoice.values)
                    ListTile(
                      key: Key('font-${font.name}'),
                      leading: Icon(
                        choice == font
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      title: Text('${font.name.toUpperCase()} · ${font.label}'),
                      subtitle: Text(
                        'ar/en: ${font.label} • ur: ${font.labelFor('ur')}',
                      ),
                      onTap: () => change(() => choice = font),
                    ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final page in ['equipment', 'expense'])
                        ChoiceChip(
                          label: Text(page),
                          selected: page == screen,
                          onSelected: (_) => change(() => screen = page),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final lang in ['ar', 'en', 'ur'])
                        ChoiceChip(
                          label: Text(lang),
                          selected: lang == language,
                          onSelected: (_) => change(() => language = lang),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final value in [1.0, 1.6])
                        ChoiceChip(
                          label: Text('Text ${value}x'),
                          selected: value == scale,
                          onSelected: (_) => change(() => scale = value),
                        ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Return to comparison'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
