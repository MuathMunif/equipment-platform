// Separate development entry point; deliberately absent from main.dart/router.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_preview/gallery.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadPreviewFonts();
  runApp(
    DesignPreviewApp(
      parameters: {
        'direction': const String.fromEnvironment(
          'PREVIEW_DIRECTION',
          defaultValue: 'a',
        ),
        'screen': const String.fromEnvironment(
          'PREVIEW_SCREEN',
          defaultValue: 'home',
        ),
        'locale': const String.fromEnvironment(
          'PREVIEW_LOCALE',
          defaultValue: 'ar',
        ),
        ...Uri.base.queryParameters,
      },
    ),
  );
}

Future<void> loadPreviewFonts() async {
  // Fonts are loaded only by this entry point, never installed on the device.
  for (final entry in <String, List<String>>{
    'PreviewNoto': ['NotoSansArabic[wdth,wght].ttf'],
    'PreviewPlex': [
      'IBMPlexSansArabic-Regular.ttf',
      'IBMPlexSansArabic-SemiBold.ttf',
    ],
    'PreviewNaskh': ['NotoNaskhArabic[wght].ttf'],
  }.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/design_fonts/$file'));
    }
    await loader.load();
  }
}
