import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/app_date_time_picker.dart';
import '../../../../theme/app_colors.dart';
import '../../cubit/appointments_cubit.dart';
import '../../domain/entities/appointment_entity.dart';

class TimeWindowsDialog extends StatefulWidget {
  final AvailabilityRuleEntity rule;

  const TimeWindowsDialog({super.key, required this.rule});

  static Future<bool?> show(
    BuildContext context, {
    required AvailabilityRuleEntity rule,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<AppointmentsCubit>(),
        child: TimeWindowsDialog(rule: rule),
      ),
    );
  }

  @override
  State<TimeWindowsDialog> createState() => _TimeWindowsDialogState();
}

class _TimeWindowsDialogState extends State<TimeWindowsDialog> {
  late bool _enabled;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _availabilityType;

  @override
  void initState() {
    super.initState();
    _enabled = widget.rule.enabled;
    _startTime =
        _parseTime(widget.rule.startTime, const TimeOfDay(hour: 9, minute: 0));
    _endTime =
        _parseTime(widget.rule.endTime, const TimeOfDay(hour: 18, minute: 0));
    _availabilityType = widget.rule.availabilityType.toLowerCase();
    if (!['available', 'preferred', 'manual_approval']
        .contains(_availabilityType)) {
      _availabilityType = 'available';
    }
  }

  TimeOfDay _parseTime(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return fallback;
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await AppDateTimePicker.pickTime(
      context,
      initial: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _onSave() {
    final cubit = context.read<AppointmentsCubit>();
    if (_enabled) {
      cubit.updateRuleTimeWindow(
        widget.rule.weekday,
        _formatTimeOfDay(_startTime),
        _formatTimeOfDay(_endTime),
        _availabilityType,
      );
    } else {
      cubit.toggleRuleEnabled(widget.rule.weekday, false);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF151B26) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        side: BorderSide(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.4),
        ),
      ),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
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
                  Text(
                    '${widget.rule.weekdayName} Hours'.toUpperCase(),
                    style: TextStyle(
                      color: context.colors.blackColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.xmark,
                      size: 18,
                      color: context.colors.darkGreyColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.buttonRadius),
                  border: Border.all(
                    color:
                        context.colors.mediumGreyColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable ${widget.rule.weekdayName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.blackColor,
                          ),
                        ),
                        Text(
                          _enabled
                              ? 'Available for appointments'
                              : 'Marked as closed / unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: _enabled,
                      activeTrackColor: context.colors.successColor,
                      onChanged: (v) => setState(() => _enabled = v),
                    ),
                  ],
                ),
              ),

              if (_enabled) ...[
                const SizedBox(height: 20),

                // Working Hours Selection
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'START TIME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickTime(isStart: true),
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                                border: Border.all(
                                  color: context.colors.mediumGreyColor
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startTime.format(context),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.blackColor,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.clock,
                                    size: 16,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'END TIME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: context.colors.darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickTime(isStart: false),
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.buttonRadius),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.buttonRadius),
                                border: Border.all(
                                  color: context.colors.mediumGreyColor
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endTime.format(context),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.blackColor,
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.clock,
                                    size: 16,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Availability Mode
                Text(
                  'BOOKING PREFERENCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: context.colors.darkGreyColor,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _buildPreferenceRadio(
                      value: 'available',
                      label: 'Standard Availability',
                      description: 'Regular open slot for automated booking',
                    ),
                    const SizedBox(height: 8),
                    _buildPreferenceRadio(
                      value: 'preferred',
                      label: 'Preferred Hours',
                      description: 'AI agent will suggest these windows first',
                    ),
                    const SizedBox(height: 8),
                    _buildPreferenceRadio(
                      value: 'manual_approval',
                      label: 'Manual Approval',
                      description:
                          'Creates a pending request requiring admin confirmation',
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: context.colors.mediumGreyColor
                                  .withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: context.colors.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply Window',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceRadio({
    required String value,
    required String label,
    required String description,
  }) {
    final isSelected = _availabilityType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _availabilityType = value),
      borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryLightColor.withValues(alpha: 0.12)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
          border: Border.all(
            color: isSelected
                ? context.colors.primaryLightColor
                : context.colors.mediumGreyColor.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              size: 18,
              color: isSelected
                  ? context.colors.primaryLightColor
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: context.colors.blackColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
