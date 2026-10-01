import 'package:flutter/material.dart';

import '../localization.dart';
import '../api.dart' show exactMoney;
import 'fixtures.dart';
import 'gallery.dart';
import 'tokens.dart';

Future<void> showPreviewSheet(
  BuildContext context,
  String title,
  String body,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(body),
          const SizedBox(height: 24),
          Text(
            l10n(context).previewSynthetic,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n(context).back),
          ),
        ],
      ),
    ),
  ),
);

class PreviewSurface extends StatelessWidget {
  final Widget child;
  final bool tinted;
  final EdgeInsetsGeometry? padding;
  const PreviewSurface({
    super.key,
    required this.child,
    this.tinted = false,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    final t = tokens(context);
    return Container(
      decoration: BoxDecoration(
        color: tinted ? t.tint : Colors.white,
        borderRadius: BorderRadius.circular(t.radius),
        border: Border.all(
          color: t.direction == DesignDirection.c && tinted ? t.tint : t.line,
        ),
      ),
      padding:
          padding ?? EdgeInsets.all(t.direction == DesignDirection.b ? 18 : 20),
      child: child,
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title, number;
  final Widget? action;
  const SectionHeading(this.title, {super.key, this.number = '', this.action});
  @override
  Widget build(BuildContext context) {
    final t = tokens(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (t.direction == DesignDirection.b && number.isNotEmpty) ...[
            Text(
              number,
              style: TextStyle(
                color: t.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?action,
        ],
      ),
    );
  }
}

class PreviewBadge extends StatelessWidget {
  final String label;
  final bool warning;
  const PreviewBadge(this.label, {super.key, this.warning = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: warning ? const Color(0xFFFBF0DD) : tokens(context).tint,
      borderRadius: BorderRadius.circular(tokens(context).radius / 2),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: warning ? const Color(0xFF795019) : tokens(context).ink,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class PreviewRow extends StatelessWidget {
  final String title;
  final String? subtitle, amount;
  final IconData icon;
  final VoidCallback? onTap;
  const PreviewRow({
    super.key,
    required this.title,
    this.subtitle,
    this.amount,
    required this.icon,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final t = tokens(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.tint,
              borderRadius: BorderRadius.circular(t.radius / 2),
            ),
            child: Icon(icon, size: 20, color: t.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: 14),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                if (amount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      localizedMoney(context, amount),
                      style: TextStyle(
                        color: t.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, top: 8),
              child: Icon(
                Icons.chevron_right,
                textDirection: Directionality.of(context),
                size: 20,
                color: t.muted,
              ),
            ),
        ],
      ),
    );
    return onTap == null ? content : InkWell(onTap: onTap, child: content);
  }
}

class AdaptiveColumns extends StatelessWidget {
  final Widget main, secondary;
  final double breakpoint;
  const AdaptiveColumns({
    super.key,
    required this.main,
    required this.secondary,
    this.breakpoint = 780,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        constraints.maxWidth >= breakpoint &&
            MediaQuery.textScalerOf(context).scale(1) < 1.5
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: main),
              SizedBox(width: tokens(context).gap),
              Expanded(flex: 4, child: secondary),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              main,
              SizedBox(height: tokens(context).gap),
              secondary,
            ],
          ),
  );
}

class OwnerPreview extends StatelessWidget {
  final ValueChanged<PreviewScreen> onNavigate;
  const OwnerPreview({super.key, required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final t = tokens(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.previewOverview,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          loc.previewAttentionHelp,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: t.muted),
        ),
        SizedBox(height: t.gap),
        AdaptiveColumns(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(loc.previewAttention, number: '01'),
              PreviewSurface(
                tinted: t.direction == DesignDirection.c,
                child: Column(
                  children: [
                    PreviewRow(
                      title: loc.docInsurance,
                      subtitle:
                          '${PreviewFixtures.equipment}\n${loc.previewDocumentDate}',
                      icon: Icons.description_outlined,
                      onTap: () => showPreviewSheet(
                        context,
                        loc.docInsurance,
                        '${loc.documentExpiryInDays('14')}\n${loc.previewDocumentDate}',
                      ),
                    ),
                    const Divider(),
                    PreviewRow(
                      title: loc.previewIssueSample,
                      subtitle: '${PreviewFixtures.equipment} · ${loc.m4Open}',
                      icon: Icons.build_outlined,
                      onTap: () => showPreviewSheet(
                        context,
                        loc.m4Issues,
                        loc.previewIssueSample,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.gap),
              SectionHeading(
                loc.m7Recorded,
                number: '02',
                action: PreviewBadge(loc.previewPeriod),
              ),
              Text(
                loc.m7EntryDateBasis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, box) {
                  final stack =
                      box.maxWidth < 340 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.2;
                  final cards = [
                    financeCard(
                      context,
                      loc.previewRecordedExpenses,
                      PreviewFixtures.recordedExpenses,
                      Icons.north_east,
                      false,
                    ),
                    financeCard(
                      context,
                      loc.previewRecordedIncome,
                      PreviewFixtures.recordedIncome,
                      Icons.south_west,
                      true,
                    ),
                  ];
                  return stack
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            cards[0],
                            const SizedBox(height: 12),
                            cards[1],
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 12),
                            Expanded(child: cards[1]),
                          ],
                        );
                },
              ),
              SizedBox(height: t.gap),
              SectionHeading(loc.m7RecentEntries, number: '03'),
              PreviewSurface(child: RecentRecords(onNavigate: onNavigate)),
            ],
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(
                loc.equipment,
                action: TextButton(
                  onPressed: () => onNavigate(PreviewScreen.equipment),
                  child: Text(loc.previewViewAll),
                ),
              ),
              PreviewSurface(
                tinted: t.direction == DesignDirection.c,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 40,
                      color: t.accent,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      PreviewFixtures.equipment,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text(
                      PreviewFixtures.model,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      PreviewFixtures.reference,
                      style: Theme.of(context).textTheme.bodySmall,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => onNavigate(PreviewScreen.equipment),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(loc.previewViewEquipment),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.previewEquipmentHelp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget financeCard(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    bool income,
  ) {
    final t = tokens(context);
    return PreviewSurface(
      tinted: income,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.accent, size: 20),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: t.ink),
          ),
          const SizedBox(height: 10),
          Text(
            localizedMoney(context, amount).replaceFirst(
              ' ${l10n(context).sarUnit}',
              '\n${l10n(context).sarUnit}',
            ),
            style: TextStyle(
              fontSize: t.direction == DesignDirection.b ? 23 : 21,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class RecentRecords extends StatelessWidget {
  final ValueChanged<PreviewScreen> onNavigate;
  const RecentRecords({super.key, required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return Column(
      children: [
        PreviewRow(
          title: loc.previewMaintenanceSample,
          subtitle:
              '${loc.expense} · ${localizedDate(context, PreviewFixtures.date)}',
          amount: '1000.00',
          icon: Icons.receipt_long_outlined,
          onTap: () => onNavigate(PreviewScreen.states),
        ),
        const Divider(),
        PreviewRow(
          title: loc.categoryFuel,
          subtitle:
              '${loc.expense} · ${localizedDate(context, PreviewFixtures.date)}',
          amount: '420.00',
          icon: Icons.local_gas_station_outlined,
          onTap: () => showPreviewSheet(
            context,
            loc.categoryFuel,
            localizedMoney(context, '420.00'),
          ),
        ),
        const Divider(),
        PreviewRow(
          title: loc.previewIncomeSample,
          subtitle:
              '${loc.income} · ${localizedDate(context, PreviewFixtures.date)}',
          amount: '3200.00',
          icon: Icons.south_west,
          onTap: () => showPreviewSheet(
            context,
            loc.uiIncomeDetails,
            localizedMoney(context, '3200.00'),
          ),
        ),
      ],
    );
  }
}

class EquipmentPreview extends StatelessWidget {
  final ValueChanged<PreviewScreen> onNavigate;
  const EquipmentPreview({super.key, required this.onNavigate});
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final t = tokens(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.previewEquipmentRecords,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Text(
          PreviewFixtures.equipment,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(PreviewFixtures.model, textDirection: TextDirection.ltr),
            const PreviewBadge(PreviewFixtures.reference),
          ],
        ),
        SizedBox(height: t.gap),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              key: const Key('previewAddExpense'),
              onPressed: () => onNavigate(PreviewScreen.expense),
              icon: const Icon(Icons.add),
              label: Text(loc.addExpense),
            ),
            OutlinedButton.icon(
              onPressed: () => showPreviewSheet(
                context,
                loc.addIncome,
                loc.previewOnlyAction,
              ),
              icon: const Icon(Icons.add),
              label: Text(loc.addIncome),
            ),
          ],
        ),
        SizedBox(height: t.gap),
        AdaptiveColumns(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(loc.documents, number: '01'),
              PreviewSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PreviewRow(
                      title: loc.docInsurance,
                      subtitle: loc.previewDocumentDate,
                      icon: Icons.description_outlined,
                      onTap: () => showPreviewSheet(
                        context,
                        loc.docInsurance,
                        '${loc.documentExpiryInDays('14')}\n${loc.previewDocumentDate}',
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PreviewBadge(
                        loc.documentExpiryInDays('14'),
                        warning: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(),
                    PreviewRow(
                      title: loc.docRegistration,
                      subtitle: loc.docMissingExpiry,
                      icon: Icons.article_outlined,
                      onTap: () => showPreviewSheet(
                        context,
                        loc.docRegistration,
                        loc.docMissingExpiry,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.gap),
              SectionHeading(loc.m4Issues, number: '02'),
              PreviewSurface(
                child: PreviewRow(
                  title: loc.previewIssueSample,
                  subtitle: loc.m4Open,
                  icon: Icons.build_outlined,
                  onTap: () => showPreviewSheet(
                    context,
                    loc.m4IssueDetails,
                    loc.previewIssueSample,
                  ),
                ),
              ),
              SizedBox(height: t.gap),
              SectionHeading(loc.m4Maintenance, number: '03'),
              PreviewSurface(
                child: PreviewRow(
                  title: loc.previewMaintenanceSample,
                  subtitle: localizedDate(context, PreviewFixtures.date),
                  icon: Icons.handyman_outlined,
                  onTap: () => showPreviewSheet(
                    context,
                    loc.m4MaintenanceDetails,
                    loc.previewMaintenanceSample,
                  ),
                ),
              ),
            ],
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(loc.m7RecentEntries),
              PreviewSurface(
                tinted: t.direction == DesignDirection.c,
                child: PreviewRow(
                  title: loc.previewMaintenanceSample,
                  subtitle: localizedDate(context, PreviewFixtures.date),
                  amount: PreviewFixtures.total,
                  icon: Icons.receipt_long_outlined,
                  onTap: () => onNavigate(PreviewScreen.states),
                ),
              ),
              SizedBox(height: t.gap),
              PreviewSurface(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 12),
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    loc.previewRelatedContext,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    for (final label in [
                      loc.m5Driver,
                      loc.m6OrganizationOptional,
                      loc.m6ProjectsContracts,
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(label)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.previewNoConnection,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExpensePreview extends StatefulWidget {
  final VoidCallback onCancel;
  const ExpensePreview({super.key, required this.onCancel});
  @override
  State<ExpensePreview> createState() => ExpensePreviewState();
}

class ExpensePreviewState extends State<ExpensePreview> {
  final form = GlobalKey<FormState>();
  final amount = TextEditingController(text: '350.00');
  final initialPaid = TextEditingController(),
      party = TextEditingController(),
      note = TextEditingController();
  final firstAllocation = TextEditingController(),
      secondAllocation = TextEditingController();
  String payment = 'FULL', scope = 'SINGLE', category = 'FUEL';
  String operationDate = PreviewFixtures.date, paidDate = PreviewFixtures.date;
  String? dueDate;
  bool dirty = false, project = false;
  @override
  void dispose() {
    for (final c in [
      amount,
      initialPaid,
      party,
      note,
      firstAllocation,
      secondAllocation,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> confirmCancel() async {
    if (dirty) {
      final loc = l10n(context);
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.previewDiscardTitle),
          content: Text(loc.previewDiscardHelp),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(loc.previewKeepEditing),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(loc.previewLeave),
            ),
          ],
        ),
      );
      if (leave != true || !mounted) return;
    }
    widget.onCancel();
  }

  Future<void> datePicker(String type) async {
    final current = type == 'operation'
        ? operationDate
        : type == 'paid'
        ? paidDate
        : dueDate;
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(current ?? PreviewFixtures.date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value == null || !mounted) return;
    // Retain date-only semantics, without UTC conversion.
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    setState(() {
      dirty = true;
      if (type == 'operation') {
        operationDate = date;
      } else if (type == 'paid') {
        paidDate = date;
      } else {
        dueDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final t = tokens(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 780 ||
            MediaQuery.textScalerOf(context).scale(1) >= 1.5;
        return Form(
          key: form,
          onChanged: () => dirty = true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.addExpense,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                loc.previewFormHint,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: t.muted),
              ),
              SizedBox(height: t.gap),
              if (compact) ...[
                equipmentContext(context, compact: true),
                SizedBox(height: t.gap),
              ],
              AdaptiveColumns(
                main: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PreviewSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeading(loc.previewCategoryDate, number: '01'),
                          TextFormField(
                            key: const Key('previewAmount'),
                            controller: amount,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: t.ink,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: loc.uiAmountSar,
                            ),
                            validator: (v) => exactMoney(v ?? '') == null
                                ? loc.uiEnterAnAmountAboveZeroUpTo
                                : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            key: const Key('previewCategory'),
                            initialValue: category,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: loc.uiExpenseType,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'FUEL',
                                child: Text(loc.categoryFuel),
                              ),
                              DropdownMenuItem(
                                value: 'MAINTENANCE',
                                child: Text(loc.categoryMaintenance),
                              ),
                              DropdownMenuItem(
                                value: 'OTHER',
                                child: Text(loc.other),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              category = v!;
                              dirty = true;
                            }),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () => datePicker('operation'),
                            icon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 19,
                            ),
                            label: Text(
                              loc.operationDate(
                                localizedDate(context, operationDate),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: t.gap),
                    PreviewSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeading(
                            loc.previewPaymentSection,
                            number: '02',
                          ),
                          Text(
                            loc.uiPaymentStatus,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              for (final item in [
                                ('FULL', loc.uiPaidInFull),
                                ('PARTIAL', loc.uiPaidPartOfIt),
                                ('UNPAID', loc.uiNotPaid),
                              ])
                                ChoiceChip(
                                  key: Key('payment-${item.$1}'),
                                  label: Text(item.$2),
                                  selected: payment == item.$1,
                                  onSelected: (_) => setState(() {
                                    payment = item.$1;
                                    dirty = true;
                                  }),
                                ),
                            ],
                          ),
                          if (payment == 'PARTIAL') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('previewInitialPaid'),
                              controller: initialPaid,
                              textDirection: TextDirection.ltr,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: loc.uiInitialPayment,
                              ),
                              validator: (v) {
                                final first = cents(v ?? ''),
                                    total = cents(amount.text);
                                return first == null ||
                                        total == null ||
                                        first >= total
                                    ? loc.uiEnterAnAmountAboveZeroAndBelow
                                    : null;
                              },
                            ),
                          ],
                          if (payment != 'UNPAID') ...[
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => datePicker('paid'),
                              icon: const Icon(
                                Icons.event_available_outlined,
                                size: 19,
                              ),
                              label: Text(
                                loc.paymentDate(
                                  localizedDate(context, paidDate),
                                ),
                              ),
                            ),
                          ],
                          if (payment != 'FULL') ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const Key('previewParty'),
                              controller: party,
                              decoration: InputDecoration(
                                labelText: loc.uiNameOfThePartyOwed,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? loc.uiEnterPartyName
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () => datePicker('due'),
                              icon: const Icon(Icons.event_outlined, size: 19),
                              label: Text(
                                dueDate == null
                                    ? loc.uiDueDateOptional
                                    : loc.dueDateValue(
                                        localizedDate(context, dueDate),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: t.gap),
                    if (compact) ...[
                      ExpansionTile(
                        key: const Key('compactAttachment'),
                        tilePadding: EdgeInsets.zero,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        leading: const Icon(Icons.attach_file_outlined),
                        title: Text(
                          loc.previewInvoice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          loc.attachmentAfterSave(loc.expense),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        children: const [AttachmentPreview()],
                      ),
                      SizedBox(height: t.gap),
                    ],
                    ExpansionTile(
                      key: const Key('previewOptional'),
                      tilePadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: Text(
                        loc.m6AdditionalDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        loc.previewScopeHelp,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      children: [
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: const Key('previewScope'),
                          initialValue: scope,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: loc.uiExpenseAppliesTo276,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'SINGLE',
                              child: Text(loc.uiOneEquipment),
                            ),
                            DropdownMenuItem(
                              value: 'SHARED',
                              child: Text(loc.uiMultipleEquipment),
                            ),
                            DropdownMenuItem(
                              value: 'GENERAL',
                              child: Text(loc.generalExpense),
                            ),
                          ],
                          onChanged: (v) => setState(() {
                            scope = v!;
                            dirty = true;
                          }),
                        ),
                        if (scope == 'SHARED') ...[
                          const SizedBox(height: 12),
                          Text(
                            loc.uiSelectDifferentEquipmentAndMakeTheirAmounts,
                          ),
                          for (final item in [
                            (PreviewFixtures.equipment, firstAllocation),
                            (PreviewFixtures.secondEquipment, secondAllocation),
                          ])
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: TextFormField(
                                controller: item.$2,
                                textDirection: TextDirection.ltr,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(labelText: item.$1),
                                validator: (v) {
                                  final a = cents(firstAllocation.text),
                                      b = cents(secondAllocation.text),
                                      total = cents(amount.text);
                                  return a == null ||
                                          b == null ||
                                          total == null ||
                                          a + b != total
                                      ? loc.uiAdjustEachEquipmentAmountToMatchThe
                                      : null;
                                },
                              ),
                            ),
                        ],
                        if (scope == 'GENERAL')
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(loc.uiAWorkspaceExpenseItIsNotAssigned),
                          ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<bool>(
                          initialValue: project,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: loc.m6ProjectClassification,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: false,
                              child: Text(loc.previewNoConnection),
                            ),
                            const DropdownMenuItem(
                              value: true,
                              child: Text('مشروع النقل التجريبي'),
                            ),
                          ],
                          onChanged: (v) => setState(() {
                            project = v!;
                            dirty = true;
                          }),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: note,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: loc.uiNoteOptional,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    SizedBox(height: t.gap),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          key: const Key('previewSave'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (form.currentState!.validate()) {
                              showPreviewSheet(
                                context,
                                loc.previewTrySave,
                                loc.previewNoWrite,
                              );
                            }
                          },
                          icon: const Icon(Icons.check, size: 19),
                          label: Text(loc.previewTrySave),
                        ),
                        OutlinedButton(
                          key: const Key('previewCancel'),
                          onPressed: confirmCancel,
                          child: Text(loc.cancel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.previewSynthetic,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                secondary: compact
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          equipmentContext(context),
                          SizedBox(height: t.gap),
                          const AttachmentPreview(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget equipmentContext(BuildContext context, {bool compact = false}) {
    final loc = l10n(context);
    if (compact) {
      return PreviewSurface(
        tinted: true,
        padding: const EdgeInsets.all(14),
        child: Semantics(
          label: loc.previewCurrentEquipment,
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 24,
                color: tokens(context).accent,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scope == 'GENERAL'
                          ? loc.generalExpense
                          : PreviewFixtures.equipment,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (scope != 'GENERAL')
                      Wrap(
                        spacing: 12,
                        children: [
                          Text(
                            PreviewFixtures.model,
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            PreviewFixtures.reference,
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    if (scope == 'SHARED')
                      const Text(PreviewFixtures.secondEquipment),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return PreviewSurface(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.previewCurrentEquipment,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          if (scope == 'GENERAL')
            Text(
              loc.generalExpense,
              style: Theme.of(context).textTheme.titleLarge,
            )
          else ...[
            Text(
              PreviewFixtures.equipment,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(PreviewFixtures.model, textDirection: TextDirection.ltr),
            const SizedBox(height: 8),
            const PreviewBadge(PreviewFixtures.reference),
            if (scope == 'SHARED')
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(PreviewFixtures.secondEquipment),
              ),
          ],
        ],
      ),
    );
  }
}

BigInt? cents(String input) {
  final normalized = exactMoney(input);
  return normalized == null
      ? null
      : BigInt.parse(normalized.replaceAll('.', ''));
}

class AttachmentPreview extends StatefulWidget {
  const AttachmentPreview({super.key});
  @override
  State<AttachmentPreview> createState() => _AttachmentPreviewState();
}

class _AttachmentPreviewState extends State<AttachmentPreview> {
  bool attached = false, failed = false;
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return PreviewSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.attach_file_rounded,
            size: 28,
            color: tokens(context).accent,
          ),
          const SizedBox(height: 16),
          Text(
            loc.previewInvoice,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.previewAttachmentHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (!attached && !failed)
            OutlinedButton.icon(
              key: const Key('tryAttachment'),
              onPressed: () => setState(() => attached = true),
              icon: const Icon(Icons.add, size: 18),
              label: Text(loc.previewTryAttachment),
            ),
          if (attached) ...[
            OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(loc.previewSynthetic),
                  content: Image.asset(
                    'integration_test/fixtures/synthetic-receipt.png',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.closeAttachment),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.image_outlined),
              label: const Text('synthetic-receipt.png'),
            ),
            TextButton(
              onPressed: () => setState(() => attached = false),
              child: Text(loc.previewRemoveAttachment),
            ),
          ],
          if (failed) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                loc.uiAttachmentUploadFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              key: const Key('retryAttachment'),
              onPressed: () => setState(() {
                failed = false;
                attached = true;
              }),
              child: Text(loc.retry),
            ),
          ],
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextButton(
              key: const Key('failAttachment'),
              onPressed: () => setState(() {
                failed = true;
                attached = false;
              }),
              child: const Text(
                'LAB · simulate upload error',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatePreview extends StatefulWidget {
  const StatePreview({super.key});
  @override
  State<StatePreview> createState() => _StatePreviewState();
}

class _StatePreviewState extends State<StatePreview> {
  String state = 'ready';
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final t = tokens(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.previewStates,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Wrap(
            spacing: 8,
            children: [
              for (final value in [
                'ready',
                'empty',
                'loading',
                'error',
                'denied',
              ])
                ChoiceChip(
                  key: Key('state-$value'),
                  label: Text(value),
                  selected: state == value,
                  onSelected: (_) => setState(() => state = value),
                ),
            ],
          ),
        ),
        SizedBox(height: t.gap),
        AdaptiveColumns(
          main: PreviewSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeading(loc.uiExpenseDetails),
                if (state == 'ready') ...[
                  Text(
                    loc.previewMaintenanceSample,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(PreviewFixtures.equipment),
                  const SizedBox(height: 16),
                  Text(
                    loc.previewLifetime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  for (final item in [
                    (loc.m7OriginalTotal, PreviewFixtures.total),
                    (loc.uiTotalPaid, PreviewFixtures.paid),
                    (loc.uiRefundedBySupplier, PreviewFixtures.refunded),
                    (loc.uiNetPaid, PreviewFixtures.net),
                    (loc.uiBalanceYouOwe, PreviewFixtures.remaining),
                  ]) ...[
                    MoneyPreviewRow(item.$1, item.$2),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PreviewBadge(loc.uiPaidPartOfIt),
                  ),
                ] else if (state == 'loading') ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(loc.previewLoading),
                ] else if (state == 'empty') ...[
                  Icon(Icons.inbox_outlined, size: 40, color: t.muted),
                  const SizedBox(height: 16),
                  Text(loc.noEntries),
                ] else ...[
                  Icon(
                    state == 'denied'
                        ? Icons.lock_outline
                        : Icons.cloud_off_outlined,
                    size: 40,
                    color: t.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(state == 'denied' ? loc.accessDenied : loc.m7LoadFailed),
                  Text(
                    loc.previewNotAvailable,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (state == 'error')
                    TextButton(
                      key: const Key('retryState'),
                      onPressed: () => setState(() => state = 'ready'),
                      child: Text(loc.retry),
                    ),
                ],
              ],
            ),
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PreviewSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeading(loc.documents),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        PreviewBadge(
                          loc.documentExpiryInDays('14'),
                          warning: true,
                        ),
                        PreviewBadge(loc.docExpired, warning: true),
                        PreviewBadge(loc.docMissingExpiry),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      initialValue: '0',
                      decoration: InputDecoration(
                        labelText: loc.uiAmountSar,
                        errorText: loc.uiEnterAValidAmount,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: null,
                      child: Text(loc.previewTrySave),
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.gap),
              const AttachmentPreview(),
            ],
          ),
        ),
      ],
    );
  }
}

class MoneyPreviewRow extends StatelessWidget {
  final String label, value;
  const MoneyPreviewRow(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final amount = Text(
        localizedMoney(context, value),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );
      return box.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.2
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(label), const SizedBox(height: 6), amount],
            )
          : Row(
              children: [
                Expanded(child: Text(label)),
                const SizedBox(width: 16),
                amount,
              ],
            );
    },
  );
}
