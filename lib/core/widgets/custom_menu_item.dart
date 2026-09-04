import 'package:flutter/material.dart';
import 'package:callx_ai/theme/app_colors.dart';

class CustomMenuItem extends StatelessWidget {
  const CustomMenuItem({
    super.key,
    required this.isCurrentIndex,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isCurrentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic minimalist styling
    final textColor = isCurrentIndex ? Colors.white : Colors.white54;

    final textWeight = isCurrentIndex ? FontWeight.w500 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor:
          isDark ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 13.0),
        child: Row(
          children: [
            // Minimalist animated active dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: isCurrentIndex ? 4 : 0,
              height: isCurrentIndex ? 10 : 0,
              margin: EdgeInsets.only(right: isCurrentIndex ? 7 : 0),
              decoration: BoxDecoration(
                color:isDark ?   context.colors.primaryLightColor : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Minimalist Icon
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(color: textColor),
              child: Icon(
                icon,
                size: 15,
                color: textColor,
              ),
            ),

            const SizedBox(width: 12),

            // Animated typography
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontWeight: textWeight,
                  color: textColor,
                  fontSize: 11.5,
                  letterSpacing: 1.5,
                ),
                child: Text(title.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
