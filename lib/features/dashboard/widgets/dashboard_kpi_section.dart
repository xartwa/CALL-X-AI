import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        return Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: "Total Calls",
                value: "${kpi.totalCalls}",
                icon: CupertinoIcons.phone_fill,
                iconColor: context.colors.primaryLightColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                title: "Calls Today",
                value: "${kpi.callsToday}",
                icon: CupertinoIcons.phone_badge_plus,
                iconColor: context.colors.warningColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                title: "Success Rate",
                value: "${kpi.successRate.toStringAsFixed(1)}%",
                icon: CupertinoIcons.checkmark_alt_circle,
                iconColor: context.colors.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _KpiCard(
                title: "Total Follow-ups",
                value: "${kpi.totalFollowUps}",
                icon: CupertinoIcons.mail_solid,
                iconColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
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
              padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
              child: SizedBox(
                height: 112,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.whiteColor,
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

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.colors.blackColor,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
