import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/customers/domain/entities/customer.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';

void main() {
  test('parses camelCase customer and nullable detail media', () {
    final customer = Customer.fromJson({
      'id': 'customer-1',
      'fullName': 'John Smith',
      'phoneNumber': '+1 604 555 0100',
      'nextFollowUpDate': null,
      'notesCount': 2,
      'documentsCount': 1,
      'callLogs': [
        {
          'id': 'call-1',
          'status': 'completed',
          'direction': 'outbound',
          'outcome': 'interested',
          'duration': '00:40',
          'durationSeconds': 40,
          'scheduledFor': null,
          'callDate': '2026-08-26',
          'callTime': '14:00',
          'scenario': null,
          'recordingUrl': null,
          'transcript': [],
          'notes': null,
          'createdAt': null,
        }
      ]
    });

    expect(customer.id, 'customer-1');
    expect(customer.phoneNumber, '+1 604 555 0100');
    expect(customer.nextFollowUpDate, isNull);
    expect(customer.callLogs.single.recordingUrl, isNull);
    expect(customer.callLogs.single.transcript, isEmpty);
  });

  test('builds server pagination, filter and sort query', () {
    const filters = CustomerFilters(
      search: 'arta',
      country: 'Canada',
      state: 'BC',
      sort: 'az',
    );
    expect(filters.toQuery(2, 20), containsPair('page', 2));
    expect(filters.toQuery(2, 20), containsPair('pageSize', 20));
    expect(filters.toQuery(2, 20), containsPair('search', 'arta'));
    expect(filters.toQuery(2, 20), containsPair('sort', 'az'));
  });
}
