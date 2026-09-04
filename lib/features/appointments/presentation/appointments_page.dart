import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../core/constants/theme_constants.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/stat_card_widget.dart';
import '../../../theme/app_colors.dart';
import '../cubit/appointments_cubit.dart';
import '../cubit/appointments_state.dart';
import 'appointments_nav_tabs.dart';
import 'tabs/availability_tab_view.dart';
import 'tabs/calendar_tab_view.dart';
import 'tabs/requests_tab_view.dart';
import 'widgets/new_appointment_drawer.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsCubit>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != prev.errorMessage ||
          curr.successMessage != prev.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppUtils.showSnackBar(
            context: context,
            title: 'Error',
            extraMessage: state.errorMessage,
            toastificationType: ToastificationType.error,
          );
        } else if (state.successMessage != null &&
            state.successMessage!.isNotEmpty) {
          AppUtils.showSnackBar(
            context: context,
            title: 'Success',
            extraMessage: state.successMessage,
            toastificationType: ToastificationType.success,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AppointmentsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  StatCardWidget(
                    label: 'TOTAL APPOINTMENTS',
                    value:
                        '${state.kpi?.totalAppointments ?? state.appointments.length}',
                    icon: CupertinoIcons.calendar,
                    iconColor: context.colors.primaryLightColor,
                    iconBgColor: context.colors.primaryLightColor
                        .withValues(alpha: 0.12),
                  ),
                  StatCardWidget(
                    label: 'CONFIRMED',
                    value:
                        '${state.kpi?.confirmedAppointments ?? state.appointments.where((a) => a.isConfirmed).length}',
                    icon: CupertinoIcons.checkmark_alt_circle,
                    iconColor: context.colors.successColor,
                    iconBgColor:
                        context.colors.successColor.withValues(alpha: 0.12),
                  ),
                  StatCardWidget(
                    label: 'PENDING REQUESTS',
                    value:
                        '${state.kpi?.pendingRequests ?? state.pendingRequestsCount}',
                    icon: CupertinoIcons.clock,
                    iconColor: context.colors.queuedColor,
                    iconBgColor:
                        context.colors.queuedColor.withValues(alpha: 0.12),
                  ),
                  StatCardWidget(
                    label: 'UPCOMING THIS WEEK',
                    value:
                        '${state.kpi?.upcomingThisWeek ?? state.upcomingAppointmentsCount}',
                    icon: CupertinoIcons.time,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Tabs & Action Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Navigation Tabs
                AppointmentsNavTabs(
                  activeTab: state.activeTab,
                  onTabChanged: (index) => cubit.setActiveTab(index),
                  pendingRequestsCount: state.pendingRequestsCount,
                ),

                // Action Button opposite the tabs
                if (state.activeTab == 2)
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () => cubit.saveAvailabilityAndSettings(),
                      icon: state.isActionLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.checkmark,
                              size: 16,
                              color: Colors.white,
                            ),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeConstants.buttonRadius),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => NewAppointmentDrawer.show(context),
                      icon: const Icon(
                        CupertinoIcons.plus,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'New Appointment',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(ThemeConstants.buttonRadius),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Body Content
            Expanded(
              child: _buildBody(context, state, cubit),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
  ) {
    if (state.status == AppointmentsStatus.loading &&
        state.appointments.isEmpty) {
      return const Center(
        child: AppLoadingView(message: 'Loading calendar & bookings...'),
      );
    }
    if (state.status == AppointmentsStatus.failure &&
        state.appointments.isEmpty) {
      return Center(
        child: AppErrorView(
          message: state.errorMessage ?? 'Failed to load appointments.',
          onRetry: () => cubit.loadInitial(),
        ),
      );
    }

    switch (state.activeTab) {
      case 0:
        return const CalendarTabView();
      case 1:
        return const RequestsTabView();
      case 2:
        return const AvailabilityTabView();
      default:
        return const CalendarTabView();
    }
  }
}
