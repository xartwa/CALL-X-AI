import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../core/constants/theme_constants.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/spaced_text.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AppointmentsCubit, AppointmentsState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != prev.errorMessage ||
          curr.successMessage != prev.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: const Text('Error'),
            description: Text(state.errorMessage!),
            autoCloseDuration: const Duration(seconds: 4),
          );
        } else if (state.successMessage != null &&
            state.successMessage!.isNotEmpty) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            title: const Text('Success'),
            description: Text(state.successMessage!),
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AppointmentsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Top Header Bar
            _buildHeader(context, state, cubit, isDark),
            const SizedBox(height: 16),

            // Navigation Tabs (Placed between Header and Content)
            AppointmentsNavTabs(
              activeTab: state.activeTab,
              onTabChanged: (index) => cubit.setActiveTab(index),
              pendingRequestsCount: state.pendingRequestsCount,
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

  Widget _buildHeader(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
    bool isDark,
  ) {
    final conn = state.calendarConnection;
    final isConnected = conn.connected;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title (Spaced Uppercase, No Subtitle Description)
        const SpacedText(text: 'CALENDAR & BOOKINGS'),

        // Right Controls: Google Calendar Pill + Settings + Dynamic Action Button
        Row(
          children: [
            // Google Calendar Connection Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 8),
                  Text(
                    'Google Calendar',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: context.colors.blackColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: state.isActionLoading ? null : () => cubit.syncCalendar(),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        CupertinoIcons.arrow_2_circlepath,
                        size: 13,
                        color: context.colors.darkGreyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Settings Button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: IconButton(
                icon: const Icon(CupertinoIcons.gear_alt, size: 16),
                tooltip: 'Booking Settings',
                color: context.colors.darkGreyColor,
                onPressed: () => cubit.setActiveTab(2),
              ),
            ),
            const SizedBox(width: 12),

            // Dynamic Action Button (+ New Appointment or Save Changes)
            if (state.activeTab == 2)
              ElevatedButton.icon(
                onPressed: state.isActionLoading
                    ? null
                    : () => cubit.saveAvailabilityAndSettings(),
                icon: state.isActionLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        CupertinoIcons.checkmark,
                        size: 15,
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
                  backgroundColor: const Color(0xFF8B5CF6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  minimumSize: const Size(0, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => NewAppointmentDrawer.show(context),
                icon: const Icon(
                  CupertinoIcons.plus,
                  size: 15,
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
                  backgroundColor: const Color(0xFF8B5CF6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  minimumSize: const Size(0, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.buttonRadius),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}
