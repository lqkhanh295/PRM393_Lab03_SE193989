class ClubModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final int followerCount;
  final String logoUrl;
  final String? acronym;
  final String? officialUrl;
  final String? fanpageUrl;
  final String? email;

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

  factory ClubModel.fromMap(Map<String, dynamic> map, String id) {
    return ClubModel(
      id: id,
      name: map['name'] as String? ?? 'CLB FPTU',
      category: map['category'] as String? ?? 'Technology',
      description: map['description'] as String? ?? '',
      followerCount: (map['followerCount'] as num?)?.toInt() ?? 100,
      logoUrl: map['logoUrl'] as String? ?? 'https://i.pravatar.cc/100?u=$id',
      acronym: map['acronym'] as String?,
      officialUrl: map['officialUrl'] as String?,
      fanpageUrl: map['fanpageUrl'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
