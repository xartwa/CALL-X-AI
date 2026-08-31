import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/features/calls/widgets/call_details_panel.dart';
import 'package:callx_ai/features/calls/widgets/calls_headers.dart';
import 'package:callx_ai/features/calls/widgets/calls_table_widget.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/app_pagination_widget.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallsCubit, CallsState>(
      listenWhen: (prev, curr) =>
          curr.actionFeedbackMessage != null &&
          curr.actionFeedbackMessage != prev.actionFeedbackMessage,
      listener: (context, state) {
        if (state.actionFeedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionFeedbackMessage!),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        final selectedCall = state.selectedCall;
        final totalCalls = state.kpi?.totalCalls ?? state.totalCount;
        final completedCalls = state.kpi?.completedCalls ??
            state.calls
                .where((c) => c.status.toLowerCase() == 'completed')
                .length;
        final failedCalls = state.kpi?.failedCalls ??
            state.calls.where((c) => c.status.toLowerCase() == 'failed').length;
        final pendingCalls = state.kpi?.pendingUpcoming ??
            state.calls
                .where((c) =>
                    c.status.toLowerCase() == 'queued' ||
                    c.status.toLowerCase() == 'upcoming')
                .length;

        // Status counts for header tabs
        final statusCounts = state.kpi?.statusCounts ??
            {
              'All': totalCalls,
              'Completed': completedCalls,
              'Failed': failedCalls,
              'Queued': state.calls
                  .where((c) => c.status.toLowerCase() == 'queued')
                  .length,
              'Upcoming': state.calls
                  .where((c) => c.status.toLowerCase() == 'upcoming')
                  .length,
            };

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: selectedCall != null ? 3 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Stat Cards Row
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 12,
                      children: [
                        StatCardWidget(
                          label: AppStrings.current.callsTotalCalls,
                          value: '$totalCalls',
                          icon: CupertinoIcons.phone,
                          iconColor: context.colors.primaryLightColor,
                          iconBgColor: context.colors.primaryLightColor
                              .withValues(alpha: 0.12),
                        ),
                        StatCardWidget(
                          label: AppStrings.current.callsCompletedCalls,
                          value: '$completedCalls',
                          icon: CupertinoIcons.checkmark_alt_circle,
                          iconColor: context.colors.successColor,
                          iconBgColor: context.colors.successColor
                              .withValues(alpha: 0.12),
                        ),
                        StatCardWidget(
                          label: AppStrings.current.callsFailedCalls,
                          value: '$failedCalls',
                          icon: CupertinoIcons.clear_thick_circled,
                          iconColor: context.colors.errorColor,
                          iconBgColor:
                              context.colors.errorColor.withValues(alpha: 0.12),
                        ),
                        StatCardWidget(
                          label: AppStrings.current.callsPendingUpcoming,
                          value: '$pendingCalls',
                          icon: CupertinoIcons.clock,
                          iconColor: context.colors.queuedColor,
                          iconBgColor: context.colors.queuedColor
                              .withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Toolbar & Filters
                  CallsHeaders(
                    selectedStatus: state.selectedStatus,
                    selectedSort: state.sortField,
                    selectedDateRange: state.selectedDateRange,
                    filterState: state.filterState,
                    statusCounts: statusCounts,
                    onStatusChanged: (status) =>
                        context.read<CallsCubit>().setStatus(status),
                    onFilterApplied: (filterState) =>
                        context.read<CallsCubit>().setFilters(filterState),
                    onSearchChanged: (query) =>
                        context.read<CallsCubit>().setSearch(query),
                    onSortChanged: (sort) =>
                        context.read<CallsCubit>().setSort(sort),
                    onDateRangeChanged: (range) =>
                        context.read<CallsCubit>().setDateRange(range),
                    onCallAdded: () => context.read<CallsCubit>().refresh(),
                  ),
                  const SizedBox(height: 12),

                  // Table Card
                  Expanded(
                    child: Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.boxRadius),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : context.colors.mediumGreyColor
                                  .withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: state.isInitialLoading && state.calls.isEmpty
                          ? const AppLoadingView(compact: true)
                          : state.calls.isEmpty
                              ? AppEmptyView(
                                  title: 'No call records found',
                                  description: state.searchQuery.isNotEmpty
                                      ? 'No results match "${state.searchQuery}". Try changing search or filters.'
                                      : 'No call logs recorded in this category yet.',
                                  icon: CupertinoIcons.phone_down_circle,
                                )
                              : Column(
                                  children: [
                                    Expanded(
                                      child: CallsTableWidget(
                                        calls: state.calls,
                                        onRemoveCall: (call) => context
                                            .read<CallsCubit>()
                                            .deleteCall(call.id),
                                      ),
                                    ),
                                    if (state.totalPages > 1) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: isDark
                                              ? Colors.white10
                                              : context.colors.lightGreyColor,
                                        ),
                                      ),
                                      AppPaginationWidget(
                                        currentPage: state.currentPage,
                                        totalPages: state.totalPages,
                                        onPageChanged: (page) => context
                                            .read<CallsCubit>()
                                            .setPage(page),
                                      ),
                                    ],
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: selectedCall != null
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        CallDetailsPanel(
                          call: selectedCall,
                          onClose: () {
                            context.read<CallsCubit>().selectCall(null);
                          },
                          onCallAdded: () =>
                              context.read<CallsCubit>().refresh(),
                          onDelete: () => context
                              .read<CallsCubit>()
                              .deleteCall(selectedCall.id),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ).withPullToRefresh(
          onRefresh: () async => context.read<CallsCubit>().refresh(),
        );
      },
    );
  }
}
