import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/cubit/email_follow_ups_cubit.dart';
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
    final emailCubit = context.read<EmailFollowUpsCubit>();
    final templates = emailCubit.state.templates
        .map((template) => template.toViewMap())
        .toList(growable: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SendEmailDialog(
        allTemplates: templates,
        startInGroupMode: true,
        onSendEmail: emailCubit.send,
      ),
    );
  }

  void _openAddNewCustomer(BuildContext context) async {
    final newUser = await AddCustomerDialog.show(context);
    if (newUser != null && context.mounted) {
      await context.read<CustomersCubit>().addCustomer(newUser);
      if (!context.mounted) return;

      final error = context.read<CustomersCubit>().state.actionError;
      AppUtils.showSnackBar(
        context: context,
        title: error == null ? 'Lead Added Successfully' : 'Unable to Add Lead',
        extraMessage: error ??
            '${newUser.fullName} has been added to your CRM directory.',
        toastificationType: error == null
            ? ToastificationType.success
            : ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.25),
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
          SpacedText(
            text: "Quick Actions",
            color: context.colors.blackColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          const SizedBox(height: 20),

          // 2x2 Minimal Action Buttons
          Row(
            children: [
              Expanded(
                child: _MinimalActionCard(
                  title: 'Batch Call',
                  icon: CupertinoIcons.phone_badge_plus,
                  accentColor: context.colors.primaryLightColor,
                  onTap: () => _openLaunchBatchCall(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MinimalActionCard(
                  title: 'Bulk Email',
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
                child: _MinimalActionCard(
                  title: 'Add Lead',
                  icon: CupertinoIcons.person_badge_plus,
                  accentColor: const Color(0xFF10B981),
                  onTap: () => _openAddNewCustomer(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MinimalActionCard(
                  title: 'AI Setup',
                  icon: CupertinoIcons.sparkles,
                  accentColor: const Color(0xFFF59E0B),
                  onTap: () => context.go(AppRoutesPath.aiSettings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MinimalActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _MinimalActionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_MinimalActionCard> createState() => _MinimalActionCardState();
}

class _MinimalActionCardState extends State<_MinimalActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withValues(alpha: 0.4)
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : context.colors.mediumGreyColor
                            .withValues(alpha: 0.35)),
              ),
              color: _isHovered
                  ? (isDark
                      ? const Color(0xFF162032)
                      : widget.accentColor.withValues(alpha: 0.05))
                  : (isDark
                      ? const Color(0xFF0F172A)
                      : context.colors.milkyColor.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.colors.blackColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 11,
                  color: _isHovered
                      ? widget.accentColor
                      : context.colors.darkGreyColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
