import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_details_panel.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';
import 'package:callx_ai/theme/app_colors.dart';

void main() {
  testWidgets('CallDetailsPanel renders header, audio player, tabs, and footer',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final call = CallHistoryModel(
      id: '1',
      fullName: 'John Smith',
      companyName: 'ABC Construction',
      phone: '0912 345 6789',
      status: 'Completed',
      assignee: 'Sarah (AI Voice Agent)',
      duration: '5:32',
      callTime: '10:30',
      callDate: '2026/08/29',
      notes: 'Customer satisfied with estimation quote.',
      email: 'john@abcconstruction.com',
      leadPriority: 'Hot',
      sentimentScore: 88,
      sentiment: 'Positive',
      callIntent: 'Scope Estimation & Quote Proposal',
      tags: ['GC', 'Hot Lead', 'Vancouver'],
      transcript: const [
        CallTranscriptMessage(
          speaker: 'ai',
          speakerName: 'Sarah (AI Voice Agent)',
          text: 'Hello John! Calling regarding your project inquiry.',
          timestamp: '00:04',
        ),
        CallTranscriptMessage(
          speaker: 'customer',
          speakerName: 'John Smith',
          text: 'Hi Sarah, glad you called back. Let us review.',
          timestamp: '00:12',
          sentiment: 'positive',
        ),
      ],
    );

    final repo = _FakeCustomerRepository();
    final customersCubit = CustomersCubit(repo);
    final selectedCallCubit = SelectedCallCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: customersCubit),
          BlocProvider.value(value: selectedCallCubit),
        ],
        child: MaterialApp(
          theme: ThemeData(
            extensions: const [AppColors.light],
          ),
          home: Scaffold(
            body: CallDetailsPanel(
              call: call,
              onCallAdded: () {},
              onCallUpdated: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Header Elements
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('5:32'), findsWidgets);

    // 2. Verify Tab labels
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Transcript'), findsOneWidget);
    expect(find.text('CRM'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);

    // 3. Verify Audio Player
    expect(find.text('CALL RECORDING'), findsOneWidget);

    // 4. Verify Insights Tab content (Default tab)
    expect(find.text('EXECUTIVE AI SUMMARY'), findsOneWidget);
    expect(find.text('SENTIMENT & CALL INTENT'), findsOneWidget);
    expect(find.text('AI ACTION ITEMS & NEXT STEPS'), findsOneWidget);

    // 5. Switch to Transcript Tab
    await tester.tap(find.text('Transcript'));
    await tester.pumpAndSettle();
    expect(find.text('Copy All'), findsOneWidget);

    // 6. Switch to CRM Tab
    await tester.tap(find.text('CRM'));
    await tester.pumpAndSettle();
    expect(find.text('CONTACT DETAILS'), findsOneWidget);
    expect(find.text('LEAD CLASSIFICATION'), findsOneWidget);
    expect(find.text('OPEN FULL CRM PROFILE'), findsOneWidget);

    // 7. Switch to Notes Tab
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('INTERNAL CALL NOTES'), findsOneWidget);
    expect(find.text('SAVE NOTES & FOLLOW-UP'), findsOneWidget);

    // 8. Verify Footer Action buttons
    expect(find.text('RE-DIAL'), findsOneWidget);
    expect(find.text('SCHEDULE'), findsOneWidget);

    await customersCubit.close();
    await selectedCallCubit.close();
  });
}

class _FakeCustomerRepository implements CustomerRepository {
  @override
  Future<CustomerPage> getCustomers(CustomerFilters filters,
          {int page = 1, int pageSize = 20, Object? cancelToken}) async =>
      const CustomerPage([], PaginationMeta());
  @override
  Future<Customer> getCustomer(String id) async =>
      Customer(id: '1', fullName: 'John Smith', phone: '0912 345 6789');
  @override
  Future<CustomerKpi> getKpi() async => const CustomerKpi(
      totalCustomers: 0,
      activeAccounts: 0,
      inactiveAccounts: 0,
      contactedToday: 0);
  @override
  Future<CustomerFilterOptions> getOptions(
          {String? country, String? state}) async =>
      const CustomerFilterOptions();
  @override
  Future<Customer> createCustomer(Customer customer) async => customer;
  @override
  Future<Customer> updateCustomer(Customer customer) async => customer;
  @override
  Future<void> deleteCustomer(String id) async {}
  @override
  Future<CustomerNote> addNote(String customerId, String content,
          {String author = 'Admin'}) =>
      throw UnimplementedError();
  @override
  Future<CustomerNote> updateNote(
          String customerId, String noteId, String content) =>
      throw UnimplementedError();
  @override
  Future<void> deleteNote(String customerId, String noteId) async {}
  @override
  Future<List<String>> addTag(String customerId, String label,
          {String color = '#6366F1'}) async =>
      [label];
  @override
  Future<List<String>> removeTag(String customerId, String label) async =>
      const [];
  @override
  Future<CustomerImportResult> importCustomers(String path) async =>
      const CustomerImportResult(created: 0, updated: 0, errors: []);
  @override
  Future<List<int>> exportCustomers(CustomerFilters filters) async => const [];
  @override
  Future<void> dispatchCall(String customerId, String scenarioId,
      {DateTime? scheduledFor}) async {}
  @override
  Future<List<Map<String, dynamic>>> getScenarios() async => const [];
  @override
  Future<CustomerDocument> uploadDocument(String customerId, String path,
          {void Function(int sent, int total)? onProgress}) =>
      throw UnimplementedError();
  @override
  Future<void> deleteDocument(String customerId, String documentId) async {}
}
