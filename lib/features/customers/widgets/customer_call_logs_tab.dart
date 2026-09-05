import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/widgets/app_status_badge.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CustomerCallLogsTab extends StatefulWidget {
  final User user;

  const CustomerCallLogsTab({
    super.key,
    required this.user,
  });

  @override
  State<CustomerCallLogsTab> createState() => _CustomerCallLogsTabState();
}

class _CustomerCallLogsTabState extends State<CustomerCallLogsTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCallId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerCallHistory> get _effectiveCalls {
    return widget.user.callLogs;
  }

  List<CustomerCallHistory> get _filteredCalls {
    final calls = _effectiveCalls;
    if (_searchQuery.trim().isEmpty) return calls;
    final query = _searchQuery.toLowerCase().trim();
    return calls.where((c) {
      final directionMatch = c.direction.toLowerCase().contains(query);
      final statusMatch = c.status.toLowerCase().contains(query);
      final dateMatch =
          '${c.callDate} ${c.callTime} ${AppDateTime.displayDateTime(c.dateTime)}'
              .toLowerCase()
              .contains(query);
      final summaryMatch = (c.summary ?? '').toLowerCase().contains(query);
      return directionMatch || statusMatch || dateMatch || summaryMatch;
    }).toList();
  }

  bool _isUnanswered(CustomerCallHistory call) {
    final status = call.status.toLowerCase();
    return status == 'no answer' ||
        status == 'failed' ||
        status == 'missed' ||
        status == 'unanswered';
  }

  void _onCallSelected(CustomerCallHistory call) {
    if (_isUnanswered(call)) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage:
            'This call was unanswered and has no recording or transcript details.',
        toastificationType: ToastificationType.info,
      );
      return;
    }
    setState(() => _selectedCallId = call.id);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: '$label copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  void _copyTranscript(CustomerCallHistory call) {
    if (call.transcript.isEmpty) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'No transcript recorded for this call.',
        toastificationType: ToastificationType.info,
      );
      return;
    }

    final transcript = call.transcript;
    final buffer = StringBuffer();
    buffer.writeln(
        '=== Call Transcript: ${widget.user.fullName} (${AppDateTime.displayDateTime(call.dateTime)}) ===');
    for (final t in transcript) {
      final isAi =
          t.speaker.toLowerCase() == 'ai' || t.speaker.toLowerCase() == 'agent';
      final speakerName = isAi ? 'AI' : (t.speakerName ?? 'Customer');
      buffer.writeln('[${t.timestamp}] $speakerName: ${t.text}');
    }

    _copyToClipboard(buffer.toString(), 'Call transcript');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calls = _filteredCalls;

    CustomerCallHistory? selectedCall;
    if (_selectedCallId != null) {
      selectedCall = calls.firstWhere(
        (c) => c.id == _selectedCallId,
        orElse: () => calls.first,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Row Matching Notes Tab (media_1788026914269.png)
          _buildHeader(calls, selectedCall, isDark),
          const SizedBox(height: 16),

          // 2. Main Content (List or 2-Column Master-Detail)
          Expanded(
            child: calls.isEmpty
                ? _buildEmptyState(isDark)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 650;

                      if (!isWide || selectedCall == null) {
                        return _buildCallsList(
                            calls, _selectedCallId ?? '', isDark, false);
                      }

                      // 2-Column Master-Detail Mode
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Calls List (flex: 4)
                          Expanded(
                            flex: 4,
                            child: _buildCallsList(
                                calls, _selectedCallId!, isDark, true),
                          ),
                          const SizedBox(width: 14),

                          // Right Column: Call Detail Card (flex: 5)
                          Expanded(
                            flex: 5,
                            child: _buildCallDetailCard(selectedCall, isDark),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    List<CustomerCallHistory> calls,
    CustomerCallHistory? selectedCall,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Icon + CALL LOGS + Count Badge
        Row(
          children: [
            Icon(
              CupertinoIcons.phone,
              size: 19,
              color: context.colors.primaryLightColor,
            ),
            const SizedBox(width: 8),
            Text(
              'CALL LOGS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.colors.primaryLightColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${calls.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryLightColor,
                ),
              ),
            ),
          ],
        ),

        // Right: Search Box + Close Button if call selected
        Row(
          children: [
            SizedBox(
              width: 220,
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Search calls...',
                  hintStyle: TextStyle(
                    fontSize: 11,
                    color: context.colors.darkGreyColor.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 15,
                    color: context.colors.darkGreyColor,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(CupertinoIcons.clear_thick, size: 14),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (selectedCall != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Close details',
                onPressed: () => setState(() => _selectedCallId = null),
                icon: Icon(
                  CupertinoIcons.clear,
                  size: 16,
                  color: isDark ? Colors.white60 : context.colors.darkGreyColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 16,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.phone_badge_plus,
            size: 44,
            color: context.colors.darkGreyColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No call logs found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.darkGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsList(
    List<CustomerCallHistory> calls,
    String activeCallId,
    bool isDark,
    bool isMasterDetail,
  ) {
    return Column(
      children: [
        // List of Call Cards
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: calls.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final call = calls[index];
              final isSelected = isMasterDetail && call.id == activeCallId;
              return _buildCallCard(call, isSelected, isDark);
            },
          ),
        ),

        // Footer: "X of X calls" with horizontal lines
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${calls.length} of ${_effectiveCalls.length} calls',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallCard(
    CustomerCallHistory call,
    bool isSelected,
    bool isDark,
  ) {
    final isOutbound = call.direction.toLowerCase().contains('out');
    final title = isOutbound ? 'Outgoing Call' : 'Incoming Call';
    final subtitle = AppDateTime.displayDateTime(
      call.dateTime,
      fallback: 'Date unavailable',
    );

    return InkWell(
      onTap: () => _onCallSelected(call),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? context.colors.primaryLightColor.withValues(alpha: 0.16)
                  : const Color(0xFFEEF2FF))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildCallIconBox(call),
            const SizedBox(width: 10),

            // Title & Date/Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected
                          ? context.colors.primaryLightColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Duration (⏱ 02:15)
            Row(
              children: [
                Icon(
                  CupertinoIcons.time,
                  size: 13,
                  color: context.colors.darkGreyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  call.duration,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // Status Badge
            _buildStatusBadge(call.status),
            const SizedBox(width: 8),

            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              size: 13,
              color: isSelected
                  ? context.colors.primaryLightColor
                  : context.colors.darkGreyColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallDetailCard(CustomerCallHistory call, bool isDark) {
    final callHistoryModel = CallHistoryModel(
      id: call.id,
      fullName: widget.user.fullName,
      phone: widget.user.phone,
      assignee: call.scenario ?? 'Sara (Sales)',
      direction: call.direction,
      status: call.status,
      duration: call.duration,
      callDate: call.callDate,
      callTime: call.callTime,
      scheduledFor: call.scheduledFor,
      createdAt: call.createdAt,
      recordingUrl: call.recordingUrl,
      notes: call.summary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Metadata 3-Column Card in App Theme Colors
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              // 1. Duration (Clock/Stopwatch Icon + Column)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.stopwatch,
                      size: 16,
                      color: context.colors.primaryLightColor,
                    ),
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
                            call.duration.isNotEmpty ? call.duration : '0:00',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
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
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 10),

              // 2. Date & Time (Calendar Icon + Column)
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 16,
                      color: context.colors.primaryLightColor,
                    ),
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
                            AppDateTime.displayDateTime(call.dateTime),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
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
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 10),

              // 3. Agent (Smart Robot Icon + Column)
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
                            call.scenario != null && call.scenario!.isNotEmpty
                                ? call.scenario!
                                : 'AI',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
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

        // 2. Audio Player (Right below metadata card)
        CallAudioPlayerWidget(
          call: callHistoryModel,
          compact: true,
        ),
        const SizedBox(height: 12),

        // Scrollable Sections: AI Summary & Call Transcript
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. AI Summary Card in App Theme Colors
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
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusBadge(call.status),
                              if (call.outcome.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                AppStatusBadge(status: call.outcome),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getDynamicSummary(call),
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Call Transcript Card in App Theme Colors
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => _copyTranscript(call),
                            borderRadius: BorderRadius.circular(4),
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
                      _buildTranscriptList(call, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptList(CustomerCallHistory call, bool isDark) {
    if (call.transcript.isEmpty) {
      final message = call.status.toLowerCase().trim() == 'queued'
          ? 'Call is queued. Transcript will appear once the call starts.'
          : (call.status.toLowerCase().trim() == 'in progress' ||
                  call.status.toLowerCase().trim() == 'ringing')
              ? 'Call in progress. Transcript is being recorded...'
              : 'No transcript recorded for this call.';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chat_bubble_text,
                size: 32,
                color: context.colors.darkGreyColor.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.darkGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final transcript = call.transcript;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transcript.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = transcript[index];
        final isAi = item.speaker.toLowerCase() == 'ai' ||
            item.speaker.toLowerCase() == 'agent';
        final speakerName = isAi ? 'AI' : (item.speakerName ?? 'Customer');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar Box + Speaker Name (NO TIMESTAMPS)
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isAi
                          ? context.colors.primaryLightColor
                              .withValues(alpha: 0.2)
                          : context.colors.successColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isAi
                          ? CupertinoIcons.sparkles
                          : CupertinoIcons.person_fill,
                      size: 13,
                      color: isAi
                          ? context.colors.primaryLightColor
                          : context.colors.successColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    speakerName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isAi
                          ? context.colors.primaryLightColor
                          : context.colors.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message Content Text
              Text(
                item.text,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallIconBox(CustomerCallHistory call) {
    final isOutbound = call.direction.toLowerCase().contains('out');
    final isFailed = call.status == 'Failed' || call.status == 'No Answer';

    Color color;
    IconData icon;

    if (isFailed) {
      color = const Color(0xFF64748B);
      icon = CupertinoIcons.phone_fill;
    } else if (isOutbound) {
      color = const Color(0xFF6366F1);
      icon = CupertinoIcons.phone_arrow_up_right;
    } else {
      color = const Color(0xFF10B981);
      icon = CupertinoIcons.phone_arrow_down_left;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 15,
          color: color,
        ),
      ),
    );
  }

  String _getDynamicSummary(CustomerCallHistory call) {
    if (call.summary != null && call.summary!.trim().isNotEmpty) {
      return call.summary!;
    }
    switch (call.status.toLowerCase().trim()) {
      case 'completed':
        return 'Call completed. No summary recorded.';
      case 'in progress':
      case 'in-progress':
      case 'ongoing':
        return 'Call is currently in progress.';
      case 'ringing':
      case 'initiated':
        return 'Call is ringing / initiating.';
      case 'queued':
      case 'pending':
        return 'Call is queued and pending outbound dispatch.';
      case 'failed':
        return 'Call was not connected or was unanswered. No audio recording or transcript is available.';
      case 'busy':
        return 'The customer line was busy. Call could not be connected.';
      case 'no answer':
      case 'missed':
      case 'unanswered':
        return 'Call was not answered by recipient.';
      case 'canceled':
      case 'cancelled':
        return 'Call was canceled.';
      default:
        return 'No AI summary available for this call.';
    }
  }

  Widget _buildStatusBadge(String status) {
    return AppStatusBadge(status: status);
  }
}
