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
}
