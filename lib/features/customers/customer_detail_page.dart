import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:callx_ai/core/constants/app_strings.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/features/customers/widgets/customer_detail_user_info_box.dart';
import 'package:callx_ai/features/customers/widgets/customer_detail_user_summary.dart';
import 'package:callx_ai/features/customers/widgets/customer_detail_notes_widget.dart';
import 'package:callx_ai/features/customers/widgets/customer_call_logs_tab.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/app_pull_to_refresh.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customerId});
  final String customerId;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  int _selectedBottomTabIndex = 0;
  late final TextEditingController _companyNameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _jobTitleCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _reasonCtrl;
  late final TextEditingController _nextFollowUpDateCtrl;
  late final ValueNotifier<String> _companyTypeNotifier;
  late final ValueNotifier<String> _leadStatusNotifier;
  late final ValueNotifier<String> _leadPriorityNotifier;
  late final ValueNotifier<String> _leadQualityNotifier;
  late final ValueNotifier<String> _lastContactResultNotifier;
  late final ValueNotifier<bool> _isActiveNotifier;

  @override
  void initState() {
    super.initState();
    final user = context.read<CustomersCubit>().state.users.firstWhere(
          (u) => u.id.toString() == widget.customerId,
          orElse: () => User(
            id: -1,
            fullName: '',
            email: '',
            phone: '',
            createdAt: '',
            lastContact: '',
            status: '',
          ),
        );

    final names = user.fullName.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    _companyNameCtrl = TextEditingController(text: user.companyName);
    _firstNameCtrl = TextEditingController(text: firstName);
    _lastNameCtrl = TextEditingController(text: lastName);
    _emailCtrl = TextEditingController(text: user.email);
    _phoneCtrl = TextEditingController(text: user.phone);
    _jobTitleCtrl = TextEditingController(text: user.jobTitle);
    _websiteCtrl = TextEditingController(text: user.website);
    _addressCtrl = TextEditingController(text: user.address);
    _cityCtrl = TextEditingController(text: user.city);
    _stateCtrl = TextEditingController(text: user.state);
    _countryCtrl = TextEditingController(text: user.country);
    _reasonCtrl = TextEditingController(text: user.reasonForContact);
    _nextFollowUpDateCtrl =
        TextEditingController(text: user.nextFollowUpDate?.toString() ?? '');

    _companyTypeNotifier = ValueNotifier<String>(
        user.companyType.isNotEmpty ? user.companyType : 'GC');
    _leadStatusNotifier = ValueNotifier<String>(
        user.leadStatus.isNotEmpty ? user.leadStatus : 'New');
    _leadPriorityNotifier = ValueNotifier<String>(
        user.leadPriority.isNotEmpty ? user.leadPriority : 'Warm');
    _leadQualityNotifier = ValueNotifier<String>(
        user.leadQuality.isNotEmpty ? user.leadQuality : 'Good');
    _lastContactResultNotifier = ValueNotifier<String>(
        user.lastContactResult.isNotEmpty
            ? user.lastContactResult
            : 'Interested');
    _isActiveNotifier = ValueNotifier<bool>(user.status == 'Active');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loaded = await context
          .read<CustomersCubit>()
          .loadCustomerDetail(widget.customerId);
      if (mounted && loaded != null) _syncControllers(loaded);
    });
  }

  void _syncControllers(User user) {
    final names = user.fullName.split(' ');
    _firstNameCtrl.text = names.isNotEmpty ? names.first : '';
    _lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
    _companyNameCtrl.text = user.companyName;
    _emailCtrl.text = user.email;
    _phoneCtrl.text = user.phone;
    _jobTitleCtrl.text = user.jobTitle;
    _websiteCtrl.text = user.website;
    _addressCtrl.text = user.address;
    _cityCtrl.text = user.city;
    _stateCtrl.text = user.state;
    _countryCtrl.text = user.country;
    _reasonCtrl.text = user.reasonForContact;
    _nextFollowUpDateCtrl.text = user.nextFollowUpDate?.toString() ?? '';
    _companyTypeNotifier.value =
        user.companyType.isEmpty ? 'GC' : user.companyType;
    _leadStatusNotifier.value =
        user.leadStatus.isEmpty ? 'New' : user.leadStatus;
    _leadPriorityNotifier.value =
        user.leadPriority.isEmpty ? 'Warm' : user.leadPriority;
    _leadQualityNotifier.value =
        user.leadQuality.isEmpty ? 'Good' : user.leadQuality;
    _lastContactResultNotifier.value =
        user.lastContactResult.isEmpty ? 'Interested' : user.lastContactResult;
    _isActiveNotifier.value = user.status == 'Active';
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _jobTitleCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _reasonCtrl.dispose();
    _nextFollowUpDateCtrl.dispose();
    _companyTypeNotifier.dispose();
    _leadStatusNotifier.dispose();
    _leadPriorityNotifier.dispose();
    _leadQualityNotifier.dispose();
    _lastContactResultNotifier.dispose();
    _isActiveNotifier.dispose();
    super.dispose();
  }

  void _save(User currentUser) {
    final fullName =
        "${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}".trim();

    final updatedUser = currentUser.copyWith(
      fullName: fullName.isNotEmpty ? fullName : currentUser.fullName,
      companyName: _companyNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      companyType: _companyTypeNotifier.value,
      leadStatus: _leadStatusNotifier.value,
      leadPriority: _leadPriorityNotifier.value,
      leadQuality: _leadQualityNotifier.value,
      lastContactResult: _lastContactResultNotifier.value,
      nextFollowUpDate: _nextFollowUpDateCtrl.text.trim(),
      reasonForContact: _reasonCtrl.text.trim(),
      status: _isActiveNotifier.value ? 'Active' : 'Deactive',
    );

    context.read<CustomersCubit>().updateCustomer(updatedUser);
    AppUtils.showSnackBar(
      context: context,
      extraMessage: AppStrings.current.customerDetailsSaved,
      toastificationType: ToastificationType.success,
    );
  }

  Future<void> _refreshCustomer() async {
    final loaded = await context
        .read<CustomersCubit>()
        .loadCustomerDetail(widget.customerId);
    if (mounted && loaded != null) _syncControllers(loaded);
  }

  @override
  Widget build(BuildContext context) {
    final text = AppStrings.current;

    final user = context.watch<CustomersCubit>().state.users.firstWhere(
          (u) => u.id.toString() == widget.customerId,
          orElse: () => User(
            id: -1,
            fullName: '',
            email: '',
            phone: '',
            createdAt: '',
            lastContact: '',
            status: '',
          ),
        );

    if (user.id.toString() == '-1') {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.errorColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.person_crop_circle_badge_xmark,
                    color: context.colors.errorColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  text.customerNotFound,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  text.customerNotFoundDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutesPath.customers);
                      }
                    },
                    icon: const Icon(CupertinoIcons.back,
                        color: Colors.white, size: 18),
                    label: Text(
                      text.backToCustomers,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primaryLightColor,
                      elevation: 0,
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
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Header + User Info Box + Notes Manager
        Expanded(
          flex: 3,
          child: Column(
            children: [
              //! HEADER
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.whiteColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(
                        CupertinoIcons.back,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SpacedText(
                      text: "CUSTOMER PROFILE",
                      color: context.colors.blackColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 38,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.errorColor,
                        ),
                        onPressed: () {
                          ConfirmationDialog.show(
                            context,
                            title: text.deleteCustomerConfirmTitle,
                            message: text.deleteCustomerConfirmMessage,
                            confirmLabel: text.delete,
                            onConfirm: () {
                              context
                                  .read<CustomersCubit>()
                                  .deleteCustomer(widget.customerId);
                              Future.microtask(() {
                                if (context.mounted) {
                                  context.pop();
                                  AppUtils.showSnackBar(
                                    context: context,
                                    extraMessage: text.deleteCustomerSuccess,
                                    toastificationType:
                                        ToastificationType.success,
                                  );
                                }
                              });
                            },
                          );
                        },
                        icon: const Icon(CupertinoIcons.trash, size: 16),
                        label: Text(text.delete.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primaryLightColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => _save(user),
                        icon: const Icon(CupertinoIcons.checkmark_alt,
                            size: 16, color: Colors.white),
                        label: Text(
                          text.save.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              //! 20 FIELDS INFO BOX
              Expanded(
                flex: 6,
                child: CustomerDetailUserInfoBox(
                  companyNameCtrl: _companyNameCtrl,
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  emailCtrl: _emailCtrl,
                  phoneCtrl: _phoneCtrl,
                  jobTitleCtrl: _jobTitleCtrl,
                  websiteCtrl: _websiteCtrl,
                  addressCtrl: _addressCtrl,
                  cityCtrl: _cityCtrl,
                  stateCtrl: _stateCtrl,
                  countryCtrl: _countryCtrl,
                  reasonCtrl: _reasonCtrl,
                  nextFollowUpDateCtrl: _nextFollowUpDateCtrl,
                  companyTypeNotifier: _companyTypeNotifier,
                  leadStatusNotifier: _leadStatusNotifier,
                  leadPriorityNotifier: _leadPriorityNotifier,
                  leadQualityNotifier: _leadQualityNotifier,
                  lastContactResultNotifier: _lastContactResultNotifier,
                  user: user,
                ),
              ),
              const SizedBox(height: 16),

              //! TABS HEADER (CALL LOGS / NOTES / DOCUMENTS)
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.whiteColor,
                  borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
                ),
                child: Row(
                  children: [
                    _buildBottomTabButton(
                      index: 0,
                      label: 'CALL LOGS',
                      icon: CupertinoIcons.phone_arrow_down_left,
                      count: user.callLogs.isNotEmpty
                          ? user.callLogs.length
                          : (user.lastContact != 'Never' &&
                                  user.lastContact.isNotEmpty
                              ? 2
                              : 0),
                    ),
                    const SizedBox(width: 8),
                    _buildBottomTabButton(
                      index: 1,
                      label: 'NOTES',
                      icon: CupertinoIcons.square_list,
                      count: user.notesList.length,
                    ),
                    const SizedBox(width: 8),
                    _buildBottomTabButton(
                      index: 2,
                      label: 'DOCUMENTS',
                      icon: CupertinoIcons.doc_text,
                      count: user.documents.length,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              //! DYNAMIC BOTTOM CONTENT (CALL LOGS / NOTES / DOCUMENTS)
              Expanded(
                flex: 5,
                child: _selectedBottomTabIndex == 0
                    ? CustomerCallLogsTab(user: user)
                    : (_selectedBottomTabIndex == 1
                        ? CustomerDetailNotesWidget(user: user)
                        : _buildDocumentsTab(user)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        //! RIGHT SUMMARY & TAGS CARD
        Expanded(
          flex: 1,
          child: CustomerDetailUserSummary(
            user: user,
            isActiveNotifier: _isActiveNotifier,
          ),
        ),
      ],
    ).withPullToRefresh(onRefresh: _refreshCustomer);
  }

  Widget _buildBottomTabButton({
    required int index,
    required String label,
    required IconData icon,
    required int count,
  }) {
    final isSelected = _selectedBottomTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedBottomTabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryLightColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.colors.primaryLightColor.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? context.colors.primaryLightColor
                  : context.colors.darkGreyColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? context.colors.primaryLightColor
                    : context.colors.darkGreyColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primaryLightColor
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white10
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : context.colors.darkGreyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab(User user) {
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
          Row(
            children: [
              Icon(CupertinoIcons.doc_text,
                  size: 18, color: context.colors.primaryLightColor),
              const SizedBox(width: 8),
              Text(
                'ATTACHED DOCUMENTS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: user.documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_on_clipboard,
                          size: 40,
                          color:
                              context.colors.darkGreyColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No documents attached to this customer yet.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: user.documents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = user.documents[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.doc_fill,
                                size: 20,
                                color: context.colors.primaryLightColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.name,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${doc.size} • ${doc.uploadDate}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.darkGreyColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
