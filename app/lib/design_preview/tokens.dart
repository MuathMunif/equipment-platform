import 'package:flutter/material.dart';

enum DesignDirection { a, b, c }

/// Experimental presentation only. No production theme imports this file.
@immutable
class DesignTokens extends ThemeExtension<DesignTokens> {
  final DesignDirection direction;
  final Color canvas, ink, muted, line, accent, tint;
  final double radius, gap;
  final String family, headingFamily;
  const DesignTokens({
    required this.direction,
    required this.canvas,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.tint,
    required this.radius,
    required this.gap,
    required this.family,
    required this.headingFamily,
  });

  static DesignTokens forDirection(DesignDirection d) => switch (d) {
    DesignDirection.a => const DesignTokens(
      direction: DesignDirection.a,
      canvas: Color(0xFFF5F7F9),
      ink: Color(0xFF182F40),
      muted: Color(0xFF536674),
      line: Color(0xFFDDE4E9),
      accent: Color(0xFF1D4C65),
      tint: Color(0xFFEAF1F5),
      radius: 12,
      gap: 24,
      family: 'PreviewNoto',
      headingFamily: 'PreviewNoto',
    ),
    DesignDirection.b => const DesignTokens(
      direction: DesignDirection.b,
      canvas: Color(0xFFF3F3EE),
      ink: Color(0xFF282F2E),
      muted: Color(0xFF59615D),
      line: Color(0xFFCFD3CB),
      accent: Color(0xFF97451F),
      tint: Color(0xFFF3E9DD),
      radius: 4,
      gap: 20,
      family: 'PreviewPlex',
      headingFamily: 'PreviewPlex',
    ),
    DesignDirection.c => const DesignTokens(
      direction: DesignDirection.c,
      canvas: Color(0xFFF8F4ED),
      ink: Color(0xFF263E34),
      muted: Color(0xFF626A5E),
      line: Color(0xFFDEDCD0),
      accent: Color(0xFF315A43),
      tint: Color(0xFFE9EEDF),
      radius: 22,
      gap: 28,
      family: 'PreviewNoto',
      headingFamily: 'PreviewNaskh',
    ),
  };

  Color get controlBorder => switch (direction) {
    DesignDirection.a => const Color(0xFF7A8A93),
    DesignDirection.b => const Color(0xFF7B847D),
    DesignDirection.c => const Color(0xFF808878),
  };

  ThemeData theme({bool urdu = false}) {
    final family = urdu ? 'PreviewNoto' : this.family;
    final headingFamily = urdu ? 'PreviewNoto' : this.headingFamily;
    final scheme = ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      secondary: ink,
      surface: Colors.white,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: line,
      error: const Color(0xFFAC2E28),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
    );
    final text = base.textTheme
        .apply(bodyColor: ink, displayColor: ink)
        .copyWith(
          headlineLarge: TextStyle(
            fontFamily: headingFamily,
            color: ink,
            fontWeight: FontWeight.w600,
            fontSize: direction == DesignDirection.c ? 36 : 30,
            height: 1.45,
          ),
          headlineSmall: TextStyle(
            fontFamily: headingFamily,
            color: ink,
            fontWeight: FontWeight.w600,
            fontSize: 24,
            height: 1.5,
          ),
          titleLarge: TextStyle(
            fontFamily: family,
            color: ink,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          titleMedium: TextStyle(
            fontFamily: family,
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.55,
          ),
          bodyMedium: TextStyle(
            fontFamily: family,
            color: ink,
            fontSize: 14,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            fontFamily: family,
            color: muted,
            fontSize: 12,
            height: 1.6,
          ),
          labelLarge: TextStyle(
            fontFamily: family,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: canvas,
      extensions: [this],
      dividerTheme: DividerThemeData(color: line, space: 1),
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(fontFamily: family, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: controlBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: controlBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorMaxLines: 4,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: shape,
          side: BorderSide(color: controlBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: shape,
        side: BorderSide.none,
        backgroundColor: canvas,
        selectedColor: tint,
        checkmarkColor: ink,
        labelStyle: text.bodySmall?.copyWith(color: ink),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  @override
  DesignTokens copyWith() => this;
  @override
  DesignTokens lerp(covariant DesignTokens? other, double t) =>
      t < .5 ? this : other ?? this;
}

DesignTokens tokens(BuildContext context) =>
    Theme.of(context).extension<DesignTokens>()!;
