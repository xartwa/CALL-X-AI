import 'package:dio/dio.dart';

enum AppErrorType {
  unauthorized,
  validation,
  network,
  timeout,
  server,
  invalidData,
  unknown,
}

class AppException implements Exception {
  const AppException(this.type, {this.statusCode, this.details});

  final AppErrorType type;
  final int? statusCode;
  final String? details;

  factory AppException.fromDio(
    DioException error, {
    bool badRequestIsValidation = true,
  }) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return AppException(AppErrorType.unauthorized, statusCode: status);
    }
    if (status == 400 && badRequestIsValidation) {
      return AppException(AppErrorType.validation, statusCode: status);
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppException(AppErrorType.timeout);
    }
    if (error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.unknown && error.response == null)) {
      return const AppException(AppErrorType.network);
    }
    if (status != null && status >= 500) {
      return AppException(AppErrorType.server, statusCode: status);
    }
    return AppException(
      AppErrorType.unknown,
      statusCode: status,
      details: error.message,
    );
  }
}
