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
          if (data is List) {
            final allResults = data
                .whereType<Map>()
                .map((item) =>
                    CustomerDto(Map<String, dynamic>.from(item)).toEntity())
                .toList(growable: false);
            final count = allResults.length;
            final validPageSize = pageSize > 0 ? pageSize : 10;
            final computedTotalPages = (count / validPageSize).ceil().clamp(1, 9999);
            final startIndex = ((page - 1) * validPageSize).clamp(0, count);
            final endIndex = (startIndex + validPageSize).clamp(0, count);
            final pagedSlice = allResults.sublist(startIndex, endIndex);

            return CustomerPage(
                pagedSlice,
                PaginationMeta(
                    count: count,
                    totalPages: computedTotalPages,
                    currentPage: page,
                    pageSize: validPageSize,
                    hasNext: page < computedTotalPages,
                    hasPrevious: page > 1));
          }
          final json = Map<String, dynamic>.from(data as Map);
          final rawResults = PaginatedCustomersDto(json).customers;
          final count = _int(
              json['count'] ?? json['total'] ?? json['total_count'],
              rawResults.length);
          final pSize = _int(json['pageSize'] ?? json['page_size'], pageSize);
          final validPageSize = pSize > 0 ? pSize : 10;
          final computedTotalPages =
              (count / validPageSize).ceil().clamp(1, 9999);
          final totalPages =
              _int(json['totalPages'] ?? json['total_pages'], computedTotalPages);
          final currentPage = _int(
              json['currentPage'] ?? json['current_page'] ?? json['page'],
              page);

          List<Customer> finalResults = rawResults;
          if (rawResults.length > validPageSize && rawResults.length >= count) {
            final startIndex =
                ((currentPage - 1) * validPageSize).clamp(0, rawResults.length);
            final endIndex =
                (startIndex + validPageSize).clamp(0, rawResults.length);
            finalResults = rawResults.sublist(startIndex, endIndex);
          }

          final hasNext = json['next'] != null ||
              json['hasNext'] == true ||
              json['has_next'] == true ||
              currentPage < totalPages;
          final hasPrev = json['previous'] != null ||
              json['hasPrevious'] == true ||
              json['has_previous'] == true ||
              currentPage > 1;

          return CustomerPage(
              finalResults,
              PaginationMeta(
                  count: count,
                  totalPages: totalPages,
                  currentPage: currentPage,
                  pageSize: validPageSize,
                  hasNext: hasNext,
                  hasPrevious: hasPrev));
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
        final raw = await remote.options(country: country, state: state);
        final j = raw['data'] is Map ? Map<String, dynamic>.from(raw['data'] as Map) : raw;
        return CustomerFilterOptions(
            country: _list(j['country'] ?? j['countries']),
            state: _list(j['state'] ?? j['states'] ?? j['provinces']),
            city: _list(j['city'] ?? j['cities']),
            companyType: _list(j['company_type'] ?? j['companyType']),
            leadStatus: _list(j['lead_status'] ?? j['leadStatus']),
            leadQuality: _list(j['lead_quality'] ?? j['leadQuality']),
            leadPriority: _list(j['lead_priority'] ?? j['leadPriority']),
            status: _list(j['status'] ?? j['statuses']));
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
  Future<List<String>> addTag(String customerId,
          {String? label, int? tagId, String color = '#6366F1'}) =>
      _request(() => remote.tag(customerId,
          label: label, tagId: tagId, color: color));
  @override
  Future<List<String>> removeTag(String customerId,
          {String? label, int? tagId}) =>
      _request(() => remote.tag(customerId,
          label: label, tagId: tagId, remove: true));
  @override
  Future<CustomerImportResult> importCustomers({
    required List<int> bytes,
    required String fileName,
  }) async {
    try {
      return _importResult(await remote.importFile(bytes, fileName));
    } on DioException catch (error) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['errors'] is List) {
        return _importResult(Map<String, dynamic>.from(responseData));
      }
      throw AppException.fromDio(error);
    } on AppException {
      rethrow;
    } on FormatException {
      throw const AppException(AppErrorType.invalidData);
    } catch (_) {
      throw const AppException(AppErrorType.unknown);
    }
  }

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
CustomerImportResult _importResult(Map<String, dynamic> json) =>
    CustomerImportResult(
      created: _int(json['created']),
      updated: _int(json['updated']),
      errors: _list(json['errors']),
    );
