import 'dart:typed_data';

import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
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
      );

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
  }) async =>
      Uint8List.fromList([1, 2, 3]);

  @override
  Future<AiScenario> createScenario(AiScenario scenario) async => scenario;

  @override
  Future<void> deleteScenario(String id) async {}
}
