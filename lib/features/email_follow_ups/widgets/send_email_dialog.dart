import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Style;
import '../cubit/email_follow_ups_cubit.dart';
import '../data/email_models.dart';
import 'email_editor_toolbar.dart';


enum _EmailSendMode { single, group }

class SendEmailDialog extends StatefulWidget {
  final Map<String, dynamic>? preloadedTemplate;
  final List<Map<String, dynamic>> allTemplates;
  final Future<bool> Function(
    Map<String, dynamic> email, {
    List<PlatformFile>? attachments,
  }) onSendEmail;
  final bool startInGroupMode;

  const SendEmailDialog({
    super.key,
    this.preloadedTemplate,
    required this.allTemplates,
    required this.onSendEmail,
    this.startInGroupMode = false,
  });

  @override
  State<SendEmailDialog> createState() => _SendEmailDialogState();
}

class _SendEmailDialogState extends State<SendEmailDialog> {
  late _EmailSendMode _mode;

  // Sender Email Account
  List<EmailSenderAccountModel> _senderAccounts = [];
  EmailSenderAccountModel? _selectedSenderAccount;

  // Single Recipient
  User? _selectedUser;
  bool _isDirectRecipient = false;
  final TextEditingController _customRecipientCtrl = TextEditingController();
  final TextEditingController _customRecipientNameCtrl =
      TextEditingController();


  // Batch Selection
  final Set<String> _manualSelectedUserIds = {};
  final TextEditingController _searchCustomerCtrl = TextEditingController();
  String _customerSearchQuery = '';

  // Templates
  Map<String, dynamic>? _selectedTemplate;

  // Controllers
  late TextEditingController _subjectCtrl;
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  // Attachments
  final List<PlatformFile> _attachments = [];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _mode =
        widget.startInGroupMode ? _EmailSendMode.group : _EmailSendMode.single;

    try {
      final emailCubit = context.read<EmailFollowUpsCubit>();
      final serverAccounts = emailCubit.state.senderAccounts;
      if (serverAccounts.isNotEmpty) {
        _senderAccounts = List<EmailSenderAccountModel>.from(serverAccounts);
      }
    } catch (_) {
      _senderAccounts = [];
    }

