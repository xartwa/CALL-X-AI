import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/chip_tag_widget.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/core/widgets/app_action_button.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/email_follow_ups_headers.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/email_preview_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/manage_template_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';

class EmailFollowUpsPage extends StatefulWidget {
  const EmailFollowUpsPage({super.key});

  @override
  State<EmailFollowUpsPage> createState() => _EmailFollowUpsPageState();
}

class _EmailFollowUpsPageState extends State<EmailFollowUpsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PreferencesService _preferences;

  List<Map<String, dynamic>> _allEmails = [];
  List<Map<String, dynamic>> _allTemplates = [];

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
    _preferences = context.read<PreferencesService>();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allEmails = _preferences.loadEmails();
      _allTemplates = _preferences.loadTemplates();

      // Seed mock templates if empty
      if (_allTemplates.isEmpty) {
        _allTemplates = [
          {
            'id': '1',
            'name': 'Contract & Project Proposal',
            'category': 'Billing & Contracts',
            'subject': 'Proposal & Scope of Work for {name} - CallX AI',
            'body':
                '<p>Hi <b>{name}</b>,</p><p>Thank you for speaking with our team today regarding {company}. We have prepared the official scope of work and project proposal tailored to your requirements.</p><p>Please find the attached proposal summary. Looking forward to your review!</p><p>Best regards,<br><b>{agent}</b></p>',
          },
          {
            'id': '2',
            'name': 'Follow-Up After Call',
            'category': 'Follow-Up & Closing',
            'subject': 'Great speaking with you, {name}!',
            'body':
                '<p>Hi <b>{name}</b>,</p><p>Thank you for your valuable time on our call today. As discussed, I am following up with key points and action items for {company}.</p><p>Let me know if you would like to schedule our next follow-up session.</p><p>Best regards,<br><b>{agent}</b></p>',
          },
          {
            'id': '3',
            'name': 'Demo Confirmation & Calendar',
            'category': 'Sales & Outreach',
            'subject': 'Confirmed: CallX AI Product Demo with {company}',
            'body':
                '<p>Hi <b>{name}</b>,</p><p>This is a quick confirmation for our upcoming product demo scheduled on {date}.</p><p>We will walk you through our AI voice automation and answer all your technical questions.</p><p>See you soon!<br><b>{agent}</b></p>',
          },
          {
            'id': '4',
            'name': 'Special Pricing & Discount Offer',
            'category': 'Sales & Outreach',
            'subject': 'Exclusive 20% Partnership Offer for {company}',
            'body':
                '<p>Hi <b>{name}</b>,</p><p>We are excited about the potential collaboration with {company}. For this month only, we are offering an exclusive tier discount on our AI line deployment.</p><p>Let us know if you would like to lock in this tier before it closes!</p><p>Warm regards,<br><b>{agent}</b></p>',
          },
        ];
        _saveTemplates();
      }
    });
  }

  void _saveEmails() {
    _preferences.saveEmails(_allEmails);
  }

  void _saveTemplates() {
    _preferences.saveTemplates(_allTemplates);
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
        final dateStr = (email['sentDate'] ?? '').toString().trim();
        if (dateStr.isNotEmpty) {
          try {
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              final d = DateTime(
                int.parse(parts[0]),
                int.parse(parts[1]),
                int.parse(parts[2]),
              );
              final start = DateTime(_selectedDateRange!.start.year,
                  _selectedDateRange!.start.month, _selectedDateRange!.start.day);
              final end = DateTime(_selectedDateRange!.end.year,
                  _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
              if (d.isBefore(start) || d.isAfter(end)) return false;
            }
          } catch (_) {}
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_selectedSort) {
          case 'Date (Newest)':
            final dateA = '${a['sentDate'] ?? ''} ${a['sentTime'] ?? ''}';
            final dateB = '${b['sentDate'] ?? ''} ${b['sentTime'] ?? ''}';
            return dateB.compareTo(dateA);
          case 'Date (Oldest)':
            final dateA = '${a['sentDate'] ?? ''} ${a['sentTime'] ?? ''}';
            final dateB = '${b['sentDate'] ?? ''} ${b['sentTime'] ?? ''}';
            return dateA.compareTo(dateB);
          case 'Recipient (A-Z)':
            return (a['recipientName'] ?? '')
                .toString()
                .toLowerCase()
                .compareTo(
                    (b['recipientName'] ?? '').toString().toLowerCase());
          case 'Recipient (Z-A)':
            return (b['recipientName'] ?? '')
                .toString()
                .toLowerCase()
                .compareTo(
                    (a['recipientName'] ?? '').toString().toLowerCase());
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
          onSendEmail: (newEmail) {
            setState(() {
              _allEmails.insert(0, newEmail);
              _saveEmails();
            });
          },
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
          onSaveTemplate: (template) {
            setState(() {
              if (templateToEdit == null) {
                _allTemplates.insert(0, template);
              } else {
                final idx = _allTemplates
                    .indexWhere((t) => t['id'] == templateToEdit['id']);
                if (idx != -1) {
                  _allTemplates[idx] = template;
                }
              }
              _saveTemplates();
            });
          },
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
        Row(
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
              iconBgColor:
                  context.colors.warningColor.withValues(alpha: 0.1),
            ),
          ],
        ),
        const SizedBox(height: 16),
    
        // Headers / Toolbar
        EmailFollowUpsHeaders(
          selectedStatus: _selectedStatus,
          selectedSort: _selectedSort,
          selectedDateRange: _selectedDateRange,
          statusCounts: _statusCounts,
          onStatusChanged: (status) =>
              setState(() => _selectedStatus = status),
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white10
                    : context.colors.lightGreyColor,
              ),
            ),
            child: Column(
              children: [
                // Tab Switcher Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor:
                            Theme.of(context).colorScheme.primary,
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
                                const Icon(CupertinoIcons.clock_fill,
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                    'SENT HISTORY (${_filteredEmails.length})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              children: [
                                const Icon(
                                    CupertinoIcons.doc_plaintext,
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
      onRefresh: () async => _loadData(),
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
      headingRowHeight: 46,
      dataRowHeight: 56,
      headingRowColor: WidgetStatePropertyAll(
        isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[100],
      ),
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white70 : Colors.black87,
        fontSize: 11.5,
        letterSpacing: 0.6,
      ),
      columns: const [
        DataColumn2(label: Text('RECIPIENT CONTACT'), size: ColumnSize.L),
        DataColumn2(label: Text('SENDER'), size: ColumnSize.M),
        DataColumn2(label: Text('SUBJECT LINE'), size: ColumnSize.L),
        DataColumn2(label: Text('TEMPLATE USED'), size: ColumnSize.M),
        DataColumn2(label: Text('DATE & TIME'), size: ColumnSize.M),
        DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
        DataColumn2(label: Text('ACTIONS'), size: ColumnSize.S, fixedWidth: 100),
      ],
      rows: emails.map((email) {
        final status = (email['status'] ?? 'Delivered').toString();
        final statusColor = _getStatusColor(status);
        final attachments = email['attachments'] as List?;

        return DataRow2(
          cells: [
            // Contact Name & Email
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    email['recipientName'] ?? 'Lead',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email['recipientEmail'] ?? '',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Sender Account
            DataCell(
              Text(
                email['senderEmail'] ?? 'support@callx.ai',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

            // Subject Line with Attachment badge
            DataCell(
              Row(
                children: [
                  if (attachments != null && attachments.isNotEmpty) ...[
                    Icon(CupertinoIcons.paperclip,
                        size: 13, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      email['subject'] ?? '(No Subject)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Template Used Tag
            DataCell(
              tagChipWidget(
                context: context,
                tagName: email['templateName'] ?? 'Custom Email',
                customColor: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Date & Time
            DataCell(
              Text(
                '${email['sentDate'] ?? ''}  •  ${email['sentTime'] ?? ''}',
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // Status Tag
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        onConfirm: () {
                          setState(() {
                            _allEmails
                                .removeWhere((e) => e['id'] == email['id']);
                            _saveEmails();
                          });
                        },
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : context.colors.lightGreyColor,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                            onConfirm: () {
                              setState(() {
                                _allTemplates
                                    .removeWhere((t) => t['id'] == temp['id']);
                                _saveTemplates();
                              });
                            },
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
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
