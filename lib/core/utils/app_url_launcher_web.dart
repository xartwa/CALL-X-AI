import 'package:web/web.dart' as web;

/// Web implementation for opening browser tabs using package:web.
void openBrowserTab(String url) {
  web.window.open(url, '_blank');
}
