import 'package:dio/dio.dart';

import '../../../core/models/auth_user_model.dart';
import '../../../services/api_provider.dart';

/// Base exception for all authentication failures.
abstract class AuthException implements Exception {
  const AuthException();
}

/// The backend rejected the credentials (HTTP 400/401).
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException();
}

/// The backend server could not be reached at all.
class ServerUnreachableException extends AuthException {
  const ServerUnreachableException();
}

/// The request timed out while connecting or waiting.
class AuthTimeoutException extends AuthException {
  const AuthTimeoutException();
}

/// Any other unexpected failure.
class UnexpectedAuthException extends AuthException {
  const UnexpectedAuthException([this.details]);

  final String? details;
}

/// Handles all authentication API calls against the backend.
class AuthRepository {
  const AuthRepository(this._client);

  final DioClient _client;

  /// Authenticates the user and returns a valid [AuthSession].
  ///
  /// Throws a typed [AuthException] so the UI layer can map each
  /// failure to a proper localized message.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.http.post(
        '/auth/login/',
        data: {'email': email.trim(), 'password': password},
      );
      return AuthSession.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (_) {
      throw const UnexpectedAuthException();
    }
  }

  AuthException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    // Wrong email/password comes back as 401 (or 400 for malformed payload).
    if (statusCode == 401 || statusCode == 400) {
      return const InvalidCredentialsException();
    }

    // Timeouts (connect, send or receive).
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AuthTimeoutException();
    }

    // No network route to the server at all.
    if (e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown && e.response == null)) {
      return const ServerUnreachableException();
    }

    return UnexpectedAuthException(e.message);
  }
}
