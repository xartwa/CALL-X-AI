import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/models/workspace_configuration_model.dart';
import 'package:callx_ai/core/repositories/workspace_repository.dart';
import 'package:callx_ai/services/preferences_service.dart';

class _FakeWorkspaceRepository implements WorkspaceRepository {
  WorkspaceConfigurationModel config = const WorkspaceConfigurationModel(
    pipelineStages: [
      TagModel(id: '1', label: 'New', color: Color(0xFF3B82F6)),
      TagModel(id: '2', label: 'Contacted', color: Color(0xFFF59E0B)),
      TagModel(id: '3', label: 'Qualified', color: Color(0xFF10B981)),
      TagModel(id: '4', label: 'Won', color: Color(0xFF6366F1)),
      TagModel(id: '5', label: 'Lost', color: Color(0xFFEF4444)),
    ],
    customTags: [
      TagModel(id: '1', label: 'High Budget', color: Color(0xFF10B981)),
      TagModel(id: '2', label: 'Developer', color: Color(0xFF3B82F6)),
      TagModel(id: '3', label: 'Agency', color: Color(0xFF8B5CF6)),
    ],
    tagColors: [
      Color(0xFFEF4444),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
    ],
    tagColorHexes: [
      '#EF4444',
      '#10B981',
      '#3B82F6',
    ],
  );

  bool shouldThrow = false;
  List<TagModel>? lastSavedTags;

  @override
  Future<WorkspaceConfigurationModel> getWorkspaceConfiguration({Object? cancelToken}) async {
    if (shouldThrow) throw Exception('Server error');
    return config;
  }

  @override
  Future<WorkspaceConfigurationModel> updateWorkspaceConfiguration(
    List<TagModel> customTags, {
    Object? cancelToken,
  }) async {
    if (shouldThrow) throw Exception('Server error');
    lastSavedTags = customTags;
    config = WorkspaceConfigurationModel(
      pipelineStages: config.pipelineStages,
      customTags: customTags,
      tagColors: config.tagColors,
      tagColorHexes: config.tagColorHexes,
    );
    return config;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkspaceSettingsCubit', () {
    late PreferencesService preferencesService;
    late _FakeWorkspaceRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      preferencesService = PreferencesService(prefs);
      repository = _FakeWorkspaceRepository();
    });

    test('loadConfiguration loads pipeline stages, custom tags, and tag colors', () async {
      final cubit = WorkspaceSettingsCubit(
        workspaceRepository: repository,
        preferencesService: preferencesService,
      );

      await cubit.loadConfiguration();

      expect(cubit.state.status, WorkspaceSettingsStatus.loaded);
      expect(cubit.state.pipelineStages.length, 5);
      expect(cubit.state.customTags.length, 3);
      expect(cubit.state.tagColors.length, 3);
      expect(preferencesService.isWorkspaceTagsMigratedV1(), true);

      await cubit.close();
    });

    test('performs one-time migration for local tags not present on the server', () async {
      // Save local custom tags in preferences before migration
      await preferencesService.saveCustomTags([
        const TagModel(id: 'local-1', label: 'High Budget', color: Color(0xFF10B981)), // Duplicate
        const TagModel(id: 'local-2', label: 'VIP Client', color: Color(0xFFEC4899)), // New
      ]);

      final cubit = WorkspaceSettingsCubit(
        workspaceRepository: repository,
        preferencesService: preferencesService,
      );

      await cubit.loadConfiguration();

      expect(cubit.state.status, WorkspaceSettingsStatus.loaded);
      // Remote had 3, local added 1 unique ('VIP Client') -> 4 total
      expect(cubit.state.customTags.length, 4);
      expect(cubit.state.customTags.any((t) => t.label == 'VIP Client'), true);
      expect(repository.lastSavedTags, isNotNull);
      expect(preferencesService.isWorkspaceTagsMigratedV1(), true);

      await cubit.close();
    });

    test('saveCustomTags updates backend and emits loaded state with updated custom tags', () async {
      final cubit = WorkspaceSettingsCubit(
        workspaceRepository: repository,
        preferencesService: preferencesService,
      );

      await cubit.loadConfiguration();

      final newDraft = [
        const TagModel(id: '1', label: 'High Budget', color: Color(0xFF10B981)),
        const TagModel(id: '', label: 'Enterprise Lead', color: Color(0xFF3B82F6)),
      ];

      final result = await cubit.saveCustomTags(newDraft);

      expect(result, true);
      expect(cubit.state.status, WorkspaceSettingsStatus.loaded);
      expect(cubit.state.customTags.length, 2);
      expect(cubit.state.customTags.last.label, 'Enterprise Lead');

      await cubit.close();
    });

    test('emits failure when remote throws an error', () async {
      repository.shouldThrow = true;

      final cubit = WorkspaceSettingsCubit(
        workspaceRepository: repository,
        preferencesService: preferencesService,
      );

      await cubit.loadConfiguration();

      expect(cubit.state.status, WorkspaceSettingsStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);

      await cubit.close();
    });
  });
}
