class CallsKpiDto {
  final int totalCalls;
  final int completedCalls;
  final int failedCalls;
  final int pendingUpcoming;
  final Map<String, int> statusCounts;

  const CallsKpiDto({
    this.totalCalls = 0,
    this.completedCalls = 0,
    this.failedCalls = 0,
    this.pendingUpcoming = 0,
    this.statusCounts = const {},
  });

  factory CallsKpiDto.fromJson(Map<String, dynamic> json) {
    final statusCountsRaw = json['status_counts'] ?? json['statusCounts'] ?? {};
    final Map<String, int> counts = {};
    if (statusCountsRaw is Map) {
      statusCountsRaw.forEach((k, v) {
        counts[k.toString().toLowerCase()] = (v is num) ? v.toInt() : 0;
      });
    }

    return CallsKpiDto(
      totalCalls:
          json['total_calls'] ?? json['totalCalls'] ?? json['total'] ?? 0,
      completedCalls: json['completed_calls'] ??
          json['completedCalls'] ??
          json['completed'] ??
          0,
      failedCalls:
          json['failed_calls'] ?? json['failedCalls'] ?? json['failed'] ?? 0,
      pendingUpcoming: json['pending_and_upcoming'] ??
          json['pending_upcoming'] ??
          json['pendingAndUpcoming'] ??
          json['pending'] ??
          0,
      statusCounts: counts,
    );
  }
}
