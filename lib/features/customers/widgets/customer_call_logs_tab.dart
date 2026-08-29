import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
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
    if (widget.user.callLogs.isNotEmpty) {
      return widget.user.callLogs;
    }

    // Default 8 clean call logs matching mockup
    return [
      const CustomerCallHistory(
        id: 'call_1',
        status: 'Completed',
        direction: 'Outbound',
        outcome: 'Completed',
        duration: '02:15',
        durationSeconds: 135,
        callDate: '2026/08/29',
        callTime: '19:44',
        scenario: 'Sara (Sales)',
        recordingUrl: 'https://example.com/recording_1.mp3',
        summary:
            'Discussed pricing plans and enterprise package. Customer is interested and requested a demo. Follow-up scheduled for next week.',
        transcript: [
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'AI',
            timestamp: '',
            text: 'Hi XARTA,',
          ),
          TranscriptTurn(
            speaker: 'customer',
            speakerName: 'Customer',
            timestamp: '',
            text: 'can you hear me?',
          ),
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'AI',
            timestamp: '',
            text: 'Yes, I can hear you. How can I help you today?',
          ),
          TranscriptTurn(
            speaker: 'customer',
            speakerName: 'Customer',
            timestamp: '',
            text:
                'I\'m looking for more information about your enterprise plan.',
          ),
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'AI',
            timestamp: '',
            text:
                'Sure! Our enterprise plan includes unlimited seats and priority support.',
          ),
        ],
      ),
      const CustomerCallHistory(
        id: 'call_2',
        status: 'Completed',
        direction: 'Inbound',
        outcome: 'Completed',
        duration: '01:32',
        durationSeconds: 92,
        callDate: '2026/08/26',
        callTime: '14:10',
        scenario: 'Sara (Support)',
        summary:
            'Customer called to inquire about custom CRM integrations and API webhooks. Provided technical documentation.',
        transcript: [
          TranscriptTurn(
            speaker: 'customer',
            speakerName: 'Customer',
            timestamp: '',
            text: 'Hello, do you support custom webhooks for our backend CRM?',
          ),
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'AI',
            timestamp: '',
            text:
                'Yes, we support realtime webhook notifications and REST endpoints for all call events.',
          ),
        ],
      ),
      const CustomerCallHistory(
        id: 'call_3',
        status: 'Completed',
        direction: 'Outbound',
        outcome: 'Completed',
        duration: '03:45',
        durationSeconds: 225,
        callDate: '2026/08/22',
        callTime: '11:03',
        scenario: 'Sara (Sales)',
        summary:
            'Deep dive on onboarding process. Client confirmed team size of 15 members.',
        transcript: [
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'AI',
            timestamp: '',
            text: 'Hi, following up on your team onboarding request.',
          ),
        ],
      ),
      const CustomerCallHistory(
        id: 'call_4',
        status: 'Completed',
        direction: 'Inbound',
        outcome: 'Completed',
        duration: '00:47',
        durationSeconds: 47,
        callDate: '2026/08/20',
        callTime: '16:38',
        scenario: 'Billing Agent',
        summary:
            'Quick check on billing cycles and invoice payment methods. Confirmed ACH and Credit Card.',
      ),
      const CustomerCallHistory(
        id: 'call_5',
        status: 'Completed',
        direction: 'Outbound',
        outcome: 'Completed',
        duration: '02:15',
        durationSeconds: 135,
        callDate: '2026/08/17',
        callTime: '10:22',
        scenario: 'Sara (Sales)',
        summary:
            'Product walkthrough demo completed. Customer expressed high satisfaction with voice response speed.',
      ),
      const CustomerCallHistory(
        id: 'call_6',
        status: 'Interested',
        direction: 'Inbound',
        outcome: 'Interested',
        duration: '01:05',
        durationSeconds: 65,
        callDate: '2026/08/15',
        callTime: '09:15',
        scenario: 'Sara (Sales)',
        summary:
            'Customer called to explore volume discounts for multiple branch locations.',
      ),
      const CustomerCallHistory(
        id: 'call_7',
        status: 'No Answer',
        direction: 'Outbound',
        outcome: 'No Answer',
        duration: '00:58',
        durationSeconds: 58,
        callDate: '2026/08/12',
        callTime: '17:50',
        scenario: 'Outreach Bot',
        summary:
            'Call rang for 50 seconds without answer. System scheduled automatic retry.',
      ),
      const CustomerCallHistory(
        id: 'call_8',
        status: 'Completed',
        direction: 'Inbound',
        outcome: 'Completed',
        duration: '02:40',
        durationSeconds: 160,
        callDate: '2026/08/10',
        callTime: '13:08',
        scenario: 'Sara (Sales)',
        summary:
            'Initial discovery call. Discussed AI voice agent requirements and target KPIs.',
      ),
    ];
  }

  List<CustomerCallHistory> get _filteredCalls {
    final calls = _effectiveCalls;
    if (_searchQuery.trim().isEmpty) return calls;
    final query = _searchQuery.toLowerCase().trim();
    return calls.where((c) {
      final directionMatch = c.direction.toLowerCase().contains(query);
      final statusMatch = c.status.toLowerCase().contains(query);
      final dateMatch =
          '${c.callDate} ${c.callTime}'.toLowerCase().contains(query);
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
    final transcript = call.transcript.isNotEmpty
        ? call.transcript
        : const [
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI',
              timestamp: '',
              text: 'Hi, how can I help you today?',
            ),
          ];

    final buffer = StringBuffer();
    buffer.writeln(
        '=== Call Transcript: ${widget.user.fullName} (${call.callDate} • ${call.callTime}) ===');
    for (final t in transcript) {
      final isAi =
          t.speaker.toLowerCase() == 'ai' || t.speaker.toLowerCase() == 'agent';
      final speakerName = isAi ? 'AI' : (t.speakerName ?? 'Customer');
      buffer.writeln('[$speakerName]: ${t.text}');
    }

    _copyToClipboard(buffer.toString(), 'Call transcript');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calls = _filteredCalls;

    if (calls.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.whiteColor,
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
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
        ),
      );
    }

    CustomerCallHistory? selectedCall;
    if (_selectedCallId != null) {
      selectedCall = calls.firstWhere(
        (c) => c.id == _selectedCallId,
        orElse: () => calls.first,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;

        if (!isWide || selectedCall == null) {
          return _buildCallsList(calls, _selectedCallId ?? '', isDark, false);
        }

        // 2-Column Master-Detail Mode
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Calls List (flex: 4)
            Expanded(
              flex: 4,
              child: _buildCallsList(calls, _selectedCallId!, isDark, true),
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
        SizedBox(
         width: MediaQuery.sizeOf(context).width,
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
                      color: context.colors.darkGreyColor.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      size: 15,
                      color: context.colors.darkGreyColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_thick,
                                size: 14),
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
        const SizedBox(height: 10),

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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
    final subtitle =
        '${call.callDate.isNotEmpty ? call.callDate : '2026/08/29'} • ${call.callTime.isNotEmpty ? call.callTime : '19:44'}';

    return InkWell(
      onTap: () => _onCallSelected(call),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
              : context.colors.whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildCallIconBox(call),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
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
      recordingUrl: call.recordingUrl,
      notes: call.summary,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Spacer(),
              IconButton(
                tooltip: 'Close details',
                onPressed: () {
                  setState(() => _selectedCallId = null);
                },
                icon: Icon(
                  CupertinoIcons.clear,
                  size: 20,
                  color: isDark ? Colors.white60 : context.colors.darkGreyColor,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                splashRadius: 14,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                                fontSize: 12.5,
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
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
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
                              '${call.callDate} • ${call.callTime}',
                              style: TextStyle(
                                fontSize: 12,
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
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
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
                                  : 'Sara (Sales)',
                              style: TextStyle(
                                fontSize: 12,
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
                            if (call.outcome.isNotEmpty) ...[
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
                                  call.outcome,
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
                          call.summary != null && call.summary!.isNotEmpty
                              ? call.summary!
                              : 'Customer (${widget.user.fullName}) was contacted by AI (B2B Sales). Key project scope, budget estimation, and delivery terms were discussed. Customer expressed strong interest in proceeding.',
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
      ),
    );
  }

  Widget _buildTranscriptList(CustomerCallHistory call, bool isDark) {
    final transcript = call.transcript.isNotEmpty
        ? call.transcript
        : const [
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI',
              timestamp: '',
              text: 'Hi XARTA,',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'AI Assistant',
              timestamp: '',
              text: 'can you hear me?',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI',
              timestamp: '',
              text: 'Yes, I can hear you. How can I help you today?',
            ),
          ];

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
            color: isDark ? context.colors.whiteColor : const Color(0xFFF8FAFC),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
      case 'won':
        color = const Color(0xFF10B981);
        break;
      case 'interested':
      case 'qualified':
        color = const Color(0xFF8B5CF6);
        break;
      case 'no answer':
      case 'failed':
      case 'missed':
        color = const Color(0xFF64748B);
        break;
      default:
        color = const Color(0xFF10B981);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
