import 'dart:typed_data';

import '../domain/entities/ai_agent_profile.dart';
import '../domain/entities/ai_scenario.dart';

enum AiSettingsStatus { initial, loading, success, failure }

class AiSettingsState {
  const AiSettingsState({
    this.status = AiSettingsStatus.initial,
    this.config,
    this.voices = const [],
    this.scenarios = const [],
    this.savedScenario,
    this.draft,
    this.agentProfile,
    this.agentDraft,
    this.isSaving = false,
    this.isDeleting = false,
    this.isUploadingPdf = false,
    this.previewingVoiceId,
    this.previewAudio,
    this.previewRevision = 0,
    this.errorMessage,
    this.feedbackMessage,
    this.feedbackRevision = 0,
  });

  final AiSettingsStatus status;
  final AiEngineConfig? config;
  final List<AiVoice> voices;
  final List<AiScenario> scenarios;
  final AiScenario? savedScenario;
  final AiScenario? draft;
  final AiAgentProfile? agentProfile;
  final AiAgentProfile? agentDraft;
  final bool isSaving;
  final bool isDeleting;
  final bool isUploadingPdf;
  final String? previewingVoiceId;
  final Uint8List? previewAudio;
  final int previewRevision;
  final String? errorMessage;
  final String? feedbackMessage;
  final int feedbackRevision;

  bool get hasUnsavedChanges =>
      draft != null &&
      savedScenario != null &&
      !draft!.sameContent(savedScenario!);

  bool get hasAgentUnsavedChanges =>
      agentDraft != null &&
      agentProfile != null &&
      !agentDraft!.sameContent(agentProfile!);

  bool get isBusy => isSaving || isDeleting || isUploadingPdf;


  AiVoice? get selectedVoice {
    final id = agentDraft?.voiceId ?? draft?.voiceId;
    for (final voice in voices) {
      if (voice.id == id) return voice;
    }
    return null;
  }

  AiSettingsState copyWith({
    AiSettingsStatus? status,
    AiEngineConfig? config,
    List<AiVoice>? voices,
    List<AiScenario>? scenarios,
    AiScenario? savedScenario,
    AiScenario? draft,
    AiAgentProfile? agentProfile,
    AiAgentProfile? agentDraft,
    bool? isSaving,
    bool? isDeleting,
    bool? isUploadingPdf,
    String? previewingVoiceId,
    Uint8List? previewAudio,
    int? previewRevision,
    String? errorMessage,
    String? feedbackMessage,
    int? feedbackRevision,
    bool clearSelection = false,
    bool clearPreviewingVoice = false,
    bool clearPreviewAudio = false,
    bool clearError = false,
    bool clearFeedback = false,
  }) =>
      AiSettingsState(
        status: status ?? this.status,
        config: config ?? this.config,
        voices: voices ?? this.voices,
        scenarios: scenarios ?? this.scenarios,
        savedScenario:
            clearSelection ? null : savedScenario ?? this.savedScenario,
        draft: clearSelection ? null : draft ?? this.draft,
        agentProfile: agentProfile ?? this.agentProfile,
        agentDraft: agentDraft ?? this.agentDraft,
        isSaving: isSaving ?? this.isSaving,
        isDeleting: isDeleting ?? this.isDeleting,
        isUploadingPdf: isUploadingPdf ?? this.isUploadingPdf,
        previewingVoiceId: clearPreviewingVoice
            ? null
            : previewingVoiceId ?? this.previewingVoiceId,
        previewAudio:
            clearPreviewAudio ? null : previewAudio ?? this.previewAudio,
        previewRevision: previewRevision ?? this.previewRevision,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        feedbackMessage:
            clearFeedback ? null : feedbackMessage ?? this.feedbackMessage,
        feedbackRevision: feedbackRevision ?? this.feedbackRevision,
      );
}

