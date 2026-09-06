import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:callx_ai/core/widgets/app_date_time_picker.dart';

class CustomerDetailUserInfoBox extends StatefulWidget {
  final TextEditingController companyNameCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController jobTitleCtrl;
  final TextEditingController websiteCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController countryCtrl;
  final TextEditingController reasonCtrl;
  final TextEditingController nextFollowUpDateCtrl;
  final ValueNotifier<String> companyTypeNotifier;
  final ValueNotifier<String> leadStatusNotifier;
  final ValueNotifier<String> leadPriorityNotifier;
  final ValueNotifier<String> leadQualityNotifier;
  final ValueNotifier<String> lastContactResultNotifier;
  final Customer user;

  const CustomerDetailUserInfoBox({
    super.key,
    required this.companyNameCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.jobTitleCtrl,
    required this.websiteCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.stateCtrl,
    required this.countryCtrl,
    required this.reasonCtrl,
    required this.nextFollowUpDateCtrl,
    required this.companyTypeNotifier,
    required this.leadStatusNotifier,
    required this.leadPriorityNotifier,
    required this.leadQualityNotifier,
    required this.lastContactResultNotifier,
    required this.user,
  });

  @override
  State<CustomerDetailUserInfoBox> createState() =>
      _CustomerDetailUserInfoBoxState();
}

class _CustomerDetailUserInfoBoxState extends State<CustomerDetailUserInfoBox> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Customer Information
          _buildCustomerInformationCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCustomerInformationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Customer Information'.toUpperCase(),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Row 1: Company Name | Job Title / Position | Company Type
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Company Name',
                  controller: widget.companyNameCtrl,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Job Title / Position',
                  controller: widget.jobTitleCtrl,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildDropdownField(
                  label: 'Company Type',
                  notifier: widget.companyTypeNotifier,
                  items: const [
                    'GC',
                    'Subcontractor',
                    'Supplier',
                    'Developer',
                    'Architect',
                    'Engineer',
                    'Consultant',
                    'Other'
                  ],
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: First Name | Last Name | Main Email
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'First Name',
                  controller: widget.firstNameCtrl,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Last Name',
                  controller: widget.lastNameCtrl,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Main Email',
                  controller: widget.emailCtrl,
                  prefixIcon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Phone Number | Website
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Phone Number',
                  controller: widget.phoneCtrl,
                  prefixIcon: CupertinoIcons.phone,
                  keyboardType: TextInputType.phone,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Website',
                  controller: widget.websiteCtrl,
                  prefixIcon: CupertinoIcons.globe,
                  keyboardType: TextInputType.url,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Divider(),
          const SizedBox(height: 15),

          _buildLeadStatusCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildLeadStatusCard(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Lead & Status'.toUpperCase(),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Row 1: Lead Status | Lead Quality | Last Contact Result (Clean Dropdowns, No Dots)
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Lead Status',
                notifier: widget.leadStatusNotifier,
                items: const [
                  'New',
                  'Contacted',
                  'Qualified',
                  'Proposal Sent',
                  'Won',
                  'Lost'
                ],
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDropdownField(
                label: 'Lead Quality',
                notifier: widget.leadQualityNotifier,
                items: const ['Excellent', 'Good', 'Fair', 'Poor'],
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDropdownField(
                label: 'Last Contact Result',
                notifier: widget.lastContactResultNotifier,
                items: const [
                  'Interested',
                  'Needs follow-up',
                  'Appointment booked',
                  'Not Interested',
                  'No Answer',
                ],
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row 2: Lead Priority (3 Button Chips) | Next Follow-up Date (Interactive Picker)
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Lead Priority Chips (Hot / Warm / Cold)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lead Priority',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: context.colors.darkGreyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<String>(
                    valueListenable: widget.leadPriorityNotifier,
                    builder: (context, priority, _) {
                      return Row(
                        children: [
                          _buildPriorityChip('Hot', 'Hot',
                              const Color(0xFFEF4444), priority, isDark),
                          const SizedBox(width: 8),
                          _buildPriorityChip('Warm', 'Warm',
                              const Color(0xFFF59E0B), priority, isDark),
                          const SizedBox(width: 8),
                          _buildPriorityChip('Cold', 'Cold',
                              const Color(0xFF3B82F6), priority, isDark),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Next Follow-up Date
            Expanded(
              flex: 1,
              child: _buildDatePickerField(
                label: 'Next Follow-up',
                controller: widget.nextFollowUpDateCtrl,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(
    String key,
    String label,
    Color color,
    String activeKey,
    bool isDark,
  ) {
    final isSelected = key.toLowerCase() == activeKey.toLowerCase();
    return Expanded(
      child: InkWell(
        onTap: () {
          widget.leadPriorityNotifier.value = key;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.22 : 0.12)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? color
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String hintText = '—',
    IconData? prefixIcon,
    TextInputType? keyboardType,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Icon(
                    prefixIcon,
                    size: 15,
                    color: context.colors.darkGreyColor,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 12),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          context.colors.darkGreyColor.withValues(alpha: 0.7),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required ValueNotifier<String> notifier,
    required List<String> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<String>(
          valueListenable: notifier,
          builder: (context, currentVal, _) {
            final effectiveValue = items.contains(currentVal)
                ? currentVal
                : (items.isNotEmpty ? items.first : '');

            return Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveValue.isNotEmpty ? effectiveValue : null,
                  isExpanded: true,
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: context.colors.darkGreyColor,
                  ),
                  dropdownColor:
                      isDark ? AppColors.darkSlateColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    if (newVal != null) notifier.value = newVal;
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: context.colors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await AppDateTimePicker.pickDateTime(
              context,
              initial: AppDateTime.tryParse(controller.text),
              first: DateTime(2020),
              last: DateTime(2035),
            );
            if (picked != null) {
              controller.text = AppDateTime.displayDateTime(picked);
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: context.colors.primaryLightColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'Select Date & Time...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: controller.text.isNotEmpty
                          ? Theme.of(context).colorScheme.onSurface
                          : context.colors.primaryLightColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
