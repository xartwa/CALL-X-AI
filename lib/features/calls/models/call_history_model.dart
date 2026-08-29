import 'package:flutter/material.dart';

class CallTranscriptMessage {
  final String speaker; // 'ai' or 'customer' or 'agent'
  final String speakerName;
  final String text;
  final String timestamp;

  const CallTranscriptMessage({
    required this.speaker,
    required this.speakerName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'speakerName': speakerName,
        'text': text,
        'timestamp': timestamp,
      };

  factory CallTranscriptMessage.fromJson(Map<String, dynamic> json) =>
      CallTranscriptMessage(
        speaker: json['speaker'] as String? ?? 'ai',
        speakerName: json['speakerName'] as String? ?? 'AI Assistant',
        text: json['text'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '00:00',
      );
}

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
  final String? recordingUrl;
  final List<CallTranscriptMessage> transcript;
  final String direction; // 'Inbound' or 'Outbound'

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
    this.recordingUrl,
    this.transcript = const [],
    this.direction = 'Outbound',
  });

  CallHistoryModel copyWith({
    String? id,
    String? fullName,
    String? companyName,
    String? phone,
    String? status,
    Color? statusColor,
    String? assignee,
    String? duration,
    String? callTime,
    String? callDate,
    String? notes,
    String? email,
    String? leadPriority,
    String? lastContactResult,
    String? nextFollowUpDate,
    List<String>? tags,
    String? recordingUrl,
    List<CallTranscriptMessage>? transcript,
    String? direction,
  }) {
    return CallHistoryModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      statusColor: statusColor ?? this.statusColor,
      assignee: assignee ?? this.assignee,
      duration: duration ?? this.duration,
      callTime: callTime ?? this.callTime,
      callDate: callDate ?? this.callDate,
      notes: notes ?? this.notes,
      email: email ?? this.email,
      leadPriority: leadPriority ?? this.leadPriority,
      lastContactResult: lastContactResult ?? this.lastContactResult,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      tags: tags ?? this.tags,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      transcript: transcript ?? this.transcript,
      direction: direction ?? this.direction,
    );
  }

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
        'recordingUrl': recordingUrl,
        'transcript': transcript.map((t) => t.toJson()).toList(),
        'direction': direction,
      };

  factory CallHistoryModel.fromJson(
    Map<String, dynamic> json, {
    Color? defaultStatusColor,
  }) {
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

    List<CallTranscriptMessage> parsedTranscript = [];
    if (json['transcript'] != null && (json['transcript'] as List).isNotEmpty) {
      parsedTranscript = (json['transcript'] as List)
          .map((item) =>
              CallTranscriptMessage.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final fullName = json['fullName'] as String? ?? 'Contact';
    final status = json['status'] as String? ?? 'Completed';
    final assignee = json['assignee'] as String? ?? 'AI Assistant';
    final direction = json['direction'] as String? ??
        (json['callDirection'] as String? ?? 'Outbound');

    if (parsedTranscript.isEmpty && status == 'Completed') {
      parsedTranscript = _generateDefaultTranscript(fullName, assignee);
    }

    return CallHistoryModel(
      id: json['id']?.toString() ?? '',
      fullName: fullName,
      companyName: json['companyName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      status: status,
      assignee: assignee,
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
      recordingUrl: json['recordingUrl'] as String?,
      transcript: parsedTranscript,
      direction: direction,
    );
  }

  static List<CallTranscriptMessage> _generateDefaultTranscript(
    String customerName,
    String agentName,
  ) {
    return [
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Agent',
        text: 'Hello $customerName! Calling from CallX AI regarding your recent inquiry.',
        timestamp: '00:03',
      ),
      CallTranscriptMessage(
        speaker: 'customer',
        speakerName: customerName,
        text: 'Hi, thanks for reaching out. I was looking for quotation details.',
        timestamp: '00:08',
      ),
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Agent',
        text: 'I have prepared your estimation overview. I will email the full proposal document to you now.',
        timestamp: '00:15',
      ),
      CallTranscriptMessage(
        speaker: 'customer',
        speakerName: customerName,
        text: 'Great, please send it over and let us follow up after my review.',
        timestamp: '00:24',
      ),
    ];
  }
}

