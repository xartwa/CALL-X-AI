import 'dart:ui';

import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supports pull-to-refresh with a mouse drag', (tester) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppPullToRefresh(
            onRefresh: () async => refreshCount++,
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      const Offset(200, 100),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(0, 300));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
  });
}
