import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        border: Border.all(
          color: context.colors.mediumGreyColor
              .withValues(alpha: isDark ? 0.35 : 1.0),
        ),
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

          // Right: Status / Filter Options
          Row(
            children: [
              PopupMenuButton<String>(
                tooltip: 'Filter by Status',
                onSelected: (val) => cubit.setStatusFilter(val),
                color: context.colors.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                itemBuilder: (ctx) => [
                  _buildFilterMenuItem('All', state.selectedStatusFilter),
                  _buildFilterMenuItem('Confirmed', state.selectedStatusFilter),
                  _buildFilterMenuItem('Pending', state.selectedStatusFilter),
                  _buildFilterMenuItem('Completed', state.selectedStatusFilter),
                  _buildFilterMenuItem('Cancelled', state.selectedStatusFilter),
                ],
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.slider_horizontal_3,
                        size: 14,
                        color: context.colors.darkGreyColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.selectedStatusFilter == 'All'
                            ? 'All Statuses'
                            : state.selectedStatusFilter,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: context.colors.blackColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 11,
                        color: context.colors.darkGreyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildFilterMenuItem(
      String value, String currentSelected) {
    final isSelected = value.toLowerCase() == currentSelected.toLowerCase();
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
            const Icon(CupertinoIcons.checkmark,
                size: 14, color: Color(0xFF8B5CF6)),
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
}
