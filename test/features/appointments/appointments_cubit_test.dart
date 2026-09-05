import 'package:flutter_test/flutter_test.dart';
import 'package:callx_ai/features/appointments/cubit/appointments_cubit.dart';
import 'package:callx_ai/features/appointments/cubit/appointments_state.dart';
import 'package:callx_ai/features/appointments/domain/entities/appointment_entity.dart';
import 'package:callx_ai/features/appointments/domain/repositories/appointments_repository.dart';

class _FakeAppointmentsRepository implements AppointmentsRepository {
  List<AppointmentEntity> appts = [];
  List<AppointmentRequestEntity> reqs = [];
  List<AvailabilityRuleEntity> rules = [
    const AvailabilityRuleEntity(id: 1, weekday: 0, enabled: true, startTime: '09:00:00', endTime: '18:00:00'),
    const AvailabilityRuleEntity(id: 2, weekday: 1, enabled: true, startTime: '09:00:00', endTime: '18:00:00'),
  ];
  List<AvailabilityExceptionEntity> exList = [];
  AppointmentSettingsEntity st = const AppointmentSettingsEntity();
  CalendarConnectionEntity conn = const CalendarConnectionEntity(connected: true, accountEmail: 'admin@callx.ai');

  @override
  Future<List<AppointmentEntity>> getAppointments({
    String? status,
    String? meetingType,
    String? search,
    String? startDate,
    String? endDate,
  }) async => appts;

  @override
  Future<List<AppointmentEntity>> getUpcomingAppointments() async => appts;

  @override
  Future<List<AppointmentEntity>> getCalendarAppointments({required int year, required int month}) async => appts;

  @override
  Future<AppointmentKPIStats> getKPIStats() async => const AppointmentKPIStats();

  @override
  Future<AppointmentEntity> getAppointment(String id) async => appts.first;

  @override
  Future<AppointmentEntity> createAppointment({
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
    String source = 'manual',
  }) async {
    final a = AppointmentEntity(
      id: 'new-appt-id',
      customerId: customerId,
      customerName: 'Test Client',
      companyName: 'Client Corp',
      customerPhone: '1234567890',
      customerEmail: customerEmail ?? 'test@client.com',
      meetingType: meetingType,
      status: 'confirmed',
      startAt: startAt,
      endAt: endAt ?? startAt.add(Duration(minutes: durationMinutes)),
      durationMinutes: durationMinutes,
      timezone: timezone,
      title: title,
    );
    appts.add(a);
    return a;
  }

  @override
  Future<AppointmentEntity> rescheduleAppointment({required String id, required DateTime startAt, DateTime? endAt, String reason = ''}) async => appts.first;

  @override
  Future<AppointmentEntity> cancelAppointment({required String id, String reason = ''}) async => appts.first;

  @override
  Future<AppointmentEntity> completeAppointment(String id) async => appts.first;

  @override
  Future<AppointmentEntity> markNoShow(String id) async => appts.first;

  @override
  Future<List<AppointmentRequestEntity>> getAppointmentRequests({String? status, String? search}) async => reqs;

  @override
  Future<AppointmentEntity> scheduleRequest({
    required String requestId,
    String? customerEmail,
    required DateTime startAt,
    DateTime? endAt,
    int? durationMinutes,
    String? meetingType,
    String location = '',
    String notes = '',
  }) async {
    final a = AppointmentEntity(
      id: 'scheduled-appt-id',
      customerId: 1,
      customerName: 'Requested Client',
      companyName: 'Requested Corp',
      customerPhone: '1234567890',
      customerEmail: customerEmail ?? 'req@client.com',
      meetingType: meetingType ?? 'online',
      status: 'confirmed',
      startAt: startAt,
      endAt: endAt ?? startAt.add(Duration(minutes: durationMinutes ?? 45)),
      durationMinutes: durationMinutes ?? 45,
      timezone: 'America/Toronto',
      title: 'Scheduled Consultation',
    );
    appts.add(a);
    reqs.removeWhere((r) => r.id == requestId);
    return a;
  }

  @override
  Future<AppointmentRequestEntity> cancelRequest(String requestId) async {
    final r = reqs.firstWhere((e) => e.id == requestId);
    return r;
  }

  @override
  Future<List<AvailabilityRuleEntity>> getAvailabilityRules() async => rules;

  @override
  Future<List<AvailabilityRuleEntity>> updateAvailabilityRules(List<AvailabilityRuleEntity> newRules) async {
    rules = newRules;
    return rules;
  }

  @override
  Future<List<AvailabilityExceptionEntity>> getExceptions() async => exList;

  @override
  Future<AvailabilityExceptionEntity> createException({
    required DateTime date,
    required bool isAvailable,
    String? startTime,
    String? endTime,
    String reason = '',
  }) async {
    final ex = AvailabilityExceptionEntity(
      id: exList.length + 1,
      date: date,
      isAvailable: isAvailable,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
    );
    exList.add(ex);
    return ex;
  }

  @override
  Future<void> deleteException(int id) async {
    exList.removeWhere((e) => e.id == id);
  }

  @override
  Future<AppointmentSettingsEntity> getSettings() async => st;

