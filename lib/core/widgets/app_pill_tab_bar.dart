import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Configuration for a single tab item in [AppPillTabBar].
class AppPillTabItem {
  final String label;
  final IconData? icon;
  final int? count;
  final String? badgeText;

  const AppPillTabItem({
    required this.label,
    this.icon,
    this.count,
    this.badgeText,
  });
}

/// Unified, reusable pill-style tab bar widget adhering to DRY principles.
/// Uses the app's theme primary color and eliminates bottom underline indicators.
class AppPillTabBar extends StatefulWidget {
  final List<AppPillTabItem> tabs;
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  final TabController? controller;
  final double height;
  final EdgeInsetsGeometry? padding;
  final MainAxisSize mainAxisSize;
  final bool isScrollable;

  const AppPillTabBar({
    super.key,
    required this.tabs,
    this.currentIndex,
    this.onTabChanged,
    this.controller,
    this.height = 44,
    this.padding,
    this.mainAxisSize = MainAxisSize.min,
    this.isScrollable = false,
  }) : assert(
          controller != null || currentIndex != null,
          'Either controller or currentIndex must be provided to AppPillTabBar',
        );

  @override
  State<AppPillTabBar> createState() => _AppPillTabBarState();
}

class _AppPillTabBarState extends State<AppPillTabBar> {
  int _internalIndex = 0;

  @override
  void initState() {
    super.initState();
    _internalIndex = widget.controller?.index ?? widget.currentIndex ?? 0;
    widget.controller?.addListener(_handleTabControllerChange);
  }

  @override
  void didUpdateWidget(covariant AppPillTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTabControllerChange);
      widget.controller?.addListener(_handleTabControllerChange);
      _internalIndex = widget.controller?.index ?? widget.currentIndex ?? 0;
    } else if (widget.currentIndex != null &&
        widget.currentIndex != oldWidget.currentIndex) {
      _internalIndex = widget.currentIndex!;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleTabControllerChange);
    super.dispose();
  }

  void _handleTabControllerChange() {
    if (widget.controller != null &&
        widget.controller!.index != _internalIndex &&
        mounted) {
      setState(() {
        _internalIndex = widget.controller!.index;
      });
    }
  }

  void _onTabTapped(int index) {
    if (widget.controller != null) {
      widget.controller!.animateTo(index);
    }
    widget.onTabChanged?.call(index);
    if (widget.currentIndex == null && mounted) {
      setState(() {
        _internalIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedIndex =
        widget.controller?.index ?? widget.currentIndex ?? _internalIndex;

    Widget content = Row(
      mainAxisSize: widget.mainAxisSize,
      children: [
        for (int i = 0; i < widget.tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _buildTabItem(
            context: context,
            tab: widget.tabs[i],
            index: i,
            isSelected: selectedIndex == i,
            isDark: isDark,
            primaryColor: primaryColor,
          ),
        ],
      ],
    );

    if (widget.isScrollable) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: content,
      );
    }

    return Container(
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E293B)
              : context.colors.mediumGreyColor.withValues(alpha: 0.35),
        ),
      ),
      child: content,
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required AppPillTabItem tab,
    required int index,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
  }) {
    final String? badgeString = tab.badgeText ?? tab.count?.toString();

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(40),
      mouseCursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          border: isSelected
              ? Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                )
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon,
                size: 14,
                color: isSelected
                    ? primaryColor
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.2,
                color: isSelected
                    ? (isDark ? Colors.white : primaryColor)
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)),
              ),
            ),
            if (badgeString != null && badgeString.isNotEmpty) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeString,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
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
