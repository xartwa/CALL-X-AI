import 'app_url_launcher_stub.dart'
    if (dart.library.js_interop) 'app_url_launcher_web.dart' as launcher;

/// Helper utility to normalize, validate, and launch URLs safely.
class AppUrlHelper {
  /// Normalizes a website URL.
  /// If it does not start with http:// or https://, automatically adds https://.
  /// Safely handles null, empty strings, and placeholder strings from Excel or raw imports.
  static String normalizeWebsiteUrl(String? input) {
    if (input == null) return '';
    var trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    final lower = trimmed.toLowerCase();
    if (lower == '-' ||
        lower == 'n/a' ||
        lower == 'na' ||
        lower == 'none' ||
        lower == 'null' ||
        lower == 'undefined') {
      return '';
    }

    if (!trimmed.startsWith(RegExp(r'^https?:\/\/', caseSensitive: false))) {
      trimmed = 'https://$trimmed';
    }
    return trimmed;
  }

  /// Checks if a string has a valid URL format (with or without scheme).
  static bool isValidUrl(String? input) {
    final normalized = normalizeWebsiteUrl(input);
    if (normalized.isEmpty) return false;
    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;

    final host = uri.host;
    if (host.isEmpty || !host.contains('.')) return false;

    final regex = RegExp(
      r'^(https?:\/\/)?([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(:\d+)?(\/[^\s]*)?$',
      caseSensitive: false,
    );
    return regex.hasMatch(normalized);
  }

  /// Opens the URL in a new browser tab/window safely.
  /// Returns true if launched, false if invalid or failed. Never throws an exception.
  static bool openUrl(String? rawUrl) {
    final normalized = normalizeWebsiteUrl(rawUrl);
    if (normalized.isEmpty) return false;

    try {
      launcher.openBrowserTab(normalized);
      return true;
    } catch (_) {
      // Gracefully ignore any platform errors to avoid crashing the app
    }
    return false;
  }
}
