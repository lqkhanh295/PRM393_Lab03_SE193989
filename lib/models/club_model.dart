/// Mô hình câu lạc bộ sinh viên (Club) tại Đại học FPT TP.HCM.
///
/// Chứa thông tin hồ sơ câu lạc bộ, phân loại hoạt động, số lượng sinh viên theo dõi
/// và các kênh liên kết truyền thông chính thức.
class ClubModel {
  /// Mã định danh duy nhất của câu lạc bộ (ví dụ: `fcode`, `fev`, `fptbeat`).
  final String id;

  /// Tên đầy đủ của câu lạc bộ.
  final String name;

  /// Phân loại câu lạc bộ (ví dụ: `Technology`, `Academic`, `Art & Music`, `Sports`, `Volunteer`).
  final String category;

  /// Mô tả ngắn về sứ mệnh và hoạt động của câu lạc bộ.
  final String description;

  /// Tổng số sinh viên nhấn theo dõi câu lạc bộ.
  final int followerCount;

  /// Đường dẫn hình ảnh logo chính thức của câu lạc bộ.
  final String logoUrl;

  /// Tên viết tắt của câu lạc bộ.
  final String? acronym;

  /// Trang web thông tin hoặc cổng thông tin chính thức.
  final String? officialUrl;

  /// Đường dẫn trang mạng xã hội Fanpage Facebook.
  final String? fanpageUrl;

  /// Địa chỉ thư điện tử liên hệ chính thức của câu lạc bộ.
  final String? email;

  /// Khởi tạo một đối tượng [ClubModel].
  const ClubModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.followerCount,
    required this.logoUrl,
    this.acronym,
    this.officialUrl,
    this.fanpageUrl,
    this.email,
  });

  /// Chuyển đổi dữ liệu Map từ Cloud Firestore thành đối tượng [ClubModel].
  factory ClubModel.fromMap(Map<String, dynamic> map, String id) {
    int parseFollowerCount(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return ClubModel(
      id: id,
      name: map['name'] as String? ?? 'CLB FPTU',
      category: map['category'] as String? ?? 'Technology',
      description: map['description'] as String? ?? '',
      followerCount: parseFollowerCount(map['followerCount']),
      logoUrl: (map['logoUrl'] as String?)?.trim() ?? '',
      acronym: map['acronym'] as String?,
      officialUrl: map['officialUrl'] as String?,
      fanpageUrl: map['fanpageUrl'] as String?,
      email: map['email'] as String?,
    );
  }

  /// Chuyển đổi đối tượng [ClubModel] thành Map để cập nhật trên Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'followerCount': followerCount,
      'logoUrl': logoUrl,
      if (acronym != null) 'acronym': acronym,
      if (officialUrl != null) 'officialUrl': officialUrl,
      if (fanpageUrl != null) 'fanpageUrl': fanpageUrl,
      if (email != null) 'email': email,
    };
  }
}
