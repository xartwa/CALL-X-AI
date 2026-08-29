import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/theme/app_colors.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'today_scheduled_call_tile.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';

class TodayScheduledCallsSection extends StatelessWidget {
  const TodayScheduledCallsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          color: context.colors.mediumGreyColor.withValues(alpha: 0.3),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title + Badge + View All
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SpacedText(
                            text: "Today's CALLS",
                            color: context.colors.blackColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            todayLabel,
                            style: TextStyle(
                              fontSize: 11.5,
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
                              .withValues(alpha: 0.07),
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
                            const SizedBox(width: 3),
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

                const SizedBox(height: 20),

                // ─── Column Headers ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 78,
                        child: Text(
                          'TIME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.colors.darkGreyColor
                                .withValues(alpha: 0.65),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: Text(
                          'CONTACT & PURPOSE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.colors.darkGreyColor
                                .withValues(alpha: 0.65),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 90),
                      Text(
                        'ACTIONS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.colors.darkGreyColor
                              .withValues(alpha: 0.65),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: context.colors.mediumGreyColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),

          // ─── Calls List ───────────────────────────────────────────────
          SizedBox(
            height: 560,
            child: dashboardState.status == DashboardStatus.loading &&
                    todayCalls.isEmpty
                ? const AppLoadingView()
                : dashboardState.status == DashboardStatus.failure &&
                        todayCalls.isEmpty
                    ? AppErrorView(
                        message: 'Dashboard data could not be loaded',
                        onRetry: () => context.read<DashboardCubit>().retry())
                    : todayCalls.isEmpty
                        ? const AppEmptyView(
                            title: 'No calls scheduled today',
                            description:
                                'Your pipeline is clear. Schedule your first call or let AI assign the next lead.',
                            icon: CupertinoIcons.calendar_badge_plus,
                          )
                        : Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  context.colors.lightGreyColor
                                      .withValues(alpha: 0.5),
                                ),
                                radius: const Radius.circular(10),
                                thickness: WidgetStateProperty.all(4),
                              ),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 22, 24),
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
