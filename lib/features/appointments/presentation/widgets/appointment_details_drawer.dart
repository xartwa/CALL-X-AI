import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_date_time_picker.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentDetailsDrawer extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onClose;

  const AppointmentDetailsDrawer({
    super.key,
    required this.appointment,
    required this.onClose,
  });

  static void show(BuildContext context, AppointmentEntity appointment) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Appointment Details',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => BlocProvider.value(
        value: context.read<AppointmentsCubit>(),
        child: Align(
          alignment: Alignment.centerRight,
          child: AppointmentDetailsDrawer(
            appointment: appointment,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final cubit = context.read<AppointmentsCubit>();

    final localStart = appointment.startAt.toLocal();
    final localEnd = appointment.endAt.toLocal();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 440,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131C2E) : Colors.white,
          border: Border(
            left: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drawer Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'APPOINTMENT DETAILS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.darkGreyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.clear, size: 18, color: context.colors.darkGreyColor),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge Banner
                    _buildStatusBanner(context, appointment, isDark),
                    const SizedBox(height: 18),

                    // Customer Details Card
                    _buildSectionHeader(context, 'ATTENDEE INFORMATION'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      context,
                      isDark,
                      [
                        _buildInfoRow('Name', appointment.customerName),
                        if (appointment.companyName.isNotEmpty)
                          _buildInfoRow('Company', appointment.companyName),
                        if (appointment.customerPhone.isNotEmpty)
                          _buildInfoRow('Phone', appointment.customerPhone),
                        if (appointment.customerEmail.isNotEmpty)
                          _buildInfoRow('Email', appointment.customerEmail),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Date & Schedule Card
                    _buildSectionHeader(context, 'SCHEDULE & TIME'),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      context,
                      isDark,
                      [
                        _buildInfoRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(localStart)),
                        _buildInfoRow(
                          'Time',
                          '${DateFormat('HH:mm').format(localStart)} – ${DateFormat('HH:mm').format(localEnd)} (${appointment.durationMinutes} mins)',
                        ),
                        _buildInfoRow('Timezone', appointment.timezone),
                        _buildInfoRow('Meeting Type', appointment.isOnline ? 'Online Meeting' : 'In-Person Meeting'),
                        if (appointment.isOnline && appointment.meetingUrl != null)
                          _buildActionableRow(
                            'Meeting URL',
                            appointment.meetingUrl!,
                            icon: CupertinoIcons.doc_on_clipboard,
                            onAction: () {
                              Clipboard.setData(ClipboardData(text: appointment.meetingUrl!));
                              AppUtils.showSnackBar(
                                context: context,
                                extraMessage: 'Meeting link copied to clipboard.',
                                toastificationType: ToastificationType.success,
                              );
                            },
                          ),
                        if (appointment.isInPerson && appointment.location != null && appointment.location!.isNotEmpty)
                          _buildInfoRow('Location', appointment.location!),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Call & Source Link
                    if (appointment.sourceCallId != null || appointment.source == 'ai_call') ...[
                      _buildSectionHeader(context, 'AI CALL CONTEXT'),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        context,
                        isDark,
                        [
                          _buildInfoRow('Source', 'AI Cold Call Schedule'),
                          if (appointment.sourceCallId != null)
                            _buildInfoRow('Call ID', appointment.sourceCallId!),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Notes
                    if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                      _buildSectionHeader(context, 'AGENDA & NOTES'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          appointment.notes!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (appointment.isOnline && appointment.meetingUrl != null && !appointment.isCancelled) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                          ),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: appointment.meetingUrl!));
                          AppUtils.showSnackBar(
                            context: context,
                            extraMessage: 'Meeting URL copied: ${appointment.meetingUrl}',
                            toastificationType: ToastificationType.success,
                          );
                        },
                        icon: const Icon(CupertinoIcons.video_camera, size: 16),
                        label: const Text(
                          'Join / Copy Meeting Link',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      if (!appointment.isCancelled && !appointment.isCompleted) ...[
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                                ),
                              ),
                              onPressed: () async {
                                final picked = await AppDateTimePicker.pickDateTime(
                                  context,
                                  initial: appointment.startAt.toLocal(),
                                );
                                if (picked != null) {
                                  await cubit.rescheduleAppointment(
                                    appointment.id,
                                    picked,
                                    reason: 'Rescheduled via admin drawer',
                                  );
                                  onClose();
                                }
                              },
                              child: const Text('Reschedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.colors.errorColor,
                                side: BorderSide(color: context.colors.errorColor.withValues(alpha: 0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConfirmationDialog(
                                    title: 'Cancel Appointment?',
                                    message: 'Are you sure you want to cancel this appointment with ${appointment.customerName}?',
                                    confirmLabel: 'Yes, Cancel',
                                    onConfirm: () async {
                                      await cubit.cancelAppointment(appointment.id);
                                      onClose();
                                    },
                                  ),
                                );
                              },
                              child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, AppointmentEntity appt, bool isDark) {
    Color bg;
    Color border;
    Color text;

    if (appt.isConfirmed) {
      bg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFD1FAE5);
      border = const Color(0xFF10B981);
      text = const Color(0xFF10B981);
    } else if (appt.isCancelled) {
      bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2);
      border = const Color(0xFFEF4444);
      text = const Color(0xFFEF4444);
    } else {
      bg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7);
      border = const Color(0xFFF59E0B);
      text = const Color(0xFFF59E0B);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                appt.isConfirmed
                    ? CupertinoIcons.checkmark_circle_fill
                    : (appt.isCancelled
                        ? CupertinoIcons.xmark_circle_fill
                        : CupertinoIcons.clock_fill),
                size: 16,
                color: text,
              ),
              const SizedBox(width: 8),
              Text(
                'STATUS: ${appt.status.toUpperCase()}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: text,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (appt.isPending)
            TextButton(
              onPressed: () {
                context.read<AppointmentsCubit>().createAppointment(
                      customerId: appt.customerId,
                      startAt: appt.startAt,
                    );
              },
              child: const Text('Confirm Now', style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.primaryLightColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: context.colors.primaryLightColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableRow(
    String label,
    String value, {
    required IconData icon,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(icon, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}
