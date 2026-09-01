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
    final draft = state.draft!;
    final cubit = context.read<AiSettingsCubit>();


    return ListView(
      children: [
        SettingsBanner(
          icon: draft.isDefaultInbound
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.phone_arrow_down_left,
          text: draft.isDefaultInbound
              ? 'This scenario is currently active for all incoming telephone calls on +1 256-602-2144.'
              : 'Select this scenario as the default inbound receptionist to answer incoming calls.',
          warning: !draft.isDefaultInbound,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Set as Default Inbound Receptionist',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                subtitle: const Text(
                  'Routes all incoming phone calls on the dedicated Twilio number to this AI persona.',
                  style: TextStyle(fontSize: 12),
                ),
                value: draft.isDefaultInbound,
                onChanged: draft.isDefaultInbound
                    ? null
                    : (value) => cubit.updateDraft(
                          (current) => current.copyWith(
                            isDefaultInbound: value,
                            isActive: value ? true : current.isActive,
                          ),
                        ),
              ),
            ),
          ],
        ),
        const Divider(height: 28),
        const SettingsLabel('INBOUND OPENING GREETING'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.openingGreeting,
          minLines: 2,
          maxLines: 3,
          hintText:
              'e.g. Thanks for calling CallX AI! This is Skyler, how can I help you today?',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(openingGreeting: value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The first sentence spoken as soon as a customer connects to the AI phone number.',
          style: TextStyle(fontSize: 11.5, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 24),
        const SettingsLabel('INBOUND RECEPTIONIST PERSONALITY & INSTRUCTIONS'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.personalityPrompt,
          minLines: 4,
          maxLines: 8,
          hintText:
              'Describe how the AI should introduce itself, actively listen, answer inbound questions, triage calls, and handle customer inquiries...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(personalityPrompt: value),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Defines the tone, conversational pacing, active backchanneling (e.g. "Mm-hmm", "Totally hear you!"), and customer service guidelines.',
          style: TextStyle(fontSize: 11.5, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 24),
        const SettingsLabel('INBOUND BUSINESS OBJECTIVE & COMPANY KNOWLEDGE'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.pitchSummary,
          minLines: 3,
          maxLines: 6,
          hintText:
              'Explain what services or products the company provides, key FAQ answers, and desired call conclusion...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(pitchSummary: value),
          ),
        ),
        const SizedBox(height: 24),
        const SettingsLabel('DESIRED ACTION WHEN CALLER IS INTERESTED'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.actionOnInterest,
          hintText:
              'e.g. Confirm caller phone/email and schedule a demo appointment',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(actionOnInterest: value),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

