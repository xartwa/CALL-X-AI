import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'today_scheduled_call_tile.dart';

class TodayScheduledCallsSection extends StatelessWidget {
  const TodayScheduledCallsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final customersState = context.watch<CustomersCubit>().state;
    final allUsers = customersState.users;

    const scheduleTimes = [
      "09:30 AM",
      "10:15 AM",
      "11:00 AM",
      "01:30 PM",
      "02:45 PM",
      "03:30 PM",
      "04:15 PM",
      "05:00 PM",
      "05:45 PM",
      "06:30 PM",
    ];

    final todayCalls = allUsers;
    final count = todayCalls.length;
    final todayDateFormatted = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SpacedText(
                    text: "Today's Calls",
                    color: context.colors.blackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.go(AppRoutesPath.calls),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View all",
                        style: TextStyle(
                          color: context.colors.primaryLightColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 11,
                        color: context.colors.primaryLightColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            todayDateFormatted,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: context.colors.darkGreyColor,
            ),
          ),
          const SizedBox(height: 22),

          // Scrollable Calls List
          SizedBox(
            height: 600,
            child: todayCalls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.calendar_badge_minus,
                          size: 36,
                          color: context.colors.darkGreyColor
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No scheduled calls for today",
                          style: TextStyle(
                            color: context.colors.blackColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "All appointments for today are caught up.",
                          style: TextStyle(
                            color: context.colors.darkGreyColor,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const CallActionDialog(
                                startInGroupMode: false,
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.plus, size: 13),
                          label: const Text(
                            "Schedule Call",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.colors.primaryLightColor,
                            side: BorderSide(
                              color: context.colors.primaryLightColor
                                  .withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(
                          context.colors.mediumGreyColor
                              .withValues(alpha: 0.35),
                        ),
                        radius: const Radius.circular(8),
                        thickness: WidgetStateProperty.all(5),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(right: 6),
                        itemCount: todayCalls.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => Divider(
                          color: context.colors.mediumGreyColor
                              .withValues(alpha: 0.15),
                          height: 1,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final user = todayCalls[index];
                          final time =
                              scheduleTimes[index % scheduleTimes.length];
                          final isPriority =
                              user.leadPriority.toLowerCase() == 'hot' ||
                                  index % 3 == 0;

                          return TodayScheduledCallTile(
                            user: user,
                            scheduledTime: time,
                            isPriority: isPriority,
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
