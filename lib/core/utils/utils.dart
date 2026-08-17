import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

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
    final toastBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final toastTextColor = isDark ? Colors.white : Colors.black87;
    final toastDescColor = isDark ? Colors.white70 : Colors.black54;

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
      borderRadius: BorderRadius.circular(12),
      alignment: Alignment.topRight, // Top right alignment is premium and clean
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: true,
      direction: getDirection(extraMessage ?? title),
      dragToClose: true,
    );
  }

  static Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = context.colors.primaryLightColor;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogTheme: DialogTheme(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: backgroundColor,
              elevation: 0,
              headerBackgroundColor: primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              dayStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: primaryColor,
              ),
              todayBackgroundColor:
                  WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
              todayForegroundColor: WidgetStateProperty.all(primaryColor),
              dayBackgroundColor:
                  WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor;
                }
                return null;
              }),
              dayForegroundColor:
                  WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  static Future<TimeOfDay?> showCustomTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = context.colors.primaryLightColor;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            brightness: isDark ? Brightness.dark : Brightness.light,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogTheme: DialogTheme(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: backgroundColor,
              elevation: 0,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: primaryColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              hourMinuteColor: context.colors.milkyColor,
              hourMinuteTextColor: isDark ? Colors.white : Colors.black87,
              dayPeriodColor: context.colors.milkyColor,
              dayPeriodTextColor: isDark ? Colors.white : Colors.black87,
              dayPeriodBorderSide: BorderSide(
                color: primaryColor.withOpacity(0.15),
                width: 1.5,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              dialHandColor: primaryColor,
              dialBackgroundColor: context.colors.milkyColor,
              dialTextColor: isDark ? Colors.white : Colors.black87,
              entryModeIconColor: primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
