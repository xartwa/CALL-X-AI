import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/core/utils/utils.dart';

class TodayScheduledCallTile extends StatefulWidget {
  final User user;
  final String scheduledTime;
  final bool isPriority;

  const TodayScheduledCallTile({
    super.key,
    required this.user,
    required this.scheduledTime,
    this.isPriority = false,
  });

  @override
  State<TodayScheduledCallTile> createState() => _TodayScheduledCallTileState();
}

class _TodayScheduledCallTileState extends State<TodayScheduledCallTile> {
  bool _isHovered = false;

  void _openCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CallActionDialog(
        fullName: widget.user.fullName,
        phone: widget.user.phone,
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
            extraMessage:
                'Follow-up email dispatched to ${widget.user.fullName}.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  Color _getTagColor(String tagLabel) {
    final lower = tagLabel.toLowerCase();
    if (lower.contains('hot') || lower.contains('lost') || lower.contains('failed')) {
      return const Color(0xFFEF4444);
    }
    if (lower.contains('warm') || lower.contains('queued') || lower.contains('pending')) {
      return const Color(0xFFF59E0B);
    }
    if (lower.contains('qualified') || lower.contains('won') || lower.contains('completed') || lower.contains('excellent')) {
      return const Color(0xFF10B981);
    }
    if (lower.contains('developer') || lower.contains('agency')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHot = widget.user.leadPriority.toLowerCase() == 'hot' || widget.isPriority;

    final initials = widget.user.fullName.isNotEmpty
        ? widget.user.fullName
            .trim()
            .split(' ')
            .where((e) => e.isNotEmpty)
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    // Determine relevant tag for display
    String? displayTag;
    Color? tagColor;

    if (isHot) {
      displayTag = 'Hot Lead';
      tagColor = const Color(0xFFEF4444);
    } else if (widget.user.leadPriority.isNotEmpty && widget.user.leadPriority.toLowerCase() != 'warm') {
      displayTag = widget.user.leadPriority;
      tagColor = _getTagColor(displayTag);
    } else if (widget.user.tags.isNotEmpty) {
      displayTag = widget.user.tags.first;
      tagColor = _getTagColor(displayTag);
    } else if (widget.user.leadStatus.isNotEmpty) {
      displayTag = widget.user.leadStatus;
      tagColor = _getTagColor(displayTag);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : context.colors.milkyColor)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered
                ? (isDark
                    ? Colors.white12
                    : context.colors.mediumGreyColor.withValues(alpha: 0.5))
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Minimalist Time Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : context.colors.mediumGreyColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.scheduledTime,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.blackColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Unified, Consistent Avatar (Neutral / Theme Blue)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primaryLightColor.withValues(alpha: 0.1),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryLightColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Customer Name & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.user.fullName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.blackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (displayTag != null && tagColor != null) ...[
                        const SizedBox(width: 6),
                        _MicroTagBadge(
                          label: displayTag,
                          color: tagColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (widget.user.companyName.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            widget.user.companyName,
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
                        widget.user.phone,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Minimalist Action Icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MinimalActionBtn(
                  icon: CupertinoIcons.phone_fill,
                  color: context.colors.successColor,
                  tooltip: 'Call Now',
                  onTap: () => _openCall(context),
                ),
                const SizedBox(width: 6),
                _MinimalActionBtn(
                  icon: CupertinoIcons.mail_solid,
                  color: const Color(0xFF8B5CF6),
                  tooltip: 'Send Email',
                  onTap: () => _openEmail(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MicroTagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MicroTagBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MinimalActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MinimalActionBtn({
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 13.5,
            color: color,
          ),
        ),
      ),
    );
  }
}
