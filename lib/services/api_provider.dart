import 'package:dio/dio.dart';

class DioClient {
  DioClient({required String baseUrl, String? Function()? accessTokenProvider})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        ) {
    // Automatically attach the JWT bearer token to every request.
    if (accessTokenProvider != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final token = accessTokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Dio get http => _dio;
}
