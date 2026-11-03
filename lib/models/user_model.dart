class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String major;
  final int activityPoints;
  final String role; // 'student' or 'staff' / 'leader'
  final List<String> followedClubs;

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

  bool get isStaffOrLeader => role == 'staff' || role == 'leader';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? 'Sinh viên FPTU',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? 'https://i.pravatar.cc/150?u=$id',
      major: map['major'] as String? ?? 'Kỹ thuật Phần mềm (SE)',
      activityPoints: (map['activityPoints'] as num?)?.toInt() ?? 15,
      role: map['role'] as String? ?? 'student',
      followedClubs: List<String>.from(map['followedClubs'] ?? []),
    );
  }

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
