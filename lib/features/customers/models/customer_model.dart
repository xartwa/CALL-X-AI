class CustomerNote {
  final String id;
  final String content;
  final String date;
  final String author;

  CustomerNote({
    required this.id,
    required this.content,
    required this.date,
    this.author = 'Admin',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'date': date,
        'author': author,
      };

  factory CustomerNote.fromJson(Map<String, dynamic> json) => CustomerNote(
        id: json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        content: json['content'] as String? ?? '',
        date: json['date'] as String? ?? '',
        author: json['author'] as String? ?? 'Admin',
      );

  CustomerNote copyWith({
    String? id,
    String? content,
    String? date,
    String? author,
  }) {
    return CustomerNote(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      author: author ?? this.author,
    );
  }
}

class CustomerDocument {
  final String id;
  final String name;
  final String size;
  final String type; // Quote, Drawing, Proposal, Brief, Invoice, etc.
  final String uploadDate;

  CustomerDocument({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.uploadDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        'type': type,
        'uploadDate': uploadDate,
      };

  factory CustomerDocument.fromJson(Map<String, dynamic> json) =>
      CustomerDocument(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        size: json['size'] as String? ?? '',
        type: json['type'] as String? ?? 'Document',
        uploadDate: json['uploadDate'] as String? ?? '',
      );
}

class User {
  final int id;
  final String fullName; // Contact Name
  final String companyName; // Company Name
  final String jobTitle; // Job Title / Position
  final String email; // Main contact email
  final String phone; // Contact's number
  final String website; // Company website
  final String address; // Street address
  final String city; // City (e.g. Vancouver)
  final String state; // Province / State (e.g. BC)
  final String country; // Country (e.g. Canada)
  final String companyType; // GC, Developer, Trade, Startup, Agency
  final String leadStatus; // New, Contacted, Qualified, Won, Lost
  final String leadPriority; // Hot, Warm, Cold
  final String leadQuality; // Excellent, Good, Average, Poor
  final String
      lastContactResult; // No answer, Interested, Call back, Meeting booked
  final String nextFollowUpDate; // Next follow up date
  final String createdAt;
  final String lastContact;
  final String status; // Active / Deactive
  final String reasonForContact;
  final List<String> tags;
  final List<CustomerNote> notesList;
  final List<CustomerDocument> documents;
  final String notes; // Backward compatibility string

  User({
    required this.id,
    required this.fullName,
    this.companyName = '',
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.lastContact,
    required this.status,
    this.jobTitle = '',
    this.reasonForContact = '',
    this.notes = '',
    this.website = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.companyType = 'General',
    this.leadStatus = 'New',
    this.leadPriority = 'Warm',
    this.leadQuality = 'Good',
    this.lastContactResult = 'Interested',
    this.nextFollowUpDate = '',
    this.tags = const [],
    this.notesList = const [],
    this.documents = const [],
  });

  User copyWith({
    int? id,
    String? fullName,
    String? companyName,
    String? jobTitle,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    String? companyType,
    String? leadStatus,
    String? leadPriority,
    String? leadQuality,
    String? lastContactResult,
    String? nextFollowUpDate,
    String? createdAt,
    String? lastContact,
    String? status,
    String? reasonForContact,
    String? notes,
    List<String>? tags,
    List<CustomerNote>? notesList,
    List<CustomerDocument>? documents,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      companyType: companyType ?? this.companyType,
      leadStatus: leadStatus ?? this.leadStatus,
      leadPriority: leadPriority ?? this.leadPriority,
      leadQuality: leadQuality ?? this.leadQuality,
      lastContactResult: lastContactResult ?? this.lastContactResult,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      createdAt: createdAt ?? this.createdAt,
      lastContact: lastContact ?? this.lastContact,
      status: status ?? this.status,
      reasonForContact: reasonForContact ?? this.reasonForContact,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      notesList: notesList ?? this.notesList,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'companyType': companyType,
      'leadStatus': leadStatus,
      'leadPriority': leadPriority,
      'leadQuality': leadQuality,
      'lastContactResult': lastContactResult,
      'nextFollowUpDate': nextFollowUpDate,
      'createdAt': createdAt,
      'lastContact': lastContact,
      'status': status,
      'reasonForContact': reasonForContact,
      'notes': notes,
      'tags': tags,
      'notesList': notesList.map((n) => n.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      parsedTags = List<String>.from(json['tags'] as List);
    }

    List<CustomerNote> parsedNotes = [];
    if (json['notesList'] != null) {
      parsedNotes = (json['notesList'] as List)
          .map(
              (n) => CustomerNote.fromJson(Map<String, dynamic>.from(n as Map)))
          .toList();
    } else if (json['notes'] != null && (json['notes'] as String).isNotEmpty) {
      parsedNotes = [
        CustomerNote(
          id: '1',
          content: json['notes'] as String,
          date: json['lastContact'] as String? ?? '2026/08/10',
          author: 'Admin',
        ),
      ];
    }

    List<CustomerDocument> parsedDocs = [];
    if (json['documents'] != null) {
      parsedDocs = (json['documents'] as List)
          .map((d) =>
              CustomerDocument.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
    }

    return User(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      companyType: json['companyType'] as String? ?? 'General',
      leadStatus: json['leadStatus'] as String? ?? 'New',
      leadPriority: json['leadPriority'] as String? ?? 'Warm',
      leadQuality: json['leadQuality'] as String? ?? 'Good',
      lastContactResult: json['lastContactResult'] as String? ?? 'Interested',
      nextFollowUpDate: json['nextFollowUpDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      lastContact: json['lastContact'] as String? ?? '',
      status: json['status'] as String? ?? 'Active',
      reasonForContact: json['reasonForContact'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      tags: parsedTags,
      notesList: parsedNotes,
      documents: parsedDocs,
    );
  }
}
