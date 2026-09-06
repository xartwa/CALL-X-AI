import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/app_action_button.dart';
import '../../../../core/widgets/app_dropdown_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
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
              final googleCalendarCard =
                  _buildGoogleCalendarCard(context, state, cubit, isDark);
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
                    // Right: Google Calendar, Settings & Exceptions (takes ~45% width)
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          googleCalendarCard,
                          const SizedBox(height: 16),
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
                    googleCalendarCard,
                    const SizedBox(height: 16),
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
          color: context.colors.mediumGreyColor
              .withValues(alpha: isDark ? 0.35 : 1.0),
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
          color: context.colors.mediumGreyColor
              .withValues(alpha: isDark ? 0.35 : 1.0),
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
                'Booking Settings & Buffers'.toUpperCase(),
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : context.colors.mediumGreyColor.withValues(alpha: 0.4),
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
          color: context.colors.mediumGreyColor
              .withValues(alpha: isDark ? 0.35 : 1.0),
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
                    label:  Text(
                      'Add Exception'.toUpperCase(),
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                              ? Colors.white.withValues(alpha: 0.03)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : context.colors.mediumGreyColor.withValues(alpha: 0.4),
                          ),
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
                        onTap: () {
                          ConfirmationDialog.show(
                            context,
                            title: 'Delete Exception',
                            message:
                                'Are you sure you want to delete the date override for ${DateFormat('MMM d, yyyy').format(ex.date)}?',
                            confirmLabel: 'DELETE',
                            onConfirm: () => cubit.deleteException(ex.id),
                          );
                        },
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

  // --- Google Calendar Sync Card ---
  Widget _buildGoogleCalendarCard(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    final conn = state.calendarConnection;
    final isConnected = conn.connected;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: context.colors.mediumGreyColor
              .withValues(alpha: isDark ? 0.35 : 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Google Calendar Sync'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.colors.blackColor,
                      ),
                    ),
                  ],
                ),
                CustomTagWidget(
                  label: isConnected ? 'Connected' : 'Not Connected',
                  color: isConnected
                      ? context.colors.successColor
                      : context.colors.darkGreyColor,
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isConnected) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(
                          ThemeConstants.buttonRadius),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : context.colors.mediumGreyColor
                                .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.mail,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            conn.accountEmail.isNotEmpty
                                ? conn.accountEmail
                                : 'Google Calendar Account',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.colors.blackColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conn.lastSyncedAt != null)
                          Text(
                            'Synced: ${DateFormat('MMM d, HH:mm').format(conn.lastSyncedAt!)}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Appointments are synchronized automatically to Google Calendar with Google Meet video links, and external busy slots block conflicting appointments.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: state.isActionLoading
                              ? null
                              : () => cubit.syncCalendar(),
                          icon: const Icon(CupertinoIcons.arrow_2_circlepath,
                              size: 14, color: Colors.white),
                          label: Text(
                            'Sync Now'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: state.isActionLoading
                              ? null
                              : () => _confirmDisconnect(context, cubit),
                          icon: Icon(CupertinoIcons.clear,
                              size: 13, color: context.colors.errorColor),
                          label: Text(
                            'Disconnect'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.errorColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.colors.errorColor
                                  .withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Connect your Google Calendar to automatically synchronize consultations, generate Google Meet links, and block off busy calendar hours.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: state.isActionLoading
                              ? null
                              : () => _connectGoogleCalendar(context, cubit),
                          icon: const Icon(CupertinoIcons.link,
                              size: 14, color: Colors.white),
                          label: Text(
                            'Connect Google Calendar'.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _connectGoogleCalendar(
      BuildContext context, AppointmentsCubit cubit) async {
    final url = await cubit.getGoogleCalendarOAuthUrl();
    if (url != null && url.isNotEmpty) {
      cubit.startOAuthPolling();
      if (kIsWeb) {
        web.window.open(url, '_blank');
      }
      if (context.mounted) {
        _showOAuthPendingDialog(context, cubit);
      }
    }
  }

  void _showOAuthPendingDialog(
      BuildContext context, AppointmentsCubit cubit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) =>
          BlocListener<AppointmentsCubit, AppointmentsState>(
        listener: (context, state) {
          if (state.calendarConnection.connected) {
            Navigator.of(dialogCtx).pop();
          }
        },
        child: Dialog(
          backgroundColor: isDark ? const Color(0xFF151B26) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
            side: BorderSide(
              color: context.colors.mediumGreyColor.withValues(alpha: 0.4),
            ),
          ),
          elevation: 12,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'CONNECT GOOGLE CALENDAR',
                          style: TextStyle(
                            color: context.colors.blackColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.xmark,
                        size: 18,
                        color: context.colors.darkGreyColor,
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Browser status notice
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : context.colors.mediumGreyColor
                              .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.compass,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A secure Google authentication window has been opened in your browser.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: context.colors.blackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Next steps section
                Text(
                  'NEXT STEPS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colors.darkGreyColor,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStepCard(
                  context,
                  step: '1',
                  title: 'Sign In to Google',
                  description:
                      'Choose your Gmail or Google Workspace account in the opened window.',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  context,
                  step: '2',
                  title: 'Grant Calendar Access',
                  description:
                      'Allow Call-X AI to sync consultations and create Google Meet video links.',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildStepCard(
                  context,
                  step: '3',
                  title: 'Confirm Connection',
                  description:
                      'Once authorized in Google, click "Check Connection" below to complete.',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.colors.mediumGreyColor
                                  .withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: context.colors.blackColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await cubit.refreshCalendarStatus();
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop();
                            }
                          },
                          icon: const Icon(CupertinoIcons.arrow_2_circlepath,
                              size: 15, color: Colors.white),
                          label: const Text(
                            'CHECK CONNECTION',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStepCard(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : context.colors.mediumGreyColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.colors.blackColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
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

  void _confirmDisconnect(BuildContext context, AppointmentsCubit cubit) {
    ConfirmationDialog.show(
      context,
      title: 'Disconnect Google Calendar',
      message:
          'Are you sure you want to disconnect your Google Calendar? Scheduled appointments will no longer be synchronized.',
      confirmLabel: 'DISCONNECT',
      icon: CupertinoIcons.xmark_circle,
      iconColor: context.colors.errorColor,
      confirmButtonColor: context.colors.errorColor,
      onConfirm: () => cubit.disconnectCalendar(),
    );
  }
}
