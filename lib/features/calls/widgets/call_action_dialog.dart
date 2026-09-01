import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/core/widgets/preset_chip_widget.dart';
import 'package:callx_ai/core/widgets/app_dropdown_widget.dart';
import 'package:callx_ai/core/widgets/app_date_time_picker.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/features/calls/cubit/calls_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:callx_ai/core/widgets/app_feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';
import 'package:toastification/toastification.dart';

enum _CallType { single, group }

enum _TimingMode { callNow, schedule }

enum _GroupTargetMode { segment, manual }

class ConversationScenario {
  final String id;
  final String title;
  final String category;
  final String description;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
  });
}

class CallActionDialog extends StatefulWidget {
  final String? fullName;
  final String? phone;
  final String? customerId;
  final String initialTab;
  final bool startInGroupMode;

  const CallActionDialog({
    super.key,
    this.fullName,
    this.phone,
    this.customerId,
    this.initialTab = 'callNow',
    this.startInGroupMode = false,
  });

  static Future<void> show(
    BuildContext context, {
    String? fullName,
    String? phone,
    String? customerId,
    String initialTab = 'callNow',
    bool startInGroupMode = false,
  }) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CallActionDialog(
        fullName: fullName,
        phone: phone,
        customerId: customerId,
        initialTab: initialTab,
        startInGroupMode: startInGroupMode,
      ),
    );
  }

  @override
  State<CallActionDialog> createState() => _CallActionDialogState();
}

class _CallActionDialogState extends State<CallActionDialog> {
  late _CallType _callType;
  _TimingMode _timingMode = _TimingMode.callNow;
  _GroupTargetMode _groupTargetMode = _GroupTargetMode.segment;
  User? _selectedUser;
  bool _isDirectPhone = false;
  final TextEditingController _customPhoneCtrl = TextEditingController();
  final TextEditingController _customNameCtrl = TextEditingController();

  // Manual Customer Selection
  final Set<String> _manualSelectedUserIds = {};
  final TextEditingController _searchCustomerCtrl = TextEditingController();

  String _customerSearchQuery = '';

  // Conversation Scenarios
  List<ConversationScenario> _scenarios = const [];
  ConversationScenario? _selectedScenario;
  String? _scenarioError;

  // Group Call States
  String _selectedGroupSegment = 'All Hot Leads';
  final List<String> _groupSegments = const [
    'All Hot Leads',
    'All Active Customers',
    'Recent Inquiries (7 Days)',
  ];

  int _concurrencyLines = 3;
  final List<int> _concurrencyOptions = const [1, 3, 5, 10];

  // Scheduler States
  String? _selectedDatePreset;
  DateTime? _customDate;

  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
    _callType = widget.startInGroupMode ? _CallType.group : _CallType.single;
    _timingMode = widget.initialTab == 'schedule'
        ? _TimingMode.schedule
        : _TimingMode.callNow;
    if (_callType == _CallType.group) _timingMode = _TimingMode.callNow;
    if (widget.fullName != null && widget.phone != null) {
      _selectedUser = User(
        id: widget.customerId ?? '-1',
        fullName: widget.fullName!,
        phone: widget.phone!,
        email: '',
        createdAt: '',
        lastContact: '',
        status: '',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customersCubit = context.read<CustomersCubit>();
      if (customersCubit.state.users.isEmpty) {
        customersCubit.loadInitial();
      }
      try {
        final raw = await customersCubit.getScenarios();

        if (!mounted) return;
        if (raw.isEmpty) {
          setState(() => _scenarioError = 'No active call scenarios found.');
          return;
        }
        final scenarios = raw
            .map((item) => ConversationScenario(
                  id: '${item['id']}',
                  title: '${item['name'] ?? 'Scenario'}',
                  category: '${item['category'] ?? ''}',
                  description: '${item['pitchSummary'] ?? ''}',
                ))
            .toList();
        setState(() {
          _scenarios = scenarios;
          _selectedScenario = scenarios.first;
          _scenarioError = null;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _scenarioError = 'Failed to load scenarios.');
      }
    });
  }

