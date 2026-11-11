class EventSpeaker {
  final String name;
  final String role;
  final String avatarUrl;

  const EventSpeaker({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  factory EventSpeaker.fromMap(Map<String, dynamic> map) {
    return EventSpeaker(
      name: map['name'] as String? ?? 'Diễn giả',
      role: map['role'] as String? ?? 'Chuyên gia công nghệ',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://i.pravatar.cc/100',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}

class EventSession {
  final String time;
  final String title;
  final String speakerName;

  const EventSession({
    required this.time,
    required this.title,
    required this.speakerName,
  });

  factory EventSession.fromMap(Map<String, dynamic> map) {
    return EventSession(
      time: map['time'] as String? ?? '09:00',
      title: map['title'] as String? ?? 'Khai mạc',
      speakerName: map['speakerName'] as String? ?? 'BTC',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'title': title,
      'speakerName': speakerName,
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String clubId;
  final String clubName;
  final String date;
  final String time;
  final String location;
  final int capacity;
  final int registeredCount;
  final String bannerUrl;
  final bool isFeatured;
  final List<EventSpeaker> speakers;
  final List<EventSession> sessions;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.clubId,
    required this.clubName,
    required this.date,
    required this.time,
    required this.location,
    required this.capacity,
    required this.registeredCount,
    required this.bannerUrl,
    this.isFeatured = false,
    this.speakers = const [],
    this.sessions = const [],
  });

  bool get isFull => registeredCount >= capacity;
  int get spotsRemaining => (capacity - registeredCount).clamp(0, capacity);

  /// Parse string date supporting DD/MM/YYYY, YYYY-MM-DD, or ISO 8601
  DateTime? get parsedDate {
    if (date.trim().isEmpty) return null;
    final trimmed = date.trim();
    try {
      if (trimmed.contains('/')) {
        final parts = trimmed.split('/');
        if (parts.length == 3) {
          final p0 = int.parse(parts[0]);
          final p1 = int.parse(parts[1]);
          final p2 = int.parse(parts[2]);
          if (p0 > 1000) {
            return DateTime(p0, p1, p2);
          } else {
            return DateTime(p2, p1, p0);
          }
        }
      }
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 3) {
          final p0 = int.parse(parts[0]);
          final p1 = int.parse(parts[1]);
          final p2 = int.parse(parts[2]);
          if (p0 > 1000) {
            return DateTime(p0, p1, p2);
          } else {
            return DateTime(p2, p1, p0);
          }
        }
      }
      return DateTime.tryParse(trimmed);
    } catch (_) {}
    return null;
  }

  /// Parse start DateTime from date and time
  DateTime? get startDateTime {
    final d = parsedDate;
    if (d == null) return null;
    if (time.trim().isEmpty) return DateTime(d.year, d.month, d.day);
    try {
      final timePart = time.split('-').first.trim();
      final hm = timePart.split(':');
      if (hm.length >= 2) {
        final hour = int.parse(hm[0].trim());
        final minute = int.parse(hm[1].trim());
        return DateTime(d.year, d.month, d.day, hour, minute);
      }
    } catch (_) {}
    return DateTime(d.year, d.month, d.day);
  }

  /// Parse end DateTime from date and time
  DateTime? get endDateTime {
    final d = parsedDate;
    if (d == null) return null;
    if (time.trim().isEmpty) return DateTime(d.year, d.month, d.day, 23, 59, 59);
    try {
      final parts = time.split('-');
      final timePart = (parts.length > 1 ? parts.last : parts.first).trim();
      final hm = timePart.split(':');
      if (hm.length >= 2) {
        final hour = int.parse(hm[0].trim());
        final minute = int.parse(hm[1].trim());
        return DateTime(d.year, d.month, d.day, hour, minute);
      }
    } catch (_) {}
    return DateTime(d.year, d.month, d.day, 23, 59, 59);
  }

  /// Determines whether the event has already concluded based on current runtime date/time
  bool get isPast {
    final end = endDateTime;
    if (end != null) {
      return DateTime.now().isAfter(end);
    }
    final d = parsedDate;
    if (d != null) {
      return DateTime.now().isAfter(DateTime(d.year, d.month, d.day, 23, 59, 59));
    }
    return false;
  }

  /// Determines whether the event is currently in progress
  bool get isOngoing {
    final start = startDateTime;
    final end = endDateTime;
    if (start != null && end != null) {
      final now = DateTime.now();
      return now.isAfter(start) && now.isBefore(end);
    }
    return false;
  }

  /// Registration is open ONLY IF the event is not past and not full
  bool get isRegistrationOpen => !isPast && !isFull;

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] as String? ?? 'Sự kiện FPTU',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Technology',
      clubId: map['clubId'] as String? ?? 'fcode',
      clubName: map['clubName'] as String? ?? 'CLB F-Code',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      location: map['location'] as String? ?? 'Campus FPTU',
      capacity: (map['capacity'] as num?)?.toInt() ?? 200,
      registeredCount: (map['registeredCount'] as num?)?.toInt() ?? 0,
      bannerUrl: map['bannerUrl'] as String? ?? '',
      isFeatured: map['isFeatured'] as bool? ?? false,
      speakers: (map['speakers'] as List<dynamic>?)
              ?.map((s) => EventSpeaker.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      sessions: (map['sessions'] as List<dynamic>?)
              ?.map((s) => EventSession.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'clubId': clubId,
      'clubName': clubName,
      'date': date,
      'time': time,
      'location': location,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'bannerUrl': bannerUrl,
      'isFeatured': isFeatured,
      'speakers': speakers.map((s) => s.toMap()).toList(),
      'sessions': sessions.map((s) => s.toMap()).toList(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? clubId,
    String? clubName,
    String? date,
    String? time,
    String? location,
    int? capacity,
    int? registeredCount,
    String? bannerUrl,
    bool? isFeatured,
    List<EventSpeaker>? speakers,
    List<EventSession>? sessions,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      speakers: speakers ?? this.speakers,
      sessions: sessions ?? this.sessions,
    );
  }
}
