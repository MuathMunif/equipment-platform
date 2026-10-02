import 'package:flutter/material.dart';

import '../localization.dart';
import 'equipment_typography.dart';

/// Approved Direction A, shared by production routes and app-controlled overlays.
abstract final class EquipmentA {
  static const canvas = Color(0xFFF5F7F9);
  static const ink = Color(0xFF182F40);
  static const muted = Color(0xFF536674);
  static const accent = Color(0xFF1D4C65);
  static const tint = Color(0xFFEAF1F5);
  static const line = Color(0xFFDDE4E9);
  static const controlBorder = Color(0xFF7A8A93);
  static const success = Color(0xFF29634B);
  static const warning = Color(0xFF855C18);
  static const danger = Color(0xFFAC2E28);
  static const gap = 24.0;
  static const radius = 12.0;
  static const family = EquipmentTypography.family;
  static const _referenceFamily = 'EquipmentNoto';

  static ThemeData theme() {
    final base = referenceTheme();
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      side: BorderSide(color: line),
    );
    return EquipmentTypography.apply(
      base.copyWith(
        appBarTheme: base.appBarTheme.copyWith(centerTitle: false),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: shape,
          constraints: BoxConstraints(minWidth: 280, maxWidth: 560),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          showDragHandle: true,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: shape,
        ),
        datePickerTheme: const DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: tint,
          headerForegroundColor: ink,
          shape: shape,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: ink,
          behavior: SnackBarBehavior.floating,
          actionTextColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: tint,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: tint,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          iconColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: tint,
          selectedColor: tint,
          side: BorderSide(color: line),
        ),
      ),
    );
  }

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

/// A bounded scroll canvas. Stable children stay mounted at every breakpoint.
class EquipmentPageBody extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  final bool alwaysScrollable;
  const EquipmentPageBody({
    super.key,
    required this.children,
    this.maxWidth = 1240,
    this.alwaysScrollable = false,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          physics: alwaysScrollable
              ? const AlwaysScrollableScrollPhysics()
              : null,
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 32,
          ),
          // Paginated pages are bounded. Keep form fields mounted so off-screen
          // validators and dropdown values survive scrolling and resizing.
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ],
        ),
      ),
    ),
  );
}

class EquipmentFormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const EquipmentFormSection({super.key, this.title, required this.children});
  @override
  Widget build(BuildContext context) => EquipmentPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [if (title != null) EquipmentHeading(title!), ...children],
    ),
  );
}

/// Same destinations/actions as Material's bar, with wrapping, unbounded labels.
/// Material NavigationDestination clamps text scaling, which hides 200% text.
class EquipmentNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  const EquipmentNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const Border(top: BorderSide(color: EquipmentA.line)),
    child: SafeArea(
      top: false,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: Semantics(
                  selected: selectedIndex == i,
                  button: true,
                  child: InkWell(
                    onTap: () => onDestinationSelected(i),
                    focusColor: EquipmentA.tint,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: selectedIndex == i
                                  ? EquipmentA.tint
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              child: IconTheme(
                                data: const IconThemeData(
                                  color: EquipmentA.accent,
                                  size: 24,
                                ),
                                child: destinations[i].icon,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destinations[i].label,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Wrap retains each field element/focus when switching from columns to rows.
class EquipmentFieldRow extends StatelessWidget {
  final Widget first, second;
  final Widget? action;
  final double breakpoint, firstFraction;
  const EquipmentFieldRow({
    super.key,
    required this.first,
    required this.second,
    this.action,
    this.breakpoint = 520,
    this.firstFraction = .5,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final stacked =
          box.maxWidth < breakpoint ||
          MediaQuery.textScalerOf(context).scale(14) > 21;
      final available = box.maxWidth - 12 - (action == null ? 0 : 60);
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: stacked ? box.maxWidth : available * firstFraction,
              child: first,
            ),
            SizedBox(
              width: stacked ? box.maxWidth : available * (1 - firstFraction),
              child: second,
            ),
            ?action,
          ],
        ),
      );
    },
  );
}

/// Bounded, wrapping report tiles; no fixed heights or reduced text scaling.
class EquipmentGrid extends StatelessWidget {
  final List<Widget> children;
  const EquipmentGrid({super.key, required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 21;
      final columns = largeText || box.maxWidth < 560
          ? 1
          : box.maxWidth < 900
          ? 2
          : 3;
      final width = (box.maxWidth - 12 * (columns - 1)) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class EquipmentValue extends StatelessWidget {
  final String label, value;
  const EquipmentValue({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final valueText = Text(
        value,
        style: Theme.of(context).textTheme.titleLarge,
      );
      if (box.maxWidth < 440 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return SizedBox(
          width: box.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(label), const SizedBox(height: 6), valueText],
          ),
        );
      }
      return Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 20),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: valueText,
            ),
          ),
        ],
      );
    },
  );
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
