import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';

import 'package:callx_ai/features/ai_settings/domain/entities/ai_scenario.dart';
import 'package:callx_ai/features/ai_settings/widgets/ai_delete_dialog.dart';
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. LEFT PANEL: SCENARIOS LIST (width 260)
        Container(
          width: 260,
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
              // Sidebar Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scenarios',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    InkWell(
                      onTap: state.isBusy ? null : () => _create(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          CupertinoIcons.plus,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scenarios List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: state.scenarios.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = state.scenarios[index];
                    final isSelected = item.id == draft.id;

                    return InkWell(
                      onTap: state.hasUnsavedChanges
                          ? null
                          : () => cubit.selectScenario(item.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: item.isActive
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? primaryColor
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black87),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.isActive ? 'Active' : 'Paused',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: context.colors.darkGreyColor,
                                        ),
                                      ),
                                      if (item.isCartesiaSynced) ...[
                                        const SizedBox(width: 5),
                                        const Text(
                                          '• Synced',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 2. RIGHT PANEL: SCENARIO EDITOR (Expanded)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Editor Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            draft.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Scenario-specific instructions for outbound calls.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: draft.isCartesiaSynced
                                      ? const Color(0xFF10B981)
                                          .withValues(alpha: 0.12)
                                      : Colors.amber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  draft.isCartesiaSynced
                                      ? 'Managed Agent: ${draft.cartesiaAgentId}'
                                      : 'Auto-syncs on save',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: draft.isCartesiaSynced
                                        ? const Color(0xFF10B981)
                                        : Colors.amber[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (!draft.isCartesiaSynced) ...[
                          SizedBox(
                            height: 38,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF10B981),
                                side: const BorderSide(
                                    color: Color(0xFF10B981)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                              ),
                              onPressed: state.isBusy
                                  ? null
                                  : () => cubit.syncManagedAgent(draft.id),
                              icon: const Icon(
                                  CupertinoIcons.arrow_2_circlepath,
                                  size: 14),
                              label: const Text(
                                'Sync Agent',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  isDark ? Colors.white : Colors.black87,
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22),
                            ),
                            onPressed: state.isBusy
                                ? null
                                : () => _duplicate(context, draft),
                            child: const Text(
                              'Duplicate',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF87171),
                              backgroundColor: const Color(0xFFF87171)
                                  .withValues(alpha: 0.06),
                              side: BorderSide(
                                color: const Color(0xFFF87171)
                                    .withValues(alpha: 0.45),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 26),
                            ),
                            onPressed: state.isBusy || draft.isDefaultInbound
                                ? null
                                : () => _delete(context, draft.name),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 18),

                // SCENARIO NAME + ACTIVE TOGGLE
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
                            hintText: 'e.g. Warm lead follow-up',
                            onChanged: (value) => cubit.updateDraft(
                              (current) => current.copyWith(name: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: draft.isActive
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              draft.isActive ? 'Active' : 'Paused',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: draft.isActive
                                    ? const Color(0xFF10B981)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Switch.adaptive(
                          value: draft.isActive,
                          onChanged: draft.isDefaultInbound
                              ? null
                              : (value) => cubit.updateDraft(
                                    (current) =>
                                        current.copyWith(isActive: value),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // OPENING GREETING & HOOK
                const SettingsLabel('OPENING GREETING & HOOK'),
                const SizedBox(height: 4),
                Text(
                  'The first sentence the AI speaks as soon as the recipient answers.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.colors.darkGreyColor,
                  ),
                ),
                const SizedBox(height: 8),
                DraftTextField(
                  value: draft.openingGreeting,
                  minLines: 3,
                  maxLines: 5,
                  hintText:
                      'e.g. Hi there! This is Maria calling from Dynamica Design. How are you today?',
                  onChanged: (value) => cubit.updateDraft(
                    (current) => current.copyWith(openingGreeting: value),
                  ),
                ),
                const SizedBox(height: 24),

                // QUALIFYING QUESTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SettingsLabel(
                      'QUALIFYING QUESTIONS · ${draft.qualifyingQuestions.length}',
                    ),
                    SizedBox(
                      height: 38,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.45),
                          ),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20),
                        ),
                        onPressed: () => _addQuestion(context),
                        icon: const Icon(CupertinoIcons.plus, size: 14),
                        label: const Text(
                          'Add question',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 12),

                if (draft.qualifyingQuestions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF131C2E)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No qualifying questions added yet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: draft.qualifyingQuestions.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final list = List<String>.from(draft.qualifyingQuestions);
                      final item = list.removeAt(oldIndex);
                      list.insert(newIndex, item);
                      cubit.updateDraft(
                        (c) => c.copyWith(qualifyingQuestions: list),
                      );
                    },
                    itemBuilder: (context, i) {
                      final q = draft.qualifyingQuestions[i];
                      final occurrence = draft.qualifyingQuestions
                          .take(i)
                          .where((item) => item == q)
                          .length;
                      return Container(
                        key: ValueKey('q_${draft.id}_${q}_$occurrence'),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131C2E)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: i,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  child: Icon(
                                    Icons.drag_indicator_rounded,
                                    size: 18,
                                    color: context.colors.darkGreyColor
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                q,
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.chevron_up,
                                  size: 14),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              tooltip: 'Move Up',
                              onPressed: i > 0
                                  ? () {
                                      final list = List<String>.from(
                                          draft.qualifyingQuestions);
                                      final item = list.removeAt(i);
                                      list.insert(i - 1, item);
                                      cubit.updateDraft(
                                        (c) => c.copyWith(
                                            qualifyingQuestions: list),
                                      );
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.chevron_down,
                                  size: 14),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              tooltip: 'Move Down',
                              onPressed: i < draft.qualifyingQuestions.length - 1
                                  ? () {
                                      final list = List<String>.from(
                                          draft.qualifyingQuestions);
                                      final item = list.removeAt(i);
                                      list.insert(i + 1, item);
                                      cubit.updateDraft(
                                        (c) => c.copyWith(
                                            qualifyingQuestions: list),
                                      );
                                    }
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.pencil,
                                size: 15,
                                color: primaryColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              tooltip: 'Edit Question',
                              onPressed: () => _editQuestion(
                                context,
                                cubit,
                                i,
                                q,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.trash,
                                size: 15,
                                color: context.colors.errorColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              tooltip: 'Delete Question',
                              onPressed: () async {
                                final confirm = await AiDeleteDialog.show(
                                  context,
                                  title: 'Delete Question',
                                  message:
                                      'Are you sure you want to delete this question? This action cannot be undone.',
                                  confirmLabel: 'Delete',
                                  cancelLabel: 'Cancel',
                                );
                                if (confirm == true && context.mounted) {
                                  final list = List<String>.from(
                                    draft.qualifyingQuestions,
                                  )..removeAt(i);
                                  cubit.updateDraft(
                                    (c) =>
                                        c.copyWith(qualifyingQuestions: list),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(CupertinoIcons.sparkles,
                        size: 13, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      '✦ Questions run in this order, but the AI may adapt naturally to the conversation.',
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

  Future<void> _duplicate(BuildContext context, AiScenario scenario) async {
    final cubit = context.read<AiSettingsCubit>();
    await cubit.createScenario(
      '${scenario.name} (Copy)',
      scenario.category,
      scenario.openingGreeting,
      scenario.pitchSummary,
      scenario.voiceId,
    );

  }

  Future<void> _delete(BuildContext context, String name) async {
    final cubit = context.read<AiSettingsCubit>();
    final confirm = await AiDeleteDialog.show(
      context,
      title: 'Delete Scenario',
      message:
          'Are you sure you want to delete "$name"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );
    if (confirm == true && context.mounted) {
      await cubit.deleteScenario();
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
                        hintStyle:
                            TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Navigator.of(dialogContext).pop(val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF334155)),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                            ),
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                Navigator.of(dialogContext)
                                    .pop(controller.text.trim());
                              }
                            },
                            child: const Text(
                              'Add question',
                              style: TextStyle(
                                fontSize: 13.5,
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
      },
    );
    if (question != null && question.isNotEmpty) {
      final current = cubit.state.draft;
      if (current != null) {
        final list = List<String>.from(current.qualifyingQuestions)
          ..add(question);
        cubit.updateDraft((c) => c.copyWith(qualifyingQuestions: list));
      }
    }
  }

  Future<void> _editQuestion(
    BuildContext context,
    AiSettingsCubit cubit,
    int index,
    String currentText,
  ) async {
    final controller = TextEditingController(text: currentText);
    final edited = await showDialog<String>(
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
                        'EDIT QUALIFYING QUESTION',
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
                        hintStyle:
                            TextStyle(fontSize: 12, color: Colors.white38),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Navigator.of(dialogContext).pop(val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF334155)),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                              ),
                            ),
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                Navigator.of(dialogContext)
                                    .pop(controller.text.trim());
                              }
                            },
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 13.5,
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
      },
    );
    if (edited != null && edited.isNotEmpty && context.mounted) {
      final current = cubit.state.draft;
      if (current != null && index < current.qualifyingQuestions.length) {
        final list = List<String>.from(current.qualifyingQuestions);
        list[index] = edited;
        cubit.updateDraft((c) => c.copyWith(qualifyingQuestions: list));
      }
    }
  }
}
