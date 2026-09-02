import '../../domain/entities/ai_agent_profile.dart';
import '../../domain/entities/ai_scenario.dart';

class AiScenarioDto {
  const AiScenarioDto(this.json);

  final Map<String, dynamic> json;

  AiScenario toEntity() => AiScenario(
        id: _string(json['id']),
        name: _string(json['name'], 'Untitled Scenario'),
        category: _string(json['category'], 'Sales & Outreach'),
        openingGreeting: _string(
          json['openingGreeting'] ?? json['opening_greeting'],
          'Hi there! How can I help you today?',
        ),
        pitchSummary: _string(json['pitchSummary'] ?? json['pitch_summary']),
        personalityPrompt: _string(json['personalityPrompt'] ?? json['personality_prompt']),
        qualifyingQuestions: _stringList(json['qualifyingQuestions'] ?? json['qualifying_questions']),
        actionOnInterest: _string(
          json['actionOnInterest'] ?? json['action_on_interest'],
          'Send Follow-up Email & Tag as Hot Lead',
        ),
        voiceId: _string(
          json['cartesiaVoiceId'] ?? json['voiceId'] ?? json['cartesia_voice_id'],
          'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4',
        ),
        voiceSpeed: _double(json['voiceSpeed'] ?? json['voice_speed'], 1.05),
        voiceTone: _string(json['voiceTone'] ?? json['voice_tone'], 'Professional & Confident'),
        isActive: _bool(json['isActive'] ?? json['is_active'], true),
        isDefaultInbound: _bool(json['isDefaultInbound'] ?? json['is_default_inbound'], false),
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
        isConfigured: _bool(json['isConfigured'] ?? json['is_configured'], false),
        transport: _string(json['transport'], 'Cartesia Line'),
        agentId: _string(json['agentId'] ?? json['agent_id']),
        defaultModel: _string(json['defaultModel'] ?? json['default_model'], 'Sonic 3.5'),
        defaultVoice: _string(
          json['defaultVoice'] ?? json['default_voice'],
          'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4',
        ),
      );
}

class AiAgentProfileDto {
  const AiAgentProfileDto(this.json);

  final Map<String, dynamic> json;

  AiAgentProfile toEntity() {
    final rawVoices = json['availableVoices'] ?? json['available_voices'];
    final List voicesJson = rawVoices is List ? rawVoices : const [];
    final voices = voicesJson
        .whereType<Map>()
        .map((m) => AiVoiceDto(Map<String, dynamic>.from(m)).toEntity())
        .toList(growable: false);

    final rawEmotions = json['availableEmotions'] ?? json['available_emotions'];
    final List emotionsJson = rawEmotions is List ? rawEmotions : const [];
    var emotions = emotionsJson
        .whereType<Map>()
        .map((m) => AiVoiceEmotion(
              id: _string(m['id']),
              label: _string(m['label']),
              emoji: _string(m['emoji']),
            ))
        .where((e) => e.id.isNotEmpty)
        .toList(growable: false);

    if (emotions.isEmpty) {
      emotions = const [
        AiVoiceEmotion(id: 'neutral', label: 'Neutral', emoji: '😐'),
        AiVoiceEmotion(id: 'calm', label: 'Calm', emoji: '😌'),
        AiVoiceEmotion(id: 'content', label: 'Content', emoji: '😊'),
        AiVoiceEmotion(id: 'excited', label: 'Excited', emoji: '🤩'),
        AiVoiceEmotion(id: 'sad', label: 'Sad', emoji: '😢'),
        AiVoiceEmotion(id: 'angry', label: 'Angry', emoji: '😡'),
        AiVoiceEmotion(id: 'scared', label: 'Scared', emoji: '😨'),
      ];
    }

    return AiAgentProfile(
      name: _string(json['name'], 'Maria'),
      rolePrompt: _string(
        json['rolePrompt'] ?? json['role_prompt'],
        'You are Maria, a professional AI communication representative for Dynamica Design & Advertising.',
      ),
      voiceId: _string(
        json['voiceId'] ?? json['voice_id'],
        'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4',
      ),
      voiceEmotion: _string(
        json['voiceEmotion'] ?? json['voice_emotion'],
        'calm',
      ),
      voiceSpeed: _double(json['voiceSpeed'] ?? json['voice_speed'], 1.05),
      knowledgeText: _string(json['knowledgeText'] ?? json['knowledge_text']),
      knowledgePdfUrl: (json['knowledgePdfUrl'] ?? json['knowledge_pdf_url'] ?? json['knowledge_pdf'])?.toString(),
      knowledgePdfName: (json['knowledgePdfName'] ?? json['knowledge_pdf_name'])?.toString(),
      knowledgeExtracted: _string(json['knowledgeExtracted'] ?? json['knowledge_extracted']),
      inboundGreeting: _string(
        json['inboundGreeting'] ?? json['inbound_greeting'],
        "Hello! You've reached Dynamica Design & Advertising, this is Maria. How may I help you today?",
      ),
      operatingHoursStart: _string(json['operatingHoursStart'] ?? json['operating_hours_start'], '09:00'),
      operatingHoursEnd: _string(json['operatingHoursEnd'] ?? json['operating_hours_end'], '18:00'),
      is247: _bool(json['is247'] ?? json['is_24_7'], true),
      isAiEnabled: _bool(json['isAiEnabled'] ?? json['is_ai_enabled'], true),
      availableVoices: voices,
      availableEmotions: emotions,
    );
  }

  static Map<String, dynamic> fromEntity(AiAgentProfile profile) => {
        'name': profile.name.trim(),
        'rolePrompt': profile.rolePrompt.trim(),
        'voiceId': profile.voiceId,
        'voiceEmotion': profile.voiceEmotion,
        'voiceSpeed': profile.voiceSpeed,
        'knowledgeText': profile.knowledgeText.trim(),
        'inboundGreeting': profile.inboundGreeting.trim(),
        'operatingHoursStart': profile.operatingHoursStart,
        'operatingHoursEnd': profile.operatingHoursEnd,
        'is247': profile.is247,
        'isAiEnabled': profile.isAiEnabled,
      };

}

String _string(Object? value, [String fallback = '']) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _double(Object? value, double fallback) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

bool _bool(Object? value, bool fallback) => value is bool ? value : fallback;

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList(growable: false);
  }
  if (value is String && value.isNotEmpty) {
    return value.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(growable: false);
  }
  return const [];
}
