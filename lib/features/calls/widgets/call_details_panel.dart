import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallDetailsPanel extends StatefulWidget {
  final CallHistoryModel call;
  final VoidCallback onCallAdded;
  final ValueChanged<CallHistoryModel>? onCallUpdated;
  final VoidCallback? onDelete;

  const CallDetailsPanel({
    super.key,
    required this.call,
    required this.onCallAdded,
    this.onCallUpdated,
    this.onDelete,
  });

  @override
  State<CallDetailsPanel> createState() => _CallDetailsPanelState();
}

class _CallDetailsPanelState extends State<CallDetailsPanel> {
  late final TextEditingController _notesCtrl;
  String? _followUpDate;
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.call.notes ?? '');
    _followUpDate = widget.call.nextFollowUpDate;
  }

  @override
  void didUpdateWidget(CallDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.id != widget.call.id) {
      _notesCtrl.text = widget.call.notes ?? '';
      _followUpDate = widget.call.nextFollowUpDate;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, String status) {
    final lower = status.toLowerCase();
    if (lower.contains('completed')) return context.colors.successColor;
    if (lower.contains('failed')) return context.colors.errorColor;
    if (lower.contains('queued') || lower.contains('upcoming')) {
      return context.colors.queuedColor;
    }
    return context.colors.primaryLightColor;
  }

  String _getDynamicSummary() {
    if (widget.call.notes != null && widget.call.notes!.isNotEmpty) {
      return widget.call.notes!;
    }

    switch (widget.call.status) {
      case 'Completed':
        return 'Customer (${widget.call.fullName}) was contacted by ${widget.call.assignee}. Key project scope, budget estimation, and delivery terms were discussed. Customer expressed strong interest in proceeding.';
      case 'Failed':
        return 'Call was unanswered or disconnected. A follow-up attempt has been logged for scheduling.';
      case 'Queued':
        return 'Call is placed in the outbound queue. The system will initiate dialing as soon as an AI line is available.';
      case 'Upcoming':
        return 'Scheduled outgoing call. The system will initiate dialing at the specified date and time.';
      default:
        return 'Call session record logged.';
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: '$label copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  void _copyTranscript() {
    if (widget.call.transcript.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln(
        '=== Call Transcript: ${widget.call.fullName} (${widget.call.callDate} • ${widget.call.callTime}) ===');
    for (final t in widget.call.transcript) {
      buffer.writeln('[${t.timestamp}] ${t.speakerName}: ${t.text}');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: 'Transcript copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  void _saveNotesAndFollowUp() async {
    setState(() => _isSavingNotes = true);
    await Future.delayed(const Duration(milliseconds: 150));

    final updated = widget.call.copyWith(
      notes: _notesCtrl.text.trim(),
      nextFollowUpDate: _followUpDate ?? '',
    );

    widget.onCallUpdated?.call(updated);

    if (mounted) {
      setState(() => _isSavingNotes = false);
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Call notes & follow-up saved',
        toastificationType: ToastificationType.success,
      );
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy/MM/dd').format(picked);
      setState(() {
        _followUpDate = formatted;
      });
    }
  }

  void _setPresetDate(int daysToAdd) {
    final target = DateTime.now().add(Duration(days: daysToAdd));
    final formatted = DateFormat('yyyy/MM/dd').format(target);
    setState(() {
      _followUpDate = formatted;
    });
  }

  void _navigateToCustomerProfile() {
    final customers = context.read<CustomersCubit>().state.users;
    final customer = customers.firstWhere(
      (u) =>
          u.phone == widget.call.phone || u.fullName == widget.call.fullName,
      orElse: () => customers.isNotEmpty
          ? customers.first
          : User(
              id: 1,
              fullName: widget.call.fullName,
              email: widget.call.email ?? '',
              phone: widget.call.phone,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = (screenWidth * 0.34).clamp(460.0, 520.0);

    final statusColor = widget.call.statusColor ??
        _getStatusColor(context, widget.call.status);
    final initials = widget.call.fullName.trim().isEmpty
        ? '?'
        : widget.call.fullName.trim()[0].toUpperCase();
    final summaryText = _getDynamicSummary();

    return Container(
      width: panelWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : context.colors.lightGreyColor.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(-2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Fixed Header Area
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(ThemeConstants.boxRadius),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white10
                      : context.colors.mediumGreyColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status & Close Row
                Row(
                  children: [
                    CustomTagWidget(
                      label: widget.call.status,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    if (widget.call.duration.isNotEmpty &&
                        widget.call.duration != '0:00') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.grey[300]!,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.timer,
                              size: 11,
                              color: context.colors.darkGreyColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.call.duration,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close details',
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
                const SizedBox(height: 12),

                // Customer Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: context.colors.primaryLightColor
                          .withValues(alpha: 0.15),
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.colors.primaryLightColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.call.fullName.isNotEmpty
                                ? widget.call.fullName
                                : 'Contact',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (widget.call.companyName.isNotEmpty) ...[
                                Flexible(
                                  child: Text(
                                    widget.call.companyName,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.primaryLightColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(' • ',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: context.colors.darkGreyColor)),
                              ],
                              InkWell(
                                onTap: () => _copyToClipboard(
                                    widget.call.phone, 'Phone number'),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.call.phone,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: context.colors.darkGreyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      CupertinoIcons.doc_on_doc,
                                      size: 11,
                                      color: context.colors.primaryLightColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Action Buttons Row (Direct Call, Schedule, View Profile)
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await CallActionDialog.show(
                              context,
                              fullName: widget.call.fullName,
                              phone: widget.call.phone,
                              initialTab: 'callNow',
                            );
                            widget.onCallAdded();
                          },
                          icon: const Icon(
                            CupertinoIcons.phone_fill,
                            size: 13,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'CALL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                context.colors.primaryLightColor,
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
                      flex: 5,
                      child: SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await CallActionDialog.show(
                              context,
                              fullName: widget.call.fullName,
                              phone: widget.call.phone,
                              initialTab: 'schedule',
                            );
                            widget.onCallAdded();
                          },
                          icon: Icon(
                            CupertinoIcons.calendar,
                            size: 13,
                            color: context.colors.primaryLightColor,
                          ),
                          label: Text(
                            'SCHEDULE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.colors.primaryLightColor
                                  .withValues(alpha: 0.6),
                              width: 1.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'View Full CRM Profile',
                      child: SizedBox(
                        height: 36,
                        width: 36,
                        child: OutlinedButton(
                          onPressed: _navigateToCustomerProfile,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white24
                                  : context.colors.mediumGreyColor,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.person_crop_circle,
                            size: 16,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Audio Recording Player
                  CallAudioPlayerWidget(call: widget.call),
                  const SizedBox(height: 14),

                  // 4. AI Executive Summary & Outcome
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1E293B),
                                const Color(0xFF0F172A)
                              ]
                            : [
                                const Color(0xFFF0F7FF),
                                const Color(0xFFE0E7FF)
                              ],
                      ),
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.boxRadius),
                      border: Border.all(
                        color: isDark
                            ? context.colors.primaryLightColor
                                .withValues(alpha: 0.3)
                            : const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.sparkles,
                                  size: 14,
                                  color: context.colors.primaryLightColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'AI SUMMARY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.call.lastContactResult != null &&
                                widget.call.lastContactResult!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryLightColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.call.lastContactResult!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summaryText,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.9)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Call Transcript Section
                  if (widget.call.transcript.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.boxRadius),
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : context.colors.mediumGreyColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.chat_bubble_2_fill,
                                    size: 14,
                                    color: context.colors.primaryLightColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'CALL TRANSCRIPT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _copyTranscript,
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_on_doc,
                                        size: 12,
                                        color:
                                            context.colors.primaryLightColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy All',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: context
                                              .colors.primaryLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Transcript Turns
                          ...widget.call.transcript.map((turn) {
                            final isAi = turn.speaker == 'ai';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: isAi
                                          ? context.colors.primaryLightColor
                                              .withValues(alpha: 0.15)
                                          : context.colors.successColor
                                              .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isAi
                                          ? CupertinoIcons.bolt_badge_a
                                          : CupertinoIcons.person_fill,
                                      size: 11,
                                      color: isAi
                                          ? context.colors.primaryLightColor
                                          : context.colors.successColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              turn.speakerName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: isAi
                                                    ? context.colors
                                                        .primaryLightColor
                                                    : (isDark
                                                        ? Colors.white
                                                        : Colors.black87),
                                              ),
                                            ),
                                            Text(
                                              turn.timestamp,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: context
                                                    .colors.darkGreyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isAi
                                                ? (isDark
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFFEFF6FF))
                                                : (isDark
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFFF8FAFC)),
                                            borderRadius: BorderRadius.circular(
                                                ThemeConstants.boxRadius),
                                            border: Border.all(
                                              color: isAi
                                                  ? (isDark
                                                      ? Colors.white10
                                                      : const Color(0xFFDBEAFE))
                                                  : (isDark
                                                      ? Colors.white12
                                                      : context.colors
                                                          .mediumGreyColor),
                                            ),
                                          ),
                                          child: Text(
                                            turn.text,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.35,
                                              color: isDark
                                                  ? Colors.white
                                                      .withValues(alpha: 0.9)
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 6. Notes & Follow-up Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.boxRadius),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : context.colors.mediumGreyColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.doc_plaintext,
                              size: 14,
                              color: context.colors.primaryLightColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NOTES & NEXT FOLLOW-UP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Text Field for Agent Notes
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : context.colors.mediumGreyColor,
                            ),
                          ),
                          child: TextField(
                            controller: _notesCtrl,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Add private follow-up notes or action requirements...',
                              hintStyle: TextStyle(
                                fontSize: 11.5,
                                color: context.colors.darkGreyColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Follow-up Date Selector Bar
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : context.colors.mediumGreyColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  size: 14,
                                  color: context.colors.primaryLightColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (_followUpDate != null &&
                                          _followUpDate!.isNotEmpty)
                                      ? 'Follow-up: $_followUpDate'
                                      : 'Set follow-up date',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: (_followUpDate != null &&
                                            _followUpDate!.isNotEmpty)
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: (_followUpDate != null &&
                                            _followUpDate!.isNotEmpty)
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.black87)
                                        : context.colors.darkGreyColor,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 12,
                                  color: context.colors.darkGreyColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Presets Row (Tomorrow, In 3 Days, Next Week)
                        Row(
                          children: [
                            _buildPresetChip(
                                'Tomorrow', () => _setPresetDate(1)),
                            const SizedBox(width: 6),
                            _buildPresetChip(
                                'In 3 Days', () => _setPresetDate(3)),
                            const SizedBox(width: 6),
                            _buildPresetChip(
                                'Next Week', () => _setPresetDate(7)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isSavingNotes ? null : _saveNotesAndFollowUp,
                            icon: _isSavingNotes
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(CupertinoIcons.checkmark_alt,
                                    size: 14, color: Colors.white),
                            label: Text(
                              _isSavingNotes
                                  ? 'SAVING...'
                                  : 'SAVE NOTES & FOLLOW-UP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.colors.primaryLightColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
