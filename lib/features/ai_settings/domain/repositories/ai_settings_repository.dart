import 'dart:typed_data';

import '../entities/ai_scenario.dart';

abstract class AiSettingsRepository {
  Future<AiSettingsBundle> loadSettings();

  Future<AiScenario> createScenario(AiScenario scenario);

  Future<AiScenario> updateScenario(AiScenario scenario);

  Future<void> deleteScenario(String id);

  Future<Uint8List> previewVoice({
    required String voiceId,
    required double speed,
    required String text,
  });
}
