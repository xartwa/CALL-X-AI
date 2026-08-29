import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/details/call_details_header.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/calls/widgets/details/call_ai_insights_tab.dart';
import 'package:callx_ai/features/calls/widgets/details/call_transcript_tab.dart';
import 'package:callx_ai/features/calls/widgets/details/call_crm_tab.dart';
import 'package:callx_ai/features/calls/widgets/details/call_notes_tab.dart';
import 'package:callx_ai/features/calls/widgets/details/call_details_footer.dart';
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

class _CallDetailsPanelState extends State<CallDetailsPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Comfortable responsive width for the detail drawer (480px to 520px)
    final panelWidth = (screenWidth * 0.35).clamp(460.0, 520.0);

    return Container(
      width: panelWidth,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? Colors.white10 : context.colors.lightGreyColor.withAlpha(80),
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
          // 1. Header (Avatar, Title, Badges, Close, Menu)
          CallDetailsHeader(
            call: widget.call,
            onCallAdded: widget.onCallAdded,
            onDelete: widget.onDelete,
          ),

          // 2. Audio Waveform Player (for active/completed calls)
          CallAudioPlayerWidget(call: widget.call),

          // 3. Segmented Tab Bar
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            ),
            child: TabBar(
              controller: _tabCtrl,
              labelColor: isDark ? Colors.white : Colors.black87,
              unselectedLabelColor: context.colors.darkGreyColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.sparkles, size: 13),
                        SizedBox(width: 4),
                        Text('Insights'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.chat_bubble_2, size: 13),
                        SizedBox(width: 4),
                        Text('Transcript'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.person_crop_circle, size: 13),
                        SizedBox(width: 4),
                        Text('CRM'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.doc_plaintext, size: 13),
                        SizedBox(width: 4),
                        Text('Notes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                CallAiInsightsTab(call: widget.call),
                CallTranscriptTab(call: widget.call),
                CallCrmTab(call: widget.call),
                CallNotesTab(
                  call: widget.call,
                  onCallUpdated: widget.onCallUpdated,
                ),
              ],
            ),
          ),

          // 5. Fixed Action Footer
          CallDetailsFooter(
            call: widget.call,
            onCallAdded: widget.onCallAdded,
          ),
        ],
      ),
    );
  }
}
