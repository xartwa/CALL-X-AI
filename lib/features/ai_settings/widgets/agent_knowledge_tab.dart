import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_agent_profile.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
import 'package:callx_ai/features/ai_settings/widgets/ai_delete_dialog.dart';

import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';

import 'package:callx_ai/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:web/web.dart' as web;

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

  void _viewPdf(String? url) {
    if (url != null && url.isNotEmpty && kIsWeb) {
      web.window.open(url, '_blank');
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

    AiVoiceEmotion? selectedEmotion;
    for (final e in profile.availableEmotions) {
      if (e.id == profile.voiceEmotion) {
        selectedEmotion = e;
        break;
      }
    }
    selectedEmotion ??= profile.availableEmotions.isNotEmpty
        ? profile.availableEmotions.first
        : const AiVoiceEmotion(id: 'calm', label: 'Calm', emoji: '😌');

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ROW 1: VOICE & DELIVERY | AGENT BEHAVIOR
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VOICE & DELIVERY
            Expanded(
              child: _CardContainer(
                title: 'VOICE & DELIVERY',
                subtitle: 'Choose the default voice used across every call.',
                children: [
                  const SettingsLabel('VOICE SELECTION'),
                  const SizedBox(height: 8),
                  // Voice Dropdown + Listen Button on same horizontal level
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
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius,
                              ),
                            ),
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: voice == null ||
                                  state.previewingVoiceId != null
                              ? null
                              : () => cubit.previewVoice(voice.id),
                          icon: state.previewingVoiceId != null
                              ? const AppLoadingIndicator(size: 14)
                              : const Icon(CupertinoIcons.play_arrow_solid,
                                  size: 14),
                          label: Text(
                            state.previewingVoiceId != null
                                ? 'Generating...'
                                : 'Listen',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Cartesia Emotion Dropdown (replaces the 2 small boxes)
                  const SettingsLabel('VOICE TONE / EMOTION'),
                  const SizedBox(height: 8),
                  AppDropdownWidget<AiVoiceEmotion>(
                    value: selectedEmotion,
                    items: profile.availableEmotions,
                    itemBuilder: (e) => '${e.emoji}   ${e.label}',
                    onChanged: (item) {
                      if (item != null) {
                        cubit.updateAgentDraft(
                          (current) => current.copyWith(voiceEmotion: item.id),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  // Speaking Cadence Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speaking cadence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Text(
                        '${profile.voiceSpeed.toStringAsFixed(2)}x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: profile.voiceSpeed.clamp(.8, 1.3),
                    min: .8,
                    max: 1.3,
                    divisions: 10,
                    onChanged: (value) => cubit.updateAgentDraft(
                      (current) => current.copyWith(voiceSpeed: value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Measured',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: context.colors.darkGreyColor)),
                        Text('Natural',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: context.colors.darkGreyColor)),
                        Text('Energetic',
                            style: TextStyle(
                                fontSize: 10.5,
                                color: context.colors.darkGreyColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 2. AGENT BEHAVIOR
            Expanded(
              child: _CardContainer(
                title: 'AGENT BEHAVIOR',
                subtitle: 'Core identity, manners, and behavior for all calls.',
                children: [
                  const SettingsLabel('ROLE & CORE PERSONALITY'),
                  const SizedBox(height: 8),
                  DraftTextField(
                    value: profile.rolePrompt,
                    minLines: 8,
                    maxLines: 12,
                    hintText:
                        'Define the core identity, manners, and behavior of your AI assistant...',
                    onChanged: (value) => cubit.updateAgentDraft(
                      (current) => current.copyWith(rolePrompt: value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ROW 2: BUSINESS KNOWLEDGE | KNOWLEDGE BASE DOCUMENT (PDF)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. BUSINESS KNOWLEDGE
            Expanded(
              child: _CardContainer(
                title: 'BUSINESS KNOWLEDGE',
                subtitle:
                    'Give the AI context to answer customer questions accurately.',
                children: [
                  const SettingsLabel('KNOWLEDGE & GUIDELINES'),
                  const SizedBox(height: 8),
                  DraftTextField(
                    value: profile.knowledgeText,
                    minLines: 6,
                    maxLines: 9,
                    hintText:
                        'Enter key company details, products, packages, operating hours, and standard replies...',
                    onChanged: (value) => cubit.updateAgentDraft(
                      (current) => current.copyWith(knowledgeText: value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 4. KNOWLEDGE BASE DOCUMENT (PDF)
            Expanded(
              child: _CardContainer(
                title: 'KNOWLEDGE BASE DOCUMENT (PDF)',
                subtitle:
                    'Upload business documentation, product manuals, or FAQ booklet.',
                children: [
                  if (state.isUploadingPdf)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131C2E)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const AppLoadingIndicator(size: 18),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Uploading & extracting PDF knowledge...',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${((state.uploadProgress ?? 0.3) * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: state.uploadProgress,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : Colors.black12,
                              valueColor:
                                  AlwaysStoppedAnimation(primaryColor),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (profile.knowledgePdfName != null &&
                      profile.knowledgePdfName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131C2E)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              CupertinoIcons.doc_fill,
                              color: Color(0xFF6366F1),
                              size: 24,
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Knowledge extracted & active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (profile.knowledgePdfUrl != null &&
                              profile.knowledgePdfUrl!.isNotEmpty)
                            IconButton(
                              tooltip: 'View Document',
                              icon: const Icon(CupertinoIcons.eye, size: 18),
                              onPressed: () =>
                                  _viewPdf(profile.knowledgePdfUrl),
                            ),
                          IconButton(
                            tooltip: 'Delete Document',
                            icon: Icon(
                              CupertinoIcons.trash,
                              size: 18,
                              color: context.colors.errorColor,
                            ),
                            onPressed: () async {
                              final confirm = await AiDeleteDialog.show(
                                context,
                                title: 'Delete Document',
                                message:
                                    'Are you sure you want to remove the uploaded knowledge document? This action cannot be undone.',
                                confirmLabel: 'Delete',
                                cancelLabel: 'Cancel',
                              );
                              if (confirm == true) {
                                await cubit.removeKnowledgePdf();
                              }
                            },

                          ),
                        ],
                      ),
                    )
                  else
                    InkWell(
                      onTap: () => _pickAndUploadPdf(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131C2E)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  CupertinoIcons.cloud_upload_fill,
                                  color: primaryColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload business PDF',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Brochure, FAQ, or catalog · PDF',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
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
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}
