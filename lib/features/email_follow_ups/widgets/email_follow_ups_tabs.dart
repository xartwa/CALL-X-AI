import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';

class EmailFollowUpsTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final int sentCount;
  final int templatesCount;

  const EmailFollowUpsTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.sentCount,
    required this.templatesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          height: 45,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius - 2),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : context.colors.mediumGreyColor.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSegmentTab(
                context: context,
                index: 0,
                label: 'Sent History',
                count: sentCount,
                icon: CupertinoIcons.clock_fill,
                isSelected: selectedTab == 0,
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _buildSegmentTab(
                context: context,
                index: 1,
                label: 'Email Templates',
                count: templatesCount,
                icon: CupertinoIcons.doc_plaintext,
                isSelected: selectedTab == 1,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTab({
    required BuildContext context,
    required int index,
    required String label,
    required int count,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => onTabChanged(index),
      borderRadius: BorderRadius.circular(ThemeConstants.boxRadius - 4),
      mouseCursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? activeColor
                  : (isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? activeColor
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? activeColor
                      : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
