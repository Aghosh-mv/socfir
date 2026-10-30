import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/post_card.dart';
import 'widgets/post_shimmer.dart';
import 'widgets/create_post_dialog.dart';
import 'posts_service.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real Supabase stream
    final feedAsync = ref.watch(feedStreamProvider);
    final localPosts = ref.watch(localPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('For You', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: feedAsync.when(
        data: (posts) {
          // Merge real posts and user posts, deduplicated
          final ids = posts.map((p) => p.id).toSet();
          final displayPosts = [...posts, ...localPosts.where((p) => !ids.contains(p.id))]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (displayPosts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, size: 64, color: AppColors.accent.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('No posts yet in SocFir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to ignite the universe! Tap + below to create a real post.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
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
          if (localPosts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, size: 64, color: AppColors.accent.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('No posts yet in SocFir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to ignite the universe! Tap + below to create a real post.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
            color: AppColors.accent,
            child: ListView.builder(
              itemCount: localPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: localPosts[index]);
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

