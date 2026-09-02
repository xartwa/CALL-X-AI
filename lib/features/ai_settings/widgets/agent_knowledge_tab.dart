import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class AgentKnowledgeTab extends StatelessWidget {
  const AgentKnowledgeTab({super.key, required this.state});

  final AiSettingsState state;

  Future<void> _pickAndUploadPdf(BuildContext context) async {
    final cubit = context.read<AiSettingsCubit>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          await cubit.uploadKnowledgePdf(bytes, file.name);
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppUtils.showSnackBar(
          context: context,
          title: 'File Selection Failed',
          extraMessage: 'Unable to read the selected PDF file.',
          toastificationType: ToastificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = state.agentDraft;
    if (profile == null) {
      return const Center(child: AppLoadingIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AiSettingsCubit>();
    final voice = state.selectedVoice;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // 1. Voice Selection Header
        const SettingsLabel('AI VOICE (CURATED FEMININE)'),
        const SizedBox(height: 10),
        if (state.voices.isEmpty)
          const SettingsBanner(
            icon: CupertinoIcons.exclamationmark_triangle,
            text: 'No Cartesia voices are available. Check the Backend API key.',
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
                      cubit.updateAgentDraft(
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
          const SizedBox(height: 8),
          Text(
            voice.tagline.isNotEmpty ? voice.tagline : voice.description,
            style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
          ),
        ],

        const SizedBox(height: 24),
        SettingsLabel(
          'SPEAKING CADENCE — ${profile.voiceSpeed.toStringAsFixed(2)}x',
        ),
        Slider(
          value: profile.voiceSpeed.clamp(.8, 1.3),
          min: .8,
          max: 1.3,
          divisions: 10,
          label: '${profile.voiceSpeed.toStringAsFixed(2)}x',
          onChanged: (value) => cubit.updateAgentDraft(
            (current) => current.copyWith(voiceSpeed: value),
          ),
        ),

        const SizedBox(height: 28),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 24),

        // 2. Core Personality / Role
        const SettingsLabel('ROLE & CORE PERSONALITY (GLOBAL FOR ALL CALLS)'),
        const SizedBox(height: 6),
        Text(
          'Define the core identity, manners, and behavior of your AI assistant. This personality remains consistent across all outbound scenarios and inbound calls.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 10),
        DraftTextField(
          value: profile.rolePrompt,
          minLines: 3,
          maxLines: 6,
          hintText:
              'e.g. You are a polite, energetic, and professional receptionist for CallX AI. You speak concisely, warm and directly...',
          onChanged: (value) => cubit.updateAgentDraft(
            (current) => current.copyWith(rolePrompt: value),
          ),
        ),

        const SizedBox(height: 28),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 24),

        // 3. Business Knowledge Base
        const SettingsLabel('BUSINESS KNOWLEDGE & GUIDELINES'),
        const SizedBox(height: 6),
        Text(
          'Provide services, pricing, company rules, and FAQs. The AI will use this knowledge to accurately answer customer questions.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 10),
        DraftTextField(
          value: profile.knowledgeText,
          minLines: 4,
          maxLines: 8,
          hintText:
              'Enter key company details, products, packages, operating hours, and standard replies...',
          onChanged: (value) => cubit.updateAgentDraft(
            (current) => current.copyWith(knowledgeText: value),
          ),
        ),

        const SizedBox(height: 20),

        // 4. PDF Document Upload
        const SettingsLabel('KNOWLEDGE BASE DOCUMENT (PDF)'),
        const SizedBox(height: 6),
        Text(
          'Upload your company catalog, product booklet, or FAQ PDF. Text will be extracted securely on the server for the AI.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 12),

        if (state.isUploadingPdf)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLoadingIndicator(size: 20),
                SizedBox(width: 14),
                Text(
                  'Processing & extracting PDF knowledge...',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else if (profile.knowledgePdfName != null &&
            profile.knowledgePdfName!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.successColor.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.successColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text_fill,
                    color: context.colors.successColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.knowledgePdfName!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Knowledge document active & extracted',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.errorColor,
                    side: BorderSide(
                      color: context.colors.errorColor.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => cubit.removeKnowledgePdf(),
                  icon: const Icon(CupertinoIcons.trash, size: 14),
                  label: const Text('REMOVE', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _pickAndUploadPdf(context),
                  icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 14),
                  label: const Text('REPLACE', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: () => _pickAndUploadPdf(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.darkGreyColor.withValues(alpha: 0.25),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.cloud_upload,
                    color: primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'UPLOAD BUSINESS PDF (BROCHURE, FAQ, OR CATALOG)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 32),

        // 5. Save Agent Profile Button
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
                state.isSaving ? 'SAVING...' : 'SAVE AGENT & KNOWLEDGE',
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
