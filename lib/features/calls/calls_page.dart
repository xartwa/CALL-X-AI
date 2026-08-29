import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/widgets/call_details_panel.dart';
import 'package:callx_ai/features/calls/widgets/calls_headers.dart';
import 'package:callx_ai/features/calls/widgets/calls_table_widget.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/app_pagination_widget.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/widgets/advanced_filter_dialog.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  int _currentPage = 1;
  static const int _pageSize = 5;

  String _selectedStatus = 'All';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;
  AdvancedFilterState _filterState = const AdvancedFilterState();
  String _sortField = 'Default';

  late List<CallHistoryModel> _allCalls;

  @override
  void initState() {
    super.initState();

    final preferences = context.read<PreferencesService>();
    final loaded = preferences.loadCalls();

    if (loaded.isEmpty) {
      final today = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy/MM/dd');

      final defaultCalls = [
        CallHistoryModel(
          id: '1',
          fullName: 'John Smith',
          companyName: 'ABC Construction',
          phone: '0912 345 6789',
          status: 'Completed',
          assignee: 'Admin',
          duration: '5:32',
          callTime: '10:30',
          callDate: formatter.format(today),
          email: 'john.smith@abcconstruction.ca',
          notes:
              'Customer satisfied with estimation quote and agreed to receive proposal contract.',
          statusColor: context.colors.successColor,
          leadPriority: 'Hot',
          nextFollowUpDate: '2026/08/20',
          tags: ['GC', 'Hot Lead', 'Vancouver'],
          direction: 'Outbound',
        ),
        CallHistoryModel(
          id: '2',
          fullName: 'Sarah Connor',
          companyName: 'Apex Real Estate Development',
          phone: '0935 111 2233',
          status: 'Failed',
          assignee: 'AI',
          duration: '0:00',
          callTime: '14:15',
          callDate: formatter.format(today),
          statusColor: context.colors.errorColor,
          leadPriority: 'Warm',
          nextFollowUpDate: '2026/08/22',
          tags: ['Developer', 'Calgary'],
          direction: 'Inbound',
        ),
        CallHistoryModel(
          id: '3',
          fullName: 'Michael Chang',
          companyName: 'Nexus Digital Agency',
          phone: '0930 777 8899',
          status: 'Completed',
          assignee: 'Admin',
          duration: '3:12',
          callTime: '11:45',
          callDate: formatter.format(today.subtract(const Duration(days: 1))),
          email: 'michael@nexusagency.io',
          notes: 'Inquired about enterprise agency white-label rates',
          statusColor: context.colors.successColor,
          leadPriority: 'Hot',
          nextFollowUpDate: '2026/08/18',
          tags: ['Agency', 'Startup', 'Toronto'],
          direction: 'Outbound',
        ),
        CallHistoryModel(
          id: '4',
          fullName: 'David Sterling',
          companyName: 'Metro Contracting Ltd',
          phone: '0912 777 5544',
          status: 'Failed',
          assignee: 'AI',
          duration: '0:00',
          callTime: '09:20',
          callDate: formatter.format(today.subtract(const Duration(days: 1))),
          statusColor: context.colors.errorColor,
          leadPriority: 'Hot',
          tags: ['GC', 'Vancouver'],
          direction: 'Inbound',
        ),
        CallHistoryModel(
          id: '5',
          fullName: 'Elena Rostova',
          companyName: 'Aura Interior Architecture',
          phone: '0935 444 8899',
          status: 'Completed',
          assignee: 'AI',
          duration: '1:45',
          callTime: '16:30',
          callDate: formatter.format(today.subtract(const Duration(days: 2))),
          email: 'elena@auradesign.com',
          notes: 'Walked through customer dashboard features',
          statusColor: context.colors.successColor,
          leadPriority: 'Warm',
          tags: ['Design', 'Toronto'],
          direction: 'Outbound',
        ),
      ];

      preferences.saveCalls(defaultCalls.map((c) => c.toJson()).toList());
      _allCalls = defaultCalls;
    } else {
      _allCalls = loaded.map((json) {
        Color? statusColor;
        if (json['statusColor'] != null) {
          statusColor = Color(json['statusColor'] as int);
        } else {
          final s = json['status'] as String;
          if (s == 'Completed') {
            statusColor = context.colors.successColor;
          } else if (s == 'Failed') {
            statusColor = context.colors.errorColor;
          } else if (s == 'Queued') {
            statusColor = context.colors.queuedColor;
          } else {
            statusColor = context.colors.primaryLightColor;
          }
        }
        return CallHistoryModel.fromJson(json, defaultStatusColor: statusColor);
      }).toList();
    }
  }

  void _reloadCalls() {
    final preferences = context.read<PreferencesService>();
    final loaded = preferences.loadCalls();
    setState(() {
      _allCalls = loaded.map((json) {
        Color? statusColor;
        if (json['statusColor'] != null) {
          statusColor = Color(json['statusColor'] as int);
        } else {
          final s = json['status'] as String;
          if (s == 'Completed') {
            statusColor = context.colors.successColor;
          } else if (s == 'Failed') {
            statusColor = context.colors.errorColor;
          } else if (s == 'Queued') {
            statusColor = context.colors.queuedColor;
          } else {
            statusColor = context.colors.primaryLightColor;
          }
        }
        return CallHistoryModel.fromJson(json, defaultStatusColor: statusColor);
      }).toList();
    });
  }

  void _updateCall(CallHistoryModel updatedCall) {
    setState(() {
      final index = _allCalls.indexWhere((c) => c.id == updatedCall.id);
      if (index != -1) {
        _allCalls[index] = updatedCall;
        final preferences = context.read<PreferencesService>();
        preferences.saveCalls(_allCalls.map((c) => c.toJson()).toList());
      }
    });
  }

  void _removeCall(CallHistoryModel call) {
    setState(() {
      _allCalls.removeWhere((c) => c.id == call.id);
      final preferences = context.read<PreferencesService>();
      preferences.saveCalls(_allCalls.map((c) => c.toJson()).toList());
      context.read<SelectedCallCubit>().clearSelection();
    });
  }

  Map<String, int> _getStatusCounts(List<CallHistoryModel> dateFilteredCalls) {
    int all = dateFilteredCalls.length;
    int completed =
        dateFilteredCalls.where((c) => c.status == 'Completed').length;
    int failed = dateFilteredCalls.where((c) => c.status == 'Failed').length;
    int queued = dateFilteredCalls.where((c) => c.status == 'Queued').length;
    int upcoming =
        dateFilteredCalls.where((c) => c.status == 'Upcoming').length;

    return {
      'All': all,
      'Completed': completed,
      'Failed': failed,
      'Queued': queued,
      'Upcoming': upcoming,
    };
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter by date range first
    List<CallHistoryModel> dateFilteredCalls = _allCalls;
    if (_selectedDateRange != null) {
      dateFilteredCalls = _allCalls.where((call) {
        try {
          final parts = call.callDate.split('/');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final start = DateTime(_selectedDateRange!.start.year,
              _selectedDateRange!.start.month, _selectedDateRange!.start.day);
          final end = DateTime(
              _selectedDateRange!.end.year,
              _selectedDateRange!.end.month,
              _selectedDateRange!.end.day,
              23,
              59,
              59);
          return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              date.isBefore(end.add(const Duration(seconds: 1)));
        } catch (_) {
          return true;
        }
      }).toList();
    }

    // Calculate status counts based on date-filtered calls
    final Map<String, int> statusCounts = _getStatusCounts(dateFilteredCalls);

    // 2. Filter by status and search
    List<CallHistoryModel> filteredCalls = dateFilteredCalls.where((call) {
      final matchesStatus = _selectedStatus == 'All' ||
          call.status.toLowerCase() == _selectedStatus.toLowerCase();
      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          call.fullName.toLowerCase().contains(q) ||
          call.companyName.toLowerCase().contains(q) ||
          call.phone.contains(q) ||
          call.status.toLowerCase().contains(q) ||
          call.assignee.toLowerCase().contains(q) ||
          (call.notes != null && call.notes!.toLowerCase().contains(q));
      final matchesPriority = _filterState.priority == 'All' ||
          _filterState.priority == 'All Priorities' ||
          (call.leadPriority != null &&
              call.leadPriority!.toLowerCase() ==
                  _filterState.priority.toLowerCase());
      return matchesStatus && matchesQuery && matchesPriority;
    }).toList();

    // Apply sorting
    if (_sortField != 'Default') {
      filteredCalls.sort((a, b) {
        switch (_sortField) {
          case 'Date (Newest)':
            return b.callDate.compareTo(a.callDate);
          case 'Date (Oldest)':
            return a.callDate.compareTo(b.callDate);
          case 'Customer (A-Z)':
            return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
          case 'Customer (Z-A)':
            return b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase());
          default:
            return 0;
        }
      });
    }

    final totalFilteredCalls = dateFilteredCalls.length;
    final completedCalls =
        dateFilteredCalls.where((c) => c.status == 'Completed').length;
    final failedCalls =
        dateFilteredCalls.where((c) => c.status == 'Failed').length;
    final pendingCalls = dateFilteredCalls
        .where((c) => c.status == 'Queued' || c.status == 'Upcoming')
        .length;

    final totalCalls = filteredCalls.length;
    final totalPages = (totalCalls / _pageSize).ceil();
    final activePage = _currentPage.clamp(1, totalPages > 0 ? totalPages : 1);

    final startIndex = (activePage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalCalls);
    final paginatedCalls = filteredCalls.sublist(startIndex, endIndex);

    return BlocProvider(
      create: (_) => SelectedCallCubit(),
      child: BlocBuilder<SelectedCallCubit, dynamic>(
        builder: (context, selectedCall) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: selectedCall != null ? 3 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 16,
                      children: [
                        StatCardWidget(
                          label: AppStrings.current.callsTotalCalls,
                          value: '$totalFilteredCalls',
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
                          iconBgColor:
                              context.colors.successColor.withValues(alpha: 0.12),
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
                          iconBgColor:
                              context.colors.queuedColor.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CallsHeaders(
                      selectedStatus: _selectedStatus,
                      selectedSort: _sortField,
                      selectedDateRange: _selectedDateRange,
                      filterState: _filterState,
                      statusCounts: statusCounts,
                      onStatusChanged: (status) {
                        setState(() {
                          _selectedStatus = status;
                          _currentPage = 1;
                        });
                      },
                      onFilterApplied: (state) {
                        setState(() {
                          _filterState = state;
                          _currentPage = 1;
                        });
                      },
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                          _currentPage = 1;
                        });
                      },
                      onSortChanged: (sort) {
                        setState(() {
                          _sortField = sort;
                          _currentPage = 1;
                        });
                      },
                      onDateRangeChanged: (range) {
                        setState(() {
                          _selectedDateRange = range;
                          _currentPage = 1;
                        });
                      },
                      onCallAdded: _reloadCalls,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.zero,
                        color: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeConstants.boxRadius),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: CallsTableWidget(
                                calls: paginatedCalls,
                                onRemoveCall: _removeCall,
                              ),
                            ),
                            if (totalPages > 1) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white10
                                      : context.colors.lightGreyColor,
                                ),
                              ),
                              AppPaginationWidget(
                                currentPage: activePage,
                                totalPages: totalPages,
                                onPageChanged: (page) {
                                  setState(() {
                                    _currentPage = page;
                                  });
                                },
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
                            onCallAdded: _reloadCalls,
                            onCallUpdated: (updated) {
                              _updateCall(updated);
                              context
                                  .read<SelectedCallCubit>()
                                  .updateCall(updated);
                            },
                            onDelete: () => _removeCall(selectedCall),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ).withPullToRefresh(
            onRefresh: () async => _reloadCalls(),
          );
        },
      ),
    );
  }
}
