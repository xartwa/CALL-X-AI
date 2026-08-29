class Customer {
  Customer({
    required Object id,
    required this.fullName,
    String phoneNumber = '',
    String? phone,
    this.companyName = '',
    this.email = '',
    this.jobTitle = '',
    this.website = '',
    String streetAddress = '',
    String? address,
    this.city = '',
    String provinceState = '',
    String? state,
    this.country = '',
    this.companyType = 'General',
    this.leadStatus = 'New',
    this.leadQuality = 'Good',
    this.leadPriority = 'Warm',
    Object? nextFollowUpDate,
    Object? lastContact,
    this.lastContactResult = 'Interested',
    this.reasonForContact = '',
    this.status = 'Active',
    this.tags = const [],
    this.notesCount = 0,
    this.documentsCount = 0,
    Object? createdAt,
    Object? updatedAt,
    this.notesList = const [],
    this.documents = const [],
    this.callLogs = const [],
    this.notes = '',
  })  : id = id.toString(),
        phoneNumber = phoneNumber != '' ? phoneNumber : phone ?? '',
        streetAddress = streetAddress != '' ? streetAddress : address ?? '',
        provinceState = provinceState != '' ? provinceState : state ?? '',
        nextFollowUpDate = _date(nextFollowUpDate),
        lastContact = _date(lastContact),
        createdAt = _date(createdAt),
        updatedAt = _date(updatedAt);

  final String id;
  final String fullName;
  final String phoneNumber;
  final String companyName;
  final String email;
  final String jobTitle;
  final String website;
  final String streetAddress;
  final String city;
  final String provinceState;
  final String country;
  final String companyType;
  final String leadStatus;
  final String leadQuality;
  final String leadPriority;
  final DateTime? nextFollowUpDate;
  final DateTime? lastContact;
  final String lastContactResult;
  final String reasonForContact;
  final String status;
  final List<String> tags;
  final int notesCount;
  final int documentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CustomerNote> notesList;
  final List<CustomerDocument> documents;
  final List<CustomerCallHistory> callLogs;
  final String notes;

  String get phone => phoneNumber;
  String get address => streetAddress;
  String get state => provinceState;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] ?? '',
        fullName: '${json['fullName'] ?? ''}',
        phoneNumber: '${json['phoneNumber'] ?? ''}',
        companyName: '${json['companyName'] ?? ''}',
        email: '${json['email'] ?? ''}',
        jobTitle: '${json['jobTitle'] ?? ''}',
        website: '${json['website'] ?? ''}',
        streetAddress: '${json['streetAddress'] ?? ''}',
        city: '${json['city'] ?? ''}',
        provinceState: '${json['provinceState'] ?? ''}',
        country: '${json['country'] ?? ''}',
        companyType: '${json['companyType'] ?? 'General'}',
        leadStatus: '${json['leadStatus'] ?? 'New'}',
        leadQuality: '${json['leadQuality'] ?? 'Good'}',
        leadPriority: '${json['leadPriority'] ?? 'Warm'}',
        nextFollowUpDate: _date(json['nextFollowUpDate']),
        lastContact: _date(json['lastContact']),
        lastContactResult: '${json['lastContactResult'] ?? 'Interested'}',
        reasonForContact: '${json['reasonForContact'] ?? ''}',
        status: '${json['status'] ?? 'Active'}',
        tags: _stringList(json['tags']),
        notesCount: _intValue(json['notesCount']),
        documentsCount: _intValue(json['documentsCount']),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
        notesList: _notes(json['notesList']),
        documents: _documents(json['documents']),
        callLogs: _calls(json['callLogs']),
      );

  Map<String, dynamic> toApiJson() {
    final Map<String, dynamic> data = {
      // Primary fields in both camelCase and snake_case for Django backend compatibility
      'fullName': fullName,
      'full_name': fullName,
      'name': fullName,
      'phoneNumber': phoneNumber,
      'phone_number': phoneNumber,
      'phone': phoneNumber,
      'companyName': companyName,
      'company_name': companyName,
      'jobTitle': jobTitle,
      'job_title': jobTitle,
      'streetAddress': streetAddress,
      'street_address': streetAddress,
      'address': streetAddress,
      'city': city,
      'provinceState': provinceState,
      'province_state': provinceState,
      'state': provinceState,
      'country': country,
      'companyType': companyType,
      'company_type': companyType,
      'leadStatus': leadStatus,
      'lead_status': leadStatus,
      'leadQuality': leadQuality,
      'lead_quality': leadQuality,
      'leadPriority': leadPriority,
      'lead_priority': leadPriority,
      'status': status == 'Inactive' ? 'Deactive' : status,
      'reasonForContact': reasonForContact,
      'reason_for_contact': reasonForContact,
    };

    if (tags.isNotEmpty) {
      data['tags'] = tags;
    }

    if (email.trim().isNotEmpty) {
      data['email'] = email.trim();
    }
    if (website.trim().isNotEmpty) {
      data['website'] = website.trim();
    }

    if (nextFollowUpDate != null) {
      final formattedDate =
          '${nextFollowUpDate!.year}-${nextFollowUpDate!.month.toString().padLeft(2, '0')}-${nextFollowUpDate!.day.toString().padLeft(2, '0')}';
      data['nextFollowUpDate'] = formattedDate;
      data['next_follow_up_date'] = formattedDate;
      data['follow_up_date'] = formattedDate;
    }

    return data;
  }

  Map<String, dynamic> toJson() => {...toApiJson(), 'id': id};

  Customer copyWith({
    Object? id,
    String? fullName,
    String? phoneNumber,
    String? phone,
    String? companyName,
    String? email,
    String? jobTitle,
    String? website,
    String? streetAddress,
    String? address,
    String? city,
    String? provinceState,
    String? state,
    String? country,
    String? companyType,
    String? leadStatus,
    String? leadQuality,
    String? leadPriority,
    Object? nextFollowUpDate,
    Object? lastContact,
    String? lastContactResult,
    String? reasonForContact,
    String? status,
    List<String>? tags,
    int? notesCount,
    int? documentsCount,
    Object? createdAt,
    Object? updatedAt,
    List<CustomerNote>? notesList,
    List<CustomerDocument>? documents,
    List<CustomerCallHistory>? callLogs,
    String? notes,
  }) =>
      Customer(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? phone ?? this.phoneNumber,
        companyName: companyName ?? this.companyName,
        email: email ?? this.email,
        jobTitle: jobTitle ?? this.jobTitle,
        website: website ?? this.website,
        streetAddress: streetAddress ?? address ?? this.streetAddress,
        city: city ?? this.city,
        provinceState: provinceState ?? state ?? this.provinceState,
        country: country ?? this.country,
        companyType: companyType ?? this.companyType,
        leadStatus: leadStatus ?? this.leadStatus,
        leadQuality: leadQuality ?? this.leadQuality,
        leadPriority: leadPriority ?? this.leadPriority,
        nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
        lastContact: lastContact ?? this.lastContact,
        lastContactResult: lastContactResult ?? this.lastContactResult,
        reasonForContact: reasonForContact ?? this.reasonForContact,
        status: status ?? this.status,
        tags: tags ?? this.tags,
        notesCount: notesCount ?? this.notesCount,
        documentsCount: documentsCount ?? this.documentsCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        notesList: notesList ?? this.notesList,
        documents: documents ?? this.documents,
        callLogs: callLogs ?? this.callLogs,
        notes: notes ?? this.notes,
      );
}

