import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../theme/app_colors.dart';

class AppointmentsNavTabs extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;
  final int pendingRequestsCount;

  const AppointmentsNavTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    required this.pendingRequestsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          height: 44,
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
              _buildTab(
                context: context,
                index: 0,
                label: 'Calendar',
                icon: CupertinoIcons.calendar,
                isSelected: activeTab == 0,
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context: context,
                index: 1,
                label: 'Requests',
                icon: CupertinoIcons.doc_text,
                badgeCount: pendingRequestsCount,
                isSelected: activeTab == 1,
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _buildTab(
                context: context,
                index: 2,
                label: 'Availability',
                icon: CupertinoIcons.clock,
                isSelected: activeTab == 2,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    int? badgeCount,
  }) {
    final activeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => onTabChanged(index),
      borderRadius: BorderRadius.circular(ThemeConstants.boxRadius - 4),
      mouseCursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius - 4),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
