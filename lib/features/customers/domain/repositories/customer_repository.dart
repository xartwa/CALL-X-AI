import '../entities/customer.dart';

class CustomerFilters {
  const CustomerFilters({
    this.search = '',
    this.country,
    this.state,
    this.city,
    this.status,
    this.leadStatus,
    this.leadPriority,
    this.leadQuality,
    this.contactedToday = false,
    this.sort = 'newest',
  });
  final String search;
  final String? country;
  final String? state;
  final String? city;
  final String? status;
  final String? leadStatus;
  final String? leadPriority;
  final String? leadQuality;
  final bool contactedToday;
  final String sort;

  Map<String, dynamic> toQuery(int page, int pageSize) => {
        'page': page,
        'pageSize': pageSize,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (status != null) 'status': status,
        if (leadStatus != null) 'leadStatus': leadStatus,
        if (leadPriority != null) 'leadPriority': leadPriority,
        if (leadQuality != null) 'leadQuality': leadQuality,
        if (contactedToday) 'contactedToday': true,
        'sort': sort,
      };
}

class PaginationMeta {
  const PaginationMeta(
      {this.count = 0,
      this.totalPages = 1,
      this.currentPage = 1,
      this.pageSize = 20,
      this.hasNext = false,
      this.hasPrevious = false});
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;
}

class CustomerPage {
  const CustomerPage(this.items, this.pagination);
  final List<Customer> items;
  final PaginationMeta pagination;
}

class CustomerKpi {
  const CustomerKpi(
      {required this.totalCustomers,
      required this.activeAccounts,
      required this.inactiveAccounts,
      required this.contactedToday,
      this.date});
  final int totalCustomers;
  final int activeAccounts;
  final int inactiveAccounts;
  final int contactedToday;
  final DateTime? date;
}

class CustomerFilterOptions {
  const CustomerFilterOptions(
      {this.country = const [],
      this.state = const [],
      this.city = const [],
      this.companyType = const [],
      this.leadStatus = const [],
      this.leadQuality = const [],
      this.leadPriority = const [],
      this.status = const []});
  final List<String> country;
  final List<String> state;
  final List<String> city;
  final List<String> companyType;
  final List<String> leadStatus;
  final List<String> leadQuality;
  final List<String> leadPriority;
  final List<String> status;
}

class CustomerImportResult {
  const CustomerImportResult(
      {required this.created, required this.updated, required this.errors});
  final int created;
  final int updated;
  final List<String> errors;
}

abstract interface class CustomerRepository {
  Future<CustomerPage> getCustomers(CustomerFilters filters,
      {int page = 1, int pageSize = 20, Object? cancelToken});
  Future<Customer> getCustomer(String id);
  Future<CustomerKpi> getKpi();
  Future<CustomerFilterOptions> getOptions({String? country, String? state});
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<CustomerNote> addNote(String customerId, String content,
      {String author = 'Admin'});
  Future<CustomerNote> updateNote(
      String customerId, String noteId, String content);
  Future<void> deleteNote(String customerId, String noteId);
  Future<List<String>> addTag(String customerId, String label,
      {String color = '#6366F1'});
  Future<List<String>> removeTag(String customerId, String label);
  Future<CustomerImportResult> importCustomers(String path);
  Future<List<int>> exportCustomers(CustomerFilters filters);
  Future<void> dispatchCall(String customerId, String scenarioId,
      {DateTime? scheduledFor});
  Future<List<Map<String, dynamic>>> getScenarios();
  Future<CustomerDocument> uploadDocument(String customerId, String path,
      {void Function(int sent, int total)? onProgress});
  Future<void> deleteDocument(String customerId, String documentId);
}
