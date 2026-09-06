import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/errors/app_exception.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/repositories/workspace_repository.dart';
import 'package:callx_ai/services/preferences_service.dart';

enum WorkspaceSettingsStatus {
  initial,
  loading,
  loaded,
  saving,
  failure,
}

class WorkspaceSettingsState {
  final WorkspaceSettingsStatus status;
  final List<TagModel> pipelineStages;
  final List<TagModel> customTags;
  final List<Color> tagColors;
  final List<String> tagColorHexes;
  final List<TagModel> leadPriorities;
  final List<TagModel> leadQualities;
  final List<TagModel> callStatuses;
  final String? errorMessage;

  const WorkspaceSettingsState({
    this.status = WorkspaceSettingsStatus.initial,
    this.pipelineStages = const [],
    this.customTags = const [],
    this.tagColors = const [],
    this.tagColorHexes = const [],
    this.leadPriorities = const [],
    this.leadQualities = const [],
    this.callStatuses = const [],
    this.errorMessage,
  });

  List<TagModel> get leadStatuses => pipelineStages;

  WorkspaceSettingsState copyWith({
    WorkspaceSettingsStatus? status,
    List<TagModel>? pipelineStages,
    List<TagModel>? customTags,
    List<Color>? tagColors,
    List<String>? tagColorHexes,
    List<TagModel>? leadPriorities,
    List<TagModel>? leadQualities,
    List<TagModel>? callStatuses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WorkspaceSettingsState(
      status: status ?? this.status,
      pipelineStages: pipelineStages ?? this.pipelineStages,
      customTags: customTags ?? this.customTags,
      tagColors: tagColors ?? this.tagColors,
      tagColorHexes: tagColorHexes ?? this.tagColorHexes,
      leadPriorities: leadPriorities ?? this.leadPriorities,
      leadQualities: leadQualities ?? this.leadQualities,
      callStatuses: callStatuses ?? this.callStatuses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class WorkspaceSettingsCubit extends Cubit<WorkspaceSettingsState> {
  final WorkspaceRepository workspaceRepository;
  final PreferencesService preferencesService;

  WorkspaceSettingsCubit({
    required this.workspaceRepository,
    required this.preferencesService,
  }) : super(WorkspaceSettingsState(
          leadPriorities: preferencesService.loadLeadPriorities(),
          leadQualities: preferencesService.loadLeadQualities(),
          callStatuses: preferencesService.loadCallStatuses(),
        ));

  Future<void> loadConfiguration() async {
    emit(state.copyWith(
      status: WorkspaceSettingsStatus.loading,
      clearError: true,
    ));

    try {
      var config = await workspaceRepository.getWorkspaceConfiguration();

      // One-time migration for legacy local tags
      if (!preferencesService.isWorkspaceTagsMigratedV1()) {
        final localTags = preferencesService.loadCustomTags();
        final serverLabels =
            config.customTags.map((t) => t.label.trim().toLowerCase()).toSet();

        final tagsToMigrate = <TagModel>[];
        for (final local in localTags) {
          final cleanLabel = local.label.trim();
          if (cleanLabel.isNotEmpty &&
              !serverLabels.contains(cleanLabel.toLowerCase())) {
            serverLabels.add(cleanLabel.toLowerCase());
            tagsToMigrate.add(TagModel(
              id: '',
              label: cleanLabel,
              color: local.color,
            ));
          }
        }

        if (tagsToMigrate.isNotEmpty) {
          final merged = [...config.customTags, ...tagsToMigrate];
          config =
              await workspaceRepository.updateWorkspaceConfiguration(merged);
        }

        await preferencesService.setWorkspaceTagsMigratedV1(true);
      }

      emit(state.copyWith(
        status: WorkspaceSettingsStatus.loaded,
        pipelineStages: config.pipelineStages,
        customTags: config.customTags,
        tagColors: config.tagColors,
        tagColorHexes: config.tagColorHexes,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WorkspaceSettingsStatus.failure,
        errorMessage: 'Unable to load workspace configuration.',
      ));
    }
  }

  void addOrUpdateTagLocally(TagModel tag) {
    final cleanLabel = tag.label.trim().toLowerCase();
    final updated = [...state.customTags];
    final index =
        updated.indexWhere((t) => t.label.trim().toLowerCase() == cleanLabel);
    if (index >= 0) {
      updated[index] = tag;
    } else {
      updated.add(tag);
    }
    emit(state.copyWith(customTags: updated));
  }

  Future<bool> saveCustomTags(List<TagModel> tags) async {
    emit(state.copyWith(
      status: WorkspaceSettingsStatus.saving,
      clearError: true,
    ));

    try {
      final config =
          await workspaceRepository.updateWorkspaceConfiguration(tags);
      emit(state.copyWith(
        status: WorkspaceSettingsStatus.loaded,
        customTags: config.customTags,
        pipelineStages: config.pipelineStages,
        tagColors: config.tagColors,
        tagColorHexes: config.tagColorHexes,
        clearError: true,
      ));
      return true;
    } on AppException catch (e) {
      String msg = 'Unable to save workspace configuration.';
      if (e.fieldErrors.isNotEmpty) {
        msg = e.fieldErrors.values.expand((x) => x).join(' ');
      } else if (e.details != null && e.details!.trim().isNotEmpty) {
        msg = e.details!;
      }
      emit(state.copyWith(
        status: WorkspaceSettingsStatus.failure,
        errorMessage: msg,
      ));
      return false;
    } catch (e) {
      emit(state.copyWith(
        status: WorkspaceSettingsStatus.failure,
        errorMessage: 'Unable to save workspace configuration.',
      ));
      return false;
    }
  }

  // Fallback helper methods for secondary metadata
  void setLeadPriorities(List<TagModel> list) {
    preferencesService.saveLeadPriorities(list);
    emit(state.copyWith(leadPriorities: list));
  }

  void setLeadQualities(List<TagModel> list) {
    preferencesService.saveLeadQualities(list);
    emit(state.copyWith(leadQualities: list));
  }

  void setCallStatuses(List<TagModel> list) {
    preferencesService.saveCallStatuses(list);
    emit(state.copyWith(callStatuses: list));
  }
}
