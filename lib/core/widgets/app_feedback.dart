import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';

/// Shared feedback primitives used by every feature for a consistent visual language.
class AppLoadingView extends StatefulWidget {
  const AppLoadingView(
      {super.key, this.message, this.compact = false, this.color});

  final String? message;
  final bool compact;
  final Color? color;

  @override
  State<AppLoadingView> createState() => _AppLoadingViewState();
}

/// Small inline variant for buttons and table rows.
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({super.key, this.color, this.size = 18});

  final Color? color;
  final double size;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: _controller.value,
            strokeWidth: widget.size <= 18 ? 2 : 2.5,
            color: widget.color ?? context.colors.primaryLightColor,
          ),
        ),
      );
}

class _AppLoadingViewState extends State<AppLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 18.0 : 28.0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => SizedBox(
              width: size * 2.3,
              height: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(3, (index) {
                  final phase = (_controller.value + index * .22) % 1;
                  final scale = .55 + ((phase < .5 ? phase : 1 - phase) * .9);
                  return Transform.scale(
                    scaleY: scale,
                    child: Container(
                      width: widget.compact ? 4 : 6,
                      height: size,
                      decoration: BoxDecoration(
                        color: widget.color ?? context.colors.primaryLightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              style: TextStyle(
                color: context.colors.darkGreyColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  const AppErrorView(
      {super.key,
      required this.message,
      this.onRetry,
      this.actionLabel = 'Retry'});

  final String message;
  final VoidCallback? onRetry;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.errorColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  Icon(CupertinoIcons.exclamationmark, color: accent, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.colors.blackColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(CupertinoIcons.refresh, size: 14),
                label: Text(actionLabel),
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.colors.primaryLightColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView(
      {super.key,
      required this.title,
      this.description,
      this.icon = CupertinoIcons.tray});

  final String title;
  final String? description;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 30,
                color: context.colors.darkGreyColor.withValues(alpha: .55)),
            const SizedBox(height: 12),
            Text(title,
                style: TextStyle(
                    color: context.colors.blackColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: context.colors.darkGreyColor, fontSize: 12)),
            ],
          ]),
        ),
      );
}
