import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/features/customers/widgets/customer_call_logs_tab.dart';
import 'package:callx_ai/theme/app_colors.dart';

void main() {
  testWidgets('CustomerCallLogsTab renders call logs, handles selection, close, and unanswered toast',
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
          callDate: 'Aug 28, 2026',
          callTime: '14:00',
          scenario: 'Paper Supply Outreach',
          recordingUrl: 'https://example.com/recording.mp3',
          summary: 'Client discussed paper bulk order for upcoming quarter.',
          transcript: const [
            TranscriptTurn(
              speaker: 'ai',
              speakerName: 'Agent',
              text: 'Good afternoon, Michael! Checking in regarding paper supplies.',
            ),
            TranscriptTurn(
              speaker: 'customer',
              speakerName: 'Customer',
              text: 'Send me the contract right away.',
            ),
          ],
          notes: 'Important account',
          createdAt: DateTime(2026, 8, 28),
        ),
        CustomerCallHistory(
          id: 'log_2',
          status: 'No Answer',
          direction: 'Outbound',
          outcome: 'No Answer',
          duration: '00:58',
          durationSeconds: 58,
          callDate: 'Aug 25, 2026',
          callTime: '11:00',
          summary: 'Unanswered call',
          transcript: const [],
          createdAt: DateTime(2026, 8, 25),
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

    // 1. Check Search and Left column list
    expect(find.text('Outgoing Call'), findsWidgets);
    expect(find.text('Aug 28, 2026 • 14:00'), findsOneWidget);
    expect(find.text('03:12'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('No Answer'), findsOneWidget);
    expect(find.text('2 of 2 calls'), findsOneWidget);

    // 2. Click on the first completed call to open details
    await tester.tap(find.text('Aug 28, 2026 • 14:00'));
    await tester.pumpAndSettle();

    // Check Detail View is open
    expect(find.text('AI Summary'), findsOneWidget);
    expect(find.text('Client discussed paper bulk order for upcoming quarter.'),
        findsOneWidget);
    expect(find.text('Call Transcript'), findsOneWidget);
    expect(find.text('Good afternoon, Michael! Checking in regarding paper supplies.'),
        findsOneWidget);
    expect(find.text('Send me the contract right away.'), findsOneWidget);
    expect(find.byType(CallAudioPlayerWidget), findsOneWidget);

    // 3. Click Close details button (✕)
    await tester.tap(find.byIcon(CupertinoIcons.clear));
    await tester.pumpAndSettle();

    // Detail view should be closed
    expect(find.text('AI Summary'), findsNothing);

    // 4. Click on the unanswered call ("No Answer") -> should not open details
    await tester.tap(find.text('No Answer'));
    await tester.pump();
    expect(find.text('AI Summary'), findsNothing);

    // Clean up toastification timers
    toastification.dismissAll();
    await tester.pumpAndSettle();
  });
}
