import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/domain/repositories/customer_repository.dart';

void main() {
  test('debounces search and requests page one with server filters', () async {
    final repository = _FakeCustomerRepository();
    final cubit = CustomersCubit(repository);

    cubit.search('a');
    cubit.search('arta');
    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(repository.listCalls, 1);
    expect(repository.lastFilters.search, 'arta');
    expect(repository.lastPage, 1);
    await cubit.close();
  });

  test('sort changes are sent to the server', () async {
    final repository = _FakeCustomerRepository();
    final cubit = CustomersCubit(repository);
    await cubit.setSort('za');
    expect(repository.lastFilters.sort, 'za');
    expect(cubit.state.pagination.currentPage, 1);
    await cubit.close();
  });

  test('list refresh preserves detail-only notes for a loaded customer',
      () async {
    final repository = _FakeCustomerRepository();
    final cubit = CustomersCubit(repository);

    repository.detailCustomer = Customer(
      id: '42',
      fullName: 'Detail Customer',
      notesList: [
        CustomerNote(
          id: 'note-1',
          content: 'Keep me visible',
          date: DateTime.utc(2026, 8, 29, 8, 30),
        ),
      ],
      notesCount: 1,
    );
    await cubit.loadCustomerDetail('42');

    repository.pageItems = [
      Customer(id: '42', fullName: 'Updated Customer'),
    ];
    await cubit.loadPage();

    expect(cubit.state.users.single.fullName, 'Updated Customer');
    expect(cubit.state.users.single.notesList.single.id, 'note-1');
    expect(cubit.state.users.single.notesCount, 1);
    await cubit.close();
  });

  test('an older list response cannot replace a newer filtered result',
      () async {
    final repository = _FakeCustomerRepository(controlListResponses: true);
    final cubit = CustomersCubit(repository);

    final initialRequest = cubit.loadPage();
    final filteredRequest = cubit.setFilters(
      const CustomerFilters(status: 'Active'),
    );

    repository.completeListRequest(
      1,
      CustomerPage(
        [Customer(id: '42', fullName: 'Current Customer')],
        const PaginationMeta(count: 1),
      ),
    );
    await filteredRequest;

    repository.completeListRequest(
      0,
      const CustomerPage([], PaginationMeta()),
    );
    await initialRequest;

    expect(cubit.state.users.single.id, '42');
    expect(cubit.state.filters.status, 'Active');
    await cubit.close();
  });

  test('initial page load can reset filters that are no longer visible',
      () async {
    final repository = _FakeCustomerRepository(controlListResponses: true);
    final cubit = CustomersCubit(repository);

    final staleFilterRequest = cubit.setFilters(
      const CustomerFilters(city: 'Hidden stale city', status: 'Deactive'),
    );
    repository.completeListRequest(
      0,
      const CustomerPage([], PaginationMeta()),
    );
    await staleFilterRequest;

    final initialLoad = cubit.loadInitial(resetFilters: true);
    repository.completeListRequest(
      1,
      CustomerPage(
        [Customer(id: '42', fullName: 'Visible Customer')],
        const PaginationMeta(count: 1),
      ),
    );
    await initialLoad;

    expect(repository.lastFilters.city, isNull);
    expect(repository.lastFilters.status, isNull);
    expect(cubit.state.users.single.id, '42');
    await cubit.close();
  });

  test('loadInitial fetches customers list, KPI metrics, and filter options on page entry',
      () async {
    final repository = _FakeCustomerRepository();
    repository.pageItems = [
      Customer(id: '1', fullName: 'Alice'),
      Customer(id: '2', fullName: 'Bob'),
    ];
    final cubit = CustomersCubit(repository);

    await cubit.loadInitial(resetFilters: true);

    expect(repository.listCalls, 1);
    expect(cubit.state.users.length, 2);
    expect(cubit.state.isInitialLoading, false);
    expect(cubit.state.kpi, isNotNull);
    expect(cubit.state.options, isNotNull);
    await cubit.close();
  });

  test('Excel import forwards browser bytes and refreshes customer data',
      () async {
    final repository = _FakeCustomerRepository();
    final cubit = CustomersCubit(repository);

    final result = await cubit.importCustomers(
      bytes: const [80, 75, 3, 4],
      fileName: 'customers.xlsx',
    );

    expect(repository.importedBytes, const [80, 75, 3, 4]);
    expect(repository.importedFileName, 'customers.xlsx');
    expect(repository.listCalls, 1);
    expect(result?.created, 1);
    expect(cubit.state.isImporting, isFalse);
    await cubit.close();
  });
}

class _FakeCustomerRepository implements CustomerRepository {
  _FakeCustomerRepository({this.controlListResponses = false});

  final bool controlListResponses;
  int listCalls = 0;
  int lastPage = 0;
  CustomerFilters lastFilters = const CustomerFilters();
  List<Customer> pageItems = const [];
  Customer? detailCustomer;
  List<int>? importedBytes;
  String? importedFileName;
  final List<Completer<CustomerPage>> _pendingListRequests = [];

  void completeListRequest(int index, CustomerPage response) {
    _pendingListRequests[index].complete(response);
  }

  @override
  Future<CustomerPage> getCustomers(CustomerFilters filters,
      {int page = 1, int pageSize = 20, Object? cancelToken}) async {
    listCalls++;
    lastPage = page;
    lastFilters = filters;
    if (controlListResponses) {
      final completer = Completer<CustomerPage>();
      _pendingListRequests.add(completer);
      return completer.future;
    }
    return CustomerPage(
        pageItems, PaginationMeta(currentPage: page, pageSize: pageSize));
  }

  @override
  Future<Customer> getCustomer(String id) async => detailCustomer!;
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
  }) async {
    importedBytes = bytes;
    importedFileName = fileName;
    return const CustomerImportResult(created: 1, updated: 0, errors: []);
  }

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
