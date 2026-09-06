import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/web.dart' as web;

import '../../../../core/constants/theme_constants.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../cubit/appointments_state.dart';
import '../widgets/appointment_details_drawer.dart';
import '../widgets/calendar_month_grid.dart';
import '../widgets/calendar_week_grid.dart';
import '../widgets/upcoming_appointments_panel.dart';

class CalendarTabView extends StatelessWidget {
  const CalendarTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cubit = context.read<AppointmentsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Sub-toolbar
            _buildToolbar(context, state, cubit, isDark),
            const SizedBox(height: 14),

            // Main Content: Week/Month Grid + Upcoming Panel
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 980;

                  final calendarCard = Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.boxRadius),
                      border: Border.all(
                        color: context.colors.mediumGreyColor
                            .withValues(alpha: isDark ? 0.35 : 1.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.boxRadius),
                      child: state.calendarViewMode == CalendarViewMode.week
                          ? CalendarWeekGrid(
                              weekDays: state.currentWeekDays,
                              appointments: state.filteredAppointments,
                              onAppointmentTapped: (appt) {
                                AppointmentDetailsDrawer.show(context, appt);
                              },
                            )
                          : CalendarMonthGrid(
                              focusedMonth: state.selectedDate,
                              appointments: state.filteredAppointments,
                              onAppointmentTapped: (appt) {
                                AppointmentDetailsDrawer.show(context, appt);
                              },
                            ),
                    ),
                  );

                  final upcomingPanel = UpcomingAppointmentsPanel(
                    appointments: state.upcomingAppointments,
                    onAppointmentTapped: (appt) {
                      AppointmentDetailsDrawer.show(context, appt);
                    },
                    onViewAllTapped: () => cubit.setActiveTab(1),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: calendarCard,
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 310,
                          child: upcomingPanel,
                        ),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 600,
                            child: calendarCard,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 400,
                            child: upcomingPanel,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Mode switch + Today + Nav + Date Label
          Row(
            children: [
              // Week / Month Toggle Pill
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
                      label: 'Week',
                      selected: state.calendarViewMode == CalendarViewMode.week,
                      isDark: isDark,
                      onTap: () =>
                          cubit.setCalendarViewMode(CalendarViewMode.week),
                    ),
                    const SizedBox(width: 4),
                    _buildModePill(
                      context: context,
                      label: 'Month',
                      selected:
                          state.calendarViewMode == CalendarViewMode.month,
                      isDark: isDark,
                      onTap: () =>
                          cubit.setCalendarViewMode(CalendarViewMode.month),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Today Button
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: () => cubit.goToToday(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.colors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Previous / Next Buttons
              InkWell(
                onTap: () {
                  if (state.calendarViewMode == CalendarViewMode.week) {
                    cubit.navigateWeek(-1);
                  } else {
                    cubit.navigateMonth(-1);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      size: 14,
                      color: context.colors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  if (state.calendarViewMode == CalendarViewMode.week) {
                    cubit.navigateWeek(1);
                  } else {
                    cubit.navigateMonth(1);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: context.colors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Date Range Text
              Text(
                state.currentWeekRangeLabel,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: context.colors.blackColor,
                ),
              ),
            ],
          ),

          // Right: Google Calendar + Status / Filter Options + Refresh Button
          Row(
            children: [
              _buildGoogleCalendarToolbarBadge(context, state, cubit, isDark),
              const SizedBox(width: 10),

              // Status Dropdown Filter (Without Arrow - matches Calls & Customers)
              PopupMenuButton<String>(
                tooltip: 'Filter by Status',
                onSelected: (val) => cubit.setStatusFilter(val),
                offset: const Offset(0, 40),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                itemBuilder: (ctx) => [
                  'All',
                  'Confirmed',
                  'Pending',
                  'Completed',
                  'Cancelled',
                ].map((status) {
                  final isSelected = state.selectedStatusFilter.toLowerCase() ==
                      status.toLowerCase();
                  return PopupMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                }).toList(),
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
                  onTap: state.isActionLoading ? null : () => cubit.refresh(),
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
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleCalendarToolbarBadge(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    final isConnected = state.calendarConnection.connected;
    if (isConnected) {
      return Tooltip(
        message:
            'Google Calendar Connected (${state.calendarConnection.accountEmail}). Click to sync now.',
        child: InkWell(
          onTap: state.isActionLoading ? null : () => cubit.syncCalendar(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  state.calendarConnection.accountEmail.isNotEmpty
                      ? state.calendarConnection.accountEmail
                      : 'Google Sync',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 7),
                state.isActionLoading
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFF10B981),
                        ),
                      )
                    : const Icon(
                        CupertinoIcons.refresh,
                        size: 13,
                        color: Color(0xFF10B981),
                      ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Tooltip(
        message: 'Connect your Google Calendar to sync appointments',
        child: InkWell(
          onTap: () async {
            final url = await cubit.getGoogleCalendarOAuthUrl();
            if (url != null && url.isNotEmpty) {
              cubit.startOAuthPolling();
              if (kIsWeb) {
                web.window.open(url, '_blank');
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4285F4).withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: Color(0xFF4285F4),
                ),
                SizedBox(width: 6),
                Text(
                  'Connect Google Calendar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
