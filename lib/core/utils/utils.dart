import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Fallback used by table cells when a value is missing.
const String tableDash = '-';

/// Single shared fallback so every table renders empty data the same way.
extension TableCellText on Object? {
  String get orDash {
    final value = this?.toString().trim() ?? '';
    return value.isEmpty ? tableDash : value;
  }
}

class AppUtils {
  static TextDirection getDirection(String? text) {
    if (text == null || text.trim().isEmpty) return TextDirection.ltr;
    final rtlRegex =
        RegExp(r'[\u0600-\u06FF\u0750-\u077F\u0590-\u05FF\uFE70-\uFEFF]');
    return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  static String fixRtlPunctuation(String text) {
    if (text.isEmpty) return text;
    // Check if the text contains RTL (Persian/Arabic) characters
    final hasRtl =
        RegExp(r'[\u0600-\u06FF\u0750-\u077F\u0590-\u05FF\uFE70-\uFEFF]')
            .hasMatch(text);
    if (hasRtl) {
      // If it ends with English/numbers and punctuation (like dot), append RTL mark to force the dot to the end of RTL layout
      if (RegExp(r'[a-zA-Z0-9\s\.\!\?\:\)\(]$').hasMatch(text)) {
        return '$text\u200F';
      }
    } else {
      // If LTR, append LTR mark to ensure dots stay on the correct side
      if (RegExp(r'[\.\!\?\:\)\(]$').hasMatch(text)) {
        return '$text\u200E';
      }
    }
    return text;
  }

  static void showSnackBar(
      {required BuildContext context,
      String? title = "",
      String? extraMessage,
      required ToastificationType toastificationType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final toastBgColor = isDark ? const Color(0xFF172033) : Colors.white;
    final toastTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final toastDescColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final accent = switch (toastificationType) {
      ToastificationType.success => context.colors.successColor,
      ToastificationType.warning => context.colors.warningColor,
      ToastificationType.error => context.colors.errorColor,
      _ => context.colors.infoColor,
    };

    toastification.show(
      context: context,
      type: toastificationType,
      style: ToastificationStyle.flat,
      title: title != null && title.isNotEmpty
          ? Text(
              fixRtlPunctuation(title),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: toastTextColor,
              ),
            )
          : null,
      description: extraMessage != null && extraMessage.trim().isNotEmpty
          ? Text(
              fixRtlPunctuation(extraMessage),
              style: TextStyle(
                fontSize: 12,
                color: toastDescColor,
              ),
            )
          : null,
      backgroundColor: toastBgColor,
      primaryColor: accent,
      foregroundColor: toastTextColor,
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: accent.withValues(alpha: .22)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.all(16),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      showIcon: true,
      direction: getDirection(extraMessage ?? title),
      dragToClose: true,
    );
  }
}
