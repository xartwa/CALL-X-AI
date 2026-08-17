import 'package:flutter/material.dart';

class CallHistoryModel {
  final String id;
  final String fullName;
  final String companyName;
  final String phone;
  final String status;
  final Color? statusColor;
  final String assignee;
  final String duration;
  final String callTime;
  final String callDate;
  final String? notes;
  final String? email;
  final String? leadPriority;
  final String? lastContactResult;
  final String? nextFollowUpDate;
  final List<String> tags;

  CallHistoryModel({
    required this.id,
    required this.fullName,
    this.companyName = '',
    required this.phone,
    required this.status,
    required this.assignee,
    required this.duration,
    required this.callTime,
    required this.callDate,
    this.statusColor,
    this.notes,
    this.email,
    this.leadPriority = 'Warm',
    this.lastContactResult = 'Interested',
    this.nextFollowUpDate = '',
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'companyName': companyName,
        'phone': phone,
        'status': status,
        'assignee': assignee,
        'duration': duration,
        'callTime': callTime,
        'callDate': callDate,
        'notes': notes,
        'email': email,
        'leadPriority': leadPriority,
        'lastContactResult': lastContactResult,
        'nextFollowUpDate': nextFollowUpDate,
        'tags': tags,
        'statusColor': statusColor?.toARGB32(),
      };

  factory CallHistoryModel.fromJson(Map<String, dynamic> json,
      {Color? defaultStatusColor}) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      parsedTags = List<String>.from(json['tags'] as List);
    }

    Color? color;
    if (json['statusColor'] != null) {
      color = Color(json['statusColor'] as int);
    } else {
      color = defaultStatusColor;
    }

    return CallHistoryModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: json['status'] as String? ?? 'Completed',
      assignee: json['assignee'] as String? ?? 'Admin',
      duration: json['duration'] as String? ?? '0:00',
      callTime: json['callTime'] as String? ?? '',
      callDate: json['callDate'] as String? ?? '',
      notes: json['notes'] as String?,
      email: json['email'] as String?,
      leadPriority: json['leadPriority'] as String? ?? 'Warm',
      lastContactResult: json['lastContactResult'] as String? ?? 'Interested',
      nextFollowUpDate: json['nextFollowUpDate'] as String? ?? '',
      tags: parsedTags,
      statusColor: color,
    );
  }
}
