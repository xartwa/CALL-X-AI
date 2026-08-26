import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/dashboard/data/models/dashboard_snapshot_model.dart';
import 'package:callx_ai/features/dashboard/domain/entities/dashboard_snapshot.dart';

void main() {
  test('parses dashboard snapshot contract and call actions', () {
    final snapshot = DashboardSnapshotModel.fromJson({
      'generatedAt': '2026-08-26T10:00:00Z',
      'timezone': 'UTC',
      'date': '2026-08-26',
      'kpi': {
        'totalCalls': 4,
        'callsToday': 2,
        'successRate': 50,
        'totalFollowUps': 3
      },
      'todayCalls': {
        'date': '2026-08-26',
        'count': 1,
        'hasMore': false,
        'items': [
          {
            'id': 'call-1',
            'customerId': 'customer-1',
            'fullName': 'Ada Lovelace',
            'companyName': 'Analytical Engines',
            'purpose': 'Discovery',
            'scenarioId': null,
            'phone': '+1',
            'email': 'ada@example.com',
            'leadPriority': 'Hot',
            'status': 'queued',
            'scheduledFor': '2026-08-26T10:30:00Z',
            'timeLabel': '10:30',
            'meridiem': 'AM',
            'timelineState': 'current',
            'availableActions': ['call_now', 'email'],
            'isOverdue': false,
          },
        ],
      },
      'callReports': {
        'total': 2,
        'items': [
          {
            'key': 'interested',
            'label': 'Interested',
            'count': 1,
            'percentage': 50,
            'color': '#6366F1'
          },
        ],
      },
      'clientState': {'todoStorage': 'local'},
    }).entity;

    expect(snapshot.kpi.totalCalls, 4);
    expect(snapshot.todayCalls.items.single.timelineState,
        DashboardTimelineState.current);
    expect(snapshot.todayCalls.items.single.availableActions,
        contains(DashboardCallAction.callNow));
  });

  test('rejects invalid dashboard percentages', () {
    expect(
      () => DashboardSnapshotModel.fromJson({
        'generatedAt': '2026-08-26T10:00:00Z',
        'timezone': 'UTC',
        'date': '2026-08-26',
        'kpi': {
          'totalCalls': 0,
          'callsToday': 0,
          'successRate': 101,
          'totalFollowUps': 0
        },
        'todayCalls': {
          'date': '2026-08-26',
          'count': 0,
          'hasMore': false,
          'items': []
        },
        'callReports': {'total': 0, 'items': []},
      }),
      throwsFormatException,
    );
  });
}
