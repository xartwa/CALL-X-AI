import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/appointment_entity.dart';

class UpcomingAppointmentsPanel extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppointmentEntity> onAppointmentTapped;
  final VoidCallback? onViewAllTapped;

  const UpcomingAppointmentsPanel({
    super.key,
    required this.appointments,
    required this.onAppointmentTapped,
    this.onViewAllTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // Filter to upcoming and not cancelled
    final upcomingList = appointments
        .where((a) =>
            !a.isCancelled &&
            a.endAt.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    // Group appointments by formatted date string
    final Map<String, List<AppointmentEntity>> grouped = {};
    final now = DateTime.now();

    for (final appt in upcomingList) {
      final local = appt.startAt.toLocal();
      String header;
      if (local.year == now.year &&
          local.month == now.month &&
          local.day == now.day) {
        header = 'Today';
      } else if (local.year == now.year &&
          local.month == now.month &&
          local.day == now.day + 1) {
        header = 'Tomorrow';
      } else {
        header = DateFormat('EEE, MMM d').format(local);
      }
      grouped.putIfAbsent(header, () => []).add(appt);
    }

    final borderColor = context.colors.mediumGreyColor
        .withValues(alpha: isDark ? 0.35 : 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (upcomingList.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${upcomingList.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (onViewAllTapped != null)
                  InkWell(
                    onTap: onViewAllTapped,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 11,
                            color: primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor.withValues(alpha: 0.6)),

          // Body
          Expanded(
            child: upcomingList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.calendar_badge_minus,
                          size: 36,
                          color: context.colors.darkGreyColor
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No upcoming appointments',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final header = grouped.keys.elementAt(index);
                      final appts = grouped[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 10, bottom: 6),
                            child: Row(
                              children: [
                                Text(
                                  header.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 0.5,
                                    color: isDark
                                        ? const Color(0xFF334155)
                                            .withValues(alpha: 0.4)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final appt in appts)
                            _buildAppointmentCard(context, appt, isDark),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentEntity appt,
    bool isDark,
  ) {
    final localStart = appt.startAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(localStart);
    final isOnline = appt.isOnline;
    final isPending = appt.isPending;
    final isRescheduled = appt.isRescheduled;

    // Accent color: amber for pending, cyan for rescheduled, emerald for online, violet for in-person
    final Color accentColor = isPending
        ? const Color(0xFFF59E0B)
        : (isRescheduled
            ? const Color(0xFF06B6D4)
            : (isOnline ? const Color(0xFF10B981) : const Color(0xFF8B5CF6)));

    final cardBg = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.5)
        : const Color(0xFFF8FAFC);

    final cardBorder = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.35)
        : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: () => onAppointmentTapped(appt),
        borderRadius: BorderRadius.circular(8),
        hoverColor: accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cardBorder, width: 0.8),
          ),
          child: Row(
            children: [
              // Left Accent Status Bar
              Container(
                width: 3.5,
                height: 30,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),

              // Details: Top row (Time & Name), Bottom row (Type & Pending badge)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appt.customerName.isNotEmpty
                                ? appt.customerName
                                : appt.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          isOnline
                              ? CupertinoIcons.video_camera
                              : CupertinoIcons.location_solid,
                          size: 11,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'In-Person',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (isPending) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ] else if (isRescheduled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Rescheduled',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF06B6D4),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Subtle arrow icon for click affordance
              Icon(
                CupertinoIcons.chevron_right,
                size: 12,
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