class CustomerNote {
  const CustomerNote({
    required this.id,
    required this.content,
    required this.date,
    this.author = 'Admin',
  });

  final String id;
  final String content;
  final String date;
  final String author;

  CustomerNote copyWith({String? content, String? date, String? author}) =>
      CustomerNote(
        id: id,
        content: content ?? this.content,
        date: date ?? this.date,
        author: author ?? this.author,
      );
}

class CustomerDocument {
  const CustomerDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.uploadDate,
    this.fileUrl,
  });

  final String id;
  final String name;
  final String size;
  final String type;
  final String uploadDate;
  final String? fileUrl;

  factory CustomerDocument.fromJson(Map<String, dynamic> json) =>
      CustomerDocument(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        size: '${json['size'] ?? ''}',
        type: '${json['type'] ?? 'Document'}',
        uploadDate: '${json['uploadDate'] ?? ''}',
        fileUrl: json['fileUrl']?.toString(),
      );
}

class CustomerCallHistory {
  const CustomerCallHistory({
    required this.id,
    required this.status,
    required this.direction,
    required this.outcome,
    required this.duration,
    required this.durationSeconds,
    this.scheduledFor,
    required this.callDate,
    required this.callTime,
    this.scenario,
    this.recordingUrl,
    this.transcript = const [],
    this.notes,
    this.createdAt,
    this.summary,
    this.leadPriority = 'Warm',
  });

