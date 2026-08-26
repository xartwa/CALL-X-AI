import 'package:dio/dio.dart';

import '../../../core/models/auth_user_model.dart';
import '../../../services/api_provider.dart';
import '../../../core/errors/app_exception.dart';

/// Handles all authentication API calls against the backend.
class AuthRepository {
  const AuthRepository(this._client);

  final DioClient _client;

  /// Authenticates the user and returns a valid [AuthSession].
  ///
  /// Throws a typed [AppException] so the UI layer can map each
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
      final mapped = AppException.fromDio(e);
      if (e.response?.statusCode == 401) {
        throw const AppException(AppErrorType.validation, statusCode: 401);
      }
      throw mapped;
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }
}
