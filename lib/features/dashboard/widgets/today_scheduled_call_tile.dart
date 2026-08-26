import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class TodayScheduledCallTile extends StatelessWidget {
  final User user;
  final String scheduledTime;
  final bool isPriority;

  const TodayScheduledCallTile({
    super.key,
    required this.user,
    required this.scheduledTime,
    this.isPriority = false,
  });

  void _openCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CallActionDialog(
        fullName: user.fullName,
        phone: user.phone,
        initialTab: 'callNow',
      ),
    );
  }

  void _openEmail(BuildContext context) {
    final prefs = context.read<PreferencesService>();
    final templates = prefs.loadTemplates();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SendEmailDialog(
        allTemplates: templates,
        onSendEmail: (newEmail) {
          final existing = prefs.loadEmails();
          existing.insert(0, newEmail);
          prefs.saveEmails(existing);
          AppUtils.showSnackBar(
            context: context,
            title: 'Email Sent',
            extraMessage: 'Follow-up email dispatched to ${user.fullName}.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHot = user.leadPriority.toLowerCase() == 'hot' || isPriority;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.01)
            : context.colors.milkyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
     
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.primaryLightColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primaryLightColor.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.clock_fill,
                  size: 12,
                  color: context.colors.primaryLightColor,
                ),
                const SizedBox(width: 5),
                Text(
                  scheduledTime,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primaryLightColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // User Initials Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:  context.colors.primaryLightColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Text(
              user.fullName.isNotEmpty
                  ? user.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.colors.primaryLightColor
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: context.colors.blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isHot) ...[
                      const SizedBox(width: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: context.colors.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (user.companyName.isNotEmpty) ...[
                      Flexible(
                        child: Text(
                          user.companyName,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: context.colors.darkGreyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        " • ",
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                    ],
                    Text(
                      user.phone,
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
          const SizedBox(width: 12),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: CupertinoIcons.phone_fill,
                color: context.colors.successColor,
                tooltip: 'Call Now',
                onTap: () => _openCall(context),
              ),
              const SizedBox(width: 8),
              _ActionIconButton(
                icon: CupertinoIcons.mail_solid,
                color: const Color(0xFF8B5CF6),
                tooltip: 'Send Email',
                onTap: () => _openEmail(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 15,
            color: color,
          ),
        ),
      ),
    );
  }
}
