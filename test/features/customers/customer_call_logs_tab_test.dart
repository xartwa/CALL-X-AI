import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/features/customers/widgets/customer_call_logs_tab.dart';
import 'package:callx_ai/theme/app_colors.dart';

void main() {
  testWidgets('CustomerCallLogsTab renders call logs, filters, and AI summaries',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final user = User(
      id: 1,
      fullName: 'Michael Scott',
      email: 'michael@dundermifflin.com',
      phone: '0912 111 2233',
      createdAt: DateTime(2026, 8, 1),
      lastContact: DateTime(2026, 8, 28, 14, 0),
      status: 'Active',
      companyName: 'Dunder Mifflin',
      callLogs: [
        CustomerCallHistory(
          id: 'log_1',
          status: 'Completed',
          direction: 'Outbound',
          outcome: 'Interested',
          duration: '03:12',
          durationSeconds: 192,
          scheduledFor: null,
          callDate: '2026/08/28',
          callTime: '14:00',
          scenario: 'Paper Supply Outreach',
          recordingUrl: 'https://example.com/recording.mp3',
          summary: 'Client discussed paper bulk order for upcoming quarter.',
          transcript: const [
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'Sarah AI',
              text: 'Good afternoon, Michael! Checking in regarding paper supplies.',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Michael',
              text: 'Send me the contract right away.',
            ),
          ],
          notes: 'Important account',
          createdAt: DateTime(2026, 8, 28),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
          ],
        ),
        home: Scaffold(
          body: CustomerCallLogsTab(user: user),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CALL LOGS'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Interested'), findsOneWidget);
    expect(find.text('AI Key Takeaways & Summary'), findsOneWidget);
    expect(find.text('Client discussed paper bulk order for upcoming quarter.'),
        findsOneWidget);
    expect(find.text('Call Recording'), findsOneWidget);
    expect(find.textContaining('View Transcript'), findsOneWidget);

    // Expand transcript
    await tester.tap(find.textContaining('View Transcript'));
    await tester.pumpAndSettle();

    expect(find.text('Good afternoon, Michael! Checking in regarding paper supplies.'),
        findsOneWidget);
    expect(find.text('Send me the contract right away.'), findsOneWidget);
  });
}
