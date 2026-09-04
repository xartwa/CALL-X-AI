import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/appointment_entity.dart';

class CalendarWeekGrid extends StatelessWidget {
  final List<DateTime> weekDays;
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onAppointmentTapped;

  const CalendarWeekGrid({
    super.key,
    required this.weekDays,
    required this.appointments,
    required this.onAppointmentTapped,
  });

  static const double _hourHeight = 60.0;
  static const int _startHour = 9; // 9 AM
  static const int _endHour = 20; // 8 PM (inclusive end)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double timeGutterWidth = 56.0;
        final double gridWidth = constraints.maxWidth - timeGutterWidth;
        final double colWidth = gridWidth / 7;

        return Column(
          children: [
            // Header Row: Days of week (Pinned at top)
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: timeGutterWidth),
                  for (int i = 0; i < 7; i++) ...[
                    SizedBox(
                      width: colWidth,
                      child: _buildDayHeader(weekDays[i], now, isDark),
                    ),
                  ],
                ],
              ),
            ),

            // Hours Grid Body (Scrollable inside available height)
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: (_endHour - _startHour + 1) * _hourHeight,
                  child: Stack(
                    children: [
                      // Background horizontal grid lines
                      Column(
                        children: [
                          for (int h = _startHour; h <= _endHour; h++) ...[
                            Container(
                              height: _hourHeight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: borderColor.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: timeGutterWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8, top: 2),
                                      child: Text(
                                        _formatHour(h),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (int d = 0; d < 7; d++) ...[
                                    Container(
                                      width: colWidth,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: borderColor.withValues(alpha: 0.5),
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Current time indicator line
                      ..._buildCurrentTimeIndicator(colWidth, timeGutterWidth, now),

                      // Render appointment blocks on top of grid
                      ..._buildAppointmentCards(colWidth, timeGutterWidth, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCurrentTimeIndicator(
    double colWidth,
    double timeGutterWidth,
    DateTime now,
  ) {
    int todayIndex = -1;
    for (int i = 0; i < 7; i++) {
      final d = weekDays[i];
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        todayIndex = i;
        break;
      }
    }
    if (todayIndex == -1) return [];

    final nowHourFrac = now.hour + (now.minute / 60.0);
    if (nowHourFrac < _startHour || nowHourFrac > _endHour + 1) return [];

    final top = (nowHourFrac - _startHour) * _hourHeight;
    final left = timeGutterWidth + (todayIndex * colWidth);

    return [
      Positioned(
        top: top - 4,
        left: left - 4,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: top,
        left: left,
        width: colWidth,
        child: Container(
          height: 2,
          color: const Color(0xFFEF4444),
        ),
      ),
    ];
  }

  Widget _buildDayHeader(DateTime day, DateTime now, bool isDark) {
    final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
    final primary = const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? primary.withValues(alpha: isDark ? 0.12 : 0.08)
            : Colors.transparent,
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEE').format(day).toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isToday
                  ? primary
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM d').format(day),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday
                  ? primary
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppointmentCards(double colWidth, double timeGutterWidth, bool isDark) {
    final List<Widget> widgets = [];

    for (final appt in appointments) {
      if (appt.isCancelled) continue;

      final localStart = appt.startAt.toLocal();
      final localEnd = appt.endAt.toLocal();

      // Check which day index of current week (0 to 6)
      int dayIndex = -1;
      for (int i = 0; i < 7; i++) {
        final d = weekDays[i];
        if (d.year == localStart.year &&
            d.month == localStart.month &&
            d.day == localStart.day) {
          dayIndex = i;
          break;
        }
      }

      if (dayIndex == -1) continue; // Outside this week

      final startHourFrac = localStart.hour + (localStart.minute / 60.0);
      final durationHours = (localEnd.difference(localStart).inMinutes / 60.0).clamp(0.5, 3.0);

      // Y position relative to _startHour
      final top = (startHourFrac - _startHour) * _hourHeight;
      final height = (durationHours * _hourHeight).clamp(48.0, 160.0);
      final left = timeGutterWidth + (dayIndex * colWidth);

      if (top < 0 || top > (_endHour - _startHour + 1) * _hourHeight) continue;

      // Card style colors
      final isOnline = appt.isOnline;
      final isPending = appt.isPending;

      Color bg;
      Color border;
      Color textAccent;

      if (isPending) {
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7);
        border = const Color(0xFFF59E0B);
        textAccent = const Color(0xFFF59E0B);
      } else if (isOnline) {
        // Emerald / Green or Blue tint
        bg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFD1FAE5);
        border = const Color(0xFF10B981);
        textAccent = const Color(0xFF10B981);
      } else {
        // In person: Blue / Purple
        bg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.6) : const Color(0xFFDBEAFE);
        border = const Color(0xFF3B82F6);
        textAccent = const Color(0xFF3B82F6);
      }

      widgets.add(
        Positioned(
          top: top + 2,
          left: left + 2,
          width: colWidth - 4,
          height: height - 4,
          child: InkWell(
            onTap: () => onAppointmentTapped(appt),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${DateFormat('HH:mm').format(localStart)} – ${DateFormat('HH:mm').format(localEnd)}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: textAccent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    appt.customerName,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height >= 58) ...[
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(
                          isOnline
                              ? CupertinoIcons.video_camera
                              : CupertinoIcons.location_solid,
                          size: 9.5,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            isOnline ? 'Online' : 'In-Person',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatHour(int h) {
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }
}
