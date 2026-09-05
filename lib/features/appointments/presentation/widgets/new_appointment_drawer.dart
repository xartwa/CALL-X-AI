import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/constants/theme_constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_date_time_picker.dart';
import '../../../../core/widgets/app_dropdown_widget.dart';
import '../../../../core/widgets/app_text_field_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../customers/cubit/customers_cubit.dart';
import '../../cubit/appointments_cubit.dart';

class NewAppointmentDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const NewAppointmentDrawer({super.key, required this.onClose});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'New Appointment',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AppointmentsCubit>()),
          BlocProvider.value(value: context.read<CustomersCubit>()),
        ],
        child: Align(
          alignment: Alignment.centerRight,
          child: NewAppointmentDrawer(
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  State<NewAppointmentDrawer> createState() => _NewAppointmentDrawerState();
}

class _NewAppointmentDrawerState extends State<NewAppointmentDrawer> {
  final _formKey = GlobalKey<FormState>();

  User? _selectedCustomer;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  String _meetingType = 'online'; // 'online' or 'in_person'
  final int _durationMinutes = 45;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController(text: 'Discovery Consultation');
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default start time: tomorrow at 11:00 AM
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0);
    _selectedEnd = _selectedStart!.add(Duration(minutes: _durationMinutes));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final picked = await AppDateTimePicker.pickDateTime(
      context,
      initial: _selectedStart ?? DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedStart = picked;
        _selectedEnd = picked.add(Duration(minutes: _durationMinutes));
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedCustomer == null) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Please select a customer.',
        toastificationType: ToastificationType.warning,
      );
      return;
    }
    if (_selectedStart == null) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Please select a meeting date and time.',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final cubit = context.read<AppointmentsCubit>();
    final ok = await cubit.createAppointment(
      customerId: int.tryParse(_selectedCustomer!.id) ?? 0,
      customerEmail: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : null,
      startAt: _selectedStart!,
      endAt: _selectedEnd,
      meetingType: _meetingType,
      title: _titleCtrl.text.trim().isNotEmpty
          ? _titleCtrl.text.trim()
          : 'Discovery Consultation',
      durationMinutes: _durationMinutes,
      location: _meetingType == 'in_person' ? _locationCtrl.text.trim() : '',
      notes: _notesCtrl.text.trim(),
    );

    if (ok && mounted) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final customersState = context.watch<CustomersCubit>().state;
    final customers = customersState.users;
    final availableSlots = context.watch<AppointmentsCubit>().state.availableSlots;
    final isBusy = context.watch<AppointmentsCubit>().state.isActionLoading;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 460,
        height: double.infinity,
        decoration: BoxDecoration(
          color: context.colors.whiteColor,
          border: Border(
            left: BorderSide(
              color: context.colors.mediumGreyColor
                  .withValues(alpha: isDark ? 0.35 : 1.0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.colors.mediumGreyColor
                          .withValues(alpha: isDark ? 0.35 : 1.0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NEW APPOINTMENT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.clear, size: 18, color: context.colors.darkGreyColor),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Select Customer
                      _buildLabel('CUSTOMER / LEAD *', isDark),
                      const SizedBox(height: 6),
                      AppDropdownWidget<User>(
                        value: _selectedCustomer,
                        items: customers,
                        hint: 'Select Lead or Customer',
                        itemBuilder: (u) => '${u.fullName} (${u.companyName.isNotEmpty ? u.companyName : u.email})',
                        onChanged: (u) {
                          setState(() {
                            _selectedCustomer = u;
                            if (u != null && u.email.isNotEmpty) {
                              _emailCtrl.text = u.email;
                            } else {
                              _emailCtrl.clear();
                            }
                          });
                        },
                        borderColor: context.colors.lightGreyColor,
                      ),
                      const SizedBox(height: 12),

                      // Customer Email
                      _buildLabel('CUSTOMER EMAIL', isDark),
                      const SizedBox(height: 6),
                      AppTextFieldWidget(
                        controller: _emailCtrl,
                        hintText: 'e.g. client@company.com',
                        textInputType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          CupertinoIcons.mail,
                          size: 16,
                          color: context.colors.darkGreyColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Format: Online vs In-Person
                      _buildLabel('MEETING FORMAT', isDark),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFormatButton(
                              'Online (Meet)',
                              CupertinoIcons.video_camera,
                              _meetingType == 'online',
                              primary,
                              isDark,
                              () => setState(() => _meetingType = 'online'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFormatButton(
                              'In-Person',
                              CupertinoIcons.building_2_fill,
                              _meetingType == 'in_person',
                              primary,
                              isDark,
                              () => setState(() => _meetingType = 'in_person'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. Recommended 1-Click Slots
                      if (availableSlots.isNotEmpty) ...[
                        _buildLabel('RECOMMENDED AVAILABLE SLOTS (1-CLICK)', isDark),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: availableSlots.take(4).map((slot) {
                            final isSel = _selectedStart != null && _selectedStart == slot.startAt;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedStart = slot.startAt.toLocal();
                                  _selectedEnd = slot.endAt.toLocal();
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? primary.withValues(alpha: 0.2)
                                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? primary : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  ),
                                ),
                                child: Text(
                                  '${slot.weekdayName.substring(0, 3)} ${slot.dateStr.split(',')[0]} • ${slot.localStart}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                    color: isSel ? (isDark ? Colors.white : primary) : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Date & Time Picker trigger
                      _buildLabel('SCHEDULED DATE & TIME *', isDark),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.colors.lightGreyColor),
                          ),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.calendar, size: 16, color: primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedStart != null
                                      ? '${DateFormat('EEEE, MMM d • HH:mm').format(_selectedStart!)} ($_durationMinutes mins)'
                                      : 'Click to select date and time',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Icon(CupertinoIcons.chevron_right, size: 14, color: context.colors.darkGreyColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Consultation Topic / Title
                      _buildLabel('CONSULTATION TOPIC', isDark),
                      const SizedBox(height: 6),
                      AppTextFieldWidget(
                        controller: _titleCtrl,
                        hintText: 'e.g. Discovery Consultation',
                        showBorder: true,
                        borderColor: context.colors.lightGreyColor,
                        fillColor: Colors.transparent,
                      ),
                      const SizedBox(height: 16),

                      // 6. If in-person, location
                      if (_meetingType == 'in_person') ...[
                        _buildLabel('MEETING LOCATION / ADDRESS', isDark),
                        const SizedBox(height: 6),
                        AppTextFieldWidget(
                          controller: _locationCtrl,
                          hintText: 'e.g. Toronto Office, Suite 400',
                          showBorder: true,
                          borderColor: context.colors.lightGreyColor,
                          fillColor: Colors.transparent,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 7. Notes
                      _buildLabel('AGENDA / NOTES', isDark),
                      const SizedBox(height: 6),
                      AppTextFieldWidget(
                        controller: _notesCtrl,
                        hintText: 'Review project scope, architectural feasibility, etc.',
                        maxLines: 2,
                        showBorder: true,
                        borderColor: context.colors.lightGreyColor,
                        fillColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.colors.mediumGreyColor
                          .withValues(alpha: isDark ? 0.35 : 1.0),
                    ),
                  ),
                ),
                child: SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    child: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'CONFIRM & CREATE APPOINTMENT',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildFormatButton(
    String label,
    IconData icon,
    bool isSelected,
    Color primary,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? context.colors.mediumGreyColor.withValues(alpha: 0.35)
                    : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isSelected ? primary : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? (isDark ? Colors.white : primary) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
