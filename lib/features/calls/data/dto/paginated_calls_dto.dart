import '../../models/call_history_model.dart';

class PaginatedCallsDto {
  final int count;
  final String? next;
  final String? previous;
  final List<CallHistoryModel> results;

  const PaginatedCallsDto({
    this.count = 0,
    this.next,
    this.previous,
    this.results = const [],
  });

  factory PaginatedCallsDto.fromJson(Map<String, dynamic> json) {
    final resultsList = json['results'] ?? json['items'] ?? json['data'] ?? [];
    return PaginatedCallsDto(
      count: json['count'] ??
          json['total'] ??
          (resultsList is List ? resultsList.length : 0),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (resultsList as List? ?? [])
          .whereType<Map>()
          .map((m) => CallHistoryModel.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
    );
  }
}
