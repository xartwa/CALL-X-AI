import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallAiInsightsTab extends StatefulWidget {
  final CallHistoryModel call;

  const CallAiInsightsTab({
    super.key,
    required this.call,
  });

  @override
  State<CallAiInsightsTab> createState() => _CallAiInsightsTabState();
}

class _CallAiInsightsTabState extends State<CallAiInsightsTab> {
  late Set<int> _checkedActionItems;

  @override
  void initState() {
    super.initState();
    _checkedActionItems = {};
  }

  @override
  void didUpdateWidget(CallAiInsightsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.id != widget.call.id) {
      _checkedActionItems.clear();
    }
  }

  String _getDynamicSummary() {
    if (widget.call.notes != null && widget.call.notes!.isNotEmpty) {
      return widget.call.notes!;
    }

    switch (widget.call.status) {
      case 'Completed':
        return 'Customer (${widget.call.fullName}) engaged positively with ${widget.call.assignee}. Key project scope, budget feasibility, and delivery timeline were addressed. The lead showed high purchase intent and requested a formal quote proposal.';
      case 'Failed':
        return 'Call attempt was unanswered or dropped due to network timeout. System logged automated retry recommendation for the next available slot.';
      case 'Queued':
        return 'Call record is placed in the outbound campaign dispatcher. AI calling line will initiate as soon as telephony channels become available.';
      case 'Upcoming':
        return 'Scheduled automated outreach. AI assistant will contact ${widget.call.fullName} at the targeted schedule with custom sales scenario.';
      default:
        return 'Session log initialized. Waiting for post-call analysis processing.';
    }
  }

  void _copySummary(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    AppUtils.showSnackBar(
      context: context,
      extraMessage: 'AI summary copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryText = _getDynamicSummary();
    final sentimentScore = widget.call.sentimentScore;
    final isPositive = sentimentScore >= 70;
    final isNegative = sentimentScore < 45;

    final sentimentColor = isPositive
        ? context.colors.successColor
        : (isNegative ? context.colors.errorColor : context.colors.warningColor);

    final actionItems = widget.call.actionItems.isNotEmpty
        ? widget.call.actionItems
        : [
            'Send custom PDF quotation to ${widget.call.email ?? widget.call.fullName}',
            'Confirm scope estimation for ${widget.call.companyName.isNotEmpty ? widget.call.companyName : "project requirements"}',
            'Schedule follow-up callback for final approval',
          ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Executive AI Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF0F7FF), const Color(0xFFE0E7FF)],
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark
                    ? context.colors.primaryLightColor.withValues(alpha: 0.3)
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
                          size: 16,
                          color: context.colors.primaryLightColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EXECUTIVE AI SUMMARY',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _copySummary(context, summaryText),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          CupertinoIcons.doc_on_doc,
                          size: 14,
                          color: context.colors.primaryLightColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  summaryText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Sentiment & Intent Analysis
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.chart_pie_fill,
                      size: 15,
                      color: context.colors.primaryLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SENTIMENT & CALL INTENT',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Sentiment Score Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Overall Sentiment',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                              Text(
                                '$sentimentScore% ${widget.call.sentiment}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: sentimentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: sentimentScore / 100.0,
                              minHeight: 7,
                              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(sentimentColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Detected Call Intent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb_fill,
                        size: 14,
                        color: context.colors.warningColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Intent:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.call.callIntent,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Action Items & Next Steps Checklist
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
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
                          CupertinoIcons.check_mark_circled_solid,
                          size: 15,
                          color: context.colors.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI ACTION ITEMS & NEXT STEPS',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_checkedActionItems.length}/${actionItems.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...actionItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isChecked = _checkedActionItems.contains(index);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          _checkedActionItems.remove(index);
                        } else {
                          _checkedActionItems.add(index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isChecked
                                ? CupertinoIcons.checkmark_square_fill
                                : CupertinoIcons.square,
                            size: 16,
                            color: isChecked
                                ? context.colors.successColor
                                : context.colors.darkGreyColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.35,
                                color: isChecked
                                    ? context.colors.darkGreyColor
                                    : (isDark ? Colors.white70 : Colors.black87),
                                decoration:
                                    isChecked ? TextDecoration.lineThrough : null,
                              ),
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
          const SizedBox(height: 16),

          // 4. Call Performance & Talk Ratio Metrics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.mediumGreyColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.gauge,
                      size: 15,
                      color: context.colors.primaryLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CONVERSATION METRICS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Talk to Listen Ratio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Talk-to-Listen Ratio',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: context.colors.darkGreyColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI: ${widget.call.talkRatioAi}% • Customer: ${widget.call.talkRatioCustomer}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: widget.call.talkRatioAi,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.colors.primaryLightColor,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: widget.call.talkRatioCustomer,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.colors.successColor,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sub-metrics Grid (Latency, Questions, Interruptions)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: 'Latency',
                        value: '420 ms',
                        icon: CupertinoIcons.bolt_fill,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: 'Questions',
                        value: '4 Asked',
                        icon: CupertinoIcons.question_circle_fill,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: 'Interruptions',
                        value: '0 Detected',
                        icon: CupertinoIcons.mic_fill,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: context.colors.primaryLightColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.colors.darkGreyColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
