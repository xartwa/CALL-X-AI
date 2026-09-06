import 'package:flutter/material.dart';

class CustomTagWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;
  final double? iconSize;

  const CustomTagWidget({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 8 : 12,
        vertical: 4.5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? 11.5,
              color: color,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label.trim().toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
