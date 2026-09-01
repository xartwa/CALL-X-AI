import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/entities/ai_scenario.dart';
import '../domain/repositories/ai_settings_repository.dart';
import 'ai_settings_state.dart';

export 'ai_settings_state.dart';

class AiSettingsCubit extends Cubit<AiSettingsState> {
  AiSettingsCubit(this.repository) : super(const AiSettingsState());

  final AiSettingsRepository repository;

  static const categories = [
    'Sales & Outreach',
    'Customer Support',
    'Follow-Up & Closing',
  ];

  static const tones = [
    'Professional & Confident',
    'Friendly & Warm',
    'Direct & Fast-Paced',
    'Casual & Relaxed',
  ];

  Future<void> load() async {
    emit(state.copyWith(
      status: AiSettingsStatus.loading,
      clearError: true,
      clearFeedback: true,
    ));

    try {
      final bundle = await repository.loadSettings();
      final selected = _preferredScenario(bundle.scenarios);
      emit(AiSettingsState(
        status: AiSettingsStatus.success,
        config: bundle.config,
        voices: bundle.voices,
        scenarios: bundle.scenarios,
        savedScenario: selected,
        draft: selected?.copyWith(),
      ));
    } on AppException catch (error) {
      emit(state.copyWith(
        status: AiSettingsStatus.failure,
        errorMessage: _message(error),
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AiSettingsStatus.failure,
        errorMessage: 'Unable to load AI settings. Please check your connection and try again.',
      ));
    }
  }


  AiScenario? _preferredScenario(List<AiScenario> scenarios) {
    if (scenarios.isEmpty) return null;
    final currentId = state.draft?.id;
    for (final scenario in scenarios) {
      if (scenario.id == currentId) return scenario;
    }
    for (final scenario in scenarios) {
      if (scenario.isDefaultInbound) return scenario;
    }
    return scenarios.first;
  }

  void selectScenario(String id) {
    if (state.hasUnsavedChanges || state.isBusy) return;
    for (final scenario in state.scenarios) {
      if (scenario.id == id) {
        emit(state.copyWith(
          savedScenario: scenario,
          draft: scenario.copyWith(),
          clearError: true,
          clearFeedback: true,
        ));
        return;
      }
    }
  }

  void updateDraft(AiScenario Function(AiScenario current) update) {
    final current = state.draft;
    if (current == null || state.isBusy) return;
    final updated = update(current);
    if (current.sameContent(updated)) return;
    emit(state.copyWith(
      draft: updated,
      clearError: true,
      clearFeedback: true,
    ));
  }


  void resetDraft() {
    final saved = state.savedScenario;
    if (saved == null || state.isBusy) return;
    emit(state.copyWith(
      draft: saved.copyWith(),
      clearError: true,
      clearFeedback: true,
    ));
  }

