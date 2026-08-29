import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/customers/widgets/customer_detail_custom_textfeild.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/cubit/workspace_settings_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

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
  final User user;

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

class _CustomerDetailUserInfoBoxState extends State<CustomerDetailUserInfoBox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SpacedText(
                text: "CUSTOMER PROFILE",
                color: context.colors.blackColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                fontSize: 12,
              ),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: context.colors.primaryLightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: context.colors.darkGreyColor,
                  labelStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 11),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'General & Contact'),
                    Tab(text: 'Lead & Business'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Divider(height: 1),
          const SizedBox(height: 20),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralContactTab(context, isDark),
                _buildLeadBusinessTab(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralContactTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        spacing: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Company Name & Job Title
          Row(
            children: [
              CustomerDetailCustomTextfeild(
                controller: widget.companyNameCtrl,
                labelText: 'COMPANY NAME',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.jobTitleCtrl,
                labelText: 'JOB TITLE / POSITION',
              ),
            ],
          ),

          // Row 2: Contact First Name & Last Name
          Row(
            children: [
              CustomerDetailCustomTextfeild(
                controller: widget.firstNameCtrl,
                labelText: 'FIRST NAME',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.lastNameCtrl,
                labelText: 'LAST NAME',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.websiteCtrl,
                labelText: 'WEBSITE',
                textInputType: TextInputType.url,
              ),
            ],
          ),

          // Row 3: Email & Phone
          Row(
            children: [
              CustomerDetailCustomTextfeild(
                controller: widget.emailCtrl,
                labelText: 'MAIN EMAIL',
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.phoneCtrl,
                labelText: 'PHONE NUMBER',
                textInputType: TextInputType.phone,
              ),
            ],
          ),

          // Row 4: Address, City, State, Country
          Row(
            children: [
              CustomerDetailCustomTextfeild(
                flex: 2,
                controller: widget.addressCtrl,
                labelText: 'STREET ADDRESS',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.cityCtrl,
                labelText: 'CITY',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.stateCtrl,
                labelText: 'PROVINCE / STATE',
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                controller: widget.countryCtrl,
                labelText: 'COUNTRY',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadBusinessTab(BuildContext context, bool isDark) {
    final settingsState = context.watch<WorkspaceSettingsCubit>().state;
    const leadStatuses = ['New', 'Contacted', 'Qualified', 'Won', 'Lost'];

    final leadQualities =
        settingsState.leadQualities.map((e) => e.label).toList();
    if (leadQualities.isEmpty) leadQualities.add('Excellent');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Company Type & Lead Status
          Row(
            children: [
              // Company Type Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPANY TYPE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.companyTypeNotifier,
                      builder: (context, value, _) {
                        return _buildDropdown(
                          context,
                          value: value,
                          items: [
                            'GC',
                            'Developer',
                            'Trade',
                            'Startup',
                            'Agency',
                            'Consulting',
                            'Enterprise',
                            'General'
                          ],
                          onChanged: (val) {
                            if (val != null)
                              widget.companyTypeNotifier.value = val;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Lead Status Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEAD STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.leadStatusNotifier,
                      builder: (context, value, _) {
                        return _buildDropdown(
                          context,
                          value: value,
                          items: leadStatuses,
                          onChanged: (val) {
                            if (val != null)
                              widget.leadStatusNotifier.value = val;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Lead Quality Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEAD QUALITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.leadQualityNotifier,
                      builder: (context, value, _) {
                        return _buildDropdown(
                          context,
                          value: value,
                          items: ['Excellent', 'Good', 'Average', 'Poor'],
                          onChanged: (val) {
                            if (val != null)
                              widget.leadQualityNotifier.value = val;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Row 2: Lead Priority Selector (Hot / Warm / Cold) & Next Follow-Up Date
          Row(
            children: [
              // Priority
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEAD PRIORITY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.leadPriorityNotifier,
                      builder: (context, priority, _) {
                        return Row(
                          children: [
                            _buildPriorityChip('Hot', 'Hot',
                                const Color(0xFFEF4444), priority),
                            const SizedBox(width: 8),
                            _buildPriorityChip('Warm', 'Warm',
                                const Color(0xFFF59E0B), priority),
                            const SizedBox(width: 8),
                            _buildPriorityChip('Cold', 'Cold',
                                const Color(0xFF3B82F6), priority),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Next Follow Up Date (Interactive)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT FOLLOW-UP DATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await AppUtils.showCustomDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 3)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          final f = DateFormat('yyyy/MM/dd');
                          widget.nextFollowUpDateCtrl.text = f.format(picked);
                        }
                      },
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.colors.skyBlueColor,
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                          border: Border.all(
                            color: context.colors.primaryLightColor
                                .withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.calendar_badge_plus,
                                size: 18,
                                color: context.colors.primaryLightColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.nextFollowUpDateCtrl.text.isEmpty
                                    ? 'Select Date...'
                                    : widget.nextFollowUpDateCtrl.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primaryLightColor,
                                ),
                              ),
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
          const SizedBox(height: 18),

          // Row 3: Last Contact Result & Reason For Contact
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST CONTACT RESULT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: widget.lastContactResultNotifier,
                      builder: (context, value, _) {
                        return _buildDropdown(
                          context,
                          value: value,
                          items: [
                            'No answer',
                            'Interested',
                            'Call back',
                            'Meeting booked',
                            'Not interested'
                          ],
                          onChanged: (val) {
                            if (val != null)
                              widget.lastContactResultNotifier.value = val;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CustomerDetailCustomTextfeild(
                flex: 2,
                controller: widget.reasonCtrl,
                labelText: 'REASON FOR CONTACT / INQUIRY',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return AppDropdownWidget<String>(
      value: items.contains(value) ? value : items.first,
      items: items,
      onChanged: onChanged,
      itemBuilder: (item) => item,
      hint: 'Select',
    );
  }

  Widget _buildPriorityChip(
      String key, String label, Color color, String activeKey) {
    final isSelected = key.toLowerCase() == activeKey.toLowerCase();
    return Expanded(
      child: InkWell(
        onTap: () {
          widget.leadPriorityNotifier.value = key;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
