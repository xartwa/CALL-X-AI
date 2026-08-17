import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/services/preferences_service.dart';
import 'package:callx_ai/theme/theme_cubit.dart';
import 'package:callx_ai/features/dashboard/widgets/workspace_settings_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import 'package:callx_ai/core/routes/app_routes_path.dart';
import 'package:callx_ai/core/utils/utils.dart';
import 'package:callx_ai/features/calls/widgets/call_action_dialog.dart';
import 'package:callx_ai/features/email_follow_ups/widgets/send_email_dialog.dart';
import 'package:callx_ai/features/customers/widgets/add_customer_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

// --- Models for Dashboard ---

class TodoItem {
  String text;
  bool isCompleted;
  TodoItem({required this.text, this.isCompleted = false});
}

// --- Dashboard Page ---

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late bool _aiEnabled;

  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _upcomingSearchCtrl = TextEditingController();
  String _upcomingFilter = 'All';
  String _upcomingSearchQuery = '';

  final List<TodoItem> _todos = [
    TodoItem(text: "Review weekly cold call metrics"),
    TodoItem(text: "Follow up with VIP qualified leads", isCompleted: true),
    TodoItem(text: "Update outbound sales campaign script"),
    TodoItem(text: "Check telephony carrier logs"),
    TodoItem(text: "Schedule pipeline review meeting"),
  ];

  @override
  void initState() {
    super.initState();
    _aiEnabled = context.read<PreferencesService>().isAiEnabled();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _todoController.dispose();
    _upcomingSearchCtrl.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_todoController.text.trim().isNotEmpty) {
      setState(() {
        _todos.insert(0, TodoItem(text: _todoController.text.trim()));
        _todoController.clear();
      });
    }
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  void _toggleAi() async {
    final newValue = !_aiEnabled;
    await context.read<PreferencesService>().setAiEnabled(newValue);
    setState(() {
      _aiEnabled = newValue;
    });
    if (mounted) {
      AppUtils.showSnackBar(
        context: context,
        title: _aiEnabled ? 'AI Calling Engine Resumed' : 'AI Calling Engine Paused',
        extraMessage: _aiEnabled
            ? 'The AI agent is now actively handling live calls.'
            : 'Outbound and inbound AI lines are currently paused.',
        toastificationType:
            _aiEnabled ? ToastificationType.success : ToastificationType.warning,
      );
    }
  }

  void _openLaunchBatchCall() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CallActionDialog(
        startInGroupMode: true,
      ),
    );
  }

  void _openSendMassEmail() {
    final prefs = context.read<PreferencesService>();
    final templates = prefs.loadTemplates();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SendEmailDialog(
        allTemplates: templates,
        startInGroupMode: true,
        onSendEmail: (newEmail) {
          final existing = prefs.loadEmails();
          existing.insert(0, newEmail);
          prefs.saveEmails(existing);
          AppUtils.showSnackBar(
            context: context,
            title: 'Email Campaign Queued',
            extraMessage:
                'Your follow-up email batch has been successfully queued.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  void _openAddNewCustomer() async {
    final newUser = await AddCustomerDialog.show(context);
    if (newUser != null && mounted) {
      context.read<CustomersCubit>().addCustomer(newUser);
      AppUtils.showSnackBar(
        context: context,
        title: 'Lead Added Successfully',
        extraMessage:
            '${newUser.fullName} has been added to your CRM directory.',
        toastificationType: ToastificationType.success,
      );
    }
  }

  void _openCallForUser(User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CallActionDialog(
        fullName: user.fullName,
        phone: user.phone,
        initialTab: 'callNow',
      ),
    );
  }

  void _openEmailForUser(User user) {
    final prefs = context.read<PreferencesService>();
    final templates = prefs.loadTemplates();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SendEmailDialog(
        allTemplates: templates,
        onSendEmail: (newEmail) {
          final existing = prefs.loadEmails();
          existing.insert(0, newEmail);
          prefs.saveEmails(existing);
          AppUtils.showSnackBar(
            context: context,
            title: 'Email Sent',
            extraMessage: 'Follow-up email dispatched to ${user.fullName}.',
            toastificationType: ToastificationType.success,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<PreferencesService>();
    final customersState = context.watch<CustomersCubit>().state;
    final calls = preferences.loadCalls();

    final totalCalls = calls.length;
    final callsToday = calls.length;
    final completedCalls =
        calls.where((c) => c['status'] == 'Completed').length;
    final successRate = totalCalls == 0 ? 0.0 : (completedCalls / totalCalls);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MINIMALIST HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpacedText(
                    text: "Overview",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.blackColor,
                  ),
                ],
              ),
              Row(
                children: [
                  // Clickable AI Status Pill
                  InkWell(
                    onTap: _toggleAi,
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _aiEnabled
                            ? context.colors.successColor.withValues(alpha: 0.1)
                            : context.colors.darkGreyColor
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _aiEnabled
                              ? context.colors.successColor
                                  .withValues(alpha: 0.3)
                              : context.colors.darkGreyColor
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _aiEnabled
                                      ? context.colors.successColor.withValues(
                                          alpha: _pulseController.value * 0.6 +
                                              0.4)
                                      : context.colors.darkGreyColor,
                                  boxShadow: _aiEnabled
                                      ? [
                                          BoxShadow(
                                            color: context.colors.successColor
                                                .withValues(alpha: 0.5),
                                            blurRadius:
                                                _pulseController.value * 8,
                                            spreadRadius:
                                                _pulseController.value * 2,
                                          )
                                        ]
                                      : null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _aiEnabled ? "AI Active" : "AI Paused",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: _aiEnabled
                                  ? context.colors.successColor
                                  : context.colors.darkGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Workspace Settings
                  InkWell(
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => const WorkspaceSettingsDialog(),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.colors.mediumGreyColor
                                .withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        CupertinoIcons.settings,
                        color: context.colors.blackColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Theme Switch
                  InkWell(
                    onTap: () {
                      final currentMode = context.read<ThemeCubit>().state;
                      context.read<ThemeCubit>().setTheme(
                          currentMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.mediumGreyColor
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? CupertinoIcons.sun_max_fill
                            : CupertinoIcons.moon_fill,
                        color: context.colors.blackColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 2. KPI BOXES
          Row(
            children: [
              Expanded(
                child: _buildCleanKpi(
                  title: "Total Calls",
                  value: "$totalCalls",
                  trend: "+12%",
                  icon: CupertinoIcons.phone_fill,
                  iconColor: context.colors.primaryLightColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCleanKpi(
                  title: "Calls Today",
                  value: "$callsToday",
                  trend: "+5%",
                  icon: CupertinoIcons.phone_badge_plus,
                  iconColor: context.colors.warningColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCleanKpi(
                  title: "Success Rate",
                  value: "${(successRate * 100).toInt()}%",
                  trend: "+2%",
                  icon: CupertinoIcons.checkmark_alt_circle,
                  iconColor: context.colors.successColor,
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCleanKpi(
                  title: "Pending Follow-ups",
                  value: "14",
                  trend: "-3%",
                  icon: CupertinoIcons.mail_solid,
                  iconColor: const Color(0xFF8B5CF6),
                  isPositive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. MAIN WORKSPACE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT PANEL: 62% (Upcoming Calls - Fixed Height & Internal Scrollable)
              Expanded(
                flex: 62,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: context.colors.mediumGreyColor
                            .withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with count and View All link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildSectionTitle("Upcoming Scheduled Calls"),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryLightColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: context.colors.primaryLightColor
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '${customersState.users.length} in Queue',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.go(AppRoutesPath.calls),
                            child: Row(
                              children: [
                                Text(
                                  "VIEW ALL CALLS",
                                  style: TextStyle(
                                    color: context.colors.primaryLightColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  CupertinoIcons.arrow_right,
                                  size: 12,
                                  color: context.colors.primaryLightColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Search & Filter Bar
                      Row(
                        children: [
                          // Search Box
                          Expanded(
                            child: Container(
                              height: 38,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : context.colors.mediumGreyColor
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white12
                                      : context.colors.mediumGreyColor
                                          .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.search,
                                    size: 14,
                                    color: context.colors.darkGreyColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _upcomingSearchCtrl,
                                      style: const TextStyle(fontSize: 12.5),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      onChanged: (val) => setState(
                                          () => _upcomingSearchQuery = val),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText:
                                            'Search scheduled calls by name or company...',
                                        hintStyle: TextStyle(
                                            fontSize: 12,
                                            color: context.colors.darkGreyColor),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  if (_upcomingSearchQuery.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _upcomingSearchCtrl.clear();
                                        setState(
                                            () => _upcomingSearchQuery = '');
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        size: 14,
                                        color: context.colors.darkGreyColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Filter Segment: All / Priority / Regular
                          Container(
                            height: 38,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : context.colors.mediumGreyColor
                                      .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white12
                                    : context.colors.mediumGreyColor
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildUpcomingFilterChip('All'),
                                _buildUpcomingFilterChip('Hot Leads'),
                                _buildUpcomingFilterChip('Standard'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fixed-size Scrollable Area for Upcoming Calls (Matched to right side height)
                      SizedBox(
                        height: 680,
                        child: () {
                          final filteredList =
                              customersState.users.where((user) {
                            final matchesSearch =
                                _upcomingSearchQuery.isEmpty ||
                                    user.fullName.toLowerCase().contains(
                                        _upcomingSearchQuery.toLowerCase()) ||
                                    user.companyName.toLowerCase().contains(
                                        _upcomingSearchQuery.toLowerCase()) ||
                                    user.phone.contains(_upcomingSearchQuery);

                            if (!matchesSearch) return false;

                            if (_upcomingFilter == 'Hot Leads') {
                              return user.leadPriority.toLowerCase() ==
                                      'hot' ||
                                  user.tags.contains('Hot Lead');
                            }
                            if (_upcomingFilter == 'Standard') {
                              return user.leadPriority.toLowerCase() != 'hot';
                            }
                            return true;
                          }).toList();

                          if (filteredList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.phone_badge_plus,
                                    size: 40,
                                    color: context.colors.darkGreyColor
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No scheduled calls match criteria.",
                                    style: TextStyle(
                                      color: context.colors.darkGreyColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: WidgetStateProperty.all(
                                  context.colors.mediumGreyColor
                                      .withValues(alpha: 0.4),
                                ),
                                radius: const Radius.circular(8),
                                thickness: WidgetStateProperty.all(6),
                              ),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView.separated(
                                padding: const EdgeInsets.only(right: 12),
                                itemCount: filteredList.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (_, __) => Divider(
                                  color: context.colors.mediumGreyColor
                                      .withValues(alpha: 0.15),
                                  height: 24,
                                ),
                                itemBuilder: (context, index) {
                                  final user = filteredList[index];
                                  final time = [
                                    "09:30 AM",
                                    "10:15 AM",
                                    "11:00 AM",
                                    "01:30 PM",
                                    "02:45 PM",
                                    "03:30 PM",
                                    "04:15 PM",
                                    "05:00 PM"
                                  ][index % 8];
                                  final isPriority =
                                      user.leadPriority.toLowerCase() ==
                                              'hot' ||
                                          index % 3 == 0;
                                  final priorityColor = isPriority
                                      ? context.colors.errorColor
                                      : context.colors.successColor;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Time & Priority Dot
                                        SizedBox(
                                          width: 75,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                time,
                                                style: TextStyle(
                                                  color: context
                                                      .colors.blackColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 7,
                                                    height: 7,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: priorityColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isPriority
                                                        ? 'Hot Lead'
                                                        : 'Standard',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: context.colors
                                                          .darkGreyColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Avatar
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: context
                                                .colors.primaryLightColor
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              user.fullName.isNotEmpty
                                                  ? user.fullName[0]
                                                      .toUpperCase()
                                                  : '?',
                                              style: TextStyle(
                                                color: context.colors
                                                    .primaryLightColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Contact Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.fullName,
                                                style: TextStyle(
                                                  color: context
                                                      .colors.blackColor,
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                      CupertinoIcons
                                                          .briefcase,
                                                      size: 11,
                                                      color: context.colors
                                                          .darkGreyColor),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      user.jobTitle.isNotEmpty
                                                          ? user.jobTitle
                                                          : (user.companyName
                                                                  .isNotEmpty
                                                              ? user
                                                                  .companyName
                                                              : "Client"),
                                                      style: TextStyle(
                                                        color: context.colors
                                                            .darkGreyColor,
                                                        fontSize: 11.5,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(CupertinoIcons.phone,
                                                      size: 11,
                                                      color: context.colors
                                                          .darkGreyColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    user.phone,
                                                    style: TextStyle(
                                                      color: context.colors
                                                          .darkGreyColor,
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Action Buttons (Call Now / Email)
                                        Row(
                                          children: [
                                            Tooltip(
                                              message:
                                                  'Call ${user.fullName}',
                                              child: _buildActionBtn(
                                                CupertinoIcons.phone_fill,
                                                context.colors.successColor,
                                                onTap: () =>
                                                    _openCallForUser(user),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message:
                                                  'Email ${user.fullName}',
                                              child: _buildActionBtn(
                                                CupertinoIcons.mail_solid,
                                                context.colors
                                                    .primaryLightColor,
                                                onTap: () =>
                                                    _openEmailForUser(user),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // RIGHT PANEL: 38% (Quick Operations Hub + Reports + To-Do)
              Expanded(
                flex: 38,
                child: Column(
                  children: [
                    // 1. QUICK OPERATIONS HUB
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.colors.mediumGreyColor
                                .withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle("Quick Operations"),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryLightColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ACTIONS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: context.colors.primaryLightColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 2x2 Grid of Rapid Actions
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickOpTile(
                                      title: 'Launch Batch Call',
                                      subtitle: 'Outbound AI Queue',
                                      icon: CupertinoIcons.phone_badge_plus,
                                      accentColor:
                                          context.colors.primaryLightColor,
                                      onTap: _openLaunchBatchCall,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickOpTile(
                                      title: 'Send Bulk Email',
                                      subtitle: 'Mass Follow-up',
                                      icon: CupertinoIcons.mail_solid,
                                      accentColor: const Color(0xFF8B5CF6),
                                      onTap: _openSendMassEmail,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickOpTile(
                                      title: 'Add New Lead',
                                      subtitle: 'Instant Prospect',
                                      icon: CupertinoIcons
                                          .person_crop_circle_badge_plus,
                                      accentColor: const Color(0xFF10B981),
                                      onTap: _openAddNewCustomer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildQuickOpTile(
                                      title: 'AI Voice Settings',
                                      subtitle: 'Prompts & Voices',
                                      icon: CupertinoIcons.sparkles,
                                      accentColor: const Color(0xFFF59E0B),
                                      onTap: () =>
                                          context.go(AppRoutesPath.aiSettings),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. CALL REPORTS DONUT CHART
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.colors.mediumGreyColor
                                .withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Call Reports"),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              // Donut Chart
                              SizedBox(
                                width: 110,
                                height: 110,
                                child: Stack(
                                  children: [
                                    CustomPaint(
                                      size: const Size(110, 110),
                                      painter: DonutChartPainter(
                                        sections: [
                                          ChartSection(
                                              value: 36,
                                              color: context
                                                  .colors.primaryLightColor),
                                          ChartSection(
                                              value: 20,
                                              color: context
                                                  .colors.primaryLightColor
                                                  .withValues(alpha: 0.7)),
                                          ChartSection(
                                              value: 12,
                                              color: context
                                                  .colors.primaryLightColor
                                                  .withValues(alpha: 0.4)),
                                          ChartSection(
                                              value: 15,
                                              color:
                                                  context.colors.darkGreyColor),
                                          ChartSection(
                                              value: 17,
                                              color: context
                                                  .colors.lightGreyColor),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "100%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.blackColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Legend
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildLegendItem("No Answer", 36,
                                        context.colors.primaryLightColor),
                                    _buildLegendItem(
                                        "Completed",
                                        20,
                                        context.colors.primaryLightColor
                                            .withValues(alpha: 0.7)),
                                    _buildLegendItem(
                                        "Dropped",
                                        17,
                                        context.colors.primaryLightColor
                                            .withValues(alpha: 0.4)),
                                    _buildLegendItem("Call Back", 12,
                                        context.colors.darkGreyColor),
                                    _buildLegendItem("Already Bought", 15,
                                        context.colors.lightGreyColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. FIXED SCROLLABLE TO-DO LIST
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: context.colors.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: context.colors.mediumGreyColor
                                .withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("To-Do List"),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: context.colors.mediumGreyColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextField(
                                    controller: _todoController,
                                    style: const TextStyle(fontSize: 12.5),
                                    textAlignVertical:
                                        TextAlignVertical.bottom,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: "Add a new task...",
                                      hintStyle: TextStyle(
                                          color: context.colors.darkGreyColor,
                                          fontSize: 12.5),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 18),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _addTodo(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: _addTodo,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: context.colors.primaryLightColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(CupertinoIcons.add,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Fixed height scrollable area for ToDos
                          SizedBox(
                            height: 220,
                            child: _todos.isEmpty
                                ? Center(
                                    child: Text("All caught up!",
                                        style: TextStyle(
                                            color:
                                                context.colors.darkGreyColor)),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _todos.length,
                                    itemBuilder: (context, index) {
                                      final todo = _todos[index];
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: context
                                                  .colors.mediumGreyColor
                                                  .withValues(alpha: 0.3)),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 0),
                                          leading: InkWell(
                                            onTap: () => _toggleTodo(index),
                                            child: Icon(
                                              todo.isCompleted
                                                  ? CupertinoIcons
                                                      .checkmark_square_fill
                                                  : Icons
                                                      .check_box_outline_blank_rounded,
                                              color: todo.isCompleted
                                                  ? context.colors.successColor
                                                  : context
                                                      .colors.darkGreyColor,
                                            ),
                                          ),
                                          title: Text(
                                            todo.text,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: todo.isCompleted
                                                  ? context.colors.darkGreyColor
                                                  : context.colors.blackColor,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                          trailing: InkWell(
                                            onTap: () => _deleteTodo(index),
                                            child: Icon(
                                              CupertinoIcons.trash_fill,
                                              color: context.colors.errorColor,
                                              size: 15,
                                            ),
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
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUpcomingFilterChip(String label) {
    final isSelected = _upcomingFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _upcomingFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : context.colors.darkGreyColor,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOpTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: accentColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : context.colors.mediumGreyColor.withValues(alpha: 0.25),
            ),
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : context.colors.mediumGreyColor.withValues(alpha: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 17),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: context.colors.blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.darkGreyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return SpacedText(
      text: text,
      color: context.colors.blackColor,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      fontSize: 16,
    );
  }

  Widget _buildCleanKpi({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color iconColor,
    required bool isPositive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: context.colors.mediumGreyColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: context.colors.darkGreyColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: context.colors.blackColor,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? CupertinoIcons.arrow_up
                              : CupertinoIcons.arrow_down,
                          color: isPositive
                              ? context.colors.successColor
                              : context.colors.errorColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$trend Since last month",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPositive
                                ? context.colors.successColor
                                : context.colors.errorColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style:
                  TextStyle(fontSize: 11, color: context.colors.darkGreyColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            "$percentage%",
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.colors.blackColor),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// --- Custom Donut Chart ---

class ChartSection {
  final double value;
  final Color color;
  ChartSection({required this.value, required this.color});
}

class DonutChartPainter extends CustomPainter {
  final List<ChartSection> sections;
  DonutChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    for (var s in sections) {
      total += s.value;
    }

    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;
    const double strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var s in sections) {
      final sweepAngle = (s.value / total) * 2 * math.pi;

      // Paint the section
      paint.color = s.color;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
