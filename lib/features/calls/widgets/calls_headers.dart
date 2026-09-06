import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/advanced_filter_dialog.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/calls/widgets/clean_date_range_picker.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class CallsHeaders extends StatefulWidget {
  final String selectedStatus;
  final String selectedSort;
  final DateTimeRange? selectedDateRange;
  final AdvancedFilterState? filterState;
  final Map<String, int> statusCounts;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSortChanged;
  final ValueChanged<AdvancedFilterState>? onFilterApplied;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onCallAdded;

  const CallsHeaders({
    super.key,
    required this.selectedStatus,
    this.selectedSort = 'Default',
    required this.selectedDateRange,
    this.filterState,
    required this.statusCounts,
    required this.onStatusChanged,
    this.onSearchChanged,
    this.onSortChanged,
    this.onFilterApplied,
    required this.onDateRangeChanged,
    required this.onCallAdded,
  });

  @override
  State<CallsHeaders> createState() => _CallsHeadersState();
}

class _CallsHeadersState extends State<CallsHeaders> {
  late final TextEditingController _searchCtrl;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchCtrl.text.isEmpty) {
        setState(() {
          _isSearchExpanded = false;
        });
      }
    });
  }

  void _onSearchChanged() {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(_searchCtrl.text);
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  final List<String> _statuses = const [
    'All',
    'Completed',
    'Failed',
    'Queued',
    'Upcoming'
  ];

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: maxWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: New Call Button
            Row(
              children: [
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    onPressed: () async {
                      await CallActionDialog.show(context);
                      widget.onCallAdded();
                    },
                    icon: const Icon(CupertinoIcons.phone_solid,
                        size: 15, color: Colors.white),
                    label: const Text(
                      'NEW CALL',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : context.colors.lightGreyColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    onPressed: () async {
                      await CallActionDialog.show(context,
                          startInGroupMode: true);
                      widget.onCallAdded();
                    },
                    icon: Icon(CupertinoIcons.person_3_fill,
                        size: 15, color: Theme.of(context).colorScheme.primary),
                    label: Text(
                      'BATCH CALL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Right side: Expandable Search, Status Dropdown, Time Range, Filter, Sort
            Row(
              children: [
                // Expandable Search
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                      ? 200
                      : 36,
                  height: 36,
                  child: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : context.colors.lightGreyColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Icon(CupertinoIcons.search,
                                  size: 15,
                                  color: context.colors.darkGreyColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  focusNode: _searchFocusNode,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search calls...',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.darkGreyColor,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  _searchFocusNode.unfocus();
                                  setState(() {
                                    _isSearchExpanded = false;
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(CupertinoIcons.clear_thick,
                                      size: 12,
                                      color: context.colors.darkGreyColor),
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              _isSearchExpanded = true;
                            });
                            Future.delayed(const Duration(milliseconds: 50),
                                () {
                              _searchFocusNode.requestFocus();
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : context.colors.lightGreyColor,
                              ),
                            ),
                            child: Center(
                              child: Icon(CupertinoIcons.search,
                                  size: 15,
                                  color: context.colors.darkGreyColor),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),

                // Status Dropdown Filter (Without Arrow)
                PopupMenuButton<String>(
                  onSelected: widget.onStatusChanged,
                  offset: const Offset(0, 40),
                  color: isDark ? AppColors.darkSlateColor : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  itemBuilder: (context) => _statuses.map((status) {
                    final isSelected = widget.selectedStatus.toLowerCase() ==
                        status.toLowerCase();
                    return PopupMenuItem<String>(
                      value: status,
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.selectedStatus != 'All'
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.selectedStatus != 'All'
                            ? Theme.of(context).colorScheme.primary
                            : (isDark
                                ? Colors.white10
                                : context.colors.lightGreyColor),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.line_horizontal_3_decrease,
                          size: 14,
                          color: widget.selectedStatus != 'All'
                              ? Theme.of(context).colorScheme.primary
                              : context.colors.darkGreyColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.selectedStatus == 'All'
                              ? 'Status'
                              : widget.selectedStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.selectedStatus != 'All'
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Date / Time Range Filter
                InkWell(
                  onTap: () async {
                    final picked = await showDialog<DateTimeRange>(
                      context: context,
                      builder: (context) => CleanDateRangePicker(
                        initialRange: widget.selectedDateRange,
                      ),
                    );
                    if (picked != null) {
                      if (picked.start.year == 1970 &&
                          picked.end.year == 1970) {
                        widget.onDateRangeChanged(null);
                      } else {
                        widget.onDateRangeChanged(picked);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: widget.selectedDateRange != null
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.selectedDateRange != null
                            ? Theme.of(context).colorScheme.primary
                            : (isDark
                                ? Colors.white10
                                : context.colors.lightGreyColor),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 14,
                          color: widget.selectedDateRange != null
                              ? Theme.of(context).colorScheme.primary
                              : context.colors.darkGreyColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.selectedDateRange == null
                              ? 'Date'
                              : AppDateTime.displayRange(
                                  widget.selectedDateRange!.start,
                                  widget.selectedDateRange!.end,
                                ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.selectedDateRange != null
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        if (widget.selectedDateRange != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => widget.onDateRangeChanged(null),
                            child: Icon(
                              CupertinoIcons.clear_thick,
                              size: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Advanced Filter Button
                Builder(
                  builder: (context) {
                    final hasActiveFilters = widget.filterState != null &&
                        widget.filterState!.isActive;
                    final activeCount = widget.filterState?.activeCount ?? 0;

                    return InkWell(
                      onTap: () async {
                        final result = await AdvancedFilterDialog.show(
                          context,
                          initialState: widget.filterState,
                        );
                        if (result != null && widget.onFilterApplied != null) {
                          widget.onFilterApplied!(result);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: hasActiveFilters
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: hasActiveFilters
                                ? Theme.of(context).colorScheme.primary
                                : (isDark
                                    ? Colors.white10
                                    : context.colors.lightGreyColor),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.slider_horizontal_3,
                              size: 15,
                              color: hasActiveFilters
                                  ? Theme.of(context).colorScheme.primary
                                  : context.colors.darkGreyColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: hasActiveFilters
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$activeCount',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),

                // Sort Menu
                Builder(
                  builder: (context) {
                    final isSortActive = widget.selectedSort != 'Default';
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        if (widget.onSortChanged != null) {
                          widget.onSortChanged!(value);
                        }
                      },
                      itemBuilder: (context) {
                        final options = const [
                          'Default',
                          'Date (Newest)',
                          'Date (Oldest)',
                          'Customer (A-Z)',
                          'Customer (Z-A)',
                        ];
                        return options.map((opt) {
                          final isSelected = widget.selectedSort == opt;
                          return PopupMenuItem<String>(
                            value: opt,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  opt == 'Default' ? 'Default (None)' : opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      offset: const Offset(0, 40),
                      color: isDark ? AppColors.darkSlateColor : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSortActive
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSortActive
                                ? Theme.of(context).colorScheme.primary
                                : (isDark
                                    ? Colors.white10
                                    : context.colors.lightGreyColor),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              size: 14,
                              color: isSortActive
                                  ? Theme.of(context).colorScheme.primary
                                  : context.colors.darkGreyColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSortActive ? widget.selectedSort : 'Sort',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSortActive
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
