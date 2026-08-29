import 'audio_file_helper_stub.dart'
    if (dart.library.html) 'audio_file_helper_web.dart' as helper;

void triggerWebDownload(String url, String fileName, List<int> bytes) {
  helper.triggerWebDownload(url, fileName, bytes);
}

void openWebFile(String url, String fileName) {
  helper.openWebFile(url, fileName);
}