  final String id;
  final String status;
  final String direction;
  final String outcome;
  final String duration;
  final int durationSeconds;
  final DateTime? scheduledFor;
  final String callDate;
  final String callTime;
  final String? scenario;
  final String? recordingUrl;
  final List<TranscriptTurn> transcript;
  final String? notes;
  final String? summary;
  final String leadPriority;
  final DateTime? createdAt;
}

class TranscriptTurn {
  const TranscriptTurn({
    required this.speaker,
    required this.text,
    this.speakerName,
    this.timestamp = '00:00',
  });

  final String speaker;
  final String text;
  final String? speakerName;
  final String timestamp;
}

DateTime? _date(Object? value) => value == null || value == 'Never'
    ? null
    : value is DateTime
        ? value
        : DateTime.tryParse(value.toString().replaceAll('/', '-'));
int _intValue(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
List<String> _stringList(Object? value) =>
    value is List ? value.map((e) => '$e').toList() : const [];
List<CustomerNote> _notes(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((e) => CustomerNote(
            id: '${e['id']}',
            content: '${e['content'] ?? ''}',
            date: '${e['date'] ?? ''}',
            author: '${e['author'] ?? 'Admin'}'))
        .toList()
    : const [];
List<CustomerDocument> _documents(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((e) => CustomerDocument(
            id: '${e['id']}',
            name: '${e['name'] ?? ''}',
            size: '${e['size'] ?? ''}',
            type: '${e['type'] ?? 'Document'}',
            uploadDate: '${e['uploadDate'] ?? e['upload_date'] ?? ''}',
            fileUrl: (e['fileUrl'] ?? e['file_url'])?.toString()))
        .toList()
    : const [];
List<CustomerCallHistory> _calls(Object? value) => value is List
    ? value
        .whereType<Map>()
        .map((e) => CustomerCallHistory(
            id: '${e['id'] ?? ''}',
            status: '${e['status'] ?? 'Completed'}',
            direction: '${e['direction'] ?? 'Outbound'}',
            outcome: '${e['outcome'] ?? e['last_contact_result'] ?? e['lastContactResult'] ?? 'Interested'}',
            duration: '${e['duration'] ?? '01:30'}',
            durationSeconds: _intValue(e['durationSeconds'] ?? e['duration_seconds']),
            scheduledFor: _date(e['scheduledFor'] ?? e['scheduled_for']),
            callDate: '${e['callDate'] ?? e['call_date'] ?? ''}',
            callTime: '${e['callTime'] ?? e['call_time'] ?? ''}',
            scenario: (e['scenario'] ?? e['agent'])?.toString(),
            recordingUrl: (e['recordingUrl'] ?? e['recording_url'])?.toString(),
            summary: (e['summary'] ?? e['ai_summary'] ?? e['notes'])?.toString(),
            leadPriority: '${e['leadPriority'] ?? e['lead_priority'] ?? 'Warm'}',
            transcript: e['transcript'] is List
                ? (e['transcript'] as List)
                    .whereType<Map>()
                    .map((t) => TranscriptTurn(
                        speaker: '${t['speaker'] ?? 'ai'}',
                        speakerName: t['speakerName']?.toString() ?? t['speaker_name']?.toString(),
                        timestamp: '${t['timestamp'] ?? t['time'] ?? '00:00'}',
                        text: '${t['text'] ?? t['content'] ?? ''}'))
                    .toList()
                : const [],
            notes: e['notes']?.toString(),
            createdAt: _date(e['createdAt'] ?? e['created_at'])))
        .toList()
    : const [];
