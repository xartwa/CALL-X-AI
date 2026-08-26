import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/core/errors/app_exception.dart';

void main() {
  test('maps validation field errors without exposing Dio text', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/customers/'),
      response: Response(
        requestOptions: RequestOptions(path: '/customers/'),
        statusCode: 400,
        data: {
          'phone': ['A customer with this phone number already exists.']
        },
      ),
    );
    final exception = AppException.fromDio(error);
    expect(exception.type, AppErrorType.validation);
    expect(exception.fieldErrors['phone'], isNotEmpty);
  });

  test('maps cancelled requests to a silent cancellation type', () {
    final exception = AppException.fromDio(DioException(
      requestOptions: RequestOptions(path: '/customers/'),
      type: DioExceptionType.cancel,
    ));
    expect(exception.type, AppErrorType.cancelled);
  });
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
