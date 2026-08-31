import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/customers/domain/entities/customer.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

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

  test('normalizes a human follow-up date to the UTC API contract', () {
    final customer = Customer(
      id: 'customer-2',
      fullName: 'Jane Smith',
      nextFollowUpDate: '17 Jan 2026',
    );

    expect(customer.nextFollowUpDate, DateTime(2026, 1, 17));
    final expected = AppDateTime.apiDateTime(DateTime(2026, 1, 17));
    expect(customer.toApiJson()['nextFollowUpDate'], expected);
    expect(customer.toApiJson(), isNot(contains('next_follow_up_date')));
    expect(customer.copyWith(companyName: 'Acme').nextFollowUpDate,
        DateTime(2026, 1, 17));
    expect(customer.copyWith(nextFollowUpDate: null).nextFollowUpDate, isNull);
  });
}
