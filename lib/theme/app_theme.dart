import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colors = AppColors.light;
    final base = ThemeData(
      hoverColor: Colors.transparent,
      fontFamily: ThemeConstants.appFont,
      colorScheme: ColorScheme.light(
        primary: colors.primaryLightColor,
        onPrimary: colors.whiteColor, // Added to fix card backgrounds
        surface: colors.whiteColor,
        onSurface: colors.blackColor,
        secondary: colors.lightBlueColor,
        error: colors.errorColor,
      ),
      scaffoldBackgroundColor: colors.scaffoldBackgroundColor,
      useMaterial3: false,
      scrollbarTheme: ScrollbarThemeData(
        trackVisibility: WidgetStatePropertyAll(true),
        thumbColor: WidgetStatePropertyAll(colors.lightGreyColor),
        thickness: WidgetStatePropertyAll(6),
        mainAxisMargin: 15,
        crossAxisMargin: 5,
        minThumbLength: 20,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.primaryLightColor,
          side: BorderSide(color: colors.primaryLightColor),
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryLightColor,
          foregroundColor: colors.whiteColor,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
      ],
    );
    return base.copyWith(
      textTheme: AppTypography.apply(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }

  static ThemeData dark() {
    final colors = AppColors.dark;
    final base = ThemeData(
      hoverColor: Colors.transparent,
      fontFamily: ThemeConstants.appFont,
      colorScheme: ColorScheme.dark(
        primary: colors.primaryLightColor,
        onPrimary: colors.whiteColor, // Added to fix card backgrounds
        surface: colors.whiteColor,
        onSurface: colors.blackColor,
        secondary: colors.lightBlueColor,
        error: colors.errorColor,
      ),
      scaffoldBackgroundColor: colors.scaffoldBackgroundColor,
      useMaterial3: false,
      scrollbarTheme: ScrollbarThemeData(
        trackVisibility: WidgetStatePropertyAll(true),
        thumbColor: WidgetStatePropertyAll(colors.lightGreyColor),
        thickness: WidgetStatePropertyAll(6),
        mainAxisMargin: 15,
        crossAxisMargin: 5,
        minThumbLength: 20,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.primaryLightColor,
          side: BorderSide(color: colors.primaryLightColor),
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryLightColor,
          foregroundColor: colors
              .whiteColor, // In dark mode, buttons can still use light text
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
      ],
    );
    return base.copyWith(
      textTheme: AppTypography.apply(base.textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );
  }
}
