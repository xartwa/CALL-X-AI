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
        final scenarioJson = (responses[1] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final rawVoices =
            (configJson['availableVoices'] as List? ?? const []);

        var voices = rawVoices
            .whereType<Map>()
            .map((item) =>
                AiVoiceDto(Map<String, dynamic>.from(item)).toEntity())
            .where((voice) => voice.id.isNotEmpty)
            .toList(growable: false);
        if (voices.isEmpty) {
          voices = const [
            AiVoice(
              id: '01fd7d67-d2a0-4e4e-8c48-42611c71a926',
              name: 'Skyler',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Easygoing & Approachable',
              description:
                  'Natural, effortless, friendly conversational cadence.',
            ),
            AiVoice(
              id: '694f9389-aac1-45b6-b726-9d9369183238',
              name: 'Sarah',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Soothing & Warm',
              description: 'Calm, natural, and friendly conversational tone.',
            ),
            AiVoice(
              id: 'f6ff7c0c-e396-40a9-a70b-f7607edb6937',
              name: 'Emma',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Casual & Relatable',
              description:
                  'Approachable and natural voice for customer support.',
            ),
            AiVoice(
              id: 'f786b574-daa5-4673-aa0c-cbe3e8534c02',
              name: 'Katie',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Upbeat & Enunciating',
              description:
                  'Clear, enthusiastic, and articulate young adult female.',
            ),
          ];
        }
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
