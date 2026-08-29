import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/advanced_filter_dialog.dart';
import '../../data/dto/calls_kpi_dto.dart';
import '../../data/dto/paginated_calls_dto.dart';
import '../../domain/repositories/calls_repository.dart';
import '../../models/call_history_model.dart';
import '../datasources/calls_remote_data_source.dart';

class CallsRepositoryImpl implements CallsRepository {
  const CallsRepositoryImpl(this.remote);
  final CallsRemoteDataSource remote;

  T _guard<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.invalidData);
    }
  }

  Future<T> _request<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

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
  }) =>
      _request(() async {
        final Map<String, dynamic> query = {
          'page': page,
          'page_size': pageSize,
        };

        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }

        if (status != null && status != 'All' && status.isNotEmpty) {
          query['status'] = status;
        }

        if (leadPriority != null &&
            leadPriority != 'All' &&
            leadPriority.isNotEmpty) {
          query['lead_priority'] = leadPriority;
        }

        if (sortField != null && sortField != 'Default') {
          switch (sortField) {
            case 'A-Z':
              query['ordering'] = 'full_name';
              break;
            case 'Z-A':
              query['ordering'] = '-full_name';
              break;
            case 'Newest First':
              query['ordering'] = '-created_at';
              break;
            case 'Oldest First':
              query['ordering'] = 'created_at';
              break;
            case 'Longest Duration':
              query['ordering'] = '-duration';
              break;
            case 'Shortest Duration':
              query['ordering'] = 'duration';
              break;
          }
        }

        if (dateRange != null) {
          final fmt = DateFormat('yyyy-MM-dd');
          query['date_from'] = fmt.format(dateRange.start);
          query['date_to'] = fmt.format(dateRange.end);
        }

        if (filterState != null) {
          if (filterState.country.isNotEmpty &&
              !filterState.country.startsWith('All')) {
            query['country'] = filterState.country;
          }
          if (filterState.province.isNotEmpty &&
              !filterState.province.startsWith('All')) {
            query['state'] = filterState.province;
          }
          if (filterState.city.isNotEmpty &&
              !filterState.city.startsWith('All')) {
            query['city'] = filterState.city;
          }
          if (filterState.priority.isNotEmpty &&
              filterState.priority != 'All') {
            query['lead_priority'] = filterState.priority;
          }
        }

        final data = await remote.list(query, cancelToken: cancelToken);
        return _guard(() {
          if (data is List) {
            final results = data
                .whereType<Map>()
                .map((m) =>
                    CallHistoryModel.fromJson(Map<String, dynamic>.from(m)))
                .toList(growable: false);
            return PaginatedCallsDto(
              count: results.length,
              results: results,
            );
          }
          final json = Map<String, dynamic>.from(data as Map);
          return PaginatedCallsDto.fromJson(json);
        });
      });

  @override
  Future<CallsKpiDto> getStats({CancelToken? cancelToken}) =>
      _request(() async {
        final raw = await remote.stats(cancelToken: cancelToken);
        return _guard(() => CallsKpiDto.fromJson(raw));
      });

  @override
  Future<CallHistoryModel> getCallDetail(String id) => _request(() async {
        final raw = await remote.detail(id);
        return _guard(() => CallHistoryModel.fromJson(raw));
      });

  @override
  Future<CallHistoryModel> scheduleFollowUp(String id, String followUpDate) =>
      _request(() async {
        final raw = await remote.scheduleFollowUp(id, followUpDate);
        return _guard(() => CallHistoryModel.fromJson(raw));
      });

  @override
  Future<CallHistoryModel> clearFollowUp(String id) => _request(() async {
        final raw = await remote.clearFollowUp(id);
        return _guard(() => CallHistoryModel.fromJson(raw));
      });

  @override
  Future<void> callAgain(String id) => _request(() async {
        await remote.callAgain(id);
      });

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String id) =>
      _request(() async {
        return await remote.customerInfo(id);
      });

  @override
  Future<void> deleteCall(String id) => _request(() async {
        await remote.delete(id);
      });
}
