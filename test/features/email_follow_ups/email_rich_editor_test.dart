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

    testWidgets('applying H1 to selected text isolates only that text as heading', (tester) async {
      final controller = QuillController(
        document: Document()..insert(0, 'Hello world and welcome\n'),
        selection: const TextSelection(baseOffset: 0, extentOffset: 5), // "Hello"
      );

      final toolbarKey = GlobalKey<EmailEditorToolbarState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailEditorToolbar(
              key: toolbarKey,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger H1 formatting on the selected "Hello"
      toolbarKey.currentState!.applyBlockAttribute(Attribute.h1);
      await tester.pumpAndSettle();

      // The document should now have "Hello" as its own line with header: 1
      // and "world and welcome" as regular paragraph text
      final delta = controller.document.toDelta().toJson();
      expect(delta[0]['insert'], 'Hello');
      expect(delta[1]['insert'], '\n');
      expect(delta[1]['attributes'], {'header': 1});

      // The rest of the text must NOT have header attribute
      final remainingInsert = delta[2]['insert'] as String;
      expect(remainingInsert, contains('world and welcome'));
      expect(delta[2]['attributes'], isNull);
    });

    testWidgets('opens unified INSERT HYPERLINK dialog with matching styling', (tester) async {
      final controller = QuillController(
        document: Document()..insert(0, 'Visit Google today\n'),
        selection: const TextSelection(baseOffset: 6, extentOffset: 12), // "Google"
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailEditorToolbar(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap link button in toolbar
      final linkBtn = find.byTooltip('Insert Link');
      expect(linkBtn, findsOneWidget);
      await tester.tap(linkBtn);
      await tester.pumpAndSettle();

      // Ensure unified dialog elements are present
      expect(find.text('INSERT HYPERLINK'), findsOneWidget);
      expect(find.text('LINK TEXT'), findsOneWidget);
      expect(find.text('DESTINATION URL'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Insert Link'), findsOneWidget);

      // Verify prefilled link text
      expect(find.text('Google'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('INSERT HYPERLINK'), findsNothing);
    });
  });
}
