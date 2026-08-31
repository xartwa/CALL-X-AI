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
    this.sentAt,
  });

  final String id;
  final String? customerId;
  final String? templateId;
  final String recipientEmail;
  final String recipientName;
  final String companyName;
  final String senderAlias;
  final String subject;
  final String body;
  final String status;
  final DateTime? sentAt;

  factory EmailLogModel.fromJson(Map<String, dynamic> json) => EmailLogModel(
        id: json['id']?.toString() ?? '',
        customerId: json['customer']?.toString(),
        templateId: json['template']?.toString(),
        recipientEmail: json['recipientEmail']?.toString() ?? '',
        recipientName: json['recipientName']?.toString() ?? '',
        companyName: json['companyName']?.toString() ?? '',
        senderAlias: json['senderAlias']?.toString() ?? 'CallX AI Team',
        subject: json['subject']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        status: json['status']?.toString() ?? 'Sent',
        sentAt: AppDateTime.tryParseApiDateTime(json['sentDate']) ??
            AppDateTime.tryParseApiDateTime(json['created_at']),
      );

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
        'senderEmail': senderAlias,
        'subject': subject,
        'body': body,
        'status': status,
        'sentAt': sentAt,
        'templateName': templateId == null
            ? 'Custom Email'
            : templates[templateId]?.name ?? 'Custom Email',
      };
}
