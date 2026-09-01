class AiScenario {
  const AiScenario({
    required this.id,
    required this.name,
    required this.category,
    required this.openingGreeting,
    required this.pitchSummary,
    required this.personalityPrompt,
    required this.qualifyingQuestions,
    required this.actionOnInterest,
    required this.voiceId,
    required this.voiceSpeed,
    required this.voiceTone,
    required this.isActive,
    required this.isDefaultInbound,
  });

  final String id;
  final String name;
  final String category;
  final String openingGreeting;
  final String pitchSummary;
  final String personalityPrompt;
  final List<String> qualifyingQuestions;
  final String actionOnInterest;
  final String voiceId;
  final double voiceSpeed;
  final String voiceTone;
  final bool isActive;
  final bool isDefaultInbound;

  AiScenario copyWith({
    String? id,
    String? name,
    String? category,
    String? openingGreeting,
    String? pitchSummary,
    String? personalityPrompt,
    List<String>? qualifyingQuestions,
    String? actionOnInterest,
    String? voiceId,
    double? voiceSpeed,
    String? voiceTone,
    bool? isActive,
    bool? isDefaultInbound,
  }) =>
      AiScenario(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        openingGreeting: openingGreeting ?? this.openingGreeting,
        pitchSummary: pitchSummary ?? this.pitchSummary,
        personalityPrompt: personalityPrompt ?? this.personalityPrompt,
        qualifyingQuestions:
            qualifyingQuestions ?? List<String>.from(this.qualifyingQuestions),
        actionOnInterest: actionOnInterest ?? this.actionOnInterest,
        voiceId: voiceId ?? this.voiceId,
        voiceSpeed: voiceSpeed ?? this.voiceSpeed,
        voiceTone: voiceTone ?? this.voiceTone,
        isActive: isActive ?? this.isActive,
        isDefaultInbound: isDefaultInbound ?? this.isDefaultInbound,
      );

  bool sameContent(AiScenario other) =>
      id == other.id &&
      name == other.name &&
      category == other.category &&
      openingGreeting == other.openingGreeting &&
      pitchSummary == other.pitchSummary &&
      personalityPrompt == other.personalityPrompt &&
      _sameList(qualifyingQuestions, other.qualifyingQuestions) &&
      actionOnInterest == other.actionOnInterest &&
      voiceId == other.voiceId &&
      voiceSpeed == other.voiceSpeed &&
      voiceTone == other.voiceTone &&
      isActive == other.isActive &&
      isDefaultInbound == other.isDefaultInbound;

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

class AiVoice {
  const AiVoice({
    required this.id,
    required this.name,
    required this.language,
    required this.locale,
    required this.gender,
    required this.accent,
    required this.tagline,
    required this.description,
  });

  final String id;
  final String name;
  final String language;
  final String locale;
  final String gender;
  final String accent;
  final String tagline;
  final String description;

  String get subtitle {
    final parts = [
      if (gender.isNotEmpty) gender,
      if (locale.isNotEmpty) locale else if (language.isNotEmpty) language,
      if (accent.isNotEmpty) accent,
    ];
    return parts.join(' • ');
  }
}

class AiEngineConfig {
  const AiEngineConfig({
    required this.isConfigured,
    required this.transport,
    required this.agentId,
    required this.defaultModel,
    required this.defaultVoice,
  });

  final bool isConfigured;
  final String transport;
  final String agentId;
  final String defaultModel;
  final String defaultVoice;
}

class AiSettingsBundle {
  const AiSettingsBundle({
    required this.config,
    required this.voices,
    required this.scenarios,
  });

  final AiEngineConfig config;
  final List<AiVoice> voices;
  final List<AiScenario> scenarios;
}
