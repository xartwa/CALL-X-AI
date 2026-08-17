import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class WorkspaceSettingsDialog extends StatefulWidget {
  const WorkspaceSettingsDialog({super.key});

  @override
  State<WorkspaceSettingsDialog> createState() =>
      _WorkspaceSettingsDialogState();
}

class _WorkspaceSettingsDialogState extends State<WorkspaceSettingsDialog> {
  late List<TagModel> leadStatuses;
  late List<TagModel> leadPriorities;
  late List<TagModel> leadQualities;
  late List<TagModel> callStatuses;
  late List<TagModel> customTags;

  @override
  void initState() {
    super.initState();
    final state = context.read<WorkspaceSettingsCubit>().state;
    leadStatuses = List.from(state.leadStatuses);
    leadPriorities = List.from(state.leadPriorities);
    leadQualities = List.from(state.leadQualities);
    callStatuses = List.from(state.callStatuses);
    customTags = List.from(state.customTags);
  }

  void _saveChanges() {
    final cubit = context.read<WorkspaceSettingsCubit>();
    cubit.setAllSettings(
      leadStatuses: leadStatuses,
      leadPriorities: leadPriorities,
      leadQualities: leadQualities,
      callStatuses: callStatuses,
      customTags: customTags,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 650,
        height: 750,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    const Text(
                      'WORKSPACE CONFIGURATION',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  children: [
                    _buildSection(
                      context,
                      title: 'Pipeline Stages',
                      tags: leadStatuses,
                      onAdd: (tag) => setState(() => leadStatuses.add(tag)),
                      onRemove: (tag) =>
                          setState(() => leadStatuses.remove(tag)),
                    ),
                    const SizedBox(height: 40),
                    _buildSection(
                      context,
                      title: 'Custom Tags',
                      tags: customTags,
                      onAdd: (tag) => setState(() => customTags.add(tag)),
                      onRemove: (tag) => setState(() => customTags.remove(tag)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: SizedBox(
                  height: 48,
                  width: MediaQuery.sizeOf(context).width,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primaryLightColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('SAVE CHANGES',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<TagModel> tags,
    required ValueChanged<TagModel> onAdd,
    required ValueChanged<TagModel> onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            InkWell(
              onTap: () => _showAddTagDialog(context, title, onAdd),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.colors.primaryLightColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.add,
                        size: 14, color: context.colors.primaryLightColor),
                    const SizedBox(width: 4),
                    Text(
                      'ADD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map((tag) => _buildTagChip(context, tag, () => onRemove(tag)))
              .toList(),
        ),
        if (tags.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('No tags yet.',
                style: TextStyle(
                    color: context.colors.darkGreyColor, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildTagChip(
      BuildContext context, TagModel tag, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: tag.color.withAlpha(15),
        border: Border.all(color: tag.color.withAlpha(50)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tag.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tag.color,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(CupertinoIcons.xmark,
                  size: 12, color: tag.color.withAlpha(150)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(
      BuildContext context, String sectionTitle, ValueChanged<TagModel> onAdd) {
    String label = '';
    Color selectedColor = const Color(0xFF3B82F6);

    final colors = const [
      Color(0xFFEF4444), // Red
      Color(0xFFF97316), // Orange
      Color(0xFFF59E0B), // Amber
      Color(0xFF10B981), // Green
      Color(0xFF3B82F6), // Blue
      Color(0xFF6366F1), // Indigo
      Color(0xFF8B5CF6), // Violet
      Color(0xFFEC4899), // Pink
      Color(0xFF64748B), // Slate
    ];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 80 : 30),
                        blurRadius: 40,
                        offset: const Offset(0, 15))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ADD ${sectionTitle.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: Icon(
                            CupertinoIcons.clear_thick,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('TAG LABEL',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: context.colors.darkGreyColor)),
                    const SizedBox(height: 8),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        hintText: 'e.g. VIP Client',
                        hintStyle: TextStyle(
                            color: context.colors.darkGreyColor.withAlpha(150),
                            fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: context.colors.primaryLightColor,
                                width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      onChanged: (val) => label = val,
                    ),
                    const SizedBox(height: 28),
                    Text('TAG COLOR',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: context.colors.darkGreyColor)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 1.0),
                            ),
                            child: isSelected
                                ? Icon(CupertinoIcons.checkmark_alt,
                                    color: color, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (label.trim().isNotEmpty) {
                            onAdd(TagModel(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              label: label.trim(),
                              color: selectedColor,
                            ));
                            Navigator.of(ctx).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primaryLightColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ADD TAG',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
