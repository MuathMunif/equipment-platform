import 'package:flutter/material.dart';

import 'design_system/equipment_a.dart';

/// Presentation helpers scoped to Home and the Equipment list. No theme changes.
class CompactSectionHeading extends StatelessWidget {
  final String title;
  final Widget action;
  const CompactSectionHeading(this.title, {super.key, required this.action});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final heading = Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
      if (box.maxWidth < 260 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, action],
        );
      }
      return Row(
        children: [
          Expanded(child: heading),
          action,
        ],
      );
    },
  );
}

class CompactEquipmentRow extends StatelessWidget {
  final String name, reference, model, actionLabel;
  final bool home;
  final VoidCallback onTap;
  const CompactEquipmentRow({
    super.key,
    required this.name,
    required this.reference,
    required this.model,
    required this.actionLabel,
    required this.home,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: actionLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EquipmentA.radius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: home ? 4 : 12,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: EquipmentA.tint,
                  borderRadius: BorderRadius.circular(EquipmentA.radius),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: EquipmentA.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: home ? text.titleMedium : text.titleLarge,
                    ),
                    Text(model, style: home ? text.bodySmall : text.bodyMedium),
                    // Direction only applies to the reference run, not its alignment.
                    Text(
                      reference,
                      textDirection: TextDirection.ltr,
                      style: home
                          ? text.bodySmall
                          : text.bodyMedium?.copyWith(color: EquipmentA.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