  @override
  Future<AppointmentSettingsEntity> updateSettings(AppointmentSettingsEntity settings) async {
    st = settings;
    return st;
  }

  @override
  Future<CalendarConnectionEntity> getCalendarConnection() async => conn;

  @override
  Future<CalendarConnectionEntity> syncCalendar() async => conn;

  @override
  Future<CalendarConnectionEntity> disconnectCalendar() async => const CalendarConnectionEntity(connected: false);

  @override
  Future<List<AvailableSlotEntity>> getAvailableSlots({
    String timezone = 'America/Toronto',
    String meetingType = 'online',
    DateTime? preferredDate,
    String? preferredPeriod,
    int duration = 45,
    int daysAhead = 14,
    int limit = 8,
  }) async => [];
}

void main() {
  group('AppointmentsState Unit Tests', () {
    test('initial state has correct default values', () {
      final state = AppointmentsState.initial();
      expect(state.activeTab, 0);
      expect(state.calendarViewMode, CalendarViewMode.week);
      expect(state.selectedStatusFilter, 'All');
      expect(state.currentWeekDays.length, 7);
      expect(state.pendingRequestsCount, 0);
    });

    test('currentWeekDays starts on Sunday and spans 7 consecutive days', () {
      final state = AppointmentsState(selectedDate: DateTime(2026, 9, 8)); // Tuesday Sep 8, 2026
      final days = state.currentWeekDays;
      expect(days.length, 7);
      expect(days.first.weekday, DateTime.sunday); // Sunday Sep 6
      expect(days.last.weekday, DateTime.saturday); // Saturday Sep 12
    });

    test('pendingRequestsCount correctly tallies pending requests', () {
      final req1 = AppointmentRequestEntity(
        id: 'r1',
        customerId: 1,
        customerName: 'Alice',
        companyName: 'Acme',
        customerPhone: '111',
        customerEmail: 'a@acme.com',
        meetingType: 'online',
        status: 'pending',
        createdAt: DateTime.now(),
      );
      final req2 = AppointmentRequestEntity(
        id: 'r2',
        customerId: 2,
        customerName: 'Bob',
        companyName: 'Beta',
        customerPhone: '222',
        customerEmail: 'b@beta.com',
        meetingType: 'in_person',
        status: 'scheduled',
        createdAt: DateTime.now(),
      );

      final state = AppointmentsState(
        selectedDate: DateTime.now(),
        requests: [req1, req2],
      );

      expect(state.pendingRequestsCount, 1);
      expect(state.filteredRequests.length, 2);
    });
  });

  group('AppointmentsCubit Flow Tests', () {
    late _FakeAppointmentsRepository repo;
    late AppointmentsCubit cubit;

    setUp(() {
      repo = _FakeAppointmentsRepository();
      cubit = AppointmentsCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadInitial loads appointments, rules, settings, and connection', () async {
      await cubit.loadInitial();
      expect(cubit.state.status, AppointmentsStatus.success);
      expect(cubit.state.availabilityRules.length, 2);
      expect(cubit.state.calendarConnection.connected, true);
    });

    test('setActiveTab updates active tab index', () {
      cubit.setActiveTab(1);
      expect(cubit.state.activeTab, 1);
      cubit.setActiveTab(2);
      expect(cubit.state.activeTab, 2);
    });

    test('toggleRuleEnabled updates weekday rule locally', () async {
      await cubit.loadInitial();
      expect(cubit.state.availabilityRules.first.enabled, true);

      cubit.toggleRuleEnabled(0, false);
      expect(cubit.state.availabilityRules.first.enabled, false);
    });

    test('createAppointment adds new appointment and refreshes state with customerEmail', () async {
      await cubit.loadInitial();
      final ok = await cubit.createAppointment(
        customerId: 42,
        customerEmail: 'custom@client.com',
        startAt: DateTime(2026, 9, 10, 14, 0),
        durationMinutes: 45,
        title: 'Strategy Session',
      );

      expect(ok, true);
      expect(cubit.state.appointments.length, 1);
      expect(cubit.state.appointments.first.title, 'Strategy Session');
      expect(cubit.state.appointments.first.customerEmail, 'custom@client.com');
    });

    test('scheduleRequest converts request to appointment with customerEmail', () async {
      await cubit.loadInitial();
      final ok = await cubit.scheduleRequest(
        requestId: 'req-1',
        customerEmail: 'custom_req@client.com',
        startAt: DateTime(2026, 9, 11, 10, 0),
        durationMinutes: 45,
      );

      expect(ok, true);
      expect(cubit.state.appointments.length, 1);
      expect(cubit.state.appointments.first.customerEmail, 'custom_req@client.com');
    });

    test('addException and deleteException update exceptions state', () async {
      await cubit.loadInitial();
      final ok = await cubit.addException(
        date: DateTime(2026, 9, 25),
        isAvailable: false,
        reason: 'Company Offsite',
      );

      expect(ok, true);
      expect(cubit.state.exceptions.length, 1);
      expect(cubit.state.exceptions.first.reason, 'Company Offsite');

      await cubit.deleteException(cubit.state.exceptions.first.id);
      expect(cubit.state.exceptions.isEmpty, true);
    });
  });
}
