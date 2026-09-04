import 'package:flutter/cupertino.dart';
import '../../../../core/widgets/app_pill_tab_bar.dart';

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
    return Row(
      children: [
        AppPillTabBar(
          currentIndex: selectedTab,
          onTabChanged: onTabChanged,
          tabs: [
            AppPillTabItem(
              label: 'Sent History',
              icon: CupertinoIcons.clock_fill,
              count: sentCount,
            ),
            AppPillTabItem(
              label: 'Email Templates',
              icon: CupertinoIcons.doc_plaintext,
              count: templatesCount,
            ),
          ],
        ),
      ],
    );
  }
}
