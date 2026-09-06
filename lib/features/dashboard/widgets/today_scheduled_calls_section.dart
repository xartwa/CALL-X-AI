import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'today_scheduled_call_tile.dart';

class TodayScheduledCallsSection extends StatelessWidget {
  const TodayScheduledCallsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardState = context.watch<DashboardCubit>().state;

    final todayCalls = dashboardState.snapshot?.todayCalls.items ??
        const <DashboardTodayCall>[];
    final todayLabel = AppDateTime.displayWeekdayDate(
      dashboardState.snapshot?.date ?? DateTime.now(),
    );

    return Container(
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: isDark ? 0.3 : 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header Section ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpacedText(
                        text: "TODAY'S CALLS",
                        color: context.colors.blackColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // View All button
                InkWell(
                  onTap: () => context.go(AppRoutesPath.calls),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View all",
                          style: TextStyle(
                            color: context.colors.primaryLightColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 11,
                          color: context.colors.primaryLightColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: context.colors.mediumGreyColor
                .withValues(alpha: isDark ? 0.25 : 0.4),
          ),

          // ─── Calls List (Scrollable) ───────────────────────────────────
          SizedBox(
            height: 400,
            child: dashboardState.status == DashboardStatus.loading &&
                    todayCalls.isEmpty
                ? const AppLoadingView()
                : dashboardState.status == DashboardStatus.failure &&
                        todayCalls.isEmpty
                    ? AppErrorView(
                        message: 'Could not load today\'s calls',
                        onRetry: () => context.read<DashboardCubit>().retry(),
                      )
                    : todayCalls.isEmpty
                        ? const AppEmptyView(
                            title: 'No calls scheduled today',
                            description: 'Your pipeline is clear for today.',
                            icon: CupertinoIcons.phone,
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  context.colors.lightGreyColor
                                      .withValues(alpha: 0.4),
                                ),
                                radius: const Radius.circular(10),
                                thickness: WidgetStateProperty.all(4),
                              ),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 18, 20),
                                itemCount: todayCalls.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final call = todayCalls[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: TodayScheduledCallTile(
                                      call: call,
                                      isPriority: call.isPriority,
                                      isNext: call.isCurrent,
                                      isDone: call.isDone,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
