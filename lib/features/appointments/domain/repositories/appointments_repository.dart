import '../entities/appointment_entity.dart';

abstract class AppointmentsRepository {
  Future<List<AppointmentEntity>> getAppointments({
    String? status,
    String? meetingType,
    String? search,
    String? startDate,
    String? endDate,
  });

  Future<AppointmentEntity> getAppointment(String id);

  Future<AppointmentEntity> createAppointment({
    required int customerId,
    required DateTime startAt,
    DateTime? endAt,
    String meetingType = 'online',
    String title = 'Discovery Consultation',
    int durationMinutes = 45,
    String timezone = 'America/Toronto',
    String location = '',
    String notes = '',
    String source = 'manual',
  });

  Future<AppointmentEntity> rescheduleAppointment({
    required String id,
    required DateTime startAt,
    DateTime? endAt,
    String reason = '',
  });

  Future<AppointmentEntity> cancelAppointment({
    required String id,
    String reason = '',
  });

  Future<AppointmentEntity> completeAppointment(String id);

  Future<AppointmentEntity> markNoShow(String id);

  Future<List<AppointmentEntity>> getUpcomingAppointments();

  Future<List<AppointmentEntity>> getCalendarAppointments({
    required int year,
    required int month,
  });

  // Appointment Requests
  Future<List<AppointmentRequestEntity>> getAppointmentRequests({
    String? status,
    String? search,
  });

  Future<AppointmentEntity> scheduleRequest({
    required String requestId,
    required DateTime startAt,
    DateTime? endAt,
    int? durationMinutes,
    String? meetingType,
    String location = '',
    String notes = '',
  });

  Future<AppointmentRequestEntity> cancelRequest(String requestId);

  // Availability & Settings
  Future<List<AvailabilityRuleEntity>> getAvailabilityRules();

  Future<List<AvailabilityRuleEntity>> updateAvailabilityRules(
    List<AvailabilityRuleEntity> rules,
  );

  Future<List<AvailabilityExceptionEntity>> getExceptions();

  Future<AvailabilityExceptionEntity> createException({
    required DateTime date,
    required bool isAvailable,
    String? startTime,
    String? endTime,
    String reason = '',
  });

  Future<void> deleteException(int id);

  Future<AppointmentSettingsEntity> getSettings();

  Future<AppointmentSettingsEntity> updateSettings(
    AppointmentSettingsEntity settings,
  );

  // Calendar Integration
  Future<CalendarConnectionEntity> getCalendarConnection();

  Future<CalendarConnectionEntity> syncCalendar();

  Future<CalendarConnectionEntity> disconnectCalendar();

  // Slots Engine
  Future<List<AvailableSlotEntity>> getAvailableSlots({
    String timezone = 'America/Toronto',
    String meetingType = 'online',
    DateTime? preferredDate,
    String? preferredPeriod,
    int duration = 45,
    int daysAhead = 14,
    int limit = 8,
  });
}
