import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  int _currentPage = 1;
  static const int _pageSize = 5;
  String _searchQuery = '';
  String _statusFilter = 'All';
  DateTimeRange? _selectedDateRange;
  AdvancedFilterState _filterState = const AdvancedFilterState();
  String _sortField = 'Default';

  final List<User> mockImportUsers = [
    User(
      id: -1,
      fullName: 'David Sterling',
      companyName: 'Metro Contracting Ltd',
      email: 'david@metrocontracting.ca',
      phone: '0912 777 5544',
      createdAt: '2026/08/10',
      lastContact: 'Never',
      status: 'Active',
      jobTitle: 'Senior Estimator',
      companyType: 'GC',
      leadStatus: 'New',
      leadPriority: 'Hot',
      leadQuality: 'Excellent',
      city: 'Vancouver',
      state: 'BC',
      country: 'Canada',
      nextFollowUpDate: '2026/08/20',
      tags: ['GC', 'Hot Lead', 'Vancouver'],
      reasonForContact: 'Commercial high-rise framing quote',
    ),
    User(
      id: -1,
      fullName: 'Elena Rostova',
      companyName: 'Aura Interior Architecture',
      email: 'elena@auradesign.com',
      phone: '0935 444 8899',
      createdAt: '2026/08/11',
      lastContact: 'Never',
      status: 'Active',
      jobTitle: 'Principal Designer',
      companyType: 'Agency',
      leadStatus: 'Contacted',
      leadPriority: 'Warm',
      leadQuality: 'Good',
      city: 'Toronto',
      state: 'ON',
      country: 'Canada',
      nextFollowUpDate: '2026/08/25',
      tags: ['Design', 'Branding', 'Toronto'],
      reasonForContact: 'Demo request for sales pipeline',
    ),
    User(
      id: -1,
      fullName: 'Brian O\'Connor',
      companyName: 'Titan Structural Trades',
      email: 'brian@titantrades.com',
      phone: '0930 555 1234',
      createdAt: '2026/08/12',
      lastContact: 'Never',
      status: 'Deactive',
      jobTitle: 'Operations Manager',
      companyType: 'Trade',
      leadStatus: 'Qualified',
      leadPriority: 'Cold',
      leadQuality: 'Average',
      city: 'Calgary',
      state: 'AB',
      country: 'Canada',
      tags: ['Trade', 'Calgary'],
      reasonForContact: 'System inquiry and pricing',
    ),
  ];

  void _showAddCustomerDialog(BuildContext context) async {
    final text = AppStrings.current;
    final newUser = await AddCustomerDialog.show(context);
    if (newUser != null) {
      if (context.mounted) {
        context.read<CustomersCubit>().addCustomer(newUser);
        AppUtils.showSnackBar(
          context: context,
          extraMessage: text.addCustomerSuccess,
          toastificationType: ToastificationType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final totalUsers = state.users.length;
        final activeUsers =
            state.users.where((u) => u.status == 'Active').length;
        final deactiveUsers =
            state.users.where((u) => u.status == 'Deactive').length;
        final contactedUsers =
            state.users.where((u) => u.lastContact != 'Never').length;

        final Map<String, int> statusCounts = {
          'All': totalUsers,
          'Active': activeUsers,
          'Deactive': deactiveUsers,
        };

        // Filter the users across all fields
        final filteredUsers = state.users.where((user) {
          final q = _searchQuery.toLowerCase().trim();
          final matchesQuery = q.isEmpty ||
              user.fullName.toLowerCase().contains(q) ||
              user.companyName.toLowerCase().contains(q) ||
              user.jobTitle.toLowerCase().contains(q) ||
              user.email.toLowerCase().contains(q) ||
              user.phone.contains(q) ||
              user.city.toLowerCase().contains(q) ||
              user.companyType.toLowerCase().contains(q) ||
              user.leadPriority.toLowerCase().contains(q) ||
              user.tags.any((t) => t.toLowerCase().contains(q));

          final matchesStatus = _statusFilter == 'All' ||
              user.status.toLowerCase() == _statusFilter.toLowerCase();

          final matchesDate = _selectedDateRange == null || () {
            try {
              final parts = user.createdAt.split('/');
              final userDate = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
              final start = DateTime(_selectedDateRange!.start.year,
                  _selectedDateRange!.start.month, _selectedDateRange!.start.day);
              final end = DateTime(_selectedDateRange!.end.year,
                  _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
              return userDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
                  userDate.isBefore(end.add(const Duration(seconds: 1)));
            } catch (_) {
              return true;
            }
          }();

          final matchesCountry = _filterState.country == 'All Countries' ||
              user.country.toLowerCase().contains(_filterState.country.toLowerCase());
          final matchesCity = _filterState.city == 'All Cities' ||
              user.city.toLowerCase().contains(_filterState.city.toLowerCase());
          final matchesPriority = _filterState.priority == 'All Priorities' ||
              user.leadPriority.toLowerCase() == _filterState.priority.toLowerCase();

          return matchesQuery && matchesStatus && matchesDate && matchesCountry && matchesCity && matchesPriority;
        }).toList();

        // Apply sorting
        if (_sortField != 'Default') {
          filteredUsers.sort((a, b) {
            switch (_sortField) {
              case 'Name (A-Z)':
                return a.fullName
                    .toLowerCase()
                    .compareTo(b.fullName.toLowerCase());
              case 'Name (Z-A)':
                return b.fullName
                    .toLowerCase()
                    .compareTo(a.fullName.toLowerCase());
              case 'Date (Newest)':
                return b.createdAt.compareTo(a.createdAt);
              case 'Date (Oldest)':
                return a.createdAt.compareTo(b.createdAt);
              default:
                return 0;
            }
          });
        }

        final filteredCount = filteredUsers.length;
        final totalPages = (filteredCount / _pageSize).ceil();

        // Clamp current page to valid range
        final activePage =
            _currentPage.clamp(1, totalPages > 0 ? totalPages : 1);
        if (activePage != _currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentPage = activePage;
              });
            }
          });
        }

        final startIndex = (activePage - 1) * _pageSize;
        final endIndex = (startIndex + _pageSize).clamp(0, filteredCount);
        final paginatedUsers = filteredCount > 0
            ? filteredUsers.sublist(startIndex, endIndex)
            : <User>[];

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
                statusCounts: statusCounts,
                onStatusChanged: (status) {
                  setState(() {
                    _statusFilter = status;
                    _currentPage = 1;
                  });
                },
                onDateRangeChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
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
                onAddPressed: () => _showAddCustomerDialog(context),
                onImportPressed: () {},
                onExportPressed: () {}),
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
                child: paginatedUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 48,
                              color:
                                  context.colors.darkGreyColor.withOpacity(0.4),
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
                                _statusFilter != 'All')
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _statusFilter = 'All';
                                  });
                                },
                                icon: const Icon(CupertinoIcons.refresh_circled,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
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
        );
      },
    );
  }
}
