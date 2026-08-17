import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CallsFilterTabs extends StatelessWidget {
  final String selectedStatus;
  final Map<String, int> statusCounts;
  final ValueChanged<String> onStatusChanged;

  const CallsFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.statusCounts,
    required this.onStatusChanged,
  });

  final List<String> filters = const [
    'All',
    'Completed',
    'Failed',
    'Queued',
    'Upcoming'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((filter) {
          final isSelected =
              filter.toLowerCase() == selectedStatus.toLowerCase();
          final count = statusCounts[filter] ?? 0;

          return InkWell(
            onTap: () => onStatusChanged(filter),
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (context.colors.mediumGreyColor),
                borderRadius:
                    BorderRadius.circular(ThemeConstants.buttonRadius),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? Colors.white10 : Colors.transparent),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.8,
                      color: isSelected
                          ? Colors.white
                          : (context.colors.darkGreyColor),
                    ),
                  ),
                  SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withAlpha(50)
                          : (isDark
                              ? Colors.white10
                              : Colors.black.withAlpha(15)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (context.colors.darkGreyColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
