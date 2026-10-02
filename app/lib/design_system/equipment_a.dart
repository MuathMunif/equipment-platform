import 'package:flutter/material.dart';

import '../localization.dart';
import 'equipment_typography.dart';

/// Approved Direction A. Applied only inside EquipmentDetail, never at app root.
abstract final class EquipmentA {
  static const canvas = Color(0xFFF5F7F9);
  static const ink = Color(0xFF182F40);
  static const muted = Color(0xFF536674);
  static const accent = Color(0xFF1D4C65);
  static const tint = Color(0xFFEAF1F5);
  static const line = Color(0xFFDDE4E9);
  static const controlBorder = Color(0xFF7A8A93);
  static const gap = 24.0;
  static const radius = 12.0;
  static const family = EquipmentTypography.family;
  static const _referenceFamily = 'EquipmentNoto';

  static ThemeData theme() => EquipmentTypography.apply(referenceTheme());

  /// Original A styling basis, also preserved by the historical font comparison.
  /// Production screens must use [theme], which applies approved Almarai.
  static ThemeData referenceTheme() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: _referenceFamily,
      colorScheme: const ColorScheme.light(
        primary: accent,
        onPrimary: Colors.white,
        primaryContainer: tint,
        onPrimaryContainer: ink,
        secondary: ink,
        secondaryContainer: tint,
        onSecondaryContainer: ink,
        surface: Colors.white,
        onSurface: ink,
        onSurfaceVariant: muted,
        outline: line,
        error: Color(0xFFAC2E28),
      ),
    );
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );
    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 30,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        headlineSmall: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 24,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleLarge: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 20,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleMedium: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 16,
          height: 1.55,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyMedium: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 14,
          height: 1.6,
          color: ink,
        ),
        bodySmall: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 12,
          height: 1.6,
          color: muted,
        ),
        labelLarge: const TextStyle(
          fontFamily: _referenceFamily,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: line)),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          side: BorderSide(color: line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: line, space: 1),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
        iconColor: muted,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide(color: controlBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide(color: controlBorder),
        ),
        errorMaxLines: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: shape,
          side: const BorderSide(color: controlBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

class EquipmentCanvas extends StatelessWidget {
  final List<Widget> children;
  const EquipmentCanvas({super.key, required this.children});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class EquipmentColumns extends StatelessWidget {
  final Widget main, secondary;
  const EquipmentColumns({
    super.key,
    required this.main,
    required this.secondary,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < 900 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            main,
            const SizedBox(height: EquipmentA.gap),
            secondary,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: main),
          const SizedBox(width: EquipmentA.gap),
          Expanded(flex: 4, child: secondary),
        ],
      );
    },
  );
}

class EquipmentPanel extends StatelessWidget {
  final Widget child;
  const EquipmentPanel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

class EquipmentHeading extends StatelessWidget {
  final String title;
  final Widget? action;
  const EquipmentHeading(this.title, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        ?action,
      ],
    ),
  );
}

class EquipmentBadge extends StatelessWidget {
  final String text;
  const EquipmentBadge(this.text, {super.key});
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: EquipmentA.tint,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: EquipmentA.ink),
      ),
    ),
  );
}

class EquipmentIdentity extends StatelessWidget {
  final Map<String, dynamic> equipment;
  const EquipmentIdentity(this.equipment, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n(context).pilotEquipmentRecord,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 6),
      Semantics(
        header: true,
        child: Text(
          '${equipment['name']}',
          key: const Key('pilotEquipmentName'),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 14,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n(context).modelValue('${equipment['model']}')),
          Directionality(
            textDirection: TextDirection.ltr,
            child: EquipmentBadge('${equipment['reference']}'),
          ),
        ],
      ),
    ],
  );
}

class EquipmentLoading extends StatelessWidget {
  const EquipmentLoading({super.key});
  @override
  Widget build(BuildContext context) => const EquipmentPanel(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class EquipmentError extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const EquipmentError({super.key, required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => EquipmentPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cloud_off_outlined, color: EquipmentA.muted),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: retry,
          icon: const Icon(Icons.refresh),
          label: Text(l10n(context).retry),
        ),
      ],
    ),
  );
}

class EquipmentEmpty extends StatelessWidget {
  final String message;
  const EquipmentEmpty(this.message, {super.key});
  @override
  Widget build(BuildContext context) => EquipmentPanel(
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: EquipmentA.muted),
    ),
  );
}
