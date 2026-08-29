import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class TodayScheduledCallTile extends StatefulWidget {
  final DashboardTodayCall call;
  final bool isPriority;
  final bool isNext;
  final bool isDone;

  const TodayScheduledCallTile({
    super.key,
    required this.call,
    this.isPriority = false,
    this.isNext = false,
    this.isDone = false,
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
        fullName: widget.call.fullName,
        phone: widget.call.phone,
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
                'Follow-up email dispatched to ${widget.call.fullName}.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  Color _tagColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('hot') || l.contains('lost') || l.contains('failed')) {
      return const Color(0xFFEF4444);
    }
    if (l.contains('warm') || l.contains('pending') || l.contains('queued')) {
      return const Color(0xFFF59E0B);
    }
    if (l.contains('qualified') ||
        l.contains('won') ||
        l.contains('completed')) {
      return const Color(0xFF10B981);
    }
    if (l.contains('developer') ||
        l.contains('agency') ||
        l.contains('startup')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCall =
        widget.call.availableActions.contains(DashboardCallAction.call) ||
            widget.call.availableActions.contains(DashboardCallAction.callNow);
    final canEmail =
        widget.call.availableActions.contains(DashboardCallAction.email);
    final canView =
        widget.call.availableActions.contains(DashboardCallAction.view);

    // — Computed values —
    final initials = widget.call.fullName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final legacyTime =
        '${widget.call.timeLabel} ${widget.call.meridiem}'.trim();
    final timeHour = AppDateTime.displayTime(
      widget.call.scheduledFor ?? legacyTime,
      fallback: '--:--',
    );

    // Tag logic
    String? displayTag;
    Color? tagColor;
    if (widget.isPriority || widget.call.leadPriority.toLowerCase() == 'hot') {
      displayTag = 'Hot';
      tagColor = const Color(0xFFEF4444);
    } else if (widget.call.leadPriority.toLowerCase() == 'warm') {
      displayTag = 'Warm';
      tagColor = const Color(0xFFF59E0B);
    } else if (widget.call.companyName.isNotEmpty) {
      displayTag = widget.call.companyName;
      tagColor = _tagColor(displayTag);
    }

    // Call objective
    final objective = widget.call.purpose.isNotEmpty
        ? widget.call.purpose
        : 'Pipeline consultation';

    // — Colors & States —
    final accentColor = widget.isNext
        ? context.colors.primaryLightColor
        : widget.isDone
            ? context.colors.successColor
            : context.colors.blackColor;

    Color cardBg;
    Color cardBorder;
    if (widget.isNext) {
      cardBg = context.colors.primaryLightColor
          .withValues(alpha: isDark ? 0.06 : 0.04);
      cardBorder = context.colors.primaryLightColor.withValues(alpha: 0.35);
    } else if (widget.isDone) {
      cardBg = Colors.transparent;
      cardBorder = Colors.transparent;
    } else if (_isHovered) {
      cardBg = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : context.colors.milkyColor;
      cardBorder = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : context.colors.mediumGreyColor.withValues(alpha: 0.7);
    } else {
      cardBg = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : context.colors.milkyColor.withValues(alpha: 0.4);
      cardBorder = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : context.colors.mediumGreyColor.withValues(alpha: 0.35);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cardBorder),
        ),
        child: Opacity(
          opacity: widget.isDone ? 0.55 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. Time ──────────────────────────────────────
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeHour,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.isNext) ...[
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                        ],
                        if (widget.isDone) ...[
                          const SizedBox(width: 4),
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 10,
                            color: context.colors.successColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Vertical separator
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: widget.isNext
                    ? context.colors.primaryLightColor.withValues(alpha: 0.3)
                    : context.colors.mediumGreyColor.withValues(alpha: 0.5),
              ),

              // ── 2. Avatar ─────────────────────────────────────
              Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.1),
                      border: widget.isNext
                          ? Border.all(
                              color: context.colors.primaryLightColor
                                  .withValues(alpha: 0.35),
                              width: 1.5,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                  // Hot lead indicator dot
                  if (widget.isPriority)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444),
                          border: Border.all(
                            color: context.colors.whiteColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 13),

              // ── 3. Contact Info ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + tag
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.call.fullName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.blackColor,
                              decoration: widget.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: context.colors.darkGreyColor
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (displayTag != null && tagColor != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: tagColor.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              displayTag,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: tagColor,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3.5),
                    // Company + objective (subtitle)
                    Row(
                      children: [
                        if (widget.call.companyName.isNotEmpty) ...[
                          Icon(
                            CupertinoIcons.building_2_fill,
                            size: 10,
                            color: context.colors.darkGreyColor
                                .withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.call.companyName,
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
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '·',
                              style: TextStyle(
                                color: context.colors.darkGreyColor
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            objective,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.darkGreyColor
                                  .withValues(alpha: 0.8),
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

              const SizedBox(width: 12),

              // ── 4. Actions ───────────────────────────────────────
              if (!widget.isDone && (canCall || canEmail))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Call button — same green style for both next & upcoming
                    if (canCall)
                      InkWell(
                        onTap: () => _openCall(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: context.colors.successColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.colors.successColor
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.phone_fill,
                                size: 12,
                                color: context.colors.successColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.isNext ? "Call Now" : "Call",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (canCall && canEmail) const SizedBox(width: 7),
                    // Email icon button
                    if (canEmail)
                      Tooltip(
                        message: 'Send Email',
                        child: InkWell(
                          onTap: () => _openEmail(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.mail_solid,
                              size: 13.5,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              else if (canView)
                Tooltip(
                  message: 'View calls',
                  child: InkWell(
                    onTap: () => context.go(AppRoutesPath.calls),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: context.colors.primaryLightColor
                            .withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colors.primaryLightColor
                              .withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.person_fill,
                            size: 12,
                            color: context.colors.primaryLightColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "View",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                        ],
                      ),
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
