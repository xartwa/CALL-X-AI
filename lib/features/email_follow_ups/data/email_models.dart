import 'package:callx_ai/core/utils/app_date_time.dart';

class EmailTemplateModel {
  const EmailTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subject,
    required this.body,
  });

  final String id;
  final String name;
  final String category;
  final String subject;
  final String body;

  factory EmailTemplateModel.fromJson(Map<String, dynamic> json) =>
      EmailTemplateModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Follow-Up & Closing',
        subject: json['subject']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
      );

  Map<String, dynamic> toApiJson() => {
        'id': id,
        'name': name,
        'category': category,
        'subject': subject,
        'body': body,
      };

  Map<String, dynamic> toViewMap() => toApiJson();
}

class EmailAttachmentModel {
  const EmailAttachmentModel({
    required this.id,
    required this.filename,
    required this.fileSize,
    required this.contentType,
    required this.fileUrl,
  });

  final String id;
  final String filename;
  final int fileSize;
  final String contentType;
  final String fileUrl;

  factory EmailAttachmentModel.fromJson(Map<String, dynamic> json) =>
      EmailAttachmentModel(
        id: json['id']?.toString() ?? '',
        filename: json['filename']?.toString() ?? '',
        fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
        contentType: json['contentType']?.toString() ?? '',
        fileUrl: json['fileUrl']?.toString() ?? '',
      );
}

class EmailSenderAccountModel {
  const EmailSenderAccountModel({
    required this.id,
    required this.name,
    required this.email,
    this.senderName = '',
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String email;
  final String senderName;
  final bool isDefault;

  factory EmailSenderAccountModel.fromJson(Map<String, dynamic> json) =>
      EmailSenderAccountModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        senderName: json['senderName']?.toString() ?? '',
        isDefault: json['isDefault'] == true,
      );

  String get displayName => senderName.isNotEmpty
      ? '$senderName <$email>'
      : (name.isNotEmpty ? '$name <$email>' : email);
}

class EmailLogModel {
  const EmailLogModel({
    required this.id,
    required this.recipientEmail,
    required this.recipientName,
    required this.senderAlias,
    required this.subject,
    required this.body,
    required this.status,
    this.customerId,
    this.templateId,
    this.companyName = '',
    this.fromEmail = '',
    this.errorMessage = '',
    this.attachments = const [],
    this.sentAt,
  });

  final String id;
  final String? customerId;
  final String? templateId;
  final String recipientEmail;
  final String recipientName;
  final String companyName;
  final String senderAlias;
  final String fromEmail;
  final String errorMessage;
  final List<EmailAttachmentModel> attachments;
  final String subject;
  final String body;
  final String status;
  final DateTime? sentAt;

  factory EmailLogModel.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'] as List? ?? [];
    return EmailLogModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer']?.toString(),
      templateId: json['template']?.toString(),
      recipientEmail: json['recipientEmail']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      senderAlias: json['senderAlias']?.toString() ?? 'CallX AI Team',
      fromEmail: json['fromEmail']?.toString() ?? '',
      errorMessage: json['errorMessage']?.toString() ?? '',
      attachments: rawAttachments
          .map((a) => EmailAttachmentModel.fromJson(a as Map<String, dynamic>))
          .toList(growable: false),
      subject: json['subject']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Sent',
      sentAt: AppDateTime.tryParseApiDateTime(json['sentDate']) ??
          AppDateTime.tryParseApiDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toViewMap(
    Map<String, EmailTemplateModel> templates,
  ) =>
      {
        'id': id,
        'customerId': customerId,
        'templateId': templateId,
        'recipientEmail': recipientEmail,
        'recipientName': recipientName,
        'companyName': companyName,
        'senderEmail': fromEmail.isNotEmpty ? fromEmail : senderAlias,
        'subject': subject,
        'body': body,
        'status': status,
        'sentAt': sentAt,
        'hasAttachments': attachments.isNotEmpty,
        'attachmentCount': attachments.length,
        'templateName': templateId == null
            ? 'Custom Email'
            : templates[templateId]?.name ?? 'Custom Email',
      };
}
