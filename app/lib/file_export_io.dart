import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> exportFile(Uint8List bytes, String filename, String type) async {
  final root = await getTemporaryDirectory();
  final dir = await Directory('${root.path}/equipment-exports')
      .create(recursive: true);
  final file = File(
    '${dir.path}/${DateTime.now().microsecondsSinceEpoch}-${filename.replaceAll(RegExp(r'[/\\]'), '_')}',
  );
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: type);
  if (result.type != ResultType.done) {
    throw Exception('تعذر فتح الملف على الجهاز');
  }
}
