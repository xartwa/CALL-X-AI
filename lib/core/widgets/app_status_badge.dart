import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_status_helper.dart';

class AppStatusBadge extends StatelessWidget {
  final String status;
  final Color? color;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppStatusBadge({
    super.key,
    required this.status,
    this.color,
    this.fontSize = 10.5,
    this.fontWeight = FontWeight.w700,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (status.trim().isEmpty) return const SizedBox.shrink();
    final effectiveColor = color ?? AppStatusHelper.getStatusColor(status);

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.5, vertical: 2.5),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Text(
        status.trim().toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: effectiveColor,
          letterSpacing: 0.4,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
