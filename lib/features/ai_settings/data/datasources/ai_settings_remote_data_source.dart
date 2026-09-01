import '../../../../services/api_provider.dart';

class AiSettingsRemoteDataSource {
  const AiSettingsRemoteDataSource(this.client);

  final DioClient client;

  Future<Map<String, dynamic>> config() async => Map<String, dynamic>.from(
        (await client.http.get('/cartesia/config/')).data as Map,
      );

  Future<List<Map<String, dynamic>>> scenarios() async {
    final response = await client.http.get(
      '/scenarios/',
      queryParameters: const {'limit': 100},
    );
    final raw = response.data;
    final items = raw is Map ? raw['results'] : raw;
    if (items is! List) throw const FormatException('Invalid scenario list');
    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> createScenario(
    Map<String, dynamic> body,
  ) async =>
      Map<String, dynamic>.from(
        (await client.http.post('/scenarios/', data: body)).data as Map,
      );

  Future<Map<String, dynamic>> updateScenario(
    String id,
    Map<String, dynamic> body,
  ) async =>
      Map<String, dynamic>.from(
        (await client.http.patch('/scenarios/$id/', data: body)).data as Map,
      );

  Future<void> deleteScenario(String id) async {
    await client.http.delete('/scenarios/$id/');
  }

  Future<String> previewVoice(Map<String, dynamic> body) async {
    final response =
        await client.http.post('/cartesia/preview-voice/', data: body);
    final data = Map<String, dynamic>.from(response.data as Map);
    final audio = data['audioBase64']?.toString() ?? '';
    if (audio.isEmpty) throw const FormatException('Missing preview audio');
    return audio;
  }
}
