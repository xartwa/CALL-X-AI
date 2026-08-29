import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CallTranscriptTab extends StatefulWidget {
  final CallHistoryModel call;

  const CallTranscriptTab({
    super.key,
    required this.call,
  });

  @override
  State<CallTranscriptTab> createState() => _CallTranscriptTabState();
}

class _CallTranscriptTabState extends State<CallTranscriptTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _copyTranscript(BuildContext context) {
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
      extraMessage: 'Full call transcript copied to clipboard',
      toastificationType: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transcript = widget.call.transcript;

    if (transcript.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.chat_bubble_2,
                  size: 32,
                  color: context.colors.darkGreyColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Transcript Available',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.call.status == 'Failed'
                    ? 'This call was disconnected before a conversation could be established.'
                    : 'Transcripts are automatically recorded and generated for active and completed voice sessions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.darkGreyColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredMessages = _searchQuery.isEmpty
        ? transcript
        : transcript
            .where((m) =>
                m.text.toLowerCase().contains(_searchQuery) ||
                m.speakerName.toLowerCase().contains(_searchQuery))
            .toList();

    return Column(
      children: [
        // Search bar & Copy All row
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Row(
            children: [
              // Search Input
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : context.colors.mediumGreyColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.search,
                        size: 14,
                        color: context.colors.darkGreyColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transcript dialogue...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: context.colors.darkGreyColor,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _searchCtrl.clear(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              CupertinoIcons.clear_thick,
                              size: 12,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Copy All Button
              InkWell(
                onTap: () => _copyTranscript(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.colors.primaryLightColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.primaryLightColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.doc_on_doc,
                        size: 13,
                        color: context.colors.primaryLightColor,
                      ),
                      const SizedBox(width: 6),
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
              ),
            ],
          ),
        ),

        // Turn-by-turn dialogue stream
        Expanded(
          child: filteredMessages.isEmpty
              ? Center(
                  child: Text(
                    'No messages matching "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  itemCount: filteredMessages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final msg = filteredMessages[index];
                    final isAi = msg.speaker == 'ai';

                    return _buildMessageTurn(
                      context,
                      msg: msg,
                      isAi: isAi,
                      isDark: isDark,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMessageTurn(
    BuildContext context, {
    required CallTranscriptMessage msg,
    required bool isAi,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Speaker Avatar / Badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isAi
                ? context.colors.primaryLightColor.withValues(alpha: 0.15)
                : context.colors.successColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAi ? CupertinoIcons.bolt_badge_a : CupertinoIcons.person_fill,
            size: 14,
            color: isAi ? context.colors.primaryLightColor : context.colors.successColor,
          ),
        ),
        const SizedBox(width: 10),

        // Message Content & Header
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speaker Name & Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        msg.speakerName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isAi
                              ? context.colors.primaryLightColor
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isAi) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: context.colors.primaryLightColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AI AGENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: context.colors.primaryLightColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    msg.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Speech Bubble
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isAi
                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF))
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                  border: Border.all(
                    color: isAi
                        ? (isDark ? Colors.white10 : const Color(0xFFDBEAFE))
                        : (isDark ? Colors.white12 : context.colors.mediumGreyColor),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
