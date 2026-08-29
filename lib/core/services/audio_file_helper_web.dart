// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void triggerWebDownload(String url, String fileName, List<int> bytes) {
  if (url.startsWith('http')) {
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
  } else {
    final blob = html.Blob([bytes], 'audio/mp3');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: blobUrl)
      ..target = '_blank'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(blobUrl);
  }
}

void openWebFile(String url, String fileName) {
  if (url.startsWith('http')) {
    html.window.open(url, '_blank');
  }
}
