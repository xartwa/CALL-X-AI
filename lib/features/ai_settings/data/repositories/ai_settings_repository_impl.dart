import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/ai_scenario.dart';
import '../../domain/repositories/ai_settings_repository.dart';
import '../datasources/ai_settings_remote_data_source.dart';
import '../dto/ai_settings_dto.dart';

class AiSettingsRepositoryImpl implements AiSettingsRepository {
  const AiSettingsRepositoryImpl(this.remote);

  final AiSettingsRemoteDataSource remote;

  Future<T> _request<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

  @override
  Future<AiSettingsBundle> loadSettings() => _request(() async {
        final responses =
            await Future.wait([remote.config(), remote.scenarios()]);
        final configJson = responses[0] as Map<String, dynamic>;
        final scenarioJson = responses[1] as List<Map<String, dynamic>>;
        final voices = (configJson['availableVoices'] as List? ?? const [])
            .whereType<Map>()
            .map((item) =>
                AiVoiceDto(Map<String, dynamic>.from(item)).toEntity())
            .where((voice) => voice.id.isNotEmpty)
            .toList(growable: false);
        return AiSettingsBundle(
          config: AiEngineConfigDto(configJson).toEntity(),
          voices: voices,
          scenarios: scenarioJson
              .map((item) => AiScenarioDto(item).toEntity())
              .toList(growable: false),
        );
      });

  @override
  Future<AiScenario> createScenario(AiScenario scenario) => _request(() async {
        final result = await remote.createScenario(
          AiScenarioDto.fromEntity(scenario),
        );
        return AiScenarioDto(result).toEntity();
      });

  @override
  Future<AiScenario> updateScenario(AiScenario scenario) => _request(() async {
        final body = AiScenarioDto.fromEntity(scenario)..remove('id');
        final result = await remote.updateScenario(scenario.id, body);
        return AiScenarioDto(result).toEntity();
      });

  @override
  Future<void> deleteScenario(String id) =>
      _request(() => remote.deleteScenario(id));

  @override
  Future<Uint8List> previewVoice({
    required String voiceId,
    required double speed,
    required String text,
  }) =>
      _request(() async {
        final encoded = await remote.previewVoice({
          'voiceId': voiceId,
          'voiceSpeed': speed,
          'text': text,
        });
        return base64Decode(encoded);
      });
}
