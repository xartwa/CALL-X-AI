import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Style;
import 'email_editor_toolbar.dart';

class ManageTemplateDialog extends StatefulWidget {
  final Map<String, dynamic>? templateToEdit;
  final Future<bool> Function(Map<String, dynamic> template) onSaveTemplate;

  const ManageTemplateDialog({
    super.key,
    this.templateToEdit,
    required this.onSaveTemplate,
  });

  @override
  State<ManageTemplateDialog> createState() => _ManageTemplateDialogState();
}

class _ManageTemplateDialogState extends State<ManageTemplateDialog> {
  late TextEditingController nameController;
  late TextEditingController subjectController;
  late QuillController bodyQuillController;
  final FocusNode bodyFocusNode = FocusNode();
  final ScrollController bodyScrollController = ScrollController();
  String _selectedCategory = 'Sales & Outreach';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.templateToEdit != null ? widget.templateToEdit!['name'] : '',
    );
    subjectController = TextEditingController(
      text: widget.templateToEdit != null
          ? widget.templateToEdit!['subject']
          : '',
    );
    final initialBody = widget.templateToEdit != null
        ? widget.templateToEdit!['body']
        : '<p>Hi <b>{name}</b>,</p><p>Thank you for connecting with {company} today.</p><p>Best regards,<br><b>{agent}</b></p>';
    bodyQuillController = EmailHtmlConverter.createController(initialBody);

    if (widget.templateToEdit != null &&
        widget.templateToEdit!['category'] != null) {
      _selectedCategory = widget.templateToEdit!['category'];
    }

    nameController.addListener(_updateState);
    subjectController.addListener(_updateState);
    bodyQuillController.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    nameController.removeListener(_updateState);
    subjectController.removeListener(_updateState);
    bodyQuillController.removeListener(_updateState);
    nameController.dispose();
    subjectController.dispose();
    bodyQuillController.dispose();
    bodyFocusNode.dispose();
    bodyScrollController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final name = nameController.text.trim();
    final subject = subjectController.text.trim();
    final body = EmailHtmlConverter.deltaToHtml(bodyQuillController.document).trim();

    if (name.isEmpty ||
        subject.isEmpty ||
        body.isEmpty ||
        bodyQuillController.document.toPlainText().trim().isEmpty) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Please fill in all template fields',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final newTemp = {
      'id': widget.templateToEdit != null
          ? widget.templateToEdit!['id']
          : DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'subject': subject,
      'body': body,
      'category': _selectedCategory,
    };

    setState(() => _isSaving = true);
    final saved = await widget.onSaveTemplate(newTemp);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!saved) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Unable to save the template. Please try again.',
        toastificationType: ToastificationType.error,
      );
      return;
    }
    Navigator.pop(context);

    AppUtils.showSnackBar(
      context: context,
      title: widget.templateToEdit == null
          ? 'Template Created'
          : 'Template Updated',
      extraMessage: 'Saved template "$name"',
      toastificationType: ToastificationType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentBodyHtml =
        EmailHtmlConverter.deltaToHtml(bodyQuillController.document);
    final previewBody = currentBodyHtml
        .replaceAll('{name}', 'John Doe')
        .replaceAll('{company}', 'Acme Corporation')
        .replaceAll('{phone}', '+1 (555) 234-5678')
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
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Container(
        width: 1040,
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
                  widget.templateToEdit != null
                      ? 'EDIT EMAIL TEMPLATE'
                      : 'CREATE EMAIL TEMPLATE',
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

            // Two-column layout
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Form Editor
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Template Name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TEMPLATE NAME',
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
                              Container(
                                height: 46,
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
                                child: Center(
                                  child: TextField(
                                    controller: nameController,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600),
                                    textAlignVertical:
                                        TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12),
                                      hintText:
                                          'e.g. Sales Follow-Up Letter',
                                      hintStyle: TextStyle(
                                          fontSize: 12.5,
                                          color: context
                                              .colors.darkGreyColor),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Subject Line
                          Text(
                            'DEFAULT SUBJECT LINE',
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
                            child: Center(
                              child: TextField(
                                controller: subjectController,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  hintText:
                                      'e.g. Next Steps for {name} ({company})',
                                  hintStyle: TextStyle(
                                      fontSize: 12.5,
                                      color: context.colors.darkGreyColor),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Rich Toolbar & Body
                          Text(
                            'TEMPLATE BODY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          EmailEditorToolbar(controller: bodyQuillController),
                          const SizedBox(height: 8),
                          EmailQuillEditor(
                            controller: bodyQuillController,
                            focusNode: bodyFocusNode,
                            scrollController: bodyScrollController,
                            minHeight: 180,
                            maxHeight: 280,
                            placeholder:
                                'Write template message with {name}, {company}, etc...',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),
                  const VerticalDivider(width: 1, thickness: 1),
                  const SizedBox(width: 24),

                  // Right Live Preview
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
                                'TEMPLATE SAMPLE PREVIEW',
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
                          Text('Sample Subject:',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.darkGreyColor)),
                          const SizedBox(height: 4),
                          Text(
                            subjectController.text.isNotEmpty
                                ? subjectController.text
                                    .replaceAll('{name}', 'John Doe')
                                    .replaceAll('{company}', 'Acme Corp')
                                : '(No Subject)',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          const Divider(height: 18, thickness: 0.5),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
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
                                      : '<p style="color: grey;">(Start typing template to preview here...)</p>',
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

            // Save CTA Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
                child: _isSaving
                    ? const AppLoadingIndicator(color: Colors.white)
                    : Text(
                        widget.templateToEdit != null
                            ? 'SAVE TEMPLATE CHANGES'
                            : 'CREATE TEMPLATE',
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
