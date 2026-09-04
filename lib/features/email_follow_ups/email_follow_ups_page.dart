import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/email_follow_ups_headers.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/email_follow_ups_tabs.dart';

import 'package:callx_ai/features/email_follow_ups/widgets/email_preview_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/manage_template_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/cubit/email_follow_ups_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/utils/utils.dart';

class EmailFollowUpsPage extends StatefulWidget {
  const EmailFollowUpsPage({super.key});

  @override
  State<EmailFollowUpsPage> createState() => _EmailFollowUpsPageState();
}

class _EmailFollowUpsPageState extends State<EmailFollowUpsPage> {
  int _selectedTabIndex = 0; // 0 = Sent History, 1 = Email Templates
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  String _selectedSort = 'Default';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmailFollowUpsCubit>().loadInitial();
        context.read<CustomersCubit>().loadInitial(resetFilters: false);
      }
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<EmailFollowUpsCubit>().refresh(),
      context.read<CustomersCubit>().refresh(),
    ]);
  }

  List<Map<String, dynamic>> get _allTemplates => context
      .read<EmailFollowUpsCubit>()
      .state
      .templates
      .map((template) => template.toViewMap())
      .toList(growable: false);

  List<Map<String, dynamic>> get _allEmails {
    final state = context.read<EmailFollowUpsCubit>().state;
    final templates = {for (final item in state.templates) item.id: item};
    return state.logs
        .map((log) => log.toViewMap(templates))
        .toList(growable: false);
  }

  Map<String, int> get _statusCounts {
    final counts = <String, int>{'All': _allEmails.length};
    for (final email in _allEmails) {
      final s = (email['status'] ?? 'Delivered').toString();
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }

  DateTime? _sentAt(Map<String, dynamic> email) =>
      AppDateTime.tryParse(
        email['sentAt'] ?? email['sent_at'] ?? email['createdAt'],
      ) ??
      AppDateTime.combine(email['sentDate'], email['sentTime']);

  List<Map<String, dynamic>> get _filteredEmails {
    return _allEmails.where((email) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (email['recipientName'] ?? '').toString().toLowerCase();
        final recipient =
            (email['recipientEmail'] ?? '').toString().toLowerCase();
        final sender = (email['senderEmail'] ?? '').toString().toLowerCase();
        final subject = (email['subject'] ?? '').toString().toLowerCase();
        final template = (email['templateName'] ?? '').toString().toLowerCase();

        final matches = name.contains(query) ||
            recipient.contains(query) ||
            sender.contains(query) ||
            subject.contains(query) ||
            template.contains(query);

        if (!matches) return false;
      }

      // 2. Status Filter
      if (_selectedStatus != 'All') {
        final status = (email['status'] ?? 'Delivered').toString();
        if (status.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 3. Date Range Filter
      if (_selectedDateRange != null) {
        final date = _sentAt(email);
        if (date == null) return false;

        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23,
          59,
          59,
        );

        if (date.isBefore(start) || date.isAfter(end)) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_selectedSort) {
          case 'Date (Newest)':
            return (_sentAt(b) ?? DateTime(1900))
                .compareTo(_sentAt(a) ?? DateTime(1900));
          case 'Date (Oldest)':
            return (_sentAt(a) ?? DateTime(1900))
                .compareTo(_sentAt(b) ?? DateTime(1900));
          case 'Recipient (A-Z)':
            return (a['recipientName'] ?? '')
                .toString()
                .toLowerCase()
                .compareTo((b['recipientName'] ?? '').toString().toLowerCase());
          case 'Recipient (Z-A)':
            return (b['recipientName'] ?? '')
                .toString()
                .toLowerCase()
                .compareTo((a['recipientName'] ?? '').toString().toLowerCase());
          case 'Subject (A-Z)':
            return (a['subject'] ?? '')
                .toString()
                .toLowerCase()
                .compareTo((b['subject'] ?? '').toString().toLowerCase());
          default:
            return 0;
        }
      });
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    var list = _allTemplates;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((template) {
        final name = (template['name'] ?? '').toString().toLowerCase();
        final subject = (template['subject'] ?? '').toString().toLowerCase();
        final body = (template['body'] ?? '').toString().toLowerCase();
        return name.contains(q) || subject.contains(q) || body.contains(q);
      }).toList();
    }
    if (_selectedCategory != 'All') {
      final c = _selectedCategory.toLowerCase();
      list = list.where((template) {
        final cat = (template['category'] ?? '').toString().toLowerCase();
        return cat.contains(c);
      }).toList();
    }
    if (_selectedSort == 'Name (A-Z)') {
      list = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) => (a['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['name'] ?? '').toString().toLowerCase()));
    } else if (_selectedSort == 'Name (Z-A)') {
      list = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) => (b['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((a['name'] ?? '').toString().toLowerCase()));
    } else if (_selectedSort == 'Subject (A-Z)') {
      list = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) => (a['subject'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['subject'] ?? '').toString().toLowerCase()));
    }
    return list;
  }

  void _showSendEmailDialog({
    Map<String, dynamic>? preloadedTemplate,
    bool startInGroupMode = false,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SendEmailDialog(
          preloadedTemplate: preloadedTemplate,
          startInGroupMode: startInGroupMode,
          allTemplates: _allTemplates,
          onSendEmail: (email) =>
              context.read<EmailFollowUpsCubit>().send(email),
        );
      },
    );
  }

  void _showManageTemplateDialog({Map<String, dynamic>? templateToEdit}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ManageTemplateDialog(
          templateToEdit: templateToEdit,
          onSaveTemplate: context.read<EmailFollowUpsCubit>().saveTemplate,
        );
      },
    );
  }

  void _showEmailPreviewDialog(Map<String, dynamic> email) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EmailPreviewDialog(email: email);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'sent':
        return const Color(0xFF10B981);
      case 'opened':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      case 'draft':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailState = context.watch<EmailFollowUpsCubit>().state;
    if (emailState.isLoading && emailState.logs.isEmpty) {
      return const AppLoadingView(message: 'Loading email activity...');
    }
    if (emailState.errorMessage != null && emailState.logs.isEmpty) {
      return AppErrorView(
        message: emailState.errorMessage!,
        onRetry: context.read<EmailFollowUpsCubit>().loadInitial,
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailsList = _filteredEmails;
    final templatesList = _filteredTemplates;

    final deliveredCount = _allEmails
        .where((e) =>
            (e['status'] ?? '').toString().toLowerCase() == 'delivered' ||
            (e['status'] ?? '').toString().toLowerCase() == 'sent')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Stat Cards Row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatCardWidget(
                label: 'TOTAL SENT EMAILS',
                value: _allEmails.length.toString(),
                icon: CupertinoIcons.mail_solid,
                iconColor: context.colors.primaryLightColor,
                iconBgColor:
                    context.colors.primaryLightColor.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'DELIVERED',
                value: deliveredCount.toString(),
                icon: CupertinoIcons.checkmark_seal_fill,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'ACTIVE TEMPLATES',
                value: _allTemplates.length.toString(),
                icon: CupertinoIcons.square_stack_3d_up_fill,
                iconColor: const Color(0xFF8B5CF6),
                iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: 'DELIVERY RATE',
                value: _allEmails.isEmpty
                    ? '100%'
                    : '${((deliveredCount / _allEmails.length) * 100).toInt()}%',
                icon: CupertinoIcons.graph_circle_fill,
                iconColor: context.colors.warningColor,
                iconBgColor: context.colors.warningColor.withValues(alpha: 0.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Dedicated Tab Bar (Between Header and Table/Templates!)
        EmailFollowUpsTabs(
          selectedTab: _selectedTabIndex,
          onTabChanged: (idx) => setState(() => _selectedTabIndex = idx),
          sentCount: _filteredEmails.length,
          templatesCount: _filteredTemplates.length,
        ),
        const SizedBox(height: 16),

        EmailFollowUpsHeaders(
          selectedTab: _selectedTabIndex,
          selectedStatus: _selectedStatus,
          selectedCategory: _selectedCategory,
          selectedSort: _selectedSort,
          selectedDateRange: _selectedDateRange,
          statusCounts: _statusCounts,
          onStatusChanged: (status) => setState(() => _selectedStatus = status),
          onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          onSortChanged: (sort) => setState(() => _selectedSort = sort),
          onDateRangeChanged: (range) =>
              setState(() => _selectedDateRange = range),
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onComposePressed: () => _showSendEmailDialog(),
          onBatchEmailPressed: () =>
              _showSendEmailDialog(startInGroupMode: true),
          onNewTemplatePressed: () => _showManageTemplateDialog(),
        ),
        const SizedBox(height: 14),

        // 4. Main Content Area
        Expanded(
          child: _selectedTabIndex == 0
              ? Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.boxRadius),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : context.colors.mediumGreyColor
                              .withValues(alpha: 0.35),
                    ),
                  ),
                  child: _buildSentHistoryTable(emailsList, isDark),
                )
              : _buildTemplatesView(templatesList, isDark),
        ),
      ],
    ).withPullToRefresh(
      onRefresh: _loadData,
    );
  }

  Widget _buildSentHistoryTable(
      List<Map<String, dynamic>> emails, bool isDark) {
    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.mail,
                size: 44, color: context.colors.darkGreyColor),
            const SizedBox(height: 14),
            Text(
              'No email records found matching your filter criteria.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.darkGreyColor,
              ),
            ),
          ],
        ),
      );
    }

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 18,
      minWidth: 1200,
      headingRowHeight: 52,
      dataRowHeight: 70,
      showCheckboxColumn: false,
      dividerThickness: 0.5,
      headingRowColor: WidgetStatePropertyAll(
        isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      dataTextStyle: TextStyle(
        fontSize: 12.5,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      columns: const [
        DataColumn2(label: Text('RECIPIENT CONTACT'), size: ColumnSize.L),
        DataColumn2(label: Text('SENDER'), size: ColumnSize.M),
        DataColumn2(label: Text('SUBJECT LINE'), size: ColumnSize.L),
        DataColumn2(label: Text('TEMPLATE USED'), size: ColumnSize.M),
        DataColumn2(label: Text('DATE & TIME'), size: ColumnSize.M),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
        DataColumn2(
            label: Text('ACTIONS'), size: ColumnSize.S, fixedWidth: 100),
      ],
      rows: emails.map((email) {
        final status = (email['status'] ?? 'Delivered').toString();
        final statusColor = _getStatusColor(status);

        return DataRow2(
          color: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.hovered)) {
              return isDark
                  ? Colors.white.withValues(alpha: 0.035)
                  : context.colors.primaryLightColor.withValues(alpha: 0.04);
            }
            return null;
          }),
          cells: [
            // Contact Name & Email
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (email['recipientName'] as Object?).orDash,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (email['recipientEmail'] as Object?).orDash,
                    style: const TextStyle(
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            // Sender Account
            DataCell(
              Text(
                (email['senderEmail'] as Object?).orDash,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            // Subject Line
            DataCell(
              Text(
                (email['subject'] as Object?).orDash,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),

            // Template Used Tag
            DataCell(
              CustomTagWidget(
                label: email['templateName'] ?? '-',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Date & Time
            DataCell(
              Text(
                AppDateTime.displayDateTime(_sentAt(email)),
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // Status Tag
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions (View, Delete)
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppActionButton(
                    type: AppActionType.view,
                    onTap: () => _showEmailPreviewDialog(email),
                  ),
                  const SizedBox(width: 6),
                  AppActionButton(
                    type: AppActionType.delete,
                    onTap: () {
                      ConfirmationDialog.show(
                        context,
                        title: 'Delete Email Record',
                        message:
                            'Are you sure you want to delete this email activity record?',
                        confirmLabel: 'DELETE',
                        onConfirm: () => context
                            .read<EmailFollowUpsCubit>()
                            .deleteLog(email['id'].toString()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTemplatesView(
      List<Map<String, dynamic>> templates, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 3
            : (constraints.maxWidth > 700 ? 2 : 1);
        final childAspectRatio = constraints.maxWidth > 1100
            ? 2.1
            : (constraints.maxWidth > 700 ? 2.3 : 1.85);

        return GridView.builder(
          padding: const EdgeInsets.only(top: 2, bottom: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: templates.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCreateTemplateCard(isDark);
            }
            final temp = templates[index - 1];
            return _buildMinimalTemplateCard(temp, isDark);
          },
        );
      },
    );
  }

  Widget _buildCreateTemplateCard(bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => _showManageTemplateDialog(),
      borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF131C2E).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.plus,
                  size: 18,
                  color: primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create New Template',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Add a reusable follow-up template',
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalTemplateCard(Map<String, dynamic> temp, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;
    final category = (temp['category'] ?? 'Outreach').toString();
    final subject = (temp['subject'] ?? '').toString();
    final rawBody = (temp['body'] ?? '').toString();
    final cleanBody = rawBody
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Extract dynamic variables like {name}, {company}
    final variableMatches = RegExp(r'\{([a-zA-Z0-9_]+)\}')
        .allMatches(rawBody)
        .map((m) => m.group(0)!)
        .toSet()
        .toList();

    Color categoryColor;
    switch (category.toLowerCase()) {
      case 'follow-up & closing':
      case 'follow-up':
        categoryColor = const Color(0xFF10B981); // Emerald
        break;
      case 'outreach':
      case 'sales':
      case 'sales & outreach':
        categoryColor = const Color(0xFF818CF8); // Indigo
        break;
      case 'meeting':
      case 'consultation':
        categoryColor = const Color(0xFFF59E0B); // Amber
        break;
      default:
        categoryColor = const Color(0xFF38BDF8); // Cyan
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Category Tag + Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: categoryColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons: Edit & Delete
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppActionButton(
                    type: AppActionType.edit,
                    onTap: () =>
                        _showManageTemplateDialog(templateToEdit: temp),
                  ),
                  const SizedBox(width: 6),
                  AppActionButton(
                    type: AppActionType.delete,
                    onTap: () {
                      ConfirmationDialog.show(
                        context,
                        title: 'Delete Template',
                        message:
                            'Are you sure you want to delete template "${temp['name']}"?',
                        confirmLabel: 'DELETE',
                        onConfirm: () => context
                            .read<EmailFollowUpsCubit>()
                            .deleteTemplate(temp['id'].toString()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Template Name
          Text(
            temp['name'] ?? 'Untitled Template',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),

          // Row 3: Subject line preview
          Row(
            children: [
              Icon(
                CupertinoIcons.mail,
                size: 11.5,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subject.isNotEmpty ? subject : 'No subject line',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 4: Clean Body Snippet
          Expanded(
            child: Text(
              cleanBody,
              style: TextStyle(
                fontSize: 11.5,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Row 5: Footer (Variable Chips on left + Minimal "USE" button on right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dynamic Variable Chips
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: variableMatches.take(3).map((v) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        v,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF818CF8) : primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Minimal USE Button
              InkWell(
                onTap: () => _showSendEmailDialog(preloadedTemplate: temp),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.paperplane_fill,
                          size: 15.5, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'USE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
