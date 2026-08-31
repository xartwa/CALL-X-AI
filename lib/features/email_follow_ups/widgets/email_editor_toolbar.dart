import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailEditorToolbar extends StatelessWidget {
  final TextEditingController controller;

  const EmailEditorToolbar({super.key, required this.controller});

  void _insertTag(
      TextEditingController controller, String openTag, String closeTag) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isValid) {
      final start = selection.start;
      final end = selection.end;
      final selectedText = text.substring(start, end);
      final newText =
          text.replaceRange(start, end, '$openTag$selectedText$closeTag');
      controller.text = newText;
      final offset =
          start + openTag.length + selectedText.length + closeTag.length;
      controller.selection = TextSelection.collapsed(offset: offset);
    } else {
      final newText = '$text$openTag$closeTag';
      controller.text = newText;
      controller.selection =
          TextSelection.collapsed(offset: newText.length - closeTag.length);
    }
  }

  void _insertText(TextEditingController controller, String textToInsert) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.isValid) {
      final start = selection.start;
      final end = selection.end;
      final newText = text.replaceRange(start, end, textToInsert);
      controller.text = newText;
      controller.selection =
          TextSelection.collapsed(offset: start + textToInsert.length);
    } else {
      final newText = '$text$textToInsert';
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: newText.length);
    }
  }

  void _showInsertLinkDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

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
          child: Container(
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'INSERT HYPERLINK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      icon: const Icon(CupertinoIcons.clear, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'LINK TEXT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: textCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'e.g. Click Here / View Proposal',
                    hintStyle: TextStyle(
                        fontSize: 12, color: context.colors.darkGreyColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'DESTINATION URL',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: urlCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'https://example.com/document',
                    hintStyle: TextStyle(
                        fontSize: 12, color: context.colors.darkGreyColor),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      final linkText = textCtrl.text.trim();
                      final url = urlCtrl.text.trim();
                      if (url.isNotEmpty) {
                        final display = linkText.isNotEmpty ? linkText : url;
                        _insertText(controller, '<a href="$url">$display</a>');
                      }
                      Navigator.pop(dialogCtx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(dialogCtx).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    child: const Text(
                      'INSERT LINK',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
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
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: child,
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
            tooltip: 'Bold (<b>)',
            onTap: () => _insertTag(controller, '<b>', '</b>'),
          ),
          // Italic
          _buildToolbarButton(
            context,
            child: const Text('I',
                style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Italic (<i>)',
            onTap: () => _insertTag(controller, '<i>', '</i>'),
          ),
          // Underline
          _buildToolbarButton(
            context,
            child: const Text('U',
                style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Underline (<u>)',
            onTap: () => _insertTag(controller, '<u>', '</u>'),
          ),
          // Strikethrough
          _buildToolbarButton(
            context,
            child: const Text('S',
                style: TextStyle(
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.bold)),
            tooltip: 'Strikethrough (<s>)',
            onTap: () => _insertTag(controller, '<s>', '</s>'),
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
            tooltip: 'Heading 1 (<h1>)',
            onTap: () => _insertTag(controller, '<h1>', '</h1>'),
          ),
          // Heading 2
          _buildToolbarButton(
            context,
            child: const Text('H2',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            tooltip: 'Heading 2 (<h2>)',
            onTap: () => _insertTag(controller, '<h2>', '</h2>'),
          ),
          // Paragraph
          _buildToolbarButton(
            context,
            child: const Text('P',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            tooltip: 'Paragraph (<p>)',
            onTap: () => _insertTag(controller, '<p>', '</p>'),
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Bullet List
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.list_bullet, size: 16),
            tooltip: 'Bullet List (<ul><li>)',
            onTap: () => _insertTag(controller, '<ul>\n  <li>', '</li>\n</ul>'),
          ),
          // Numbered List
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.list_number, size: 16),
            tooltip: 'Numbered List (<ol><li>)',
            onTap: () => _insertTag(controller, '<ol>\n  <li>', '</li>\n</ol>'),
          ),
          // Quote
          _buildToolbarButton(
            context,
            child: const Icon(CupertinoIcons.quote_bubble, size: 15),
            tooltip: 'Blockquote',
            onTap: () =>
                _insertTag(controller, '<blockquote>', '</blockquote>'),
          ),

          const SizedBox(
            height: 18,
            child: VerticalDivider(width: 12, thickness: 1),
          ),

          // Color Palette Popup
          PopupMenuButton<String>(
            tooltip: 'Text Color',
            offset: const Offset(0, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            onSelected: (colorHex) {
              _insertTag(
                  controller, '<span style="color: $colorHex;">', '</span>');
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

          // Variable Tags Pill
          PopupMenuButton<String>(
            tooltip: 'Insert Dynamic Variable',
            offset: const Offset(0, 36),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            onSelected: (variable) => _insertText(controller, variable),
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
