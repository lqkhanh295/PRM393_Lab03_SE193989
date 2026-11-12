/// Mô hình thông tin tài khoản người dùng trong hệ thống Campus Event.
///
/// Quản lý hồ sơ sinh viên hoặc cán bộ, điểm rèn luyện tích lũy [activityPoints],
/// vai trò hệ thống [role] và danh sách các câu lạc bộ đang theo dõi [followedClubs].
class UserModel {
  /// Mã định danh duy nhất của tài khoản (khớp với Firebase Auth UID).
  final String id;

  /// Họ tên của người dùng.
  final String name;

  /// Địa chỉ email trường FPT (@fpt.edu.vn).
  final String email;

  /// Đường dẫn hình đại diện đại diện người dùng.
  final String avatarUrl;

  /// Chuyên ngành theo học (ví dụ: `Kỹ thuật Phần mềm (SE)`).
  final String major;

  /// Điểm rèn luyện tích lũy được cộng từ việc tham gia và check-in các sự kiện.
  final int activityPoints;

  /// Vai trò tài khoản trong hệ thống (`student`, `staff`, `leader`, `security`).
  final String role;

  /// Danh sách mã định danh các câu lạc bộ mà người dùng bấm theo dõi.
  final List<String> followedClubs;

  /// Khởi tạo một đối tượng [UserModel].
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.major,
    required this.activityPoints,
    required this.role,
    this.followedClubs = const [],
  });

  /// Kiểm tra xem tài khoản có quyền cán bộ quản trị hoặc ban chủ nhiệm CLB hay không.
  bool get isStaffOrLeader => role == 'staff' || role == 'leader';

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [UserModel].
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? 'Sinh viên FPTU',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://i.pravatar.cc/150?u=$id',
      major: map['major'] as String? ?? 'Kỹ thuật Phần mềm (SE)',
      activityPoints: (map['activityPoints'] as num?)?.toInt() ?? 0,
      role: map['role'] as String? ?? 'student',
      followedClubs: List<String>.from(map['followedClubs'] ?? []),
    );
  }

  /// Chuyển đổi đối tượng [UserModel] thành Map để cập nhật trên Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'major': major,
      'activityPoints': activityPoints,
      'role': role,
      'followedClubs': followedClubs,
    };
  }

  /// Tạo bản sao [UserModel] với các thuộc tính cập nhật có chủ đích.
  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? major,
    int? activityPoints,
    String? role,
    List<String>? followedClubs,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      major: major ?? this.major,
      activityPoints: activityPoints ?? this.activityPoints,
      role: role ?? this.role,
      followedClubs: followedClubs ?? this.followedClubs,
    );
  }
}
