import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/domain/entities/customer.dart';
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
}

class _FakeCustomerRepository implements CustomerRepository {
  int listCalls = 0;
  int lastPage = 0;
  CustomerFilters lastFilters = const CustomerFilters();

  @override
  Future<CustomerPage> getCustomers(CustomerFilters filters,
      {int page = 1, int pageSize = 20, Object? cancelToken}) async {
    listCalls++;
    lastPage = page;
    lastFilters = filters;
    return CustomerPage(
        const [], PaginationMeta(currentPage: page, pageSize: pageSize));
  }

  @override
  Future<Customer> getCustomer(String id) => throw UnimplementedError();
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
