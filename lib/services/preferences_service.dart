import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callx_ai/core/models/auth_user_model.dart';
import 'package:callx_ai/core/models/tag_model.dart';

class PreferencesService {
  PreferencesService(this._preferences);

  final SharedPreferences _preferences;

  static const _themeKey = 'theme_mode';

  ThemeMode loadThemeMode() {
    final stored = _preferences.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _preferences.setString(_themeKey, mode.name);
  }

  static const _isLoggedInKey = 'is_logged_in';

  bool isLoggedIn() {
    return _preferences.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _preferences.setBool(_isLoggedInKey, value);
  }

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _authUserKey = 'auth_user';

  /// In-memory token for sessions without "remember me".
  /// It survives navigation but not an app restart.
  String? _runtimeAccessToken;

  String? getAccessToken() {
    return _runtimeAccessToken ?? _preferences.getString(_accessTokenKey);
  }

  AuthUser? getAuthUser() {
    final raw = _preferences.getString(_authUserKey);
    if (raw == null) return null;
    try {
      return AuthUser.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
    } catch (_) {
      return null;
    }
  }

  /// Persists the auth session. When [persist] is false (remember me
  /// unchecked), tokens are kept in memory only.
  Future<void> saveAuthSession({
    required AuthSession session,
    required bool persist,
  }) async {
    _runtimeAccessToken = session.accessToken;
    if (persist) {
      await _preferences.setString(_accessTokenKey, session.accessToken);
      await _preferences.setString(_refreshTokenKey, session.refreshToken);
      await _preferences.setString(
          _authUserKey, jsonEncode(session.user.toJson()));
    }
    await setLoggedIn(true);
  }

