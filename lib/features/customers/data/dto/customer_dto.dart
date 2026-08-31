import '../../domain/entities/customer.dart';

class CustomerDto {
  const CustomerDto(this.json);
  final Map<String, dynamic> json;

  Customer toEntity() => Customer.fromJson(json);
}

class PaginatedCustomersDto {
  const PaginatedCustomersDto(this.json);
  final Map<String, dynamic> json;

  List<Customer> get customers {
    final rawList =
        json['results'] ?? json['customers'] ?? json['items'] ?? json['data'];
    final list = rawList is List ? rawList : const [];
    return list
        .whereType<Map>()
        .map((item) => CustomerDto(Map<String, dynamic>.from(item)).toEntity())
        .toList(growable: false);
  }
}
