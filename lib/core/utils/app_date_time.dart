import 'package:intl/intl.dart';

/// The single date/time contract used by the Flutter application.
///
/// UI values are human-readable and use a 24-hour clock. API date-only values
/// use `yyyy-MM-dd`; API date-times are UTC ISO-8601 values with second
/// precision, for example `2026-01-17T14:30:00Z`.
abstract final class AppDateTime {
  static final DateFormat _displayDate = DateFormat('dd MMM yyyy', 'en_US');
  static final DateFormat _displayDateTime =
      DateFormat('dd MMM yyyy • HH:mm', 'en_US');
  static final DateFormat _displayTime = DateFormat('HH:mm', 'en_US');
  static final DateFormat _displayWeekdayDate =
      DateFormat('EEEE, dd MMM yyyy', 'en_US');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd', 'en_US');

  static final List<DateFormat> _legacyParsers = [
    DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US'),
    DateFormat('yyyy-MM-dd HH:mm', 'en_US'),
    DateFormat('d MMM yyyy HH:mm', 'en_US'),
    DateFormat('MMM d, yyyy HH:mm', 'en_US'),
    DateFormat('d MMM yyyy', 'en_US'),
    DateFormat('MMM d, yyyy', 'en_US'),
    DateFormat('h:mm a', 'en_US'),
    DateFormat('hh:mm a', 'en_US'),
  ];

  static final RegExp _dateOnlyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp _legacyDateOnlyPattern =
      RegExp(r'^\d{4}[-/]\d{2}[-/]\d{2}$');
  static final RegExp _timezonePattern = RegExp(r'(?:[zZ]|[+-]\d{2}:\d{2})$');
  static final RegExp _timeOnlyPattern =
      RegExp(r'^(?:[01]?\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$');

  static DateTime? tryParse(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      final milliseconds = value.abs() < 100000000000 ? value * 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt(),
          isUtc: true);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty || raw == '-' || raw.toLowerCase() == 'never') return null;

    final normalized = raw
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'\s*[•]\s*'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final direct = DateTime.tryParse(normalized) ??
        DateTime.tryParse(normalized.replaceFirst(' ', 'T'));
    if (direct != null) return direct;

    for (final parser in _legacyParsers) {
      try {
        return parser.parseStrict(normalized);
      } on FormatException {
        // Try the next supported legacy format.
      }
    }
    return null;
  }

  static DateTime? tryParseApiDate(Object? value) {
    if (value is DateTime) {
      return DateTime(value.year, value.month, value.day);
    }
    final raw = value?.toString().trim() ?? '';
    if (!_dateOnlyPattern.hasMatch(raw)) return null;
    final parsed = DateTime.tryParse(raw);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? tryParseApiDateTime(Object? value) {
    if (value is DateTime) return value.toUtc();
    final raw = value?.toString().trim() ?? '';
    if (!raw.contains('T') || !_timezonePattern.hasMatch(raw)) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static DateTime? combine(Object? date, Object? time) {
    final rawDate = date?.toString().trim() ?? '';
    final rawTime = time?.toString().trim() ?? '';
    if (rawDate.isEmpty) return tryParse(time);

    final parsedDate = tryParse(rawDate);
    if (parsedDate == null || rawTime.isEmpty) return parsedDate;
    if (!_timeOnlyPattern.hasMatch(rawTime)) {
      return tryParse('$rawDate $rawTime') ?? parsedDate;
    }

    final parts = rawTime.split(':').map(int.parse).toList(growable: false);
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parts[0],
      parts[1],
      parts.length > 2 ? parts[2] : 0,
    );
  }

  static String displayDate(Object? value, {String fallback = '-'}) {
    final parsed = tryParse(value);
    return parsed == null ? fallback : _displayDate.format(_forDisplay(parsed));
  }

  static String displayDateTime(Object? value, {String fallback = '-'}) {
    final parsed = tryParse(value);
    return parsed == null
        ? fallback
        : _displayDateTime.format(_forDisplay(parsed));
  }

  static String displayDateTimeParts(
    Object? date,
    Object? time, {
    String fallback = '-',
  }) {
    final parsed = combine(date, time);
    return parsed == null
        ? fallback
        : _displayDateTime.format(_forDisplay(parsed));
  }

  static String displayDateOrDateTime(Object? value, {String fallback = '-'}) {
    final parsed = tryParse(value);
    if (parsed == null) return fallback;

    final raw = value?.toString().trim() ?? '';
    final isDateOnly = _legacyDateOnlyPattern.hasMatch(raw);
    final hasTime = !isDateOnly &&
        (parsed.hour != 0 ||
            parsed.minute != 0 ||
            parsed.second != 0 ||
            raw.contains('T') ||
            RegExp(r'\d{1,2}:\d{2}').hasMatch(raw));
    return hasTime ? displayDateTime(parsed) : displayDate(parsed);
  }

  static String displayTime(Object? value, {String fallback = '-'}) {
    if (value is String && _timeOnlyPattern.hasMatch(value.trim())) {
      final parts = value.trim().split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1]}';
    }
    final parsed = tryParse(value);
    return parsed == null ? fallback : _displayTime.format(_forDisplay(parsed));
  }

  static String displayWeekdayDate(Object? value, {String fallback = '-'}) {
    final parsed = tryParse(value);
    return parsed == null
        ? fallback
        : _displayWeekdayDate.format(_forDisplay(parsed));
  }

  static String displayRange(DateTime start, DateTime end) =>
      '${displayDate(start)} – ${displayDate(end)}';

  static String apiDate(DateTime value) => _apiDate.format(value);

  static String apiDateTime(DateTime value) {
    final utc = value.toUtc();
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '${_apiDate.format(utc)}T$hour:$minute:${second}Z';
  }

  static bool isWithinDateRange(
    Object? value,
    DateTime start,
    DateTime end,
  ) {
    final parsed = tryParse(value);
    if (parsed == null) return false;
    final local = _forDisplay(parsed);
    final day = DateTime(local.year, local.month, local.day);
    final first = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    return !day.isBefore(first) && !day.isAfter(last);
  }

  static DateTime _forDisplay(DateTime value) =>
      value.isUtc ? value.toLocal() : value;
}
