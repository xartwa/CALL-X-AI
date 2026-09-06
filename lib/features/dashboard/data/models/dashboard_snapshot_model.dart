import '../../domain/entities/dashboard_snapshot.dart';
import '../../../../core/utils/app_date_time.dart';

class DashboardSnapshotModel {
  const DashboardSnapshotModel._(this.entity);

  final DashboardSnapshot entity;

  factory DashboardSnapshotModel.fromJson(Map<String, dynamic> json) {
    final kpiJson = _map(json['kpi']);
    final callsJson = _map(json['todayCalls']);
    final reportsJson = _map(json['callReports']);
    final generatedAt = AppDateTime.tryParseApiDateTime(json['generatedAt']);
    final date = AppDateTime.tryParseApiDate(json['date']);
    final callsDate = AppDateTime.tryParseApiDate(callsJson['date']);
    if (generatedAt == null || date == null || callsDate == null) {
      throw const FormatException('Invalid dashboard date fields');
    }

    return DashboardSnapshotModel._(
      DashboardSnapshot(
        generatedAt: generatedAt,
        timezone: _string(json['timezone']),
        date: date,
        kpi: DashboardKpi(
          totalCalls: _nonNegativeInt(kpiJson['totalCalls']),
          callsToday: _nonNegativeInt(kpiJson['callsToday']),
          successRate: _percentage(kpiJson['successRate']),
          totalFollowUps: _nonNegativeInt(kpiJson['totalFollowUps']),
        ),
        todayCalls: DashboardTodayCalls(
          date: callsDate,
          count: _nonNegativeInt(callsJson['count']),
          hasMore: callsJson['hasMore'] == true,
          items: _list(callsJson['items'])
              .map(
                  (item) => DashboardTodayCallModel.fromJson(_map(item)).entity)
              .toList(growable: false),
        ),
        callReports: DashboardCallReports(
          total: _nonNegativeInt(reportsJson['total']),
          items: _list(reportsJson['items'])
              .map((item) =>
                  DashboardCallReportItemModel.fromJson(_map(item)).entity)
              .toList(growable: false),
        ),
      ),
    );
  }
}

class DashboardTodayCallModel {
  const DashboardTodayCallModel._(this.entity);

  final DashboardTodayCall entity;

  factory DashboardTodayCallModel.fromJson(Map<String, dynamic> json) {
    final scheduled = AppDateTime.tryParseApiDateTime(json['scheduledFor']);
    return DashboardTodayCallModel._(DashboardTodayCall(
      id: _string(json['id']),
      customerId: _nullableString(json['customerId']),
      fullName: _string(json['fullName']),
      companyName: _string(json['companyName']),
      purpose: _string(json['purpose']),
      scenarioId: _nullableString(json['scenarioId']),
      phone: _string(json['phone']),
      email: _string(json['email']),
      leadPriority: _string(json['leadPriority']),
      status: _string(json['status']),
      scheduledFor: scheduled,
      timeLabel: _string(json['timeLabel']),
      meridiem: _string(json['meridiem']),
      timelineState: _timelineState(json['timelineState']),
      availableActions:
          _list(json['availableActions']).map(_action).toList(growable: false),
      isOverdue: json['isOverdue'] == true,
      outcome: _string(json['outcome']),
      duration: _string(json['duration']),
    ));
  }
}

class DashboardCallReportItemModel {
  const DashboardCallReportItemModel._(this.entity);

  final DashboardCallReportItem entity;

  factory DashboardCallReportItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardCallReportItemModel._(DashboardCallReportItem(
      key: _string(json['key']),
      label: _string(json['label']),
      count: _nonNegativeInt(json['count']),
      percentage: _percentage(json['percentage']),
      colorHex: _string(json['color']),
    ));
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Object?> _list(Object? value) => value is List ? value : const [];

String _string(Object? value) => value?.toString() ?? '';

String? _nullableString(Object? value) => value == null ? null : _string(value);

int _nonNegativeInt(Object? value) {
  final parsed = value is num ? value.toInt() : int.tryParse(_string(value));
  if (parsed == null || parsed < 0) {
    throw const FormatException('Invalid count');
  }
  return parsed;
}

double _percentage(Object? value) {
  final parsed =
      value is num ? value.toDouble() : double.tryParse(_string(value));
  if (parsed == null || parsed < 0 || parsed > 100) {
    throw const FormatException('Invalid percentage');
  }
  return parsed;
}

DashboardTimelineState _timelineState(Object? value) =>
    DashboardTimelineState.values.firstWhere(
      (state) => state.name == _string(value),
      orElse: () => throw const FormatException('Invalid timeline state'),
    );

DashboardCallAction _action(Object? value) {
  final raw = _string(value);
  final normalized = raw == 'call_now' ? 'callNow' : raw;
  return DashboardCallAction.values.firstWhere(
    (action) => action.name == normalized,
    orElse: () => throw const FormatException('Invalid dashboard action'),
  );
}
