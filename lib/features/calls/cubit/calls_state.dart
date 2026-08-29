import 'package:flutter/material.dart';
import '../../../../core/widgets/advanced_filter_dialog.dart';
import '../data/dto/calls_kpi_dto.dart';
import '../models/call_history_model.dart';

class CallsState {
  final List<CallHistoryModel> calls;
  final CallsKpiDto? kpi;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingDetail;
  final bool isUpdatingFollowUp;
  final String selectedStatus;
  final String searchQuery;
  final String sortField;
  final DateTimeRange? selectedDateRange;
  final AdvancedFilterState filterState;
  final CallHistoryModel? selectedCall;
  final String? errorMessage;
  final String? actionFeedbackMessage;

  const CallsState({
    this.calls = const [],
    this.kpi,
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 5,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.isLoadingDetail = false,
    this.isUpdatingFollowUp = false,
    this.selectedStatus = 'All',
    this.searchQuery = '',
    this.sortField = 'Default',
    this.selectedDateRange,
    this.filterState = const AdvancedFilterState(),
    this.selectedCall,
    this.errorMessage,
    this.actionFeedbackMessage,
  });

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 9999);

  CallsState copyWith({
    List<CallHistoryModel>? calls,
    CallsKpiDto? kpi,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingDetail,
    bool? isUpdatingFollowUp,
    String? selectedStatus,
    String? searchQuery,
    String? sortField,
    DateTimeRange? selectedDateRange,
    bool clearDateRange = false,
    AdvancedFilterState? filterState,
    CallHistoryModel? selectedCall,
    bool clearSelectedCall = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? actionFeedbackMessage,
    bool clearActionFeedback = false,
  }) {
    return CallsState(
      calls: calls ?? this.calls,
      kpi: kpi ?? this.kpi,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isUpdatingFollowUp: isUpdatingFollowUp ?? this.isUpdatingFollowUp,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      sortField: sortField ?? this.sortField,
      selectedDateRange:
          clearDateRange ? null : (selectedDateRange ?? this.selectedDateRange),
      filterState: filterState ?? this.filterState,
      selectedCall:
          clearSelectedCall ? null : (selectedCall ?? this.selectedCall),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      actionFeedbackMessage: clearActionFeedback
          ? null
          : (actionFeedbackMessage ?? this.actionFeedbackMessage),
    );
  }
}
