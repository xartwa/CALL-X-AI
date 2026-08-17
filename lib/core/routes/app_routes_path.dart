class AppRoutesPath {
  static const String login = '/';
  static const String loginName = 'login';

  static const String dashboard = '/dashboard';
  static const String dashboardName = 'dashboard';

  static const String customers = '/customers';
  static const String customersName = 'customers';
  static const String customerDetail = 'detail/:id';
  static const String customerDetailName = 'customer-detail';

  static const String calls = '/calls';
  static const String callsName = 'calls';

  static const String emailFollowUps = '/email-follow-ups';
  static const String emailFollowUpsName = 'email-follow-ups';

  static const String aiSettings = '/ai-settings';
  static const String aiSettingsName = 'ai-settings';

  static String customerDetailPath(String id) =>
      '$customers/$customerDetail'.replaceAll(':id', id);
}
