import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryLightColor;
  final Color lightBlueColor;
  final Color skyBlueColor;
  final Color queuedColor;
  final Color scaffoldBackgroundColor;
  final Color whiteColor;
  final Color blackColor;
  final Color infoColor;
  final Color errorColor;
  final Color darkGreyColor;
  final Color mediumGreyColor;
  final Color milkyColor;
  final Color lightGreyColor;
  final Color successColor;
  final Color warningColor;

  const AppColorsExtension({
    required this.primaryLightColor,
    required this.lightBlueColor,
    required this.skyBlueColor,
    required this.queuedColor,
    required this.scaffoldBackgroundColor,
    required this.whiteColor,
    required this.blackColor,
    required this.infoColor,
    required this.errorColor,
    required this.darkGreyColor,
    required this.mediumGreyColor,
    required this.milkyColor,
    required this.lightGreyColor,
    required this.successColor,
    required this.warningColor,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primaryLightColor,
    Color? lightBlueColor,
    Color? skyBlueColor,
    Color? queuedColor,
    Color? scaffoldBackgroundColor,
    Color? whiteColor,
    Color? blackColor,
    Color? infoColor,
    Color? errorColor,
    Color? darkGreyColor,
    Color? mediumGreyColor,
    Color? milkyColor,
    Color? lightGreyColor,
    Color? successColor,
    Color? warningColor,
  }) {
    return AppColorsExtension(
      primaryLightColor: primaryLightColor ?? this.primaryLightColor,
      lightBlueColor: lightBlueColor ?? this.lightBlueColor,
      skyBlueColor: skyBlueColor ?? this.skyBlueColor,
      queuedColor: queuedColor ?? this.queuedColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      whiteColor: whiteColor ?? this.whiteColor,
      blackColor: blackColor ?? this.blackColor,
      infoColor: infoColor ?? this.infoColor,
      errorColor: errorColor ?? this.errorColor,
      darkGreyColor: darkGreyColor ?? this.darkGreyColor,
      mediumGreyColor: mediumGreyColor ?? this.mediumGreyColor,
      milkyColor: milkyColor ?? this.milkyColor,
      lightGreyColor: lightGreyColor ?? this.lightGreyColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryLightColor:
          Color.lerp(primaryLightColor, other.primaryLightColor, t)!,
      lightBlueColor: Color.lerp(lightBlueColor, other.lightBlueColor, t)!,
      skyBlueColor: Color.lerp(skyBlueColor, other.skyBlueColor, t)!,
      queuedColor: Color.lerp(queuedColor, other.queuedColor, t)!,
      scaffoldBackgroundColor: Color.lerp(
          scaffoldBackgroundColor, other.scaffoldBackgroundColor, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      blackColor: Color.lerp(blackColor, other.blackColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      darkGreyColor: Color.lerp(darkGreyColor, other.darkGreyColor, t)!,
      mediumGreyColor: Color.lerp(mediumGreyColor, other.mediumGreyColor, t)!,
      milkyColor: Color.lerp(milkyColor, other.milkyColor, t)!,
      lightGreyColor: Color.lerp(lightGreyColor, other.lightGreyColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
    );
  }
}

class AppColors {
  const AppColors._();

  static const light = AppColorsExtension(
    primaryLightColor: Color(0XFF1d4ed8),
    lightBlueColor: Color(0XFF818CF8), // Softer Indigo
    skyBlueColor:
        Color(0XFFF8FAFC), // Slate 50 - Very light background for contrast
    queuedColor: Color(0XFF06B6D4), // Modern Cyan
    scaffoldBackgroundColor:
        Color(0XFFF1F5F9), // Slate 100 - Better app background
    whiteColor: Color(0XFFFFFFFF), // Crisp white
    blackColor: Color(0XFF0F172A), // Slate 900 - Soft premium black
    infoColor: Color(0XFF3B82F6), // Blue 500
    errorColor: Color(0XFFEF4444), // Red 500
    darkGreyColor: Color(0XFF64748B), // Slate 500
    mediumGreyColor: Color(0XFFE2E8F0), // Slate 200 - Borders
    milkyColor: Color(0XFFF8FAFC), // Slate 50
    lightGreyColor: Color(0XFFCBD5E1), // Slate 300
    successColor: Color(0XFF10B981), // Emerald 500
    warningColor: Color(0XFFF59E0B), // Amber 500
  );

  static const dark = AppColorsExtension(
    primaryLightColor: Color(0XFF1d4ed8), // Indigo 500 - Pops nicely on dark
    lightBlueColor: Color(0XFFA5B4FC), // Indigo 300
    skyBlueColor: Color(0XFF1E293B), // Slate 800 - Good for headers
    queuedColor: Color(0XFF22D3EE), // Cyan 400
    scaffoldBackgroundColor: Color(0XFF0B0F17), // Deep midnight
    whiteColor: Color(0XFF151B26), // Soft midnight card background
    blackColor: Color(0XFFF8FAFC), // Slate 50 - Almost white text
    infoColor: Color(0XFF60A5FA), // Blue 400
    errorColor: Color(0XFFF87171), // Red 400
    darkGreyColor: Color(0XFF94A3B8), // Slate 400
    mediumGreyColor: Color(0XFF334155), // Slate 700 - Borders
    milkyColor: Color(0XFF1E293B), // Slate 800 
    lightGreyColor: Color(0XFF475569), // Slate 600
    successColor: Color(0XFF34D399), // Emerald 400
    warningColor: Color(0XFFFBBF24), // Amber 400
  );

  // Deprecated direct accessors - will be removed after full refactoring
  static const Color primaryLightColor = Color(0XFF1d4ed8);
  static const Color lightBlueColor = Color(0XFF678DFF);
  static const Color skyBlueColor = Color(0XFFEFF4FF);
  static const Color queuedColor = Color(0XFF00C9D3);
  static const Color scaffoldBackgroundColor = Color(0XFFF7F7FB);
  static const Color whiteColor = Color(0XFFFFFFFF);
  static const Color blackColor = Color(0XFF000000);
  static const Color infoColor = Color(0XFF0a84fe);
  static const Color errorColor = Color(0XFFf74242);
  static const Color darkGreyColor = Color(0XFF7A7A7A);
  static const Color mediumGreyColor = Color(0XFFF5F5F5);
  static const Color milkyColor = Color(0XFFF6F6F6);
  static const Color lightGreyColor = Color(0XFFDDDDDD);
  static const Color successColor = Color(0XFF34C759);
  static const Color warningColor = Color(0XFFFF8110);
}

extension BuildContextColors on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColors.light;
}
