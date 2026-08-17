import 'package:flutter/material.dart';
import 'package:callx_ai/theme/app_text_theme.dart';

Widget tagChipWidget({
  required BuildContext context,
  required String tagName,
  required Color customColor,
}) {
  return Container(
    alignment: AlignmentDirectional.center,
    height: 24,
    decoration: BoxDecoration(
      color: customColor.withOpacity(.10),
      borderRadius: BorderRadius.circular(20.0),
      border: Border.all(color: customColor, width: 1.0),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Text(
      tagName,
      style: AppTextTheme.bodyMedium.copyWith(
          color: customColor, fontSize: 11.0, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.center,
    ),
  );
}
