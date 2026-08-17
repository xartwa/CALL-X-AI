import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  /// Change this number to increase or decrease every text size in the app.
  static double scale = 1.0;

  static TextTheme apply(TextTheme base) {
    final theme =
        base.apply(fontSizeFactor: scale, fontFamily: ThemeConstants.appFont);
    const tabular = [FontFeature.tabularFigures()];

    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(fontFeatures: tabular),
      displayMedium: theme.displayMedium?.copyWith(fontFeatures: tabular),
      displaySmall: theme.displaySmall?.copyWith(fontFeatures: tabular),
      headlineLarge: theme.headlineLarge?.copyWith(fontFeatures: tabular),
      headlineMedium: theme.headlineMedium?.copyWith(fontFeatures: tabular),
      headlineSmall: theme.headlineSmall?.copyWith(fontFeatures: tabular),
      titleLarge: theme.titleLarge?.copyWith(fontFeatures: tabular),
      titleMedium: theme.titleMedium?.copyWith(fontFeatures: tabular),
      titleSmall: theme.titleSmall?.copyWith(fontFeatures: tabular),
      bodyLarge: theme.bodyLarge?.copyWith(fontFeatures: tabular),
      bodyMedium: theme.bodyMedium?.copyWith(fontFeatures: tabular),
      bodySmall: theme.bodySmall?.copyWith(fontFeatures: tabular),
      labelLarge: theme.labelLarge?.copyWith(fontFeatures: tabular),
      labelMedium: theme.labelMedium?.copyWith(fontFeatures: tabular),
      labelSmall: theme.labelSmall?.copyWith(fontFeatures: tabular),
    );
  }
}
