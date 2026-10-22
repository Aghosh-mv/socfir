class SocFirUser {
  final String id;
  final String username;
  final String? displayName;
  final String email;
  final String? avatarUrl;
  final String bio;
  final int? age;
  final String education;
  final List<String> jobs;
  final List<String> hobbies;
  final List<String> projects;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int likesCount;
  final int viewsCount;
  final double leaderboardScore;
  final int leaderboardRank;
  final bool isOnboarded;
  final DateTime createdAt;

  const SocFirUser({
    required this.id,
    required this.username,
    this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio = '',
    this.age,
    this.education = '',
    this.jobs = const [],
    this.hobbies = const [],
    this.projects = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.leaderboardScore = 0,
    this.leaderboardRank = 0,
    this.isOnboarded = false,
    required this.createdAt,
  });

  String get name => displayName ?? username;

  /// Age-based content tier: 0=under13, 1=teen13to17, 2=adult18plus
  int get contentTier {
    if (age == null) return 0;
    if (age! >= 18) return 2;
    if (age! >= 13) return 1;
    return 0;
  }

  factory SocFirUser.fromJson(Map<String, dynamic> json) {
    return SocFirUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      age: json['age'] as int?,
      education: json['education'] as String? ?? '',
      jobs: List<String>.from(json['jobs'] ?? []),
      hobbies: List<String>.from(json['hobbies'] ?? []),
      projects: List<String>.from(json['projects'] ?? []),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      leaderboardScore: (json['leaderboard_score'] as num?)?.toDouble() ?? 0,
      leaderboardRank: json['leaderboard_rank'] as int? ?? 0,
      isOnboarded: json['is_onboarded'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'email': email,
    'avatar_url': avatarUrl,
    'bio': bio,
    'age': age,
    'education': education,
    'jobs': jobs,
    'hobbies': hobbies,
    'projects': projects,
    'followers_count': followersCount,
    'following_count': followingCount,
    'posts_count': postsCount,
    'likes_count': likesCount,
    'views_count': viewsCount,
    'leaderboard_score': leaderboardScore,
    'leaderboard_rank': leaderboardRank,
    'is_onboarded': isOnboarded,
    'created_at': createdAt.toIso8601String(),
  };

  SocFirUser copyWith({
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? age,
    String? education,
    List<String>? jobs,
    List<String>? hobbies,
    List<String>? projects,
    bool? isOnboarded,
    int? followersCount,
    int? followingCount,
  }) {
    return SocFirUser(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      education: education ?? this.education,
      jobs: jobs ?? this.jobs,
      hobbies: hobbies ?? this.hobbies,
      projects: projects ?? this.projects,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount,
      likesCount: likesCount,
      viewsCount: viewsCount,
      leaderboardScore: leaderboardScore,
      leaderboardRank: leaderboardRank,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      createdAt: createdAt,
    );
  }
}
