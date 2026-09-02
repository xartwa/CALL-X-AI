import 'ai_scenario.dart';

class AiVoiceEmotion {
  const AiVoiceEmotion({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiVoiceEmotion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AiAgentProfile {
  const AiAgentProfile({
    required this.name,
    required this.rolePrompt,
    required this.voiceId,
    this.voiceEmotion = 'calm',
    required this.voiceSpeed,
    required this.knowledgeText,
    this.knowledgePdfUrl,
    this.knowledgePdfName,
    required this.knowledgeExtracted,
    required this.inboundGreeting,
    required this.operatingHoursStart,
    required this.operatingHoursEnd,
    required this.is247,
    required this.isAiEnabled,
    this.availableVoices = const [],
    this.availableEmotions = const [],
  });

  final String name;
  final String rolePrompt;
  final String voiceId;
  final String voiceEmotion;
  final double voiceSpeed;
  final String knowledgeText;
  final String? knowledgePdfUrl;
  final String? knowledgePdfName;
  final String knowledgeExtracted;
  final String inboundGreeting;
  final String operatingHoursStart;
  final String operatingHoursEnd;
  final bool is247;
  final bool isAiEnabled;
  final List<AiVoice> availableVoices;
  final List<AiVoiceEmotion> availableEmotions;

  AiAgentProfile copyWith({
    String? name,
    String? rolePrompt,
    String? voiceId,
    String? voiceEmotion,
    double? voiceSpeed,
    String? knowledgeText,
    String? knowledgePdfUrl,
    String? knowledgePdfName,
    String? knowledgeExtracted,
    String? inboundGreeting,
    String? operatingHoursStart,
    String? operatingHoursEnd,
    bool? is247,
    bool? isAiEnabled,
    List<AiVoice>? availableVoices,
    List<AiVoiceEmotion>? availableEmotions,
  }) =>
      AiAgentProfile(
        name: name ?? this.name,
        rolePrompt: rolePrompt ?? this.rolePrompt,
        voiceId: voiceId ?? this.voiceId,
        voiceEmotion: voiceEmotion ?? this.voiceEmotion,
        voiceSpeed: voiceSpeed ?? this.voiceSpeed,
        knowledgeText: knowledgeText ?? this.knowledgeText,
        knowledgePdfUrl: knowledgePdfUrl ?? this.knowledgePdfUrl,
        knowledgePdfName: knowledgePdfName ?? this.knowledgePdfName,
        knowledgeExtracted: knowledgeExtracted ?? this.knowledgeExtracted,
        inboundGreeting: inboundGreeting ?? this.inboundGreeting,
        operatingHoursStart: operatingHoursStart ?? this.operatingHoursStart,
        operatingHoursEnd: operatingHoursEnd ?? this.operatingHoursEnd,
        is247: is247 ?? this.is247,
        isAiEnabled: isAiEnabled ?? this.isAiEnabled,
        availableVoices: availableVoices ?? this.availableVoices,
        availableEmotions: availableEmotions ?? this.availableEmotions,
      );

  bool sameContent(AiAgentProfile other) =>
      name == other.name &&
      rolePrompt == other.rolePrompt &&
      voiceId == other.voiceId &&
      voiceEmotion == other.voiceEmotion &&
      voiceSpeed == other.voiceSpeed &&
      knowledgeText == other.knowledgeText &&
      knowledgePdfUrl == other.knowledgePdfUrl &&
      knowledgePdfName == other.knowledgePdfName &&
      inboundGreeting == other.inboundGreeting &&
      operatingHoursStart == other.operatingHoursStart &&
      operatingHoursEnd == other.operatingHoursEnd &&
      is247 == other.is247 &&
      isAiEnabled == other.isAiEnabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiAgentProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          rolePrompt == other.rolePrompt &&
          voiceId == other.voiceId &&
          voiceEmotion == other.voiceEmotion &&
          voiceSpeed == other.voiceSpeed &&
          knowledgeText == other.knowledgeText &&
          knowledgePdfUrl == other.knowledgePdfUrl &&
          knowledgePdfName == other.knowledgePdfName &&
          knowledgeExtracted == other.knowledgeExtracted &&
          inboundGreeting == other.inboundGreeting &&
          operatingHoursStart == other.operatingHoursStart &&
          operatingHoursEnd == other.operatingHoursEnd &&
          is247 == other.is247 &&
          isAiEnabled == other.isAiEnabled;

  @override
  int get hashCode => Object.hash(
        name,
        rolePrompt,
        voiceId,
        voiceEmotion,
        voiceSpeed,
        knowledgeText,
        knowledgePdfUrl,
        knowledgePdfName,
        knowledgeExtracted,
        inboundGreeting,
        operatingHoursStart,
        operatingHoursEnd,
        is247,
        isAiEnabled,
      );
}

