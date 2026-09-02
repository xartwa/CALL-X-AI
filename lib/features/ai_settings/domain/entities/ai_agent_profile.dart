import 'ai_scenario.dart';

class AiAgentProfile {
  const AiAgentProfile({
    required this.name,
    required this.rolePrompt,
    required this.voiceId,
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
  });

  final String name;
  final String rolePrompt;
  final String voiceId;
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

  AiAgentProfile copyWith({
    String? name,
    String? rolePrompt,
    String? voiceId,
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
  }) =>
      AiAgentProfile(
        name: name ?? this.name,
        rolePrompt: rolePrompt ?? this.rolePrompt,
        voiceId: voiceId ?? this.voiceId,
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
      );

  bool sameContent(AiAgentProfile other) =>
      name == other.name &&
      rolePrompt == other.rolePrompt &&
      voiceId == other.voiceId &&
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
