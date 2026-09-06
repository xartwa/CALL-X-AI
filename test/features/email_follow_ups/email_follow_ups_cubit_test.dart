import 'package:callx_ai/features/email_follow_ups/cubit/email_follow_ups_cubit.dart';
import 'package:callx_ai/features/email_follow_ups/data/email_models.dart';
import 'package:callx_ai/features/email_follow_ups/domain/email_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEmailRepository implements EmailRepository {
  final templates = <EmailTemplateModel>[
    const EmailTemplateModel(
      id: 'template-1',
      name: 'Follow up',
      category: 'Follow-Up & Closing',
      subject: 'Hello {name}',
      body: '<p>Hello</p>',
    ),
  ];
  final logs = <EmailLogModel>[];
  final senderAccounts = <EmailSenderAccountModel>[
    const EmailSenderAccountModel(
      id: 'sender-1',
      name: 'CallX AI',
      email: 'xartwa@gmail.com',
      isDefault: true,
    ),
  ];
  bool sendCalled = false;

  @override
  Future<List<EmailLogModel>> getLogs() async => List.of(logs);

  @override
  Future<List<EmailTemplateModel>> getTemplates() async => List.of(templates);

  @override
  Future<List<EmailSenderAccountModel>> getSenderAccounts() async =>
      List.of(senderAccounts);

  @override
  Future<EmailLogModel> send(
    Map<String, dynamic> body, {
    List<PlatformFile>? attachments,
  }) async {
    sendCalled = true;
    return EmailLogModel(
      id: 'log-1',
      recipientEmail: body['recipientEmail'].toString(),
      recipientName: body['recipientName'].toString(),
      senderAlias: body['senderAlias'].toString(),
      subject: body['subject'].toString(),
      body: body['body'].toString(),
      status: 'Sent',
      sentAt: DateTime.utc(2026, 8, 31, 12),
    );
  }

  @override
  Future<EmailTemplateModel> saveTemplate(
    EmailTemplateModel template, {
    required bool isNew,
  }) async =>
      template;

  @override
  Future<void> deleteLog(String id) async {
    logs.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    templates.removeWhere((item) => item.id == id);
  }
}

void main() {
  test('EmailLogModel parses the strict UTC backend contract', () {
    final log = EmailLogModel.fromJson({
      'id': 'log-1',
      'recipientEmail': 'jane@example.com',
      'recipientName': 'Jane',
      'senderAlias': 'sales@callx.ai',
      'subject': 'Hello',
      'body': '<p>Hello</p>',
      'status': 'Sent',
      'sentDate': '2026-08-31T12:30:00Z',
    });

    expect(log.sentAt, DateTime.utc(2026, 8, 31, 12, 30));
    expect(log.toViewMap(const {})['sentAt'], log.sentAt);
  });

  test('EmailFollowUpsCubit loads server data and sends through repository',
      () async {
    final repository = _FakeEmailRepository();
    final cubit = EmailFollowUpsCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadInitial();
    expect(cubit.state.templates.single.id, 'template-1');
    expect(cubit.state.isLoading, false);

    final sent = await cubit.send({
      'recipientEmail': 'jane@example.com',
      'recipientName': 'Jane',
      'senderAlias': 'sales@callx.ai',
      'subject': 'Hello',
      'body': '<p>Hello</p>',
    });

    expect(sent, true);
    expect(repository.sendCalled, true);
    expect(cubit.state.logs.single.id, 'log-1');
  });
}
