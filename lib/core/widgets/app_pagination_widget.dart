import 'package:flutter/material.dart';

class AppPaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const AppPaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<dynamic> _getPageNumbers() {
    List<dynamic> items = [];
    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        items.add(i);
      }
    } else {
      if (currentPage <= 3) {
        items.addAll([1, 2, 3]);
        items.add('...');
        items.addAll([totalPages - 2, totalPages - 1, totalPages]);
      } else if (currentPage >= totalPages - 2) {
        items.addAll([1, 2, 3]);
        items.add('...');
        items.addAll([totalPages - 2, totalPages - 1, totalPages]);
      } else {
        items.add(1);
        items.add('...');
        items.addAll([currentPage - 1, currentPage, currentPage + 1]);
        items.add('...');
        items.add(totalPages);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-tailored colors
    final primaryColor = theme.colorScheme.primary;
    final activeBg = isDark
        ? primaryColor.withValues(alpha: 0.2)
        : primaryColor.withValues(alpha: 0.08);
    final activeText =
        isDark ? theme.colorScheme.onPrimaryContainer : primaryColor;
    final inactiveText = isDark ? Colors.grey[400] : const Color(0xFF64748B);
    final disabledColor = isDark ? Colors.white24 : Colors.black26;

    final pageItems = _getPageNumbers();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Navigation Arrow
          _NavigationArrow(
            icon: Icons.west_rounded,
            isEnabled: currentPage > 1,
            onTap: () => onPageChanged(currentPage - 1),
            disabledColor: disabledColor,
            activeColor: inactiveText!,
          ),

          // Center Page Numbers
          Row(
            mainAxisSize: MainAxisSize.min,
            children: pageItems.map((item) {
              if (item == '...') {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '...',
                    style: TextStyle(
                      fontSize: 14,
                      color: inactiveText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              final pageNum = item as int;
              final isActive = pageNum == currentPage;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () => onPageChanged(pageNum),
                  borderRadius: BorderRadius.circular(20),
                  hoverColor: primaryColor.withValues(alpha: 0.05),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive ? activeBg : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? activeText : inactiveText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Right Navigation Action (NEXT →)
          _NextButton(
            isEnabled: currentPage < totalPages,
            onTap: () => onPageChanged(currentPage + 1),
            disabledColor: disabledColor,
            activeColor: inactiveText,
          ),
        ],
      ),
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;
  final Color disabledColor;
  final Color activeColor;

  const _NavigationArrow({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    required this.disabledColor,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? activeColor : disabledColor,
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;
  final Color disabledColor;
  final Color activeColor;

  const _NextButton({
    required this.isEnabled,
    required this.onTap,
    required this.disabledColor,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NEXT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: isEnabled ? activeColor : disabledColor,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.east_rounded,
              size: 16,
              color: isEnabled ? activeColor : disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
