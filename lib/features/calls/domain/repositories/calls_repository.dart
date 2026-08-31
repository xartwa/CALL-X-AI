import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/dto/calls_kpi_dto.dart';
import '../../data/dto/paginated_calls_dto.dart';
import '../../models/call_history_model.dart';
import '../../../../core/widgets/advanced_filter_dialog.dart';

abstract class CallsRepository {
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
  });

  Future<CallsKpiDto> getStats({CancelToken? cancelToken});

  Future<CallHistoryModel> getCallDetail(String id);

  Future<CallHistoryModel> scheduleFollowUp(String id, String followUpDate);

  Future<CallHistoryModel> clearFollowUp(String id);

  Future<void> callAgain(String id);

  Future<Map<String, dynamic>> getCustomerInfo(String id);

  Future<void> launchBatch({
    required String name,
    required String scenarioId,
    required List<String> customerIds,
    required int concurrentLines,
  });

  Future<void> deleteCall(String id);
}
