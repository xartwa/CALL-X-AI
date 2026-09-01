import 'package:callx_ai/features/ai_settings/data/dto/ai_settings_dto.dart';
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
    }).toEntity();

    expect(entity.personalityPrompt, 'Be thoughtful and concise.');
    expect(entity.voiceSpeed, 1.15);
    expect(entity.voiceId, 'voice-1');
    expect(entity.isDefaultInbound, isTrue);

    final json = AiScenarioDto.fromEntity(entity);
    expect(json['personalityPrompt'], 'Be thoughtful and concise.');
    expect(json['voiceSpeed'], 1.15);
    expect(json['isDefaultInbound'], isTrue);
  });
}
