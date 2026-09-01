import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AiSettingsHeaders extends StatelessWidget {
  const AiSettingsHeaders({
    super.key,
    required this.hasUnsavedChanges,
    required this.isSaving,
    required this.isConfigured,
    required this.engineLabel,
    required this.onSave,
    required this.onReset,
    required this.onRefresh,
    this.onNewScenario,
  });

  final bool hasUnsavedChanges;
  final bool isSaving;
  final bool isConfigured;
  final String engineLabel;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onRefresh;
  final VoidCallback? onNewScenario;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor =
        isConfigured ? const Color(0xFF10B981) : AppColors.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Save & Go Live + Reset Draft + New Scenario
          Row(
            children: [
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasUnsavedChanges
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                  onPressed: hasUnsavedChanges && !isSaving ? onSave : null,
                  icon: isSaving
                      ? const AppLoadingIndicator(size: 14, color: Colors.white)
                      : const Icon(
                          CupertinoIcons.cloud_upload_fill,
                          size: 15,
                          color: Colors.white,
                        ),
                  label: Text(
                    isSaving ? 'SAVING...' : 'SAVE & GO LIVE',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
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
                  onPressed: hasUnsavedChanges && !isSaving ? onReset : null,
                  icon: Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    size: 14,
                    color: hasUnsavedChanges
                        ? context.colors.warningColor
                        : context.colors.darkGreyColor,
                  ),
                  label: Text(
                    'RESET DRAFT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasUnsavedChanges
                          ? (isDark ? Colors.white : Colors.black87)
                          : context.colors.darkGreyColor,
                    ),
                  ),
                ),
              ),
              if (onNewScenario != null) ...[
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
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
                    onPressed: isSaving ? null : onNewScenario,
                    icon: Icon(
                      CupertinoIcons.plus,
                      size: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'NEW SCENARIO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Right: Voice Engine Online status badge + Refresh Button
          Row(
            children: [
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConfigured
                          ? 'VOICE ENGINE ONLINE'
                          : 'VOICE ENGINE OFFLINE',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (engineLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• $engineLabel',
                        style: TextStyle(
                          color: context.colors.darkGreyColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: isSaving ? null : onRefresh,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : context.colors.lightGreyColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.refresh,
                      size: 15,
                      color: context.colors.darkGreyColor,
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

