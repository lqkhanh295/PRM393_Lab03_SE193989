class ClubModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final int followerCount;
  final String logoUrl;

  const ClubModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.followerCount,
    required this.logoUrl,
  });

  factory ClubModel.fromMap(Map<String, dynamic> map, String id) {
    return ClubModel(
      id: id,
      name: map['name'] as String? ?? 'CLB FPTU',
      category: map['category'] as String? ?? 'Technology',
      description: map['description'] as String? ?? '',
      followerCount: (map['followerCount'] as num?)?.toInt() ?? 100,
      logoUrl: map['logoUrl'] as String? ?? 'https://i.pravatar.cc/100?u=$id',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'followerCount': followerCount,
      'logoUrl': logoUrl,
    };
  }
}
