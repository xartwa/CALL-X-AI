import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/widgets/stat_card_widget.dart';
import 'package:callx_ai/theme/app_colors.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';

class DashboardKpiSection extends StatelessWidget {
  const DashboardKpiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final kpi = state.snapshot?.kpi;
        if (state.status == DashboardStatus.loading && kpi == null) {
          return const _KpiLoading();
        }
        if (kpi == null) return const SizedBox.shrink();
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatCardWidget(
                label: "Total Calls",
                value: "${kpi.totalCalls}",
                icon: CupertinoIcons.phone_fill,
                iconColor: context.colors.primaryLightColor,
                iconBgColor:
                    context.colors.primaryLightColor.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: "Calls Today",
                value: "${kpi.callsToday}",
                icon: CupertinoIcons.phone_badge_plus,
                iconColor: context.colors.warningColor,
                iconBgColor:
                    context.colors.warningColor.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: "Success Rate",
                value: "${kpi.successRate.toStringAsFixed(1)}%",
                icon: CupertinoIcons.checkmark_alt_circle,
                iconColor: context.colors.successColor,
                iconBgColor:
                    context.colors.successColor.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 14),
              StatCardWidget(
                label: "Total Follow-ups",
                value: "${kpi.totalFollowUps}",
                icon: CupertinoIcons.mail_solid,
                iconColor: const Color(0xFF8B5CF6),
                iconBgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KpiLoading extends StatelessWidget {
  const _KpiLoading();

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 3 ? 0 : 14),
              child: SizedBox(
                height: 82,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const AppLoadingView(compact: true),
                ),
              ),
            ),
          ),
        ),
      );
}

