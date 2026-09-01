import '../../domain/entities/ai_scenario.dart';

class AiScenarioDto {
  const AiScenarioDto(this.json);

  final Map<String, dynamic> json;

  AiScenario toEntity() => AiScenario(
        id: _string(json['id']),
        name: _string(json['name']),
        category: _string(json['category'], 'Sales & Outreach'),
        openingGreeting: _string(json['openingGreeting']),
        pitchSummary: _string(json['pitchSummary']),
        personalityPrompt: _string(json['personalityPrompt']),
        qualifyingQuestions: (json['qualifyingQuestions'] as List? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
        actionOnInterest: _string(
          json['actionOnInterest'],
          'Send Follow-up Email & Tag as Hot Lead',
        ),
        voiceId: _string(json['cartesiaVoiceId']),
        voiceSpeed: _double(json['voiceSpeed'], 1.0),
        voiceTone: _string(json['voiceTone'], 'Professional & Confident'),
        isActive: _bool(json['isActive'] ?? json['is_active'], true),
        isDefaultInbound: _bool(json['isDefaultInbound'], false),
      );

  static Map<String, dynamic> fromEntity(AiScenario scenario) => {
        'id': scenario.id,
        'name': scenario.name.trim(),
        'category': scenario.category,
        'openingGreeting': scenario.openingGreeting.trim(),
        'pitchSummary': scenario.pitchSummary.trim(),
        'personalityPrompt': scenario.personalityPrompt.trim(),
        'qualifyingQuestions': scenario.qualifyingQuestions
            .map((question) => question.trim())
            .where((question) => question.isNotEmpty)
            .toList(growable: false),
        'actionOnInterest': scenario.actionOnInterest.trim(),
        'cartesiaVoiceId': scenario.voiceId,
        'voiceSpeed': scenario.voiceSpeed,
        'voiceTone': scenario.voiceTone,
        'isActive': scenario.isActive,
        'isDefaultInbound': scenario.isDefaultInbound,
      };
}

class AiVoiceDto {
  const AiVoiceDto(this.json);

  final Map<String, dynamic> json;

  AiVoice toEntity() => AiVoice(
        id: _string(json['id']),
        name: _string(json['name'], 'Unknown voice'),
        language: _string(json['language']),
        locale: _string(json['locale']),
        gender: _string(json['gender']),
        accent: _string(json['accent']),
        tagline: _string(json['tagline']),
        description: _string(json['description']),
      );
}

class AiEngineConfigDto {
  const AiEngineConfigDto(this.json);

  final Map<String, dynamic> json;

  AiEngineConfig toEntity() => AiEngineConfig(
        isConfigured: _bool(json['isConfigured'], false),
        transport: _string(json['transport']),
        agentId: _string(json['agentId']),
        defaultModel: _string(json['defaultModel']),
        defaultVoice: _string(json['defaultVoice']),
      );
}

String _string(Object? value, [String fallback = '']) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _double(Object? value, double fallback) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

bool _bool(Object? value, bool fallback) => value is bool ? value : fallback;
