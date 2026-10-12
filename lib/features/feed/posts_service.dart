import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post_model.dart';
import '../../supabase/supabase_service.dart';

final postsServiceProvider = Provider<PostsService>((ref) {
  return PostsService(ref.watch(supabaseClientProvider));
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

class PostsService {
  final SupabaseClient _client;

  PostsService(this._client);

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
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

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
  }

  Future<void> likePost(String postId, bool isLiking) async {
    final userId = _client.auth.currentUser?.id;
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
