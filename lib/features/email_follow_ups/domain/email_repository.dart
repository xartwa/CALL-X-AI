import '../data/email_models.dart';

abstract interface class EmailRepository {
  Future<List<EmailLogModel>> getLogs();
  Future<List<EmailTemplateModel>> getTemplates();
  Future<EmailLogModel> send(Map<String, dynamic> body);
  Future<EmailTemplateModel> saveTemplate(
    EmailTemplateModel template, {
    required bool isNew,
  });
  Future<void> deleteTemplate(String id);
  Future<void> deleteLog(String id);
}
