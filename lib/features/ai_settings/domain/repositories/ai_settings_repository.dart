import 'dart:typed_data';

import '../entities/ai_agent_profile.dart';
import '../entities/ai_scenario.dart';

abstract class AiSettingsRepository {
  Future<AiSettingsBundle> loadSettings();

  Future<AiAgentProfile> getAgentProfile();

  Future<AiAgentProfile> updateAgentProfile(AiAgentProfile profile);

  Future<AiAgentProfile> uploadKnowledgePdf({
    required Uint8List bytes,
    required String fileName,
    void Function(double progress)? onProgress,
  });

  Future<AiAgentProfile> removeKnowledgePdf();

  Future<bool> toggleAiStatus([bool? explicit]);

  Future<AiScenario> createScenario(AiScenario scenario);

  Future<AiScenario> updateScenario(AiScenario scenario);

  Future<void> deleteScenario(String id);

  Future<Uint8List> previewVoice({
    required String voiceId,
    required double speed,
    required String text,
    String? emotion,
  });
}


