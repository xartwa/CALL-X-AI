import 'package:callx_ai/core/widgets/app_pill_tab_bar.dart';
import 'package:callx_ai/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('renders all tabs with icons, labels, and badges', (tester) async {
    var selected = 0;

    await tester.pumpWidget(
      buildTestWidget(
        child: StatefulBuilder(
          builder: (context, setState) {
            return AppPillTabBar(
              currentIndex: selected,
              onTabChanged: (index) => setState(() => selected = index),
              tabs: const [
                AppPillTabItem(
                  label: 'Sent History',
                  icon: CupertinoIcons.clock_fill,
                  count: 6,
                ),
                AppPillTabItem(
                  label: 'Email Templates',
                  icon: CupertinoIcons.doc_plaintext,
                  count: 4,
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.text('Sent History'), findsOneWidget);
    expect(find.text('Email Templates'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.doc_plaintext), findsOneWidget);

    // Tap on second tab
    await tester.tap(find.text('Email Templates'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });

  testWidgets('works seamlessly with TabController and TabBarView', (tester) async {
    late TabController controller;

    await tester.pumpWidget(
      buildTestWidget(
        child: DefaultTabController(
          length: 3,
          child: Builder(
            builder: (context) {
              controller = DefaultTabController.of(context);
              return Column(
                children: [
                  AppPillTabBar(
                    controller: controller,
                    tabs: const [
                      AppPillTabItem(label: 'Tab 1', badgeText: '01'),
                      AppPillTabItem(label: 'Tab 2', badgeText: '02'),
                      AppPillTabItem(label: 'Tab 3', badgeText: '03'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: const [
                        Text('View 1'),
                        Text('View 2'),
                        Text('View 3'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('View 1'), findsOneWidget);
    expect(controller.index, 0);

    // Tap Tab 2
    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();

    expect(controller.index, 1);
    expect(find.text('View 2'), findsOneWidget);
  });
}
