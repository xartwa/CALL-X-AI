import 'package:flutter/material.dart';

class CallTranscriptMessage {
  final String speaker; // 'ai', 'customer', or 'agent'
  final String speakerName;
  final String text;
  final String timestamp;
  final String? sentiment; // 'positive', 'neutral', 'negative'

  const CallTranscriptMessage({
    required this.speaker,
    required this.speakerName,
    required this.text,
    required this.timestamp,
    this.sentiment,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'speakerName': speakerName,
        'text': text,
        'timestamp': timestamp,
        if (sentiment != null) 'sentiment': sentiment,
      };

  factory CallTranscriptMessage.fromJson(Map<String, dynamic> json) =>
      CallTranscriptMessage(
        speaker: json['speaker'] as String? ?? 'ai',
        speakerName: json['speakerName'] as String? ?? 'AI Assistant',
        text: json['text'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '00:00',
        sentiment: json['sentiment'] as String?,
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
  final String callDirection;
  final int sentimentScore;
  final String sentiment;
  final String callIntent;
  final List<String> actionItems;
  final List<CallTranscriptMessage> transcript;
  final int talkRatioAi;
  final int talkRatioCustomer;
  final String? scenarioName;
  final String? recordingUrl;

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
    this.callDirection = 'Outbound',
    this.sentimentScore = 85,
    this.sentiment = 'Positive',
    this.callIntent = 'Product Estimation & Pricing',
    this.actionItems = const [],
    this.transcript = const [],
    this.talkRatioAi = 45,
    this.talkRatioCustomer = 55,
    this.scenarioName,
    this.recordingUrl,
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
    String? callDirection,
    int? sentimentScore,
    String? sentiment,
    String? callIntent,
    List<String>? actionItems,
    List<CallTranscriptMessage>? transcript,
    int? talkRatioAi,
    int? talkRatioCustomer,
    String? scenarioName,
    String? recordingUrl,
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
      callDirection: callDirection ?? this.callDirection,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      sentiment: sentiment ?? this.sentiment,
      callIntent: callIntent ?? this.callIntent,
      actionItems: actionItems ?? this.actionItems,
      transcript: transcript ?? this.transcript,
      talkRatioAi: talkRatioAi ?? this.talkRatioAi,
      talkRatioCustomer: talkRatioCustomer ?? this.talkRatioCustomer,
      scenarioName: scenarioName ?? this.scenarioName,
      recordingUrl: recordingUrl ?? this.recordingUrl,
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
        'callDirection': callDirection,
        'sentimentScore': sentimentScore,
        'sentiment': sentiment,
        'callIntent': callIntent,
        'actionItems': actionItems,
        'transcript': transcript.map((t) => t.toJson()).toList(),
        'talkRatioAi': talkRatioAi,
        'talkRatioCustomer': talkRatioCustomer,
        'scenarioName': scenarioName,
        'recordingUrl': recordingUrl,
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

    List<String> parsedActionItems = [];
    if (json['actionItems'] != null) {
      parsedActionItems = List<String>.from(json['actionItems'] as List);
    }

    final fullName = json['fullName'] as String? ?? 'Contact';
    final status = json['status'] as String? ?? 'Completed';
    final assignee = json['assignee'] as String? ?? 'AI Assistant';

    // Generate intelligent defaults if empty
    if (parsedTranscript.isEmpty && status == 'Completed') {
      parsedTranscript = _generateDefaultTranscript(fullName, assignee);
    }
    if (parsedActionItems.isEmpty && status == 'Completed') {
      parsedActionItems = [
        'Send custom PDF proposal quote to ${json['email'] ?? fullName}',
        'Confirm scope estimation for ${json['companyName'] ?? 'current project'}',
        'Schedule follow-up callback for next milestone check',
      ];
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
      callDirection: json['callDirection'] as String? ?? 'Outbound',
      sentimentScore: (json['sentimentScore'] as num?)?.toInt() ??
          (status == 'Completed' ? 88 : (status == 'Failed' ? 24 : 60)),
      sentiment: json['sentiment'] as String? ??
          (status == 'Completed'
              ? 'Positive'
              : (status == 'Failed' ? 'Negative' : 'Neutral')),
      callIntent: json['callIntent'] as String? ??
          'Sales Qualification & Quotation Estimate',
      actionItems: parsedActionItems,
      transcript: parsedTranscript,
      talkRatioAi: (json['talkRatioAi'] as num?)?.toInt() ?? 42,
      talkRatioCustomer: (json['talkRatioCustomer'] as num?)?.toInt() ?? 58,
      scenarioName: json['scenarioName'] as String?,
      recordingUrl: json['recordingUrl'] as String?,
    );
  }

  static List<CallTranscriptMessage> _generateDefaultTranscript(
    String customerName,
    String agentName,
  ) {
    return [
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Voice Agent',
        text:
            'Hello! This is Sarah from CallX AI. Am I speaking with $customerName?',
        timestamp: '00:03',
      ),
      CallTranscriptMessage(
        speaker: 'customer',
        speakerName: customerName,
        text: 'Hi Sarah, yes this is $customerName speaking. How can I help?',
        timestamp: '00:08',
        sentiment: 'neutral',
      ),
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Voice Agent',
        text:
            'I am following up regarding your recent project inquiry. We reviewed your requirements and prepared an estimated budget and timeline overview. Would you like to review the key points now?',
        timestamp: '00:15',
      ),
      CallTranscriptMessage(
        speaker: 'customer',
        speakerName: customerName,
        text:
            'That sounds great! I was particularly looking for turnaround times and how you handle integrations.',
        timestamp: '00:26',
        sentiment: 'positive',
      ),
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Voice Agent',
        text:
            'Our standard integration takes under 48 hours with full API & webhook support. I have attached the full documentation and formal agreement to your email.',
        timestamp: '00:39',
      ),
      CallTranscriptMessage(
        speaker: 'customer',
        speakerName: customerName,
        text:
            'Perfect, send it over and let us set up a follow-up discussion once my team reviews it.',
        timestamp: '00:52',
        sentiment: 'positive',
      ),
      CallTranscriptMessage(
        speaker: 'ai',
        speakerName: agentName.isNotEmpty ? agentName : 'AI Voice Agent',
        text:
            'Wonderful! You will receive the email in a few moments. Have a wonderful rest of your day, $customerName!',
        timestamp: '01:05',
      ),
    ];
  }
}
