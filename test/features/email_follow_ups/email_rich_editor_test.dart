import 'package:callx_ai/features/email_follow_ups/widgets/email_editor_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailHtmlConverter Tests', () {
    test('converts HTML to Quill Delta and back without losing content', () {
      const originalHtml = '<p>Hi <strong>{name}</strong>,</p><p>Thank you for reaching out to <em>{company}</em>.</p>';
      final controller = EmailHtmlConverter.createController(originalHtml);

      expect(controller.document.toPlainText(), contains('Hi {name}'));
      expect(controller.document.toPlainText(), contains('Thank you for reaching out to {company}'));
      // Ensure raw HTML tags are NOT in the plain text seen by the editor
      expect(controller.document.toPlainText(), isNot(contains('<p>')));
      expect(controller.document.toPlainText(), isNot(contains('<strong>')));

      final convertedHtml = EmailHtmlConverter.deltaToHtml(controller.document);
      expect(convertedHtml, contains('<strong>{name}</strong>'));
      expect(convertedHtml, contains('<em>{company}</em>'));
    });

    test('handles empty or whitespace html gracefully', () {
      final controller = EmailHtmlConverter.createController('');
      expect(controller.document.toPlainText().trim(), isEmpty);

      final html = EmailHtmlConverter.deltaToHtml(controller.document);
      expect(html, isNotNull);
    });
  });

  group('EmailEditorToolbar & EmailQuillEditor Widget Tests', () {
    testWidgets('renders toolbar and visual quill editor without raw html tags', (tester) async {
      const initialHtml = '<p>Proposal for <strong>{company}</strong></p>';
      final controller = EmailHtmlConverter.createController(initialHtml);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                EmailEditorToolbar(controller: controller),
                EmailQuillEditor(controller: controller),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure toolbar action buttons are present
      expect(find.text('B'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('H1'), findsOneWidget);
      expect(find.text('H2'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('VARIABLES'), findsOneWidget);

      // Verify that raw HTML tags like <p> are NOT displayed in the UI
      expect(find.textContaining('<p>'), findsNothing);
      expect(find.textContaining('<strong>'), findsNothing);
    });
  });
}
