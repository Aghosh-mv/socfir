import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/app_providers.dart';
import '../../supabase/supabase_service.dart';
import '../feed/posts_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final localPosts = ref.watch(localPostsProvider);

    // Compute dynamic leaderboard scores from actual registered accounts and activity
    final prefs = ref.watch(sharedPrefsProvider);
    final rawAccounts = prefs.getString('registered_users_db');
    List<Map<String, dynamic>> accounts = [];
    if (rawAccounts != null && rawAccounts.isNotEmpty) {
      try {
        final List decoded = jsonDecode(rawAccounts);
        accounts = decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    // Build real list of users
    List<SocFirUser> rankedUsers = [];
    for (final acc in accounts) {
      final username = acc['username'] ?? '';
      final userPosts = localPosts.where((p) => p.authorUsername == username).length;
      final score = (userPosts * 25.0) + (username == currentUser?.username ? 50.0 : 10.0);
      rankedUsers.add(SocFirUser(
        id: acc['id'] ?? 'user_$username',
        username: username,
        displayName: acc['display_name'] ?? username,
        email: acc['email'] ?? '',
        leaderboardScore: score,
        createdAt: DateTime.tryParse(acc['created_at'] ?? '') ?? DateTime.now(),
      ));
    }

    // If current logged in user not in accounts list yet, ensure they are represented
    if (currentUser != null && !rankedUsers.any((u) => u.username == currentUser.username)) {
      final userPosts = localPosts.where((p) => p.authorUsername == currentUser.username).length;
      final score = (userPosts * 25.0) + 50.0;
      rankedUsers.add(currentUser.copyWith(
        leaderboardScore: score,
      ));
    }

    // Sort descending by score
    rankedUsers.sort((a, b) => b.leaderboardScore.compareTo(a.leaderboardScore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Real-time ranking based on account sparks, posts published & platform activity.',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: rankedUsers.isEmpty
                ? Center(
                    child: Text(
                      'No ranked accounts yet.\nCreate an account and post to join the leaderboard!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                    ),
                  )
                : ListView.builder(
                    itemCount: rankedUsers.length,
                    itemBuilder: (context, index) {
                      final user = rankedUsers[index];
                      final isMe = currentUser != null && user.username == currentUser.username;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index < 3 ? AppColors.accent : Colors.grey.withValues(alpha: 0.2),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: index < 3 ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(user.displayName ?? user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (isMe) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('YOU', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('@${user.username}'),
                        trailing: Text(
                          '${user.leaderboardScore.toStringAsFixed(0)} pts',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

