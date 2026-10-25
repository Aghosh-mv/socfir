import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/app_providers.dart';
import '../auth/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('App Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between dark and light themes'),
            value: isDark,
            onChanged: (val) {
              ref.read(isDarkModeProvider.notifier).toggle();
            },
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            activeThumbColor: Theme.of(context).primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.color_lens, size: 24),
                const SizedBox(width: 16),
                const Text('Accent Color', style: TextStyle(fontSize: 16)),
                const Spacer(),
                ...[
                  const Color(0xFFFF4E00), // Default Orange
                  Colors.blue,
                  Colors.purple,
                  Colors.green,
                ].map((color) => GestureDetector(
                      onTap: () => ref.read(accentColorProvider.notifier).setColor(color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ref.watch(accentColorProvider) == color ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy & Safety'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Preferences'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/intro');
            },
          ),
        ],
      ),
    );
  }
}

