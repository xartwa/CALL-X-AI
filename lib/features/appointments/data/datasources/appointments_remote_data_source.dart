import 'package:callx_ai/services/api_provider.dart';

class AppointmentsRemoteDataSource {
  final DioClient _client;

  const AppointmentsRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getAppointments({
    String? status,
    String? meetingType,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status != 'All') query['status'] = status;
    if (meetingType != null && meetingType != 'All') {
      query['meeting_type'] = meetingType.toLowerCase();
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (startDate != null) query['start_date'] = startDate;
    if (endDate != null) query['end_date'] = endDate;

    final response = await _client.http.get(
      '/appointments/',
      queryParameters: query.isEmpty ? null : query,
    );

    return _toList(response.data);
  }

  Future<Map<String, dynamic>> getAppointment(String id) async {
    final response = await _client.http.get('/appointments/$id/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> body) async {
    final response = await _client.http.post('/appointments/', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> rescheduleAppointment(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.http.post(
      '/appointments/$id/reschedule/',
      data: body,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> cancelAppointment(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.http.post(
      '/appointments/$id/cancel/',
      data: body,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> completeAppointment(String id) async {
    final response = await _client.http.post('/appointments/$id/complete/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> markNoShow(String id) async {
    final response = await _client.http.post('/appointments/$id/no-show/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getUpcoming() async {
    final response = await _client.http.get('/appointments/upcoming/');
    return _toList(response.data);
  }

  Future<List<Map<String, dynamic>>> getCalendar(int year, int month) async {
    final response = await _client.http.get(
      '/appointments/calendar/',
      queryParameters: {'year': year, 'month': month},
    );
    return _toList(response.data);
  }

  // Appointment Requests
  Future<List<Map<String, dynamic>>> getRequests({
    String? status,
    String? search,
  }) async {
    final query = <String, dynamic>{};
    if (status != null && status != 'All') query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _client.http.get(
      '/appointment-requests/',
      queryParameters: query.isEmpty ? null : query,
    );
    return _toList(response.data);
  }

  Future<Map<String, dynamic>> scheduleRequest(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.http.post(
      '/appointment-requests/$id/schedule/',
      data: body,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> cancelRequest(String id) async {
    final response = await _client.http.post('/appointment-requests/$id/cancel/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  // Availability & Settings
  Future<List<Map<String, dynamic>>> getAvailabilityRules() async {
    final response = await _client.http.get('/availability/');
    return _toList(response.data);
  }

  Future<List<Map<String, dynamic>>> updateAvailabilityRules(
    List<Map<String, dynamic>> body,
  ) async {
    final response = await _client.http.put('/availability/', data: body);
    return _toList(response.data);
  }

  Future<List<Map<String, dynamic>>> getExceptions() async {
    final response = await _client.http.get('/availability/exceptions/');
    return _toList(response.data);
  }

  Future<Map<String, dynamic>> createException(Map<String, dynamic> body) async {
    final response = await _client.http.post('/availability/exceptions/', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteException(int id) async {
    await _client.http.delete('/availability/exceptions/$id/');
  }

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _client.http.get('/appointment-settings/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getKPIStats() async {
    final response = await _client.http.get('/appointments/kpi/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> body) async {
    final response = await _client.http.patch('/appointment-settings/', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  // Calendar
  Future<Map<String, dynamic>> getCalendarStatus() async {
    final response = await _client.http.get('/calendar/status/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> syncCalendar() async {
    final response = await _client.http.post('/calendar/sync/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> disconnectCalendar() async {
    final response = await _client.http.post('/calendar/disconnect/');
    return Map<String, dynamic>.from(response.data as Map);
  }

  // Slots Engine
  Future<List<Map<String, dynamic>>> getAvailableSlots(
    Map<String, dynamic> body,
  ) async {
    final response = await _client.http.post('/availability/slots/', data: body);
    return _toList(response.data);
  }

  List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }
}
