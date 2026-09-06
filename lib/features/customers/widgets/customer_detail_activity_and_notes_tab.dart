import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/customers/widgets/customers_table_widget.dart'
    show User;
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class CustomerDetailActivityAndNotesTab extends StatelessWidget {
  final User user;
  final TextEditingController notesCtrl;

  const CustomerDetailActivityAndNotesTab({
    super.key,
    required this.user,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timelineEvents = [
      _TimelineEvent(
        title: text.customerProfileCreated,
        description: text.customerProfileCreatedDesc,
        date: AppDateTime.displayDateTime(user.createdAt),
        icon: CupertinoIcons.person_add_solid,
        color: context.colors.primaryLightColor,
      ),
      if (user.lastContact != null)
        _TimelineEvent(
          title: text.lastCustomerContactTitle,
          description: text.lastCustomerContactDesc,
          date: AppDateTime.displayDateTime(user.lastContact),
          icon: CupertinoIcons.phone_fill,
          color: context.colors.successColor,
        ),
      if (user.reasonForContact.isNotEmpty)
        _TimelineEvent(
          title: text.reasonLogged,
          description: user.reasonForContact,
          date: AppDateTime.displayDateTime(user.createdAt),
          icon: CupertinoIcons.doc_text_fill,
          color: context.colors.warningColor,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Timeline Column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.time,
                        size: 18, color: context.colors.darkGreyColor),
                    const SizedBox(width: 8),
                    Text(
                      text.activityLog,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: timelineEvents.isEmpty
                      ? Center(
                          child: Text(
                            text.noRecordedActivities,
                            style: TextStyle(
                                color: context.colors.darkGreyColor,
                                fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: timelineEvents.length,
                          itemBuilder: (context, index) {
                            final event = timelineEvents[index];
                            final isLast = index == timelineEvents.length - 1;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: event.color.withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(event.icon,
                                          size: 14, color: event.color),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.black12,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.description,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.colors.darkGreyColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.date,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: context.colors.darkGreyColor
                                              .withAlpha(180),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 32, thickness: 1),

          // Internal Notes Column
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.square_pencil,
                        size: 18, color: context.colors.darkGreyColor),
                    const SizedBox(width: 8),
                    Text(
                      text.internalNotes,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextFormField(
                    controller: notesCtrl,
                    maxLines: null,
                    minLines: 8,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                    decoration: InputDecoration(
                      hintText: text.internalNotesHint,
                      hintStyle: TextStyle(
                          color: context.colors.darkGreyColor, fontSize: 12),
                      fillColor: isDark
                          ? AppColors.darkSlateColor.withAlpha(128)
                          : const Color(0xFFF8FAFC),
                      filled: true,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withAlpha(20)),
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.boxRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.boxRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final Color color;

  _TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.color,
  });
}
