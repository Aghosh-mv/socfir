class Community {
  final String id;
  final String name;
  final String description;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? creatorId;
  final String ageRestriction; // 'all', '13plus', '18plus'
  final bool isPrivate;
  final int membersCount;
  final int postsCount;
  final DateTime createdAt;
  final bool? isMember;

  const Community({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl,
    this.bannerUrl,
    this.creatorId,
    this.ageRestriction = 'all',
    this.isPrivate = false,
    this.membersCount = 0,
    this.postsCount = 0,
    required this.createdAt,
    this.isMember,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      creatorId: json['creator_id'] as String?,
      ageRestriction: json['age_restriction'] as String? ?? 'all',
      isPrivate: json['is_private'] as bool? ?? false,
      membersCount: json['members_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
