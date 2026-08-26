enum DashboardTimelineState { completed, current, upcoming }

enum DashboardCallAction { view, callNow, call, email }

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.generatedAt,
    required this.timezone,
    required this.date,
    required this.kpi,
    required this.todayCalls,
    required this.callReports,
  });

  final DateTime generatedAt;
  final String timezone;
  final DateTime date;
  final DashboardKpi kpi;
  final DashboardTodayCalls todayCalls;
  final DashboardCallReports callReports;
}

class DashboardKpi {
  const DashboardKpi({
    required this.totalCalls,
    required this.callsToday,
    required this.successRate,
    required this.totalFollowUps,
  });

  final int totalCalls;
  final int callsToday;
  final double successRate;
  final int totalFollowUps;
}

class DashboardTodayCalls {
  const DashboardTodayCalls({
    required this.date,
    required this.count,
    required this.hasMore,
    required this.items,
  });

  final DateTime date;
  final int count;
  final bool hasMore;
  final List<DashboardTodayCall> items;
}

class DashboardTodayCall {
  const DashboardTodayCall({
    required this.id,
    required this.customerId,
    required this.fullName,
    required this.companyName,
    required this.purpose,
    required this.scenarioId,
    required this.phone,
    required this.email,
    required this.leadPriority,
    required this.status,
    required this.scheduledFor,
    required this.timeLabel,
    required this.meridiem,
    required this.timelineState,
    required this.availableActions,
    required this.isOverdue,
  });

  final String id;
  final String? customerId;
  final String fullName;
  final String companyName;
  final String purpose;
  final String? scenarioId;
  final String phone;
  final String email;
  final String leadPriority;
  final String status;
  final DateTime? scheduledFor;
  final String timeLabel;
  final String meridiem;
  final DashboardTimelineState timelineState;
  final List<DashboardCallAction> availableActions;
  final bool isOverdue;

  bool get isPriority => leadPriority.toLowerCase() == 'hot';
  bool get isDone => timelineState == DashboardTimelineState.completed;
  bool get isCurrent => timelineState == DashboardTimelineState.current;
}

class DashboardCallReports {
  const DashboardCallReports({required this.total, required this.items});

  final int total;
  final List<DashboardCallReportItem> items;
}

class DashboardCallReportItem {
  const DashboardCallReportItem({
    required this.key,
    required this.label,
    required this.count,
    required this.percentage,
    required this.colorHex,
  });

  final String key;
  final String label;
  final int count;
  final double percentage;
  final String colorHex;
}
