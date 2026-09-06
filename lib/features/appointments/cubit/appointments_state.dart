import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../domain/entities/appointment_entity.dart';

enum AppointmentsStatus { initial, loading, success, failure }
enum CalendarViewMode { week, month }

class AppointmentsState extends Equatable {
  final AppointmentsStatus status;
  final int activeTab; // 0 = Calendar, 1 = Requests, 2 = Availability
  final CalendarViewMode calendarViewMode;
  final DateTime selectedDate; // The reference date for the active week/month view
  final List<AppointmentEntity> appointments;
  final List<AppointmentEntity> upcomingAppointments;
  final List<AppointmentEntity> calendarAppointments;
  final List<AppointmentRequestEntity> requests;
  final List<AvailabilityRuleEntity> availabilityRules;
  final List<AvailabilityExceptionEntity> exceptions;
  final AppointmentSettingsEntity settings;
  final CalendarConnectionEntity calendarConnection;
  final List<AvailableSlotEntity> availableSlots;
  final AppointmentKPIStats? kpi;
  final String selectedStatusFilter; // 'All', 'Confirmed', 'Pending', etc.
  final String selectedTypeFilter; // 'All', 'Online', 'In-Person'
  final String searchQuery;
  final bool isActionLoading;
  final String? errorMessage;
  final String? successMessage;

  const AppointmentsState({
    this.status = AppointmentsStatus.initial,
    this.activeTab = 0,
    this.calendarViewMode = CalendarViewMode.week,
    required this.selectedDate,
    this.appointments = const [],
    this.upcomingAppointments = const [],
    this.calendarAppointments = const [],
    this.requests = const [],
    this.availabilityRules = const [],
    this.exceptions = const [],
    this.settings = const AppointmentSettingsEntity(),
    this.calendarConnection = const CalendarConnectionEntity(),
    this.availableSlots = const [],
    this.kpi,
    this.selectedStatusFilter = 'All',
    this.selectedTypeFilter = 'All',
    this.searchQuery = '',
    this.isActionLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory AppointmentsState.initial() {
    return AppointmentsState(selectedDate: DateTime.now());
  }

  int get pendingRequestsCount =>
      requests.where((r) => r.status.toLowerCase() == 'pending').length;

  int get todayAppointmentsCount =>
      appointments.where((a) => a.isToday && !a.isCancelled).length;

  int get upcomingAppointmentsCount =>
      appointments.where((a) => a.isUpcoming).length;

  int get completedThisMonthCount {
    final now = DateTime.now();
    return appointments
        .where((a) =>
            a.isCompleted &&
            a.startAt.year == now.year &&
            a.startAt.month == now.month)
        .length;
  }

  List<AppointmentEntity> get filteredAppointments {
    return appointments.where((a) {
      if (selectedStatusFilter != 'All') {
        final filterLower = selectedStatusFilter.toLowerCase();
        if (filterLower == 'confirmed') {
          if (!a.isConfirmed && !a.isRescheduled) return false;
        } else if (a.status.toLowerCase() != filterLower) {
          return false;
        }
      }
      if (selectedTypeFilter != 'All' &&
          a.meetingType.toLowerCase() != selectedTypeFilter.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matches = a.title.toLowerCase().contains(q) ||
            a.customerName.toLowerCase().contains(q) ||
            a.companyName.toLowerCase().contains(q) ||
            a.customerEmail.toLowerCase().contains(q) ||
            (a.notes != null && a.notes!.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  List<AppointmentRequestEntity> get filteredRequests {
    return requests.where((r) {
      if (selectedStatusFilter != 'All' &&
          r.status.toLowerCase() != selectedStatusFilter.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matches = r.customerName.toLowerCase().contains(q) ||
            r.companyName.toLowerCase().contains(q) ||
            r.customerEmail.toLowerCase().contains(q) ||
            (r.notes != null && r.notes!.toLowerCase().contains(q));
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  /// Calculates the 7 days of the currently selected week (starting Sunday to match screenshot)
  List<DateTime> get currentWeekDays {
    // Sunday as start of week: weekday % 7 (Sunday=7 -> 0)
    final sundayOffset = selectedDate.weekday % 7;
    final sunday = selectedDate.subtract(Duration(days: sundayOffset));
    return List.generate(
      7,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
  }

  String get currentWeekRangeLabel {
    final week = currentWeekDays;
    final start = week.first;
    final end = week.last;
    if (start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} – ${DateFormat('d, yyyy').format(end)}';
    }
    return '${DateFormat('MMM d').format(start)} – ${DateFormat('MMM d, yyyy').format(end)}';
  }

  AppointmentsState copyWith({
    AppointmentsStatus? status,
    int? activeTab,
    CalendarViewMode? calendarViewMode,
    DateTime? selectedDate,
    List<AppointmentEntity>? appointments,
    List<AppointmentEntity>? upcomingAppointments,
    List<AppointmentEntity>? calendarAppointments,
    List<AppointmentRequestEntity>? requests,
    List<AvailabilityRuleEntity>? availabilityRules,
    List<AvailabilityExceptionEntity>? exceptions,
    AppointmentSettingsEntity? settings,
    CalendarConnectionEntity? calendarConnection,
    List<AvailableSlotEntity>? availableSlots,
    AppointmentKPIStats? kpi,
    String? selectedStatusFilter,
    String? selectedTypeFilter,
    String? searchQuery,
    bool? isActionLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      activeTab: activeTab ?? this.activeTab,
      calendarViewMode: calendarViewMode ?? this.calendarViewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      appointments: appointments ?? this.appointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      calendarAppointments: calendarAppointments ?? this.calendarAppointments,
      requests: requests ?? this.requests,
      availabilityRules: availabilityRules ?? this.availabilityRules,
      exceptions: exceptions ?? this.exceptions,
      settings: settings ?? this.settings,
      calendarConnection: calendarConnection ?? this.calendarConnection,
      availableSlots: availableSlots ?? this.availableSlots,
      kpi: kpi ?? this.kpi,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedTypeFilter: selectedTypeFilter ?? this.selectedTypeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeTab,
        calendarViewMode,
        selectedDate,
        appointments,
        upcomingAppointments,
        calendarAppointments,
        requests,
        availabilityRules,
        exceptions,
        settings,
        calendarConnection,
        availableSlots,
        kpi,
        selectedStatusFilter,
        selectedTypeFilter,
        searchQuery,
        isActionLoading,
        errorMessage,
        successMessage,
      ];
}
