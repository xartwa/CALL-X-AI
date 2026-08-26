class AppConstants {
  const AppConstants._();

  static const String appName = 'Call Center Admin';

  /// Override per platform/build with `--dart-define=API_BASE_URL=...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
}
