import 'package:audioplayers/audioplayers.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/widgets/ai_settings_headers.dart';
import 'package:callx_ai/features/ai_settings/widgets/create_scenario_dialog.dart';
import 'package:callx_ai/features/ai_settings/widgets/inbound_settings_tab.dart';
import 'package:callx_ai/features/ai_settings/widgets/scenario_settings_tab.dart';
import 'package:callx_ai/features/ai_settings/widgets/voice_settings_tab.dart';
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
          if (state.draft == null) {
            return const AppEmptyView(
              title: 'No AI scenarios found',
              description: 'Create a scenario in the Backend to get started.',
              icon: CupertinoIcons.waveform,
            );
          }
          return _content(context, state);
        },
      );

  Widget _content(BuildContext context, AiSettingsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AiSettingsCubit>();
    final inbound = state.scenarios
        .where((scenario) => scenario.isDefaultInbound)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Cards Row matching EmailFollowUpsPage
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatCardWidget(
                label: 'ACTIVE SCENARIOS',
                value:
                    '${state.scenarios.where((item) => item.isActive).length}',
                icon: CupertinoIcons.waveform,
                iconColor: context.colors.primaryLightColor,
                iconBgColor:
                    context.colors.primaryLightColor.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'SELECTED VOICE',
                value: state.selectedVoice?.name ?? 'Not selected',
                icon: CupertinoIcons.mic_circle_fill,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'INBOUND AI',
                value: inbound?.name ?? 'Not configured',
                icon: CupertinoIcons.phone_arrow_down_left,
                iconColor: context.colors.warningColor,
                iconBgColor: context.colors.warningColor.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'VOICE ENGINE',
                value:
                    state.config?.isConfigured == true ? 'Online' : 'Offline',
                icon: CupertinoIcons.cloud_fill,
                iconColor: state.config?.isConfigured == true
                    ? const Color(0xFF10B981)
                    : AppColors.errorColor,
                iconBgColor: (state.config?.isConfigured == true
                        ? const Color(0xFF10B981)
                        : AppColors.errorColor)
                    .withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Headers / Action Toolbar matching EmailFollowUpsPage
        AiSettingsHeaders(
          hasUnsavedChanges: state.hasUnsavedChanges,
          isSaving: state.isSaving,
          isConfigured: state.config?.isConfigured == true,
          engineLabel: [
            state.config?.defaultModel ?? '',
            state.config?.transport ?? '',
          ].where((item) => item.isNotEmpty).join(' • '),
          onSave: cubit.save,
          onReset: cubit.resetDraft,
          onRefresh: cubit.load,
          onNewScenario: () => _showCreateScenarioDialog(context),
        ),
        const SizedBox(height: 16),

        // Main Content Card with Left-Aligned Tabs
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
                // Tab Switcher Header (Left Aligned)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabs,
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
                                Icon(CupertinoIcons.mic_circle_fill, size: 14),
                                SizedBox(width: 6),
                                Text('VOICE & PERSONALITY'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.waveform, size: 14),
                                SizedBox(width: 6),
                                Text('SCENARIO & CONVERSATION'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.phone_arrow_down_left,
                                    size: 14),
                                SizedBox(width: 6),
                                Text('INBOUND RECEPTION'),
                              ],
                            ),
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
                        VoiceSettingsTab(state: state),
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

  Future<void> _showCreateScenarioDialog(BuildContext context) async {
    final result = await CreateScenarioDialog.show(context);
    if (result != null && context.mounted) {
      await context
          .read<AiSettingsCubit>()
          .createScenario(result.$1, result.$2);
    }
  }
}


extension<T> on Iterable<T> {
  T? get firstOrNull {
    final value = iterator;
    return value.moveNext() ? value.current : null;
  }
}