  Future<void> save() async {
    final draft = state.draft;
    if (draft == null || !state.hasUnsavedChanges || state.isSaving) return;
    final validation = _validate(draft);
    if (validation != null) {
      _feedback(validation);
      return;
    }
    emit(state.copyWith(isSaving: true, clearError: true, clearFeedback: true));
    try {
      final updated = await repository.updateScenario(draft);
      final scenarios = state.scenarios.map((scenario) {
        if (scenario.id == updated.id) return updated;
        if (updated.isDefaultInbound && scenario.isDefaultInbound) {
          return scenario.copyWith(isDefaultInbound: false);
        }
        return scenario;
      }).toList(growable: false);
      emit(state.copyWith(
        scenarios: scenarios,
        savedScenario: updated,
        draft: updated.copyWith(),
        isSaving: false,
        feedbackMessage: 'AI settings are live for the next call.',
        feedbackRevision: state.feedbackRevision + 1,
      ));
    } on AppException catch (error) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        feedbackMessage: _message(error),
        feedbackRevision: state.feedbackRevision + 1,
      ));
    }
  }

  Future<void> createScenario(String name, String category) async {
    if (state.isBusy || name.trim().length < 3) return;
    final voiceId = state.config?.defaultVoice.isNotEmpty == true
        ? state.config!.defaultVoice
        : (state.voices.isNotEmpty ? state.voices.first.id : '');
    final scenario = AiScenario(
      id: 'scenario-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      category: category,
      openingGreeting: 'Hi {name}, this is Skyler. Is now a good time to talk?',
      pitchSummary:
          'Understand the caller\'s needs and offer the next helpful step.',
      personalityPrompt:
          'Be warm, concise, attentive, and natural. Listen fully before responding.',
      qualifyingQuestions: const [],
      actionOnInterest: 'Offer a discovery appointment',
      voiceId: voiceId,
      voiceSpeed: 1.0,
      voiceTone: tones.first,
      isActive: true,
      isDefaultInbound: false,
    );
    emit(state.copyWith(isSaving: true, clearError: true, clearFeedback: true));
    try {
      final created = await repository.createScenario(scenario);
      emit(state.copyWith(
        scenarios: [...state.scenarios, created],
        savedScenario: created,
        draft: created.copyWith(),
        isSaving: false,
        feedbackMessage: 'Scenario created.',
        feedbackRevision: state.feedbackRevision + 1,
      ));
    } on AppException catch (error) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: _message(error),
        feedbackMessage: _message(error),
        feedbackRevision: state.feedbackRevision + 1,
      ));
    }
  }

  Future<void> deleteSelected() async {
    final selected = state.savedScenario;
    if (selected == null || state.isBusy) return;
    if (selected.isDefaultInbound) {
      _feedback(
          'Choose another inbound default before deleting this scenario.');
      return;
    }
    if (state.scenarios.length <= 1) {
      _feedback('At least one AI scenario is required.');
      return;
    }
    emit(state.copyWith(
        isDeleting: true, clearError: true, clearFeedback: true));
    try {
      await repository.deleteScenario(selected.id);
      final scenarios = state.scenarios
          .where((scenario) => scenario.id != selected.id)
          .toList(growable: false);
      final next = _preferredScenario(scenarios);
      emit(state.copyWith(
        scenarios: scenarios,
        savedScenario: next,
        draft: next?.copyWith(),
        isDeleting: false,
        feedbackMessage: 'Scenario deleted.',
        feedbackRevision: state.feedbackRevision + 1,
      ));
    } on AppException catch (error) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: _message(error),
        feedbackMessage: _message(error),
        feedbackRevision: state.feedbackRevision + 1,
      ));
    }
  }

  Future<void> previewVoice(String voiceId) async {
    final draft = state.draft;
    if (draft == null || voiceId.isEmpty || state.previewingVoiceId != null) {
      return;
    }
    emit(state.copyWith(
      previewingVoiceId: voiceId,
      clearPreviewAudio: true,
      clearError: true,
    ));
    try {
      final audio = await repository.previewVoice(
        voiceId: voiceId,
        speed: draft.voiceSpeed,
        text: draft.openingGreeting.isEmpty
            ? 'Hi, this is Skyler. How can I help you today?'
            : draft.openingGreeting.replaceAll('{name}', 'there'),
      );
      emit(state.copyWith(
        previewAudio: audio,
        previewRevision: state.previewRevision + 1,
        clearPreviewingVoice: true,
      ));
    } on AppException catch (error) {
      emit(state.copyWith(
        clearPreviewingVoice: true,
        errorMessage: _message(error),
        feedbackMessage: _message(error),
        feedbackRevision: state.feedbackRevision + 1,
      ));
    }
  }

  void _feedback(String message) {
    emit(state.copyWith(
      feedbackMessage: message,
      feedbackRevision: state.feedbackRevision + 1,
    ));
  }

  String? _validate(AiScenario scenario) {
    if (scenario.name.trim().length < 3) return 'Enter a valid scenario name.';
    if (scenario.openingGreeting.trim().isEmpty) {
      return 'Opening greeting cannot be empty.';
    }
    if (scenario.pitchSummary.trim().isEmpty) {
      return 'Business objective cannot be empty.';
    }
    if (scenario.voiceId.isEmpty) return 'Choose an AI voice.';
    if (scenario.isDefaultInbound && !scenario.isActive) {
      return 'The inbound default scenario must stay active.';
    }
    return null;
  }

  String _message(AppException error) {
    if (error.fieldErrors.isNotEmpty) {
      return error.fieldErrors.values.expand((value) => value).join(' ');
    }
    return switch (error.type) {
      AppErrorType.unauthorized =>
        'Your session expired. Please sign in again.',
      AppErrorType.forbidden =>
        'You do not have permission to change AI settings.',
      AppErrorType.network => 'Cannot reach the server. Check your connection.',
      AppErrorType.timeout => 'The server took too long to respond. Try again.',
      AppErrorType.invalidData =>
        'The server returned invalid AI settings data.',
      AppErrorType.validation =>
        'Review the highlighted settings and try again.',
      AppErrorType.server => 'The AI service is temporarily unavailable.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
