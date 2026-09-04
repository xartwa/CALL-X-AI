import 'package:flutter/material.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

/// The single minimal date/time picker used across the whole application.
///
/// Use [pickDate] for date-only values (filters and ranges) and
/// [pickDateTime] whenever a time of day matters, such as follow-ups.
abstract final class AppDateTimePicker {
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) =>
      _open(
        context,
        includeTime: false,
        initial: initial,
        first: first,
        last: last,
      );

  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) =>
      _open(
        context,
        includeTime: true,
        initial: initial,
        first: first,
        last: last,
      );

  static Future<TimeOfDay?> pickTime(
    BuildContext context, {
    TimeOfDay? initial,
  }) async {
    final now = DateTime.now();
    final initDt = initial != null
        ? DateTime(now.year, now.month, now.day, initial.hour, initial.minute)
        : now;
    final res = await showDialog<DateTime>(
      context: context,
      builder: (_) => _AppDateTimePickerDialog(
        includeTime: true,
        timeOnly: true,
        initial: initDt,
        first: _dateOnly(DateTime(now.year - 1, now.month, now.day)),
        last: _dateOnly(DateTime(now.year + 2, now.month, now.day)),
      ),
    );
    if (res == null) return null;
    return TimeOfDay(hour: res.hour, minute: res.minute);
  }

  static Future<DateTime?> _open(
    BuildContext context, {
    required bool includeTime,
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) {
    final now = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      builder: (_) => _AppDateTimePickerDialog(
        includeTime: includeTime,
        initial: initial,
        first: _dateOnly(first ?? DateTime(now.year - 1, now.month, now.day)),
        last: _dateOnly(last ?? DateTime(now.year + 2, now.month, now.day)),
      ),
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _AppDateTimePickerDialog extends StatefulWidget {
  final bool includeTime;
  final bool timeOnly;
  final DateTime? initial;
  final DateTime first;
  final DateTime last;

  const _AppDateTimePickerDialog({
    required this.includeTime,
    this.timeOnly = false,
    required this.initial,
    required this.first,
    required this.last,
  });

  @override
  State<_AppDateTimePickerDialog> createState() =>
      _AppDateTimePickerDialogState();
}

class _AppDateTimePickerDialogState extends State<_AppDateTimePickerDialog> {
  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthLabels = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  late int _hour;
  late int _minute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final now = DateTime.now();
    var date = initial != null && !_DateBounds.isBefore(initial, widget.first)
        ? initial
        : now;
    if (date.isAfter(widget.last)) date = now;
    _selectedDate = DateTime(date.year, date.month, date.day);
    _visibleMonth = DateTime(date.year, date.month);
    _hour = (initial ?? now).hour;
    _minute = (initial ?? now).minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    if (widget.timeOnly) {
      _showTimeStep = true;
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.colors.primaryLightColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SizedBox(
        width: 352,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                _isTimeStep ? 'SELECT TIME' : 'SELECT DATE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: context.colors.darkGreyColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.timeOnly
                    ? '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}'
                    : widget.includeTime
                        ? AppDateTime.displayDateTime(
                            _combine(_selectedDate, _hour, _minute))
                        : AppDateTime.displayDate(_selectedDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 14),

              // Body
              if (_isTimeStep)
                _buildTimeStep(context, isDark, onSurface)
              else
                _buildDateStep(context, isDark, onSurface),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: () {
                          if (widget.timeOnly) {
                            Navigator.of(context).pop();
                          } else if (_isTimeStep) {
                            setState(() => _stepToDate());
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.darkGreyColor,
                        ),
                        child: Text(widget.timeOnly || !_isTimeStep
                            ? 'CANCEL'
                            : 'BACK'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: () {
                          if (_isTimeStep) {
                            Navigator.of(context).pop(
                              _combine(_selectedDate, _hour, _minute),
                            );
                          } else if (widget.includeTime) {
                            setState(() => _stepToTime());
                          } else {
                            Navigator.of(context).pop(_selectedDate);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(widget.timeOnly || _isTimeStep || !widget.includeTime
                            ? 'CONFIRM'
                            : 'CONTINUE'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isTimeStep => widget.includeTime && _showTimeStep;
  bool _showTimeStep = false;

  void _stepToTime() {
    _showTimeStep = true;
  }

  void _stepToDate() {
    _showTimeStep = false;
  }

  // ------------------------------------------------------------------
  // Date step
  // ------------------------------------------------------------------

  Widget _buildDateStep(BuildContext context, bool isDark, Color onSurface) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMonthSelector(context, isDark),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        ..._buildMonthRows(context, isDark, onSurface),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context, bool isDark) {
    final previousMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    final canGoPrevious = !_DateBounds.isBefore(previousMonth, widget.first);
    final canGoNext = nextMonth.day == 1 &&
        !nextMonth
            .isAfter(DateTime(widget.last.year, widget.last.month + 1, 0));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _navButton(
          icon: Icons.chevron_left_rounded,
          enabled: canGoPrevious,
          onTap: () => setState(() => _visibleMonth = previousMonth),
        ),
        Text(
          '${_monthLabels[_visibleMonth.month - 1]} ${_visibleMonth.year}',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        _navButton(
          icon: Icons.chevron_right_rounded,
          enabled: canGoNext,
          onTap: () => setState(() => _visibleMonth = nextMonth),
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? context.colors.primaryLightColor
              : context.colors.darkGreyColor.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  List<Widget> _buildMonthRows(
      BuildContext context, bool isDark, Color onSurface) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = firstOfMonth.weekday % 7; // Sunday-first grid.

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.expand());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(_buildDayCell(context, isDark, onSurface, day));
    }
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.expand());
    }

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      rows.add(
        SizedBox(
          height: 38,
          child: Row(
            children: [
              for (final cell in cells.sublist(i, i + 7)) Expanded(child: cell),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildDayCell(
      BuildContext context, bool isDark, Color onSurface, int day) {
    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
    final isSelected = date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final enabled = !date.isBefore(widget.first) && !date.isAfter(widget.last);

    return Center(
      child: InkWell(
        onTap: enabled ? () => setState(() => _selectedDate = date) : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? context.colors.primaryLightColor
                : Colors.transparent,
            border: isToday && !isSelected
                ? Border.all(
                    color: context.colors.primaryLightColor, width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight:
                  isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
              color: !enabled
                  ? onSurface.withValues(alpha: 0.22)
                  : isSelected
                      ? Colors.white
                      : onSurface,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Time step
  // ------------------------------------------------------------------

  Widget _buildTimeStep(BuildContext context, bool isDark, Color onSurface) {
    final primary = context.colors.primaryLightColor;
    final bandColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: bandColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Selection band behind the selected hour/minute.
          Positioned(
            top: 62,
            left: 16,
            right: 16,
            height: 44,
            child: Container(
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _timeWheel(
                  count: 24,
                  controller: _hourController,
                  selected: _hour,
                  onChanged: (value) => setState(() => _hour = value),
                ),
              ),
              Text(
                ':',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.colors.darkGreyColor,
                ),
              ),
              Expanded(
                child: _timeWheel(
                  count: 60,
                  controller: _minuteController,
                  selected: _minute,
                  onChanged: (value) => setState(() => _minute = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeWheel({
    required int count,
    required FixedExtentScrollController controller,
    required int selected,
    required ValueChanged<int> onChanged,
  }) {
    final primary = context.colors.primaryLightColor;
    final normalColor = Theme.of(context).colorScheme.onSurface;

    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 44,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 6,
      useMagnifier: true,
      magnification: 1.12,
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildLoopingListDelegate(
        children: List.generate(
          count,
          (i) => Center(
            child: Text(
              '$i'.padLeft(2, '0'),
              style: TextStyle(
                fontSize: 17,
                fontWeight: i == selected ? FontWeight.w800 : FontWeight.w500,
                color: i == selected
                    ? primary
                    : normalColor.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static DateTime _combine(DateTime date, int hour, int minute) =>
      DateTime(date.year, date.month, date.day, hour, minute);
}

/// Small private helper for inclusive date bounds checks.
abstract final class _DateBounds {
  static bool isBefore(DateTime value, DateTime first) {
    final day = DateTime(value.year, value.month, value.day);
    return day.isBefore(DateTime(first.year, first.month, first.day));
  }
}
