import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';

void main() {
  group('CallHistoryModel Tests', () {
    test('serializes and deserializes properly with default transcript and action items', () {
      final call = CallHistoryModel(
        id: '101',
        fullName: 'Jane Doe',
        companyName: 'Acme Corp',
        phone: '0912 345 6789',
        status: 'Completed',
        assignee: 'AI Agent (Emma)',
        duration: '3:45',
        callTime: '11:00',
        callDate: '2026/08/29',
        notes: 'Customer interested in Enterprise Tier',
        email: 'jane@acme.com',
        leadPriority: 'Hot',
        callDirection: 'Outbound',
        sentimentScore: 92,
        sentiment: 'Positive',
        callIntent: 'Demo & Quotation',
      );

      final json = call.toJson();
      expect(json['id'], '101');
      expect(json['fullName'], 'Jane Doe');
      expect(json['sentimentScore'], 92);
      expect(json['sentiment'], 'Positive');

      final deserialized = CallHistoryModel.fromJson(json);
      expect(deserialized.id, '101');
      expect(deserialized.fullName, 'Jane Doe');
      expect(deserialized.companyName, 'Acme Corp');
      expect(deserialized.duration, '3:45');
      expect(deserialized.sentimentScore, 92);
      expect(deserialized.transcript, isNotEmpty);
    });

    test('copyWith updates specific fields accurately', () {
      final call = CallHistoryModel(
        id: '102',
        fullName: 'Bob Builder',
        phone: '0935 123 4567',
        status: 'Completed',
        assignee: 'Admin',
        duration: '1:30',
        callTime: '14:20',
        callDate: '2026/08/28',
      );

      final updated = call.copyWith(
        notes: 'Updated follow-up note',
        nextFollowUpDate: '2026/09/01',
        sentimentScore: 95,
      );

      expect(updated.id, '102');
      expect(updated.notes, 'Updated follow-up note');
      expect(updated.nextFollowUpDate, '2026/09/01');
      expect(updated.sentimentScore, 95);
      expect(updated.fullName, 'Bob Builder');
    });

    test('CallTranscriptMessage serialization and deserialization', () {
      const msg = CallTranscriptMessage(
        speaker: 'ai',
        speakerName: 'AI Voice Assistant',
        text: 'Hello, how can I assist you?',
        timestamp: '00:05',
        sentiment: 'positive',
      );

      final json = msg.toJson();
      expect(json['speaker'], 'ai');
      expect(json['text'], 'Hello, how can I assist you?');

      final deserialized = CallTranscriptMessage.fromJson(json);
      expect(deserialized.speaker, 'ai');
      expect(deserialized.speakerName, 'AI Voice Assistant');
      expect(deserialized.timestamp, '00:05');
      expect(deserialized.sentiment, 'positive');
    });
  });
}
