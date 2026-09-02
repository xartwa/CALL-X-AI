import 'dart:typed_data';

import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_agent_profile.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';

import 'package:callx_ai/features/ai_settings/domain/repositories/ai_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiSettingsCubit', () {
    late _FakeAiSettingsRepository repository;
    late AiSettingsCubit cubit;

    setUp(() {
      repository = _FakeAiSettingsRepository();
      cubit = AiSettingsCubit(repository);
    });

    tearDown(() => cubit.close());

    test('loads server data and selects the inbound default', () async {
      await cubit.load();

      expect(cubit.state.status, AiSettingsStatus.success);
      expect(cubit.state.draft?.id, 'inbound');
      expect(cubit.state.selectedVoice?.name, 'Skyler');
      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('saves personality voice and speed through repository', () async {
      await cubit.load();
      cubit.updateDraft(
        (current) => current.copyWith(
          personalityPrompt: 'Be energetic and empathetic.',
          voiceSpeed: 1.2,
          voiceId: 'voice-alt',
        ),
      );

      expect(cubit.state.hasUnsavedChanges, isTrue);
      await cubit.save();

      expect(repository.updated?.personalityPrompt,
          'Be energetic and empathetic.');
      expect(repository.updated?.voiceSpeed, 1.2);
      expect(repository.updated?.voiceId, 'voice-alt');
      expect(cubit.state.hasUnsavedChanges, isFalse);
    });

    test('voice preview returns playable bytes and clears busy state',
        () async {
      await cubit.load();

      await cubit.previewVoice('voice-skyler');

      expect(cubit.state.previewAudio, Uint8List.fromList([1, 2, 3]));
      expect(cubit.state.previewRevision, 1);
      expect(cubit.state.previewingVoiceId, isNull);
    });

    test('updates and saves agent profile successfully', () async {
      await cubit.load();
      expect(cubit.state.agentProfile?.name, 'CallX Assistant');

      cubit.updateAgentDraft(
        (current) => current.copyWith(
          rolePrompt: 'You are Nova, luxury receptionist.',
          knowledgeText: 'We build high-end AI assistants.',
          is247: false,
        ),
      );

      expect(cubit.state.hasAgentUnsavedChanges, isTrue);
      final saved = await cubit.saveAgentProfile();

      expect(saved, isTrue);
      expect(cubit.state.agentProfile?.rolePrompt,
          'You are Nova, luxury receptionist.');
      expect(cubit.state.hasAgentUnsavedChanges, isFalse);
    });

    test('uploads and removes knowledge PDF', () async {
      await cubit.load();
      final uploaded = await cubit.uploadKnowledgePdf(
        Uint8List.fromList([1, 2, 3, 4]),
        'company_handbook.pdf',
      );

      expect(uploaded, isTrue);
      expect(cubit.state.agentProfile?.knowledgePdfName,
          'company_handbook.pdf');

      final removed = await cubit.removeKnowledgePdf();
      expect(removed, isTrue);
      expect(cubit.state.agentProfile?.knowledgePdfName, '');
    });

    test('toggles AI live status', () async {
      await cubit.load();
      final status = await cubit.toggleAiStatus(false);
      expect(status, isFalse);
      expect(cubit.state.agentProfile?.isAiEnabled, isFalse);
    });
  });
}


class _FakeAiSettingsRepository implements AiSettingsRepository {
  AiScenario? updated;

  static const voices = [
    AiVoice(
      id: 'voice-skyler',
      name: 'Skyler',
      language: 'en',
      locale: 'en-US',
      gender: 'female',
      accent: 'American',
      tagline: 'Friendly and energetic',
      description: '',
    ),
    AiVoice(
      id: 'voice-alt',
      name: 'Alternative',
      language: 'en',
      locale: 'en-US',
      gender: '',
      accent: '',
      tagline: '',
      description: '',
    ),
  ];

  static const inbound = AiScenario(
    id: 'inbound',
    name: 'Inbound concierge',
    category: 'Customer Support',
    openingGreeting: 'Hi, this is Skyler.',
    pitchSummary: 'Help every caller.',
    personalityPrompt: 'Be warm and concise.',
    qualifyingQuestions: ['How can I help?'],
    actionOnInterest: 'Offer a follow-up.',
    voiceId: 'voice-skyler',
    voiceSpeed: 1.0,
    voiceTone: 'Friendly & Warm',
    isActive: true,
    isDefaultInbound: true,
  );

  @override
  Future<AiSettingsBundle> loadSettings() async => const AiSettingsBundle(
        config: AiEngineConfig(
          isConfigured: true,
          transport: 'cartesia-line',
          agentId: 'agent-test',
          defaultModel: 'sonic-3.5',
          defaultVoice: 'voice-skyler',
        ),
        voices: voices,
        scenarios: [inbound],
        profile: defaultProfile,
      );

  static const defaultProfile = AiAgentProfile(
    name: 'CallX Assistant',
    rolePrompt: 'You are a polite, helpful receptionist.',
    voiceId: 'voice-skyler',
    voiceSpeed: 1.05,
    knowledgeText: 'CallX AI builds custom voice solutions.',
    knowledgeExtracted: '',
    inboundGreeting: 'Thank you for calling CallX AI Headquarters.',
    operatingHoursStart: '09:00',
    operatingHoursEnd: '18:00',
    is247: true,

    isAiEnabled: true,
  );

  @override
  Future<AiAgentProfile> getAgentProfile() async => defaultProfile;

  @override
  Future<AiAgentProfile> updateAgentProfile(AiAgentProfile profile) async =>
      profile;

  @override
  Future<AiAgentProfile> uploadKnowledgePdf({
    required Uint8List bytes,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    onProgress?.call(1.0);
    return defaultProfile.copyWith(knowledgePdfName: fileName);
  }

  @override
  Future<AiAgentProfile> removeKnowledgePdf() async =>
      defaultProfile.copyWith(knowledgePdfName: '');

  @override
  Future<bool> toggleAiStatus([bool? explicit]) async => explicit ?? false;

  @override
  Future<AiScenario> updateScenario(AiScenario scenario) async {
    updated = scenario;
    return scenario;
  }

  @override
  Future<Uint8List> previewVoice({
    required String voiceId,
    required double speed,
    required String text,
    String? emotion,
  }) async =>
      Uint8List.fromList([1, 2, 3]);


  @override
  Future<AiScenario> createScenario(AiScenario scenario) async => scenario;

  @override
  Future<void> deleteScenario(String id) async {}
}

