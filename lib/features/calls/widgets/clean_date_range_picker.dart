import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_date_time_picker.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class CleanDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialRange;

  const CleanDateRangePicker({super.key, this.initialRange});

  @override
  State<CleanDateRangePicker> createState() => _CleanDateRangePickerState();
}

class _CleanDateRangePickerState extends State<CleanDateRangePicker> {
  bool isCustomMode = false;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialRange?.start;
    endDate = widget.initialRange?.end;
    if (widget.initialRange != null &&
        !(widget.initialRange!.start.year == 1970 &&
            widget.initialRange!.end.year == 1970)) {
      isCustomMode = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildPresetItem(String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildDateSelectorBox({
      required String label,
      required DateTime? date,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colors.lightGreyColor,
              ),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
              color: context.colors.milkyColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.colors.darkGreyColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        date != null
                            ? AppDateTime.displayDate(date)
                            : 'Select Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              date != null ? FontWeight.w600 : FontWeight.w400,
                          color: date != null
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.grey[600] : Colors.grey[500]),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: date != null
                          ? context.colors.primaryLightColor
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSlateColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 320,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isCustomMode ? 'CUSTOM DATE RANGE' : 'FILTER BY DATE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (!isCustomMode) ...[
              buildPresetItem(
                'All Time',
                () => Navigator.pop(
                  context,
                  DateTimeRange(
                    start: DateTime(1970),
                    end: DateTime(1970),
                  ),
                ),
              ),
              buildPresetItem('Today', () {
                final now = DateTime.now();
                Navigator.pop(
                  context,
                  DateTimeRange(
                    start: DateTime(now.year, now.month, now.day),
                    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                  ),
                );
              }),
              buildPresetItem('Yesterday', () {
                final yesterday =
                    DateTime.now().subtract(const Duration(days: 1));
                Navigator.pop(
                  context,
                  DateTimeRange(
                    start: DateTime(
                        yesterday.year, yesterday.month, yesterday.day),
                    end: DateTime(yesterday.year, yesterday.month,
                        yesterday.day, 23, 59, 59),
                  ),
                );
              }),
              buildPresetItem('Last 7 Days', () {
                final now = DateTime.now();
                final sevenDaysAgo = now.subtract(const Duration(days: 6));
                Navigator.pop(
                  context,
                  DateTimeRange(
                    start: DateTime(sevenDaysAgo.year, sevenDaysAgo.month,
                        sevenDaysAgo.day),
                    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                  ),
                );
              }),
              buildPresetItem('Last 30 Days', () {
                final now = DateTime.now();
                final thirtyDaysAgo = now.subtract(const Duration(days: 29));
                Navigator.pop(
                  context,
                  DateTimeRange(
                    start: DateTime(thirtyDaysAgo.year, thirtyDaysAgo.month,
                        thirtyDaysAgo.day),
                    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
                  ),
                );
              }),
              buildPresetItem(
                'Custom Range...',
                () => setState(() => isCustomMode = true),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.colors.lightGreyColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        buildDateSelectorBox(
                          label: 'FROM',
                          date: startDate,
                          onTap: () async {
                            final picked = await AppDateTimePicker.pickDate(
                              context,
                              initial: startDate,
                              first: DateTime(2020),
                              last: endDate ??
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                        ),
                        SizedBox(width: 12),
                        buildDateSelectorBox(
                          label: 'TO',
                          date: endDate,
                          onTap: () async {
                            final picked = await AppDateTimePicker.pickDate(
                              context,
                              initial: endDate,
                              first: startDate ?? DateTime(2020),
                              last:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                endDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: startDate != null && endDate != null
                            ? () {
                                Navigator.pop(
                                  context,
                                  DateTimeRange(
                                    start: DateTime(startDate!.year,
                                        startDate!.month, startDate!.day),
                                    end: DateTime(endDate!.year, endDate!.month,
                                        endDate!.day, 23, 59, 59),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primaryLightColor,
                          disabledBackgroundColor: isDark
                              ? Colors.white10
                              : Colors.black.withAlpha(10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                        ),
                        child: Text(
                          'APPLY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: startDate != null && endDate != null
                                ? Colors.white
                                : (isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            isCustomMode = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: context.colors.lightGreyColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                        ),
                        child: Text(
                          'BACK',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
