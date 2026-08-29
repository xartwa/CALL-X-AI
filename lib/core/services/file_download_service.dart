import 'dart:typed_data';

import 'file_download_service_stub.dart'
    if (dart.library.io) 'file_download_service_io.dart'
    if (dart.library.html) 'file_download_service_web.dart' as implementation;

Future<bool> saveDownloadedFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) =>
    implementation.saveDownloadedFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
