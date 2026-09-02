import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/calls/widgets/clean_date_range_picker.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class EmailFollowUpsHeaders extends StatefulWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final int sentCount;
  final int templatesCount;
  final String selectedStatus;
  final String selectedCategory;
  final String selectedSort;
  final DateTimeRange? selectedDateRange;
  final Map<String, int> statusCounts;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSortChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onComposePressed;
  final VoidCallback onBatchEmailPressed;
  final VoidCallback onNewTemplatePressed;

  const EmailFollowUpsHeaders({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.sentCount,
    required this.templatesCount,
    required this.selectedStatus,
    this.selectedCategory = 'All',
    this.selectedSort = 'Default',
    required this.selectedDateRange,
    required this.statusCounts,
    required this.onStatusChanged,
    this.onCategoryChanged,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E293B)
              : context.colors.mediumGreyColor.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 1050;

          final tabSwitcherAndActions = Row(
            mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                isNarrow ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              // Segmented Tab Switcher
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentTab(
                      index: 0,
                      label: 'Sent History',
                      count: widget.sentCount,
                      icon: CupertinoIcons.clock_fill,
                      isSelected: widget.selectedTab == 0,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    _buildSegmentTab(
                      index: 1,
                      label: 'Email Templates',
                      count: widget.templatesCount,
                      icon: CupertinoIcons.doc_plaintext,
                      isSelected: widget.selectedTab == 1,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Divider
              if (!isNarrow) ...[
                Container(
                  height: 22,
                  width: 1,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
                const SizedBox(width: 14),
              ],

              // Contextual Action Buttons
              if (widget.selectedTab == 0) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                        ),
                        onPressed: widget.onComposePressed,
                        icon: const Icon(CupertinoIcons.mail_solid,
                            size: 14, color: Colors.white),
                        label: const Text(
                          'COMPOSE EMAIL',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
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
                                ? const Color(0xFF1E293B)
                                : context.colors.lightGreyColor,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                          ),
                        ),
                        onPressed: widget.onBatchEmailPressed,
                        icon: Icon(CupertinoIcons.person_3_fill,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary),
                        label: Text(
                          'BATCH EMAIL',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    onPressed: widget.onNewTemplatePressed,
                    icon: const Icon(CupertinoIcons.plus_circle_fill,
                        size: 14, color: Colors.white),
                    label: const Text(
                      'NEW TEMPLATE',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );

          final filterControls = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expandable Search Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                    ? 190
                    : 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                      ? (isDark
                          ? const Color(0xFF131C2E)
                          : context.colors.lightGreyColor
                              .withValues(alpha: 0.4))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                        ? Theme.of(context).colorScheme.primary
                        : (isDark
                            ? const Color(0xFF1E293B)
                            : context.colors.lightGreyColor),
                  ),
                ),
                child: (_isSearchExpanded || _searchCtrl.text.isNotEmpty)
                    ? Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            CupertinoIcons.search,
                            size: 13,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: widget.selectedTab == 0
                                    ? 'Search emails...'
                                    : 'Search templates...',
                                hintStyle: TextStyle(
                                  fontSize: 11.5,
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
                                size: 13,
                                color: context.colors.darkGreyColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () {
                          setState(() => _isSearchExpanded = true);
                          Future.delayed(const Duration(milliseconds: 80), () {
                            _searchFocusNode.requestFocus();
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.search,
                            size: 14,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ),
              ),

              const SizedBox(width: 8),

              // Filter Controls (Contextual to Active Tab)
              if (widget.selectedTab == 0) ...[
                // Status Dropdown
                _buildStatusDropdown(context, isDark),
                const SizedBox(width: 8),

                // Date Range
                _buildDateRangePicker(context, isDark),
                const SizedBox(width: 8),

                // Sort Dropdown
                _buildSortDropdown(context, isDark, false),
              ] else ...[
                // Category Filter
                _buildCategoryDropdown(context, isDark),
                const SizedBox(width: 8),

                // Sort Dropdown for Templates
                _buildSortDropdown(context, isDark, true),
              ],
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabSwitcherAndActions,
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [filterControls],
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              tabSwitcherAndActions,
              filterControls,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentTab({
    required int index,
    required String label,
    required int count,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => widget.onTabChanged(index),
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? activeColor
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? activeColor
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, bool isDark) {
    final statuses = const [
      'All',
      'Sent',
      'Pending',
      'Delivered',
      'Opened',
      'Failed',
      'Draft',
    ];

    return PopupMenuButton<String>(
      onSelected: widget.onStatusChanged,
      itemBuilder: (context) {
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
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: widget.selectedStatus != 'All'
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: widget.selectedStatus != 'All'
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF1E293B) : context.colors.lightGreyColor),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.line_horizontal_3_decrease,
              size: 13,
              color: widget.selectedStatus != 'All'
                  ? Theme.of(context).colorScheme.primary
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 5),
            Text(
              widget.selectedStatus == 'All'
                  ? 'Status'
                  : widget.selectedStatus,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: widget.selectedStatus != 'All'
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, bool isDark) {
    final categories = const [
      'All',
      'Outreach',
      'Follow-Up & Closing',
      'Meeting',
      'Consultation',
      'Sales',
    ];

    return PopupMenuButton<String>(
      onSelected: (cat) {
        widget.onCategoryChanged?.call(cat);
      },
      itemBuilder: (context) {
        return categories.map((cat) {
          final isSelected = widget.selectedCategory == cat;
          return PopupMenuItem<String>(
            value: cat,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (isSelected)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      offset: const Offset(0, 40),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: widget.selectedCategory != 'All'
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: widget.selectedCategory != 'All'
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF1E293B) : context.colors.lightGreyColor),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.tag,
              size: 13,
              color: widget.selectedCategory != 'All'
                  ? Theme.of(context).colorScheme.primary
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 5),
            Text(
              widget.selectedCategory == 'All'
                  ? 'Category'
                  : widget.selectedCategory,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: widget.selectedCategory != 'All'
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () async {
        final picked = await showDialog<DateTimeRange>(
          context: context,
          builder: (context) => CleanDateRangePicker(
            initialRange: widget.selectedDateRange,
          ),
        );
        if (picked != null) {
          if (picked.start.year == 1970 && picked.end.year == 1970) {
            widget.onDateRangeChanged(null);
          } else {
            widget.onDateRangeChanged(picked);
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: widget.selectedDateRange != null
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: widget.selectedDateRange != null
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF1E293B) : context.colors.lightGreyColor),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 13,
              color: widget.selectedDateRange != null
                  ? Theme.of(context).colorScheme.primary
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 5),
            Text(
              widget.selectedDateRange == null
                  ? 'Date'
                  : AppDateTime.displayRange(
                      widget.selectedDateRange!.start,
                      widget.selectedDateRange!.end,
                    ),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: widget.selectedDateRange != null
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            if (widget.selectedDateRange != null) ...[
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => widget.onDateRangeChanged(null),
                child: Icon(
                  CupertinoIcons.clear_thick,
                  size: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context, bool isDark, bool isTemplate) {
    final options = isTemplate
        ? const [
            'Default',
            'Name (A-Z)',
            'Name (Z-A)',
            'Subject (A-Z)',
          ]
        : const [
            'Default',
            'Date (Newest)',
            'Date (Oldest)',
            'Recipient (A-Z)',
            'Recipient (Z-A)',
            'Subject (A-Z)',
          ];

    final isSortActive = widget.selectedSort != 'Default';

    return PopupMenuButton<String>(
      onSelected: (value) {
        widget.onSortChanged?.call(value);
      },
      itemBuilder: (context) {
        return options.map((opt) {
          final isSelected = widget.selectedSort == opt;
          return PopupMenuItem<String>(
            value: opt,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  opt == 'Default' ? 'Default' : opt,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (isSelected)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList();
      },
      offset: const Offset(0, 40),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSortActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: isSortActive
                ? Theme.of(context).colorScheme.primary
                : (isDark ? const Color(0xFF1E293B) : context.colors.lightGreyColor),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.arrow_up_arrow_down,
              size: 13,
              color: isSortActive
                  ? Theme.of(context).colorScheme.primary
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 5),
            Text(
              isSortActive ? widget.selectedSort : 'Sort',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isSortActive
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
