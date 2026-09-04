import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String title;
  final int customerId;
  final String customerName;
  final String companyName;
  final String customerPhone;
  final String customerEmail;
  final String meetingType; // 'online' or 'in_person'
  final String status; // 'confirmed', 'pending', 'completed', 'cancelled', 'rescheduled', 'no_show'
  final DateTime startAt;
  final DateTime endAt;
  final String timezone;
  final int durationMinutes;
  final String meetingProvider; // 'google_meet', 'microsoft_teams', 'none'
  final String? meetingUrl;
  final String? location;
  final String? notes;
  final String? calendarEventId;
  final String source; // 'ai_call', 'manual', 'email', 'other'
  final String? sourceCallId;
  final String? appointmentRequestId;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  const AppointmentEntity({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.customerPhone,
    required this.customerEmail,
    required this.meetingType,
    required this.status,
    required this.startAt,
    required this.endAt,
    this.timezone = 'America/Toronto',
    this.durationMinutes = 45,
    this.meetingProvider = 'google_meet',
    this.meetingUrl,
    this.location,
    this.notes,
    this.calendarEventId,
    this.source = 'ai_call',
    this.sourceCallId,
    this.appointmentRequestId,
    this.confirmedAt,
    this.cancelledAt,
  });

  bool get isOnline => meetingType.toLowerCase() == 'online';
  bool get isInPerson => meetingType.toLowerCase() == 'in_person';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isUpcoming {
    final now = DateTime.now();
    return endAt.isAfter(now) && (isConfirmed || isPending);
  }

  bool get isToday {
    final now = DateTime.now();
    final localStart = startAt.toLocal();
    return localStart.year == now.year &&
        localStart.month == now.month &&
        localStart.day == now.day;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        customerId,
        meetingType,
        status,
        startAt,
        endAt,
        meetingUrl,
        location,
      ];
}

class AppointmentRequestEntity extends Equatable {
  final String id;
  final int customerId;
  final String customerName;
  final String companyName;
  final String customerPhone;
  final String customerEmail;
  final String meetingType;
  final DateTime? preferredDate;
  final String? preferredStartTime;
  final String? preferredEndTime;
  final String preferredPeriod; // 'morning', 'afternoon', 'evening', 'anytime', 'custom'
  final String timezone;
  final String? location;
  final String? notes;
  final String status; // 'pending', 'scheduled', 'closed', 'cancelled'
  final String? sourceCallId;
  final DateTime createdAt;

  const AppointmentRequestEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.customerPhone,
    required this.customerEmail,
    required this.meetingType,
    this.preferredDate,
    this.preferredStartTime,
    this.preferredEndTime,
    this.preferredPeriod = 'anytime',
    this.timezone = 'America/Toronto',
    this.location,
    this.notes,
    this.status = 'pending',
    this.sourceCallId,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isOnline => meetingType.toLowerCase() == 'online';
  bool get isInPerson => meetingType.toLowerCase() == 'in_person';

  String get preferredDateLabel {
    if (preferredDate != null) {
      final d = preferredDate!;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return 'Flexible (${preferredPeriod.toUpperCase()})';
  }

  String get preferredTimeLabel {
    if (preferredStartTime != null && preferredEndTime != null) {
      return '$preferredStartTime - $preferredEndTime';
    }
    return preferredPeriod.toUpperCase();
  }

  String get preferredDisplay {
    if (notes != null && notes!.isNotEmpty) return notes!;
    if (preferredDate != null) {
      final d = preferredDate!;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} (${preferredPeriod.toUpperCase()})';
    }
    return preferredPeriod.toUpperCase();
  }

  @override
  List<Object?> get props => [id, customerId, status, createdAt];
}

class AvailabilityRuleEntity extends Equatable {
  final int id;
  final int weekday; // 0=Mon, 1=Tue, ..., 6=Sun
  final bool enabled;
  final String startTime; // "18:00"
  final String endTime; // "21:00"
  final String availabilityType; // 'available', 'preferred', 'manual_approval'

  const AvailabilityRuleEntity({
    required this.id,
    required this.weekday,
    required this.enabled,
    required this.startTime,
    required this.endTime,
    this.availabilityType = 'available',
  });

  String get weekdayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    if (weekday >= 0 && weekday < days.length) return days[weekday];
    return 'Day $weekday';
  }

  String get formattedDisplay {
    if (!enabled) return 'Unavailable';
    if (availabilityType == 'manual_approval') return 'Manual approval';
    return '$startTime – $endTime';
  }

  AvailabilityRuleEntity copyWith({
    int? id,
    int? weekday,
    bool? enabled,
    String? startTime,
    String? endTime,
    String? availabilityType,
  }) {
    return AvailabilityRuleEntity(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      availabilityType: availabilityType ?? this.availabilityType,
    );
  }

  @override
  List<Object?> get props => [id, weekday, enabled, startTime, endTime, availabilityType];
}

class AvailabilityExceptionEntity extends Equatable {
  final int id;
  final DateTime date;
  final bool isAvailable;
  final String? startTime;
  final String? endTime;
  final String reason;

