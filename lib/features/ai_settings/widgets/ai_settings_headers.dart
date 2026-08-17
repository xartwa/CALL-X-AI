import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiSettingsHeaders extends StatelessWidget {
  final bool hasUnsavedChanges;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const AiSettingsHeaders({
    super.key,
    required this.hasUnsavedChanges,
    required this.isSaving,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? Colors.white10 : context.colors.lightGreyColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Engine Operational Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'VOICE ENGINE STATUS: OPERATIONAL',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• Cartesia Sonic & GPT-4o Connected',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: context.colors.darkGreyColor,
                ),
              ),
            ],
          ),

          // Actions: Reset + Save All Changes
          Row(
            children: [
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise,
                      size: 14),
                  label: const Text(
                    'RESET DEFAULTS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : context.colors.lightGreyColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: hasUnsavedChanges && !isSaving ? onSave : null,
                  icon: isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(CupertinoIcons.floppy_disk,
                          size: 14, color: Colors.white),
                  label: Text(
                    isSaving ? 'SAVING...' : 'SAVE ALL CHANGES',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
