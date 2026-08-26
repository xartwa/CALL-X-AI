import 'package:dio/dio.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../dto/customer_dto.dart';
import '../dto/customer_kpi_dto.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl(this.remote);
  final CustomerRemoteDataSource remote;

  T _guard<T>(T Function() parse) {
    try {
      return parse();
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.invalidData);
    }
  }

  Future<T> _request<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

  @override
  Future<CustomerPage> getCustomers(CustomerFilters filters,
          {int page = 1, int pageSize = 20, Object? cancelToken}) =>
      _request(() async {
        final data = await remote.list(filters.toQuery(page, pageSize),
            cancelToken: cancelToken as CancelToken?);
        return _guard(() {
          final json = Map<String, dynamic>.from(data as Map);
          final results = PaginatedCustomersDto(json).customers;
          return CustomerPage(
              results,
              PaginationMeta(
                  count: _int(json['count']),
                  totalPages: _int(json['totalPages'], 1),
                  currentPage: _int(json['currentPage'], 1),
                  pageSize: _int(json['pageSize'], pageSize),
                  hasNext: json['hasNext'] == true,
                  hasPrevious: json['hasPrevious'] == true));
        });
      });

  @override
  Future<Customer> getCustomer(String id) =>
      _request(() async => CustomerDto(await remote.detail(id)).toEntity());
  @override
  Future<CustomerKpi> getKpi() => _request(() async {
        final j = await remote.kpi();
        return CustomerKpiDto(j).toEntity();
      });
  @override
  Future<CustomerFilterOptions> getOptions({String? country, String? state}) =>
      _request(() async {
        final j = await remote.options(country: country, state: state);
        return CustomerFilterOptions(
            country: _list(j['country']),
            state: _list(j['state']),
            city: _list(j['city']),
            companyType: _list(j['company_type']),
            leadStatus: _list(j['lead_status']),
            leadQuality: _list(j['lead_quality']),
            leadPriority: _list(j['lead_priority']),
            status: _list(j['status']));
      });
  @override
  Future<Customer> createCustomer(Customer customer) => _request(() async =>
      CustomerDto(await remote.create(customer.toApiJson())).toEntity());
  @override
  Future<Customer> updateCustomer(Customer customer) => _request(() async =>
      CustomerDto(await remote.update('${customer.id}', customer.toApiJson()))
          .toEntity());
  @override
  Future<void> deleteCustomer(String id) => _request(() => remote.delete(id));
  @override
  Future<CustomerNote> addNote(String customerId, String content,
          {String author = 'Admin'}) =>
      _request(() async => _note(await remote.note(customerId, {
            'content': content,
            'author': author,
            'date': DateTime.now().toIso8601String()
          })));
  @override
  Future<CustomerNote> updateNote(
          String customerId, String noteId, String content) =>
      _request(() async => _note(
          await remote.noteUpdate(customerId, noteId, {'content': content})));
  @override
  Future<void> deleteNote(String customerId, String noteId) =>
      _request(() => remote.noteDelete(customerId, noteId));
  @override
  Future<List<String>> addTag(String customerId, String label,
          {String color = '#6366F1'}) =>
      _request(() => remote.tag(customerId, label, color: color));
  @override
  Future<List<String>> removeTag(String customerId, String label) =>
      _request(() => remote.tag(customerId, label, remove: true));
  @override
  Future<CustomerImportResult> importCustomers(String path) =>
      _request(() async {
        final j = await remote.importFile(path);
        return CustomerImportResult(
            created: _int(j['created']),
            updated: _int(j['updated']),
            errors: _list(j['errors']));
      });
  @override
  Future<List<int>> exportCustomers(CustomerFilters filters) =>
      _request(() => remote.exportFile(filters.toQuery(1, 100000)));
  @override
  Future<void> dispatchCall(String customerId, String scenarioId,
          {DateTime? scheduledFor}) =>
      _request(() => remote.dispatchCall(customerId, scenarioId,
          scheduledFor: scheduledFor));
  @override
  Future<List<Map<String, dynamic>>> getScenarios() =>
      _request(remote.scenarios);
  @override
  Future<CustomerDocument> uploadDocument(String customerId, String path,
          {void Function(int sent, int total)? onProgress}) =>
      _request(() async => CustomerDocument.fromJson(await remote
          .uploadDocument(customerId, path, onProgress: onProgress)));
  @override
  Future<void> deleteDocument(String customerId, String documentId) =>
      _request(() => remote.deleteDocument(customerId, documentId));
}

int _int(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
List<String> _list(Object? value) =>
    value is List ? value.map((e) => '$e').toList() : const [];
CustomerNote _note(Map<String, dynamic> j) => CustomerNote(
    id: '${j['id']}',
    content: '${j['content'] ?? ''}',
    date: '${j['date'] ?? ''}',
    author: '${j['author'] ?? 'Admin'}');
