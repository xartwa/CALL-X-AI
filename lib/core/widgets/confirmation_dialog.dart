import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? confirmButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel,
    this.cancelLabel,
    this.icon = CupertinoIcons.trash,
    this.iconColor,
    this.iconBackgroundColor,
    this.confirmButtonColor,
    this.onCancel,
  });

  /// Static helper to display the confirmation dialog.
  /// Returns `true` if confirmed, `false` or `null` otherwise.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String? confirmLabel,
    String? cancelLabel,
    IconData icon = CupertinoIcons.trash,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? confirmButtonColor,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackgroundColor,
          confirmButtonColor: confirmButtonColor,
          onCancel: onCancel,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? context.colors.errorColor;
    final resolvedConfirmButtonColor =
        confirmButtonColor ?? context.colors.errorColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default background color for circle icon is 10% opacity of iconColor
    final finalIconBgColor =
        iconBackgroundColor ?? resolvedIconColor.withValues(alpha: 0.1);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: finalIconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: resolvedIconColor,
                  size: 32,
                ),
              ),
              SizedBox(height: 20),
              // Title
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              // Message
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () {
                          if (onCancel != null) {
                            onCancel!();
                          }
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.colors.lightGreyColor,
                          ),
                          foregroundColor:
                              isDark ? Colors.white : Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          cancelLabel ?? 'Cancel',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Confirm Button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirm();
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: resolvedConfirmButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmLabel ?? 'Confirm',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
  }
}
