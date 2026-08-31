import 'package:callx_ai/core/errors/app_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/email_models.dart';
import '../domain/email_repository.dart';

class EmailFollowUpsState {
  const EmailFollowUpsState({
    this.logs = const [],
    this.templates = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<EmailLogModel> logs;
  final List<EmailTemplateModel> templates;
  final bool isLoading;
  final bool isRefreshing;
  final bool isSubmitting;
  final String? errorMessage;

  EmailFollowUpsState copyWith({
    List<EmailLogModel>? logs,
    List<EmailTemplateModel>? templates,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) =>
      EmailFollowUpsState(
        logs: logs ?? this.logs,
        templates: templates ?? this.templates,
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}

class EmailFollowUpsCubit extends Cubit<EmailFollowUpsState> {
  EmailFollowUpsCubit(this._repository) : super(const EmailFollowUpsState());

  final EmailRepository _repository;

  Future<void> loadInitial() => _load(initial: true);

  Future<void> refresh() => _load(initial: false);

  Future<void> _load({required bool initial}) async {
    emit(state.copyWith(
      isLoading: initial,
      isRefreshing: !initial,
      clearError: true,
    ));
    try {
      final results = await Future.wait([
        _repository.getLogs(),
        _repository.getTemplates(),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        logs: results[0] as List<EmailLogModel>,
        templates: results[1] as List<EmailTemplateModel>,
        isLoading: false,
        isRefreshing: false,
      ));
    } catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: _message(error),
      ));
    }
  }

  Future<bool> send(Map<String, dynamic> body) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final log = await _repository.send(body);
      if (!isClosed) {
        emit(state.copyWith(
          logs: [log, ...state.logs],
          isSubmitting: false,
        ));
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: _message(error),
        ));
      }
      return false;
    }
  }

  Future<bool> saveTemplate(Map<String, dynamic> value) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final candidate = EmailTemplateModel.fromJson(value);
      final template = await _repository.saveTemplate(
        candidate,
        isNew: !state.templates.any((item) => item.id == candidate.id),
      );
      final templates = [...state.templates];
      final index = templates.indexWhere((item) => item.id == template.id);
      if (index < 0) {
        templates.insert(0, template);
      } else {
        templates[index] = template;
      }
      if (!isClosed) {
        emit(state.copyWith(templates: templates, isSubmitting: false));
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: _message(error),
        ));
      }
      return false;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _repository.deleteTemplate(id);
      if (!isClosed) {
        emit(state.copyWith(
          templates: state.templates.where((item) => item.id != id).toList(),
          clearError: true,
        ));
      }
    } catch (error) {
      if (!isClosed) emit(state.copyWith(errorMessage: _message(error)));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await _repository.deleteLog(id);
      if (!isClosed) {
        emit(state.copyWith(
          logs: state.logs.where((item) => item.id != id).toList(),
          clearError: true,
        ));
      }
    } catch (error) {
      if (!isClosed) emit(state.copyWith(errorMessage: _message(error)));
    }
  }

  String _message(Object error) {
    if (error is! AppException) {
      return 'Unable to complete the email request.';
    }
    if (error.fieldErrors.isNotEmpty) {
      return error.fieldErrors.values.expand((items) => items).join(' ');
    }
    return switch (error.type) {
      AppErrorType.network => 'Network error. Please check your connection.',
      AppErrorType.timeout => 'The request timed out. Please try again.',
      AppErrorType.unauthorized => 'Session expired. Please log in again.',
      AppErrorType.forbidden => 'You do not have permission for this action.',
      AppErrorType.notFound => 'The requested email record was not found.',
      AppErrorType.invalidData => 'The server returned invalid email data.',
      _ => error.details ?? 'Unable to complete the email request.',
    };
  }
}
