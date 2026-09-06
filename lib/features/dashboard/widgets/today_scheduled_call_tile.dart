import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
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

  void _openDetails(BuildContext context) {
    context.read<CallsCubit>().selectCallById(widget.call.id);
    context.go(AppRoutesPath.calls);
  }

  void _onTileTap(BuildContext context) {
    if (!widget.isDone) {
      _openCall(context);
    } else {
      _openDetails(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Formatted time (e.g. 19:00 or 07:00 PM)
    final legacyTime =
        '${widget.call.timeLabel} ${widget.call.meridiem}'.trim();
    final timeDisplay = AppDateTime.displayTime(
      widget.call.scheduledFor ?? legacyTime,
      fallback: widget.call.timeLabel.isNotEmpty ? widget.call.timeLabel : '--:--',
    );

    // Two-letter initials for contact avatar
    final initials = widget.call.fullName
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    // Priority
    final isHot = widget.isPriority || widget.call.leadPriority.toLowerCase() == 'hot';
    final isWarm = widget.call.leadPriority.toLowerCase() == 'warm';

    // Outcome / Status determination
    final isBooked = widget.call.isAppointmentBooked;
    final isNoAnswer = widget.call.isNoAnswer;
    final isInterested = widget.call.isInterested;

    // Unified card background & border
    final cardBg = _isHovered
        ? (isDark
            ? const Color(0xFF162032)
            : context.colors.milkyColor)
        : (isDark
            ? const Color(0xFF0F172A)
            : context.colors.milkyColor.withValues(alpha: 0.35));

    final cardBorder = _isHovered
        ? (isDark
            ? const Color(0xFF334155)
            : context.colors.mediumGreyColor.withValues(alpha: 0.7))
        : (isDark
            ? AppColors.darkSlateColor
            : context.colors.mediumGreyColor.withValues(alpha: 0.3));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => _onTileTap(context),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. Time (Clean, fixed width) ──────────────────────────────
              SizedBox(
                width: 52,
                child: Text(
                  timeDisplay,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: widget.isNext
                        ? context.colors.primaryLightColor
                        : context.colors.blackColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── 2. Avatar ─────────────────────────────────────────────────
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primaryLightColor.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryLightColor,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── 3. Contact Details (Name + Company & Phone) ───────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Line 1: Name + Priority Pill
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.call.fullName.isEmpty
                                ? 'Unknown Contact'
                                : widget.call.fullName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isHot) ...[
                          const SizedBox(width: 6),
                          _buildPill('Hot', const Color(0xFFEF4444)),
                        ] else if (isWarm) ...[
                          const SizedBox(width: 6),
                          _buildPill('Warm', const Color(0xFFF59E0B)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Line 2: Company • Phone
                    Row(
                      children: [
                        if (widget.call.companyName.isNotEmpty) ...[
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
                          if (widget.call.phone.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: context.colors.darkGreyColor
                                      .withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                        if (widget.call.phone.isNotEmpty)
                          Text(
                            widget.call.phone,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: context.colors.darkGreyColor
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ── 4. Unified Status Badge ───────────────────────────────────
              _buildStatusBadge(
                isBooked: isBooked,
                isInterested: isInterested,
                isNoAnswer: isNoAnswer,
                isDone: widget.isDone,
                isNext: widget.isNext,
                status: widget.call.status,
              ),

              const SizedBox(width: 10),

              // ── 5. Unified Action Button (Same dimensions on all cards) ───
              SizedBox(
                width: 68,
                height: 28,
                child: !widget.isDone
                    ? InkWell(
                        onTap: () => _openCall(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.successColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: context.colors.successColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.phone_fill,
                                size: 10.5,
                                color: context.colors.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Call",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () => _openDetails(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSlateColor
                                : context.colors.mediumGreyColor
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : context.colors.mediumGreyColor
                                      .withValues(alpha: 0.35),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "View",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                CupertinoIcons.chevron_right,
                                size: 9.5,
                                color: context.colors.darkGreyColor,
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

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required bool isBooked,
    required bool isInterested,
    required bool isNoAnswer,
    required bool isDone,
    required bool isNext,
    required String status,
  }) {
    final String label;
    final Color color;

    if (isBooked) {
      label = 'Booked 📅';
      color = const Color(0xFF10B981);
    } else if (isInterested) {
      label = 'Interested';
      color = const Color(0xFF6366F1);
    } else if (isNoAnswer) {
      label = 'No Answer';
      color = const Color(0xFFEF4444);
    } else if (isDone) {
      label = 'Completed';
      color = const Color(0xFF10B981);
    } else if (isNext) {
      label = 'Due Now';
      color = const Color(0xFF6366F1);
    } else {
      label = 'Scheduled';
      color = const Color(0xFF64748B);
    }

    return Container(
      width: 78,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 0.8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
