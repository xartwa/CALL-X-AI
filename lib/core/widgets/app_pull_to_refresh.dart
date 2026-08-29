import 'package:flutter/material.dart';

/// A consistent, unobtrusive pull-to-refresh affordance for application pages.
///
/// Pages with their own top-level scroll view can set [scrollableChild] to
/// true. Fixed dashboard-style layouts are wrapped in an always-scrollable
/// viewport so the gesture is still available when their content fits.
class AppPullToRefresh extends StatelessWidget {
  const AppPullToRefresh({
    required this.onRefresh,
    required this.child,
    this.scrollableChild = false,
    super.key,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final bool scrollableChild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      notificationPredicate: (_) => true,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      displacement: 32,
      edgeOffset: 2,
      elevation: 1,
      strokeWidth: 2,
      child: scrollableChild
          ? child
          : LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: child,
                ),
              ),
            ),
    );
  }
}

extension AppPullToRefreshExtension on Widget {
  Widget withPullToRefresh({
    required RefreshCallback onRefresh,
    bool scrollableChild = false,
  }) =>
      AppPullToRefresh(
        onRefresh: onRefresh,
        scrollableChild: scrollableChild,
        child: this,
      );
}
