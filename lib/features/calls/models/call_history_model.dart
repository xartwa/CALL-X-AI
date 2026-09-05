import 'package:flutter/material.dart';
import '../../../core/utils/app_date_time.dart';

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

  factory CallTranscriptMessage.fromJson(Map<String, dynamic> json) {
    final rawSpeaker = (json['speaker'] as String? ?? 'ai').toLowerCase();
    final isAi = rawSpeaker == 'ai' || rawSpeaker == 'assistant' || rawSpeaker == 'agent';
    final defaultSpeakerName = isAi ? 'AI Assistant' : 'Customer';
    final rawSpeakerName = json['speakerName'] as String? ??
        (json['speaker_name'] as String? ?? defaultSpeakerName);

    String effectiveSpeakerName = rawSpeakerName;
    if (!isAi) {
      if (effectiveSpeakerName.isEmpty ||
          effectiveSpeakerName == 'AI' ||
          effectiveSpeakerName == 'AI Assistant' ||
          effectiveSpeakerName == 'AI Agent') {
        effectiveSpeakerName = 'Customer';
      }
    } else {
      if (effectiveSpeakerName.isEmpty || effectiveSpeakerName == 'Customer') {
        effectiveSpeakerName = 'AI Assistant';
      }
    }

    String timestamp = (json['timestamp'] ?? json['time'])?.toString() ?? '';
    if (timestamp.isEmpty || timestamp == '00:00') {
      final rawStart = json['start_timestamp'] ?? json['startTimestamp'];
      if (rawStart != null) {
        final sec = (rawStart is num ? rawStart : double.tryParse('$rawStart') ?? 0).toInt();
        final m = sec ~/ 60;
        final s = sec % 60;
        timestamp = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } else {
        timestamp = '00:00';
      }
    }

    return CallTranscriptMessage(
      speaker: isAi ? 'ai' : 'customer',
      speakerName: effectiveSpeakerName,
      text: json['text'] as String? ?? (json['content'] as String? ?? ''),
      timestamp: timestamp,
    );
  }
}

