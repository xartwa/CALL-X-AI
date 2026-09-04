import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/appointment_entity.dart';

class CalendarMonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onAppointmentTapped;

  const CalendarMonthGrid({
    super.key,
    required this.focusedMonth,
    required this.appointments,
    required this.onAppointmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final borderColor = isDark
        ? context.colors.mediumGreyColor.withValues(alpha: 0.35)
        : const Color(0xFFE2E8F0);

    // Compute month calendar days (Sunday - Saturday)
    final year = focusedMonth.year;
    final month = focusedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // weekday: Mon=1..Sun=7. In Sunday-first: Sun=0, Mon=1...Sat=6
    final startWeekday = firstDayOfMonth.weekday % 7;

    final daysInPrevMonth = DateTime(year, month, 0).day;
    final List<_MonthDayInfo> days = [];

    // 1. Preceding month days
    for (int i = startWeekday - 1; i >= 0; i--) {
      final d = daysInPrevMonth - i;
      days.add(_MonthDayInfo(
        date: DateTime(month == 1 ? year - 1 : year, month == 1 ? 12 : month - 1, d),
        isCurrentMonth: false,
      ));
    }

    // 2. Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(_MonthDayInfo(
        date: DateTime(year, month, i),
        isCurrentMonth: true,
      ));
    }

    // 3. Trailing next month days to complete 35 or 42 grid cells
    final totalCells = days.length <= 35 ? 35 : 42;
    final remaining = totalCells - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(_MonthDayInfo(
        date: DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, i),
        isCurrentMonth: false,
      ));
    }

    const weekDayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    return Column(
      children: [
        // Days of Week Header
        Container(
          height: 38,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: Row(
            children: [
              for (final name in weekDayNames)
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Weeks Grid
        Expanded(
          child: Column(
            children: [
              for (int w = 0; w < totalCells / 7; w++)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: w < (totalCells / 7) - 1
                            ? BorderSide(color: borderColor.withValues(alpha: 0.6), width: 0.6)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int d = 0; d < 7; d++) ...[
                          Expanded(
                            child: _buildDayCell(
                              context,
                              days[w * 7 + d],
                              now,
                              isDark,
                              borderColor,
                            ),
                          ),
                          if (d < 6)
                            VerticalDivider(
                              width: 1,
                              thickness: 0.6,
                              color: borderColor.withValues(alpha: 0.6),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    _MonthDayInfo dayInfo,
    DateTime now,
    bool isDark,
    Color borderColor,
  ) {
    final date = dayInfo.date;
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isCurrent = dayInfo.isCurrentMonth;

    // Filter appointments for this day
    final dayAppointments = appointments.where((a) {
      if (a.isCancelled) return false;
      final local = a.startAt.toLocal();
      return local.year == date.year && local.month == date.month && local.day == date.day;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      color: isToday
          ? primary.withValues(alpha: isDark ? 0.08 : 0.05)
          : (isCurrent ? Colors.transparent : (isDark ? Colors.black12 : const Color(0xFFFAFAFA))),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isToday ? primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday
                          ? Colors.white
                          : (isCurrent
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))),
                    ),
                  ),
                ),
              ),
              if (dayAppointments.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dayAppointments.length}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),

          // Appointment Chips (show up to 2, then +N more)
          Expanded(
            child: dayAppointments.isEmpty
                ? const SizedBox.shrink()
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (int i = 0; i < dayAppointments.length && i < 2; i++)
                        _buildAppointmentPill(dayAppointments[i], isDark),
                      if (dayAppointments.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '+${dayAppointments.length - 2} more',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentPill(AppointmentEntity appt, bool isDark) {
    final localStart = appt.startAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(localStart);
    final isOnline = appt.isOnline;
    final isPending = appt.isPending;

    Color bg;
    Color border;
    Color textCol;

    if (isPending) {
      bg = isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7);
      border = const Color(0xFFF59E0B);
      textCol = const Color(0xFFF59E0B);
    } else if (isOnline) {
      bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      border = const Color(0xFF10B981);
      textCol = isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
    } else {
      bg = isDark
          ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
          : const Color(0xFFEDE9FE);
      border = const Color(0xFF8B5CF6);
      textCol = isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => onAppointmentTapped(appt),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(color: border, shape: BoxShape.circle),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '$timeStr ${appt.customerName.isNotEmpty ? appt.customerName : appt.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthDayInfo {
  final DateTime date;
  final bool isCurrentMonth;

  _MonthDayInfo({required this.date, required this.isCurrentMonth});
}
