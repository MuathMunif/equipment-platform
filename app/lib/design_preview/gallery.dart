import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../localization.dart';
import 'fixtures.dart';
import 'screens.dart';
import 'tokens.dart';

enum PreviewScreen { home, equipment, expense, states }

class DesignPreviewApp extends StatefulWidget {
  final Map<String, String> parameters;
  const DesignPreviewApp({super.key, this.parameters = const {}});
  @override
  State<DesignPreviewApp> createState() => _DesignPreviewAppState();
}

class _DesignPreviewAppState extends State<DesignPreviewApp> {
  late DesignDirection direction;
  late PreviewScreen screen;
  late String language;
  late double scale;
  double? frameWidth;
  int revision = 0;
  final expenseKey = GlobalKey<ExpensePreviewState>();

  @override
  void initState() {
    super.initState();
    direction = DesignDirection.values.firstWhere(
      (v) => v.name == widget.parameters['direction'],
      orElse: () => DesignDirection.a,
    );
    screen = PreviewScreen.values.firstWhere(
      (v) => v.name == widget.parameters['screen'],
      orElse: () => PreviewScreen.home,
    );
    language = supportedLanguageCodes.contains(widget.parameters['locale'])
        ? widget.parameters['locale']!
        : 'ar';
    scale = (double.tryParse(widget.parameters['scale'] ?? '') ?? 1).clamp(
      1,
      2,
    );
  }

  void navigate(PreviewScreen target) => setState(() {
    screen = target;
    revision++;
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Equipment • Design laboratory',
    theme: DesignTokens.forDirection(direction).theme(urdu: language == 'ur'),
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Developer controls are intentionally separate from localized product UI.
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  color: const Color(0xFF202B33),
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'UI LAB / ${direction.name.toUpperCase()}  ·  ${l10n(context).previewSynthetic}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.5,
                            fontFamily: 'PreviewNoto',
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('galleryControls'),
                        tooltip: 'Preview controls',
                        onPressed: () => controls(context),
                        icon: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: frameWidth ?? double.infinity,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final desktop = constraints.maxWidth >= 1000;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (desktop) _sidebar(context),
                            Expanded(
                              child: Column(
                                children: [
                                  _workspaceBar(context, desktop),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      key: ValueKey('$screen-$revision'),
                                      padding: EdgeInsets.all(
                                        desktop ? 36 : 20,
                                      ),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 1160,
                                          ),
                                          child: switch (screen) {
                                            PreviewScreen.home => OwnerPreview(
                                              onNavigate: navigate,
                                            ),
                                            PreviewScreen.equipment =>
                                              EquipmentPreview(
                                                onNavigate: navigate,
                                              ),
                                            PreviewScreen.expense =>
                                              ExpensePreview(
                                                key: expenseKey,
                                                onCancel: () => navigate(
                                                  PreviewScreen.equipment,
                                                ),
                                              ),
                                            PreviewScreen.states =>
                                              const StatePreview(),
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!desktop &&
                                      screen != PreviewScreen.expense)
                                    _mobileNav(context),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _workspaceBar(BuildContext context, bool desktop) {
    final t = tokens(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 36 : 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          if (screen == PreviewScreen.expense)
            IconButton(
              tooltip: l10n(context).back,
              onPressed: () async {
                // Dispatch through the form's cancel button so entered data is guarded.
                expenseKey.currentState?.confirmCancel();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.tint,
              borderRadius: BorderRadius.circular(t.radius / 2),
            ),
            child: Icon(
              Icons.space_dashboard_outlined,
              color: t.accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n(context).uiWorkspace,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Text(
                  PreviewFixtures.workspace,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n(context).notifications,
            onPressed: () => showPreviewSheet(
              context,
              l10n(context).notifications,
              '${l10n(context).notificationDocumentExpiryTitle}\n${l10n(context).docInsurance} · ${PreviewFixtures.equipment}\n${l10n(context).previewDocumentDate}',
            ),
            icon: Icon(Icons.notifications_none_rounded, color: t.ink),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context) {
    final t = tokens(context);
    final loc = l10n(context);
    return Container(
      width: direction == DesignDirection.b ? 216 : 238,
      decoration: BoxDecoration(
        color: direction == DesignDirection.c
            ? const Color(0xFFF0EDDF)
            : Colors.white,
        border: BorderDirectional(end: BorderSide(color: t.line)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.view_in_ar_outlined, size: 32, color: t.accent),
          const SizedBox(height: 12),
          Text(
            loc.equipment,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 42),
          _navItem(
            context,
            loc.home,
            Icons.grid_view_rounded,
            PreviewScreen.home,
          ),
          const SizedBox(height: 8),
          _navItem(
            context,
            loc.equipment,
            Icons.local_shipping_outlined,
            PreviewScreen.equipment,
          ),
          const SizedBox(height: 8),
          _navItem(
            context,
            loc.previewStates,
            Icons.layers_outlined,
            PreviewScreen.states,
          ),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            loc.previewSynthetic,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            loc.previewFixtureNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String title,
    IconData icon,
    PreviewScreen target,
  ) {
    final t = tokens(context);
    final selected = screen == target;
    return Material(
      color: selected ? t.tint : Colors.transparent,
      borderRadius: BorderRadius.circular(t.radius),
      child: InkWell(
        onTap: () => navigate(target),
        borderRadius: BorderRadius.circular(t.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 21, color: selected ? t.accent : t.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileNav(BuildContext context) {
    final loc = l10n(context);
    final t = tokens(context);
    final items = [
      (loc.home, Icons.grid_view_rounded, PreviewScreen.home),
      (loc.equipment, Icons.local_shipping_outlined, PreviewScreen.equipment),
      (loc.previewStates, Icons.layers_outlined, PreviewScreen.states),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Semantics(
                selected: screen == item.$3,
                child: InkWell(
                  onTap: () => navigate(item.$3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.$2,
                          color: screen == item.$3 ? t.accent : t.muted,
                          size: 23,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: t.ink,
                            fontWeight: screen == item.$3
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> controls(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, localSetState) {
          void change(VoidCallback update) {
            setState(update);
            localSetState(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'DEVELOPER GALLERY',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Synthetic fixtures • no API • no persistence'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final d in DesignDirection.values)
                          ChoiceChip(
                            label: Text(
                              '${d.name.toUpperCase()} / ${['Clear', 'Industrial', 'Warm'][d.index]}',
                            ),
                            selected: d == direction,
                            onSelected: (_) => change(() => direction = d),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in PreviewScreen.values)
                          ChoiceChip(
                            label: Text(s.name),
                            selected: s == screen,
                            onSelected: (_) => change(() {
                              screen = s;
                              revision++;
                            }),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final lang in ['ar', 'en', 'ur'])
                          ChoiceChip(
                            label: Text(lang),
                            selected: language == lang,
                            onSelected: (_) => change(() => language = lang),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final width in [null, 320.0, 390.0, 1440.0])
                          ChoiceChip(
                            label: Text(
                              width == null
                                  ? 'Fit viewport'
                                  : '${width.toInt()} px',
                            ),
                            selected: frameWidth == width,
                            onSelected: (_) => change(() => frameWidth = width),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final value in [1.0, 1.3, 1.6, 2.0])
                          ChoiceChip(
                            label: Text('Text ${value}x'),
                            selected: scale == value,
                            onSelected: (_) => change(() => scale = value),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Return to preview'),
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
}
