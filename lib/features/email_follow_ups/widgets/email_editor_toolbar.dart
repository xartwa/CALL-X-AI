import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Helper to convert back and forth between HTML and Quill Delta/Document.
class EmailHtmlConverter {
  /// Normalizes HTML before passing to HtmlToDelta so that block paragraphs and line breaks
  /// are preserved as distinct blocks with newlines in Quill.
  static String normalizeHtml(String html) {
    var cleaned = html.trim();
    if (cleaned.isEmpty) return cleaned;
    // Replace <p>...</p> with <div>...</div> to ensure HtmlToDelta creates separate lines for each paragraph
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'<p(\s[^>]*)?>', caseSensitive: false),
      (m) => '<div${m[1] ?? ''}>',
    );
    cleaned = cleaned.replaceAll(RegExp(r'</p>', caseSensitive: false), '</div>');
    return cleaned;
  }

  /// Converts an HTML string to a Quill Delta.
  static Delta htmlToDelta(String html) {
    final trimmed = normalizeHtml(html);
    if (trimmed.isEmpty) {
      return Delta()..insert('\n');
    }
    try {
      final delta = HtmlToDelta().convert(trimmed);
      if (delta.isEmpty) {
        return Delta()..insert('\n');
      }
      return delta;
    } catch (_) {
      return Delta()..insert('$trimmed\n');
    }
  }

  /// Converts a Quill Document to clean HTML.
  static String deltaToHtml(Document document) {
    try {
      final jsonList = document.toDelta().toJson();
      final ops = List<Map<String, dynamic>>.from(
        jsonList.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      final html = QuillDeltaToHtmlConverter(ops).convert();
      return html;
    } catch (_) {
      return document.toPlainText();
    }
  }

  /// Creates a ready-to-use QuillController initialized with the given HTML.
  static QuillController createController(String initialHtml) {
    final delta = htmlToDelta(initialHtml);
    return QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }
}

/// Custom styled toolbar for the email editor that preserves CallX AI branding.
class EmailEditorToolbar extends StatefulWidget {
  final QuillController controller;

  const EmailEditorToolbar({super.key, required this.controller});

  @override
  State<EmailEditorToolbar> createState() => EmailEditorToolbarState();
}

