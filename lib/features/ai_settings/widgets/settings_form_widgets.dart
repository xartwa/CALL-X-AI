import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsLabel extends StatelessWidget {
  const SettingsLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .6,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[700],
        ),
      );
}

class DraftTextField extends StatefulWidget {
  const DraftTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int minLines;
  final int maxLines;

  @override
  State<DraftTextField> createState() => _DraftTextFieldState();
}

class _DraftTextFieldState extends State<DraftTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DraftTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 13, height: 1.4),
        decoration: InputDecoration(
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          ),
        ),
      );
}

class SettingsBanner extends StatelessWidget {
  const SettingsBanner({
    super.key,
    required this.icon,
    required this.text,
    this.warning = false,
  });

  final IconData icon;
  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color =
        warning ? context.colors.warningColor : const Color(0xFF10B981);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        border: Border.all(color: color.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsKeyValue extends StatelessWidget {
  const SettingsKeyValue({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.darkGreyColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}
