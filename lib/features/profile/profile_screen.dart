import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/post_model.dart';
import '../../shared/theme/app_theme.dart';
import '../../supabase/supabase_service.dart';
import '../auth/auth_service.dart';
import '../feed/posts_service.dart';
import '../feed/widgets/post_card.dart';

class ProfileScreen extends ConsumerWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    // Determine profile data: if viewing own profile, use actual currentUser data
    final isMe = username == 'me' || (currentUser != null && currentUser.username == username);
    final user = isMe ? currentUser : null;

    final allLocalPosts = ref.watch(localPostsProvider);
    final userPosts = user != null
        ? allLocalPosts.where((p) => p.authorUsername == user.username || (isMe && p.userId == user.id)).toList()
        : <Post>[];

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('@$username', style: const TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 72, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                const Text('Profile Not Set Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'This profile is completely blank until the user adds their details and starts posting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null ? const Icon(Icons.person, size: 40, color: AppColors.accent) : null,
                      ),
                      if (!isMe)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(authServiceProvider).signOut();
                            if (context.mounted) context.go('/intro');
                          },
                          icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                          label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(user.displayName ?? user.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('@${user.username}', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 16)),
                  const SizedBox(height: 16),
                  if (user.bio.isNotEmpty) Text(user.bio, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStat('${user.followersCount}', 'Followers'),
                      const SizedBox(width: 16),
                      _buildStat('${user.followingCount}', 'Following'),
                      const SizedBox(width: 16),
                      _buildStat('${user.likesCount}', 'Likes'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Posts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (userPosts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.feed_outlined, size: 48, color: Colors.grey.shade600),
                          const SizedBox(height: 12),
                          Text('No posts yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                }
                return PostCard(post: userPosts[index]);
              },
              childCount: userPosts.isEmpty ? 1 : userPosts.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Row(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}

