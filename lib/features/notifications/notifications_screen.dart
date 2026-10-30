import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../shared/theme/app_theme.dart';

// ─── NOTIFICATION PREFERENCES PROVIDER ───────────────────────────────────────

class NotifPrefs {
  final bool followerGrowth;
  final bool newConnections;
  final bool jobOffers;
  final bool postLikes;
  final bool postComments;
  final bool mentions;

  const NotifPrefs({
    this.followerGrowth = true,
    this.newConnections = true,
    this.jobOffers = true,
    this.postLikes = true,
    this.postComments = true,
    this.mentions = true,
  });

  NotifPrefs copyWith({
    bool? followerGrowth, bool? newConnections, bool? jobOffers,
    bool? postLikes, bool? postComments, bool? mentions,
  }) => NotifPrefs(
    followerGrowth: followerGrowth ?? this.followerGrowth,
    newConnections: newConnections ?? this.newConnections,
    jobOffers: jobOffers ?? this.jobOffers,
    postLikes: postLikes ?? this.postLikes,
    postComments: postComments ?? this.postComments,
    mentions: mentions ?? this.mentions,
  );
}

class NotifPrefsNotifier extends Notifier<NotifPrefs> {
  @override
  NotifPrefs build() => const NotifPrefs();
  void update(NotifPrefs Function(NotifPrefs) fn) => state = fn(state);
}

final notifPrefsProvider = NotifierProvider<NotifPrefsNotifier, NotifPrefs>(NotifPrefsNotifier.new);

// ─── SCREEN ──────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  final List<AppNotification> _notifications = [];

  IconData _icon(NotificationType t) {
    switch (t) {
      case NotificationType.like: return Icons.favorite;
      case NotificationType.comment: return Icons.chat_bubble;
      case NotificationType.follow: return Icons.person_add;
      case NotificationType.repost: return Icons.repeat;
      case NotificationType.mention: return Icons.alternate_email;
      case NotificationType.dm: return Icons.mail;
    }
  }

  Color _color(NotificationType t) {
    switch (t) {
      case NotificationType.like: return Colors.red;
      case NotificationType.follow: return Colors.blue;
      case NotificationType.repost: return Colors.green;
      case NotificationType.dm: return Colors.purple;
      default: return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(notifPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Activity'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── ACTIVITY TAB ──────────────────────────────────────────────────
          _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        const Text('All Caught Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'You have no new notifications.\nInteractions and mentions on your posts will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
                  itemBuilder: (context, i) {
              final n = _notifications[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: _color(n.type).withValues(alpha: 0.15),
                      child: Text(
                        n.actorUsername?[0].toUpperCase() ?? '?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _color(n.type)),
                      ),
                    ),
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          color: _color(n.type),
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: Icon(_icon(n.type), size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                title: Text(n.displayMessage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(
                  timeago.format(n.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                ),
              ).animate().fadeIn(delay: (i * 60).ms, duration: 300.ms).slideX(begin: 0.05, end: 0);
            },
          ),

          // ── SETTINGS TAB ─────────────────────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Notify me about', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _NotifToggle(
                icon: Icons.trending_up,
                label: 'Follower Growth',
                subtitle: 'When you gain new followers',
                color: Colors.blue,
                value: prefs.followerGrowth,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(followerGrowth: v)),
              ),
              _NotifToggle(
                icon: Icons.people,
                label: 'New Connections',
                subtitle: 'People you may know join SocFir',
                color: Colors.green,
                value: prefs.newConnections,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(newConnections: v)),
              ),
              _NotifToggle(
                icon: Icons.work,
                label: 'Job & Partnership Offers',
                subtitle: 'Career opportunities in your network',
                color: Colors.orange,
                value: prefs.jobOffers,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(jobOffers: v)),
              ),
              _NotifToggle(
                icon: Icons.favorite,
                label: 'Post Likes',
                subtitle: 'When someone likes your post',
                color: Colors.red,
                value: prefs.postLikes,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(postLikes: v)),
              ),
              _NotifToggle(
                icon: Icons.chat_bubble,
                label: 'Comments',
                subtitle: 'Replies to your posts',
                color: Colors.purple,
                value: prefs.postComments,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(postComments: v)),
              ),
              _NotifToggle(
                icon: Icons.alternate_email,
                label: 'Mentions',
                subtitle: 'When someone @mentions you',
                color: AppColors.accent,
                value: prefs.mentions,
                onChanged: (v) => ref.read(notifPrefsProvider.notifier).update((s) => s.copyWith(mentions: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── TOGGLE TILE ─────────────────────────────────────────────────────────────

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon, required this.label, required this.subtitle,
    required this.color, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: value ? color.withValues(alpha: 0.25) : Theme.of(context).dividerColor.withValues(alpha: 0.4)),
      ),
      child: SwitchListTile.adaptive(
        secondary: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        value: value,
        activeThumbColor: color,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
