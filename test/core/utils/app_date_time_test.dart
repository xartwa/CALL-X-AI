import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDateTime', () {
    test('uses the shared human-readable display formats', () {
      final value = DateTime(2026, 1, 17, 14, 30);

      expect(AppDateTime.displayDate(value), '17 Jan 2026');
      expect(AppDateTime.displayDateTime(value), '17 Jan 2026 • 14:30');
      expect(AppDateTime.displayTime(value), '14:30');
      expect(AppDateTime.displayWeekdayDate(value), 'Saturday, 17 Jan 2026');
    });

    test('uses numeric date and UTC ISO datetime for transport', () {
      expect(AppDateTime.apiDate(DateTime(2026, 1, 17)), '2026-01-17');
      expect(
        AppDateTime.apiDateTime(DateTime.utc(2026, 1, 17, 14, 30)),
        '2026-01-17T14:30:00Z',
      );
    });

    test('enforces strict date and timezone-aware datetime API inputs', () {
      expect(AppDateTime.tryParseApiDate('2026-01-17'), DateTime(2026, 1, 17));
      expect(AppDateTime.tryParseApiDate('2026/01/17'), isNull);
      expect(
        AppDateTime.tryParseApiDateTime('2026-01-17T14:30:00Z'),
        DateTime.utc(2026, 1, 17, 14, 30),
      );
      expect(
        AppDateTime.tryParseApiDateTime('2026-01-17T14:30:00'),
        isNull,
      );
    });

    test('parses ISO and supported slash-separated legacy values', () {
      expect(AppDateTime.tryParse('2026-01-17T14:30:00Z'), isNotNull);
      expect(
        AppDateTime.displayDateTimeParts('2026/01/17', '14:30'),
        '17 Jan 2026 • 14:30',
      );
      expect(
        AppDateTime.displayDateOrDateTime('2026/01/17'),
        '17 Jan 2026',
      );
    });

    test('returns explicit fallbacks for missing or invalid values', () {
      expect(AppDateTime.displayDateTime(null), '-');
      expect(
        AppDateTime.displayDate('not-a-date', fallback: 'Unavailable'),
        'Unavailable',
      );
    });

    test('compares date ranges without time-of-day leakage', () {
      expect(
        AppDateTime.isWithinDateRange(
          '2026-01-17T23:45:00',
          DateTime(2026, 1, 17),
          DateTime(2026, 1, 17),
        ),
        isTrue,
      );
    });
  });
}
