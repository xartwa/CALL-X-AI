import '../../domain/repositories/customer_repository.dart';

/// Transport representation of the server-side filter query.
class CustomerFilterDto {
  const CustomerFilterDto(this.filters);
  final CustomerFilters filters;
  Map<String, dynamic> toQuery({int page = 1, int pageSize = 20}) =>
      filters.toQuery(page, pageSize);
}
