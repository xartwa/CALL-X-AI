import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/features/customers/widgets/customers_table_widget.dart';
import 'package:callx_ai/features/customers/widgets/customers_headers.dart';
import 'package:callx_ai/features/customers/widgets/add_customer_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_pagination_widget.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/cupertino.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/widgets/advanced_filter_dialog.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  DateTimeRange? _selectedDateRange;
  AdvancedFilterState _filterState = const AdvancedFilterState();
  String _sortField = 'Default';

  @override
  void initState() {
    super.initState();
    context.read<CustomersCubit>().loadInitial(resetFilters: true);
  }

  void _showAddCustomerDialog(BuildContext context) async {
    final text = AppStrings.current;
    final newUser = await AddCustomerDialog.show(context);
    if (newUser != null && context.mounted) {
      await context.read<CustomersCubit>().addCustomer(newUser);
      if (context.mounted) {
        final error = context.read<CustomersCubit>().state.actionError;
        AppUtils.showSnackBar(
          context: context,
          extraMessage: error ?? text.addCustomerSuccess,
          toastificationType: error == null
              ? ToastificationType.success
              : ToastificationType.error,
        );
      }
    }
  }

  Future<void> _importCustomers(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );
    if (!context.mounted || picked == null) return;
    final file = picked.files.single;
    if (file.size > 10 * 1024 * 1024 || file.path == null) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Select an .xlsx file smaller than 10 MB.',
        toastificationType: ToastificationType.error,
      );
      return;
    }
    final result =
        await context.read<CustomersCubit>().importCustomers(file.path!);
    if (!context.mounted || result == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import complete'),
        content: Text(
            'Created: ${result.created}\nUpdated: ${result.updated}${result.errors.isEmpty ? '' : '\n\n${result.errors.join('\n')}'}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  Future<void> _exportCustomers(BuildContext context) async {
    final bytes = await context.read<CustomersCubit>().exportCustomers();
    if (!context.mounted || bytes == null) return;
    await FilePicker.platform.saveFile(
      dialogTitle: 'Export customers',
      fileName: 'customers.xlsx',
      bytes: Uint8List.fromList(bytes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        if (state.isInitialLoading && state.users.isEmpty) {
          return const AppLoadingView(message: 'Loading customers…');
        }
        if (state.listError != null && state.users.isEmpty) {
          return AppErrorView(
            message: state.listError!,
            onRetry: () => context.read<CustomersCubit>().loadPage(),
          );
        }
        final totalUsers = state.kpi?.totalCustomers ?? state.pagination.count;
        final activeUsers = state.kpi?.activeAccounts ??
            state.users.where((u) => u.status == 'Active').length;
        final deactiveUsers = state.kpi?.inactiveAccounts ??
            state.users.where((u) => u.status == 'Deactive').length;
        final contactedUsers = state.kpi?.contactedToday ??
            state.users.where((u) => u.lastContact != null).length;

        final Map<String, int> statusCounts = {
          'All': totalUsers,
          'Active': activeUsers,
          'Deactive': deactiveUsers,
        };

        final paginatedUsers = state.users;
        final activePage = state.pagination.currentPage;
        final totalPages = state.pagination.totalPages;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Banner Row
            Row(
              spacing: 12,
              children: [
                StatCardWidget(
                  label: AppStrings.current.customersTotalCustomers,
                  value: '$totalUsers',
                  icon: CupertinoIcons.group_solid,
                  iconColor: context.colors.primaryLightColor,
                  iconBgColor:
                      context.colors.primaryLightColor.withOpacity(0.12),
                ),
                StatCardWidget(
                  label: AppStrings.current.customersActiveAccounts,
                  value: '$activeUsers',
                  icon: CupertinoIcons.checkmark_alt_circle,
                  iconColor: context.colors.successColor,
                  iconBgColor: context.colors.successColor.withOpacity(0.12),
                ),
                StatCardWidget(
                  label: AppStrings.current.customersInactiveAccounts,
                  value: '$deactiveUsers',
                  icon: CupertinoIcons.minus_circle,
                  iconColor: context.colors.errorColor,
                  iconBgColor: context.colors.errorColor.withOpacity(0.12),
                ),
                StatCardWidget(
                  label: AppStrings.current.customersContactedToday,
                  value: '$contactedUsers',
                  icon: CupertinoIcons.phone_badge_plus,
                  iconColor: context.colors.queuedColor,
                  iconBgColor: context.colors.queuedColor.withOpacity(0.12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomersHeaders(
                selectedStatus: _statusFilter,
                selectedSort: _sortField,
                selectedDateRange: _selectedDateRange,
                filterState: _filterState,
                countries: state.options == null
                    ? null
                    : ['All Countries', ...state.options!.country],
                provinces: state.options == null
                    ? null
                    : ['All Provinces', ...state.options!.state],
                cities: state.options == null
                    ? null
                    : ['All Cities', ...state.options!.city],
                priorities: state.options == null
                    ? null
                    : ['All Priorities', ...state.options!.leadPriority],
                statusCounts: statusCounts,
                onStatusChanged: (status) {
                  setState(() => _statusFilter = status);
                  context.read<CustomersCubit>().setFilters(CustomerFilters(
                      status: status == 'All' ? null : status,
                      search: _searchQuery));
                },
                onDateRangeChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
                  });
                },
                onFilterApplied: (state) {
                  setState(() {
                    _filterState = state;
                  });
                  final current = context.read<CustomersCubit>().state.filters;
                  context.read<CustomersCubit>().setFilters(CustomerFilters(
                        search: _searchQuery,
                        country: state.country.startsWith('All')
                            ? null
                            : state.country,
                        state: state.province.startsWith('All')
                            ? null
                            : state.province,
                        city: state.city.startsWith('All') ? null : state.city,
                        leadPriority: state.priority.startsWith('All')
                            ? null
                            : state.priority,
                        status: current.status,
                        sort: current.sort,
                      ));
                },
                onSearchChanged: (query) {
                  setState(() => _searchQuery = query);
                  context.read<CustomersCubit>().search(query);
                },
                onSortChanged: (sort) {
                  setState(() => _sortField = sort);
                  final mapped = sort == 'Name (A-Z)'
                      ? 'az'
                      : sort == 'Name (Z-A)'
                          ? 'za'
                          : sort == 'Date (Oldest)'
                              ? 'oldest'
                              : 'newest';
                  context.read<CustomersCubit>().setSort(mapped);
                },
                onAddPressed: () => _showAddCustomerDialog(context),
                onImportPressed: () => _importCustomers(context),
                onExportPressed: () => _exportCustomers(context)),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                color: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                ),
                child: state.isRefreshing && paginatedUsers.isEmpty
                    ? const AppLoadingView(compact: true)
                    : paginatedUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.search,
                                  size: 48,
                                  color: context.colors.darkGreyColor
                                      .withOpacity(0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.current.customersNoCustomersFound,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No matches for "$_searchQuery" in this category.'
                                      : 'No customers available in this category.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_searchQuery.isNotEmpty ||
                                    _statusFilter != 'All' ||
                                    _filterState.isActive ||
                                    _sortField != 'Default')
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _statusFilter = 'All';
                                        _filterState =
                                            const AdvancedFilterState();
                                        _sortField = 'Default';
                                        _selectedDateRange = null;
                                      });
                                      context
                                          .read<CustomersCubit>()
                                          .setFilters(const CustomerFilters());
                                    },
                                    icon: const Icon(
                                        CupertinoIcons.refresh_circled,
                                        size: 16),
                                    label: const Text('Clear Filters',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: UsersTableWidget(
                                  users: paginatedUsers,
                                  onRemoveUser: (user) {
                                    context
                                        .read<CustomersCubit>()
                                        .deleteCustomer(user.id);
                                  },
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
                                    context
                                        .read<CustomersCubit>()
                                        .loadPage(page: page);
                                  },
                                ),
                              ],
                            ],
                          ),
              ),
            ),
          ],
        ).withPullToRefresh(
          onRefresh: context.read<CustomersCubit>().refresh,
        );
      },
    );
  }
}
