import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/widgets/chip_tag_widget.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CallDetailsPanel extends StatelessWidget {
  final CallHistoryModel call;
  final VoidCallback onCallAdded;

  const CallDetailsPanel({
    super.key,
    required this.call,
    required this.onCallAdded,
  });

  String _getDynamicSummary() {
    if (call.notes != null && call.notes!.isNotEmpty) {
      return call.notes!;
    }

    switch (call.status) {
      case 'Completed':
        return 'The customer was successfully contacted by ${call.assignee}. Discussed project estimation and business terms. Customer expressed strong interest in proceeding.';
      case 'Failed':
        return 'The call was disconnected or unanswered. A follow-up attempt has been logged for scheduling.';
      case 'Queued':
        return 'Call is currently placed in the outbound queue. The system will initiate dialing as soon as ${call.assignee} is free.';
      case 'Upcoming':
        return 'Scheduled outgoing call. The system will alert ${call.assignee} to contact the customer at the specified date and time.';
      default:
        return 'No summary available for this call session.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = call.fullName.trim().isEmpty
        ? '?'
        : call.fullName.trim()[0].toUpperCase();

    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.of(context).size.width / 4.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: context.colors.lightGreyColor.withAlpha(50),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CALL SESSION',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: context.colors.darkGreyColor,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.read<SelectedCallCubit>().clearSelection(),
                  icon: const Icon(CupertinoIcons.clear_thick, size: 22),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Profile Header section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        context.colors.primaryLightColor.withAlpha(20),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    call.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (call.companyName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      call.companyName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    call.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.darkGreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tags (if available)
            if (call.tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: call.tags.map((t) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLightColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: context.colors.primaryLightColor
                              .withOpacity(0.3)),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // Direct Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await CallActionDialog.show(
                          context,
                          fullName: call.fullName,
                          phone: call.phone,
                          initialTab: 'callNow',
                        );
                        onCallAdded();
                      },
                      icon: const Icon(CupertinoIcons.phone_fill,
                          size: 15, color: Colors.white),
                      label: const Text(
                        'CALL',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primaryLightColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await CallActionDialog.show(
                          context,
                          fullName: call.fullName,
                          phone: call.phone,
                          initialTab: 'schedule',
                        );
                        onCallAdded();
                      },
                      icon: Icon(CupertinoIcons.calendar,
                          size: 14, color: context.colors.primaryLightColor),
                      label: Text(
                        'SCHEDULE',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primaryLightColor),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: context.colors.primaryLightColor,
                            width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // View Profile text button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton.icon(
                onPressed: () {
                  final customers = context.read<CustomersCubit>().state.users;
                  final customer = customers.firstWhere(
                    (u) => u.phone == call.phone || u.fullName == call.fullName,
                    orElse: () => customers.first,
                  );
                  context.goNamed(
                    AppRoutesPath.customerDetailName,
                    pathParameters: {'id': customer.id.toString()},
                  );
                },
                icon: Icon(CupertinoIcons.person_crop_circle,
                    size: 16, color: context.colors.primaryLightColor),
                label: Text(
                  'VIEW FULL PROFILE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primaryLightColor,
                    letterSpacing: 0.5,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      context.colors.primaryLightColor.withAlpha(10),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Divider(
                height: 1, thickness: 1, color: context.colors.mediumGreyColor),
            const SizedBox(height: 16),

            // Metadata List
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SpacedText(
                    text: "Call Details".toUpperCase(),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2.5,
                    color: context.colors.blackColor,
                  ),
                ),
                const SizedBox(height: 14),
                _buildField(
                  context,
                  icon: CupertinoIcons.device_phone_portrait,
                  label: 'Phone',
                  value: call.phone,
                ),
                const SizedBox(height: 12),
                _buildField(
                  context,
                  icon: CupertinoIcons.info_circle,
                  label: 'Status',
                  value: call.status,
                  widget: tagChipWidget(
                    context: context,
                    tagName: call.status,
                    customColor: call.statusColor ?? Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildField(
                  context,
                  icon: CupertinoIcons.person,
                  label: 'Assignee',
                  value: call.assignee,
                ),
                const SizedBox(height: 12),
                _buildField(
                  context,
                  icon: CupertinoIcons.timer,
                  label: 'Duration',
                  value: call.duration,
                ),
                const SizedBox(height: 12),
                _buildField(
                  context,
                  icon: CupertinoIcons.calendar,
                  label: 'Scheduled',
                  value: '${call.callDate}  •  ${call.callTime}',
                ),
                if (call.nextFollowUpDate != null &&
                    call.nextFollowUpDate!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildField(
                    context,
                    icon: CupertinoIcons.calendar_badge_plus,
                    label: 'Next Follow-up',
                    value: call.nextFollowUpDate!,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),
            Divider(
                height: 1, thickness: 1, color: context.colors.mediumGreyColor),
            const SizedBox(height: 16),

            // AI Summary Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFDBEAFE),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.sparkles,
                          size: 15, color: context.colors.primaryLightColor),
                      const SizedBox(width: 6),
                      SpacedText(
                        text: "Ai summary".toUpperCase(),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 2,
                        color: context.colors.primaryLightColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getDynamicSummary(),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? widget,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: 16, color: context.colors.darkGreyColor.withAlpha(180)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
        ),
        const Spacer(),
        widget ??
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
      ],
    );
  }
}
