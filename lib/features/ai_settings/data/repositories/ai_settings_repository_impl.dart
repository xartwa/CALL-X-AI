import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/ai_agent_profile.dart';
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

        Map<String, dynamic> configJson = {};
        List<Map<String, dynamic>> scenarioJson = [];
        Map<String, dynamic> profileJson = {};

        final results = await Future.wait([
          remote.config().catchError((_) => <String, dynamic>{}),
          remote.scenarios().catchError((_) => <Map<String, dynamic>>[]),
          remote.agentProfile().catchError((_) => <String, dynamic>{}),
        ]);

        if (results[0] is Map) {
          configJson = Map<String, dynamic>.from(results[0] as Map);
        }
        if (results[1] is List) {
          scenarioJson = (results[1] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (results[2] is Map) {
          profileJson = Map<String, dynamic>.from(results[2] as Map);
        }

        final rawVoices = configJson['availableVoices'] is List
            ? (configJson['availableVoices'] as List)
            : (profileJson['availableVoices'] is List
                ? (profileJson['availableVoices'] as List)
                : const []);

        var voices = rawVoices
            .whereType<Map>()
            .map((item) =>
                AiVoiceDto(Map<String, dynamic>.from(item)).toEntity())
            .where((voice) => voice.id.isNotEmpty)
            .toList(growable: false);
        if (voices.isEmpty) {
          voices = const [
            AiVoice(
              id: 'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4',
              name: 'Skylar',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Approachable & Natural',
              description:
                  'Approachable American female ideal for customer care and support.',
            ),
            AiVoice(
              id: '9626c31c-bec5-4cca-baa8-f8ba9e84c8bc',
              name: 'Jacqueline',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Reassuring & Empathic',
              description: 'Confident, young adult female for empathic customer support.',
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
              id: 'a33f7a4c-100f-41cf-a1fd-5822e8fc253f',
              name: 'Lauren',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Lively & Expressive',
              description: 'Expressive female voice for narration and creative customer engagement.',
            ),
            AiVoice(
              id: 'f786b574-daa5-4673-aa0c-cbe3e8534c02',
              name: 'Katie',
              language: 'en',
              locale: 'en-US',
              gender: 'feminine',
              accent: 'American',
              tagline: 'Enunciating & Clear',
              description:
                  'Enunciating young adult female for conversational support use cases.',
            ),
          ];

        }
        return AiSettingsBundle(
          config: AiEngineConfigDto(configJson).toEntity(),
          voices: voices,
          scenarios: scenarioJson
              .map((item) => AiScenarioDto(item).toEntity())
              .toList(growable: false),
          profile: AiAgentProfileDto(profileJson).toEntity(),
        );
      });


  @override
  Future<AiAgentProfile> getAgentProfile() => _request(() async {
        final result = await remote.agentProfile();
        return AiAgentProfileDto(result).toEntity();
      });

  @override
  Future<AiAgentProfile> updateAgentProfile(AiAgentProfile profile) =>
      _request(() async {
        final result = await remote.updateAgentProfile(
          AiAgentProfileDto.fromEntity(profile),
        );
        return AiAgentProfileDto(result).toEntity();
      });

  @override
  Future<AiAgentProfile> uploadKnowledgePdf({
    required Uint8List bytes,
    required String fileName,
  }) =>
      _request(() async {
        final result = await remote.uploadKnowledgePdf(
          bytes: bytes,
          fileName: fileName,
        );
        return AiAgentProfileDto(result).toEntity();
      });

  @override
  Future<AiAgentProfile> removeKnowledgePdf() => _request(() async {
        final result = await remote.removeKnowledgePdf();
        return AiAgentProfileDto(result).toEntity();
      });

  @override
  Future<bool> toggleAiStatus([bool? explicit]) =>
      _request(() => remote.toggleAiStatus(explicit));

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

