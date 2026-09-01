import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/custom_tag_widget.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/email_follow_ups_headers.dart';

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

class _EmailFollowUpsPageState extends State<EmailFollowUpsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedSort = 'Default';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        final recipient =
            (email['recipientName'] ?? '').toString().toLowerCase();
        final emailAddress =
            (email['recipientEmail'] ?? '').toString().toLowerCase();
        final subject = (email['subject'] ?? '').toString().toLowerCase();
        final template = (email['templateName'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        final matches = recipient.contains(query) ||
            emailAddress.contains(query) ||
            subject.contains(query) ||
            template.contains(query);
        if (!matches) return false;
      }

      // 2. Status Filter
      if (_selectedStatus != 'All') {
        final emailStatus = (email['status'] ?? '').toString().toLowerCase();
        if (emailStatus != _selectedStatus.toLowerCase()) return false;
      }

      // 3. Date Range Filter
      if (_selectedDateRange != null) {
        final sentAt = _sentAt(email);
        if (sentAt == null ||
            !AppDateTime.isWithinDateRange(
              sentAt,
              _selectedDateRange!.start,
              _selectedDateRange!.end,
            )) {
          return false;
        }
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
    if (_searchQuery.isEmpty) return _allTemplates;
    return _allTemplates.where((template) {
      final name = (template['name'] ?? '').toString().toLowerCase();
      final subject = (template['subject'] ?? '').toString().toLowerCase();
      final body = (template['body'] ?? '').toString().toLowerCase();
      final category = (template['category'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          subject.contains(query) ||
          body.contains(query) ||
          category.contains(query);
    }).toList();
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
          allTemplates: _allTemplates,
          startInGroupMode: startInGroupMode,
          onSendEmail: context.read<EmailFollowUpsCubit>().send,
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
        // Stat Cards Row
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

        // Headers / Toolbar
        EmailFollowUpsHeaders(
          selectedStatus: _selectedStatus,
          selectedSort: _selectedSort,
          selectedDateRange: _selectedDateRange,
          statusCounts: _statusCounts,
          onStatusChanged: (status) => setState(() => _selectedStatus = status),
          onSortChanged: (sort) => setState(() => _selectedSort = sort),
          onDateRangeChanged: (range) =>
              setState(() => _selectedDateRange = range),
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          onComposePressed: () => _showSendEmailDialog(),
          onBatchEmailPressed: () =>
              _showSendEmailDialog(startInGroupMode: true),
          onNewTemplatePressed: () => _showManageTemplateDialog(),
        ),
        const SizedBox(height: 16),

        // Main Card with Tabs
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : context.colors.mediumGreyColor.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                // Tab Switcher Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: context.colors.darkGreyColor,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          letterSpacing: 0.5,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.clock_fill, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                    'SENT HISTORY (${_filteredEmails.length})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.doc_plaintext,
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                    'EMAIL TEMPLATES (${_filteredTemplates.length})'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 1. Sent History DataTable2
                      _buildSentHistoryTable(emailsList, isDark),

                      // 2. Email Templates Grid
                      _buildTemplatesGrid(templatesList, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                            'Are you sure you want to delete this email from history?',
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

  Widget _buildTemplatesGrid(
      List<Map<String, dynamic>> templates, bool isDark) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.square_stack_3d_up,
                size: 44, color: context.colors.darkGreyColor),
            const SizedBox(height: 14),
            Text(
              'No email templates found.',
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

    return GridView.builder(
      padding: const EdgeInsets.all(18),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final temp = templates[index];
        final category = temp['category'] ?? 'Outreach';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
            border: Border.all(
              color: isDark ? Colors.white12 : context.colors.lightGreyColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge + Action icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
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

              // Title
              Text(
                temp['name'] ?? 'Template',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Subject preview
              Text(
                'Subject: ${temp['subject'] ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                  color: context.colors.darkGreyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Body preview
              Expanded(
                child: Text(
                  (temp['body'] ?? '')
                      .replaceAll(RegExp(r'<[^>]*>'), '')
                      .replaceAll('&nbsp;', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),

              // Use Template Button
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showSendEmailDialog(preloadedTemplate: temp),
                  icon: const Icon(CupertinoIcons.paperplane_fill,
                      size: 13, color: Colors.white),
                  label: const Text(
                    'USE TEMPLATE',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
