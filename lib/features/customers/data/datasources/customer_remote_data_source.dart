import 'package:dio/dio.dart';
import '../../../../services/api_provider.dart';

class CustomerRemoteDataSource {
  const CustomerRemoteDataSource(this.client);
  final DioClient client;

  Future<dynamic> list(Map<String, dynamic> query,
          {CancelToken? cancelToken}) =>
      client.http
          .get('/customers/', queryParameters: query, cancelToken: cancelToken)
          .then((r) => r.data);
  Future<Map<String, dynamic>> detail(String id) async =>
      Map<String, dynamic>.from(
          (await client.http.get('/customers/$id/')).data as Map);
  Future<Map<String, dynamic>> kpi() async => Map<String, dynamic>.from(
      (await client.http.get('/customers/kpi/')).data as Map);
  Future<Map<String, dynamic>> options(
          {String? country, String? state}) async =>
      Map<String, dynamic>.from((await client.http.get('/customers/options/',
              queryParameters: {
            if (country != null) 'country': country,
            if (state != null) 'state': state
          }))
          .data as Map);
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(
          (await client.http.post('/customers/', data: body)).data as Map);
  Future<Map<String, dynamic>> update(
          String id, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(
          (await client.http.patch('/customers/$id/', data: body)).data as Map);
  Future<void> delete(String id) async {
    await client.http.delete('/customers/$id/');
  }

  Future<Map<String, dynamic>> note(
          String id, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(
          (await client.http.post('/customers/$id/notes/', data: body)).data
              as Map);
  Future<Map<String, dynamic>> noteUpdate(
          String id, String noteId, Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(
          (await client.http.patch('/customers/$id/notes/$noteId/', data: body))
              .data as Map);
  Future<void> noteDelete(String id, String noteId) async {
    await client.http.delete('/customers/$id/notes/$noteId/');
  }

  Future<List<String>> tag(
    String id, {
    String? label,
    int? tagId,
    String color = '#6366F1',
    bool remove = false,
  }) async {
    final Map<String, dynamic> body = {};
    if (tagId != null && tagId > 0) {
      body['tagId'] = tagId;
    } else if (label != null && label.trim().isNotEmpty) {
      body['label'] = label.trim();
      body['color'] = color;
    }

    final response = await client.http.request(
      '/customers/$id/tags/',
      options: Options(method: remove ? 'DELETE' : 'POST'),
      data: body,
    );
    final data = response.data;
    if (data is Map && data['tags'] is List) {
      return List<String>.from(
          (data['tags'] as List).map((e) => e.toString()));
    }
    if (data is List) {
      return List<String>.from(data.map((e) => e.toString()));
    }
    return <String>[];
  }

  Future<Map<String, dynamic>> importFile(
          List<int> bytes, String fileName) async =>
      Map<String, dynamic>.from((await client.http.post('/customers/import/',
              data: FormData.fromMap({
                'file': MultipartFile.fromBytes(bytes, filename: fileName),
              })))
          .data as Map);
  Future<List<int>> exportFile(Map<String, dynamic> query) async {
    final response = await client.http.get(
      '/customers/export/',
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );
    return List<int>.from(response.data as List);
  }

  Future<void> dispatchCall(String customerId, String scenarioId,
      {DateTime? scheduledFor}) async {
    await client.http.post('/calls/dispatch-single/', data: {
      'customerId': customerId,
      'scenarioId': scenarioId,
      if (scheduledFor != null) 'scheduledFor': scheduledFor.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> scenarios() async {
    final response = await client.http.get('/scenarios/');
    final data = response.data is Map
        ? (response.data as Map)['results']
        : response.data;
    return (data as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> uploadDocument(String customerId, String path,
      {ProgressCallback? onProgress}) async {
    final response = await client.http.post(
      '/customers/$customerId/documents/',
      data: FormData.fromMap({'file': await MultipartFile.fromFile(path)}),
      onSendProgress: onProgress,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteDocument(String customerId, String documentId) async {
    await client.http.delete('/customers/$customerId/documents/$documentId/');
  }
}
