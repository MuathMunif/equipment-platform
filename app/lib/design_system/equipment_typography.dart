import 'package:flutter/material.dart';

/// Owner-approved F3 for the production root and its app-controlled overlays.
/// Assets are registered with explicit 400/700 faces in pubspec.yaml.
abstract final class EquipmentTypography {
  static const family = 'EquipmentAlmarai';
  static const fallbackFamily = 'EquipmentPlex';
  static const bodyWeight = FontWeight.w400;
  static const emphasisWeight = FontWeight.w700;

  // Preserve the reviewed F3 mapping, sizes, heights and letter spacing.
  // All locales use Almarai; Plex covers unsupported characters only.
  static TextStyle _face(TextStyle? style) {
    final original = style ?? const TextStyle();
    return original.copyWith(
      fontFamily: family,
      fontFamilyFallback: const [fallbackFamily],
      fontWeight: (original.fontWeight ?? bodyWeight).value >= 500
          ? emphasisWeight
          : bodyWeight,
    );
  }

  static ThemeData apply(ThemeData base) {
    final t = base.textTheme;
    final text = TextTheme(
      displayLarge: _face(t.displayLarge),
      displayMedium: _face(t.displayMedium),
      displaySmall: _face(t.displaySmall),
      headlineLarge: _face(t.headlineLarge),
      headlineMedium: _face(t.headlineMedium),
      headlineSmall: _face(t.headlineSmall),
      titleLarge: _face(t.titleLarge),
      titleMedium: _face(t.titleMedium),
      titleSmall: _face(t.titleSmall),
      bodyLarge: _face(t.bodyLarge),
      bodyMedium: _face(t.bodyMedium),
      bodySmall: _face(t.bodySmall),
      labelLarge: _face(t.labelLarge),
      labelMedium: _face(t.labelMedium),
      labelSmall: _face(t.labelSmall),
    );
    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      appBarTheme: base.appBarTheme.copyWith(titleTextStyle: text.titleLarge),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        labelStyle: _face(base.inputDecorationTheme.labelStyle),
        floatingLabelStyle: _face(base.inputDecorationTheme.floatingLabelStyle),
        hintStyle: _face(base.inputDecorationTheme.hintStyle),
        errorStyle: _face(base.inputDecorationTheme.errorStyle),
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
        labelStyle: text.bodySmall?.copyWith(color: base.colorScheme.onSurface),
      ),
      tooltipTheme: base.tooltipTheme.copyWith(
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      ),
      popupMenuTheme: base.popupMenuTheme.copyWith(textStyle: text.bodyMedium),
      dropdownMenuTheme: base.dropdownMenuTheme.copyWith(
        textStyle: text.bodyMedium,
      ),
      datePickerTheme: base.datePickerTheme.copyWith(
        headerHeadlineStyle: text.headlineSmall,
        headerHelpStyle: text.bodySmall,
        weekdayStyle: text.bodySmall,
        dayStyle: text.bodyMedium,
        yearStyle: text.bodyMedium,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        labelTextStyle: WidgetStatePropertyAll(text.bodySmall),
      ),
      navigationRailTheme: base.navigationRailTheme.copyWith(
        selectedLabelTextStyle: text.labelLarge,
        unselectedLabelTextStyle: text.bodyMedium,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.bodyMedium,
      ),
    );
  }
}
