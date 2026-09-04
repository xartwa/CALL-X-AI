import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/app_text_field_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../cubit/appointments_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../widgets/schedule_request_drawer.dart';

class RequestsTabView extends StatefulWidget {
  const RequestsTabView({super.key});

  @override
  State<RequestsTabView> createState() => _RequestsTabViewState();
}

class _RequestsTabViewState extends State<RequestsTabView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cubit = context.read<AppointmentsCubit>();
        final requests = state.filteredRequests;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar: Search + Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  // Search Input
                  Expanded(
                    child: AppTextFieldWidget(
                      controller: _searchCtrl,
                      hintText: 'Search requests by customer name, company, or notes...',
                      prefixIcon: Icon(
                        CupertinoIcons.search,
                        size: 18,
                        color: context.colors.darkGreyColor,
                      ),
                      onChanged: (val) => cubit.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Filter Menu
                  PopupMenuButton<String>(
                    tooltip: 'Filter Status',
                    onSelected: (val) => cubit.setStatusFilter(val),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      _buildMenuItem('All', state.selectedStatusFilter),
                      _buildMenuItem('Pending', state.selectedStatusFilter),
                      _buildMenuItem('Scheduled', state.selectedStatusFilter),
                      _buildMenuItem('Closed', state.selectedStatusFilter),
                      _buildMenuItem('Cancelled', state.selectedStatusFilter),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.line_horizontal_3_decrease,
                            size: 14,
                            color: context.colors.darkGreyColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.selectedStatusFilter == 'All'
                                ? 'All Status'
                                : state.selectedStatusFilter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.colors.blackColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.chevron_down,
                            size: 12,
                            color: context.colors.darkGreyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table Card
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                  child: requests.isEmpty
                      ? _buildEmptyState(context, isDark)
                      : _buildTable(context, requests, isDark, cubit),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String selected) {
    final isSelected = value.toLowerCase() == selected.toLowerCase();
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (isSelected)
            const Icon(CupertinoIcons.checkmark, size: 14, color: Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
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
              'No Appointment Requests',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.colors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'When AI cold calls identify interested prospects who requested a meeting,\nthey will appear here ready to be confirmed.',
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

  Widget _buildTable(
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
        DataColumn2(label: Text('TYPE'), size: ColumnSize.S, fixedWidth: 110),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S, fixedWidth: 120),
        DataColumn2(label: Text('NOTES / AI INTENT'), size: ColumnSize.L),
        DataColumn2(label: Text('ACTIONS'), size: ColumnSize.S, fixedWidth: 130),
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
            // Prospect / Customer
            DataCell(
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        req.customerName.isNotEmpty ? req.customerName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
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
                              : (req.customerPhone.isNotEmpty ? req.customerPhone : req.customerEmail),
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
                ],
              ),
            ),

            // Preferred Time
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

            // Type
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: req.isOnline
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.12)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      req.isOnline ? CupertinoIcons.videocam_fill : CupertinoIcons.person_2_fill,
                      size: 12,
                      color: req.isOnline ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      req.isOnline ? 'Online' : 'In-Person',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: req.isOnline ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Status
            DataCell(
              _buildStatusBadge(req.status),
            ),

            // Notes / AI Intent
            DataCell(
              Text(
                req.notes ?? 'Requested via AI Cold Call',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.darkGreyColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Actions
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        ScheduleRequestDrawer.show(context, req);
                      },
                      icon: const Icon(CupertinoIcons.calendar_badge_plus, size: 13, color: Colors.white),
                      label: const Text(
                        'Schedule',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, size: 14),
                      tooltip: 'Cancel Request',
                      color: context.colors.errorColor,
                      onPressed: () => _confirmCancelRequest(context, cubit, req),
                    ),
                  ] else if (isScheduled) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Booked',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      req.status,
                      style: TextStyle(
                        fontSize: 11,
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    final s = status.toLowerCase();

    if (s == 'pending') {
      bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      fg = const Color(0xFFF59E0B);
    } else if (s == 'scheduled') {
      bg = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
      fg = const Color(0xFF8B5CF6);
    } else if (s == 'closed') {
      bg = const Color(0xFF64748B).withValues(alpha: 0.15);
      fg = const Color(0xFF64748B);
    } else {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
      fg = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancelRequest(
    BuildContext context,
    AppointmentsCubit cubit,
    AppointmentRequestEntity req,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: Text('Are you sure you want to cancel the appointment request for ${req.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              cubit.cancelRequest(req.id);
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
