import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_data_source.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource _dataSource;

  const AppointmentsRepositoryImpl(this._dataSource);

  @override
  Future<List<AppointmentEntity>> getAppointments({
    String? status,
    String? meetingType,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final raw = await _dataSource.getAppointments(
      status: status,
      meetingType: meetingType,
      search: search,
      startDate: startDate,
      endDate: endDate,
    );
    return raw.map(_mapAppointment).toList();
  }

  @override
  Future<AppointmentEntity> getAppointment(String id) async {
    final raw = await _dataSource.getAppointment(id);
    return _mapAppointment(raw);
  }

  @override
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
  }) async {
    final body = {
      'customerId': customerId,
      'startAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endAt': endAt.toUtc().toIso8601String(),
      'meetingType': meetingType,
      'title': title,
      'durationMinutes': durationMinutes,
      'timezone': timezone,
      'location': location,
      'notes': notes,
      'source': source,
    };
    final raw = await _dataSource.createAppointment(body);
    return _mapAppointment(raw);
  }

  @override
  Future<AppointmentEntity> rescheduleAppointment({
    required String id,
    required DateTime startAt,
    DateTime? endAt,
    String reason = '',
  }) async {
    final body = {
      'startAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endAt': endAt.toUtc().toIso8601String(),
      'reason': reason,
    };
    final raw = await _dataSource.rescheduleAppointment(id, body);
    return _mapAppointment(raw);
  }

  @override
  Future<AppointmentEntity> cancelAppointment({
    required String id,
    String reason = '',
  }) async {
    final raw = await _dataSource.cancelAppointment(id, {'reason': reason});
    return _mapAppointment(raw);
  }

  @override
  Future<AppointmentEntity> completeAppointment(String id) async {
    final raw = await _dataSource.completeAppointment(id);
    return _mapAppointment(raw);
  }

  @override
  Future<AppointmentEntity> markNoShow(String id) async {
    final raw = await _dataSource.markNoShow(id);
    return _mapAppointment(raw);
  }

  @override
  Future<List<AppointmentEntity>> getUpcomingAppointments() async {
    final raw = await _dataSource.getUpcoming();
    return raw.map(_mapAppointment).toList();
  }

  @override
  Future<List<AppointmentEntity>> getCalendarAppointments({
    required int year,
    required int month,
  }) async {
    final raw = await _dataSource.getCalendar(year, month);
    return raw.map(_mapAppointment).toList();
  }

  @override
  Future<List<AppointmentRequestEntity>> getAppointmentRequests({
    String? status,
    String? search,
  }) async {
    final raw = await _dataSource.getRequests(status: status, search: search);
    return raw.map(_mapRequest).toList();
  }

  @override
  Future<AppointmentEntity> scheduleRequest({
    required String requestId,
    required DateTime startAt,
    DateTime? endAt,
    int? durationMinutes,
    String? meetingType,
    String location = '',
    String notes = '',
  }) async {
    final body = {
      'startAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endAt': endAt.toUtc().toIso8601String(),
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (meetingType != null) 'meetingType': meetingType,
      'location': location,
      'notes': notes,
    };
    final raw = await _dataSource.scheduleRequest(requestId, body);
    return _mapAppointment(raw);
  }

  @override
  Future<AppointmentRequestEntity> cancelRequest(String requestId) async {
    final raw = await _dataSource.cancelRequest(requestId);
    return _mapRequest(raw);
  }

  @override
  Future<List<AvailabilityRuleEntity>> getAvailabilityRules() async {
    final raw = await _dataSource.getAvailabilityRules();
    return raw.map(_mapRule).toList();
  }

  @override
  Future<List<AvailabilityRuleEntity>> updateAvailabilityRules(
    List<AvailabilityRuleEntity> rules,
  ) async {
    final body = rules.map((r) => {
          'id': r.id,
          'weekday': r.weekday,
          'enabled': r.enabled,
          'startTime': r.startTime,
          'endTime': r.endTime,
          'availabilityType': r.availabilityType,
        }).toList();
    final raw = await _dataSource.updateAvailabilityRules(body);
    return raw.map(_mapRule).toList();
  }

  @override
  Future<List<AvailabilityExceptionEntity>> getExceptions() async {
    final raw = await _dataSource.getExceptions();
    return raw.map(_mapException).toList();
  }

  @override
  Future<AvailabilityExceptionEntity> createException({
    required DateTime date,
    required bool isAvailable,
    String? startTime,
    String? endTime,
    String reason = '',
  }) async {
    final body = {
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'isAvailable': isAvailable,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'reason': reason,
    };
    final raw = await _dataSource.createException(body);
    return _mapException(raw);
  }

  @override
  Future<void> deleteException(int id) async {
    await _dataSource.deleteException(id);
  }

  @override
  Future<AppointmentSettingsEntity> getSettings() async {
    final raw = await _dataSource.getSettings();
    return AppointmentSettingsEntity(
      timezone: (raw['timezone'] ?? 'America/Toronto').toString(),
      defaultDurationMinutes: (raw['defaultDurationMinutes'] ?? 45) as int,
      bufferBeforeMinutes: (raw['bufferBeforeMinutes'] ?? 15) as int,
      bufferAfterMinutes: (raw['bufferAfterMinutes'] ?? 15) as int,
      minimumNoticeMinutes: (raw['minimumNoticeMinutes'] ?? 120) as int,
      maximumBookingDaysAhead: (raw['maximumBookingDaysAhead'] ?? 60) as int,
      onlineAutoConfirm: raw['onlineAutoConfirm'] as bool? ?? true,
      inPersonAutoConfirm: raw['inPersonAutoConfirm'] as bool? ?? false,
    );
  }

  @override
  Future<AppointmentSettingsEntity> updateSettings(
    AppointmentSettingsEntity settings,
  ) async {
    final body = {
      'timezone': settings.timezone,
      'defaultDurationMinutes': settings.defaultDurationMinutes,
      'bufferBeforeMinutes': settings.bufferBeforeMinutes,
      'bufferAfterMinutes': settings.bufferAfterMinutes,
      'minimumNoticeMinutes': settings.minimumNoticeMinutes,
      'maximumBookingDaysAhead': settings.maximumBookingDaysAhead,
      'onlineAutoConfirm': settings.onlineAutoConfirm,
      'inPersonAutoConfirm': settings.inPersonAutoConfirm,
    };
    final raw = await _dataSource.updateSettings(body);
    return AppointmentSettingsEntity(
      timezone: (raw['timezone'] ?? settings.timezone).toString(),
      defaultDurationMinutes: (raw['defaultDurationMinutes'] ?? settings.defaultDurationMinutes) as int,
      bufferBeforeMinutes: (raw['bufferBeforeMinutes'] ?? settings.bufferBeforeMinutes) as int,
      bufferAfterMinutes: (raw['bufferAfterMinutes'] ?? settings.bufferAfterMinutes) as int,
      minimumNoticeMinutes: (raw['minimumNoticeMinutes'] ?? settings.minimumNoticeMinutes) as int,
      maximumBookingDaysAhead: (raw['maximumBookingDaysAhead'] ?? settings.maximumBookingDaysAhead) as int,
      onlineAutoConfirm: raw['onlineAutoConfirm'] as bool? ?? settings.onlineAutoConfirm,
      inPersonAutoConfirm: raw['inPersonAutoConfirm'] as bool? ?? settings.inPersonAutoConfirm,
    );
  }

  @override
  Future<CalendarConnectionEntity> getCalendarConnection() async {
    final raw = await _dataSource.getCalendarStatus();
    return CalendarConnectionEntity(
      provider: (raw['provider'] ?? 'google').toString(),
      accountEmail: (raw['accountEmail'] ?? '').toString(),
      calendarId: (raw['calendarId'] ?? 'primary').toString(),
      connected: raw['connected'] as bool? ?? false,
      lastSyncedAt: raw['lastSyncedAt'] != null
          ? DateTime.tryParse(raw['lastSyncedAt'].toString())
          : null,
    );
  }

  @override
  Future<CalendarConnectionEntity> syncCalendar() async {
    final raw = await _dataSource.syncCalendar();
    return CalendarConnectionEntity(
      provider: (raw['provider'] ?? 'google').toString(),
      accountEmail: (raw['account_email'] ?? raw['accountEmail'] ?? '').toString(),
      calendarId: (raw['calendar_id'] ?? raw['calendarId'] ?? 'primary').toString(),
      connected: raw['connected'] as bool? ?? true,
      lastSyncedAt: raw['last_synced_at'] != null
          ? DateTime.tryParse(raw['last_synced_at'].toString())
          : null,
    );
  }

  @override
  Future<CalendarConnectionEntity> disconnectCalendar() async {
    final raw = await _dataSource.disconnectCalendar();
    return CalendarConnectionEntity(
      provider: 'google',
      accountEmail: '',
      calendarId: 'primary',
      connected: raw['connected'] as bool? ?? false,
    );
  }

  @override
  Future<List<AvailableSlotEntity>> getAvailableSlots({
    String timezone = 'America/Toronto',
    String meetingType = 'online',
    DateTime? preferredDate,
    String? preferredPeriod,
    int duration = 45,
    int daysAhead = 14,
    int limit = 8,
  }) async {
    final body = {
      'timezone': timezone,
      'meetingType': meetingType,
      if (preferredDate != null)
        'preferredDate':
            '${preferredDate.year}-${preferredDate.month.toString().padLeft(2, '0')}-${preferredDate.day.toString().padLeft(2, '0')}',
      if (preferredPeriod != null) 'preferredPeriod': preferredPeriod,
      'duration': duration,
      'daysAhead': daysAhead,
      'limit': limit,
    };
    final raw = await _dataSource.getAvailableSlots(body);
    return raw.map((s) {
      return AvailableSlotEntity(
        startAt: DateTime.parse(s['start_at'].toString()),
        endAt: DateTime.parse(s['end_at'].toString()),
        localStart: (s['local_start'] ?? '').toString(),
        localEnd: (s['local_end'] ?? '').toString(),
        timezone: (s['timezone'] ?? 'America/Toronto').toString(),
        weekday: (s['weekday'] ?? 0) as int,
        weekdayName: (s['weekday_name'] ?? '').toString(),
        dateStr: (s['date_str'] ?? '').toString(),
        availabilityType: (s['availability_type'] ?? 'available').toString(),
        score: (s['score'] ?? 0) as int,
      );
    }).toList();
  }

  AppointmentEntity _mapAppointment(Map<String, dynamic> raw) {
    final cust = raw['customer'] as Map? ?? {};
    return AppointmentEntity(
      id: raw['id'].toString(),
      title: (raw['title'] ?? 'Discovery Consultation').toString(),
      customerId: (cust['id'] ?? 0) as int,
      customerName: (cust['fullName'] ?? cust['name'] ?? 'Customer').toString(),
      companyName: (cust['companyName'] ?? '').toString(),
      customerPhone: (cust['phone'] ?? '').toString(),
      customerEmail: (cust['email'] ?? '').toString(),
      meetingType: (raw['meetingType'] ?? 'online').toString(),
      status: (raw['status'] ?? 'confirmed').toString(),
      startAt: DateTime.parse(raw['startAt'].toString()),
      endAt: DateTime.parse(raw['endAt'].toString()),
      timezone: (raw['timezone'] ?? 'America/Toronto').toString(),
      durationMinutes: (raw['durationMinutes'] ?? 45) as int,
      meetingProvider: (raw['meetingProvider'] ?? 'google_meet').toString(),
      meetingUrl: raw['meetingUrl']?.toString(),
      location: raw['location']?.toString(),
      notes: raw['notes']?.toString(),
      calendarEventId: raw['calendarEventId']?.toString(),
      source: (raw['source'] ?? 'ai_call').toString(),
      sourceCallId: raw['sourceCallId']?.toString(),
      appointmentRequestId: raw['appointmentRequestId']?.toString(),
      confirmedAt: raw['confirmedAt'] != null ? DateTime.tryParse(raw['confirmedAt'].toString()) : null,
      cancelledAt: raw['cancelledAt'] != null ? DateTime.tryParse(raw['cancelledAt'].toString()) : null,
    );
  }

  AppointmentRequestEntity _mapRequest(Map<String, dynamic> raw) {
    final cust = raw['customer'] as Map? ?? {};
    return AppointmentRequestEntity(
      id: raw['id'].toString(),
      customerId: (cust['id'] ?? 0) as int,
      customerName: (cust['fullName'] ?? cust['name'] ?? 'Lead').toString(),
      companyName: (cust['companyName'] ?? '').toString(),
      customerPhone: (cust['phone'] ?? '').toString(),
      customerEmail: (cust['email'] ?? '').toString(),
      meetingType: (raw['meetingType'] ?? 'online').toString(),
      preferredDate: raw['preferredDate'] != null ? DateTime.tryParse(raw['preferredDate'].toString()) : null,
      preferredStartTime: raw['preferredStartTime']?.toString(),
      preferredEndTime: raw['preferredEndTime']?.toString(),
      preferredPeriod: (raw['preferredPeriod'] ?? 'anytime').toString(),
      timezone: (raw['timezone'] ?? 'America/Toronto').toString(),
      location: raw['location']?.toString(),
      notes: raw['notes']?.toString(),
      status: (raw['status'] ?? 'pending').toString(),
      sourceCallId: raw['sourceCallId']?.toString(),
      createdAt: raw['createdAt'] != null ? DateTime.parse(raw['createdAt'].toString()) : DateTime.now(),
    );
  }

  AvailabilityRuleEntity _mapRule(Map<String, dynamic> raw) {
    return AvailabilityRuleEntity(
      id: (raw['id'] ?? 0) as int,
      weekday: (raw['weekday'] ?? 0) as int,
      enabled: raw['enabled'] as bool? ?? true,
      startTime: (raw['startTime'] ?? '09:00').toString(),
      endTime: (raw['endTime'] ?? '18:00').toString(),
      availabilityType: (raw['availabilityType'] ?? 'available').toString(),
    );
  }

  AvailabilityExceptionEntity _mapException(Map<String, dynamic> raw) {
    return AvailabilityExceptionEntity(
      id: (raw['id'] ?? 0) as int,
      date: DateTime.parse(raw['date'].toString()),
      isAvailable: raw['isAvailable'] as bool? ?? false,
      startTime: raw['startTime']?.toString(),
      endTime: raw['endTime']?.toString(),
      reason: (raw['reason'] ?? '').toString(),
    );
  }
}
