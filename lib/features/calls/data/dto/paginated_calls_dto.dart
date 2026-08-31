import '../../models/call_history_model.dart';

class PaginatedCallsDto {
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final String? next;
  final String? previous;
  final List<CallHistoryModel> results;

  const PaginatedCallsDto({
    this.count = 0,
    this.totalPages = 1,
    this.currentPage = 1,
    this.pageSize = 10,
    this.next,
    this.previous,
    this.results = const [],
  });

  factory PaginatedCallsDto.fromJson(
    Map<String, dynamic> json, {
    int page = 1,
    int requestedPageSize = 10,
  }) {
    final resultsList = json['results'] ?? json['items'] ?? json['data'] ?? [];
    final rawResults = (resultsList as List? ?? [])
        .whereType<Map>()
        .map((m) => CallHistoryModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final count = json['count'] ?? json['total'] ?? rawResults.length;
    final parsedCount = count is num
        ? count.toInt()
        : int.tryParse('$count') ?? rawResults.length;

    final pSize = json['pageSize'] ?? json['page_size'] ?? requestedPageSize;
    final parsedPageSize = pSize is num
        ? pSize.toInt()
        : int.tryParse('$pSize') ?? requestedPageSize;
    final validPageSize = parsedPageSize > 0 ? parsedPageSize : 10;

    final computedTotalPages =
        (parsedCount / validPageSize).ceil().clamp(1, 9999);
    final totalPages =
        json['totalPages'] ?? json['total_pages'] ?? computedTotalPages;
    final parsedTotalPages = totalPages is num
        ? totalPages.toInt()
        : int.tryParse('$totalPages') ?? computedTotalPages;

    List<CallHistoryModel> finalResults = rawResults;
    if (rawResults.length > validPageSize && rawResults.length >= parsedCount) {
      final startIndex =
          ((page - 1) * validPageSize).clamp(0, rawResults.length);
      final endIndex = (startIndex + validPageSize).clamp(0, rawResults.length);
      finalResults = rawResults.sublist(startIndex, endIndex);
    }

    return PaginatedCallsDto(
      count: parsedCount,
      totalPages: parsedTotalPages,
      currentPage: page,
      pageSize: validPageSize,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: finalResults,
    );
  }
}
