import 'package:audioplayers/audioplayers.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/widgets/app_pill_tab_bar.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/widgets/agent_knowledge_tab.dart';
import 'package:callx_ai/features/ai_settings/widgets/ai_settings_status_bar.dart';
import 'package:callx_ai/features/ai_settings/widgets/inbound_settings_tab.dart';

import 'package:callx_ai/features/ai_settings/widgets/scenario_settings_tab.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AiSettingsCubit>().load();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AiSettingsCubit, AiSettingsState>(
        listenWhen: (previous, current) =>
            previous.feedbackRevision != current.feedbackRevision ||
            previous.previewRevision != current.previewRevision,
        listener: (context, state) async {
          if (state.feedbackMessage != null) {
            AppUtils.showSnackBar(
              context: context,
              title:
                  state.errorMessage == null ? 'AI Settings' : 'Action failed',
              extraMessage: state.feedbackMessage!,
              toastificationType: state.errorMessage == null
                  ? ToastificationType.success
                  : ToastificationType.error,
            );
          }
          if (state.previewAudio != null) {
            await _audioPlayer.stop();
            await _audioPlayer.play(BytesSource(state.previewAudio!));
          }
        },
        builder: (context, state) {
          if (state.status == AiSettingsStatus.initial ||
              state.status == AiSettingsStatus.loading) {
            return const AppLoadingView(message: 'Loading live AI settings...');
          }
          if (state.status == AiSettingsStatus.failure) {
            return AppErrorView(
              message: state.errorMessage ?? 'Unable to load AI settings.',
              onRetry: context.read<AiSettingsCubit>().load,
            );
          }
          if (state.agentDraft == null) {
            return const AppEmptyView(
              title: 'No AI configuration found',
              description: 'Setting up default AI configuration...',
              icon: CupertinoIcons.waveform,
            );
          }
          return _content(context, state);
        },
      );

  Widget _content(BuildContext context, AiSettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AiSettingsCubit>();

    final hasChanges = state.hasUnsavedChanges || state.hasAgentUnsavedChanges;

    final saveLabel = state.isSaving
        ? 'Saving...'
        : (_tabs.index == 0
            ? 'Save agent settings'
            : (_tabs.index == 1 ? 'Save scenario' : 'Save inbound settings'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Header: SpacedText Title + Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpacedText(
              text: 'AI Settings',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.colors.blackColor,
            ),
            Row(
              children: [
                if (hasChanges) ...[
                  SizedBox(
                    height: 38,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: context.colors.darkGreyColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                      onPressed: state.isBusy ? null : cubit.load,
                      child: Text(
                        'Reset draft'.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    onPressed: state.isBusy
                        ? null
                        : () async {
                            if (state.hasAgentUnsavedChanges) {
                              await cubit.saveAgentProfile();
                            }
                            if (state.hasUnsavedChanges) {
                              await cubit.saveDraft();
                            }
                          },
                    child: Text(
                      saveLabel.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Sleek Horizontal KPI Status Bar
        AiSettingsStatusBar(
          state: state,
          onRefresh: cubit.load,
        ),
        const SizedBox(height: 14),

        // 3. Main Content Card with Numbered Tabs
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : context.colors.mediumGreyColor.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                // Tab Switcher Header (Left Aligned with numbers)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      AppPillTabBar(
                        controller: _tabs,
                        tabs: const [
                          AppPillTabItem(
                            label: 'Agent & Knowledge',
                            icon: CupertinoIcons.sparkles,
                            badgeText: '01',
                          ),
                          AppPillTabItem(
                            label: 'Outbound Scenarios',
                            icon: CupertinoIcons.phone_arrow_up_right,
                            badgeText: '02',
                          ),
                          AppPillTabItem(
                            label: 'Inbound & Hours',
                            icon: CupertinoIcons.clock,
                            badgeText: '03',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        AgentKnowledgeTab(state: state),
                        ScenarioSettingsTab(state: state),
                        InboundSettingsTab(state: state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).withPullToRefresh(onRefresh: cubit.load);
  }
}
