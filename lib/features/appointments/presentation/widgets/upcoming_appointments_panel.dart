import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/custom_tag_widget.dart';
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
        .where((a) => !a.isCancelled && a.endAt.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    // Group appointments by formatted date string
    final Map<String, List<AppointmentEntity>> grouped = {};
    final now = DateTime.now();

    for (final appt in upcomingList) {
      final local = appt.startAt.toLocal();
      String header;
      if (local.year == now.year && local.month == now.month && local.day == now.day) {
        header = 'Today • ${DateFormat('EEE, MMM d').format(local)}';
      } else {
        header = DateFormat('EEE, MMM d').format(local);
      }
      grouped.putIfAbsent(header, () => []).add(appt);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
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
                Text(
                  'Upcoming',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (onViewAllTapped != null)
                  InkWell(
                    onTap: onViewAllTapped,
                    child: Text(
                      'View all >',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

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
                          color: context.colors.darkGreyColor.withValues(alpha: 0.5),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Text(
                              header,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          for (final appt in appts) ...[
                            _buildAppointmentRow(context, appt, isDark),
                          ],
                          const SizedBox(height: 6),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentRow(
    BuildContext context,
    AppointmentEntity appt,
    bool isDark,
  ) {
    final localStart = appt.startAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(localStart);
    final isOnline = appt.isOnline;
    final isConfirmed = appt.isConfirmed;

    return InkWell(
      onTap: () => onAppointmentTapped(appt),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Time
            SizedBox(
              width: 44,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Attendee details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt.customerName,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isOnline
                            ? CupertinoIcons.video_camera
                            : CupertinoIcons.location_solid,
                        size: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isOnline ? 'Online' : 'In-Person',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status Badge (Using standard CustomTagWidget)
            CustomTagWidget(
              label: isConfirmed ? 'Confirmed' : 'Pending',
              color: isConfirmed ? context.colors.successColor : context.colors.warningColor,
            ),
          ],
        ),
      ),
    );
  }
}
