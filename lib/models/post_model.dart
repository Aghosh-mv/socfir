enum PostType { text, image, card, video, gif, link, repost, shitpost }
enum PostVisibility { public, friends, community }

class Post {
  final String id;
  final String userId;
  final PostType type;
  final String content;
  final List<String> mediaUrls;
  final String? linkUrl;
  final String? linkTitle;
  final String? linkImage;
  final PostVisibility visibility;
  final String? communityId;
  final String? repostOf;
  final bool isSensitive;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int viewsCount;
  final int sparksCount;
  final DateTime createdAt;

  // Joined fields
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? authorDisplayName;
  final bool? isLiked;
  final bool? isSaved;
  final Post? repostOriginal;
  
  // Collab fields
  final String? coAuthorUsername;
  final String? coAuthorDisplayName;
  final String? coAuthorAvatarUrl;

  const Post({
    required this.id,
    required this.userId,
    required this.type,
    this.content = '',
    this.mediaUrls = const [],
    this.linkUrl,
    this.linkTitle,
    this.linkImage,
    this.visibility = PostVisibility.public,
    this.communityId,
    this.repostOf,
    this.isSensitive = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.viewsCount = 0,
    this.sparksCount = 0,
    required this.createdAt,
    this.authorUsername,
    this.authorAvatarUrl,
    this.authorDisplayName,
    this.isLiked,
    this.isSaved,
    this.repostOriginal,
    this.coAuthorUsername,
    this.coAuthorDisplayName,
    this.coAuthorAvatarUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.text,
      ),
      content: json['content'] as String? ?? '',
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      linkUrl: json['link_url'] as String?,
      linkTitle: json['link_title'] as String?,
      linkImage: json['link_image'] as String?,
      visibility: PostVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => PostVisibility.public,
      ),
      communityId: json['community_id'] as String?,
      repostOf: json['repost_of'] as String?,
      isSensitive: json['is_sensitive'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      repostsCount: json['reposts_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      sparksCount: json['sparks_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: json['socfir_users']?['username'] as String?,
      authorAvatarUrl: json['socfir_users']?['avatar_url'] as String?,
      authorDisplayName: json['socfir_users']?['display_name'] as String?,
      coAuthorUsername: json['co_author']?['username'] as String?,
      coAuthorAvatarUrl: json['co_author']?['avatar_url'] as String?,
      coAuthorDisplayName: json['co_author']?['display_name'] as String?,
    );
  }

  Post copyWith({bool? isLiked, bool? isSaved, int? likesCount, int? sparksCount}) {
    return Post(
      id: id,
      userId: userId,
      type: type,
      content: content,
      mediaUrls: mediaUrls,
      linkUrl: linkUrl,
      linkTitle: linkTitle,
      linkImage: linkImage,
      visibility: visibility,
      communityId: communityId,
      repostOf: repostOf,
      isSensitive: isSensitive,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      repostsCount: repostsCount,
      viewsCount: viewsCount,
      sparksCount: sparksCount ?? this.sparksCount,
      createdAt: createdAt,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      authorDisplayName: authorDisplayName,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      repostOriginal: repostOriginal,
      coAuthorUsername: coAuthorUsername,
      coAuthorAvatarUrl: coAuthorAvatarUrl,
      coAuthorDisplayName: coAuthorDisplayName,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final int likesCount;
  final DateTime createdAt;
  final String? authorUsername;
  final String? authorAvatarUrl;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.likesCount = 0,
    required this.createdAt,
    this.authorUsername,
    this.authorAvatarUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorUsername: json['socfir_users']?['username'] as String?,
      authorAvatarUrl: json['socfir_users']?['avatar_url'] as String?,
    );
  }
}
