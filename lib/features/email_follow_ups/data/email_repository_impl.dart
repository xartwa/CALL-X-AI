import 'package:callx_ai/core/errors/app_exception.dart';
import 'package:dio/dio.dart';

import '../domain/email_repository.dart';
import 'email_models.dart';
import 'email_remote_data_source.dart';

class EmailRepositoryImpl implements EmailRepository {
  const EmailRepositoryImpl(this._remote);

  final EmailRemoteDataSource _remote;

  Future<T> _request<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

  @override
  Future<List<EmailLogModel>> getLogs() => _request(() async =>
      (await _remote.getLogs()).map(EmailLogModel.fromJson).toList());

  @override
  Future<List<EmailTemplateModel>> getTemplates() => _request(() async =>
      (await _remote.getTemplates()).map(EmailTemplateModel.fromJson).toList());

  @override
  Future<EmailLogModel> send(Map<String, dynamic> body) =>
      _request(() async => EmailLogModel.fromJson(await _remote.send(body)));

  @override
  Future<EmailTemplateModel> saveTemplate(
    EmailTemplateModel template, {
    required bool isNew,
  }) =>
      _request(() async {
        final json = isNew
            ? await _remote.createTemplate(template.toApiJson())
            : await _remote.updateTemplate(template.id, template.toApiJson());
        return EmailTemplateModel.fromJson(json);
      });

  @override
  Future<void> deleteTemplate(String id) =>
      _request(() => _remote.deleteTemplate(id));

  @override
  Future<void> deleteLog(String id) => _request(() => _remote.deleteLog(id));
}