class EmailEditorToolbarState extends State<EmailEditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(EmailEditorToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  void _toggleAttribute(Attribute attribute) {
    final attrs = widget.controller.getSelectionStyle().attributes;
    if (attrs.containsKey(attribute.key)) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
  }

  /// Formats a block-level attribute (e.g. H1, H2, List, Quote) specifically on the
  /// selected text. If only a portion of a line is selected, isolates that portion into its
  /// own block so that unselected text is never unintentionally formatted.
  void applyBlockAttribute(Attribute attribute, {bool isToggle = true}) {
    final selection = widget.controller.selection;
    final doc = widget.controller.document;
    final plainText = doc.toPlainText();

    if (selection.isCollapsed) {
      final attrs = widget.controller.getSelectionStyle().attributes;
      final current = attrs[attribute.key];
      if (isToggle && current != null && current.value == attribute.value) {
        widget.controller.formatSelection(Attribute.clone(attribute, null));
      } else {
        widget.controller.formatSelection(attribute);
      }
      return;
    }

    var start = selection.start;
    var end = selection.end;
    if (start > end) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    if (start < 0) start = 0;
    if (end > plainText.length) end = plainText.length;
    if (start >= end) return;

    // Find line boundaries
    final prevNewline = start > 0 ? plainText.lastIndexOf('\n', start - 1) : -1;
    final lineStart = prevNewline == -1 ? 0 : prevNewline + 1;

    var nextNewline = plainText.indexOf('\n', end);
    if (nextNewline == -1) nextNewline = plainText.length;
    final lineEnd = nextNewline;

    final startsAtLineStart = start == lineStart;
    final endsAtLineEnd = end >= lineEnd;

    var adjustedStart = start;
    var adjustedEnd = end;

    // If selection does not start at line start, isolate with a newline before
    if (!startsAtLineStart) {
      doc.insert(start, '\n');
      adjustedStart += 1;
      adjustedEnd += 1;
    }

    // If selection does not end at line end, isolate with a newline after
    if (!endsAtLineEnd) {
      doc.insert(adjustedEnd, '\n');
    }

    // Update selection to cover the isolated text exactly
    widget.controller.updateSelection(
      TextSelection(baseOffset: adjustedStart, extentOffset: adjustedEnd),
      ChangeSource.local,
    );

    final attrs = widget.controller.getSelectionStyle().attributes;
    final current = attrs[attribute.key];
    if (isToggle && current != null && current.value == attribute.value) {
      widget.controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      widget.controller.formatSelection(attribute);
    }
  }

  void _toggleHeader(Attribute headerAttr) {
    applyBlockAttribute(headerAttr);
  }

  void _setParagraph() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    if (attrs.containsKey(Attribute.header.key)) {
      applyBlockAttribute(Attribute.header, isToggle: false);
    }
  }

  void _toggleList(Attribute listAttr) {
    applyBlockAttribute(listAttr);
  }

  void _toggleBlockQuote() {
    applyBlockAttribute(Attribute.blockQuote);
  }

  void _clearFormatting() {
    final selection = widget.controller.selection;
    if (selection.isCollapsed) return;
    final attrs = widget.controller.getSelectionStyle().attributes;
    for (final attr in attrs.values) {
      widget.controller.formatSelection(Attribute.clone(attr, null));
    }
    if (attrs.containsKey(Attribute.header.key)) {
      widget.controller.formatSelection(Attribute.header);
    }
  }

  void _insertVariable(String variable) {
    final offset = widget.controller.selection.baseOffset;
    widget.controller.document.insert(offset, variable);
    widget.controller.updateSelection(
      TextSelection.collapsed(offset: offset + variable.length),
      ChangeSource.local,
    );
  }

  void _showInsertLinkDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    final selection = widget.controller.selection;
    if (!selection.isCollapsed) {
      final selectedText = widget.controller.document.getPlainText(
        selection.start,
        selection.end - selection.start,
      );
      textCtrl.text = selectedText;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
           
          ),
          elevation: 12,
          child: Container(
            width: 440,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon badge, Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                       
                        const Text(
                          'INSERT HYPERLINK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(CupertinoIcons.clear, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Link Text Field
                Text(
                  'LINK TEXT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
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
                      controller: textCtrl,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        hintText: 'e.g. Click Here / View Proposal',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: context.colors.darkGreyColor,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Destination URL Field
                Text(
                  'DESTINATION URL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
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
                      controller: urlCtrl,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        hintText: 'https://example.com',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: context.colors.darkGreyColor,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                            ),
                            foregroundColor:
                                isDark ? Colors.white : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius,
                              ),
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
                                    extentOffset: offset + text.length),
                                ChangeSource.local,
                              );
                            }
                            widget.controller.formatSelection(LinkAttribute(url));
                            Navigator.pop(dialogCtx);
                          },
                          child: const Text(
                            'Insert Link',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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

  Widget _buildToolbarButton(
    BuildContext context, {
    required Widget child,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? primaryColor.withValues(alpha: 0.16)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isActive
                  ? Border.all(color: primaryColor.withValues(alpha: 0.35))
                  : null,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: isActive
                    ? primaryColor
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: isActive
                      ? primaryColor
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  size: 15,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildColorItem(
      String name, String hex, Color previewColor) {
    return PopupMenuItem<String>(
      value: hex,
      height: 36,
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: previewColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
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
    final isStrike = attrs.containsKey(Attribute.strikeThrough.key);

    final headerVal = attrs[Attribute.header.key]?.value;
    final listVal = attrs[Attribute.list.key]?.value;
    final isBlockQuote = attrs.containsKey(Attribute.blockQuote.key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        border: Border.all(
          color: isDark ? Colors.white12 : context.colors.lightGreyColor,
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          // Bold
          _buildToolbarButton(
            context,
            child: const Text('B',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            tooltip: 'Bold',
            isActive: isBold,
            onTap: () => _toggleAttribute(Attribute.bold),
          ),
          // Italic
          _buildToolbarButton(
            context,
            child: const Text('I',
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Italic',
            isActive: isItalic,
            onTap: () => _toggleAttribute(Attribute.italic),
          ),
          // Underline
          _buildToolbarButton(
            context,
            child: const Text('U',
                style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Underline',
            isActive: isUnderline,
            onTap: () => _toggleAttribute(Attribute.underline),
          ),
          // Strikethrough
          _buildToolbarButton(
            context,
            child: const Text('S',
                style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Strikethrough',
            isActive: isStrike,
            onTap: () => _toggleAttribute(Attribute.strikeThrough),
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Heading 1
          _buildToolbarButton(
            context,
            child: const Text('H1',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            tooltip: 'Heading 1',
            isActive: headerVal == 1,
            onTap: () => _toggleHeader(Attribute.h1),
          ),
          // Heading 2
          _buildToolbarButton(
            context,
            child: const Text('H2',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            tooltip: 'Heading 2',
            isActive: headerVal == 2,
            onTap: () => _toggleHeader(Attribute.h2),
          ),
          // Paragraph
          _buildToolbarButton(
            context,
            child: const Text('P',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            tooltip: 'Paragraph',
            isActive: headerVal == null || headerVal == 0,
            onTap: _setParagraph,
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Bullet List
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.list_bullet, size: 16),
            tooltip: 'Bullet List',
            isActive: listVal == Attribute.ul.value,
            onTap: () => _toggleList(Attribute.ul),
          ),
          // Numbered List
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.list_number, size: 16),
            tooltip: 'Numbered List',
            isActive: listVal == Attribute.ol.value,
            onTap: () => _toggleList(Attribute.ol),
          ),
          // Blockquote
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.quote_bubble, size: 15),
            tooltip: 'Blockquote',
            isActive: isBlockQuote,
            onTap: () => _toggleBlockQuote(),
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Clear formatting
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.paintbrush, size: 15),
            tooltip: 'Clear Formatting',
            onTap: _clearFormatting,
          ),

          // Color Palette Popup
          PopupMenuButton<String>(
            tooltip: 'Text Color',
            offset: const Offset(0, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            onSelected: (colorHex) {
              widget.controller.formatSelection(ColorAttribute(colorHex));
            },
            itemBuilder: (context) => [
              _buildColorItem(
                  'Primary Blue', '#3B82F6', const Color(0xFF3B82F6)),
              _buildColorItem(
                  'Emerald Green', '#10B981', const Color(0xFF10B981)),
              _buildColorItem('Coral Red', '#EF4444', const Color(0xFFEF4444)),
              _buildColorItem('Amber Gold', '#F59E0B', const Color(0xFFF59E0B)),
              _buildColorItem(
                  'Royal Purple', '#8B5CF6', const Color(0xFF8B5CF6)),
              _buildColorItem('Charcoal', '#374151', const Color(0xFF374151)),
            ],
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: const Icon(CupertinoIcons.paintbrush_fill, size: 15),
            ),
          ),

          // Insert Link
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.link, size: 15),
            tooltip: 'Insert Link',
            onTap: () => _showInsertLinkDialog(context),
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Dynamic Variable Tags Pill
          PopupMenuButton<String>(
            tooltip: 'Insert Dynamic Variable',
            offset: const Offset(0, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            onSelected: _insertVariable,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: '{name}',
                height: 36,
                child: Text('{name} - Customer Full Name',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: '{company}',
                height: 36,
                child: Text('{company} - Company Name',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: '{phone}',
                height: 36,
                child: Text('{phone} - Phone Number',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: '{date}',
                height: 36,
                child: Text('{date} - Current Date',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: '{agent}',
                height: 36,
                child: Text('{agent} - Your Name / Agent',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.tag_fill,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'VARIABLES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A beautifully styled Quill editor container that integrates with CallX AI design system.
class EmailQuillEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final double minHeight;
  final double? maxHeight;
  final String placeholder;

  const EmailQuillEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.scrollController,
    this.minHeight = 160,
    this.maxHeight = 280,
    this.placeholder = 'Write your follow-up email...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        border: Border.all(
          color: isDark ? Colors.white12 : context.colors.lightGreyColor,
        ),
      ),
      child: QuillEditor.basic(
        controller: controller,
        focusNode: focusNode,
        scrollController: scrollController,
        config: QuillEditorConfig(
          placeholder: placeholder,
          scrollable: true,
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          customStyles: DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
              ),
              const HorizontalSpacing(0, 0),
              const VerticalSpacing(2, 2),
              const VerticalSpacing(0, 0),
              null,
            ),
            h1: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
                height: 1.4,
              ),
              const HorizontalSpacing(0, 0),
              const VerticalSpacing(6, 4),
              const VerticalSpacing(0, 0),
              null,
            ),
            h2: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.4,
              ),
              const HorizontalSpacing(0, 0),
              const VerticalSpacing(4, 2),
              const VerticalSpacing(0, 0),
              null,
            ),
          ),
        ),
      ),
    );
  }
}