  const AvailabilityExceptionEntity({
    required this.id,
    required this.date,
    required this.isAvailable,
    this.startTime,
    this.endTime,
    this.reason = '',
  });

  String get formattedDisplay {
    if (isAvailable && startTime != null && endTime != null) {
      return '$startTime – $endTime';
    }
    return reason.isNotEmpty ? reason : (isAvailable ? 'Available' : 'Unavailable');
  }

  @override
  List<Object?> get props => [id, date, isAvailable, startTime, endTime, reason];
}

class AppointmentSettingsEntity extends Equatable {
  final String timezone;
  final int defaultDurationMinutes;
  final int bufferBeforeMinutes;
  final int bufferAfterMinutes;
  final int minimumNoticeMinutes;
  final int maximumBookingDaysAhead;
  final bool onlineAutoConfirm;
  final bool inPersonAutoConfirm;

  const AppointmentSettingsEntity({
    this.timezone = 'America/Toronto',
    this.defaultDurationMinutes = 45,
    this.bufferBeforeMinutes = 15,
    this.bufferAfterMinutes = 15,
    this.minimumNoticeMinutes = 120,
    this.maximumBookingDaysAhead = 60,
    this.onlineAutoConfirm = true,
    this.inPersonAutoConfirm = false,
  });

  AppointmentSettingsEntity copyWith({
    String? timezone,
    int? defaultDurationMinutes,
    int? bufferBeforeMinutes,
    int? bufferAfterMinutes,
    int? minimumNoticeMinutes,
    int? maximumBookingDaysAhead,
    bool? onlineAutoConfirm,
    bool? inPersonAutoConfirm,
  }) {
    return AppointmentSettingsEntity(
      timezone: timezone ?? this.timezone,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      bufferBeforeMinutes: bufferBeforeMinutes ?? this.bufferBeforeMinutes,
      bufferAfterMinutes: bufferAfterMinutes ?? this.bufferAfterMinutes,
      minimumNoticeMinutes:
          minimumNoticeMinutes ?? this.minimumNoticeMinutes,
      maximumBookingDaysAhead:
          maximumBookingDaysAhead ?? this.maximumBookingDaysAhead,
      onlineAutoConfirm: onlineAutoConfirm ?? this.onlineAutoConfirm,
      inPersonAutoConfirm: inPersonAutoConfirm ?? this.inPersonAutoConfirm,
    );
  }

  @override
  List<Object?> get props => [
        timezone,
        defaultDurationMinutes,
        bufferBeforeMinutes,
        bufferAfterMinutes,
        minimumNoticeMinutes,
        maximumBookingDaysAhead,
        onlineAutoConfirm,
        inPersonAutoConfirm,
      ];
}

class CalendarConnectionEntity extends Equatable {
  final String provider;
  final String accountEmail;
  final String calendarId;
  final bool connected;
  final DateTime? lastSyncedAt;

  const CalendarConnectionEntity({
    this.provider = 'google',
    this.accountEmail = '',
    this.calendarId = 'primary',
    this.connected = false,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [provider, accountEmail, calendarId, connected, lastSyncedAt];
}

class AvailableSlotEntity extends Equatable {
  final DateTime startAt;
  final DateTime endAt;
  final String localStart;
  final String localEnd;
  final String timezone;
  final int weekday;
  final String weekdayName;
  final String dateStr;
  final String availabilityType;
  final int score;

  const AvailableSlotEntity({
    required this.startAt,
    required this.endAt,
    required this.localStart,
    required this.localEnd,
    required this.timezone,
    required this.weekday,
    required this.weekdayName,
    required this.dateStr,
    required this.availabilityType,
    required this.score,
  });

  @override
  List<Object?> get props => [startAt, endAt, score];
}

class AppointmentKPIStats extends Equatable {
  final int totalAppointments;
  final int confirmedAppointments;
  final int pendingRequests;
  final int upcomingThisWeek;
  final int completedAppointments;

  const AppointmentKPIStats({
    this.totalAppointments = 0,
    this.confirmedAppointments = 0,
    this.pendingRequests = 0,
    this.upcomingThisWeek = 0,
    this.completedAppointments = 0,
  });

  factory AppointmentKPIStats.fromJson(Map<String, dynamic> json) {
    return AppointmentKPIStats(
      totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
      confirmedAppointments:
          (json['confirmedAppointments'] as num?)?.toInt() ?? 0,
      pendingRequests: (json['pendingRequests'] as num?)?.toInt() ?? 0,
      upcomingThisWeek: (json['upcomingThisWeek'] as num?)?.toInt() ?? 0,
      completedAppointments:
          (json['completedAppointments'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalAppointments': totalAppointments,
        'confirmedAppointments': confirmedAppointments,
        'pendingRequests': pendingRequests,
        'upcomingThisWeek': upcomingThisWeek,
        'completedAppointments': completedAppointments,
      };

  @override
  List<Object?> get props => [
        totalAppointments,
        confirmedAppointments,
        pendingRequests,
        upcomingThisWeek,
        completedAppointments,
      ];
}
