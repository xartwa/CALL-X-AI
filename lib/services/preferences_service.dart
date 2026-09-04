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
  static const _workspaceTagsMigratedV1Key = 'workspace_tags_migrated_v1';

  bool isWorkspaceTagsMigratedV1() {
    return _preferences.getBool(_workspaceTagsMigratedV1Key) ?? false;
  }

  Future<void> setWorkspaceTagsMigratedV1(bool value) async {
    await _preferences.setBool(_workspaceTagsMigratedV1Key, value);
  }

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
        TagModel(id: '4', label: 'Upcoming', color: const Color(0xFFF59E0B)),
        TagModel(id: '5', label: 'In Progress', color: const Color(0xFF3B82F6)),
        TagModel(id: '6', label: 'Ringing', color: const Color(0xFF0284C7)),
        TagModel(id: '7', label: 'Busy', color: const Color(0xFFF97316)),
        TagModel(id: '8', label: 'No Answer', color: const Color(0xFF94A3B8)),
        TagModel(id: '9', label: 'Canceled', color: const Color(0xFFEF4444)),
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
          'createdAt': '2026-08-26T09:00:00Z'
        },
        {
          'id': '2',
          'text': 'Follow up with VIP qualified leads',
          'isCompleted': true,
          'createdAt': '2026-08-26T08:30:00Z'
        },
        {
          'id': '3',
          'text': 'Update outbound sales campaign script',
          'isCompleted': false,
          'createdAt': '2026-08-26T08:00:00Z'
        },
        {
          'id': '4',
          'text': 'Check telephony carrier logs',
          'isCompleted': false,
          'createdAt': '2026-08-26T07:30:00Z'
        },
        {
          'id': '5',
          'text': 'Schedule pipeline review meeting',
          'isCompleted': false,
          'createdAt': '2026-08-26T07:00:00Z'
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

  static const _savedSenderEmailsKey = 'saved_sender_emails';

  List<String> loadSavedSenderEmails() {
    return _preferences.getStringList(_savedSenderEmailsKey) ?? [];
  }

  Future<void> saveSenderEmail(String email) async {
    final clean = email.trim();
    if (clean.isEmpty) return;
    final current = List<String>.from(loadSavedSenderEmails());
    if (!current.contains(clean)) {
      current.insert(0, clean);
      await _preferences.setStringList(_savedSenderEmailsKey, current);
    }
  }

  Future<void> removeSenderEmail(String email) async {
    final clean = email.trim();
    final current = List<String>.from(loadSavedSenderEmails());
    current.remove(clean);
    await _preferences.setStringList(_savedSenderEmailsKey, current);
  }
}

