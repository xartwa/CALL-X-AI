import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/features/customers/models/customer_model.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  int _activeTopTab = 0; // 0: Overview, 1: Call Logs

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Tab Bar (Overview / Call Logs 8)
          _buildTopTabs(context, isDark),
          const SizedBox(height: 16),

          // Card 1: Customer Information
          _buildCustomerInformationCard(context, isDark),
          const SizedBox(height: 16),

          // Card 2: Lead & Status
          _buildLeadStatusCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTopTabs(BuildContext context, bool isDark) {
    final callCount = widget.user.callLogs.isNotEmpty
        ? widget.user.callLogs.length
        : (widget.user.lastContact != null ? 8 : 0);

    return Row(
      children: [
        // Overview Tab
        InkWell(
          onTap: () => setState(() => _activeTopTab = 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        _activeTopTab == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: _activeTopTab == 0
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? const Color(0xFF94A3B8) : Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2.5,
                width: 74,
                decoration: BoxDecoration(
                  color: _activeTopTab == 0
                      ? context.colors.primaryLightColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Call Logs Tab
        InkWell(
          onTap: () => setState(() => _activeTopTab = 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Call Logs',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _activeTopTab == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _activeTopTab == 1
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$callCount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2.5,
                width: 90,
                decoration: BoxDecoration(
                  color: _activeTopTab == 1
                      ? context.colors.primaryLightColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInformationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 18),

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
          const SizedBox(height: 16),

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
          const SizedBox(height: 16),

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
        ],
      ),
    );
  }

  Widget _buildLeadStatusCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Lead & Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 18),

          // Row 1: Lead Status | Lead Priority | Lead Quality
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
                  dotColorGetter: _getLeadStatusColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildDropdownField(
                  label: 'Lead Priority',
                  notifier: widget.leadPriorityNotifier,
                  items: const ['Hot', 'Warm', 'Cold'],
                  dotColorGetter: _getLeadPriorityColor,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildDropdownField(
                  label: 'Lead Quality',
                  notifier: widget.leadQualityNotifier,
                  items: const ['Excellent', 'Good', 'Fair', 'Poor'],
                  dotColorGetter: _getLeadQualityColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Last Contact Result | Next Follow-up Date | Reason for Contact / Inquiry
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Last Contact Result',
                  notifier: widget.lastContactResultNotifier,
                  items: const [
                    'Interested',
                    'Callback Requested',
                    'Meeting Scheduled',
                    'Not Interested',
                    'No Answer',
                    'Left Voicemail',
                    'Closed/Won',
                  ],
                  dotColorGetter: (val) => const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildDatePickerField(
                  label: 'Next Follow-up Date',
                  controller: widget.nextFollowUpDateCtrl,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField(
                  label: 'Reason for Contact / Inquiry',
                  controller: widget.reasonCtrl,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
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
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF24344D) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 6),
                  child: Icon(
                    prefixIcon,
                    size: 15,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
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
    Color Function(String)? dotColorGetter,
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
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                    isDark ? const Color(0xFF131C2E) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF24344D)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: effectiveValue.isNotEmpty ? effectiveValue : null,
                  isExpanded: true,
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  dropdownColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  items: items.map((item) {
                    final dotColor = dotColorGetter?.call(item);
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Row(
                        children: [
                          if (dotColor != null) ...[
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
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
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
              setState(() {});
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF131C2E)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF24344D)
                    : const Color(0xFFE2E8F0),
              ),
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
                        : 'Select Date...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: controller.text.isNotEmpty
                          ? (isDark ? Colors.white : Colors.black87)
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

  Color _getLeadStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF10B981);
      case 'contacted':
        return const Color(0xFF3B82F6);
      case 'qualified':
        return const Color(0xFF14B8A6);
      case 'won':
        return const Color(0xFF059669);
      case 'lost':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _getLeadPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'hot':
        return const Color(0xFFEF4444);
      case 'warm':
        return const Color(0xFFF59E0B);
      case 'cold':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _getLeadQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF10B981);
      case 'good':
        return const Color(0xFF14B8A6);
      case 'fair':
        return const Color(0xFFEAB308);
      case 'poor':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF10B981);
    }
  }
}
