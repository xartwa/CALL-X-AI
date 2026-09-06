import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AppActionType { call, view, edit, delete, email, message, download, video }

class AppActionButton extends StatefulWidget {
  final AppActionType type;
  final VoidCallback onTap;
  final String? tooltip;

  const AppActionButton({
    super.key,
    required this.type,
    required this.onTap,
    this.tooltip,
  });

  @override
  State<AppActionButton> createState() => _AppActionButtonState();
}

class _AppActionButtonState extends State<AppActionButton> {
  bool _isHovered = false;

  IconData _getIcon() {
    switch (widget.type) {
      case AppActionType.call:
        return CupertinoIcons.phone_fill;
      case AppActionType.view:
        return CupertinoIcons.eye_fill;
      case AppActionType.edit:
        return CupertinoIcons.pencil;
      case AppActionType.delete:
        return CupertinoIcons.trash_fill;
      case AppActionType.email:
        return CupertinoIcons.mail_solid;
      case AppActionType.message:
        return CupertinoIcons.chat_bubble_fill;
      case AppActionType.download:
        return CupertinoIcons.cloud_download_fill;
      case AppActionType.video:
        return CupertinoIcons.videocam_fill;
    }
  }

  Color _getColor(BuildContext context) {
    switch (widget.type) {
      case AppActionType.call:
        return context.colors.successColor;
      case AppActionType.view:
        return context.colors.primaryLightColor;
      case AppActionType.edit:
        return context.colors.warningColor;
      case AppActionType.delete:
        return context.colors.errorColor;
      case AppActionType.email:
        return context.colors.infoColor;
      case AppActionType.message:
        return context.colors.queuedColor;
      case AppActionType.download:
        return context.colors.darkGreyColor;
      case AppActionType.video:
        return context.colors.successColor;
    }
  }

  String _getDefaultTooltip() {
    switch (widget.type) {
      case AppActionType.call:
        return 'Call';
      case AppActionType.view:
        return 'View Details';
      case AppActionType.edit:
        return 'Edit Record';
      case AppActionType.delete:
        return 'Delete Record';
      case AppActionType.email:
        return 'Send Email';
      case AppActionType.message:
        return 'Send Message';
      case AppActionType.download:
        return 'Download';
      case AppActionType.video:
        return 'Join Meeting';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    final icon = _getIcon();

    return Tooltip(
      message: widget.tooltip ?? _getDefaultTooltip(),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _isHovered
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? color : color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}
