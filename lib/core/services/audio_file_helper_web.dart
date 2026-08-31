import 'package:web/web.dart' as web;

void triggerWebDownload(String url, String fileName, List<int> bytes) {
  if (url.startsWith('http')) {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..target = '_blank'
      ..download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  } else {
    final dataUrl = Uri.dataFromBytes(
      bytes,
      mimeType: 'audio/mp3',
    ).toString();
    final anchor = web.HTMLAnchorElement()
      ..href = dataUrl
      ..target = '_blank'
      ..download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
}

void openWebFile(String url, String fileName) {
  if (url.startsWith('http')) {
    web.window.open(url, '_blank');
  }
}
