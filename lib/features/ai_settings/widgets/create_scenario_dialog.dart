import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/features/ai_settings/cubit/ai_settings_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateScenarioDialog extends StatefulWidget {
  const CreateScenarioDialog({super.key});

  static Future<(String, String)?> show(BuildContext context) =>
      showDialog<(String, String)>(
        barrierDismissible: false,
        context: context,
        builder: (context) => const CreateScenarioDialog(),
      );

  @override
  State<CreateScenarioDialog> createState() => _CreateScenarioDialogState();
}

class _CreateScenarioDialogState extends State<CreateScenarioDialog> {
  late final TextEditingController _nameCtrl;
  String _selectedCategory = AiSettingsCubit.categories.first;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _nameCtrl.addListener(() {
      final isNotEmpty = _nameCtrl.text.trim().length >= 3;
      if (isNotEmpty != _isDirty) {
        setState(() => _isDirty = isNotEmpty);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.length >= 3) {
      Navigator.pop(context, (name, _selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
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
            // Top Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        CupertinoIcons.waveform,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CREATE AI SCENARIO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(CupertinoIcons.clear, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Field: Scenario Name
            Text(
              'SCENARIO NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 46,
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
              child: Center(
                child: TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    hintText: 'e.g. Inbound Support & Appointment Triage',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: context.colors.darkGreyColor,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Field: Category
            Text(
              'SCENARIO CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            AppDropdownWidget<String>(
              value: _selectedCategory,
              items: AiSettingsCubit.categories,
              height: 46,
              itemBuilder: (category) => category,
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 26),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : context.colors.lightGreyColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonRadius,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
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
                        backgroundColor: _isDirty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonRadius,
                          ),
                        ),
                      ),
                      onPressed: _isDirty ? _submit : null,
                      icon: const Icon(
                        CupertinoIcons.plus_circle_fill,
                        size: 15,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'CREATE SCENARIO',
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
    );
  }
}
