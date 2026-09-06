import 'package:file_picker/file_picker.dart';
import '../data/email_models.dart';

abstract interface class EmailRepository {
  Future<List<EmailLogModel>> getLogs();
  Future<List<EmailTemplateModel>> getTemplates();
  Future<List<EmailSenderAccountModel>> getSenderAccounts();
  Future<EmailLogModel> send(
    Map<String, dynamic> body, {
    List<PlatformFile>? attachments,
  });
  Future<EmailTemplateModel> saveTemplate(
    EmailTemplateModel template, {
    required bool isNew,
  });
  Future<void> deleteTemplate(String id);
  Future<void> deleteLog(String id);
}

