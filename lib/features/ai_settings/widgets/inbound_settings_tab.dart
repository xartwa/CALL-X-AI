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

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // 1. Inbound AI Master Switch Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: profile.isAiEnabled
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.phone_arrow_down_left,
                  color: profile.isAiEnabled
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Inbound AI Receptionist',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: profile.isAiEnabled
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            profile.isAiEnabled ? 'ACTIVE' : 'PAUSED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: profile.isAiEnabled
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Answers calls on +1 256-602-2144 using Maria\'s persona and business knowledge.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: profile.isAiEnabled,
                onChanged: (val) => cubit.toggleAiStatus(val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Two-Column Layout: OPENING GREETING (Left) | OPERATING HOURS (Right)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT CARD: OPENING GREETING
            Expanded(
              child: _InboundCard(
                title: 'OPENING GREETING',
                subtitle:
                    'The first sentence spoken when a customer calls your company.',
                headerAction: SizedBox(
                  height: 38,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.5),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: state.previewingVoiceId != null
                        ? null
                        : () => cubit.previewVoice(profile.voiceId),
                    icon: state.previewingVoiceId != null
                        ? const AppLoadingIndicator(size: 13)
                        : const Icon(CupertinoIcons.play_arrow_solid, size: 13),
                    label: Text(
                      state.previewingVoiceId != null ? 'Generating...' : 'Preview',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                children: [
                  const SettingsLabel('INBOUND OPENING GREETING'),
                  const SizedBox(height: 8),
                  DraftTextField(
                    value: profile.inboundGreeting,
                    minLines: 7,
                    maxLines: 10,
                    hintText:
                        'e.g. Thank you for calling CallX AI Headquarters. How can I help you today?',
                    onChanged: (value) => cubit.updateAgentDraft(
                      (current) => current.copyWith(inboundGreeting: value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(CupertinoIcons.sparkles,
                          size: 13, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Uses Maria\'s voice and your global speaking cadence.',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // RIGHT CARD: OPERATING HOURS & AVAILABILITY
            Expanded(
              child: _InboundCard(
                title: 'OPERATING HOURS & AVAILABILITY',
                subtitle: 'Choose when the AI should answer inbound calls.',
                children: [
                  // Option Selection Cards (24/7 vs Custom)
                  Row(
                    children: [
                      Expanded(
                        child: _AvailabilityOptionCard(
                          title: '24/7 availability',
                          subtitle: 'Answer every call',
                          isSelected: profile.is247,
                          onTap: () => cubit.updateAgentDraft(
                            (c) => c.copyWith(is247: true),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AvailabilityOptionCard(
                          title: 'Custom hours',
                          subtitle: 'Set weekly schedule',
                          isSelected: !profile.is247,
                          onTap: () => cubit.updateAgentDraft(
                            (c) => c.copyWith(is247: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (profile.is247) ...[
                    // 24/7 Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131C2E)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
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
                                    'Continuous availability',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'AI answers all calls around the clock, every day.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: profile.is247,
                                onChanged: (val) => cubit.updateAgentDraft(
                                  (c) => c.copyWith(is247: val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Day chips: M, T, W, T, F, S, S
                          Row(
                            children: [
                              for (final day in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                                Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                '24 hours · every day',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.darkGreyColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Custom Hours Time Inputs
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131C2E)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      onChanged: (value) =>
                                          cubit.updateAgentDraft(
                                        (current) => current.copyWith(
                                            operatingHoursStart: value),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SettingsLabel('END TIME (HH:MM)'),
                                    const SizedBox(height: 8),
                                    DraftTextField(
                                      value: profile.operatingHoursEnd,
                                      hintText: '18:00',
                                      onChanged: (value) =>
                                          cubit.updateAgentDraft(
                                        (current) => current.copyWith(
                                            operatingHoursEnd: value),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Outside ${profile.operatingHoursStart} - ${profile.operatingHoursEnd}, callers route to the human admin line.',
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InboundCard extends StatelessWidget {
  const _InboundCard({
    required this.title,
    required this.subtitle,
    this.headerAction,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Widget? headerAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              if (headerAction != null) headerAction!,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _AvailabilityOptionCard extends StatelessWidget {
  const _AvailabilityOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF131C2E) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
