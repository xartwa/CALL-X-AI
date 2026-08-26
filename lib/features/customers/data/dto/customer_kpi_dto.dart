import '../../domain/repositories/customer_repository.dart';

class CustomerKpiDto {
  const CustomerKpiDto(this.json);
  final Map<String, dynamic> json;
  CustomerKpi toEntity() => CustomerKpi(
        totalCustomers: _int(json['totalCustomers']),
        activeAccounts: _int(json['activeAccounts']),
        inactiveAccounts: _int(json['inactiveAccounts']),
        contactedToday: _int(json['contactedToday']),
        date: DateTime.tryParse('${json['date']}'),
      );
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
