import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../shared/theme/app_theme.dart';
import '../feed/widgets/post_card.dart';
import '../feed/feed_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, mock a user. In reality, fetch from Supabase.
    final user = SocFirUser(
      id: 'mock-1',
      username: username,
      displayName: username == 'me' ? 'Tinker Space' : 'Awesome User',
      email: 'hello@example.com',
      bio: 'Building the future of social media, one flutter widget at a time.',
      followersCount: 1337,
      followingCount: 42,
      likesCount: 9001,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final posts = ref.watch(dummyPostsProvider);

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
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
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
                return PostCard(post: posts[index]);
              },
              childCount: posts.length,
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

