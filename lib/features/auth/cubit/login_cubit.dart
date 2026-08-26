import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/auth_user_model.dart';
import '../../../services/preferences_service.dart';
import '../repository/auth_repository.dart';
import '../../../core/errors/app_exception.dart';

/// Immutable UI states of the login flow.
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.session);

  final AuthSession session;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}

/// Drives the login flow: validation is done in the UI, this cubit
/// only handles the request lifecycle (loading / success / failure).
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
    required PreferencesService preferencesService,
  })  : _authRepository = authRepository,
        _preferencesService = preferencesService,
        super(const LoginInitial());

  final AuthRepository _authRepository;
  final PreferencesService _preferencesService;

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    // Ignore taps while a request is already in flight.
    if (state is LoginLoading) return;

    emit(const LoginLoading());

    try {
      final session = await _authRepository.login(
        email: email,
        password: password,
      );
      await _preferencesService.saveAuthSession(
        session: session,
        persist: rememberMe,
      );
      emit(LoginSuccess(session));
    } on AppException catch (error) {
      final message = switch (error.type) {
        AppErrorType.validation ||
        AppErrorType.unauthorized =>
          AppStrings.current.loginErrorInvalidCredentials,
        AppErrorType.network => AppStrings.current.loginErrorServerUnreachable,
        AppErrorType.timeout => AppStrings.current.loginErrorTimeout,
        _ => AppStrings.current.loginErrorGeneric,
      };
      emit(LoginFailure(message));
    } catch (_) {
      emit(LoginFailure(AppStrings.current.loginErrorGeneric));
    }
  }
}
