import 'package:flutter/material.dart';

import '../design_preview/screens.dart' show PreviewBadge, showPreviewSheet;
import '../design_system/equipment_a.dart';
import '../localization.dart';

/// Fixed synthetic presentation of the production pilot; no Api, auth or writes.
class TypographyEquipment extends StatelessWidget {
  final VoidCallback addExpense;
  const TypographyEquipment({super.key, required this.addExpense});
  static const equipment = {
    'name': 'الشاحنة الأولى — Volvo FH16',
    'model': 'FH 460',
    'reference': 'EQ-004',
  };
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    void preview(String title) =>
        showPreviewSheet(context, title, loc.previewNoWrite);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EquipmentIdentity(equipment),
        const SizedBox(height: EquipmentA.gap),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: addExpense,
              icon: const Icon(Icons.add),
              label: Text(loc.addExpense),
            ),
            OutlinedButton.icon(
              onPressed: () => preview(loc.addIncome),
              icon: const Icon(Icons.add),
              label: Text(loc.addIncome),
            ),
            OutlinedButton.icon(
              onPressed: () => preview(loc.uiAwaitingCompletion),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(loc.uiSaveInvoiceNowAndCompleteDetailsLater),
            ),
            TextButton.icon(
              onPressed: () => preview(loc.uiAwaitingCompletion),
              icon: const Icon(Icons.pending_actions_outlined),
              label: Text(loc.uiAwaitingCompletion),
            ),
          ],
        ),
        const SizedBox(height: EquipmentA.gap),
        EquipmentColumns(
          main: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EquipmentPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.documents,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(loc.documentSummary('1', '0', '1', '0')),
                    const SizedBox(height: 8),
                    Text('${loc.docInsurance} • ${loc.docExpiringSoon}'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => preview(loc.documents),
                      icon: const Icon(Icons.description_outlined),
                      label: Text(loc.uiViewDocuments),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EquipmentA.gap),
              EquipmentPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.m4Hub,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(loc.previewIssueSample),
                    Text(
                      loc.m4Open,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${loc.m4Maintenance}: ${localizedDate(context, '2026-10-01')}',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final title in [
                          loc.m4ViewHistory,
                          loc.m4NewIssue,
                          loc.m4AddMaintenance,
                        ])
                          TextButton(
                            onPressed: () => preview(title),
                            child: Text(title),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: EquipmentA.gap),
              EquipmentPanel(
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    loc.pilotOptionalConnections,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    Text(loc.m6NoOrganization),
                    Text(loc.m6NoActiveProjects),
                  ],
                ),
              ),
            ],
          ),
          secondary: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EquipmentHeading(
                loc.uiEquipmentHistory,
                action: IconButton(
                  onPressed: () => preview(loc.uiEquipmentHistory),
                  tooltip: loc.uiRefreshRecords,
                  icon: const Icon(Icons.refresh),
                ),
              ),
              Text(loc.uiEachEntryItsPaymentsAndAttachmentsIn),
              const SizedBox(height: 12),
              EquipmentPanel(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: loc.searchLedger,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ExpansionTile(
                  title: Text(loc.uiFilterRecords),
                  children: [Text(loc.uiAll)],
                ),
              ),
              const SizedBox(height: 12),
              for (final row in [
                (loc.income, '4500.00', loc.receivedPartial),
                (loc.categoryMaintenance, '1850.00', loc.paidFull),
              ]) ...[
                EquipmentPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${row.$1} • ${equipment['name']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizedDate(context, '2026-10-01'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        row.$3,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizedMoney(context, row.$2),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Clearly separated specimen, identical for every option. Values are formatted
/// by the same exact-money/date helpers; these are not new business fields.
class TypographySpecimen extends StatelessWidget {
  const TypographySpecimen({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return EquipmentPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FONT SPECIMEN · SYNTHETIC',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'الشَّاحِنَةُ الأولى لنقل المعدّات الثقيلة — Volvo FH16 / EQ-004',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'بِسْمِ اللَّهِ · اختبار اتصال الحروف والنقاط والمسافات',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'ٹ ڈ ڑ ں ھ ہ ے پ چ ژ گ — گاڑی کی دیکھ بھال',
            key: const Key('urduGlyphSpecimen'),
            style: Theme.of(context).textTheme.bodyMedium,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              for (final amount in ['0.00', '1234.50', '-125.25'])
                Text(
                  localizedMoney(context, amount),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${localizedDate(context, '2026-10-01')} · 0123456789 · ٠١٢٣٤٥٦٧٨٩',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          PreviewBadge(loc.documentExpiryInDays('14'), warning: true),
          const SizedBox(height: 12),
          Text(
            loc.uiAttachmentUploadFailed,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }
}
