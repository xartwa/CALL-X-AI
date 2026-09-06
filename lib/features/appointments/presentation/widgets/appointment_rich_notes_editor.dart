import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../theme/app_colors.dart';

/// A sleek, single-container rich text notes editor matching CallX AI input fields
/// and Google Calendar event description formatting standards (Bold, Italic, Underline,
/// Bullet/Numbered lists, Hyperlink, and Clear formatting).
class AppointmentRichNotesEditor extends StatefulWidget {
  final QuillController controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final String placeholder;
  final double minHeight;
  final double maxHeight;

  const AppointmentRichNotesEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.scrollController,
    this.placeholder = 'Review project scope, architectural feasibility, bullet points...',
    this.minHeight = 85,
    this.maxHeight = 150,
  });

  @override
  State<AppointmentRichNotesEditor> createState() =>
      _AppointmentRichNotesEditorState();
}

class _AppointmentRichNotesEditorState
    extends State<AppointmentRichNotesEditor> {
  late FocusNode _effectiveFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(AppointmentRichNotesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) {
        _effectiveFocusNode.removeListener(_handleFocusChange);
        _effectiveFocusNode.dispose();
      }
      _effectiveFocusNode = widget.focusNode ?? FocusNode();
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleAttribute(Attribute attribute) {
    final attrs = widget.controller.getSelectionStyle().attributes;
    if (attrs.containsKey(attribute.key)) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
  }

  void _toggleList(Attribute attribute) {
    final attrs = widget.controller.getSelectionStyle().attributes;
    if (attrs[attribute.key] == attribute) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
  }

  void _clearFormatting() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    for (final attr in attrs.values) {
      widget.controller.formatSelection(Attribute.clone(attr, null));
    }
  }

  void _showLinkDialog(BuildContext context) {
    final selection = widget.controller.selection;
    final doc = widget.controller.document;
    final selectedText = (selection.isCollapsed || selection.start < 0)
        ? ''
        : doc.getPlainText(selection.start, selection.end - selection.start);

    final textCtrl = TextEditingController(text: selectedText);
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? AppColors.darkSlateColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
          ),
          elevation: 10,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'INSERT LINK',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(CupertinoIcons.clear, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'LINK TEXT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : context.colors.lightGreyColor,
                    ),
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  ),
                  child: TextField(
                    controller: textCtrl,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      hintText: 'e.g. Project Plan / Meeting Link',
                      hintStyle: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'DESTINATION URL',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : context.colors.lightGreyColor,
                    ),
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  ),
                  child: TextField(
                    controller: urlCtrl,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      hintText: 'https://...',
                      hintStyle: TextStyle(fontSize: 12, color: context.colors.darkGreyColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final text = textCtrl.text.trim();
                            final rawUrl = urlCtrl.text.trim();
                            if (rawUrl.isEmpty) return;

                            final url = (rawUrl.startsWith('http://') ||
                                    rawUrl.startsWith('https://') ||
                                    rawUrl.startsWith('mailto:'))
                                ? rawUrl
                                : 'https://$rawUrl';

                            if (selection.isCollapsed && text.isNotEmpty) {
                              final offset = selection.baseOffset;
                              widget.controller.document.insert(offset, text);
                              widget.controller.updateSelection(
                                TextSelection(
                                  baseOffset: offset,
                                  extentOffset: offset + text.length,
                                ),
                                ChangeSource.local,
                              );
                            }
                            widget.controller.formatSelection(LinkAttribute(url));
                            Navigator.pop(dialogCtx);
                          },
                          child: const Text(
                            'Insert',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbarButton({
    String? label,
    IconData? icon,
    bool isText = false,
    TextStyle? textStyle,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: isActive ? primary.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: isActive
                  ? Border.all(color: primary.withValues(alpha: 0.4), width: 1)
                  : null,
            ),
            child: isText
                ? Text(
                    label ?? '',
                    style: (textStyle ?? const TextStyle(fontSize: 12.5)).copyWith(
                      color: isActive
                          ? primary
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  )
                : Icon(
                    icon,
                    size: 14,
                    color: isActive
                        ? primary
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attrs = widget.controller.getSelectionStyle().attributes;

    final isBold = attrs.containsKey(Attribute.bold.key);
    final isItalic = attrs.containsKey(Attribute.italic.key);
    final isUnderline = attrs.containsKey(Attribute.underline.key);
    final listVal = attrs[Attribute.list.key]?.value;
    final isBulletList = listVal == Attribute.ul.value;
    final isNumberedList = listVal == Attribute.ol.value;
    final isLink = attrs.containsKey(Attribute.link.key);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        border: Border.all(
          color: _isFocused
              ? context.colors.primaryLightColor
              : (isDark
                  ? Colors.white10
                  : context.colors.lightGreyColor),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact, elegant toolbar header
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141E30)
                    : const Color(0xFFF1F5F9),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.darkSlateColor
                        : context.colors.lightGreyColor.withValues(alpha: 0.7),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildToolbarButton(
                    label: 'B',
                    isText: true,
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    tooltip: 'Bold',
                    isActive: isBold,
                    onTap: () => _toggleAttribute(Attribute.bold),
                  ),
                  const SizedBox(width: 2),
                  _buildToolbarButton(
                    label: 'I',
                    isText: true,
                    textStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tooltip: 'Italic',
                    isActive: isItalic,
                    onTap: () => _toggleAttribute(Attribute.italic),
                  ),
                  const SizedBox(width: 2),
                  _buildToolbarButton(
                    label: 'U',
                    isText: true,
                    textStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    tooltip: 'Underline',
                    isActive: isUnderline,
                    onTap: () => _toggleAttribute(Attribute.underline),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 14,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: isDark ? Colors.white12 : context.colors.lightGreyColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildToolbarButton(
                    icon: CupertinoIcons.list_bullet,
                    tooltip: 'Bullet List',
                    isActive: isBulletList,
                    onTap: () => _toggleList(Attribute.ul),
                  ),
                  const SizedBox(width: 2),
                  _buildToolbarButton(
                    icon: CupertinoIcons.list_number,
                    tooltip: 'Numbered List',
                    isActive: isNumberedList,
                    onTap: () => _toggleList(Attribute.ol),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 14,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: isDark ? Colors.white12 : context.colors.lightGreyColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildToolbarButton(
                    icon: CupertinoIcons.link,
                    tooltip: 'Add Link',
                    isActive: isLink,
                    onTap: () => _showLinkDialog(context),
                  ),
                  const SizedBox(width: 2),
                  _buildToolbarButton(
                    icon: CupertinoIcons.clear,
                    tooltip: 'Clear Formatting',
                    isActive: false,
                    onTap: _clearFormatting,
                  ),
                ],
              ),
            ),

            // Text input area
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: widget.minHeight,
                maxHeight: widget.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: QuillEditor.basic(
                  controller: widget.controller,
                  focusNode: _effectiveFocusNode,
                  scrollController: widget.scrollController,
                  config: QuillEditorConfig(
                    placeholder: widget.placeholder,
                    scrollable: true,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.45,
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(2, 2),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      placeHolder: DefaultTextBlockStyle(
                        TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: context.colors.darkGreyColor,
                          height: 1.45,
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(2, 2),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                      lists: DefaultListBlockStyle(
                        TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.45,
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(2, 2),
                        const VerticalSpacing(0, 0),
                        null,
                        null,
                      ),
                    ),
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
