import 'package:flutter/material.dart';

class SpacedText extends StatelessWidget {
  final String text;
  final double letterSpacing;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SpacedText({
    super.key,
    required this.text,
    this.letterSpacing = 10.0,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: style?.copyWith(
            letterSpacing: letterSpacing,
            color: color ?? style?.color,
            fontWeight: fontWeight ?? style?.fontWeight,
            fontSize: fontSize ?? style?.fontSize,
          ) ??
          TextStyle(
            letterSpacing: letterSpacing,
            color: color ?? Theme.of(context).colorScheme.onPrimary,
            fontWeight: fontWeight ?? FontWeight.w400,
            fontSize: fontSize,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
