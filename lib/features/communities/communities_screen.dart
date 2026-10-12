import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/community_model.dart';
import '../../shared/theme/app_theme.dart';

class CommunitiesScreen extends ConsumerWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = [
      Community(id: '1', name: 'Flutter Devs', description: 'Everything flutter.', membersCount: 450, createdAt: DateTime.now()),
      Community(id: '2', name: 'UI/UX Design', description: 'Make it pop.', membersCount: 1200, createdAt: DateTime.now()),
      Community(id: '3', name: 'NSFW Content', description: '18+ only.', ageRestriction: '18plus', membersCount: 69, createdAt: DateTime.now()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final comm = communities[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.groups, color: AppColors.accent),
              ),
              title: Text(comm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(comm.description),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (comm.ageRestriction == '18plus') 
                    const Text('18+', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  Text('${comm.membersCount} members', style: const TextStyle(fontSize: 12)),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

