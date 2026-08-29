import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallDetailsHeader extends StatelessWidget {
  final CallHistoryModel call;
  final VoidCallback onCallAdded;
  final VoidCallback? onDelete;

  const CallDetailsHeader({
    super.key,
    required this.call,
    required this.onCallAdded,
    this.onDelete,
  });

  Color _getStatusColor(BuildContext context, String status) {
    final lower = status.toLowerCase();
    if (lower.contains('completed')) return context.colors.successColor;
    if (lower.contains('failed')) return context.colors.errorColor;
    if (lower.contains('queued') || lower.contains('upcoming')) {
      return context.colors.queuedColor;
    }
    return context.colors.primaryLightColor;
  }

  void _copyDetails(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('Call Session with: ${call.fullName}');
    buffer.writeln('Company: ${call.companyName}');
    buffer.writeln('Phone: ${call.phone}');
    buffer.writeln('Status: ${call.status}');
    buffer.writeln('Duration: ${call.duration}');
    buffer.writeln('Date/Time: ${call.callDate} ${call.callTime}');
    buffer.writeln('Assignee: ${call.assignee}');
    if (call.notes != null && call.notes!.isNotEmpty) {
      buffer.writeln('Notes: ${call.notes}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: 'Call details copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  void _copyTranscript(BuildContext context) {
    if (call.transcript.isEmpty) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'No transcript available for this call',
        toastificationType: ToastificationType.info,
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('--- Call Transcript (${call.fullName} • ${call.callDate}) ---');
    for (final turn in call.transcript) {
      buffer.writeln('[${turn.timestamp}] ${turn.speakerName}: ${turn.text}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: 'Full call transcript copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  void _navigateToCustomerProfile(BuildContext context) {
    final customers = context.read<CustomersCubit>().state.users;
    final customer = customers.firstWhere(
      (u) => u.phone == call.phone || u.fullName == call.fullName,
      orElse: () => customers.isNotEmpty
          ? customers.first
          : User(
              id: 1,
              fullName: call.fullName,
              email: call.email ?? '',
              phone: call.phone,
              createdAt: '',
              lastContact: '',
              status: 'Active',
            ),
    );
    context.goNamed(
      AppRoutesPath.customerDetailName,
      pathParameters: {'id': customer.id.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = call.fullName.trim().isEmpty
        ? '?'
        : call.fullName.trim()[0].toUpperCase();
    final statusColor = call.statusColor ?? _getStatusColor(context, call.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeConstants.boxRadius),
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tag, Badges, and Top-Right Action Controls
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Direction Badge (Outbound AI / Inbound AI)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.colors.primaryLightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            call.callDirection.toLowerCase() == 'inbound'
                                ? CupertinoIcons.arrow_down_left
                                : CupertinoIcons.arrow_up_right,
                            size: 10,
                            color: context.colors.primaryLightColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            call.callDirection.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Pill
                    CustomTagWidget(
                      label: call.status,
                      color: statusColor,
                    ),

                    // Duration Badge
                    if (call.duration.isNotEmpty && call.duration != '0:00') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.grey[300]!,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.timer,
                              size: 10,
                              color: context.colors.darkGreyColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              call.duration,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Quick Redial / Action Icon Button
              IconButton(
                tooltip: 'Initiate Call Now',
                onPressed: () async {
                  await CallActionDialog.show(
                    context,
                    fullName: call.fullName,
                    phone: call.phone,
                    initialTab: 'callNow',
                  );
                  onCallAdded();
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colors.primaryLightColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.phone_fill,
                    size: 13,
                    color: context.colors.primaryLightColor,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
              ),
              const SizedBox(width: 10),

              // More Options Menu
              PopupMenuButton<String>(
                tooltip: 'More actions',
                icon: Icon(
                  CupertinoIcons.ellipsis_vertical,
                  size: 16,
                  color: context.colors.darkGreyColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                onSelected: (action) {
                  switch (action) {
                    case 'copy_details':
                      _copyDetails(context);
                      break;
                    case 'copy_transcript':
                      _copyTranscript(context);
                      break;
                    case 'crm_profile':
                      _navigateToCustomerProfile(context);
                      break;
                    case 'delete':
                      ConfirmationDialog.show(
                        context,
                        title: 'Delete Call Log',
                        message:
                            'Are you sure you want to delete the call record for "${call.fullName}"?',
                        confirmLabel: 'Delete',
                        onConfirm: () {
                          onDelete?.call();
                          context.read<SelectedCallCubit>().clearSelection();
                          AppUtils.showSnackBar(
                            context: context,
                            extraMessage: 'Call record deleted successfully',
                            toastificationType: ToastificationType.success,
                          );
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy_details',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.doc_on_doc,
                            size: 15, color: context.colors.darkGreyColor),
                        const SizedBox(width: 10),
                        const Text('Copy Details', style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'copy_transcript',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.chat_bubble_2,
                            size: 15, color: context.colors.darkGreyColor),
                        const SizedBox(width: 10),
                        const Text('Copy Transcript',
                            style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'crm_profile',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.person_crop_circle,
                            size: 15, color: context.colors.primaryLightColor),
                        const SizedBox(width: 10),
                        const Text('View Full CRM Profile',
                            style: TextStyle(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.trash,
                            size: 15, color: context.colors.errorColor),
                        const SizedBox(width: 10),
                        Text('Delete Log',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: context.colors.errorColor,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Close Button
              IconButton(
                tooltip: 'Close panel',
                onPressed: () =>
                    context.read<SelectedCallCubit>().clearSelection(),
                icon: Icon(
                  CupertinoIcons.clear_thick,
                  size: 16,
                  color: context.colors.darkGreyColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Header Info: Avatar + Full Name + Company + Timestamp
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with status ring
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        context.colors.primaryLightColor.withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name, Company, and Phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.fullName.isNotEmpty ? call.fullName : 'Unknown Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (call.companyName.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              call.companyName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.primaryLightColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                        ],
                        Text(
                          '${call.callDate} ${call.callTime}',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: context.colors.darkGreyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
