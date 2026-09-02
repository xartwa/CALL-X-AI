import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
import 'package:callx_ai/features/ai_settings/widgets/create_scenario_dialog.dart';
import 'package:callx_ai/features/ai_settings/widgets/settings_form_widgets.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScenarioSettingsTab extends StatelessWidget {
  const ScenarioSettingsTab({super.key, required this.state});

  final AiSettingsState state;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    if (draft == null) {
      return const Center(child: Text('No scenario selected.'));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<AiSettingsCubit>();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        // 1. Scenario Selector & Actions
        Row(
          children: [
            Expanded(
              child: AppDropdownWidget<AiScenario>(
                value: state.savedScenario,
                items: state.scenarios,
                itemBuilder: (scenario) => scenario.name,
                onChanged: state.hasUnsavedChanges
                    ? null
                    : (scenario) {
                        if (scenario != null) cubit.selectScenario(scenario.id);
                      },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
                onPressed: state.isBusy ? null : () => _create(context),
                icon: const Icon(CupertinoIcons.plus, size: 14),
                label: const Text('NEW SCENARIO'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.errorColor,
                  side: BorderSide(
                    color: context.colors.errorColor.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
                onPressed: state.isBusy || draft.isDefaultInbound
                    ? null
                    : () => _delete(context, draft.name),
                icon: const Icon(CupertinoIcons.delete, size: 14),
                label: const Text('DELETE'),
              ),
            ),
          ],
        ),
        if (state.hasUnsavedChanges) ...[
          const SizedBox(height: 8),
          Text(
            'Save or reset changes before switching scenarios.',
            style:
                TextStyle(fontSize: 11.5, color: context.colors.warningColor),
          ),
        ],

        const SizedBox(height: 26),

        // 2. Scenario Name & Active Switch
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsLabel('SCENARIO NAME'),
                  const SizedBox(height: 8),
                  DraftTextField(
                    value: draft.name,
                    hintText: 'e.g. Website Inquiry Follow-Up',
                    onChanged: (value) => cubit.updateDraft(
                      (current) => current.copyWith(name: value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const SettingsLabel('ACTIVE'),
                const SizedBox(height: 4),
                Switch.adaptive(
                  value: draft.isActive,
                  onChanged: draft.isDefaultInbound
                      ? null
                      : (value) => cubit.updateDraft(
                            (current) => current.copyWith(isActive: value),
                          ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 3. Opening Hook / Greeting
        const SettingsLabel('OPENING GREETING & HOOK'),
        const SizedBox(height: 6),
        Text(
          'The first sentence the AI speaks as soon as the recipient answers this outbound call.',
          style: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
        ),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.openingGreeting,
          minLines: 2,
          maxLines: 4,
          hintText:
              'e.g. Hi there! This is Skylar from CallX AI. I noticed you checked out our service yesterday...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(openingGreeting: value),
          ),
        ),

        const SizedBox(height: 28),

        // 4. Qualifying Questions List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsLabel(
                  'QUALIFYING QUESTIONS (${draft.qualifyingQuestions.length})',
                ),
                const SizedBox(height: 2),
                Text(
                  'Questions the AI will naturally ask during the conversation.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: draft.qualifyingQuestions.length >= 20
                  ? null
                  : () => _addQuestion(context),
              icon: const Icon(CupertinoIcons.plus_circle, size: 14),
              label: const Text('ADD QUESTION'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (draft.qualifyingQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.colors.darkGreyColor.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              'No qualifying questions added. Click "+ ADD QUESTION" to specify what information the AI should collect.',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.darkGreyColor,
              ),
            ),
          )
        else
          ...draft.qualifyingQuestions.asMap().entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          context.colors.darkGreyColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove question',
                        icon: const Icon(CupertinoIcons.trash, size: 15),
                        onPressed: () {
                          final questions = List<String>.from(
                            draft.qualifyingQuestions,
                          )..removeAt(entry.key);
                          cubit.updateDraft(
                            (current) => current.copyWith(
                              qualifyingQuestions: questions,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

        const SizedBox(height: 32),

        // 5. Action Buttons (Save & Reset)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (state.hasUnsavedChanges) ...[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: state.isBusy ? null : () => cubit.resetDraft(),
                child: const Text('RESET', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 12),
            ],
            SizedBox(
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
                onPressed: state.isBusy ? null : () => cubit.saveDraft(),
                icon: state.isSaving
                    ? const AppLoadingIndicator(size: 14)
                    : const Icon(CupertinoIcons.check_mark, size: 16),
                label: Text(
                  state.isSaving ? 'SAVING...' : 'SAVE SCENARIO',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final cubit = context.read<AiSettingsCubit>();
    final result = await CreateScenarioDialog.show(context);
    if (result != null) {
      final name = result['name'] ?? '';
      final greeting = result['greeting'] ?? '';
      final defaultVoiceId = cubit.state.agentDraft?.voiceId ??
          'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4';
      await cubit.createScenario(
        name,
        'Sales & Outreach',
        greeting,
        'Engage prospective customers, introduce services, and qualify needs.',
        defaultVoiceId,
      );
    }
  }

  Future<void> _addQuestion(BuildContext context) async {
    final cubit = context.read<AiSettingsCubit>();
    final controller = TextEditingController();
    final question = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 440,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ADD QUALIFYING QUESTION',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.clear,
                            size: 18, color: Colors.white70),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. What is your estimated monthly budget?',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      onSubmitted: (val) {
                        final text = val.trim();
                        if (text.isNotEmpty) {
                          Navigator.of(dialogContext).pop(text);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('CANCEL',
                            style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.of(dialogContext).pop(text);
                          }
                        },
                        child: const Text('ADD QUESTION',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (question != null && question.trim().isNotEmpty) {
      final currentQuestions = cubit.state.draft?.qualifyingQuestions ?? [];
      cubit.updateDraft(
        (current) => current.copyWith(
          qualifyingQuestions: [...currentQuestions, question.trim()],
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, String name) async {
    final cubit = context.read<AiSettingsCubit>();
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DELETE SCENARIO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to permanently delete "$name"? This action cannot be undone.',
                    style:
                        const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('CANCEL',
                            style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('DELETE',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirm == true) {
      await cubit.deleteScenario();
    }
  }
}
