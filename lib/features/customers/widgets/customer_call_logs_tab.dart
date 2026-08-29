import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_text_field_widget.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
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
  String _selectedFilter = 'All'; // 'All', 'Completed', 'Failed', 'Inbound', 'Outbound'
  final Set<String> _expandedTranscripts = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CustomerCallHistory> get _effectiveCalls {
    // If user.callLogs is populated, use it. Otherwise generate fallback call logs for rich preview
    if (widget.user.callLogs.isNotEmpty) {
      return widget.user.callLogs;
    }

    // Default rich sample logs for demonstration if customer has contact history
    final lastContact = widget.user.lastContact;
    if (lastContact != null) {
      final dateStr =
          '${lastContact.year}/${lastContact.month.toString().padLeft(2, '0')}/${lastContact.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${lastContact.hour.toString().padLeft(2, '0')}:${lastContact.minute.toString().padLeft(2, '0')}';

      return [
        CustomerCallHistory(
          id: 'cl_1',
          status: 'Completed',
          direction: 'Outbound',
          outcome: widget.user.lastContactResult.isNotEmpty
              ? widget.user.lastContactResult
              : 'Interested',
          duration: '02:45',
          durationSeconds: 165,
          scheduledFor: widget.user.nextFollowUpDate,
          callDate: dateStr,
          callTime: timeStr,
          scenario: 'Construction Lead Outreach',
          recordingUrl: 'https://example.com/recording_1.mp3',
          summary:
              'Customer showed high interest in the commercial drywall estimate. Discussed project timelines for Vancouver site and agreed on a follow-up proposal.',
          leadPriority: widget.user.leadPriority,
          transcript: const [
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI Voice Assistant',
              timestamp: '00:05',
              text:
                  'Hello! This is Sarah from CallX AI reaching out regarding your project inquiry.',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              timestamp: '00:15',
              text:
                  'Hi Sarah, yes! We are currently looking for subcontractors on our new commercial building in Vancouver.',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI Voice Assistant',
              timestamp: '00:32',
              text:
                  'Excellent. Could you confirm the expected start date and the square footage for the drywall scope?',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              timestamp: '00:50',
              text:
                  'Start date is mid-next month, roughly 45,000 sq ft. Send over your preliminary pricing proposal.',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI Voice Assistant',
              timestamp: '01:10',
              text:
                  'Understood! I will schedule our estimator to prepare the package and follow up with you on Thursday.',
            ),
          ],
          notes: 'High priority lead for Vancouver project.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        CustomerCallHistory(
          id: 'cl_2',
          status: 'Completed',
          direction: 'Inbound',
          outcome: 'Follow-Up Needed',
          duration: '01:20',
          durationSeconds: 80,
          scheduledFor: null,
          callDate: '2026/08/25',
          callTime: '11:15',
          scenario: 'Inbound Customer Service',
          recordingUrl: 'https://example.com/recording_2.mp3',
          summary:
              'Client called to check on insurance certificate compliance before awarding contract.',
          leadPriority: 'Warm',
          transcript: const [
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              timestamp: '00:02',
              text: 'Hi, I need to verify your WCB and safety compliance status.',
            ),
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'AI Voice Assistant',
              timestamp: '00:15',
              text:
                  'Certainly! All our compliance certifications are up to date and can be emailed directly to your desk.',
            ),
          ],
          notes: 'Emailed WCB clearance letter.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];
    }

    return const [];
  }

  List<CustomerCallHistory> get _filteredCalls {
    return _effectiveCalls.where((call) {
      // 1. Filter by Status / Direction
      if (_selectedFilter == 'Completed' && call.status != 'Completed') {
        return false;
      }
      if (_selectedFilter == 'Failed' &&
          call.status != 'Failed' &&
          call.status != 'Queued') {
        return false;
      }
      if (_selectedFilter == 'Inbound' && call.direction != 'Inbound') {
        return false;
      }
      if (_selectedFilter == 'Outbound' && call.direction != 'Outbound') {
        return false;
      }

      // 2. Filter by Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesOutcome = call.outcome.toLowerCase().contains(q);
        final matchesStatus = call.status.toLowerCase().contains(q);
        final matchesSummary = (call.summary ?? '').toLowerCase().contains(q);
        final matchesNotes = (call.notes ?? '').toLowerCase().contains(q);
        final matchesScenario = (call.scenario ?? '').toLowerCase().contains(q);
        final matchesTranscript = call.transcript
            .any((t) => t.text.toLowerCase().contains(q));

        if (!matchesOutcome &&
            !matchesStatus &&
            !matchesSummary &&
            !matchesNotes &&
            !matchesScenario &&
            !matchesTranscript) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981); // Emerald
      case 'failed':
      case 'unanswered':
        return const Color(0xFFEF4444); // Red
      case 'queued':
      case 'upcoming':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  CallHistoryModel _toCallModel(CustomerCallHistory call) {
    return CallHistoryModel(
      id: call.id,
      fullName: widget.user.fullName.isNotEmpty
          ? widget.user.fullName
          : 'Customer Lead',
      companyName: widget.user.companyName,
      phone: widget.user.phone,
      status: call.status,
      assignee: call.scenario ?? 'AI Assistant',
      duration: call.duration,
      callTime: call.callTime,
      callDate: call.callDate,
      direction: call.direction,
      notes: call.notes ?? call.summary,
      recordingUrl: call.recordingUrl,
      leadPriority: call.leadPriority,
      transcript: call.transcript
          .map((t) => CallTranscriptMessage(
                speaker: t.speaker,
                speakerName: t.speakerName ??
                    (t.speaker == 'ai' ? 'AI Assistant' : 'Customer'),
                text: t.text,
                timestamp: t.timestamp,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allCalls = _effectiveCalls;
    final filtered = _filteredCalls;

    final completedCount =
        allCalls.where((c) => c.status == 'Completed').length;
    final inboundCount =
        allCalls.where((c) => c.direction == 'Inbound').length;
    final outboundCount =
        allCalls.where((c) => c.direction == 'Outbound').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary Header & Search
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.phone_fill_arrow_down_left,
                size: 18,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      context.colors.primaryLightColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${allCalls.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primaryLightColor,
                  ),
                ),
              ),
              const Spacer(),

              // Search Box
              SizedBox(
                width: 220,
                height: 36,
                child: AppTextFieldWidget(
                  controller: _searchCtrl,
                  hintText: 'Search call logs...',
                  prefixIcon: Icon(CupertinoIcons.search,
                      size: 15, color: context.colors.darkGreyColor),
                  showBorder: true,
                  borderColor: isDark ? Colors.white12 : Colors.grey[300],
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'All (${allCalls.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', 'Completed ($completedCount)'),
                const SizedBox(width: 8),
                _buildFilterChip('Inbound', 'Incoming ↙ ($inboundCount)'),
                const SizedBox(width: 8),
                _buildFilterChip('Outbound', 'Outgoing ↗ ($outboundCount)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calls List / Empty View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.phone_down_circle,
                          size: 40,
                          color: context.colors.darkGreyColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No call logs match "$_searchQuery"'
                              : 'No call records found for this customer.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final call = filtered[index];
                      final isExpanded =
                          _expandedTranscripts.contains(call.id);
                      final callModel = _toCallModel(call);
                      final statusColor = _getStatusColor(call.status);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.boxRadius),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Direction + Status + Date/Time + Duration + Outcome
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Direction Icon Badge
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: (call.direction == 'Inbound'
                                                ? const Color(0xFF06B6D4)
                                                : context
                                                    .colors.primaryLightColor)
                                            .withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        call.direction == 'Inbound'
                                            ? CupertinoIcons.phone_arrow_down_left
                                            : CupertinoIcons.phone_arrow_up_right,
                                        size: 14,
                                        color: call.direction == 'Inbound'
                                            ? const Color(0xFF06B6D4)
                                            : context
                                                .colors.primaryLightColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                            alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                            color: statusColor
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            call.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: statusColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Outcome Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Text(
                                        call.outcome,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Date, Time and Duration
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.clock,
                                      size: 13,
                                      color: context.colors.darkGreyColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${call.callDate}  ${call.callTime}  •  ${call.duration}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.darkGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // AI Summary Box (if available)
                            if (call.summary != null &&
                                call.summary!.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryLightColor
                                      .withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.colors.primaryLightColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      CupertinoIcons.sparkles,
                                      size: 15,
                                      color: context.colors.primaryLightColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'AI Key Takeaways & Summary',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: context
                                                  .colors.primaryLightColor,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            call.summary!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              height: 1.4,
                                              color: isDark
                                                  ? Colors.white.withOpacity(0.85)
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Interactive Audio Player (with Web & Download support)
                            CallAudioPlayerWidget(
                              call: callModel,
                              compact: true,
                            ),

                            // Transcript Toggle Button
                            if (call.transcript.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedTranscripts.remove(call.id);
                                    } else {
                                      _expandedTranscripts.add(call.id);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExpanded
                                            ? CupertinoIcons.chevron_up
                                            : CupertinoIcons.chevron_down,
                                        size: 13,
                                        color: context
                                            .colors.primaryLightColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isExpanded
                                            ? 'Hide Transcript'
                                            : 'View Transcript (${call.transcript.length} turns)',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: context
                                              .colors.primaryLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded Transcript View
                              if (isExpanded) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                    children: call.transcript.map((t) {
                                      final isAi =
                                          t.speaker.toLowerCase() == 'ai';
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isAi
                                                    ? context.colors
                                                        .primaryLightColor
                                                        .withValues(
                                                            alpha: 0.15)
                                                    : context.colors
                                                        .skyBlueColor,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isAi ? 'AI' : 'Client',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: isAi
                                                      ? context.colors
                                                          .primaryLightColor
                                                      : context.colors
                                                          .darkGreyColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                t.text,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  height: 1.35,
                                                  color: isDark
                                                      ? Colors.white.withOpacity(0.85)
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryLightColor
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
