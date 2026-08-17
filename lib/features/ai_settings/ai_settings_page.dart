import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/features/ai_settings/widgets/ai_settings_headers.dart';
import 'package:callx_ai/features/ai_settings/widgets/inbound_reception_tab.dart';
import 'package:callx_ai/features/ai_settings/widgets/outbound_campaigns_tab.dart';
import 'package:callx_ai/features/ai_settings/widgets/voice_personality_tab.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _saveSettings() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _hasUnsavedChanges = false;
    });

    AppUtils.showSnackBar(
      context: context,
      title: 'AI Settings Saved',
      extraMessage: 'Voice agent settings updated successfully.',
      toastificationType: ToastificationType.success,
    );
  }

  void _resetDefaults() {
    setState(() {
      _hasUnsavedChanges = false;
    });

    AppUtils.showSnackBar(
      context: context,
      title: 'Settings Reset',
      extraMessage: 'Default AI voice settings restored.',
      toastificationType: ToastificationType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Row
        Row(
          children: [
            StatCardWidget(
              label: 'AI CALL LINES',
              value: '10 Active',
              icon: CupertinoIcons.phone_badge_plus,
              iconColor: context.colors.primaryLightColor,
              iconBgColor:
                  context.colors.primaryLightColor.withValues(alpha: 0.1),
            ),
            const SizedBox(width: 16),
            StatCardWidget(
              label: 'SELECTED VOICE',
              value: 'Sarah (US)',
              icon: CupertinoIcons.mic_circle_fill,
              iconColor: const Color(0xFF10B981),
              iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
            ),
            const SizedBox(width: 16),
            StatCardWidget(
              label: 'OUTBOUND CAMPAIGN',
              value: 'B2B Sales',
              icon: CupertinoIcons.phone_arrow_up_right,
              iconColor: const Color(0xFF8B5CF6),
              iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            ),
            const SizedBox(width: 16),
            StatCardWidget(
              label: 'INBOUND RECEPTION',
              value: '24/7 Active',
              icon: CupertinoIcons.phone_arrow_down_left,
              iconColor: context.colors.warningColor,
              iconBgColor: context.colors.warningColor.withValues(alpha: 0.1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Header Toolbar with Save/Reset
        AiSettingsHeaders(
          hasUnsavedChanges: _hasUnsavedChanges,
          isSaving: _isSaving,
          onSave: _saveSettings,
          onReset: _resetDefaults,
        ),
        const SizedBox(height: 20),
        
        // Main Tabs Card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : context.colors.lightGreyColor,
              ),
            ),
            child: Column(
              children: [
                // TabBar Navigation
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: context.colors.darkGreyColor,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          letterSpacing: 0.5,
                        ),
                        tabs: const [
                          Tab(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.mic_fill, size: 14),
                                SizedBox(width: 8),
                                Text('AI VOICE & TONE'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.phone_arrow_up_right,
                                    size: 14),
                                SizedBox(width: 8),
                                Text('OUTBOUND COLD CALL SCRIPT (OUTCOME)'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.phone_arrow_down_left,
                                    size: 14),
                                SizedBox(width: 8),
                                Text('INBOUND CALL ANSWERING (INCOME)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
        
                // TabBar Views
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 26.0),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // 1. AI Voice & Tone
                        VoicePersonalityTab(onDataChanged: _onDataChanged),
        
                        // 2. Outbound Cold Calls (Outcome)
                        OutboundCampaignsTab(onDataChanged: _onDataChanged),
        
                        // 3. Inbound Reception (Income)
                        InboundReceptionTab(onDataChanged: _onDataChanged),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
