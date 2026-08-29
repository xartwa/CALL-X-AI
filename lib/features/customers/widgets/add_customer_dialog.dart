import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/app_text_field_widget.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_date_time_picker.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  static Future<User?> show(BuildContext context) {
    return showGeneralDialog<User>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Add Customer',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const AddCustomerDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curveValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.85 + (curveValue * 0.15),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Canada');
  final _reasonCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _nextFollowUpCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  String _companyType = 'GC';
  String _leadStatus = 'New';
  String _leadPriority = 'Hot';
  String _leadQuality = 'Excellent';
  String _lastContactResult = 'Interested';
  String _status = 'Active';
  DateTime? _nextFollowUp;
  final List<String> _tags = const [];

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _jobTitleCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _reasonCtrl.dispose();
    _noteCtrl.dispose();
    _nextFollowUpCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      List<CustomerNote> initialNotes = [];
      if (_noteCtrl.text.trim().isNotEmpty) {
        initialNotes.add(
          CustomerNote(
            id: 'n_${DateTime.now().millisecondsSinceEpoch}',
            content: _noteCtrl.text.trim(),
            date: now,
            author: 'Admin',
          ),
        );
      }

      final newUser = User(
        id: -1,
        fullName: _nameCtrl.text.trim(),
        companyName: _companyNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        jobTitle: _jobTitleCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        companyType: _companyType,
        leadStatus: _leadStatus,
        leadPriority: _leadPriority,
        leadQuality: _leadQuality,
        lastContactResult: _lastContactResult,
        nextFollowUpDate: _nextFollowUp,
        createdAt: now,
        lastContact: "Never",
        status: _status,
        reasonForContact: _reasonCtrl.text.trim(),
        tags: _tags,
        notesList: initialNotes,
        notes: _noteCtrl.text.trim(),
      );
      Navigator.pop(context, newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final settingsState = context.watch<WorkspaceSettingsCubit>().state;
    const leadStatuses = ['New', 'Contacted', 'Qualified', 'Won', 'Lost'];

    final leadQualities =
        settingsState.leadQualities.map((e) => e.label).toList();
    if (leadQualities.isEmpty) leadQualities.add('Excellent');

    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      elevation: 12,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: (screenHeight * 0.88).clamp(520.0, 800.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ADD NEW CUSTOMER',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        CupertinoIcons.clear_thick,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Company & Contact Name
                        _buildSectionHeader('1. COMPANY & CONTACT DETAILS'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                label: 'FULLNAME *',
                                controller: _nameCtrl,
                                hintText: 'e.g. John Smith',
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormField(
                                label: 'PHONE *',
                                controller: _phoneCtrl,
                                hintText: 'e.g. 0912 345 6789',
                                textInputType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                label: 'COMPANY NAME',
                                controller: _companyNameCtrl,
                                hintText: 'e.g. ABC Construction',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormField(
                                label: 'EMAIL',
                                controller: _emailCtrl,
                                hintText: 'e.g. john@example.com',
                                textInputType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                label: 'JOB TITLE',
                                controller: _jobTitleCtrl,
                                hintText: 'e.g. Estimator, Project Manager',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormField(
                                label: 'WEBSITE',
                                controller: _websiteCtrl,
                                hintText: 'e.g. https://company.com',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Address & Location
                        _buildSectionHeader('2. LOCATION'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildFormField(
                                label: 'STREET ADDRESS',
                                controller: _addressCtrl,
                                hintText: 'e.g. 123 Main St, Suite 400',
                                prefixIcon: CupertinoIcons.location_solid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormField(
                                label: 'CITY',
                                controller: _cityCtrl,
                                hintText: 'e.g. Vancouver',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFormField(
                                label: 'PROVINCE / STATE',
                                controller: _stateCtrl,
                                hintText: 'e.g. BC',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Lead Classification
                        _buildSectionHeader('3. LEAD & BUSINESS QUALIFICATION'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'COMPANY TYPE',
                                value: _companyType,
                                items: [
                                  'GC',
                                  'Developer',
                                  'Trade',
                                  'Startup',
                                  'Agency',
                                  'Enterprise',
                                  'General'
                                ],
                                onChanged: (val) =>
                                    setState(() => _companyType = val ?? 'GC'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'LEAD STATUS',
                                value: _leadStatus,
                                items: leadStatuses,
                                onChanged: (val) => setState(() =>
                                    _leadStatus = val ?? leadStatuses.first),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'LEAD QUALITY',
                                value: _leadQuality,
                                items: leadQualities,
                                onChanged: (val) => setState(() =>
                                    _leadQuality = val ?? leadQualities.first),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 1. Lead Priority
                        Text(
                          'LEAD PRIORITY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPriorityChoice(
                                'Hot', 'Hot', const Color(0xFFEF4444)),
                            const SizedBox(width: 12),
                            _buildPriorityChoice(
                                'Warm', 'Warm', const Color(0xFFF59E0B)),
                            const SizedBox(width: 12),
                            _buildPriorityChoice(
                                'Cold', 'Cold', const Color(0xFF3B82F6)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 2. Next Follow-Up
                        Text(
                          'NEXT FOLLOW-UP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.colors.primaryLightColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked =
                                await AppDateTimePicker.pickDateTime(
                              context,
                              initial: _nextFollowUp ??
                                  DateTime.now()
                                      .add(const Duration(days: 2)),
                              first: DateTime.now(),
                              last: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                _nextFollowUp = picked;
                                _nextFollowUpCtrl.text =
                                    AppDateTime.displayDateTime(picked);
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: context.colors.skyBlueColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: context.colors.primaryLightColor
                                      .withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.calendar,
                                    size: 16,
                                    color: context.colors.primaryLightColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _nextFollowUpCtrl.text.isEmpty
                                        ? 'Select Date & Time...'
                                        : _nextFollowUpCtrl.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.primaryLightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tags and Initial Note removed as per user request
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ThemeConstants.buttonRadius),
                      ),
                    ),
                    child: Text(text.add,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.primaryLightColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: context.colors.primaryLightColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? textInputType,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        AppTextFieldWidget(
          controller: controller,
          hintText: hintText,
          showBorder: true,
          borderColor: context.colors.lightGreyColor,
          fillColor: Colors.transparent,
          textInputType: textInputType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        AppDropdownWidget<String>(
          value: items.contains(value) ? value : items.first,
          items: items,
          onChanged: onChanged,
          itemBuilder: (item) => item,
          hint: 'Select $label',
        ),
      ],
    );
  }

  Widget _buildPriorityChoice(String key, String label, Color color) {
    final isSelected = _leadPriority == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _leadPriority = key),
        borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
            border: Border.all(
              color: isSelected ? color : context.colors.lightGreyColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : context.colors.darkGreyColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
