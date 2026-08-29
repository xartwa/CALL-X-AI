import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/features/customers/widgets/customer_call_logs_tab.dart';
import 'package:callx_ai/theme/app_colors.dart';

void main() {
  testWidgets('CustomerCallLogsTab renders 2-column master-detail layout, search, transcript, and audio player',
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
    expect(find.text('Aug 28, 2026 • 14:00'), findsWidgets);
    expect(find.text('03:12'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('1 of 1 calls'), findsOneWidget);

    // 2. Check Detail View
    expect(find.text('AI Summary'), findsOneWidget);
    expect(find.text('Client discussed paper bulk order for upcoming quarter.'),
        findsOneWidget);
    expect(find.text('Call Transcript'), findsOneWidget);
    expect(find.text('Good afternoon, Michael! Checking in regarding paper supplies.'),
        findsOneWidget);
    expect(find.text('Send me the contract right away.'), findsOneWidget);

    // 3. Check Audio Player
    expect(find.byType(CallAudioPlayerWidget), findsOneWidget);
  });
}
