import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';
import 'package:callx_ai/theme/app_colors.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoiceSettingsTab extends StatelessWidget {
  const VoiceSettingsTab({super.key, required this.state});

  final AiSettingsState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft!;
    final cubit = context.read<AiSettingsCubit>();
    final voice = state.selectedVoice;
    return ListView(
      children: [
        const SettingsLabel('CARTESIA VOICE'),
        const SizedBox(height: 10),
        if (state.voices.isEmpty)
          const SettingsBanner(
            icon: CupertinoIcons.exclamationmark_triangle,
            text:
                'No Cartesia voices are available. Check the Backend API key.',
            warning: true,
          )
        else
          Row(
            children: [
              Expanded(
                child: AppDropdownWidget<AiVoice>(
                  value: voice,
                  items: state.voices,
                  itemBuilder: (item) => item.subtitle.isEmpty
                      ? item.name
                      : '${item.name} — ${item.subtitle}',
                  onChanged: (item) {
                    if (item != null) {
                      cubit.updateDraft(
                        (current) => current.copyWith(voiceId: item.id),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                  onPressed: voice == null || state.previewingVoiceId != null
                      ? null
                      : () => cubit.previewVoice(voice.id),
                  icon: state.previewingVoiceId != null
                      ? const AppLoadingIndicator(size: 14)
                      : const Icon(CupertinoIcons.play_arrow_solid, size: 14),
                  label: Text(
                    state.previewingVoiceId != null
                        ? 'GENERATING...'
                        : 'LISTEN SAMPLE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            ],
          ),
        if (voice != null &&
            (voice.tagline.isNotEmpty || voice.description.isNotEmpty)) ...[
          const SizedBox(height: 10),
          Text(
            voice.tagline.isNotEmpty ? voice.tagline : voice.description,
            style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
          ),
        ],
        const SizedBox(height: 30),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsLabel('CONVERSATIONAL TONE'),
                  const SizedBox(height: 10),
                  AppDropdownWidget<String>(
                    value: draft.voiceTone,
                    items: AiSettingsCubit.tones,
                    itemBuilder: (item) => item,
                    onChanged: (value) {
                      if (value != null) {
                        cubit.updateDraft(
                          (current) => current.copyWith(voiceTone: value),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsLabel(
                    'SPEAKING SPEED — ${draft.voiceSpeed.toStringAsFixed(2)}x',
                  ),
                  Slider(
                    value: draft.voiceSpeed.clamp(.8, 1.3),
                    min: .8,
                    max: 1.3,
                    divisions: 10,
                    label: '${draft.voiceSpeed.toStringAsFixed(2)}x',
                    onChanged: (value) => cubit.updateDraft(
                      (current) => current.copyWith(voiceSpeed: value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const SettingsLabel('AI PERSONALITY & BEHAVIOR'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.personalityPrompt,
          minLines: 5,
          maxLines: 9,
          hintText:
              'Describe who the AI is, how it listens, responds, and handles objections...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(personalityPrompt: value),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your personality is combined with mandatory call safety, truthful AI disclosure, turn-taking, and no-hallucination rules.',
          style: TextStyle(fontSize: 11.5, color: context.colors.darkGreyColor),
        ),
      ],
    );
  }
}