  DateTime? _scheduledFor() {
    if (_timingMode != _TimingMode.schedule) return null;
    final now = DateTime.now();
    DateTime date;
    if (_selectedDatePreset == 'Tomorrow') {
      date = now.add(const Duration(days: 1));
    } else if (_selectedDatePreset == 'Next Monday') {
      final days = (DateTime.monday - now.weekday + 7) % 7;
      date = now.add(Duration(days: days == 0 ? 7 : days));
    } else if (_selectedDatePreset == 'Custom') {
      final custom = _customDate;
      if (custom != null) return custom; // Custom includes picked time.
      date = now;
    } else {
      date = now;
    }
    return DateTime(date.year, date.month, date.day, 14, 30);
  }

  @override
  void dispose() {
    _searchCustomerCtrl.dispose();
    _customPhoneCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }


  int _getGroupTargetCount(List<User> customers) {
    return _groupTargets(customers).length;
  }

  List<User> _groupTargets(List<User> customers) {
    if (_groupTargetMode == _GroupTargetMode.manual) {
      return customers
          .where((user) => _manualSelectedUserIds.contains(user.id))
          .toList(growable: false);
    }
    return switch (_selectedGroupSegment) {
      'All Hot Leads' => customers
          .where((u) => u.leadPriority.toLowerCase() == 'hot')
          .toList(growable: false),
      'All Active Customers' => customers
          .where((u) => u.status.toLowerCase() == 'active')
          .toList(growable: false),
      'Recent Inquiries (7 Days)' => customers.where((u) {
          final createdAt = u.createdAt;
          return createdAt != null &&
              DateTime.now().difference(createdAt).inDays <= 7;
        }).toList(growable: false),
      _ => const <User>[],
    };
  }

  void _triggerCall() async {
    final scenario = _selectedScenario;
    if (scenario == null) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: _scenarioError ?? 'Select an active call scenario.',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    final isScheduled = _timingMode == _TimingMode.schedule;
    if (_callType == _CallType.group && isScheduled) {
      AppUtils.showSnackBar(
        context: context,
        extraMessage: 'Batch scheduling is not supported by the server yet.',
        toastificationType: ToastificationType.warning,
      );
      return;
    }

    setState(() => _isCalling = true);
    final buildContext = context;
    final navigator = Navigator.of(context);
    final customersCubit = context.read<CustomersCubit>();
    final callsCubit = context.read<CallsCubit>();

    if (_callType == _CallType.single) {
      final String phone;
      final String name;
      final String? customerId;

      if (_isDirectPhone && widget.fullName == null) {
        phone = _customPhoneCtrl.text.trim();
        name = _customNameCtrl.text.trim().isNotEmpty
            ? _customNameCtrl.text.trim()
            : 'Direct Contact';
        customerId = null;
      } else {
        if (_selectedUser == null) {
          setState(() => _isCalling = false);
          AppUtils.showSnackBar(
            context: context,
            extraMessage: 'Please select a recipient customer or enter a phone number.',
            toastificationType: ToastificationType.warning,
          );
          return;
        }
        phone = _selectedUser!.phone;
        name = _selectedUser!.fullName;
        customerId =
            _selectedUser!.id != '-1' ? _selectedUser!.id.toString() : null;
      }

      if (phone.isEmpty || phone.length < 5) {
        setState(() => _isCalling = false);
        AppUtils.showSnackBar(
          context: context,
          extraMessage: 'Please enter a valid destination phone number.',
          toastificationType: ToastificationType.warning,
        );
        return;
      }

      final dispatched = await customersCubit.dispatchCall(
        customerId: customerId,
        scenarioId: scenario.id,
        phone: phone,
        fullName: name,
        scheduledFor: _scheduledFor(),
      );
      if (!dispatched) {
        if (mounted) {
          setState(() => _isCalling = false);
          if (customersCubit.state.actionError != null) {
            AppUtils.showSnackBar(
              context: context,
              extraMessage: customersCubit.state.actionError!,
              toastificationType: ToastificationType.error,
            );
          }
        }
        return;
      }
      await callsCubit.refresh();

      if (buildContext.mounted) {
        setState(() => _isCalling = false);
        navigator.pop();

        AppUtils.showSnackBar(
          context: buildContext,
          title: isScheduled
              ? 'Call Scheduled Successfully'
              : 'Call Initiated with $name',
          extraMessage: 'Scenario: ${scenario.title}',
          toastificationType: ToastificationType.success,
        );
      }
    }
 else {
      final customers = customersCubit.state.users;
      final targets = _groupTargets(customers);
      if (targets.isEmpty) {
        setState(() => _isCalling = false);
        AppUtils.showSnackBar(
          context: context,
          extraMessage: 'Select at least one customer for this campaign.',
          toastificationType: ToastificationType.warning,
        );
        return;
      }

      final launched = await callsCubit.launchBatch(
        name: '${scenario.title} Campaign',
        scenarioId: scenario.id,
        customerIds: targets.map((user) => user.id).toList(growable: false),
        concurrentLines: _concurrencyLines,
      );
      if (!launched) {
        if (mounted) setState(() => _isCalling = false);
        return;
      }

      if (buildContext.mounted) {
        setState(() => _isCalling = false);
        navigator.pop();

        AppUtils.showSnackBar(
          context: buildContext,
          title: 'Batch Campaign Launched (${targets.length} Leads)',
          extraMessage:
              'Scenario: ${scenario.title} across $_concurrencyLines concurrent lines.',
          toastificationType: ToastificationType.success,
        );
      }
    }
  }

