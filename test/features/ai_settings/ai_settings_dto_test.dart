import 'package:callx_ai/features/ai_settings/data/dto/ai_settings_dto.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_agent_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scenario DTO maps the complete camelCase API contract', () {
    final entity = AiScenarioDto({
      'id': 'scenario-1',
      'name': 'AI Concierge',
      'category': 'Customer Support',
      'openingGreeting': 'Welcome!',
      'pitchSummary': 'Answer customer questions.',
      'personalityPrompt': 'Be thoughtful and concise.',
      'qualifyingQuestions': ['What do you need?'],
      'actionOnInterest': 'Offer a follow-up.',
      'cartesiaVoiceId': 'voice-1',
      'voiceSpeed': 1.15,
      'voiceTone': 'Friendly & Warm',
      'isActive': true,
      'isDefaultInbound': true,
      'cartesiaAgentId': 'agent_Test123',
    }).toEntity();

    expect(entity.personalityPrompt, 'Be thoughtful and concise.');
    expect(entity.voiceSpeed, 1.15);
    expect(entity.voiceId, 'voice-1');
    expect(entity.isDefaultInbound, isTrue);
    expect(entity.cartesiaAgentId, 'agent_Test123');
    expect(entity.isCartesiaSynced, isTrue);

    final json = AiScenarioDto.fromEntity(entity);
    expect(json['personalityPrompt'], 'Be thoughtful and concise.');
    expect(json['voiceSpeed'], 1.15);
    expect(json['isDefaultInbound'], isTrue);
    expect(json['cartesiaAgentId'], 'agent_Test123');
  });

  test('agent prompt and greeting round-trip without trimming or mutation', () {
    const prompt = '  You are Maria.\n\nAsk one question.  ';
    const greeting = '  Hi there.  ';
    const profile = AiAgentProfile(
      name: 'Maria',
      rolePrompt: prompt,
      voiceId: 'voice-1',
      voiceSpeed: 1.05,
      knowledgeText: '',
      knowledgeExtracted: '',
      inboundGreeting: greeting,
      operatingHoursStart: '09:00',
      operatingHoursEnd: '18:00',
      is247: true,
      isAiEnabled: true,
    );

    final json = AiAgentProfileDto.fromEntity(profile);
    expect(json['rolePrompt'], prompt);
    expect(json['inboundGreeting'], greeting);

    final decoded = AiAgentProfileDto({
      ...json,
      'availableVoices': null,
      'availableEmotions': null,
      'knowledgePdfUrl': null,
    }).toEntity();
    expect(decoded.rolePrompt, prompt);
    expect(decoded.inboundGreeting, greeting);
    expect(decoded.availableVoices, isEmpty);
  });
}
