import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/theme/theme_cubit.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/features/ai_settings/domain/repositories/ai_settings_repository.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'workspace_settings_dialog.dart';

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late bool _aiEnabled;

  @override
  void initState() {
    super.initState();
    _aiEnabled = context.read<PreferencesService>().isAiEnabled();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final repo = context.read<AiSettingsRepository>();
        final profile = await repo.getAgentProfile();
        if (mounted && profile.isAiEnabled != _aiEnabled) {
          setState(() {
            _aiEnabled = profile.isAiEnabled;
          });
          context.read<PreferencesService>().setAiEnabled(profile.isAiEnabled);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleAi() async {
    final prefs = context.read<PreferencesService>();
    final repo = context.read<AiSettingsRepository>();
    final newValue = !_aiEnabled;
    setState(() {
      _aiEnabled = newValue;
    });
    await prefs.setAiEnabled(newValue);

    try {
      final realState = await repo.toggleAiStatus(newValue);
      if (mounted && realState != _aiEnabled) {
        setState(() {
          _aiEnabled = realState;
        });
      }
    } catch (_) {}

    if (mounted) {
      AppUtils.showSnackBar(
        context: context,
        title: _aiEnabled

            ? 'AI Calling Engine Resumed'
            : 'AI Calling Engine Paused',
        extraMessage: _aiEnabled
            ? 'The AI agent is actively handling live calls.'
            : 'Outbound and inbound AI lines are currently paused and routing to admin.',
        toastificationType: _aiEnabled
            ? ToastificationType.success
            : ToastificationType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpacedText(
              text: "Overview",
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.colors.blackColor,
            ),
          ],
        ),
        Row(
          children: [
            // Clickable AI Status Pill
            InkWell(
              onTap: _toggleAi,
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: _aiEnabled
                      ? context.colors.successColor.withValues(alpha: 0.1)
                      : context.colors.darkGreyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: _aiEnabled
                        ? context.colors.successColor.withValues(alpha: 0.35)
                        : context.colors.darkGreyColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _aiEnabled
                                ? context.colors.successColor.withValues(
                                    alpha: _pulseController.value * 0.6 + 0.4)
                                : context.colors.darkGreyColor,
                            boxShadow: _aiEnabled
                                ? [
                                    BoxShadow(
                                      color: context.colors.successColor
                                          .withValues(alpha: 0.5),
                                      blurRadius: _pulseController.value * 8,
                                      spreadRadius: _pulseController.value * 2,
                                    )
                                  ]
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _aiEnabled ? "AI Active" : "AI Paused",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: _aiEnabled
                            ? context.colors.successColor
                            : context.colors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Workspace Settings
            InkWell(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (_) => const WorkspaceSettingsDialog(),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.whiteColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        context.colors.mediumGreyColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.settings,
                  color: context.colors.blackColor,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Theme Switch
            InkWell(
              onTap: () {
                final currentMode = context.read<ThemeCubit>().state;
                context.read<ThemeCubit>().setTheme(
                      currentMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark,
                    );
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.whiteColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        context.colors.mediumGreyColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  isDark
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_fill,
                  color: context.colors.blackColor,
                  size: 19,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