  Widget _buildCallingAnimation(bool isDark) {
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Container(
        width: 440,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _callType == _CallType.single
                    ? CupertinoIcons.phone_fill
                    : CupertinoIcons.person_3_fill,
                color: Theme.of(context).colorScheme.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _callType == _CallType.single
                  ? 'Connecting to ${_selectedUser?.fullName ?? "Contact"}...'
                  : 'Dispatching $_concurrencyLines AI Calling Bots...',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Scenario: ${_selectedScenario?.title ?? "Loading..."}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const AppLoadingIndicator(size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioItem(ConversationScenario s, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            s.category.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            s.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersState = context.watch<CustomersCubit>().state;
    final customers = customersState.users;
    final isCustomersLoading = customersState.isInitialLoading;

    if (_isCalling) {
      return _buildCallingAnimation(isDark);
    }


    final targetCount = _getGroupTargetCount(customers);

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Container(
        width: 560,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _callType == _CallType.single
                        ? 'START OUTBOUND CALL'
                        : 'START BATCH CALL CAMPAIGN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(CupertinoIcons.clear, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Call Mode Switcher (Single vs Group Call)
              if (widget.fullName == null) ...[
                Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    borderRadius:
                        BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _callType = _CallType.single),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _callType == _CallType.single
                                  ? (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow:
                                  _callType == _CallType.single && !isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'SINGLE CALL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: _callType == _CallType.single
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white60
                                        : Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _callType = _CallType.group;
                            _timingMode = _TimingMode.callNow;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _callType == _CallType.group
                                  ? (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: _callType == _CallType.group && !isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'GROUP BATCH CALL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: _callType == _CallType.group
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white60
                                        : Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ----------------------------------------------------
              // SINGLE CALL CONTENT
              // ----------------------------------------------------
              if (_callType == _CallType.single) ...[
                if (widget.fullName == null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELECT RECIPIENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isDirectPhone = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !_isDirectPhone
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CUSTOMER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: !_isDirectPhone
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _isDirectPhone = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isDirectPhone
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DIRECT PHONE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _isDirectPhone
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_isDirectPhone)
                    AppDropdownWidget<User>(
                      value: _selectedUser,
                      hint: isCustomersLoading
                          ? 'Loading customers...'
                          : (customers.isEmpty
                              ? 'No customers found'
                              : 'Choose customer'),
                      items: customers,
                      itemBuilder: (user) =>
                          '${user.fullName} (${user.companyName.isNotEmpty ? user.companyName : user.phone})',
                      onChanged: (user) =>
                          setState(() => _selectedUser = user),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : context.colors.lightGreyColor,
                              ),
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02),
                            ),
                            child: TextField(
                              controller: _customPhoneCtrl,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                hintText:
                                    'Phone Number (e.g. +1 604 262 2563)',
                                hintStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: context.colors.darkGreyColor),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : context.colors.lightGreyColor,
                              ),
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.black.withValues(alpha: 0.02),
                            ),
                            child: TextField(
                              controller: _customNameCtrl,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                hintText: 'Name (optional)',
                                hintStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: context.colors.darkGreyColor),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 22),
                ] else ...[

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedUser?.fullName ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _selectedUser?.phone ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // Conversation Scenario Selector (Using AppDropdownWidget opening below)
                Text(
                  'AI CONVERSATION SCENARIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                AppDropdownWidget<ConversationScenario>(
                  value: _selectedScenario,
                  items: _scenarios,
                  hint: _scenarioError ?? 'Loading scenarios...',
                  customItemBuilder: (s) => _buildScenarioItem(s, isDark),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedScenario = val);
                  },
                ),
                const SizedBox(height: 22),

                // Timing Selector
                Text(
                  'EXECUTION TIMING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _timingMode = _TimingMode.callNow),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _timingMode == _TimingMode.callNow
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? Colors.white12
                                      : context.colors.lightGreyColor),
                            ),
                            backgroundColor: _timingMode == _TimingMode.callNow
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                          child: Text(
                            'CALL NOW',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _timingMode == _TimingMode.callNow
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _timingMode == _TimingMode.schedule
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? Colors.white12
                                      : context.colors.lightGreyColor),
                            ),
                            backgroundColor: _timingMode == _TimingMode.schedule
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                          child: Text(
                            'SCHEDULE CALL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _timingMode == _TimingMode.schedule
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_timingMode == _TimingMode.schedule) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PresetChipWidget(
                        label: 'Today',
                        isSelected: _selectedDatePreset == 'Today',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Today'),
                      ),
                      PresetChipWidget(
                        label: 'Tomorrow',
                        isSelected: _selectedDatePreset == 'Tomorrow',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Tomorrow'),
                      ),
                      PresetChipWidget(
                        label: 'Next Monday',
                        isSelected: _selectedDatePreset == 'Next Monday',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Next Monday'),
                      ),
                      PresetChipWidget(
                        label: _customDate != null
                            ? AppDateTime.displayDateTime(_customDate!)
                            : 'Custom Date & Time',
                        isSelected: _selectedDatePreset == 'Custom',
                        onTap: () async {
                          final picked = await AppDateTimePicker.pickDateTime(
                            context,
                            initial: _customDate,
                            first: DateTime.now(),
                            last: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDatePreset = 'Custom';
                              _customDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // ----------------------------------------------------
                // GROUP BATCH CALL CONTENT
                // ----------------------------------------------------
                Text(
                  'TARGET AUDIENCE SELECTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                // Predefined Segment vs Manual Selection Switcher
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() =>
                              _groupTargetMode = _GroupTargetMode.segment),
                          icon: Icon(
                            CupertinoIcons.layers_fill,
                            size: 14,
                            color: _groupTargetMode == _GroupTargetMode.segment
                                ? Theme.of(context).colorScheme.primary
                                : context.colors.darkGreyColor,
                          ),
                          label: Text(
                            'PRESET SEGMENT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _groupTargetMode ==
                                      _GroupTargetMode.segment
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  _groupTargetMode == _GroupTargetMode.segment
                                      ? Theme.of(context).colorScheme.primary
                                      : (isDark
                                          ? Colors.white12
                                          : context.colors.lightGreyColor),
                            ),
                            backgroundColor:
                                _groupTargetMode == _GroupTargetMode.segment
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08)
                                    : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(
                              () => _groupTargetMode = _GroupTargetMode.manual),
                          icon: Icon(
                            CupertinoIcons.person_crop_circle_badge_checkmark,
                            size: 14,
                            color: _groupTargetMode == _GroupTargetMode.manual
                                ? Theme.of(context).colorScheme.primary
                                : context.colors.darkGreyColor,
                          ),
                          label: Text(
                            'MANUAL SELECTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _groupTargetMode == _GroupTargetMode.manual
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _groupTargetMode == _GroupTargetMode.manual
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? Colors.white12
                                      : context.colors.lightGreyColor),
                            ),
                            backgroundColor:
                                _groupTargetMode == _GroupTargetMode.manual
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.08)
                                    : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_groupTargetMode == _GroupTargetMode.segment) ...[
                  AppDropdownWidget<String>(
                    value: _selectedGroupSegment,
                    items: _groupSegments,
                    itemBuilder: (seg) => seg,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedGroupSegment = val);
                      }
                    },
                  ),
                ] else ...[
                  // Redesigned Pixel-Perfect Customer Selection Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : context.colors.lightGreyColor,
                      ),
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                    child: Column(
                      children: [
                        // Pixel-perfect Search Bar
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : context.colors.lightGreyColor,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.search,
                                size: 15,
                                color: context.colors.darkGreyColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCustomerCtrl,
                                  textAlignVertical: TextAlignVertical.center,
                                  onChanged: (val) => setState(
                                      () => _customerSearchQuery = val),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    hintText:
                                        'Search customer name or company...',
                                    hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.darkGreyColor,
                                    ),
                                  ),
                                ),
                              ),
                              if (_customerSearchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCustomerCtrl.clear();
                                    setState(() => _customerSearchQuery = '');
                                  },
                                  child: Icon(
                                    CupertinoIcons.clear_circled_solid,
                                    size: 15,
                                    color: context.colors.darkGreyColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Count and Select All Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_manualSelectedUserIds.length} of ${customers.length} selected',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _manualSelectedUserIds.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : context.colors.darkGreyColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (_manualSelectedUserIds.length ==
                                      customers.length) {
                                    _manualSelectedUserIds.clear();
                                  } else {
                                    _manualSelectedUserIds
                                        .addAll(customers.map((u) => u.id));
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                child: Text(
                                  _manualSelectedUserIds.length ==
                                          customers.length
                                      ? 'Clear All'
                                      : 'Select All',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 8),

                        // Scrollable List of customers
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            itemCount: customers
                                .where((u) =>
                                    _customerSearchQuery.isEmpty ||
                                    u.fullName.toLowerCase().contains(
                                        _customerSearchQuery.toLowerCase()) ||
                                    u.companyName.toLowerCase().contains(
                                        _customerSearchQuery.toLowerCase()))
                                .length,
                            itemBuilder: (context, idx) {
                              final filtered = customers
                                  .where((u) =>
                                      _customerSearchQuery.isEmpty ||
                                      u.fullName.toLowerCase().contains(
                                          _customerSearchQuery.toLowerCase()) ||
                                      u.companyName.toLowerCase().contains(
                                          _customerSearchQuery.toLowerCase()))
                                  .toList();
                              final user = filtered[idx];
                              final isSelected =
                                  _manualSelectedUserIds.contains(user.id);

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _manualSelectedUserIds.remove(user.id);
                                    } else {
                                      _manualSelectedUserIds.add(user.id);
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? CupertinoIcons
                                                .checkmark_square_fill
                                            : CupertinoIcons.square,
                                        size: 16,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : context.colors.darkGreyColor,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          user.fullName,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        user.companyName.isNotEmpty
                                            ? user.companyName
                                            : user.phone,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: context.colors.darkGreyColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),

                // Conversation Scenario for Batch
                Text(
                  'AI CONVERSATION SCENARIO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                AppDropdownWidget<ConversationScenario>(
                  value: _selectedScenario,
                  items: _scenarios,
                  hint: _scenarioError ?? 'Loading scenarios...',
                  customItemBuilder: (s) => _buildScenarioItem(s, isDark),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedScenario = val);
                  },
                ),
                const SizedBox(height: 22),

                // Concurrency Lines
                Text(
                  'CONCURRENT AI CALLING BOTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _concurrencyOptions.map((lines) {
                    final isSelected = _concurrencyLines == lines;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () =>
                              setState(() => _concurrencyLines = lines),
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.buttonRadius),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white12
                                        : context.colors.lightGreyColor),
                              ),
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$lines ${lines == 1 ? 'Line' : 'Lines'}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),

                // Timing Selector for Group Call
                Text(
                  'EXECUTION TIMING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _timingMode = _TimingMode.callNow),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _timingMode == _TimingMode.callNow
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? Colors.white12
                                      : context.colors.lightGreyColor),
                            ),
                            backgroundColor: _timingMode == _TimingMode.callNow
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                          child: Text(
                            'LAUNCH NOW',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _timingMode == _TimingMode.callNow
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => setState(
                              () => _timingMode = _TimingMode.schedule),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _timingMode == _TimingMode.schedule
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark
                                      ? Colors.white12
                                      : context.colors.lightGreyColor),
                            ),
                            backgroundColor: _timingMode == _TimingMode.schedule
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.08)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  ThemeConstants.buttonRadius),
                            ),
                          ),
                          child: Text(
                            'SCHEDULE UNAVAILABLE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _timingMode == _TimingMode.schedule
                                  ? Theme.of(context).colorScheme.primary
                                  : (isDark ? Colors.white60 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_timingMode == _TimingMode.schedule) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PresetChipWidget(
                        label: 'Today',
                        isSelected: _selectedDatePreset == 'Today',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Today'),
                      ),
                      PresetChipWidget(
                        label: 'Tomorrow',
                        isSelected: _selectedDatePreset == 'Tomorrow',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Tomorrow'),
                      ),
                      PresetChipWidget(
                        label: 'Next Monday',
                        isSelected: _selectedDatePreset == 'Next Monday',
                        onTap: () =>
                            setState(() => _selectedDatePreset = 'Next Monday'),
                      ),
                      PresetChipWidget(
                        label: _customDate != null
                            ? AppDateTime.displayDateTime(_customDate!)
                            : 'Custom Date & Time',
                        isSelected: _selectedDatePreset == 'Custom',
                        onTap: () async {
                          final picked = await AppDateTimePicker.pickDateTime(
                            context,
                            initial: _customDate,
                            first: DateTime.now(),
                            last: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDatePreset = 'Custom';
                              _customDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 32),

              // Full-Width Primary Action Button (Matching App Standards)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedScenario == null ||
                          (_callType == _CallType.single &&
                              _selectedUser == null) ||
                          (_callType == _CallType.group && targetCount == 0)
                      ? null
                      : _triggerCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                    ),
                  ),
                  child: Text(
                    _callType == _CallType.single
                        ? (_timingMode == _TimingMode.callNow
                            ? 'START CALL NOW'
                            : 'CONFIRM SCHEDULE')
                        : (_timingMode == _TimingMode.callNow
                            ? 'START BATCH CALL ($targetCount CONTACTS)'
                            : 'SCHEDULE BATCH CAMPAIGN ($targetCount CONTACTS)'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
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
}
