import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_pagination_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/custom_tag_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../cubit/appointments_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../widgets/appointment_details_drawer.dart';
import '../widgets/schedule_request_drawer.dart';

String _stripHtml(String? input) {
  if (input == null || input.isEmpty) return 'No notes provided';
  var text = input
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'#CALLX', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text.isNotEmpty ? text : 'No notes provided';
}

class RequestsTabView extends StatefulWidget {
  const RequestsTabView({super.key});

  @override
  State<RequestsTabView> createState() => _RequestsTabViewState();
}

class _RequestsTabViewState extends State<RequestsTabView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _listMode = 0; // 0 = All Appointments, 1 = Lead Requests
  bool _isSearchExpanded = false;
  int _appointmentsPage = 1;
  int _requestsPage = 1;
  static const int _pageSize = 10;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cubit = context.read<AppointmentsCubit>();
        final isConnected = state.calendarConnection.connected;

        if (!isConnected) {
          return _buildDisconnectedState(context, isDark, cubit);
        }

        final appointments = state.filteredAppointments;
        final requests = state.filteredRequests;

        final appointmentsTotalPages = (appointments.length / _pageSize).ceil();
        final safeAppointmentsPage = appointmentsTotalPages > 0
            ? _appointmentsPage.clamp(1, appointmentsTotalPages)
            : 1;
        final apptStart = (safeAppointmentsPage - 1) * _pageSize;
        final apptEnd = (apptStart + _pageSize < appointments.length)
            ? apptStart + _pageSize
            : appointments.length;
        final pagedAppointments = apptStart < appointments.length
            ? appointments.sublist(apptStart, apptEnd)
            : <AppointmentEntity>[];

        final requestsTotalPages = (requests.length / _pageSize).ceil();
        final safeRequestsPage = requestsTotalPages > 0
            ? _requestsPage.clamp(1, requestsTotalPages)
            : 1;
        final reqStart = (safeRequestsPage - 1) * _pageSize;
        final reqEnd = (reqStart + _pageSize < requests.length)
            ? reqStart + _pageSize
            : requests.length;
        final pagedRequests = reqStart < requests.length
            ? requests.sublist(reqStart, reqEnd)
            : <AppointmentRequestEntity>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Top Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              ),
              child: Row(
                children: [
                  // Left: Segmented Tabs (Identical to Calendar Week/Month)
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildModePill(
                          context: context,
                          label: 'All Appointments (${state.appointments.length})',
                          selected: _listMode == 0,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _listMode = 0;
                            _appointmentsPage = 1;
                          }),
                        ),
                        const SizedBox(width: 4),
                        _buildModePill(
                          context: context,
                          label: 'Lead Requests (${state.requests.length})',
                          selected: _listMode == 1,
                          isDark: isDark,
                          onTap: () => setState(() {
                            _listMode = 1;
                            _requestsPage = 1;
                          }),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Right: Expandable Search (Matches Customers & Email Follow-ups)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                        ? 220
                        : 36,
                    height: 36,
                    child: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : context.colors.lightGreyColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Icon(CupertinoIcons.search,
                                    size: 15,
                                    color: context.colors.darkGreyColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    focusNode: _searchFocusNode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: context.colors.darkGreyColor,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8),
                                    ),
                                    onChanged: (val) {
                                      cubit.setSearchQuery(val);
                                      setState(() {
                                        _appointmentsPage = 1;
                                        _requestsPage = 1;
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    _searchFocusNode.unfocus();
                                    cubit.setSearchQuery('');
                                    setState(() {
                                      _isSearchExpanded = false;
                                      _appointmentsPage = 1;
                                      _requestsPage = 1;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Icon(CupertinoIcons.clear_thick,
                                        size: 12,
                                        color: context.colors.darkGreyColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              setState(() {
                                _isSearchExpanded = true;
                              });
                              Future.delayed(
                                  const Duration(milliseconds: 50), () {
                                _searchFocusNode.requestFocus();
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : context.colors.lightGreyColor,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.search,
                                  size: 15,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),

                  // Status Dropdown Filter (Matches Calls, Customers & Calendar)
                  PopupMenuButton<String>(
                    tooltip: 'Filter by Status',
                    onSelected: (val) {
                      cubit.setStatusFilter(val);
                      setState(() {
                        _appointmentsPage = 1;
                        _requestsPage = 1;
                      });
                    },
                    offset: const Offset(0, 40),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder: (ctx) {
                      final options = _listMode == 0
                          ? [
                              'All',
                              'Confirmed',
                              'Pending',
                              'Rescheduled',
                              'Completed',
                              'Cancelled'
                            ]
                          : [
                              'All',
                              'Pending',
                              'Scheduled',
                              'Closed',
                              'Cancelled'
                            ];
                      return options.map((status) {
                        final isSelected =
                            state.selectedStatusFilter.toLowerCase() ==
                                status.toLowerCase();
                        return PopupMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: state.selectedStatusFilter != 'All'
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.08)
                            : Colors.transparent,
                        border: Border.all(
                          color: state.selectedStatusFilter != 'All'
                              ? Theme.of(context).colorScheme.primary
                              : (isDark
                                  ? Colors.white10
                                  : context.colors.lightGreyColor),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.line_horizontal_3_decrease,
                            size: 14,
                            color: state.selectedStatusFilter != 'All'
                                ? Theme.of(context).colorScheme.primary
                                : context.colors.darkGreyColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.selectedStatusFilter == 'All'
                                ? 'Status'
                                : state.selectedStatusFilter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: state.selectedStatusFilter != 'All'
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Refresh Button (matches Calls, Customers & AI Settings)
                  Tooltip(
                    message: 'Refresh',
                    child: InkWell(
                      onTap: state.isActionLoading
                          ? null
                          : () => cubit.refresh(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : context.colors.lightGreyColor,
                          ),
                        ),
                        child: Center(
                          child: state.isActionLoading
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  CupertinoIcons.refresh,
                                  size: 15,
                                  color: context.colors.darkGreyColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Table Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                  border: Border.all(
                    color: context.colors.mediumGreyColor
                        .withValues(alpha: isDark ? 0.35 : 1.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                  child: _listMode == 0
                      ? (appointments.isEmpty
                          ? _buildEmptyAppointmentsState(context, isDark)
                          : Column(
                              children: [
                                Expanded(
                                  child: _buildAppointmentsTable(
                                      context, pagedAppointments, isDark, cubit),
                                ),
                                if (appointmentsTotalPages > 1) ...[
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
                                    currentPage: safeAppointmentsPage,
                                    totalPages: appointmentsTotalPages,
                                    onPageChanged: (page) => setState(() {
                                      _appointmentsPage = page;
                                    }),
                                  ),
                                ],
                              ],
                            ))
                      : (requests.isEmpty
                          ? _buildEmptyRequestsState(context, isDark)
                          : Column(
                              children: [
                                Expanded(
                                  child: _buildRequestsTable(
                                      context, pagedRequests, isDark, cubit),
                                ),
                                if (requestsTotalPages > 1) ...[
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
                                    currentPage: safeRequestsPage,
                                    totalPages: requestsTotalPages,
                                    onPageChanged: (page) => setState(() {
                                      _requestsPage = page;
                                    }),
                                  ),
                                ],
                              ],
                            )),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModePill({
    required BuildContext context,
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? context.colors.whiteColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected
                ? (isDark ? Colors.white : Colors.black87)
                : context.colors.darkGreyColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDisconnectedState(
      BuildContext context, bool isDark, AppointmentsCubit cubit) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.calendar,
                size: 44,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Google Calendar Not Connected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect your Google Calendar account to view, schedule, and synchronize all appointments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.colors.darkGreyColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => cubit.setActiveTab(2),
                icon: const Icon(CupertinoIcons.link, size: 15, color: Colors.white),
                label: const Text(
                  'CONNECT GOOGLE CALENDAR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.calendar_today,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Appointments Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All consultations, Google Calendar events, and scheduled meetings will appear here in list format.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.colors.darkGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRequestsState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.tray,
                size: 40,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Lead Requests',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When AI cold calls identify interested prospects who requested a meeting,\nthey will appear here ready to be scheduled.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.colors.darkGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTable(
    BuildContext context,
    List<AppointmentEntity> appointments,
    bool isDark,
    AppointmentsCubit cubit,
  ) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 20,
      minWidth: 1050,
      headingRowHeight: 50,
      dataRowHeight: 68,
      showCheckboxColumn: false,
      dividerThickness: 0.5,
      headingRowColor: WidgetStatePropertyAll(
        isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      dataTextStyle: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      columns: const [
        DataColumn2(label: Text('PROSPECT / CUSTOMER'), size: ColumnSize.L),
        DataColumn2(label: Text('DATE & TIME'), size: ColumnSize.M),
        DataColumn2(label: Text('TYPE'), size: ColumnSize.S, fixedWidth: 120),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S, fixedWidth: 130),
        DataColumn2(label: Text('NOTES / AGENDA'), size: ColumnSize.L),
        DataColumn2(
            label: Text('ACTIONS'), size: ColumnSize.M, fixedWidth: 140),
      ],
      rows: appointments.map((appt) {
        final localStart = appt.startAt.toLocal();
        final localEnd = appt.endAt.toLocal();
        final dateStr = DateFormat('EEE, MMM d, yyyy').format(localStart);
        final timeStr =
            '${DateFormat('HH:mm').format(localStart)} - ${DateFormat('HH:mm').format(localEnd)}';
        final cleanNotes = _stripHtml(appt.notes?.isNotEmpty == true ? appt.notes : appt.title);

        return DataRow2(
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : Colors.black.withValues(alpha: 0.02);
            }
            return null;
          }),
          cells: [
            // Prospect / Customer
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appt.customerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: context.colors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    appt.companyName.isNotEmpty
                        ? appt.companyName
                        : (appt.customerEmail.isNotEmpty
                            ? appt.customerEmail
                            : (appt.customerPhone.isNotEmpty
                                ? appt.customerPhone
                                : 'Google Calendar Sync')),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.darkGreyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Date & Time
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.colors.blackColor,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Type (Clean CustomTagWidget with integrated Cupertino icons)
            DataCell(
              CustomTagWidget(
                label: appt.isOnline ? 'Online' : 'In-Person',
                icon: appt.isOnline
                    ? CupertinoIcons.videocam_fill
                    : CupertinoIcons.location_solid,
                iconSize: 11.5,
                color: appt.isOnline
                    ? context.colors.infoColor
                    : const Color(0xFF8B5CF6),
              ),
            ),

            // Status
            DataCell(
              CustomTagWidget(
                label: appt.status.toUpperCase(),
                color: _getApptStatusColor(context, appt.status),
              ),
            ),

            // Notes / Agenda (Clean plain text, single line with ellipsis)
            DataCell(
              Tooltip(
                message: cleanNotes,
                child: Text(
                  cleanNotes,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.darkGreyColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Actions (Standardized AppActionButton - Exact match with Customers & Calls)
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appt.isOnline &&
                      appt.meetingUrl != null &&
                      appt.meetingUrl!.isNotEmpty &&
                      !appt.isCancelled) ...[
                    AppActionButton(
                      type: AppActionType.video,
                      tooltip: 'Join Google Meet',
                      onTap: () {
                        if (kIsWeb) {
                          web.window.open(appt.meetingUrl!, '_blank');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  AppActionButton(
                    type: AppActionType.view,
                    tooltip: 'View Details',
                    onTap: () {
                      AppointmentDetailsDrawer.show(context, appt);
                    },
                  ),
                  if (!appt.isCancelled) ...[
                    const SizedBox(width: 8),
                    AppActionButton(
                      type: AppActionType.delete,
                      tooltip: 'Cancel Appointment',
                      onTap: () {
                        _confirmCancelAppointment(context, cubit, appt);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRequestsTable(
    BuildContext context,
    List<AppointmentRequestEntity> requests,
    bool isDark,
    AppointmentsCubit cubit,
  ) {
    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 20,
      minWidth: 1000,
      headingRowHeight: 50,
      dataRowHeight: 68,
      showCheckboxColumn: false,
      dividerThickness: 0.5,
      headingRowColor: WidgetStatePropertyAll(
        isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      dataTextStyle: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      columns: const [
        DataColumn2(label: Text('PROSPECT / CUSTOMER'), size: ColumnSize.L),
        DataColumn2(label: Text('PREFERRED TIME'), size: ColumnSize.M),
        DataColumn2(label: Text('TYPE'), size: ColumnSize.S, fixedWidth: 120),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S, fixedWidth: 120),
        DataColumn2(label: Text('NOTES / AI INTENT'), size: ColumnSize.L),
        DataColumn2(
            label: Text('ACTIONS'), size: ColumnSize.M, fixedWidth: 180),
      ],
      rows: requests.map((req) {
        final isPending = req.status.toLowerCase() == 'pending';
        final isScheduled = req.status.toLowerCase() == 'scheduled';

        return DataRow2(
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : Colors.black.withValues(alpha: 0.02);
            }
            return null;
          }),
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    req.customerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: context.colors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    req.companyName.isNotEmpty
                        ? req.companyName
                        : (req.customerPhone.isNotEmpty
                            ? req.customerPhone
                            : req.customerEmail),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.darkGreyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    req.preferredDateLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.colors.blackColor,
                    ),
                  ),
                  Text(
                    req.preferredTimeLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              CustomTagWidget(
                label: req.isOnline ? 'Online' : 'In-Person',
                icon: req.isOnline
                    ? CupertinoIcons.videocam_fill
                    : CupertinoIcons.location_solid,
                iconSize: 11.5,
                color: req.isOnline
                    ? context.colors.infoColor
                    : const Color(0xFF8B5CF6),
              ),
            ),
            DataCell(
              CustomTagWidget(
                label: req.status,
                color: _getStatusColor(context, req.status),
              ),
            ),
            DataCell(
              Text(
                _stripHtml(req.notes),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.darkGreyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending) ...[
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScheduleRequestDrawer.show(context, req);
                        },
                        icon: const Icon(CupertinoIcons.calendar_badge_plus,
                            size: 14, color: Colors.white),
                        label: const Text(
                          'Schedule',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppActionButton(
                      type: AppActionType.delete,
                      tooltip: 'Cancel Request',
                      onTap: () => _confirmCancelRequest(context, cubit, req),
                    ),
                  ] else if (isScheduled) ...[
                    CustomTagWidget(
                      label: 'Booked',
                      color: context.colors.primaryLightColor,
                    ),
                  ] else ...[
                    Text(
                      req.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getApptStatusColor(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'confirmed') {
      return context.colors.successColor;
    } else if (s == 'pending') {
      return context.colors.queuedColor;
    } else if (s == 'rescheduled') {
      return context.colors.infoColor;
    } else if (s == 'cancelled') {
      return context.colors.errorColor;
    } else if (s == 'completed') {
      return context.colors.darkGreyColor;
    }
    return context.colors.darkGreyColor;
  }

  Color _getStatusColor(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'pending') {
      return context.colors.warningColor;
    } else if (s == 'scheduled' || s == 'confirmed') {
      return context.colors.primaryLightColor;
    } else if (s == 'cancelled' || s == 'rejected') {
      return context.colors.errorColor;
    }
    return context.colors.darkGreyColor;
  }

  void _confirmCancelAppointment(
    BuildContext context,
    AppointmentsCubit cubit,
    AppointmentEntity appt,
  ) {
    ConfirmationDialog.show(
      context,
      title: 'Delete Appointment',
      message:
          'Are you sure you want to cancel the appointment with "${appt.customerName}"?',
      confirmLabel: 'DELETE',
      onConfirm: () async {
        await cubit.cancelAppointment(appt.id);
      },
    );
  }

  void _confirmCancelRequest(
    BuildContext context,
    AppointmentsCubit cubit,
    AppointmentRequestEntity req,
  ) {
    ConfirmationDialog.show(
      context,
      title: 'Delete Request',
      message:
          'Are you sure you want to cancel the appointment request for "${req.customerName}"?',
      confirmLabel: 'DELETE',
      onConfirm: () => cubit.cancelRequest(req.id),
    );
  }
}
