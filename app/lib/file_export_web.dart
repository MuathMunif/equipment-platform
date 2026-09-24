import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

Future<void> exportFile(Uint8List bytes, String filename, String type) =>
    XFile.fromData(bytes, name: filename, mimeType: type).saveTo(filename);
