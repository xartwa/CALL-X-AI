import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/features/customers/widgets/add_customer_dialog.dart';

class QuickOperationsHub extends StatelessWidget {
  const QuickOperationsHub({super.key});

  void _openLaunchBatchCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CallActionDialog(
        startInGroupMode: true,
      ),
    );
  }

  void _openSendMassEmail(BuildContext context) {
    final prefs = context.read<PreferencesService>();
    final templates = prefs.loadTemplates();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SendEmailDialog(
        allTemplates: templates,
        startInGroupMode: true,
        onSendEmail: (newEmail) {
          final existing = prefs.loadEmails();
          existing.insert(0, newEmail);
          prefs.saveEmails(existing);
          AppUtils.showSnackBar(
            context: context,
            title: 'Email Campaign Queued',
            extraMessage:
                'Your follow-up email batch has been successfully queued.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  void _openAddNewCustomer(BuildContext context) async {
    final newUser = await AddCustomerDialog.show(context);
    if (newUser != null && context.mounted) {
      context.read<CustomersCubit>().addCustomer(newUser);
      AppUtils.showSnackBar(
        context: context,
        title: 'Lead Added Successfully',
        extraMessage:
            '${newUser.fullName} has been added to your CRM directory.',
        toastificationType: ToastificationType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpacedText(
                text: "Quick Operations",
                color: context.colors.blackColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      context.colors.primaryLightColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryLightColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid of Operations
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _QuickOpTile(
                      title: 'Launch Batch Call',
                      subtitle: 'Outbound AI Queue',
                      icon: CupertinoIcons.phone_badge_plus,
                      accentColor: context.colors.primaryLightColor,
                      onTap: () => _openLaunchBatchCall(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickOpTile(
                      title: 'Send Bulk Email',
                      subtitle: 'Mass Follow-up',
                      icon: CupertinoIcons.mail_solid,
                      accentColor: const Color(0xFF8B5CF6),
                      onTap: () => _openSendMassEmail(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickOpTile(
                      title: 'Add New Lead',
                      subtitle: 'Instant Prospect',
                      icon: CupertinoIcons.person_crop_circle_badge_plus,
                      accentColor: const Color(0xFF10B981),
                      onTap: () => _openAddNewCustomer(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickOpTile(
                      title: 'AI Voice Settings',
                      subtitle: 'Prompts & Voices',
                      icon: CupertinoIcons.sparkles,
                      accentColor: const Color(0xFFF59E0B),
                      onTap: () => context.go(AppRoutesPath.aiSettings),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickOpTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickOpTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: accentColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : context.colors.mediumGreyColor.withValues(alpha: 0.25),
            ),
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : context.colors.mediumGreyColor.withValues(alpha: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 17),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: context.colors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.darkGreyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
