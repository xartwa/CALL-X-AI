import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
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
    final draft = state.draft!;
    final cubit = context.read<AiSettingsCubit>();
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: AppDropdownWidget<AiScenario>(
                value: state.savedScenario,
                items: state.scenarios,
                itemBuilder: (scenario) =>
                    '${scenario.name} (${scenario.category})',
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
                label: const Text('NEW'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
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
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsLabel('SCENARIO NAME'),
                  const SizedBox(height: 8),
                  DraftTextField(
                    value: draft.name,
                    onChanged: (value) => cubit.updateDraft(
                      (current) => current.copyWith(name: value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SettingsLabel('CATEGORY'),
                  const SizedBox(height: 8),
                  AppDropdownWidget<String>(
                    value: draft.category,
                    items: AiSettingsCubit.categories,
                    itemBuilder: (item) => item,
                    onChanged: (value) {
                      if (value != null) {
                        cubit.updateDraft(
                          (current) => current.copyWith(category: value),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Column(
              children: [
                const SettingsLabel('ACTIVE'),
                Switch(
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
        const SizedBox(height: 26),
        const SettingsLabel('OPENING GREETING'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.openingGreeting,
          minLines: 2,
          maxLines: 3,
          hintText: 'The first sentence spoken when the call connects...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(openingGreeting: value),
          ),
        ),
        const SizedBox(height: 26),
        const SettingsLabel('BUSINESS OBJECTIVE & KNOWLEDGE'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.pitchSummary,
          minLines: 3,
          maxLines: 6,
          hintText:
              'Describe the offer, facts the AI can use, and the desired outcome...',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(pitchSummary: value),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SettingsLabel(
              'QUALIFYING QUESTIONS (${draft.qualifyingQuestions.length})',
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
        ...draft.qualifyingQuestions.asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: .04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${entry.key + 1}.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove question',
                      icon: const Icon(CupertinoIcons.delete, size: 15),
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
        const SizedBox(height: 22),
        const SettingsLabel('ACTION WHEN INTERESTED'),
        const SizedBox(height: 8),
        DraftTextField(
          value: draft.actionOnInterest,
          hintText: 'e.g. Offer an appointment and confirm contact details',
          onChanged: (value) => cubit.updateDraft(
            (current) => current.copyWith(actionOnInterest: value),
          ),
        ),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final result = await CreateScenarioDialog.show(context);
    if (result != null && context.mounted) {
      await context
          .read<AiSettingsCubit>()
          .createScenario(result.$1, result.$2);
    }
  }

  Future<void> _addQuestion(BuildContext context) async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Container(
          width: 480,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(CupertinoIcons.clear, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'QUESTION TEXT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                  border: Border.all(
                    color: isDark
                        ? Colors.white12
                        : context.colors.lightGreyColor,
                  ),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.02),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14),
                    hintText:
                        'e.g. How many service calls does your team handle per week?',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: context.colors.darkGreyColor,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius,
                            ),
                          ),
                        ),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pop(dialogContext, text);
                          }
                        },
                        icon: const Icon(
                          CupertinoIcons.plus_circle_fill,
                          size: 15,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'ADD QUESTION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<AiSettingsCubit>().updateDraft(
            (current) => current.copyWith(
              qualifyingQuestions: [...current.qualifyingQuestions, result],
            ),
          );
    }
  }

  Future<void> _delete(BuildContext context, String name) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: Container(
          width: 440,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              AppColors.errorColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash_fill,
                          size: 16,
                          color: AppColors.errorColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'DELETE SCENARIO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(CupertinoIcons.clear, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Are you sure you want to permanently delete "$name"? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius,
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AiSettingsCubit>().deleteSelected();
    }
  }

}
