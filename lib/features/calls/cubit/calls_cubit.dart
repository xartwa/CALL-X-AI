import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/advanced_filter_dialog.dart';
import '../domain/repositories/calls_repository.dart';
import '../models/call_history_model.dart';
import 'calls_state.dart';

export 'calls_state.dart';

class CallsCubit extends Cubit<CallsState> {
  CallsCubit(this.repository) : super(const CallsState());

  final CallsRepository repository;
  Timer? _debounce;
  CancelToken? _cancelToken;
  int _listRequestId = 0;

  Future<void> loadInitial() async {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    emit(state.copyWith(
      isInitialLoading: true,
      clearErrorMessage: true,
    ));

    await Future.wait([
      _fetchCalls(page: 1),
      _fetchStats(),
    ]);

    if (!isClosed) {
      emit(state.copyWith(isInitialLoading: false, isRefreshing: false));
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    emit(state.copyWith(isRefreshing: true, clearErrorMessage: true));

    await Future.wait([
      _fetchCalls(page: state.currentPage),
      _fetchStats(),
    ]);

    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> setPage(int page) async {
    if (page == state.currentPage) return;
    emit(state.copyWith(currentPage: page, isRefreshing: true));
    await _fetchCalls(page: page);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  void setSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      emit(state.copyWith(searchQuery: query, currentPage: 1, isRefreshing: true));
      _fetchCalls(page: 1).then((_) {
        if (!isClosed) emit(state.copyWith(isRefreshing: false));
      });
    });
  }

  Future<void> setStatus(String status) async {
    if (status == state.selectedStatus) return;
    emit(state.copyWith(selectedStatus: status, currentPage: 1, isRefreshing: true));
    await _fetchCalls(page: 1);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> setSort(String sortField) async {
    if (sortField == state.sortField) return;
    emit(state.copyWith(sortField: sortField, currentPage: 1, isRefreshing: true));
    await _fetchCalls(page: 1);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> setDateRange(DateTimeRange? range) async {
    emit(state.copyWith(
      selectedDateRange: range,
      clearDateRange: range == null,
      currentPage: 1,
      isRefreshing: true,
    ));
    await _fetchCalls(page: 1);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> setFilters(AdvancedFilterState filterState) async {
    emit(state.copyWith(
      filterState: filterState,
      currentPage: 1,
      isRefreshing: true,
    ));
    await _fetchCalls(page: 1);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> selectCall(CallHistoryModel? call) async {
    if (call == null) {
      emit(state.copyWith(clearSelectedCall: true));
      return;
    }

    emit(state.copyWith(selectedCall: call, isLoadingDetail: true));

    try {
      final detailedCall = await repository.getCallDetail(call.id);
      if (!isClosed && state.selectedCall?.id == call.id) {
        emit(state.copyWith(selectedCall: detailedCall, isLoadingDetail: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingDetail: false));
      }
    }
  }

  Future<void> scheduleFollowUp(String callId, String followUpDate) async {
    emit(state.copyWith(isUpdatingFollowUp: true));

    try {
      final updated = await repository.scheduleFollowUp(callId, followUpDate);
      final updatedCalls = state.calls.map((c) => c.id == callId ? updated : c).toList();

      emit(state.copyWith(
        calls: updatedCalls,
        selectedCall: state.selectedCall?.id == callId ? updated : state.selectedCall,
        isUpdatingFollowUp: false,
        actionFeedbackMessage: 'Follow-up scheduled for $followUpDate',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdatingFollowUp: false,
        errorMessage: 'Failed to schedule follow-up.',
      ));
    }
  }

  Future<void> clearFollowUp(String callId) async {
    emit(state.copyWith(isUpdatingFollowUp: true));

    try {
      final updated = await repository.clearFollowUp(callId);
      final updatedCalls = state.calls.map((c) => c.id == callId ? updated : c).toList();

      emit(state.copyWith(
        calls: updatedCalls,
        selectedCall: state.selectedCall?.id == callId ? updated : state.selectedCall,
        isUpdatingFollowUp: false,
        actionFeedbackMessage: 'Follow-up cleared',
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdatingFollowUp: false,
        errorMessage: 'Failed to clear follow-up.',
      ));
    }
  }

  Future<void> callAgain(String callId) async {
    try {
      await repository.callAgain(callId);
      emit(state.copyWith(actionFeedbackMessage: 'Outbound call queued successfully'));
      await refresh();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to initiate outbound call.'));
    }
  }

  Future<void> deleteCall(String callId) async {
    try {
      await repository.deleteCall(callId);
      if (state.selectedCall?.id == callId) {
        emit(state.copyWith(clearSelectedCall: true));
      }
      emit(state.copyWith(actionFeedbackMessage: 'Call record deleted'));
      await refresh();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete call record.'));
    }
  }

  Future<bool> _fetchCalls({required int page}) async {
    final requestId = ++_listRequestId;

    try {
      final result = await repository.getCalls(
        page: page,
        pageSize: state.pageSize,
        search: state.searchQuery,
        status: state.selectedStatus,
        leadPriority: state.filterState.priority,
        sortField: state.sortField,
        dateRange: state.selectedDateRange,
        filterState: state.filterState,
        cancelToken: _cancelToken,
      );

      if (isClosed || requestId != _listRequestId) return false;

      emit(state.copyWith(
        calls: result.results,
        totalCount: result.count,
        currentPage: page,
        clearErrorMessage: true,
      ));
      return true;
    } catch (e) {
      if (isClosed || requestId != _listRequestId) return false;

      if (e is! AppException || e.type != AppErrorType.cancelled) {
        emit(state.copyWith(errorMessage: 'Unable to load call logs.'));
      }
      return false;
    }
  }

  Future<void> _fetchStats() async {
    try {
      final kpi = await repository.getStats(cancelToken: _cancelToken);
      if (!isClosed) {
        emit(state.copyWith(kpi: kpi));
      }
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    return super.close();
  }
}
