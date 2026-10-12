class Chat {
  final String id;
  final String type; // 'dm' or 'group'
  final String? name;
  final String? avatarUrl;
  final String? communityId;
  final DateTime createdAt;
  final List<String> memberIds;
  final Message? lastMessage;

  const Chat({
    required this.id,
    required this.type,
    this.name,
    this.avatarUrl,
    this.communityId,
    required this.createdAt,
    this.memberIds = const [],
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'dm',
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      communityId: json['community_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'gif'
  final String? mediaUrl;
  final DateTime createdAt;
  final String? senderUsername;
  final String? senderAvatarUrl;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = 'text',
    this.mediaUrl,
    required this.createdAt,
    this.senderUsername,
    this.senderAvatarUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderUsername: json['socfir_users']?['username'] as String?,
      senderAvatarUrl: json['socfir_users']?['avatar_url'] as String?,
    );
  }
}
