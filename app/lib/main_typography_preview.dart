// Isolated offline comparison. Never imported by the production entry point.
import 'package:flutter/material.dart';

import 'typography_preview/fonts.dart';
import 'typography_preview/gallery.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTypographyFonts();
  runApp(
    TypographyPreviewApp(
      parameters: {
        'font': const String.fromEnvironment(
          'TYPOGRAPHY_FONT',
          defaultValue: 'f1',
        ),
        'screen': const String.fromEnvironment(
          'TYPOGRAPHY_SCREEN',
          defaultValue: 'equipment',
        ),
        'locale': const String.fromEnvironment(
          'TYPOGRAPHY_LOCALE',
          defaultValue: 'ar',
        ),
        ...Uri.base.queryParameters,
      },
    ),
  );
}
