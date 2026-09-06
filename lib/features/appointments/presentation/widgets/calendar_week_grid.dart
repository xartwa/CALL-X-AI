import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/appointment_entity.dart';

class CalendarWeekGrid extends StatefulWidget {
  final List<DateTime> weekDays;
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onAppointmentTapped;

  const CalendarWeekGrid({
    super.key,
    required this.weekDays,
    required this.appointments,
    required this.onAppointmentTapped,
  });

  static const double hourHeight = 60.0;

  @override
  State<CalendarWeekGrid> createState() => _CalendarWeekGridState();
}

class _CalendarWeekGridState extends State<CalendarWeekGrid> {
  late final ScrollController _scrollController;

  static const double _hourHeight = CalendarWeekGrid.hourHeight;

  @override
  void initState() {
    super.initState();
    final initialOffset = _calculateScrollOffset();
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void didUpdateWidget(covariant CalendarWeekGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekDays != widget.weekDays ||
        oldWidget.appointments != widget.appointments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final targetOffset = _calculateScrollOffset();
          _scrollController.animateTo(
            targetOffset.clamp(
                0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateStartHour() {
    int startHour = 8;
    for (final appt in widget.appointments) {
      if (appt.isCancelled) continue;
      final localStart = appt.startAt.toLocal();
      bool inThisWeek = false;
      for (final d in widget.weekDays) {
        if (d.year == localStart.year &&
            d.month == localStart.month &&
            d.day == localStart.day) {
          inThisWeek = true;
          break;
        }
      }
      if (!inThisWeek) continue;
      if (localStart.hour < startHour) {
        startHour = localStart.hour;
      }
    }
    return startHour.clamp(0, 8);
  }

  int _calculateEndHour(int startHour) {
    int endHour = 21;
    for (final appt in widget.appointments) {
      if (appt.isCancelled) continue;
      final localStart = appt.startAt.toLocal();
      final localEnd = appt.endAt.toLocal();
      bool inThisWeek = false;
      for (final d in widget.weekDays) {
        if (d.year == localStart.year &&
            d.month == localStart.month &&
            d.day == localStart.day) {
          inThisWeek = true;
          break;
        }
      }
      if (!inThisWeek) continue;
      final endH = localEnd.minute > 0 ? localEnd.hour : (localEnd.hour - 1);
      if (endH > endHour) {
        endHour = endH.clamp(startHour, 23);
      }
    }
    return endHour.clamp(20, 23);
  }

  double _calculateScrollOffset() {
    final startHour = _calculateStartHour();
    final endHour = _calculateEndHour(startHour);
    final now = DateTime.now();

    final weekAppts = widget.appointments.where((appt) {
      if (appt.isCancelled) return false;
      final local = appt.startAt.toLocal();
      return widget.weekDays.any((d) =>
          d.year == local.year && d.month == local.month && d.day == local.day);
    }).toList();

    int targetHour = 8;

    if (weekAppts.isNotEmpty) {
      final todayAppts = weekAppts.where((appt) {
        final local = appt.startAt.toLocal();
        return local.year == now.year &&
            local.month == now.month &&
            local.day == now.day;
      }).toList();

      if (todayAppts.isNotEmpty) {
        todayAppts.sort((a, b) => a.startAt.compareTo(b.startAt));
        final upcomingToday =
            todayAppts.where((a) => a.endAt.toLocal().isAfter(now)).toList();
        if (upcomingToday.isNotEmpty) {
          targetHour = upcomingToday.first.startAt.toLocal().hour;
        } else {
          targetHour = todayAppts.first.startAt.toLocal().hour;
        }
      } else {
        final futureAppts =
            weekAppts.where((a) => a.endAt.toLocal().isAfter(now)).toList();
        if (futureAppts.isNotEmpty) {
          futureAppts.sort((a, b) => a.startAt.compareTo(b.startAt));
          targetHour = futureAppts.first.startAt.toLocal().hour;
        } else {
          weekAppts.sort((a, b) => a.startAt.compareTo(b.startAt));
          targetHour = weekAppts.first.startAt.toLocal().hour;
        }
      }
    } else {
      final todayInWeek = widget.weekDays.any((d) =>
          d.year == now.year && d.month == now.month && d.day == now.day);
      if (todayInWeek) {
        targetHour = now.hour;
      } else {
        targetHour = 9;
      }
    }

    final clampedHour = (targetHour - 1).clamp(startHour, endHour);
    return ((clampedHour - startHour) * _hourHeight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    final startHour = _calculateStartHour();
    final endHour = _calculateEndHour(startHour);

    final borderColor =
        context.colors.mediumGreyColor.withValues(alpha: isDark ? 0.35 : 1.0);

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
                border:
                    Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: timeGutterWidth),
                  for (int i = 0; i < 7; i++) ...[
                    SizedBox(
                      width: colWidth,
                      child: _buildDayHeader(
                          widget.weekDays[i], now, isDark, context),
                    ),
                  ],
                ],
              ),
            ),

            // Hours Grid Body (Scrollable inside available height)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 60),
                child: SizedBox(
                  height: (endHour - startHour + 1) * _hourHeight,
                  child: Stack(
                    children: [
                      // Background horizontal grid lines
                      Column(
                        children: [
                          for (int h = startHour; h <= endHour; h++) ...[
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
                                      padding: const EdgeInsets.only(
                                          right: 8, top: 2),
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
                                            color: borderColor.withValues(
                                                alpha: 0.5),
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
                      ..._buildCurrentTimeIndicator(
                          colWidth, timeGutterWidth, now, startHour, endHour),

                      // Render appointment blocks on top of grid
                      ..._buildAppointmentCards(
                          colWidth, timeGutterWidth, isDark, startHour, endHour),
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
    int startHour,
    int endHour,
  ) {
    int todayIndex = -1;
    for (int i = 0; i < 7; i++) {
      final d = widget.weekDays[i];
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        todayIndex = i;
        break;
      }
    }
    if (todayIndex == -1) return [];

    final nowHourFrac = now.hour + (now.minute / 60.0);
    if (nowHourFrac < startHour || nowHourFrac > endHour + 1) return [];

    final top = (nowHourFrac - startHour) * _hourHeight;
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

  Widget _buildDayHeader(
      DateTime day, DateTime now, bool isDark, BuildContext context) {
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final primary = Theme.of(context).colorScheme.primary;

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
                  : (isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B)),
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

  List<Widget> _buildAppointmentCards(
    double colWidth,
    double timeGutterWidth,
    bool isDark,
    int startHour,
    int endHour,
  ) {
    final List<Widget> widgets = [];

    // Process each day column independently
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final dayDate = widget.weekDays[dayIndex];

      // 1. Gather all active appointments for this day
      final dayAppts = widget.appointments.where((appt) {
        if (appt.isCancelled) return false;
        final local = appt.startAt.toLocal();
        return local.year == dayDate.year &&
            local.month == dayDate.month &&
            local.day == dayDate.day;
      }).toList();

      if (dayAppts.isEmpty) continue;

      // 2. Sort by start time ascending, then by duration descending
      dayAppts.sort((a, b) {
        final cmp = a.startAt.compareTo(b.startAt);
        if (cmp != 0) return cmp;
        final durA = a.endAt.difference(a.startAt);
        final durB = b.endAt.difference(b.startAt);
        return durB.compareTo(durA);
      });

      // 3. Cluster overlapping appointments
      final List<List<AppointmentEntity>> clusters = [];
      List<AppointmentEntity> currentCluster = [];
      DateTime? currentClusterMaxEnd;

      for (final appt in dayAppts) {
        final start = appt.startAt.toLocal();
        final end = appt.endAt.toLocal();

        if (currentCluster.isEmpty) {
          currentCluster.add(appt);
          currentClusterMaxEnd = end;
        } else {
          // If this appointment starts before the latest end of the cluster, it overlaps!
          if (start.isBefore(currentClusterMaxEnd!)) {
            currentCluster.add(appt);
            if (end.isAfter(currentClusterMaxEnd)) {
              currentClusterMaxEnd = end;
            }
          } else {
            clusters.add(currentCluster);
            currentCluster = [appt];
            currentClusterMaxEnd = end;
          }
        }
      }
      if (currentCluster.isNotEmpty) {
        clusters.add(currentCluster);
      }

      // 4. For each cluster, assign columns greedily and render
      final dayBaseLeft = timeGutterWidth + (dayIndex * colWidth);
      final double totalDayWidth = colWidth - 4.0;

      for (final cluster in clusters) {
        final List<DateTime> columnEnds = [];
        final Map<String, int> apptColumnMap = {};

        for (final appt in cluster) {
          final start = appt.startAt.toLocal();
          final end = appt.endAt.toLocal();

          int assignedCol = -1;
          for (int c = 0; c < columnEnds.length; c++) {
            if (!columnEnds[c].isAfter(start)) {
              assignedCol = c;
              columnEnds[c] = end;
              break;
            }
          }
          if (assignedCol == -1) {
            assignedCol = columnEnds.length;
            columnEnds.add(end);
          }
          apptColumnMap[appt.id] = assignedCol;
        }

        final int totalCols = columnEnds.length;
        final double cardWidth = totalDayWidth / totalCols;

        for (final appt in cluster) {
          final localStart = appt.startAt.toLocal();
          final localEnd = appt.endAt.toLocal();
          final colIndex = apptColumnMap[appt.id] ?? 0;

          final startHourFrac = localStart.hour + (localStart.minute / 60.0);
          final durationHours =
              (localEnd.difference(localStart).inMinutes / 60.0).clamp(0.4, 4.0);

          final top = (startHourFrac - startHour) * _hourHeight;
          final height = (durationHours * _hourHeight).clamp(40.0, 200.0);
          final left = dayBaseLeft + 2.0 + (colIndex * cardWidth);
          final itemWidth = (cardWidth - 2.0).clamp(24.0, totalDayWidth);

          if (top < 0 || top > (endHour - startHour + 1) * _hourHeight) continue;

          // Card style colors
          final isOnline = appt.isOnline;
          final isPending = appt.isPending;

          Color bg;
          Color border;
          Color textAccent;

          if (isPending) {
            bg = isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7);
            border = const Color(0xFFF59E0B);
            textAccent = const Color(0xFFF59E0B);
          } else if (isOnline) {
            bg = isDark
                ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                : const Color(0xFFD1FAE5);
            border = const Color(0xFF10B981);
            textAccent = const Color(0xFF10B981);
          } else {
            bg = isDark
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.18)
                : const Color(0xFFEDE9FE);
            border = const Color(0xFF8B5CF6);
            textAccent = const Color(0xFF8B5CF6);
          }

          final timeStr = itemWidth < 65
              ? DateFormat('HH:mm').format(localStart)
              : '${DateFormat('HH:mm').format(localStart)} – ${DateFormat('HH:mm').format(localEnd)}';

          widgets.add(
            Positioned(
              top: top + 1.5,
              left: left,
              width: itemWidth,
              height: height - 3.0,
              child: InkWell(
                onTap: () => widget.onAppointmentTapped(appt),
                borderRadius: BorderRadius.circular(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: textAccent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (height >= 34) ...[
                          const SizedBox(height: 1),
                          Text(
                            appt.customerName.isNotEmpty
                                ? appt.customerName
                                : appt.title,
                            style: TextStyle(
                              fontSize: itemWidth < 60 ? 9 : 10,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color:
                                  isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (height >= 56 && itemWidth >= 65) ...[
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Icon(
                                isOnline
                                    ? CupertinoIcons.video_camera
                                    : CupertinoIcons.location_solid,
                                size: 9,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  isOnline ? 'Online' : 'In-Person',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    height: 1.1,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF475569),
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
            ),
          );
        }
      }
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
