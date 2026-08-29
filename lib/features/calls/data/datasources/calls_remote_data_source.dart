import 'package:dio/dio.dart';
import '../../../../services/api_provider.dart';

class CallsRemoteDataSource {
  const CallsRemoteDataSource(this.client);
  final DioClient client;

  Future<dynamic> list(Map<String, dynamic> query,
          {CancelToken? cancelToken}) =>
      client.http
          .get('/calls/', queryParameters: query, cancelToken: cancelToken)
          .then((r) => r.data);

  Future<Map<String, dynamic>> stats({CancelToken? cancelToken}) async =>
      Map<String, dynamic>.from(
          (await client.http.get('/calls/stats/', cancelToken: cancelToken))
              .data as Map);

  Future<Map<String, dynamic>> detail(String id) async =>
      Map<String, dynamic>.from(
          (await client.http.get('/calls/$id/')).data as Map);

  Future<Map<String, dynamic>> scheduleFollowUp(
          String id, String followUpDate) async =>
      Map<String, dynamic>.from((await client.http.post(
        '/calls/$id/schedule-follow-up/',
        data: {'followUpDate': followUpDate},
      ))
          .data as Map);

  Future<Map<String, dynamic>> clearFollowUp(String id) async =>
      Map<String, dynamic>.from(
          (await client.http.post('/calls/$id/clear-follow-up/')).data as Map);

  Future<Map<String, dynamic>> callAgain(String id) async =>
      Map<String, dynamic>.from(
          (await client.http.post('/calls/$id/call-again/')).data as Map);

  Future<Map<String, dynamic>> customerInfo(String id) async =>
      Map<String, dynamic>.from(
          (await client.http.get('/calls/$id/customer-info/')).data as Map);

  Future<void> delete(String id) async {
    await client.http.delete('/calls/$id/');
  }
}
