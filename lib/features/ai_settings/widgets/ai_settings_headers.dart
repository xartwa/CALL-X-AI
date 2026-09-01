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
  });

  final bool hasUnsavedChanges;
  final bool isSaving;
  final bool isConfigured;
  final String engineLabel;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isConfigured ? const Color(0xFF10B981) : context.colors.errorColor;
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
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isConfigured ? 'VOICE ENGINE ONLINE' : 'VOICE ENGINE OFFLINE',
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          if (engineLabel.isNotEmpty) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '• $engineLabel',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.darkGreyColor,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            tooltip: 'Refresh from server',
            onPressed: isSaving ? null : onRefresh,
            icon: const Icon(CupertinoIcons.refresh, size: 16),
          ),
          OutlinedButton.icon(
            onPressed: hasUnsavedChanges && !isSaving ? onReset : null,
            icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 14),
            label: const Text('RESET'),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: hasUnsavedChanges && !isSaving ? onSave : null,
            icon: isSaving
                ? const AppLoadingIndicator(size: 15, color: Colors.white)
                : const Icon(
                    CupertinoIcons.cloud_upload_fill,
                    size: 14,
                    color: Colors.white,
                  ),
            label: Text(isSaving ? 'SAVING...' : 'SAVE & GO LIVE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
