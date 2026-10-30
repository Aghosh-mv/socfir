import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post_model.dart';
import '../../supabase/supabase_service.dart';
import '../../shared/utils/app_providers.dart';

final postsServiceProvider = Provider<PostsService>((ref) {
  return PostsService(ref.watch(supabaseClientProvider), ref);
});

// Stream provider for realtime feed updates
final feedStreamProvider = StreamProvider<List<Post>>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return supabase
      .from('posts')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => Post.fromJson(json)).toList());
});

// Local posts provider (reads from SharedPreferences)
final localPostsProvider = Provider<List<Post>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final raw = prefs.getString('local_posts_db');
  if (raw == null || raw.isEmpty) return [];
  try {
    final List decoded = jsonDecode(raw);
    return decoded
        .cast<Map<String, dynamic>>()
        .map((j) => Post.fromJson(j))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } catch (_) {
    return [];
  }
});

class PostsService {
  final SupabaseClient _client;
  final Ref _ref;

  PostsService(this._client, this._ref);

  /// Current user ID: try Supabase first, then fall back to SharedPreferences
  String? get _currentUserId {
    try {
      final sbId = _client.auth.currentUser?.id;
      if (sbId != null) return sbId;
    } catch (_) {}
    return _ref.read(sharedPrefsProvider).getString('current_user_id');
  }

  List<Map<String, dynamic>> _getLocalPosts() {
    final prefs = _ref.read(sharedPrefsProvider);
    final raw = prefs.getString('local_posts_db');
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalPost(Map<String, dynamic> postData) async {
    final prefs = _ref.read(sharedPrefsProvider);
    final posts = _getLocalPosts();
    posts.insert(0, postData);
    await prefs.setString('local_posts_db', jsonEncode(posts));
    _ref.invalidate(localPostsProvider);
  }

  Future<void> createPost({
    required PostType type,
    String content = '',
    List<String> mediaUrls = const [],
    String? linkUrl,
    String? linkTitle,
    String? linkImage,
    PostVisibility visibility = PostVisibility.public,
    String? communityId,
    bool isSensitive = false,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    final authorUser = _ref.read(currentUserProvider);

    final postData = {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'type': type.name,
      'content': content,
      'media_urls': mediaUrls,
      'link_url': linkUrl,
      'link_title': linkTitle,
      'link_image': linkImage,
      'visibility': visibility.name,
      'community_id': communityId,
      'is_sensitive': isSensitive,
      'likes_count': 0,
      'comments_count': 0,
      'reposts_count': 0,
      'views_count': 0,
      'sparks_count': 0,
      'created_at': DateTime.now().toIso8601String(),
      'socfir_users': {
        'username': authorUser?.username ?? 'socfirdev',
        'display_name': authorUser?.displayName ?? authorUser?.username ?? 'socfirdev',
        'avatar_url': authorUser?.avatarUrl,
      },
    };

    // Try Supabase first
    try {
      await _client.from('posts').insert({
        'user_id': userId,
        'type': type.name,
        'content': content,
        'media_urls': mediaUrls,
        'link_url': linkUrl,
        'link_title': linkTitle,
        'link_image': linkImage,
        'visibility': visibility.name,
        'community_id': communityId,
        'is_sensitive': isSensitive,
      });
      return; // Supabase succeeded, no need to store locally
    } catch (_) {
      // Supabase unavailable — fall back to local storage
    }

    await _saveLocalPost(postData);
  }

  Future<void> likePost(String postId, bool isLiking) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not logged in');

    if (isLiking) {
      await _client.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
    } else {
      await _client.from('likes')
          .delete()
          .match({'post_id': postId, 'user_id': userId});
    }
  }
}
