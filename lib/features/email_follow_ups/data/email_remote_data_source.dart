import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:callx_ai/services/api_provider.dart';

class EmailRemoteDataSource {
  const EmailRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<Map<String, dynamic>>> getLogs() => _getAll('/emails/logs/');

  Future<List<Map<String, dynamic>>> getTemplates() =>
      _getAll('/emails/templates/');

  Future<List<Map<String, dynamic>>> getSenderAccounts() =>
      _getAll('/emails/senders/');

  Future<Map<String, dynamic>> createSenderAccount(
    Map<String, dynamic> body,
  ) async =>
      Map<String, dynamic>.from(
        (await _client.http.post('/emails/senders/', data: body)).data as Map,
      );

  Future<Map<String, dynamic>> send(
    Map<String, dynamic> body, {
    List<PlatformFile>? attachments,
  }) async {
    dynamic payload;
    if (attachments != null && attachments.isNotEmpty) {
      final map = Map<String, dynamic>.from(body);
      final files = <MultipartFile>[];
      for (final file in attachments) {
        if (file.bytes != null) {
          files.add(MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ));
        } else if (file.path != null) {
          files.add(await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ));
        }
      }
      map['attachments'] = files;
      payload = FormData.fromMap(map);
    } else {
      payload = body;
    }

    final response = await _client.http.post('/emails/logs/send/', data: payload);
    final data = Map<String, dynamic>.from(response.data as Map);
    return Map<String, dynamic>.from(data['email'] as Map);
  }

  Future<Map<String, dynamic>> createTemplate(
    Map<String, dynamic> body,
  ) async =>
      Map<String, dynamic>.from(
        (await _client.http.post('/emails/templates/', data: body)).data as Map,
      );

  Future<Map<String, dynamic>> updateTemplate(
    String id,
    Map<String, dynamic> body,
  ) async =>
      Map<String, dynamic>.from(
        (await _client.http.patch('/emails/templates/$id/', data: body)).data
            as Map,
      );

  Future<void> deleteTemplate(String id) async {
    await _client.http.delete('/emails/templates/$id/');
  }

  Future<void> deleteLog(String id) async {
    await _client.http.delete('/emails/logs/$id/');
  }

  Future<List<Map<String, dynamic>>> _getAll(String path) async {
    final items = <Map<String, dynamic>>[];
    final visited = <String>{};
    String? next = path;
    var firstRequest = true;
    while (next != null && visited.add(next)) {
      final response = await _client.http.get(
        next,
        queryParameters: firstRequest ? const {'limit': 100} : null,
      );
      firstRequest = false;
      items.addAll(_list(response.data));
      final data = response.data;
      next =
          data is Map && data['next'] != null ? data['next'].toString() : null;
    }
    return items;
  }

  List<Map<String, dynamic>> _list(Object? raw) {
    final items = raw is Map ? raw['results'] : raw;
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
