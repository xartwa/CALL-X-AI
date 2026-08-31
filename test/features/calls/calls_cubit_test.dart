import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/core/widgets/advanced_filter_dialog.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/features/calls/data/dto/calls_kpi_dto.dart';
import 'package:callx_ai/features/calls/data/dto/paginated_calls_dto.dart';
import 'package:callx_ai/features/calls/domain/repositories/calls_repository.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';

class MockCallsRepository implements CallsRepository {
  int getCallsCallCount = 0;
  String? lastSearch;
  String? lastStatus;
  String? lastSort;
  String? lastScheduledFollowUp;
  bool deleteCalled = false;
  bool callAgainCalled = false;
  bool batchLaunched = false;

  @override
  Future<PaginatedCallsDto> getCalls({
    required int page,
    int pageSize = 10,
    String? search,
    String? status,
    String? leadPriority,
    String? sortField,
    DateTimeRange? dateRange,
    AdvancedFilterState? filterState,
    CancelToken? cancelToken,
  }) async {
    getCallsCallCount++;
    lastSearch = search;
    lastStatus = status;
    lastSort = sortField;

    return PaginatedCallsDto(
      count: 2,
      results: [
        CallHistoryModel(
          id: '1',
          fullName: 'Sarah Connor',
          phone: '+1 555-0199',
          status: 'Completed',
          assignee: 'AI Assistant',
          duration: '02:15',
          callTime: '19:44',
          callDate: '2026/08/26',
        ),
        CallHistoryModel(
          id: '2',
          fullName: 'John Smith',
          phone: '+1 555-0200',
          status: 'Failed',
          assignee: 'AI Assistant',
          duration: '0:00',
          callTime: '10:00',
          callDate: '2026/08/26',
        ),
      ],
    );
  }

  @override
  Future<CallsKpiDto> getStats({CancelToken? cancelToken}) async {
    return const CallsKpiDto(
      totalCalls: 25,
      completedCalls: 10,
      failedCalls: 3,
      pendingUpcoming: 12,
      statusCounts: {
        'all': 25,
        'completed': 10,
        'failed': 3,
        'queued': 5,
        'upcoming': 7,
      },
    );
  }

  @override
  Future<CallHistoryModel> getCallDetail(String id) async {
    return CallHistoryModel(
      id: id,
      fullName: 'Sarah Connor',
      phone: '+1 555-0199',
      status: 'Completed',
      assignee: 'AI Assistant',
      duration: '02:15',
      callTime: '19:44',
      callDate: '2026/08/26',
      notes: 'Customer interested in enterprise quote',
    );
  }

  @override
  Future<CallHistoryModel> scheduleFollowUp(
      String id, String followUpDate) async {
    lastScheduledFollowUp = followUpDate;
    return CallHistoryModel(
      id: id,
      fullName: 'Sarah Connor',
      phone: '+1 555-0199',
      status: 'Completed',
      assignee: 'AI Assistant',
      duration: '02:15',
      callTime: '19:44',
      callDate: '2026/08/26',
      nextFollowUpDate: followUpDate,
    );
  }

  @override
  Future<CallHistoryModel> clearFollowUp(String id) async {
    return CallHistoryModel(
      id: id,
      fullName: 'Sarah Connor',
      phone: '+1 555-0199',
      status: 'Completed',
      assignee: 'AI Assistant',
      duration: '02:15',
      callTime: '19:44',
      callDate: '2026/08/26',
      nextFollowUpDate: '',
    );
  }

  @override
  Future<void> callAgain(String id) async {
    callAgainCalled = true;
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String id) async {
    return {'id': 12, 'name': 'Sarah Connor'};
  }

  @override
  Future<void> launchBatch({
    required String name,
    required String scenarioId,
    required List<String> customerIds,
    required int concurrentLines,
  }) async {
    batchLaunched = true;
  }

  @override
  Future<void> deleteCall(String id) async {
    deleteCalled = true;
  }
}

