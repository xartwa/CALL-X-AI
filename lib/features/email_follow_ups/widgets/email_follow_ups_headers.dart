import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/calls/widgets/clean_date_range_picker.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class EmailFollowUpsHeaders extends StatefulWidget {
  final String selectedStatus;
  final String selectedSort;
  final DateTimeRange? selectedDateRange;
  final Map<String, int> statusCounts;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSortChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onComposePressed;
  final VoidCallback onBatchEmailPressed;
  final VoidCallback onNewTemplatePressed;

  const EmailFollowUpsHeaders({
    super.key,
    required this.selectedStatus,
    this.selectedSort = 'Default',
    required this.selectedDateRange,
    required this.statusCounts,
    required this.onStatusChanged,
    this.onSearchChanged,
    this.onSortChanged,
    required this.onDateRangeChanged,
    required this.onComposePressed,
    required this.onBatchEmailPressed,
    required this.onNewTemplatePressed,
  });

  @override
  State<EmailFollowUpsHeaders> createState() => _EmailFollowUpsHeadersState();
}

class _EmailFollowUpsHeadersState extends State<EmailFollowUpsHeaders> {
  late final TextEditingController _searchCtrl;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    widget.onSearchChanged?.call(_searchCtrl.text);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        children: [
          // Toolbar: Left Action Buttons | Right Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Compose Email + Batch Email + New Template
              Row(
                children: [
                  SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                      onPressed: widget.onComposePressed,
                      icon: const Icon(CupertinoIcons.mail_solid,
                          size: 15, color: Colors.white),
                      label: const Text(
                        'COMPOSE EMAIL',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                      onPressed: widget.onBatchEmailPressed,
                      icon: Icon(CupertinoIcons.person_3_fill,
                          size: 15,
                          color: Theme.of(context).colorScheme.primary),
                      label: Text(
                        'BATCH EMAIL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
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
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                        ),
                      ),
                      onPressed: widget.onNewTemplatePressed,
                      icon: Icon(CupertinoIcons.doc_text_fill,
                          size: 15,
                          color: Theme.of(context).colorScheme.primary),
                      label: Text(
                        'NEW TEMPLATE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Right: Expandable Search + Status + Date Range + Sort
              Row(
                children: [
                  // Expandable Search Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                        ? 200
                        : 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03))
                          : Colors.transparent,
                      border: Border.all(
                        color:
                            (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                                ? Theme.of(context).colorScheme.primary
                                : (isDark
                                    ? Colors.white10
                                    : context.colors.lightGreyColor),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                        ? Row(
                            children: [
                              const SizedBox(width: 8),
                              Icon(
                                CupertinoIcons.search,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: 'Search emails...',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.darkGreyColor,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  _searchFocusNode.unfocus();
                                  setState(() => _isSearchExpanded = false);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    size: 14,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () {
                              setState(() => _isSearchExpanded = true);
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                _searchFocusNode.requestFocus();
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.search,
                                size: 15,
                                color: context.colors.darkGreyColor,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),

                  // Status Dropdown Filter (Arrow-free)
                  PopupMenuButton<String>(
                    onSelected: widget.onStatusChanged,
                    itemBuilder: (context) {
                      final statuses = [
                        'All',
                        'Sent',
                        'Pending',
                        'Delivered',
                        'Opened',
                        'Failed',
                        'Draft',
                      ];

                      return statuses.map((status) {
                        final isSelected = widget.selectedStatus == status;
                        final count = widget.statusCounts[status] ?? 0;

                        return PopupMenuItem<String>(
                          value: status,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                status,
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black
                                              .withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : context.colors.darkGreyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    offset: const Offset(0, 40),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
                            'Recipient (A-Z)',
                            'Recipient (Z-A)',
                            'Subject (A-Z)',
                          ];
                          return options.map((opt) {
                            final isSelected = widget.selectedSort == opt;
                            return PopupMenuItem<String>(
                              value: opt,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    opt == 'Default' ? 'Default (None)' : opt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
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
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
        ],
      ),
    );
  }
}
