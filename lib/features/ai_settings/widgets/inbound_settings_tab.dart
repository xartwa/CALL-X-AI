import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InboundSettingsTab extends StatelessWidget {
  const InboundSettingsTab({super.key, required this.state});

  final AiSettingsState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.agentDraft;
    if (profile == null) {
      return const Center(child: AppLoadingIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AiSettingsCubit>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        SettingsBanner(
          icon: profile.isAiEnabled
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.pause_circle_fill,
          text: profile.isAiEnabled
              ? 'Inbound AI Receptionist is ACTIVE on dedicated line +1 256-602-2144. It uses your Global Agent Personality and Knowledge Base.'
              : 'AI Engine is currently PAUSED. Incoming calls will route directly to the admin phone number.',
          warning: !profile.isAiEnabled,
        ),
        const SizedBox(height: 24),

        // 1. Inbound Greeting
        const SettingsLabel('INBOUND OPENING GREETING'),
        const SizedBox(height: 6),
        Text(
          'The first sentence spoken immediately when a customer calls your company phone number.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 10),
        DraftTextField(
          value: profile.inboundGreeting,
          minLines: 2,
          maxLines: 4,
          hintText:
              'e.g. Thank you for calling CallX AI Headquarters. How can I help you today?',
          onChanged: (value) => cubit.updateAgentDraft(
            (current) => current.copyWith(inboundGreeting: value),
          ),
        ),

        const SizedBox(height: 32),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 24),

        // 2. Operating Hours & Schedule
        const SettingsLabel('OPERATING HOURS & AVAILABILITY'),
        const SizedBox(height: 6),
        Text(
          'Configure when the AI answers inbound calls. Outside these hours, calls route to the human admin line.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.darkGreyColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24/7 Continuous Availability',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'AI answers all calls around the clock, every day.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: profile.is247,
                    onChanged: (val) => cubit.updateAgentDraft(
                      (current) => current.copyWith(is247: val),
                    ),
                  ),
                ],
              ),
              if (!profile.is247) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SettingsLabel('START TIME (HH:MM)'),
                          const SizedBox(height: 8),
                          DraftTextField(
                            value: profile.operatingHoursStart,
                            hintText: '09:00',
                            onChanged: (value) => cubit.updateAgentDraft(
                              (current) =>
                                  current.copyWith(operatingHoursStart: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SettingsLabel('END TIME (HH:MM)'),
                          const SizedBox(height: 8),
                          DraftTextField(
                            value: profile.operatingHoursEnd,
                            hintText: '18:00',
                            onChanged: (value) => cubit.updateAgentDraft(
                              (current) =>
                                  current.copyWith(operatingHoursEnd: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Outside ${profile.operatingHoursStart} - ${profile.operatingHoursEnd}, callers will be connected to the human office line.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 3. Save Button
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 42,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: state.isBusy ? null : () => cubit.saveAgentProfile(),
              icon: state.isSaving
                  ? const AppLoadingIndicator(size: 14)
                  : const Icon(CupertinoIcons.check_mark, size: 16),
              label: Text(
                state.isSaving ? 'SAVING...' : 'SAVE INBOUND SETTINGS',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