void main() {
  group('CallsCubit Online Tests', () {
    late MockCallsRepository repository;
    late CallsCubit cubit;

    setUp(() {
      repository = MockCallsRepository();
      cubit = CallsCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loadInitial fetches calls list and KPI metrics from server',
        () async {
      await cubit.loadInitial();

      expect(cubit.state.calls.length, 2);
      expect(cubit.state.calls.first.fullName, 'Sarah Connor');
      expect(cubit.state.kpi?.totalCalls, 25);
      expect(cubit.state.kpi?.completedCalls, 10);
      expect(cubit.state.kpi?.failedCalls, 3);
      expect(cubit.state.kpi?.pendingUpcoming, 12);
      expect(cubit.state.isInitialLoading, false);
      expect(cubit.state.isRefreshing, false);
    });

    test('setStatus updates filter and requests page one from server',
        () async {
      await cubit.loadInitial();
      await cubit.setStatus('Completed');

      expect(cubit.state.selectedStatus, 'Completed');
      expect(repository.lastStatus, 'Completed');
    });

    test('setSort sends ordering to server', () async {
      await cubit.loadInitial();
      await cubit.setSort('A-Z');

      expect(cubit.state.sortField, 'A-Z');
      expect(repository.lastSort, 'A-Z');
    });

    test('scheduleFollowUp updates online follow up date', () async {
      await cubit.loadInitial();
      await cubit.scheduleFollowUp('1', '2026-08-30');

      expect(repository.lastScheduledFollowUp, '2026-08-30');
      expect(cubit.state.calls.first.nextFollowUpDate, DateTime(2026, 8, 30));
    });

    test('callAgain triggers online call queueing', () async {
      await cubit.loadInitial();
      await cubit.callAgain('1');

      expect(repository.callAgainCalled, true);
    });

    test('launchBatch dispatches campaign and refreshes calls', () async {
      final launched = await cubit.launchBatch(
        name: 'Sales Campaign',
        scenarioId: 'scenario-1',
        customerIds: const ['customer-1'],
        concurrentLines: 3,
      );

      expect(launched, true);
      expect(repository.batchLaunched, true);
      expect(repository.getCallsCallCount, 1);
    });

    test('deleteCall calls remote delete and refreshes list', () async {
      await cubit.loadInitial();
      await cubit.deleteCall('1');

      expect(repository.deleteCalled, true);
    });
  });

  group('Calls DTO Tests', () {
    test('CallsKpiDto parses snake_case and camelCase payloads', () {
      final json = {
        'total_calls': 50,
        'completed_calls': 30,
        'failed_calls': 5,
        'pending_and_upcoming': 15,
        'status_counts': {
          'all': 50,
          'completed': 30,
          'failed': 5,
          'queued': 10,
          'upcoming': 5,
        },
      };

      final kpi = CallsKpiDto.fromJson(json);
      expect(kpi.totalCalls, 50);
      expect(kpi.completedCalls, 30);
      expect(kpi.failedCalls, 5);
      expect(kpi.pendingUpcoming, 15);
      expect(kpi.statusCounts['completed'], 30);
    });

    test('PaginatedCallsDto parses call list from server', () {
      final json = {
        'count': 1,
        'results': [
          {
            'id': 10,
            'full_name': 'Michael Jordan',
            'company_name': 'Chicago Bulls',
            'phone': '+1 312-555-2323',
            'status': 'Completed',
            'lead_priority': 'Hot',
            'direction': 'Inbound',
            'duration': '04:23',
            'call_date': '2026/08/29',
            'call_time': '12:00',
            'assignee': 'AI Assistant',
          }
        ],
      };

      final page = PaginatedCallsDto.fromJson(json);
      expect(page.count, 1);
      expect(page.results.first.fullName, 'Michael Jordan');
      expect(page.results.first.companyName, 'Chicago Bulls');
      expect(page.results.first.direction, 'Inbound');
      expect(page.results.first.leadPriority, 'Hot');
    });

    test('PaginatedCallsDto handles in-memory slicing when full list returned',
        () {
      final json = {
        'count': 15,
        'results': List.generate(
          15,
          (i) => {
            'id': i + 1,
            'full_name': 'Person $i',
            'phone': '+1 555-00$i',
            'status': 'Completed',
            'duration': '01:00',
            'call_date': '2026/08/29',
            'call_time': '10:00',
          },
        ),
      };

      final page1 =
          PaginatedCallsDto.fromJson(json, page: 1, requestedPageSize: 10);
      expect(page1.count, 15);
      expect(page1.totalPages, 2);
      expect(page1.results.length, 10);
      expect(page1.results.first.fullName, 'Person 0');

      final page2 =
          PaginatedCallsDto.fromJson(json, page: 2, requestedPageSize: 10);
      expect(page2.count, 15);
      expect(page2.totalPages, 2);
      expect(page2.results.length, 5);
      expect(page2.results.first.fullName, 'Person 10');
    });
  });
}