  /// Clears every piece of auth state (logout).
  Future<void> clearAuthSession() async {
    _runtimeAccessToken = null;
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_refreshTokenKey);
    await _preferences.remove(_authUserKey);
    await setLoggedIn(false);
  }

  static const _aiEnabledKey = 'ai_enabled';
  static const _aiVoiceKey = 'ai_voice';
  static const _questionsKey = 'questions_list';

  bool isAiEnabled() {
    return _preferences.getBool(_aiEnabledKey) ?? true;
  }

  Future<void> setAiEnabled(bool value) async {
    await _preferences.setBool(_aiEnabledKey, value);
  }

  String getAiVoice() {
    return _preferences.getString(_aiVoiceKey) ?? 'Emma';
  }

  Future<void> setAiVoice(String value) async {
    await _preferences.setString(_aiVoiceKey, value);
  }

  List<Map<String, dynamic>> loadQuestions() {
    final list = _preferences.getStringList(_questionsKey);
    if (list == null) {
      return [
        {
          'id': '1',
          'text': 'How can I assist you with your account today?',
          'enabled': true
        },
        {
          'id': '2',
          'text': 'Are you calling to report a service interruption?',
          'enabled': true
        },
        {
          'id': '3',
          'text':
              'Would you like to upgrade your current call center subscription package?',
          'enabled': false
        },
      ];
    }
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveQuestions(List<Map<String, dynamic>> questions) async {
    final list = questions.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_questionsKey, list);
  }

  static const _callsKey = 'calls_list';

  List<Map<String, dynamic>> loadCalls() {
    final list = _preferences.getStringList(_callsKey);
    if (list == null) return [];
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveCalls(List<Map<String, dynamic>> calls) async {
    final list = calls.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_callsKey, list);
  }

  static const _emailsKey = 'emails_list';
  static const _templatesKey = 'email_templates_list';

  List<Map<String, dynamic>> loadEmails() {
    final list = _preferences.getStringList(_emailsKey);
    if (list == null) return [];
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveEmails(List<Map<String, dynamic>> emails) async {
    final list = emails.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_emailsKey, list);
  }

  List<Map<String, dynamic>> loadTemplates() {
    final list = _preferences.getStringList(_templatesKey);
    if (list == null) {
      return [
        {
          'id': '1',
          'name': 'Welcome Onboarding',
          'subject': 'Welcome to CallCenter Pro!',
          'body':
              'Dear {name},\n\nThank you for choosing CallCenter Pro! We are excited to support your team. Let us know if you want to schedule a quick onboarding session.\n\nBest regards,\nCallCenter Admin Team'
        },
        {
          'id': '2',
          'name': 'Pricing & Upgrade Offer',
          'subject': 'Special Offer: Upgrade Your Plan Today',
          'body':
              'Hi {name},\n\nWe noticed you are reaching your monthly limit on call volume. We have a special 20% discount if you upgrade to the enterprise plan this week.\n\nLet me know if you would like to discuss this opportunity!\n\nBest,\nSales Team'
        },
        {
          'id': '3',
          'name': 'Missed Call Follow-up',
          'subject': 'Sorry we missed you today',
          'body':
              'Dear {name},\n\nWe tried to reach you today at your scheduled time but were unable to connect. Please let us know when is a better time to call you back.\n\nSchedule link: www.callcenterpro.com/schedule\n\nThanks,\nSupport Team'
        }
      ];
    }
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveTemplates(List<Map<String, dynamic>> templates) async {
    final list = templates.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_templatesKey, list);
  }

  static const _customersKey = 'customers_list';

  List<Map<String, dynamic>> loadCustomers() {
    final list = _preferences.getStringList(_customersKey);
    if (list == null) return [];
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveCustomers(List<Map<String, dynamic>> customers) async {
    final list = customers.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_customersKey, list);
  }

  static const _leadStatusesKey = 'lead_statuses_list';
  static const _leadPrioritiesKey = 'lead_priorities_list';
  static const _leadQualitiesKey = 'lead_qualities_list';
  static const _customTagsKey = 'custom_tags_list';
  static const _callStatusesKey = 'call_statuses_list';

  List<TagModel> loadLeadStatuses() {
    final list = _preferences.getStringList(_leadStatusesKey);
    if (list == null) {
      return [
        TagModel(id: '1', label: 'New', color: const Color(0xFF3B82F6)),
        TagModel(id: '2', label: 'Contacted', color: const Color(0xFF3B82F6)),
        TagModel(id: '3', label: 'Qualified', color: const Color(0xFF10B981)),
        TagModel(id: '4', label: 'Won', color: const Color(0xFF10B981)),
        TagModel(id: '5', label: 'Lost', color: const Color(0xFFEF4444)),
      ];
    }
    return list.map((item) => TagModel.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveLeadStatuses(List<TagModel> tags) async {
    await _preferences.setStringList(
        _leadStatusesKey, tags.map((t) => jsonEncode(t.toJson())).toList());
  }

  List<TagModel> loadLeadPriorities() {
    final list = _preferences.getStringList(_leadPrioritiesKey);
    if (list == null) {
      return [
        TagModel(id: '1', label: 'Hot', color: const Color(0xFFEF4444)),
        TagModel(id: '2', label: 'Warm', color: const Color(0xFFF59E0B)),
        TagModel(id: '3', label: 'Cold', color: const Color(0xFF3B82F6)),
      ];
    }
    return list.map((item) => TagModel.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveLeadPriorities(List<TagModel> tags) async {
    await _preferences.setStringList(
        _leadPrioritiesKey, tags.map((t) => jsonEncode(t.toJson())).toList());
  }

  List<TagModel> loadLeadQualities() {
    final list = _preferences.getStringList(_leadQualitiesKey);
    if (list == null) {
      return [
        TagModel(id: '1', label: 'Excellent', color: const Color(0xFF10B981)),
        TagModel(id: '2', label: 'Good', color: const Color(0xFF3B82F6)),
        TagModel(id: '3', label: 'Average', color: const Color(0xFFF59E0B)),
        TagModel(id: '4', label: 'Poor', color: const Color(0xFFEF4444)),
      ];
    }
    return list.map((item) => TagModel.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveLeadQualities(List<TagModel> tags) async {
    await _preferences.setStringList(
        _leadQualitiesKey, tags.map((t) => jsonEncode(t.toJson())).toList());
  }

  List<TagModel> loadCustomTags() {
    final list = _preferences.getStringList(_customTagsKey);
    if (list == null) {
      return [
        TagModel(id: '1', label: 'High Budget', color: const Color(0xFF10B981)),
        TagModel(id: '2', label: 'Developer', color: const Color(0xFF8B5CF6)),
        TagModel(id: '3', label: 'Agency', color: const Color(0xFFF59E0B)),
      ];
    }
    return list.map((item) => TagModel.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveCustomTags(List<TagModel> tags) async {
    await _preferences.setStringList(
        _customTagsKey, tags.map((t) => jsonEncode(t.toJson())).toList());
  }

  List<TagModel> loadCallStatuses() {
    final list = _preferences.getStringList(_callStatusesKey);
    if (list == null) {
      return [
        TagModel(id: '1', label: 'Completed', color: const Color(0xFF10B981)),
        TagModel(id: '2', label: 'Failed', color: const Color(0xFFEF4444)),
        TagModel(id: '3', label: 'Queued', color: const Color(0xFFF59E0B)),
        TagModel(id: '4', label: 'Upcoming', color: const Color(0xFF3B82F6)),
      ];
    }
    return list.map((item) => TagModel.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveCallStatuses(List<TagModel> tags) async {
    await _preferences.setStringList(
        _callStatusesKey, tags.map((t) => jsonEncode(t.toJson())).toList());
  }

  static const _todosKey = 'dashboard_todos_list';

  List<Map<String, dynamic>> loadTodos() {
    final list = _preferences.getStringList(_todosKey);
    if (list == null) {
      return [
        {
          'id': '1',
          'text': 'Review weekly cold call metrics',
          'isCompleted': false,
          'createdAt': '2026-08-26T09:00:00.000Z'
        },
        {
          'id': '2',
          'text': 'Follow up with VIP qualified leads',
          'isCompleted': true,
          'createdAt': '2026-08-26T08:30:00.000Z'
        },
        {
          'id': '3',
          'text': 'Update outbound sales campaign script',
          'isCompleted': false,
          'createdAt': '2026-08-26T08:00:00.000Z'
        },
        {
          'id': '4',
          'text': 'Check telephony carrier logs',
          'isCompleted': false,
          'createdAt': '2026-08-26T07:30:00.000Z'
        },
        {
          'id': '5',
          'text': 'Schedule pipeline review meeting',
          'isCompleted': false,
          'createdAt': '2026-08-26T07:00:00.000Z'
        },
      ];
    }
    return list
        .map((item) => Map<String, dynamic>.from(jsonDecode(item)))
        .toList();
  }

  Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final list = todos.map((item) => jsonEncode(item)).toList();
    await _preferences.setStringList(_todosKey, list);
  }
}
