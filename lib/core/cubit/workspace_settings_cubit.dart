import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/services/preferences_service.dart';

class WorkspaceSettingsState {
  final List<TagModel> leadStatuses;
  final List<TagModel> leadPriorities;
  final List<TagModel> leadQualities;
  final List<TagModel> customTags;
  final List<TagModel> callStatuses;

  WorkspaceSettingsState({
    this.leadStatuses = const [],
    this.leadPriorities = const [],
    this.leadQualities = const [],
    this.customTags = const [],
    this.callStatuses = const [],
  });

  WorkspaceSettingsState copyWith({
    List<TagModel>? leadStatuses,
    List<TagModel>? leadPriorities,
    List<TagModel>? leadQualities,
    List<TagModel>? customTags,
    List<TagModel>? callStatuses,
  }) {
    return WorkspaceSettingsState(
      leadStatuses: leadStatuses ?? this.leadStatuses,
      leadPriorities: leadPriorities ?? this.leadPriorities,
      leadQualities: leadQualities ?? this.leadQualities,
      customTags: customTags ?? this.customTags,
      callStatuses: callStatuses ?? this.callStatuses,
    );
  }
}

class WorkspaceSettingsCubit extends Cubit<WorkspaceSettingsState> {
  final PreferencesService preferencesService;

  WorkspaceSettingsCubit({required this.preferencesService})
      : super(WorkspaceSettingsState()) {
    loadSettings();
  }

  void loadSettings() {
    final state = WorkspaceSettingsState(
      leadStatuses: preferencesService.loadLeadStatuses(),
      leadPriorities: preferencesService.loadLeadPriorities(),
      leadQualities: preferencesService.loadLeadQualities(),
      customTags: preferencesService.loadCustomTags(),
      callStatuses: preferencesService.loadCallStatuses(),
    );
    emit(state);
  }

  void addLeadStatus(TagModel tag) {
    final list = List<TagModel>.from(state.leadStatuses)..add(tag);
    preferencesService.saveLeadStatuses(list);
    emit(state.copyWith(leadStatuses: list));
  }

  void removeLeadStatus(TagModel tag) {
    final list = List<TagModel>.from(state.leadStatuses)
      ..removeWhere((t) => t.id == tag.id);
    preferencesService.saveLeadStatuses(list);
    emit(state.copyWith(leadStatuses: list));
  }

  void addLeadPriority(TagModel tag) {
    final list = List<TagModel>.from(state.leadPriorities)..add(tag);
    preferencesService.saveLeadPriorities(list);
    emit(state.copyWith(leadPriorities: list));
  }

  void removeLeadPriority(TagModel tag) {
    final list = List<TagModel>.from(state.leadPriorities)
      ..removeWhere((t) => t.id == tag.id);
    preferencesService.saveLeadPriorities(list);
    emit(state.copyWith(leadPriorities: list));
  }

  void addLeadQuality(TagModel tag) {
    final list = List<TagModel>.from(state.leadQualities)..add(tag);
    preferencesService.saveLeadQualities(list);
    emit(state.copyWith(leadQualities: list));
  }

  void removeLeadQuality(TagModel tag) {
    final list = List<TagModel>.from(state.leadQualities)
      ..removeWhere((t) => t.id == tag.id);
    preferencesService.saveLeadQualities(list);
    emit(state.copyWith(leadQualities: list));
  }

  void addCustomTag(TagModel tag) {
    final list = List<TagModel>.from(state.customTags)..add(tag);
    preferencesService.saveCustomTags(list);
    emit(state.copyWith(customTags: list));
  }

  void removeCustomTag(TagModel tag) {
    final list = List<TagModel>.from(state.customTags)
      ..removeWhere((t) => t.id == tag.id);
    preferencesService.saveCustomTags(list);
    emit(state.copyWith(customTags: list));
  }

  void addCallStatus(TagModel tag) {
    final list = List<TagModel>.from(state.callStatuses)..add(tag);
    preferencesService.saveCallStatuses(list);
    emit(state.copyWith(callStatuses: list));
  }

  void removeCallStatus(TagModel tag) {
    final list = List<TagModel>.from(state.callStatuses)
      ..removeWhere((t) => t.id == tag.id);
    preferencesService.saveCallStatuses(list);
    emit(state.copyWith(callStatuses: list));
  }

  void setAllSettings({
    required List<TagModel> leadStatuses,
    required List<TagModel> leadPriorities,
    required List<TagModel> leadQualities,
    required List<TagModel> customTags,
    required List<TagModel> callStatuses,
  }) {
    preferencesService.saveLeadStatuses(leadStatuses);
    preferencesService.saveLeadPriorities(leadPriorities);
    preferencesService.saveLeadQualities(leadQualities);
    preferencesService.saveCustomTags(customTags);
    preferencesService.saveCallStatuses(callStatuses);

    emit(state.copyWith(
      leadStatuses: leadStatuses,
      leadPriorities: leadPriorities,
      leadQualities: leadQualities,
      customTags: customTags,
      callStatuses: callStatuses,
    ));
  }
}
