import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/widgets/app_date_time_picker.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
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
  final VoidCallback? onClose;

  const CallDetailsPanel({
    super.key,
    required this.call,
    required this.onCallAdded,
    this.onCallUpdated,
    this.onDelete,
    this.onClose,
  });

  @override
  State<CallDetailsPanel> createState() => _CallDetailsPanelState();
}

class _CallDetailsPanelState extends State<CallDetailsPanel> {
  DateTime? _followUpDate;

  @override
  void initState() {
    super.initState();
    _followUpDate = widget.call.nextFollowUpDate;
  }

  @override
  void didUpdateWidget(CallDetailsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.id != widget.call.id) {
      _followUpDate = widget.call.nextFollowUpDate;
    }
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
        return 'Customer (${widget.call.fullName}) was contacted by AI (B2B Sales).\nKey project scope, budget estimation, and delivery terms were discussed.\nCustomer expressed strong interest in proceeding.';
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
        '=== Call Transcript: ${widget.call.fullName} (${AppDateTime.displayDateTime(widget.call.dateTime)}) ===');
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

  void _saveFollowUpDate(DateTime? newDate) async {
    setState(() {
      _followUpDate = newDate;
    });

    final formatted = newDate == null ? '' : AppDateTime.apiDateTime(newDate);

    if (formatted.isNotEmpty) {
      await context
          .read<CallsCubit>()
          .scheduleFollowUp(widget.call.id, formatted);
    } else {
      await context.read<CallsCubit>().clearFollowUp(widget.call.id);
    }

    if (!mounted) return;

    final updated = widget.call.copyWith(
      nextFollowUpDate: newDate,
    );

    widget.onCallUpdated?.call(updated);
    context.read<SelectedCallCubit>().updateFollowUpDate(newDate);

    AppUtils.showSnackBar(
      context: context,
      extraMessage: newDate != null
          ? 'Follow-up scheduled for ${AppDateTime.displayDateTime(newDate)}'
          : 'Follow-up date cleared',
      toastificationType: ToastificationType.success,
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    DateTime initial = now.add(const Duration(days: 1));
    if (_followUpDate != null) {
      initial = _followUpDate!;
    }

    final picked = await AppDateTimePicker.pickDateTime(
      context,
      initial: initial.isBefore(now) ? now : initial,
      first: now,
      last: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      _saveFollowUpDate(picked);
    }
  }

  void _navigateToCustomerProfile() {
    if (widget.call.customerId != null && widget.call.customerId!.isNotEmpty) {
      context.goNamed(
        AppRoutesPath.customerDetailName,
        pathParameters: {'id': widget.call.customerId!},
      );
      return;
    }

    final customers = context.read<CustomersCubit>().state.users;
    final customer = customers.firstWhere(
      (u) => u.phone == widget.call.phone || u.fullName == widget.call.fullName,
      orElse: () => customers.isNotEmpty
          ? customers.first
          : Customer(
              id: '1',
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

    final statusColor =
        widget.call.statusColor ?? _getStatusColor(context, widget.call.status);

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
              ? const Color(0xFF1E293B)
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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(ThemeConstants.boxRadius),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : context.colors.mediumGreyColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: context.colors.primaryLightColor
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Customer Name, Company, Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.call.fullName.isNotEmpty
                                      ? widget.call.fullName
                                      : 'Contact',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status Pill Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.call.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Company name (only shown if not empty)
                          if (widget.call.companyName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.call.companyName,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 5),
                          // Phone with copy action
                          InkWell(
                            onTap: () => _copyToClipboard(
                                widget.call.phone, 'Phone number'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.phone_fill,
                                  size: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : context.colors.darkGreyColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.call.phone,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  CupertinoIcons.doc_on_doc,
                                  size: 12,
                                  color: context.colors.primaryLightColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top Right Close Button
                    IconButton(
                      tooltip: 'Close details',
                      onPressed: () {
                        widget.onClose?.call();
                        context.read<CallsCubit>().selectCall(null);
                        context.read<SelectedCallCubit>().clearSelection();
                      },
                      icon: Icon(
                        CupertinoIcons.clear,
                        size: 17,
                        color: isDark
                            ? Colors.white60
                            : context.colors.darkGreyColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Action Buttons Row: Call Again & Customer Info
                Row(
                  children: [
                    // Call Again (Primary Solid)
                    Expanded(
                      child: SizedBox(
                        height: 40,
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
                            'Call Again',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primaryLightColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customer Info (Outlined / Tinted)
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: _navigateToCustomerProfile,
                          icon: Icon(
                            CupertinoIcons.person_fill,
                            size: 14,
                            color: context.colors.primaryLightColor,
                          ),
                          label: Text(
                            'Customer Info',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF131D31)
                                : const Color(0xFFF1F5F9),
                            side: BorderSide(
                              color: context.colors.primaryLightColor
                                  .withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                  // 2. Call Metadata Card (Duration, Date & Time, Agent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 1. Duration
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.stopwatch,
                                  size: 16,
                                  color: context.colors.primaryLightColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: context.colors.darkGreyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.call.duration.isNotEmpty
                                          ? widget.call.duration
                                          : '0:00',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                        const SizedBox(width: 10),
                        // 2. Date & Time
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.calendar,
                                  size: 16,
                                  color: context.colors.primaryLightColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date & Time',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: context.colors.darkGreyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppDateTime.displayDateTime(
                                          widget.call.dateTime),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                        const SizedBox(width: 10),
                        // 3. Agent (Smart Robot Icon)
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Icon(
                                Icons.smart_toy_outlined,
                                size: 17,
                                color: context.colors.primaryLightColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Agent',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: context.colors.darkGreyColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.call.assignee
                                              .toLowerCase()
                                              .contains('ai')
                                          ? 'AI'
                                          : widget.call.assignee,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Call Recording Player Card
                  CallAudioPlayerWidget(call: widget.call),
                  const SizedBox(height: 12),

                  // 4. AI Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
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
                                  size: 15,
                                  color: context.colors.primaryLightColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Summary',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.call.lastContactResult != null &&
                                widget.call.lastContactResult!.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryLightColor
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: context.colors.primaryLightColor
                                        .withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.call.lastContactResult!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          summaryText,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Call Transcript Card
                  if (widget.call.transcript.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
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
                                    size: 15,
                                    color: context.colors.primaryLightColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Call Transcript',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: _copyTranscript,
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.doc_on_doc,
                                      size: 12,
                                      color: context.colors.primaryLightColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy All',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.primaryLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Turns List Matching Mockup
                          ...widget.call.transcript.map((turn) {
                            final isAi = turn.speaker == 'ai';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : context.colors.mediumGreyColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isAi
                                                ? context
                                                    .colors.primaryLightColor
                                                    .withValues(alpha: 0.2)
                                                : context.colors.successColor
                                                    .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            isAi
                                                ? CupertinoIcons.sparkles
                                                : CupertinoIcons.person_fill,
                                            size: 13,
                                            color: isAi
                                                ? context
                                                    .colors.primaryLightColor
                                                : context.colors.successColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isAi ? 'AI' : turn.speakerName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isAi
                                                ? context
                                                    .colors.primaryLightColor
                                                : context.colors.successColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      turn.text,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.4,
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.9)
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 6. Next Steps (Follow-Up) Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
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
                                  CupertinoIcons.calendar,
                                  size: 15,
                                  color: context.colors.primaryLightColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Next Steps',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (_followUpDate != null)
                              InkWell(
                                onTap: () => _saveFollowUpDate(null),
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.errorColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Interactive Follow-up Date Box
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF131D31)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : context.colors.mediumGreyColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryLightColor
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.calendar,
                                    size: 18,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Next Follow-up Date',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: context.colors.darkGreyColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _followUpDate != null
                                            ? AppDateTime.displayDateOrDateTime(
                                                _followUpDate)
                                            : 'Click to select follow-up date & time',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: _followUpDate != null
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: _followUpDate != null
                                              ? (isDark
                                                  ? Colors.white
                                                  : Colors.black87)
                                              : context.colors.darkGreyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 15,
                                  color: context.colors.darkGreyColor,
                                ),
                              ],
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
}
