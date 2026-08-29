import 'package:callx_ai/features/customers/widgets/customer_detail_custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'supports custom flex without nesting incompatible ParentDataWidgets',
    (tester) async {
      final wideController = TextEditingController();
      final regularController = TextEditingController();
      addTearDown(wideController.dispose);
      addTearDown(regularController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 600,
              child: Row(
                children: [
                  CustomerDetailCustomTextfeild(
                    key: const Key('wide-field'),
                    controller: wideController,
                    labelText: 'Street address',
                    flex: 2,
                  ),
                  const SizedBox(width: 16),
                  CustomerDetailCustomTextfeild(
                    key: const Key('regular-field'),
                    controller: regularController,
                    labelText: 'City',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final wideWidth =
          tester.getSize(find.byKey(const Key('wide-field'))).width;
      final regularWidth =
          tester.getSize(find.byKey(const Key('regular-field'))).width;
      expect(wideWidth / regularWidth, closeTo(2, 0.01));
    },
  );
}
