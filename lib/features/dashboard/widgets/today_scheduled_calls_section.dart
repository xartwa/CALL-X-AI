import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'today_scheduled_call_tile.dart';

class TodayScheduledCallsSection extends StatelessWidget {
  const TodayScheduledCallsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersState = context.watch<CustomersCubit>().state;
    final allUsers = customersState.users;

    const scheduleTimes = [
      "09:00 AM", "09:30 AM", "10:00 AM", "10:45 AM",
      "11:30 AM", "12:00 PM", "01:00 PM", "01:45 PM",
      "02:30 PM", "03:15 PM", "04:00 PM", "04:30 PM",
    ];

    final todayCalls = allUsers;
    const doneSoFar = 2;
    final todayLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

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
            child: todayCalls.isEmpty
                ? _EmptyState(isDark: isDark)
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
                        padding: const EdgeInsets.fromLTRB(16, 4, 22, 24),
                        itemCount: todayCalls.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = todayCalls[index];
                          final time = scheduleTimes[index % scheduleTimes.length];
                          final isHot = user.leadPriority.toLowerCase() == 'hot';
                          final isDone = index < doneSoFar;
                          final isNext = index == doneSoFar;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: TodayScheduledCallTile(
                              user: user,
                              scheduledTime: time,
                              isPriority: isHot,
                              isNext: isNext,
                              isDone: isDone,
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

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.primaryLightColor.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 28,
                color: context.colors.primaryLightColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No calls scheduled today",
              style: TextStyle(
                color: context.colors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your pipeline is clear. Schedule your first\ncall or let AI assign the next lead.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.darkGreyColor,
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const CallActionDialog(
                        startInGroupMode: false,
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.phone_badge_plus, size: 14),
                  label: const Text(
                    "Schedule Call",
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryLightColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
