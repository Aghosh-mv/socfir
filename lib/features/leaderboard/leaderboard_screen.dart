import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../shared/theme/app_theme.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock users
    final topUsers = [
      SocFirUser(id: '1', username: 'tinkerspace', displayName: 'Tinker Space', email: '', leaderboardRank: 1, leaderboardScore: 15420.5, createdAt: DateTime.now()),
      SocFirUser(id: '2', username: 'devgirl', displayName: 'Jane Dev', email: '', leaderboardRank: 2, leaderboardScore: 12050.0, createdAt: DateTime.now()),
      SocFirUser(id: '3', username: 'flutter_guru', displayName: 'Flutter Guru', email: '', leaderboardRank: 3, leaderboardScore: 11000.2, createdAt: DateTime.now()),
      SocFirUser(id: '4', username: 'ui_ux_master', displayName: 'Design God', email: '', leaderboardRank: 4, leaderboardScore: 9500.0, createdAt: DateTime.now()),
    ];

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
                    'Score = (Followers × 3) + Likes + (Views × 0.1) + (Posts × 0.5)',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: topUsers.length,
              itemBuilder: (context, index) {
                final user = topUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index < 3 ? AppColors.accent : Colors.grey.withValues(alpha: 0.2),
                    child: Text(
                      '#${user.leaderboardRank}',
                      style: TextStyle(
                        color: index < 3 ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user.displayName ?? user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('@${user.username}'),
                  trailing: Text(
                    '${user.leaderboardScore.toStringAsFixed(1)} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

