enum NotificationType { like, comment, follow, repost, mention, dm }

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String actorId;
  final String? postId;
  final String? message;
  final bool isRead;
  final DateTime createdAt;
  final String? actorUsername;
  final String? actorAvatarUrl;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.actorId,
    this.postId,
    this.message,
    this.isRead = false,
    required this.createdAt,
    this.actorUsername,
    this.actorAvatarUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.like,
      ),
      actorId: json['actor_id'] as String,
      postId: json['post_id'] as String?,
      message: json['message'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorUsername: json['actor']?['username'] as String?,
      actorAvatarUrl: json['actor']?['avatar_url'] as String?,
    );
  }

  String get displayMessage {
    switch (type) {
      case NotificationType.like:
        return '${actorUsername ?? 'Someone'} liked your post';
      case NotificationType.comment:
        return '${actorUsername ?? 'Someone'} commented on your post';
      case NotificationType.follow:
        return '${actorUsername ?? 'Someone'} started following you';
      case NotificationType.repost:
        return '${actorUsername ?? 'Someone'} reposted your post';
      case NotificationType.mention:
        return '${actorUsername ?? 'Someone'} mentioned you';
      case NotificationType.dm:
        return '${actorUsername ?? 'Someone'} sent you a message';
    }
  }
}