class CallHistoryModel {
  static const Object _unset = Object();

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
  final DateTime? scheduledFor;
  final DateTime? createdAt;
  final String? notes;
  final String? email;
  final String? leadPriority;
  final String? lastContactResult;
  final DateTime? nextFollowUpDate;
  final List<String> tags;
  final String? recordingUrl;
  final List<CallTranscriptMessage> transcript;
  final String direction; // 'Inbound' or 'Outbound'
  final String? customerId;

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
    this.scheduledFor,
    this.createdAt,
    this.statusColor,
    this.notes,
    this.email,
    this.leadPriority = 'Warm',
    this.lastContactResult = 'Interested',
    Object? nextFollowUpDate = _unset,
    this.tags = const [],
    this.recordingUrl,
    this.transcript = const [],
    this.direction = 'Outbound',
    this.customerId,
  }) : nextFollowUpDate = AppDateTime.tryParse(nextFollowUpDate);

  DateTime? get dateTime =>
      AppDateTime.combine(callDate, callTime) ?? scheduledFor ?? createdAt;

  DateTime? get nextFollowUpAt => nextFollowUpDate;

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
    DateTime? scheduledFor,
    DateTime? createdAt,
    String? notes,
    String? email,
    String? leadPriority,
    String? lastContactResult,
    Object? nextFollowUpDate = _unset,
    List<String>? tags,
    String? recordingUrl,
    List<CallTranscriptMessage>? transcript,
    String? direction,
    String? customerId,
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
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      email: email ?? this.email,
      leadPriority: leadPriority ?? this.leadPriority,
      lastContactResult: lastContactResult ?? this.lastContactResult,
      nextFollowUpDate: identical(nextFollowUpDate, _unset)
          ? this.nextFollowUpDate
          : nextFollowUpDate,
      tags: tags ?? this.tags,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      transcript: transcript ?? this.transcript,
      direction: direction ?? this.direction,
      customerId: customerId ?? this.customerId,
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
        'callDate': callDate,
        'callTime': callTime,
        if (scheduledFor != null)
          'scheduledFor': AppDateTime.apiDateTime(scheduledFor!),
        if (createdAt != null) 'createdAt': AppDateTime.apiDateTime(createdAt!),
        'notes': notes,
        'email': email,
        'leadPriority': leadPriority,
        'lastContactResult': lastContactResult,
        if (nextFollowUpDate != null)
          'nextFollowUpDate': AppDateTime.apiDateTime(nextFollowUpDate!),
        'tags': tags,
        'statusColor': statusColor?.toARGB32(),
        'recordingUrl': recordingUrl,
        'transcript': transcript.map((t) => t.toJson()).toList(),
        'direction': direction,
        'customerId': customerId,
      };

  factory CallHistoryModel.fromJson(
    Map<String, dynamic> rawJson, {
    Color? defaultStatusColor,
  }) {
    final json = (rawJson['call'] is Map)
        ? Map<String, dynamic>.from(rawJson['call'] as Map)
        : rawJson;

    List<String> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      for (final t in json['tags'] as List) {
        if (t is String) {
          parsedTags.add(t);
        } else if (t is Map && t['label'] != null) {
          parsedTags.add(t['label'].toString());
        }
      }
    }

    Color? color;
    if (json['statusColor'] != null) {
      color = Color(json['statusColor'] as int);
    } else {
      color = defaultStatusColor;
    }

    List<CallTranscriptMessage> parsedTranscript = [];
    final rawTranscript = json['transcript'] ?? json['transcript_messages'];
    if (rawTranscript is List && rawTranscript.isNotEmpty) {
      parsedTranscript = rawTranscript
          .whereType<Map>()
          .map((item) =>
              CallTranscriptMessage.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final fullName =
        (json['fullName'] ?? json['full_name'] ?? json['name'] ?? 'Contact')
            .toString();
    final status = (json['status'] ?? 'Queued').toString();
    final assignee = (json['assignee'] ?? 'AI Assistant').toString();
    final direction = (json['direction'] ??
            json['call_direction'] ??
            json['callDirection'] ??
            'Outbound')
        .toString();

    final customerIdRaw = json['customerId'] ??
        json['customer_id'] ??
        (json['customer'] is Map ? json['customer']['id'] : null) ??
        (json['customer'] is num ? json['customer'].toString() : null);

    return CallHistoryModel(

      id: json['id']?.toString() ?? '',
      fullName: fullName,
      companyName:
          (json['companyName'] ?? json['company_name'] ?? json['company'] ?? '')
              .toString(),
      phone:
          (json['phone'] ?? json['phone_number'] ?? json['phoneNumber'] ?? '')
              .toString(),
      status: status,
      assignee: assignee,
      duration: (json['duration'] ?? '0:00').toString(),
      callTime: (json['callTime'] ?? json['call_time'] ?? '').toString(),
      callDate: (json['callDate'] ?? json['call_date'] ?? '').toString(),
      scheduledFor: AppDateTime.tryParseApiDateTime(
          json['scheduledFor'] ?? json['scheduled_for']),
      createdAt: AppDateTime.tryParseApiDateTime(
        json['occurredAt'] ?? json['createdAt'] ?? json['created_at'],
      ),
      notes: json['notes'] as String?,
      email: json['email'] as String?,
      leadPriority:
          (json['leadPriority'] ?? json['lead_priority'] ?? 'Warm').toString(),
      lastContactResult: (json['lastContactResult'] ??
              json['last_contact_result'] ??
              'Interested')
          .toString(),
      nextFollowUpDate: AppDateTime.tryParseApiDateTime(
        json['nextFollowUpDate'] ?? json['next_follow_up_date'],
      ),
      tags: parsedTags,
      statusColor: color,
      recordingUrl: (json['recordingUrl'] ??
          json['recording_url'] ??
          json['audio_url']) as String?,
      transcript: parsedTranscript,
      direction: direction,
      customerId: customerIdRaw?.toString(),
    );
  }
}

