import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/appointment_entity.dart';
import '../domain/repositories/appointments_repository.dart';
import 'appointments_state.dart';

String _extractErrorMessage(dynamic e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['non_field_errors'] != null) {
        final errs = data['non_field_errors'];
        if (errs is List && errs.isNotEmpty) {
          return errs.first.toString();
        }
        return errs.toString();
      }
      if (data.isNotEmpty) {
        final firstVal = data.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          return '${data.keys.first}: ${firstVal.first}';
        }
        return '${data.keys.first}: $firstVal';
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
  }
  return e.toString();
}

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository _repository;

  AppointmentsCubit(this._repository)
      : super(AppointmentsState.initial());

  Future<void> loadInitial() async {
    emit(state.copyWith(status: AppointmentsStatus.loading, clearError: true));
    try {
      final results = await Future.wait([
        _repository.getAppointments().catchError((_) => <AppointmentEntity>[]),
        _repository.getUpcomingAppointments().catchError((_) => <AppointmentEntity>[]),
        _repository.getAppointmentRequests().catchError((_) => <AppointmentRequestEntity>[]),
        _repository.getAvailabilityRules().catchError((_) => <AvailabilityRuleEntity>[]),
        _repository.getExceptions().catchError((_) => <AvailabilityExceptionEntity>[]),
        _repository.getSettings().catchError((_) => const AppointmentSettingsEntity()),
        _repository.getCalendarConnection().catchError((_) => const CalendarConnectionEntity()),
        _repository.getCalendarAppointments(
          year: state.selectedDate.year,
          month: state.selectedDate.month,
        ).catchError((_) => <AppointmentEntity>[]),
        _repository.getKPIStats().catchError((_) => const AppointmentKPIStats()),
      ]);

      emit(state.copyWith(
        status: AppointmentsStatus.success,
        appointments: results[0] as List<AppointmentEntity>,
        upcomingAppointments: results[1] as List<AppointmentEntity>,
        requests: results[2] as List<AppointmentRequestEntity>,
        availabilityRules: results[3] as List<AvailabilityRuleEntity>,
        exceptions: results[4] as List<AvailabilityExceptionEntity>,
        settings: results[5] as AppointmentSettingsEntity,
        calendarConnection: results[6] as CalendarConnectionEntity,
        calendarAppointments: results[7] as List<AppointmentEntity>,
        kpi: results[8] as AppointmentKPIStats,
      ));

      // Also trigger a pre-load of available slots
      loadAvailableSlots();
    } catch (e) {
      emit(state.copyWith(
        status: AppointmentsStatus.failure,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> refresh() async {
    if (state.isActionLoading) return;
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final now = state.selectedDate;
      final results = await Future.wait([
        _repository.getAppointments().catchError((_) => <AppointmentEntity>[]),
        _repository.getUpcomingAppointments().catchError((_) => <AppointmentEntity>[]),
        _repository.getAppointmentRequests().catchError((_) => <AppointmentRequestEntity>[]),
        _repository.getAvailabilityRules().catchError((_) => <AvailabilityRuleEntity>[]),
        _repository.getExceptions().catchError((_) => <AvailabilityExceptionEntity>[]),
        _repository.getSettings().catchError((_) => const AppointmentSettingsEntity()),
        _repository.getCalendarConnection().catchError((_) => const CalendarConnectionEntity()),
        _repository.getKPIStats().catchError((_) => const AppointmentKPIStats()),
        _repository.getCalendarAppointments(year: now.year, month: now.month).catchError((_) => <AppointmentEntity>[]),
      ]);

      if (!isClosed) {
        emit(state.copyWith(
          isActionLoading: false,
          appointments: results[0] as List<AppointmentEntity>,
          upcomingAppointments: results[1] as List<AppointmentEntity>,
          requests: results[2] as List<AppointmentRequestEntity>,
          availabilityRules: results[3] as List<AvailabilityRuleEntity>,
          exceptions: results[4] as List<AvailabilityExceptionEntity>,
          settings: results[5] as AppointmentSettingsEntity,
          calendarConnection: results[6] as CalendarConnectionEntity,
          kpi: results[7] as AppointmentKPIStats,
          calendarAppointments: results[8] as List<AppointmentEntity>,
        ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(isActionLoading: false));
      }
    }
  }

  void setActiveTab(int index) {
    emit(state.copyWith(activeTab: index));
  }

  void setCalendarViewMode(CalendarViewMode mode) {
    emit(state.copyWith(calendarViewMode: mode));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(selectedDate: now));
    _loadCalendarForDate(now);
  }

  void navigateWeek(int offsetWeeks) {
    final newDate = state.selectedDate.add(Duration(days: offsetWeeks * 7));
    emit(state.copyWith(selectedDate: newDate));
    _loadCalendarForDate(newDate);
  }

  void navigateMonth(int offsetMonths) {
    int y = state.selectedDate.year;
    int m = state.selectedDate.month + offsetMonths;
    if (m > 12) {
      y += 1;
      m = 1;
    } else if (m < 1) {
      y -= 1;
      m = 12;
    }
    final newDate = DateTime(y, m, state.selectedDate.day.clamp(1, 28));
    emit(state.copyWith(selectedDate: newDate));
    _loadCalendarForDate(newDate);
  }

  Future<void> _loadCalendarForDate(DateTime dt) async {
    try {
      final appts = await _repository.getCalendarAppointments(
        year: dt.year,
        month: dt.month,
      );
      emit(state.copyWith(calendarAppointments: appts));
    } catch (_) {}
  }

  void setStatusFilter(String status) {
    emit(state.copyWith(selectedStatusFilter: status));
  }

  void setTypeFilter(String type) {
    emit(state.copyWith(selectedTypeFilter: type));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  // --- Appointment Actions ---

  Future<bool> createAppointment({
    required int customerId,
    String? customerEmail,
    required DateTime startAt,
    DateTime? endAt,
    String meetingType = 'online',
    String title = 'Discovery Consultation',
    int durationMinutes = 45,
    String timezone = 'America/Toronto',
    String location = '',
    String notes = '',
  }) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.createAppointment(
        customerId: customerId,
        customerEmail: customerEmail,
        startAt: startAt,
        endAt: endAt,
        meetingType: meetingType,
        title: title,
        durationMinutes: durationMinutes,
        timezone: timezone,
        location: location,
        notes: notes,
        source: 'manual',
      );
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Appointment created successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> rescheduleAppointment(
    String id,
    DateTime startAt, {
    DateTime? endAt,
    String reason = '',
  }) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.rescheduleAppointment(
        id: id,
        startAt: startAt,
        endAt: endAt,
        reason: reason,
      );
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Appointment rescheduled successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> cancelAppointment(String id, {String reason = ''}) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.cancelAppointment(id: id, reason: reason);
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Appointment cancelled.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> completeAppointment(String id) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.completeAppointment(id);
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Appointment marked as completed.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> markNoShow(String id) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.markNoShow(id);
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Appointment marked as no-show.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  // --- Requests Actions ---

  Future<bool> scheduleRequest({
    required String requestId,
    String? customerEmail,
    required DateTime startAt,
    DateTime? endAt,
    int? durationMinutes,
    String? meetingType,
    String location = '',
    String notes = '',
  }) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.scheduleRequest(
        requestId: requestId,
        customerEmail: customerEmail,
        startAt: startAt,
        endAt: endAt,
        durationMinutes: durationMinutes,
        meetingType: meetingType,
        location: location,
        notes: notes,
      );
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Request confirmed and scheduled as an Appointment.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> cancelRequest(String requestId) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.cancelRequest(requestId);
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Request cancelled.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  // --- Availability & Settings Actions ---

  void toggleRuleEnabled(int weekday, bool enabled) {
    final updated = state.availabilityRules.map((r) {
      if (r.weekday == weekday) {
        return r.copyWith(enabled: enabled);
      }
      return r;
    }).toList();
    emit(state.copyWith(availabilityRules: updated));
  }

  void updateRuleTimeWindow(
    int weekday,
    String startTime,
    String endTime,
    String availabilityType,
  ) {
    final updated = state.availabilityRules.map((r) {
      if (r.weekday == weekday) {
        return r.copyWith(
          startTime: startTime,
          endTime: endTime,
          availabilityType: availabilityType,
          enabled: true,
        );
      }
      return r;
    }).toList();
    emit(state.copyWith(availabilityRules: updated));
  }

  Future<bool> saveAvailabilityAndSettings() async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await Future.wait([
        _repository.updateAvailabilityRules(state.availabilityRules),
        _repository.updateSettings(state.settings),
      ]);
      await refresh();
      emit(state.copyWith(
        isActionLoading: false,
        successMessage: 'Availability and settings saved successfully.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  void updateSettingsLocally(AppointmentSettingsEntity settings) {
    emit(state.copyWith(settings: settings));
  }

  Future<bool> addException({
    required DateTime date,
    required bool isAvailable,
    String? startTime,
    String? endTime,
    String reason = '',
  }) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.createException(
        date: date,
        isAvailable: isAvailable,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
      );
      final exceptions = await _repository.getExceptions();
      emit(state.copyWith(
        exceptions: exceptions,
        isActionLoading: false,
        successMessage: 'Exception added.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> deleteException(int id) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      await _repository.deleteException(id);
      final exceptions = await _repository.getExceptions();
      emit(state.copyWith(
        exceptions: exceptions,
        isActionLoading: false,
        successMessage: 'Exception removed.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  // --- Calendar Integration Actions ---

  Timer? _oauthPollingTimer;

  Future<String?> getGoogleCalendarOAuthUrl() async {
    try {
      return await _repository.getGoogleCalendarOAuthUrl();
    } catch (e) {
      emit(state.copyWith(errorMessage: _extractErrorMessage(e)));
      return null;
    }
  }

  void startOAuthPolling({Duration timeout = const Duration(minutes: 2)}) {
    _oauthPollingTimer?.cancel();
    final startTime = DateTime.now();

    _oauthPollingTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if (DateTime.now().difference(startTime) > timeout) {
        timer.cancel();
        return;
      }

      try {
        final conn = await _repository.getCalendarConnection();
        if (conn.connected) {
          timer.cancel();
          emit(state.copyWith(
            calendarConnection: conn,
            successMessage: 'Google Calendar connected successfully!',
          ));
          await refresh();
        }
      } catch (_) {}
    });
  }

  void stopOAuthPolling() {
    _oauthPollingTimer?.cancel();
    _oauthPollingTimer = null;
  }

  Future<void> refreshCalendarStatus() async {
    try {
      final conn = await _repository.getCalendarConnection();
      emit(state.copyWith(calendarConnection: conn));
      if (conn.connected) {
        await refresh();
      }
    } catch (_) {}
  }

  Future<bool> syncCalendar() async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final conn = await _repository.syncCalendar();
      emit(state.copyWith(
        calendarConnection: conn,
        isActionLoading: false,
        successMessage: 'Calendar synchronized.',
      ));
      await refresh();
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<bool> disconnectCalendar() async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final conn = await _repository.disconnectCalendar();
      emit(state.copyWith(
        calendarConnection: conn,
        appointments: const [],
        calendarAppointments: const [],
        upcomingAppointments: const [],
        requests: const [],
        kpi: const AppointmentKPIStats(),
        isActionLoading: false,
        successMessage: 'Calendar disconnected.',
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isActionLoading: false, errorMessage: _extractErrorMessage(e)));
      return false;
    }
  }

  Future<void> loadAvailableSlots({
    DateTime? preferredDate,
    String? preferredPeriod,
  }) async {
    try {
      final slots = await _repository.getAvailableSlots(
        timezone: state.settings.timezone,
        preferredDate: preferredDate,
        preferredPeriod: preferredPeriod,
        duration: state.settings.defaultDurationMinutes,
      );
      emit(state.copyWith(availableSlots: slots));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    stopOAuthPolling();
    return super.close();
  }
}