    if (_senderAccounts.isNotEmpty) {
      _selectedSenderAccount = _senderAccounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => _senderAccounts.first,
      );
    } else {
      _selectedSenderAccount = const EmailSenderAccountModel(
        id: '',
        name: 'xartwa@gmail.com',
        email: 'xartwa@gmail.com',
        senderName: '',
        isDefault: true,
      );
      _senderAccounts = [_selectedSenderAccount!];
    }


    final customers = context.read<CustomersCubit>().state.users;
    if (customers.isEmpty) {
      context.read<CustomersCubit>().loadInitial(resetFilters: false);
      _isDirectRecipient = true;
    } else {
      _isDirectRecipient = false;
    }
    _selectedUser = customers.isNotEmpty ? customers.first : null;
    _selectedTemplate = widget.preloadedTemplate;


    _subjectCtrl = TextEditingController(
      text: widget.preloadedTemplate != null && _selectedUser != null
          ? widget.preloadedTemplate!['subject']
              .replaceAll('{name}', _selectedUser!.fullName)
              .replaceAll('{company}', _selectedUser!.companyName)
          : (widget.preloadedTemplate != null
              ? widget.preloadedTemplate!['subject']
              : ''),
    );

    final initialBodyHtml = widget.preloadedTemplate != null &&
            _selectedUser != null
        ? widget.preloadedTemplate!['body']
            .replaceAll('{name}', _selectedUser!.fullName)
            .replaceAll('{company}', _selectedUser!.companyName)
        : (widget.preloadedTemplate != null
            ? widget.preloadedTemplate!['body']
            : '<p>Hi <b>{name}</b>,</p><p>Thank you for speaking with our team today. We would love to share our project proposal and outline the next steps for {company}.</p><p>Please let us know if you have any questions.</p><p>Best regards,<br><b>CallX AI Team</b></p>');

    _quillController = EmailHtmlConverter.createController(initialBodyHtml);

    _subjectCtrl.addListener(_updateState);
    _quillController.addListener(_updateState);
    _customRecipientCtrl.addListener(_updateState);
    _customRecipientNameCtrl.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subjectCtrl.removeListener(_updateState);
    _quillController.removeListener(_updateState);
    _customRecipientCtrl.removeListener(_updateState);
    _customRecipientNameCtrl.removeListener(_updateState);
    _subjectCtrl.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _customRecipientCtrl.dispose();
    _customRecipientNameCtrl.dispose();
    _searchCustomerCtrl.dispose();
    super.dispose();
  }

  String get _resolvedSender {
    return _selectedSenderAccount?.displayName ?? 'xartwa@gmail.com';
  }

  String? get _resolvedSenderAccountId {
    final id = _selectedSenderAccount?.id;
    if (id != null && id.isNotEmpty) return id;
    return null;
  }


  int _getBatchTargetCount(List<User> customers) {
    return _batchTargets(customers).length;
  }

  List<User> _batchTargets(List<User> customers) {
    if (_manualSelectedUserIds.isEmpty) {
      return List<User>.from(customers);
    }
    return customers
        .where((user) => _manualSelectedUserIds.contains(user.id))
        .toList(growable: false);
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _attachments.addAll(result.files);
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context: context,
          extraMessage: 'Unable to pick files: $e',
          toastificationType: ToastificationType.error,
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _renderContent(
    String value, {
    required String name,
    required String company,
    required String phone,
  }) =>
      value
          .replaceAll('{name}', name)
          .replaceAll('{company}', company)
          .replaceAll('{phone}', phone)
          .replaceAll('{date}', AppDateTime.displayDate(DateTime.now()))
          .replaceAll('{agent}', _resolvedSender);

  void _applyTemplate(Map<String, dynamic> temp) {
    setState(() {
      _selectedTemplate = temp;
      final name = _isDirectRecipient
          ? (_customRecipientNameCtrl.text.trim().isNotEmpty
              ? _customRecipientNameCtrl.text.trim()
              : '{name}')
          : (_selectedUser?.fullName ?? '{name}');
      final company = _isDirectRecipient
          ? 'Client Company'
          : (_selectedUser?.companyName ?? '{company}');
      _subjectCtrl.text = (temp['subject'] ?? '')
          .replaceAll('{name}', name)
          .replaceAll('{company}', company);
      final rawBody = (temp['body'] ?? '')
          .replaceAll('{name}', name)
          .replaceAll('{company}', company);
      _quillController.document =
          Document.fromDelta(EmailHtmlConverter.htmlToDelta(rawBody));
    });
  }

  void _onSend() async {
    final subject = _subjectCtrl.text.trim();
    final body =
        EmailHtmlConverter.deltaToHtml(_quillController.document).trim();

    if (subject.isEmpty ||
        body.isEmpty ||
        _quillController.document.toPlainText().trim().isEmpty) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Please fill in both Subject and Email Body',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final sender = _resolvedSender;
    if (sender.isEmpty) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Please select a sender account.',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final customers = context.read<CustomersCubit>().state.users;
    setState(() => _isSending = true);


    if (_mode == _EmailSendMode.single) {
      final recipientName = _isDirectRecipient
          ? (_customRecipientNameCtrl.text.trim().isNotEmpty
              ? _customRecipientNameCtrl.text.trim()
              : 'Direct Client')
          : (_selectedUser?.fullName ?? 'Client');
      final recipientEmail = _isDirectRecipient
          ? _customRecipientCtrl.text.trim()
          : (_selectedUser?.email ?? '');
      final companyName = _isDirectRecipient
          ? 'Client Company'
          : (_selectedUser?.companyName ?? 'Your Company');
      final phone = _isDirectRecipient ? '' : (_selectedUser?.phone ?? '');

      final renderedSubject = _renderContent(
        subject,
        name: recipientName,
        company: companyName,
        phone: phone,
      );
      final renderedBody = _renderContent(
        body,
        name: recipientName,
        company: companyName,
        phone: phone,
      );

      if (!recipientEmail.contains('@')) {
        setState(() => _isSending = false);
        AppUtils.showSnackBar(
          context: context,
          extraMessage: 'Please enter a valid recipient email address.',
          toastificationType: ToastificationType.warning,
        );
        return;
      }

      final sent = await widget.onSendEmail(
        {
          if (!_isDirectRecipient && _selectedUser != null)
            'customerId': _selectedUser!.id,
          if (_selectedTemplate != null) 'templateId': _selectedTemplate!['id'],
          if (_resolvedSenderAccountId != null)
            'senderAccountId': _resolvedSenderAccountId,
          'senderAlias': _resolvedSender,
          'recipientName': recipientName,
          'recipientEmail': recipientEmail,
          'subject': renderedSubject,
          'body': renderedBody,
        },
        attachments: _attachments.isNotEmpty ? _attachments : null,
      );

      if (!mounted) return;
      setState(() => _isSending = false);
      if (!sent) {
        final errorMsg =
            context.read<EmailFollowUpsCubit>().state.errorMessage;
        AppUtils.showSnackBar(
          context: context,
          title: 'Email Delivery Failed',
          extraMessage: (errorMsg != null && errorMsg.isNotEmpty)
              ? errorMsg
              : 'The server could not send this email.',
          toastificationType: ToastificationType.error,
        );
        return;
      }
      Navigator.pop(context);

      AppUtils.showSnackBar(
        context: context,
        title: 'Email Sent Successfully',
        extraMessage: 'Delivered to $recipientName ($recipientEmail)',
        toastificationType: ToastificationType.success,
      );
    } else {
      // Group Batch Email
      final targetList = _batchTargets(customers)
          .where((user) => user.email.contains('@'))
          .toList(growable: false);
      if (targetList.isEmpty) {
        setState(() => _isSending = false);
        AppUtils.showSnackBar(
          context: context,
          extraMessage: 'No selected customer has a valid email address.',
          toastificationType: ToastificationType.warning,
        );
        return;
      }

      var sentCount = 0;
      for (final targetUser in targetList) {
        final sent = await widget.onSendEmail(
          {
            'customerId': targetUser.id,
            if (_selectedTemplate != null) 'templateId': _selectedTemplate!['id'],
            if (_resolvedSenderAccountId != null)
              'senderAccountId': _resolvedSenderAccountId,
            'senderAlias': _resolvedSender,
            'recipientName': targetUser.fullName,
            'recipientEmail': targetUser.email,
            'subject': _renderContent(
              subject,
              name: targetUser.fullName,
              company: targetUser.companyName,
              phone: targetUser.phone,
            ),
            'body': _renderContent(
              body,
              name: targetUser.fullName,
              company: targetUser.companyName,
              phone: targetUser.phone,
            ),
          },
          attachments: _attachments.isNotEmpty ? _attachments : null,
        );
        if (sent) sentCount++;
      }
      if (!mounted) return;
      setState(() => _isSending = false);

      if (sentCount == 0) {
        final errorMsg =
            context.read<EmailFollowUpsCubit>().state.errorMessage;
        AppUtils.showSnackBar(
          context: context,
          title: 'Batch Email Failed',
          extraMessage: (errorMsg != null && errorMsg.isNotEmpty)
              ? errorMsg
              : 'The batch could not be sent.',
          toastificationType: ToastificationType.error,
        );
        return;
      }

      Navigator.pop(context);

      AppUtils.showSnackBar(
        context: context,
        title: 'Batch Email Campaign Dispatched',
        extraMessage:
            'Sent to $sentCount of ${targetList.length} recipients from $_resolvedSender',
        toastificationType: sentCount == targetList.length
            ? ToastificationType.success
            : ToastificationType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customers = context.watch<CustomersCubit>().state.users;
    if (_selectedUser == null && customers.isNotEmpty) {
      _selectedUser = customers.first;
    }
    if (_manualSelectedUserIds.isEmpty && customers.isNotEmpty) {
      _manualSelectedUserIds.addAll(customers.map((u) => u.id));
    }
    final targetCount = _getBatchTargetCount(customers);


    final currentBodyHtml =
        EmailHtmlConverter.deltaToHtml(_quillController.document);
    final previewBody = currentBodyHtml
        .replaceAll('{name}', _selectedUser?.fullName ?? 'Valued Customer')
        .replaceAll('{company}', _selectedUser?.companyName ?? 'Your Company')
        .replaceAll('{phone}', _selectedUser?.phone ?? '+1 (555) 000-0000')
        .replaceAll('{date}', AppDateTime.displayDate(DateTime.now()))
        .replaceAll('{agent}', 'Alex Morgan');

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : context.colors.mediumGreyColor.withValues(alpha: 0.5),
        ),
      ),
      elevation: 12,
      backgroundColor: isDark ? AppColors.darkSlateColor : Colors.white,
      child: Container(
        width: 1100,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        child: Column(
          children: [
            // Top Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _mode == _EmailSendMode.single
                      ? 'COMPOSE OUTBOUND EMAIL'
                      : 'COMPOSE BATCH EMAIL CAMPAIGN',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(CupertinoIcons.clear, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Mode Switcher (Single vs Batch Email)
            Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius:
                    BorderRadius.circular(ThemeConstants.buttonRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _mode = _EmailSendMode.single),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _mode == _EmailSendMode.single
                              ? (isDark
                                  ? AppColors.darkSlateColor
                                  : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _mode == _EmailSendMode.single && !isDark
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'SINGLE EMAIL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: _mode == _EmailSendMode.single
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = _EmailSendMode.group),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _mode == _EmailSendMode.group
                              ? (isDark
                                  ? AppColors.darkSlateColor
                                  : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _mode == _EmailSendMode.group && !isDark
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'GROUP BATCH EMAIL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: _mode == _EmailSendMode.group
                                ? Theme.of(context).colorScheme.primary
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Two-column Main Content (Left: Form/Editor, Right: Live Preview)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Form Editor
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SENDER & TEMPLATE ROW
                          Row(
                            children: [
                              // Sender Email Dropdown
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FROM (SENDER ACCOUNT)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppDropdownWidget<EmailSenderAccountModel>(
                                      value: _selectedSenderAccount,
                                      items: _senderAccounts,
                                      height: 46,
                                      itemBuilder: (account) =>
                                          account.displayName,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() =>
                                              _selectedSenderAccount = val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Template Dropdown
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EMAIL TEMPLATE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AppDropdownWidget<Map<String, dynamic>>(
                                      value: _selectedTemplate,
                                      hint: 'Select or write custom',
                                      items: widget.allTemplates,
                                      height: 46,
                                      itemBuilder: (t) =>
                                          t['name'] ?? 'Template',
                                      onChanged: (val) {
                                        if (val != null) _applyTemplate(val);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),


                          // RECIPIENT ROW
                          if (_mode == _EmailSendMode.single) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TO (RECIPIENT)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _isDirectRecipient = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: !_isDirectRecipient
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'CUSTOMER',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: !_isDirectRecipient
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : (isDark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _isDirectRecipient = true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isDirectRecipient
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.12)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'DIRECT EMAIL',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: _isDirectRecipient
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : (isDark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (!_isDirectRecipient)
                              customers.isNotEmpty
                                  ? AppDropdownWidget<User>(
                                      value: _selectedUser,
                                      hint: 'Select recipient customer',
                                      items: customers,
                                      height: 46,
                                      itemBuilder: (u) =>
                                          '${u.fullName} (${u.email.isNotEmpty ? u.email : u.companyName})',
                                      onChanged: (u) =>
                                          setState(() => _selectedUser = u),
                                    )
                                  : Container(
                                      height: 46,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            ThemeConstants.buttonRadius),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : context.colors.lightGreyColor,
                                        ),
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.03)
                                            : Colors.black
                                                .withValues(alpha: 0.02),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(CupertinoIcons.info_circle,
                                              size: 15,
                                              color: Colors.orange[400]),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'No customers in database. Please use "DIRECT EMAIL".',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => setState(
                                                () => _isDirectRecipient = true),
                                            child: Text(
                                              'Switch to Direct',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            ThemeConstants.buttonRadius),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : context.colors.lightGreyColor,
                                        ),
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.03)
                                            : Colors.black
                                                .withValues(alpha: 0.02),
                                      ),
                                      child: TextField(
                                        controller: _customRecipientCtrl,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14),
                                          hintText:
                                              'Recipient Email (e.g. client@gmail.com)',
                                          hintStyle: TextStyle(
                                              fontSize: 12.5,
                                              color:
                                                  context.colors.darkGreyColor),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            ThemeConstants.buttonRadius),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : context.colors.lightGreyColor,
                                        ),
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.03)
                                            : Colors.black
                                                .withValues(alpha: 0.02),
                                      ),
                                      child: TextField(
                                        controller: _customRecipientNameCtrl,
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14),
                                          hintText: 'Name (optional)',
                                          hintStyle: TextStyle(
                                              fontSize: 12.5,
                                              color:
                                                  context.colors.darkGreyColor),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ] else ...[

                            // BATCH TARGET SELECTION
                            Text(
                              'BATCH TARGET AUDIENCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                              // Redesigned Pixel-Perfect Customer Selection Box
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.black.withValues(alpha: 0.02),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : context.colors.lightGreyColor,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      ThemeConstants.buttonRadius),
                                ),
                                child: Column(
                                  children: [
                                    // Search Bar
                                    Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSlateColor
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : context.colors.lightGreyColor,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons.search,
                                            size: 15,
                                            color: context.colors.darkGreyColor,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchCustomerCtrl,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              onChanged: (val) => setState(() =>
                                                  _customerSearchQuery = val),
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                hintText:
                                                    'Search customer name or company...',
                                                hintStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: context
                                                      .colors.darkGreyColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_customerSearchQuery.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                _searchCustomerCtrl.clear();
                                                setState(() =>
                                                    _customerSearchQuery = '');
                                              },
                                              child: Icon(
                                                CupertinoIcons
                                                    .clear_circled_solid,
                                                size: 15,
                                                color: context
                                                    .colors.darkGreyColor,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Count and Select All Bar
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_manualSelectedUserIds.length} of ${customers.length} selected',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: _manualSelectedUserIds
                                                    .isNotEmpty
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : context.colors.darkGreyColor,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (_manualSelectedUserIds
                                                      .length ==
                                                  customers.length) {
                                                _manualSelectedUserIds.clear();
                                              } else {
                                                _manualSelectedUserIds.addAll(
                                                    customers.map((u) => u.id));
                                              }
                                            });
                                          },
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            child: Text(
                                              _manualSelectedUserIds.length ==
                                                      customers.length
                                                  ? 'Clear All'
                                                  : 'Select All',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1, thickness: 0.5),
                                    const SizedBox(height: 8),

                                    // Scrollable List of customers
                                    SizedBox(
                                      height: 160,
                                      child: ListView.builder(
                                        itemCount: customers
                                            .where((u) =>
                                                _customerSearchQuery.isEmpty ||
                                                u.fullName
                                                    .toLowerCase()
                                                    .contains(
                                                        _customerSearchQuery
                                                            .toLowerCase()) ||
                                                u.companyName
                                                    .toLowerCase()
                                                    .contains(
                                                        _customerSearchQuery
                                                            .toLowerCase()) ||
                                                u.email.toLowerCase().contains(
                                                    _customerSearchQuery
                                                        .toLowerCase()))
                                            .length,
                                        itemBuilder: (context, idx) {
                                          final filtered = customers
                                              .where((u) =>
                                                  _customerSearchQuery
                                                      .isEmpty ||
                                                  u.fullName
                                                      .toLowerCase()
                                                      .contains(
                                                          _customerSearchQuery
                                                              .toLowerCase()) ||
                                                  u.companyName
                                                      .toLowerCase()
                                                      .contains(
                                                          _customerSearchQuery
                                                              .toLowerCase()) ||
                                                  u.email
                                                      .toLowerCase()
                                                      .contains(
                                                          _customerSearchQuery
                                                              .toLowerCase()))
                                              .toList();
                                          final user = filtered[idx];
                                          final isSelected =
                                              _manualSelectedUserIds
                                                  .contains(user.id);

                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (isSelected) {
                                                  _manualSelectedUserIds
                                                      .remove(user.id);
                                                } else {
                                                  _manualSelectedUserIds
                                                      .add(user.id);
                                                }
                                              });
                                            },
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 8),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.08)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isSelected
                                                        ? CupertinoIcons
                                                            .checkmark_square_fill
                                                        : CupertinoIcons.square,
                                                    size: 16,
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : context.colors
                                                            .darkGreyColor,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      user.fullName,
                                                      style: TextStyle(
                                                        fontSize: 12.5,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w700
                                                            : FontWeight.w500,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    user.companyName.isNotEmpty
                                                        ? user.companyName
                                                        : user.email,
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      color: context
                                                          .colors.darkGreyColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          const SizedBox(height: 20),

                          // SUBJECT
                          Text(
                            'SUBJECT LINE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : context.colors.lightGreyColor,
                              ),
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02),
                            ),
                            child: TextField(
                              controller: _subjectCtrl,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                hintText:
                                    'e.g. Proposal and Project Scope Document',
                                hintStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: context.colors.darkGreyColor),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // RICH TOOLBAR + BODY EDITOR
                          Text(
                            'EMAIL BODY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          EmailEditorToolbar(controller: _quillController),
                          const SizedBox(height: 8),
                          EmailQuillEditor(
                            controller: _quillController,
                            focusNode: _editorFocusNode,
                            scrollController: _editorScrollController,
                            minHeight: 180,
                            maxHeight: 280,
                            placeholder: 'Write your follow-up email...',
                          ),
                          const SizedBox(height: 20),

                          // ATTACHMENTS SECTION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ATTACHMENTS (${_attachments.length})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                              ),
                              InkWell(
                                onTap: _pickAttachments,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.paperclip,
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ATTACH FILES',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_attachments.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _attachments.map((file) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.doc_fill,
                                        size: 13,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 160),
                                        child: Text(
                                          '${file.name} (${_formatFileSize(file.size)})',
                                          style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          setState(
                                              () => _attachments.remove(file));
                                        },
                                        child: const Icon(
                                            CupertinoIcons.clear_circled_solid,
                                            size: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),
                  const VerticalDivider(width: 1, thickness: 1),
                  const SizedBox(width: 24),

                  // Right Live Preview Panel
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.grey[50],
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.boxRadius),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : context.colors.lightGreyColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(CupertinoIcons.eye_fill,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE EMAIL PREVIEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 0.5),

                          // Header Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From:',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.darkGreyColor)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_resolvedSender,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('To:',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.darkGreyColor)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _mode == _EmailSendMode.single
                                      ? (_isDirectRecipient
                                          ? (_customRecipientCtrl.text.trim().isNotEmpty
                                              ? _customRecipientCtrl.text.trim()
                                              : 'client@example.com')
                                          : (_selectedUser?.email ??
                                              'client@example.com'))
                                      : 'Batch Audience ($targetCount recipients)',
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subject:',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.darkGreyColor)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _subjectCtrl.text.isNotEmpty
                                      ? _subjectCtrl.text
                                      : '(No Subject)',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),

                          if (_attachments.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Attached:',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.darkGreyColor)),
                                const SizedBox(width: 8),
                                Text(
                                  '${_attachments.length} file(s)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const Divider(height: 18, thickness: 0.5),

                          // Rendered HTML Body
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSlateColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                child: Html(
                                  data: previewBody.isNotEmpty
                                      ? previewBody
                                      : '<p style="color: grey;">(Start typing your message to preview here...)</p>',
                                  style: {
                                    'body': Style(
                                      fontSize: FontSize(12.5),
                                      lineHeight: const LineHeight(1.5),
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer Send Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSending ? null : _onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
                child: _isSending
                    ? const AppLoadingIndicator(
                        size: 20,
                        color: Colors.white,
                      )
                    : Text(
                        _mode == _EmailSendMode.single
                            ? 'SEND EMAIL NOW'
                            : 'SEND BATCH EMAIL ($targetCount RECIPIENTS)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
