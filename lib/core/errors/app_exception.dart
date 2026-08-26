import 'package:dio/dio.dart';

enum AppErrorType {
  unauthorized,
  forbidden,
  notFound,
  validation,
  cancelled,
  network,
  timeout,
  server,
  invalidData,
  unknown,
}

class AppException implements Exception {
  const AppException(
    this.type, {
    this.statusCode,
    this.details,
    this.fieldErrors = const {},
  });

  final AppErrorType type;
  final int? statusCode;
  final String? details;
  final Map<String, List<String>> fieldErrors;

  factory AppException.fromDio(
    DioException error, {
    bool badRequestIsValidation = true,
  }) {
    final status = error.response?.statusCode;
    if (error.type == DioExceptionType.cancel) {
      return const AppException(AppErrorType.cancelled);
    }
    if (status == 401) {
      return AppException(AppErrorType.unauthorized, statusCode: status);
    }
    if (status == 403) {
      return AppException(AppErrorType.forbidden, statusCode: status);
    }
    if (status == 404) {
      return AppException(AppErrorType.notFound, statusCode: status);
    }
    if (status == 400 && badRequestIsValidation) {
      return AppException(
        AppErrorType.validation,
        statusCode: status,
        fieldErrors: _parseFieldErrors(error.response?.data),
      );
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

  static Map<String, List<String>> _parseFieldErrors(Object? data) {
    if (data is! Map) return const {};
    return data.map((key, value) {
      final messages = value is List
          ? value.map((item) => item.toString()).toList(growable: false)
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }
}
