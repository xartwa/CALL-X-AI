import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_dropdown_widget.dart';
import '../../../../core/widgets/custom_tag_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../cubit/appointments_state.dart';
import '../../domain/entities/appointment_entity.dart';
import '../widgets/add_exception_dialog.dart';
import '../widgets/time_windows_dialog.dart';

class AvailabilityTabView extends StatelessWidget {
  const AvailabilityTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cubit = context.read<AppointmentsCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;

              final weeklyCard =
                  _buildWeeklyCard(context, state, cubit, isDark);
              final settingsCard =
                  _buildSettingsCard(context, state, cubit, isDark);
              final exceptionsCard =
                  _buildExceptionsCard(context, state, cubit, isDark);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Weekly Availability (takes ~55% width)
                    Expanded(
                      flex: 6,
                      child: weeklyCard,
                    ),
                    const SizedBox(width: 16),
                    // Right: Settings & Exceptions (takes ~45% width)
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          settingsCard,
                          const SizedBox(height: 16),
                          exceptionsCard,
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    weeklyCard,
                    const SizedBox(height: 16),
                    settingsCard,
                    const SizedBox(height: 16),
                    exceptionsCard,
                  ],
                );
              }
            },
          ),
        );
      },
    );
  }

  // --- 1. Weekly Availability Card ---
  Widget _buildWeeklyCard(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    // Sort rules Monday (0) to Sunday (6)
    final rules = List<AvailabilityRuleEntity>.from(state.availabilityRules)
      ..sort((a, b) => a.weekday.compareTo(b.weekday));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(CupertinoIcons.calendar,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Weekly Availability'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.blackColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Days List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rules.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return InkWell(
                onTap: () => TimeWindowsDialog.show(context, rule: rule),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      // Toggle Switch
                      CupertinoSwitch(
                        value: rule.enabled,
                        activeTrackColor: context.colors.successColor,
                        onChanged: (val) {
                          cubit.toggleRuleEnabled(rule.weekday, val);
                        },
                      ),
                      const SizedBox(width: 14),

                      // Day Name
                      SizedBox(
                        width: 100,
                        child: Text(
                          rule.weekdayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: rule.enabled
                                ? context.colors.blackColor
                                : context.colors.darkGreyColor,
                          ),
                        ),
                      ),

                      // Hours & Type Pill
                      Expanded(
                        child: Row(
                          children: [
                            if (rule.enabled) ...[
                              Text(
                                '${rule.startTime.substring(0, 5)} – ${rule.endTime.substring(0, 5)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.blackColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (rule.availabilityType.toLowerCase() ==
                                  'preferred')
                                CustomTagWidget(
                                  label: 'Preferred',
                                  color: context.colors.successColor,
                                )
                              else if (rule.availabilityType.toLowerCase() ==
                                  'manual_approval')
                                CustomTagWidget(
                                  label: 'Manual Approval',
                                  color: context.colors.warningColor,
                                ),
                            ] else ...[
                              Text(
                                'Unavailable',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.darkGreyColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Edit Chevron
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: context.colors.darkGreyColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 2. Default Settings Card ---
  Widget _buildSettingsCard(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    final settings = state.settings;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Booking Settings & Buffers',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Duration & Notice
          Row(
            children: [
              Expanded(
                child: _buildSettingDropdown<int>(
                  context: context,
                  label: 'DEFAULT DURATION',
                  currentValue: settings.defaultDurationMinutes,
                  items: const [15, 30, 45, 60, 90],
                  itemBuilder: (val) => '$val minutes',
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(
                          settings.copyWith(defaultDurationMinutes: val));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettingDropdown<int>(
                  context: context,
                  label: 'MINIMUM NOTICE',
                  currentValue: settings.minimumNoticeMinutes,
                  items: const [60, 120, 240, 1440],
                  itemBuilder: (val) => val == 60
                      ? '1 hour'
                      : (val == 1440 ? '24 hours' : '${val ~/ 60} hours'),
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(
                          settings.copyWith(minimumNoticeMinutes: val));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buffers
          Row(
            children: [
              Expanded(
                child: _buildSettingDropdown<int>(
                  context: context,
                  label: 'BUFFER BEFORE',
                  currentValue: settings.bufferBeforeMinutes,
                  items: const [0, 5, 10, 15, 30],
                  itemBuilder: (val) => val == 0 ? 'None' : '$val minutes',
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(
                          settings.copyWith(bufferBeforeMinutes: val));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettingDropdown<int>(
                  context: context,
                  label: 'BUFFER AFTER',
                  currentValue: settings.bufferAfterMinutes,
                  items: const [0, 5, 10, 15, 30],
                  itemBuilder: (val) => val == 0 ? 'None' : '$val minutes',
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(
                          settings.copyWith(bufferAfterMinutes: val));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Timezone Display
          Text(
            'TIMEZONE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.colors.darkGreyColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
              border: Border.all(
                color: context.colors.mediumGreyColor.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.globe,
                    size: 16, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 10),
                Text(
                  settings.timezone,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.blackColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Toronto / Eastern Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingDropdown<T>({
    required BuildContext context,
    required String label,
    required T currentValue,
    required List<T> items,
    required String Function(T) itemBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: context.colors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 6),
        AppDropdownWidget<T>(
          value: currentValue,
          items: items,
          itemBuilder: itemBuilder,
          onChanged: onChanged,
          height: 44,
        ),
      ],
    );
  }

  // --- 3. Exceptions & Time Off Card ---
  Widget _buildExceptionsCard(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    final exceptions = state.exceptions;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Add Button
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.calendar_badge_minus,
                        size: 20,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Exceptions & Time Off'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.blackColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => AddExceptionDialog.show(context),
                    icon: const Icon(CupertinoIcons.plus,
                        size: 15, color: Colors.white),
                    label: const Text(
                      'Add Exception',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: 
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Exceptions list
          if (exceptions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No exceptions added. Standard weekly schedule applies to all dates.',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exceptions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final ex = exceptions[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      // Date label
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(ex.date),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: context.colors.blackColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Availability Pill (Using standard CustomTagWidget)
                      CustomTagWidget(
                        label: ex.isAvailable ? 'Custom Hours' : 'Unavailable',
                        color: ex.isAvailable
                            ? context.colors.successColor
                            : context.colors.errorColor,
                      ),
                      const SizedBox(width: 12),

                      // Reason & Hours
                      Expanded(
                        child: Text(
                          ex.reason.isNotEmpty
                              ? ex.reason
                              : (ex.isAvailable && ex.startTime != null
                                  ? '${ex.startTime!.substring(0, 5)} - ${ex.endTime!.substring(0, 5)}'
                                  : 'Date blocked'),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.colors.blackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Delete action
                      AppActionButton(
                        type: AppActionType.delete,
                        tooltip: 'Remove Exception',
                        onTap: () => cubit.deleteException(ex.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
