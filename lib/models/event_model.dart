/// Thông tin diễn giả hoặc khách mời đặc biệt tham gia sự kiện.
class EventSpeaker {
  /// Họ tên của diễn giả.
  final String name;

  /// Vai trò hoặc chức danh chuyên môn của diễn giả.
  final String role;

  /// Đường dẫn ảnh đại diện của diễn giả.
  final String avatarUrl;

  /// Khởi tạo một đối tượng [EventSpeaker].
  const EventSpeaker({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  /// Chuyển đổi dữ liệu Map thành đối tượng [EventSpeaker].
  factory EventSpeaker.fromMap(Map<String, dynamic> map) {
    return EventSpeaker(
      name: map['name'] as String? ?? 'Diễn giả',
      role: map['role'] as String? ?? 'Chuyên gia công nghệ',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://i.pravatar.cc/100',
    );
  }

  /// Chuyển đổi đối tượng [EventSpeaker] thành Map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}

/// Thông tin một phiên nội dung trong lịch trình của sự kiện.
class EventSession {
  /// Khung giờ diễn ra phiên (ví dụ: `09:00 - 10:00`).
  final String time;

  /// Tiêu đề hoặc chủ đề của phiên.
  final String title;

  /// Tên diễn giả hoặc ban tổ chức chủ trì phiên.
  final String speakerName;

  /// Khởi tạo một đối tượng [EventSession].
  const EventSession({
    required this.time,
    required this.title,
    required this.speakerName,
  });

  /// Chuyển đổi dữ liệu Map thành đối tượng [EventSession].
  factory EventSession.fromMap(Map<String, dynamic> map) {
    return EventSession(
      time: map['time'] as String? ?? '09:00',
      title: map['title'] as String? ?? 'Khai mạc',
      speakerName: map['speakerName'] as String? ?? 'BTC',
    );
  }

  /// Chuyển đổi đối tượng [EventSession] thành Map.
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'title': title,
      'speakerName': speakerName,
    };
  }
}

/// Mô hình sự kiện hoàn chỉnh trong hệ thống Campus Event.
///
/// Quản lý toàn bộ thông tin về thời gian, địa điểm, sức chứa, câu lạc bộ chủ trì,
/// danh sách diễn giả, lịch trình các phiên và tính toán trạng thái sự kiện tự động theo thời gian thực.
class EventModel {
  /// Mã định danh duy nhất của sự kiện trên Cloud Firestore.
  final String id;

  /// Tiêu đề chính thức của sự kiện.
  final String title;

  /// Nội dung mô tả chi tiết, thể lệ và quyền lợi sinh viên tham gia.
  final String description;

  /// Danh mục sự kiện (ví dụ: `Technology`, `Academic`, `Art & Music`, `Sports`, `Career`).
  final String category;

  /// Mã định danh câu lạc bộ chủ trì tổ chức sự kiện.
  final String clubId;

  /// Tên câu lạc bộ chủ trì.
  final String clubName;

  /// Ngày diễn ra sự kiện (chuỗi định dạng `YYYY-MM-DD` hoặc `DD/MM/YYYY`).
  final String date;

  /// Khung giờ tổ chức sự kiện (ví dụ: `13:30 - 17:30`).
  final String time;

  /// Địa điểm tổ chức tại cơ sở Campus (ví dụ: `Hội trường Trịnh Công Sơn`).
  final String location;

  /// Sức chứa hoặc số lượng vé tối đa được phép đăng ký.
  final int capacity;

  /// Số lượng sinh viên đã đăng ký thành công tính đến thời điểm hiện tại.
  final int registeredCount;

  /// Đường dẫn hình ảnh banner quảng bá sự kiện.
  final String bannerUrl;

  /// Cờ đánh dấu sự kiện nổi bật được ghim tại trang chủ Mobile.
  final bool isFeatured;

  /// Danh sách diễn giả khách mời tham gia sự kiện.
  final List<EventSpeaker> speakers;

  /// Lịch trình các phiên làm việc trong sự kiện.
  final List<EventSession> sessions;

  /// Khởi tạo một đối tượng [EventModel].
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

  /// Kiểm tra xem sự kiện đã hết chỗ đăng ký hay chưa.
  bool get isFull => registeredCount >= capacity;

  /// Số lượng suất đăng ký còn lại của sự kiện.
  int get spotsRemaining => (capacity - registeredCount).clamp(0, capacity);

  /// Phân tích chuỗi ngày [date] thành đối tượng [DateTime] hỗ trợ nhiều định dạng (DD/MM/YYYY, YYYY-MM-DD, ISO 8601).
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

  /// Phân tích thời điểm bắt đầu sự kiện từ [date] và phần đầu của [time].
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

  /// Phân tích thời điểm kết thúc sự kiện từ [date] và phần sau của [time].
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

  /// Cổng check-in mở trước giờ bắt đầu sự kiện 60 phút.
  static const Duration gateOpenLeadTime = Duration(minutes: 60);

  /// Thời điểm mở cổng quét vé QR hợp lệ (trước giờ khai mạc 60 phút).
  DateTime? get gateOpenDateTime => startDateTime?.subtract(gateOpenLeadTime);

  /// Sắp xếp danh sách sự kiện: đang diễn ra -> sắp diễn ra (gần nhất trước) -> đã kết thúc (mới nhất trước).
  static List<EventModel> sortByPriority(List<EventModel> events) {
    final sorted = List<EventModel>.from(events);
    sorted.sort((a, b) {
      final rankA = a.isOngoing ? 0 : (!a.isPast ? 1 : 2);
      final rankB = b.isOngoing ? 0 : (!b.isPast ? 1 : 2);
      if (rankA != rankB) return rankA.compareTo(rankB);
      final timeA = a.startDateTime ?? DateTime(2099);
      final timeB = b.startDateTime ?? DateTime(2099);
      return rankA == 2 ? timeB.compareTo(timeA) : timeA.compareTo(timeB);
    });
    return sorted;
  }

  /// Xác định xem sự kiện đã diễn ra và kết thúc hay chưa dựa vào thời gian thực hiện tại.
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

  /// Xác định xem sự kiện hiện có đang trong khung giờ diễn ra hay không.
  bool get isOngoing {
    final start = startDateTime;
    final end = endDateTime;
    if (start != null && end != null) {
      final now = DateTime.now();
      return now.isAfter(start) && now.isBefore(end);
    }
    return false;
  }

  /// Cổng đăng ký sự kiện chỉ mở khi sự kiện chưa kết thúc và chưa đầy chỗ.
  bool get isRegistrationOpen => !isPast && !isFull;

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [EventModel].
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
              ?.whereType<Map>()
              .map((s) => EventSpeaker.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      sessions: (map['sessions'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((s) => EventSession.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
    );
  }

  /// Chuyển đổi đối tượng [EventModel] thành Map để cập nhật hoặc lưu trữ trên Firestore.
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

  /// Tạo bản sao [EventModel] mới với các thuộc tính được thay thế có chủ đích.
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
