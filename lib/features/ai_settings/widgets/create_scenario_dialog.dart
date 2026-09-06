import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateScenarioDialog extends StatefulWidget {
  const CreateScenarioDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) =>
      showDialog<Map<String, String>>(
        barrierDismissible: false,
        context: context,
        builder: (context) => const CreateScenarioDialog(),
      );

  @override
  State<CreateScenarioDialog> createState() => _CreateScenarioDialogState();
}

class _CreateScenarioDialogState extends State<CreateScenarioDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _greetingCtrl;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _greetingCtrl = TextEditingController(
      text:
          'Hi there! This is Skylar from CallX AI. I wanted to quickly follow up on your recent request.',
    );
    _nameCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final isNotEmpty = _nameCtrl.text.trim().length >= 3;
    if (isNotEmpty != _isDirty) {
      setState(() => _isDirty = isNotEmpty);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _greetingCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final greeting = _greetingCtrl.text.trim();
    if (name.length >= 3) {
      Navigator.pop(context, {'name': name, 'greeting': greeting});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      backgroundColor: isDark ? AppColors.darkSlateColor : Colors.white,
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
                  
                    const Text(
                      'CREATE OUTBOUND SCENARIO',
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
                    hintText: 'e.g. Cold Lead Outreach & Booking',
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

            // Field: Opening Greeting
            Text(
              'OPENING GREETING / HOOK',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 70,
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
                controller: _greetingCtrl,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  hintText: 'The phrase spoken when call connects...',
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
            const SizedBox(height: 26),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                        ),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonRadius,
                          ),
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
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        disabledBackgroundColor: isDark
                            ? Colors.white10
                            : context.colors.lightGreyColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ThemeConstants.buttonRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isDirty ? _submit : null,
                      child: const Text(
                        'Create scenario',
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
    );
  }
}
