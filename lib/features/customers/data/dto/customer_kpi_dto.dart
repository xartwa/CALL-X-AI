import '../../domain/repositories/customer_repository.dart';
import '../../../../core/utils/app_date_time.dart';

class CustomerKpiDto {
  const CustomerKpiDto(this.rawJson);
  final Map<String, dynamic> rawJson;

  Map<String, dynamic> get json {
    if (rawJson['data'] is Map) {
      return Map<String, dynamic>.from(rawJson['data'] as Map);
    }
    if (rawJson['results'] is Map) {
      return Map<String, dynamic>.from(rawJson['results'] as Map);
    }
    if (rawJson['kpi'] is Map) {
      return Map<String, dynamic>.from(rawJson['kpi'] as Map);
    }
    return rawJson;
  }

  CustomerKpi toEntity() => CustomerKpi(
        totalCustomers: _int(json['totalCustomers'] ??
            json['total_customers'] ??
            json['total'] ??
            json['totalCount'] ??
            json['total_count']),
        activeAccounts: _int(json['activeAccounts'] ??
            json['active_accounts'] ??
            json['active']),
        inactiveAccounts: _int(json['inactiveAccounts'] ??
            json['inactive_accounts'] ??
            json['inactive'] ??
            json['deactive_accounts'] ??
            json['deactive']),
        contactedToday: _int(json['contactedToday'] ??
            json['contacted_today'] ??
            json['contacted']),
        date: AppDateTime.tryParseApiDate(
            json['date'] ?? json['updated_at'] ?? json['updatedAt']),
      );
}

int _int(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
