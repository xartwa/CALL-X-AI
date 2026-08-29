import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveDownloadedFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save customers export',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      bytes: bytes,
    );
    return savedPath != null;
  }

  final savedPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Save customers export',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
  );
  if (savedPath == null) return false;

  await File(savedPath).writeAsBytes(bytes, flush: true);
  return true;
}
