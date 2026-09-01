import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
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
            OutlinedButton.icon(
              onPressed: state.isBusy ? null : () => _create(context),
              icon: const Icon(CupertinoIcons.plus, size: 14),
              label: const Text('NEW'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: state.isBusy || draft.isDefaultInbound
                  ? null
                  : () => _delete(context, draft.name),
              icon: const Icon(CupertinoIcons.delete, size: 14),
              label: const Text('DELETE'),
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
    final controller = TextEditingController();
    var category = AiSettingsCubit.categories.first;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create AI scenario'),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Scenario name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                AppDropdownWidget<String>(
                  value: category,
                  items: AiSettingsCubit.categories,
                  itemBuilder: (item) => item,
                  onChanged: (value) {
                    if (value != null) setState(() => category = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().length >= 3) {
                  Navigator.pop(
                    dialogContext,
                    (controller.text.trim(), category),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) {
      await context
          .read<AiSettingsCubit>()
          .createScenario(result.$1, result.$2);
    }
  }

  Future<void> _addQuestion(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add qualifying question'),
        content: SizedBox(
          width: 440,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'What should the AI ask?',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete scenario?'),
        content: Text('“$name” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.errorColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AiSettingsCubit>().deleteSelected();
    }
  }
}
