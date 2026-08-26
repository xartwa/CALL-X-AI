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

    // Fixed schedule times for today's calls queue
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
          color: context.colors.mediumGreyColor.withValues(alpha: 0.3),
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
            children: [
              Row(
                children: [
                  SpacedText(
                    text: "Today's Calls",
                    color: context.colors.blackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(width: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.colors.primaryLightColor
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$count in Queue Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go(AppRoutesPath.calls),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      "VIEW ALL CALLS",
                      style: TextStyle(
                        color: context.colors.primaryLightColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: 12,
                      color: context.colors.primaryLightColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todayDateFormatted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.darkGreyColor,
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 640,
            child: todayCalls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primaryLightColor
                                .withValues(alpha: 0.08),
                          ),
                          child: Icon(
                            CupertinoIcons.phone_badge_plus,
                            size: 36,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "No scheduled calls for today",
                          style: TextStyle(
                            color: context.colors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "All pending appointments for today have been completed.",
                          style: TextStyle(
                            color: context.colors.darkGreyColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          icon: const Icon(CupertinoIcons.add, size: 14),
                          label: const Text(
                            "Schedule Call",
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primaryLightColor,
                            foregroundColor: Colors.white,
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
                              .withValues(alpha: 0.4),
                        ),
                        radius: const Radius.circular(8),
                        thickness: WidgetStateProperty.all(6),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(right: 12),
                        itemCount: todayCalls.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
