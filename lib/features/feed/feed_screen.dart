import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post_model.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/post_card.dart';
import 'widgets/post_shimmer.dart';
import 'widgets/create_post_dialog.dart';
import 'posts_service.dart';

final dummyPostsProvider = Provider<List<Post>>((ref) {
  return [
    Post(
      id: '1',
      userId: 'u1',
      type: PostType.text,
      content: 'Just deployed the first version of SocFir! 🔥 What do you all think?',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      authorUsername: 'tinkerspace',
      authorDisplayName: 'Tinker',
      authorAvatarUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png', // Transparent PNG to demonstrate out-of-bounds pop-out
      coAuthorUsername: 'devgirl',
      coAuthorDisplayName: 'Jane Dev',
      coAuthorAvatarUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      sparksCount: 15,
      likesCount: 42,
      commentsCount: 7,
      isLiked: true,
    ),
    Post(
      id: '2',
      userId: 'u2',
      type: PostType.card, // multiple images
      content: 'Beautiful sunset today from my setup. Here is a mini tour! (NSFW for age filtering)',
      isSensitive: true,
      mediaUrls: [
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
        'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
        'https://images.unsplash.com/photo-1537498425277-c283d32ef9db?w=800',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      authorUsername: 'devgirl',
      authorDisplayName: 'Jane Dev',
      likesCount: 120,
      commentsCount: 15,
      repostsCount: 3,
    ),
    Post(
      id: '3',
      userId: 'u3',
      type: PostType.shitpost,
      content: 'imagine using state management when you can just pass callbacks down 15 levels of widgets amirite?? 😂',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      authorUsername: 'chaos_coder',
      authorDisplayName: 'Chaos Coder',
      likesCount: 9001,
      commentsCount: 420,
    ),
  ];
});

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real Supabase stream
    final feedAsync = ref.watch(feedStreamProvider);
    // Watch dummy posts as fallback/demo
    final dummyPosts = ref.watch(dummyPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('For You', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {}, // Switch feed type
          )
        ],
      ),
      body: feedAsync.when(
        data: (posts) {
          final displayPosts = posts.isEmpty ? dummyPosts : posts;
          
          return RefreshIndicator(
            onRefresh: () async {
              // Usually ref.refresh(feedStreamProvider) or similar for FutureProviders
              await Future.delayed(const Duration(seconds: 1));
            },
            color: AppColors.accent,
            child: ListView.builder(
              itemCount: displayPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: displayPosts[index]);
              },
            ),
          );
        },
        loading: () => ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const PostShimmer(),
        ),
        error: (err, stack) {
          return RefreshIndicator(
            onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
            color: AppColors.accent,
            child: ListView.builder(
              itemCount: dummyPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: dummyPosts[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const CreatePostDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

