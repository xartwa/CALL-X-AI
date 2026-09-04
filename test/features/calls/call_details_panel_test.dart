import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/widgets/advanced_filter_dialog.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/features/calls/cubit/selected_call_cubit.dart';
import 'package:callx_ai/features/calls/data/dto/calls_kpi_dto.dart';
import 'package:callx_ai/features/calls/data/dto/paginated_calls_dto.dart';
import 'package:callx_ai/features/calls/domain/repositories/calls_repository.dart';
import 'package:callx_ai/features/calls/models/call_history_model.dart';
import 'package:callx_ai/features/calls/widgets/call_details_panel.dart';
import 'package:callx_ai/features/calls/widgets/details/call_audio_player_widget.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';
import 'package:callx_ai/theme/app_colors.dart';

void main() {
  testWidgets(
      'CallDetailsPanel renders single-view with header, audio player, AI summary, transcript, and notes',
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
      lastContactResult: 'Interested',
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
        ),
      ],
    );

    final repo = _FakeCustomerRepository();
    final customersCubit = CustomersCubit(repo);
    final callsRepo = _FakeCallsRepository();
    final callsCubit = CallsCubit(callsRepo);
    final selectedCallCubit = SelectedCallCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: customersCubit),
          BlocProvider.value(value: callsCubit),
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

    // 1. Verify Header Elements & Customer Name
    expect(find.text('John Smith'), findsWidgets);
    expect(find.text('COMPLETED'), findsWidgets);
    expect(find.text('5:32'), findsWidgets);

    // 2. Verify Action buttons
    expect(find.text('Call Again'), findsOneWidget);
    expect(find.text('Customer Info'), findsOneWidget);

    // 3. Verify Audio Player
    expect(find.byType(CallAudioPlayerWidget), findsOneWidget);

    // 4. Verify AI Summary Section
    expect(find.text('AI Summary'), findsOneWidget);
    expect(find.text('INTERESTED'), findsOneWidget);

    // 5. Verify Transcript Section
    expect(find.text('Call Transcript'), findsOneWidget);
    expect(find.text('Copy All'), findsOneWidget);
    expect(find.text('Hello John! Calling regarding your project inquiry.'),
        findsOneWidget);

    // 6. Verify Next Steps & Follow-up Section
    expect(find.text('Next Steps'), findsOneWidget);
    expect(find.text('Next Follow-up Date'), findsOneWidget);

    await customersCubit.close();
    await callsCubit.close();
    await selectedCallCubit.close();
  });
}

class _FakeCallsRepository implements CallsRepository {
  @override
  Future<PaginatedCallsDto> getCalls({
    required int page,
    int pageSize = 10,
    String? search,
    String? status,
    String? leadPriority,
    String? sortField,
    DateTimeRange? dateRange,
    AdvancedFilterState? filterState,
    CancelToken? cancelToken,
  }) async =>
      const PaginatedCallsDto(count: 0, results: []);

  @override
  Future<CallsKpiDto> getStats({CancelToken? cancelToken}) async =>
      const CallsKpiDto();

  @override
  Future<CallHistoryModel> getCallDetail(String id) async => CallHistoryModel(
        id: id,
        fullName: 'John Smith',
        phone: '0912 345 6789',
        status: 'Completed',
        assignee: 'AI',
        duration: '5:32',
        callTime: '10:30',
        callDate: '2026/08/29',
      );

  @override
  Future<CallHistoryModel> scheduleFollowUp(
          String id, String followUpDate) async =>
      CallHistoryModel(
        id: id,
        fullName: 'John Smith',
        phone: '0912 345 6789',
        status: 'Completed',
        assignee: 'AI',
        duration: '5:32',
        callTime: '10:30',
        callDate: '2026/08/29',
        nextFollowUpDate: followUpDate,
      );

  @override
  Future<CallHistoryModel> clearFollowUp(String id) async => CallHistoryModel(
        id: id,
        fullName: 'John Smith',
        phone: '0912 345 6789',
        status: 'Completed',
        assignee: 'AI',
        duration: '5:32',
        callTime: '10:30',
        callDate: '2026/08/29',
      );

  @override
  Future<void> callAgain(String id) async {}

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String id) async => {};

  @override
  Future<void> launchBatch({
    required String name,
    required String scenarioId,
    required List<String> customerIds,
    required int concurrentLines,
  }) async {}

  @override
  Future<void> deleteCall(String id) async {}
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
  Future<List<String>> addTag(String customerId,
          {String? label, int? tagId, String color = '#6366F1'}) async =>
      [label ?? 'Tag-$tagId'];
  @override
  Future<List<String>> removeTag(String customerId,
          {String? label, int? tagId}) async =>
      const [];
  @override
  Future<CustomerImportResult> importCustomers({
    required List<int> bytes,
    required String fileName,
  }) async =>
      const CustomerImportResult(created: 0, updated: 0, errors: []);
  @override
  Future<List<int>> exportCustomers(CustomerFilters filters) async => const [];
  @override
  Future<void> dispatchCall({
    String? customerId,
    String? scenarioId,
    String? phone,
    String? fullName,
    DateTime? scheduledFor,
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> getScenarios() async => const [];
  @override
  Future<CustomerDocument> uploadDocument(String customerId, String path,
          {void Function(int sent, int total)? onProgress}) =>
      throw UnimplementedError();
  @override
  Future<void> deleteDocument(String customerId, String documentId) async {}
}
