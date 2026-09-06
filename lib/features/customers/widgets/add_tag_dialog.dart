import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/models/tag_model.dart';
import 'package:callx_ai/core/widgets/app_text_field_widget.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';

class AddTagDialog extends StatefulWidget {
  final List<String> existingTags;

  const AddTagDialog({
    super.key,
    this.existingTags = const [],
  });

  static Future<TagModel?> show(BuildContext context,
      {List<String> existingTags = const []}) {
    return showDialog<TagModel>(
      context: context,
      builder: (context) => AddTagDialog(existingTags: existingTags),
    );
  }

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final _tagCtrl = TextEditingController();
  Color? _selectedColor;

  static const _defaultColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
  ];

  @override
  void dispose() {
    _tagCtrl.dispose();
    super.dispose();
  }

  void _submitCustom() {
    final clean = _tagCtrl.text.trim();
    if (clean.isNotEmpty) {
      final state = context.read<WorkspaceSettingsCubit>().state;
      final serverColors = state.tagColors;
      final colors = serverColors.isNotEmpty ? serverColors : _defaultColors;
      final color = _selectedColor ?? colors.first;

      Navigator.pop(
        context,
        TagModel(
          id: '',
          label: clean,
          color: color,
        ),
      );
    }
  }

  void _submitPreset(TagModel tag) {
    Navigator.pop(context, tag);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final state = context.watch<WorkspaceSettingsCubit>().state;
    final popularTags = state.customTags;
    final serverColors = state.tagColors;
    final colors = serverColors.isNotEmpty ? serverColors : _defaultColors;

    _selectedColor ??= colors.first;

    final availablePresets = popularTags
        .where((p) => !widget.existingTags.contains(p.label))
        .toList();

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSlateColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ADD TAG',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
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
            const SizedBox(height: 20),

            // Custom Tag Input
            Text(
              'CUSTOM TAG NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.colors.darkGreyColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextFieldWidget(
                    controller: _tagCtrl,
                    hintText: 'e.g. VIP Client, Vancouver, GC...',
                    showBorder: true,
                    borderColor: context.colors.lightGreyColor,
                    fillColor: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    onFieldSubmitted: (_) => _submitCustom(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _submitCustom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primaryLightColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tag Color Picker
            Text(
              'TAG COLOR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.colors.darkGreyColor,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: isSelected
                        ? Icon(CupertinoIcons.checkmark_alt,
                            color: color, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Preset suggestions
            if (availablePresets.isNotEmpty) ...[
              Text(
                'POPULAR SUGGESTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: context.colors.darkGreyColor,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availablePresets.map((presetModel) {
                      final preset = presetModel.label;
                      final color = presetModel.color;
                      return InkWell(
                        onTap: () => _submitPreset(presetModel),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                color.withValues(alpha: isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 13, color: color),
                              const SizedBox(width: 4),
                              Text(
                                preset,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
