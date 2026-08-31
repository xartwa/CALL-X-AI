import '../../../../services/api_provider.dart';

class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._client);

  final DioClient _client;

  Future<Map<String, dynamic>> getSnapshot() async {
    final response = await _client.http.get('/dashboard/stats/');
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Dashboard response is not an object');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> getTodos() async {
    final response = await _client.http.get('/dashboard/todos/');
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createTodo(String text) async {
    final response = await _client.http.post(
      '/dashboard/todos/',
      data: {'text': text, 'isCompleted': false},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateTodo(String id,
      {bool? isCompleted, String? text}) async {
    final response = await _client.http.patch(
      '/dashboard/todos/$id/',
      data: {
        if (isCompleted != null) 'isCompleted': isCompleted,
        if (text != null) 'text': text,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteTodo(String id) async {
    await _client.http.delete('/dashboard/todos/$id/');
  }
}

