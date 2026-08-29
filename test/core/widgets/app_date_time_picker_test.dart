import 'package:callx_ai/core/widgets/app_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openPicker(
    WidgetTester tester,
    Future<DateTime?> Function(BuildContext context) picker,
    ValueChanged<DateTime?> onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => onResult(await picker(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('pickDate confirms the tapped day at midnight',
      (tester) async {
    DateTime? result;
    await openPicker(tester, AppDateTimePicker.pickDate, (v) => result = v);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(result, DateTime(now.year, now.month, 15));
  });

  testWidgets('pickDateTime sets hour and minute via scroll wheels',
      (tester) async {
    DateTime? result;
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result =
                  await AppDateTimePicker.pickDateTime(
                context,
                initial: DateTime(now.year, now.month, 10, 8, 15),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    // Hour wheel up 2 items (08 -> 10), minute wheel down 1 item (15 -> 16).
    await tester.drag(
      find.byType(ListWheelScrollView).at(0),
      const Offset(0, -88),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(ListWheelScrollView).at(1),
      const Offset(0, 44),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(result, DateTime(now.year, now.month, 10, 10, 16));
  });

  testWidgets('cancel returns no value', (tester) async {
    DateTime? result = DateTime(2000);
    await openPicker(tester, AppDateTimePicker.pickDate, (v) => result = v);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
