import 'package:dio/dio.dart';
import '../../services/api_provider.dart';

class WorkspaceRemoteDataSource {
  const WorkspaceRemoteDataSource(this.client);
  final DioClient client;

  Future<Map<String, dynamic>> getWorkspaceConfiguration(
      {CancelToken? cancelToken}) async {
    final response = await client.http.get(
      '/customers/workspace-configuration/',
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateWorkspaceConfiguration(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    final response = await client.http.put(
      '/customers/workspace-configuration/',
      data: body,
      cancelToken: cancelToken,
    );
    final data = response.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
