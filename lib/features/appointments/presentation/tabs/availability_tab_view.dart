import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/theme_constants.dart';
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

              final weeklyCard = _buildWeeklyCard(context, state, cubit, isDark);
              final settingsCard = _buildSettingsCard(context, state, cubit, isDark);
              final exceptionsCard = _buildExceptionsCard(context, state, cubit, isDark);

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
                  child: const Icon(
                    CupertinoIcons.calendar,
                    size: 20,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Availability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.colors.blackColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set standard booking hours for each day of the week',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ],
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
            separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return InkWell(
                onTap: () => TimeWindowsDialog.show(context, rule: rule),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      // Toggle Switch
                      CupertinoSwitch(
                        value: rule.enabled,
                        activeTrackColor: const Color(0xFF8B5CF6),
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
                              if (rule.availabilityType.toLowerCase() == 'preferred')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Preferred',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                )
                              else if (rule.availabilityType.toLowerCase() == 'manual_approval')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Manual Approval',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Settings & Buffers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Slot durations, padding buffers, and minimum notice',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Duration & Notice
          Row(
            children: [
              Expanded(
                child: _buildSettingDropdown(
                  context,
                  label: 'DEFAULT DURATION',
                  currentValue: settings.defaultDurationMinutes,
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes')),
                    DropdownMenuItem(value: 90, child: Text('90 minutes')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(settings.copyWith(defaultDurationMinutes: val));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettingDropdown(
                  context,
                  label: 'MINIMUM NOTICE',
                  currentValue: settings.minimumNoticeMinutes,
                  items: const [
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                    DropdownMenuItem(value: 120, child: Text('2 hours')),
                    DropdownMenuItem(value: 240, child: Text('4 hours')),
                    DropdownMenuItem(value: 1440, child: Text('24 hours')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(settings.copyWith(minimumNoticeMinutes: val));
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
                child: _buildSettingDropdown(
                  context,
                  label: 'BUFFER BEFORE',
                  currentValue: settings.bufferBeforeMinutes,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('None')),
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(settings.copyWith(bufferBeforeMinutes: val));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSettingDropdown(
                  context,
                  label: 'BUFFER AFTER',
                  currentValue: settings.bufferAfterMinutes,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('None')),
                    DropdownMenuItem(value: 5, child: Text('5 minutes')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      cubit.updateSettingsLocally(settings.copyWith(bufferAfterMinutes: val));
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
                const Icon(CupertinoIcons.globe, size: 16, color: Color(0xFF8B5CF6)),
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

  Widget _buildSettingDropdown<T>(
    BuildContext context, {
    required String label,
    required T currentValue,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            border: Border.all(
              color: context.colors.mediumGreyColor.withValues(alpha: 0.4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: currentValue,
              items: items,
              onChanged: onChanged,
              icon: Icon(CupertinoIcons.chevron_down, size: 14, color: context.colors.darkGreyColor),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.blackColor,
              ),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
          ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exceptions & Time Off',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.colors.blackColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Holidays and specific dates with custom availability',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => AddExceptionDialog.show(context),
                  icon: const Icon(CupertinoIcons.plus, size: 14, color: Colors.white),
                  label: const Text(
                    'Add Exception',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
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
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final ex = exceptions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Row(
                    children: [
                      // Date label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
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

                      // Availability Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ex.isAvailable
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ex.isAvailable ? 'Custom Hours' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ex.isAvailable ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
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

                      // Delete
                      IconButton(
                        icon: const Icon(CupertinoIcons.trash, size: 16),
                        color: context.colors.errorColor,
                        onPressed: () => cubit.deleteException(ex.id),
                        tooltip: 'Remove Exception',
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
