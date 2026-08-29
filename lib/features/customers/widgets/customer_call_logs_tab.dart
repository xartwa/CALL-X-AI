import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
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
        callDate: 'Aug 29, 2026',
        callTime: '19:44',
        scenario: 'Sara',
        recordingUrl: 'https://example.com/recording_1.mp3',
        summary:
            'Discussed pricing plans and enterprise package. Customer is interested and requested a demo. Follow-up scheduled for next week.',
        transcript: [
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'Agent',
            timestamp: '',
            text: 'Hi, this is Arta from CallX. How can I help you today?',
          ),
          TranscriptTurn(
            speaker: 'customer',
            speakerName: 'Customer',
            timestamp: '',
            text:
                'Hi, I\'m looking for more information about your enterprise plan.',
          ),
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'Agent',
            timestamp: '',
            text:
                'Sure! Our enterprise plan includes more seats, priority support, and advanced analytics.',
          ),
          TranscriptTurn(
            speaker: 'customer',
            speakerName: 'Customer',
            timestamp: '',
            text: 'Sounds good. Can we schedule a demo for next week?',
          ),
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'Agent',
            timestamp: '',
            text: 'Absolutely! I\'ll send you some available slots.',
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
        callDate: 'Aug 26, 2026',
        callTime: '14:10',
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
            speakerName: 'Agent',
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
        callDate: 'Aug 22, 2026',
        callTime: '11:03',
        summary:
            'Deep dive on onboarding process. Client confirmed team size of 15 members.',
        transcript: [
          TranscriptTurn(
            speaker: 'ai',
            speakerName: 'Agent',
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
        callDate: 'Aug 20, 2026',
        callTime: '16:38',
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
        callDate: 'Aug 17, 2026',
        callTime: '10:22',
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
        callDate: 'Aug 15, 2026',
        callTime: '09:15',
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
        callDate: 'Aug 12, 2026',
        callTime: '17:50',
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
        callDate: 'Aug 10, 2026',
        callTime: '13:08',
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
      final dateMatch = '${c.callDate} ${c.callTime}'.toLowerCase().contains(query);
      final summaryMatch = (c.summary ?? '').toLowerCase().contains(query);
      return directionMatch || statusMatch || dateMatch || summaryMatch;
    }).toList();
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

    final activeCallId = _selectedCallId ?? calls.first.id;
    final selectedCall = calls.firstWhere(
      (c) => c.id == activeCallId,
      orElse: () => calls.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;

        if (!isWide) {
          return _buildCallsList(calls, activeCallId, isDark, false);
        }

        // 2-Column Master-Detail Mode (Clean & Minimal)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Calls List
            Expanded(
              flex: 4,
              child: _buildCallsList(calls, activeCallId, isDark, true),
            ),
            const SizedBox(width: 14),

            // Right Column: Call Detail Card
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
        // Search Input
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                CupertinoIcons.search,
                size: 15,
                color: context.colors.darkGreyColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search call logs...',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: context.colors.darkGreyColor,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(CupertinoIcons.clear_circled_solid, size: 14),
                  color: context.colors.darkGreyColor,
                ),
              ],
            ],
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
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
        '${call.callDate.isNotEmpty ? call.callDate : 'Aug 29, 2026'} • ${call.callTime.isNotEmpty ? call.callTime : '19:44'}';

    return InkWell(
      onTap: () {
        setState(() => _selectedCallId = call.id);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF131C2E) : const Color(0xFFEFF6FF))
              : (isDark ? const Color(0xFF0F172A) : context.colors.whiteColor),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? context.colors.primaryLightColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _buildDirectionIcon(call),
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
    final isOutbound = call.direction.toLowerCase().contains('out');
    final title = isOutbound ? 'Outgoing Call' : 'Incoming Call';
    final subtitle =
        '${call.callDate.isNotEmpty ? call.callDate : 'Aug 29, 2026'} • ${call.callTime.isNotEmpty ? call.callTime : '19:44'}';

    final callHistoryModel = CallHistoryModel(
      id: call.id,
      fullName: widget.user.fullName,
      phone: widget.user.phone,
      assignee: call.scenario ?? 'Sara',
      direction: call.direction,
      status: call.status,
      duration: call.duration,
      callDate: call.callDate,
      callTime: call.callTime,
      recordingUrl: call.recordingUrl,
      notes: call.summary,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Direction Icon + Title + Subtitle + Status + Duration
          Row(
            children: [
              _buildDirectionIcon(call, size: 36, iconSize: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(call.status),
              const SizedBox(width: 8),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Scrollable Sections: Call Summary & Call Transcript
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Call Summary
                  Text(
                    'Call Summary',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      call.summary != null && call.summary!.isNotEmpty
                          ? call.summary!
                          : 'Discussed pricing plans and enterprise package. Customer is interested and requested a demo. Follow-up scheduled for next week.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Call Transcript
                  Text(
                    'Call Transcript',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTranscriptList(call, isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Bottom Unified Audio Player
          CallAudioPlayerWidget(
            call: callHistoryModel,
            compact: true,
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
              speakerName: 'Agent',
              timestamp: '',
              text: 'Hi, this is Arta from CallX. How can I help you today?',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              timestamp: '',
              text:
                  'Hi, I\'m looking for more information about your enterprise plan.',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'Agent',
              timestamp: '',
              text:
                  'Sure! Our enterprise plan includes more seats, priority support, and advanced analytics.',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              timestamp: '',
              text: 'Sounds good. Can we schedule a demo for next week?',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'Agent',
              timestamp: '',
              text: 'Absolutely! I\'ll send you some available slots.',
            ),
          ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transcript.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = transcript[index];
        final isAgent = item.speaker.toLowerCase() == 'ai' ||
            item.speaker.toLowerCase() == 'agent';
        final initial = isAgent ? 'A' : 'C';
        final speakerName = isAgent ? 'Agent' : 'Customer';
        final avatarColor =
            isAgent ? context.colors.primaryLightColor : const Color(0xFF0284C7);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: avatarColor,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speakerName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectionIcon(
    CustomerCallHistory call, {
    double size = 30,
    double iconSize = 14,
  }) {
    final isOutbound = call.direction.toLowerCase().contains('out');
    final isFailed = call.status == 'Failed' || call.status == 'No Answer';

    Color bgColor;
    IconData icon;

    if (isFailed) {
      bgColor = const Color(0xFF64748B);
      icon = CupertinoIcons.phone_fill;
    } else if (isOutbound) {
      bgColor = const Color(0xFF10B981);
      icon = CupertinoIcons.arrow_up_right;
    } else {
      bgColor = const Color(0xFF3B82F6);
      icon = CupertinoIcons.arrow_down_left;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: bgColor,
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
