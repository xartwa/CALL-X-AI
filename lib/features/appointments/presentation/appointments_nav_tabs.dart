import 'package:flutter/cupertino.dart';
import '../../../../core/widgets/app_pill_tab_bar.dart';

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
    return Row(
      children: [
        AppPillTabBar(
          currentIndex: activeTab,
          onTabChanged: onTabChanged,
          tabs: [
            const AppPillTabItem(
              label: 'Calendar',
              icon: CupertinoIcons.calendar,
            ),
            AppPillTabItem(
              label: 'Requests',
              icon: CupertinoIcons.doc_text,
              count: pendingRequestsCount > 0 ? pendingRequestsCount : null,
            ),
            const AppPillTabItem(
              label: 'Availability',
              icon: CupertinoIcons.clock,
            ),
          ],
        ),
      ],
    );
  }
}
