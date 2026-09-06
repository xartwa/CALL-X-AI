import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/features/appointments/cubit/appointments_cubit.dart';
import 'package:callx_ai/features/appointments/cubit/appointments_state.dart';
import 'package:callx_ai/features/appointments/domain/entities/appointment_entity.dart';

class DashboardAppointmentsCard extends StatefulWidget {
  const DashboardAppointmentsCard({super.key});

  @override
  State<DashboardAppointmentsCard> createState() =>
      _DashboardAppointmentsCardState();
}

class _DashboardAppointmentsCardState extends State<DashboardAppointmentsCard> {
  // 0: Next 7 Days, 1: Today Only
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apptState = context.read<AppointmentsCubit>().state;
      if (apptState.appointments.isEmpty &&
          apptState.status != AppointmentsStatus.loading) {
        context.read<AppointmentsCubit>().loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final apptState = context.watch<AppointmentsCubit>().state;

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final in7Days = todayMidnight.add(const Duration(days: 7, hours: 23, minutes: 59));

    // Filter appointments
    final List<AppointmentEntity> appointments;
    if (_selectedFilter == 1) {
      // Today only
      appointments = apptState.appointments
          .where((a) => !a.isCancelled && a.isToday)
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
    } else {
      // Next 7 days (including today)
      appointments = apptState.appointments
          .where((a) =>
              !a.isCancelled &&
              a.endAt.isAfter(now.subtract(const Duration(hours: 1))) &&
              a.startAt.isBefore(in7Days))
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt));
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: isDark ? 0.3 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SpacedText(
                            text: "UPCOMING APPOINTMENTS",
                            color: context.colors.blackColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          const SizedBox(width: 8),
                          // Count badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${appointments.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Filter toggle: Next 7 Days / Today
                      Row(
                        children: [
                          _buildFilterToggle(0, "Next 7 Days"),
                          const SizedBox(width: 6),
                          _buildFilterToggle(1, "Today"),
                        ],
                      ),
                    ],
                  ),
                ),

                // Calendar link
                InkWell(
                  onTap: () => context.go(AppRoutesPath.appointments),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Calendar",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 11,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: context.colors.mediumGreyColor
                .withValues(alpha: isDark ? 0.25 : 0.4),
          ),

          // ─── List of Appointments ────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 320),
            child: apptState.status == AppointmentsStatus.loading &&
                    appointments.isEmpty
                ? const Center(
                    child: CupertinoActivityIndicator(),
                  )
                : appointments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.calendar_badge_plus,
                                size: 28,
                                color: context.colors.darkGreyColor
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 1
                                    ? 'No appointments scheduled for today'
                                    : 'No appointments in the next 7 days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 18, 16),
                        itemCount: appointments.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final appt = appointments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _AppointmentTile(appointment: appt),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(int index, String label) {
    final isSelected = _selectedFilter == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF10B981)
                : context.colors.darkGreyColor,
          ),
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatefulWidget {
  final AppointmentEntity appointment;

  const _AppointmentTile({required this.appointment});

  @override
  State<_AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<_AppointmentTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appt = widget.appointment;
    final localStart = appt.startAt.toLocal();
    final timeStr = DateFormat('h:mm a').format(localStart);

    final now = DateTime.now();
    final isToday = localStart.year == now.year &&
        localStart.month == now.month &&
        localStart.day == now.day;
    final isTomorrow = localStart.year == now.year &&
        localStart.month == now.month &&
        localStart.day == now.day + 1;

    final String dayLabel = isToday
        ? 'Today'
        : isTomorrow
            ? 'Tomorrow'
            : DateFormat('EEE, MMM d').format(localStart);

    final initials = (appt.customerName.isNotEmpty ? appt.customerName : appt.title)
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final cardBg = _isHovered
        ? (isDark
            ? const Color(0xFF162032)
            : context.colors.milkyColor)
        : (isDark
            ? const Color(0xFF0F172A)
            : context.colors.milkyColor.withValues(alpha: 0.35));

    final cardBorder = _isHovered
        ? (isDark
            ? const Color(0xFF334155)
            : context.colors.mediumGreyColor.withValues(alpha: 0.7))
        : (isDark
            ? const Color(0xFF1E293B)
            : context.colors.mediumGreyColor.withValues(alpha: 0.3));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => context.go(AppRoutesPath.appointments),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. Date & Time Box ───────────────────────────────────────
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? const Color(0xFF10B981)
                            : context.colors.blackColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? const Color(0xFF10B981)
                            : context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // ── 2. Avatar ────────────────────────────────────────────────
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'M' : initials,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── 3. Appointment Details ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      appt.title.isNotEmpty
                          ? appt.title
                          : 'Consultation Meeting',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Guest / Company + Platform
                    Row(
                      children: [
                        if (appt.customerName.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              appt.customerName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: context.colors.darkGreyColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: context.colors.darkGreyColor
                                    .withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                        Icon(
                          appt.isOnline
                              ? CupertinoIcons.videocam_fill
                              : CupertinoIcons.location_solid,
                          size: 10,
                          color: context.colors.darkGreyColor
                              .withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          appt.isOnline ? 'Google Meet' : 'In-Person',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: context.colors.darkGreyColor
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── 4. Status Badge ──────────────────────────────────────────
              Container(
                width: 78,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.22),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  appt.isConfirmed ? 'Confirmed' : appt.status,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 10),

              // ── 5. Action Button (Consistent 68x28) ───────────────────────
              SizedBox(
                width: 68,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : context.colors.mediumGreyColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : context.colors.mediumGreyColor.withValues(alpha: 0.35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Open",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 9.5,
                        color: context.colors.darkGreyColor,
                      ),
                    ],
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
