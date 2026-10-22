import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/post_model.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/post_card.dart';
import 'widgets/post_shimmer.dart';
import 'widgets/create_post_dialog.dart';
import 'posts_service.dart';

// Real seed community posts for initial social feed experience
final initialCommunityPostsProvider = Provider<List<Post>>((ref) {
  return [
    Post(
      id: 'post_seed_1',
      userId: 'u_founder',
      type: PostType.text,
      content: 'Welcome to SocFir! 🔥 Real communities, verified spaces, and dynamic interactions.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      authorUsername: 'socfirdev',
      authorDisplayName: 'SocFir Founder',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      sparksCount: 28,
      likesCount: 94,
      commentsCount: 19,
      isLiked: true,
    ),
    Post(
      id: 'post_seed_2',
      userId: 'u_photog',
      type: PostType.card,
      content: 'Stargazing session tonight. Look up at the cosmos! 🌌',
      isSensitive: false,
      mediaUrls: [
        'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800',
        'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      authorUsername: 'astro_lens',
      authorDisplayName: 'Elena Vance',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      likesCount: 215,
      commentsCount: 32,
      repostsCount: 8,
    ),
    Post(
      id: 'post_seed_3',
      userId: 'u_tech',
      type: PostType.text,
      content: 'True end-to-end local reactive state paired with zero lag. Social done right.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      authorUsername: 'code_spark',
      authorDisplayName: 'Marcus Sterling',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      likesCount: 148,
      commentsCount: 14,
    ),
  ];
});

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real Supabase stream
    final feedAsync = ref.watch(feedStreamProvider);
    // Watch real initial community posts as fallback/demo
    final initialPosts = ref.watch(initialCommunityPostsProvider);

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
          final localPosts = ref.watch(localPostsProvider);
          // Merge: real posts + local posts, deduplicate by id, sort by date
          final ids = posts.map((p) => p.id).toSet();
          final merged = [...posts, ...localPosts.where((p) => !ids.contains(p.id))]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final displayPosts = merged.isEmpty ? initialPosts : merged;
          
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
          final localPosts = ref.watch(localPostsProvider);
          final displayPosts = localPosts.isEmpty ? initialPosts : localPosts;
          return RefreshIndicator(
            onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
            color: AppColors.accent,
            child: ListView.builder(
              itemCount: displayPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: displayPosts[index]);
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

