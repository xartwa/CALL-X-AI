import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/core/errors/app_exception.dart';

void main() {
  test('maps connection errors to network', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/test'),
      type: DioExceptionType.connectionError,
    );
    expect(AppException.fromDio(error).type, AppErrorType.network);
  });

  test('maps server responses to server errors', () {
    final options = RequestOptions(path: '/test');
    final error = DioException(
      requestOptions: options,
      response: Response(requestOptions: options, statusCode: 503),
      type: DioExceptionType.badResponse,
    );
    expect(AppException.fromDio(error).type, AppErrorType.server);
  });
}
