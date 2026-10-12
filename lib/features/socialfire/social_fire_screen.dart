import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../shared/theme/app_theme.dart';

// ─── DATA MODEL ──────────────────────────────────────────────────────────────

class FireViewer {
  final String username;
  final String? avatarUrl;
  final bool isHidden;
  FireViewer({required this.username, this.avatarUrl, this.isHidden = false});
}

// ─── PROVIDER ────────────────────────────────────────────────────────────────

final socialFireProvider = Provider<List<_FirePost>>((ref) => _dummyPosts);

final _dummyPosts = [
  _FirePost(
    id: '1',
    content: 'Just shipped SocFir v1 — the fastest social app alive 🔥',
    likes: 142,
    comments: 38,
    views: 1820,
    postedAt: DateTime.now().subtract(const Duration(hours: 2)),
    viewers: [
      FireViewer(username: 'devgirl'),
      FireViewer(username: 'flutter_guru'),
      FireViewer(username: 'ui_master'),
      FireViewer(username: 'someone', isHidden: true),
      FireViewer(username: 'another_user'),
    ],
  ),
  _FirePost(
    id: '2',
    content: 'Dark mode + orange accents = premium perfection 🧡',
    likes: 67,
    comments: 12,
    views: 540,
    postedAt: DateTime.now().subtract(const Duration(hours: 8)),
    viewers: [
      FireViewer(username: 'fanboy_42'),
      FireViewer(username: 'kode_lover'),
    ],
  ),
  _FirePost(
    id: '3',
    content: 'Just added Whispers to DMs. Some secrets deserve to burn.',
    likes: 21,
    comments: 5,
    views: 98,
    postedAt: DateTime.now().subtract(const Duration(days: 1)),
    viewers: [
      FireViewer(username: 'curious_cat'),
    ],
  ),
];

// ─── MODEL ───────────────────────────────────────────────────────────────────

class _FirePost {
  final String id;
  final String content;
  final int likes;
  final int comments;
  final int views;
  final DateTime postedAt;
  final List<FireViewer> viewers;

  _FirePost({
    required this.id,
    required this.content,
    required this.likes,
    required this.comments,
    required this.views,
    required this.postedAt,
    required this.viewers,
  });

  // Score = views + likes×5 + comments×8 → bigger = bigger fire
  double get fireScore => views + likes * 5.0 + comments * 8.0;
}

// ─── SCREEN ──────────────────────────────────────────────────────────────────

class SocialFireScreen extends ConsumerWidget {
  const SocialFireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(socialFireProvider);
    final maxScore = posts.isEmpty ? 1.0 : posts.map((p) => p.fireScore).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('SocialFire', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = posts[index];
          final ratio = (post.fireScore / maxScore).clamp(0.05, 1.0);
          return _FirePostCard(post: post, fireRatio: ratio)
              .animate()
              .fadeIn(delay: (index * 80).ms, duration: 350.ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

// ─── FIRE POST CARD ───────────────────────────────────────────────────────────

class _FirePostCard extends StatefulWidget {
  final _FirePost post;
  final double fireRatio;
  const _FirePostCard({required this.post, required this.fireRatio});

  @override
  State<_FirePostCard> createState() => _FirePostCardState();
}

class _FirePostCardState extends State<_FirePostCard> {
  bool _showViewers = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final r = widget.fireRatio;

    // Fire intensity colours
    final Color fireColor = r > 0.7
        ? Colors.deepOrange
        : r > 0.4
            ? Colors.orange
            : Colors.amber;

    final int flameCount = (r * 5).ceil().clamp(1, 5);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fireColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: fireColor.withValues(alpha: r * 0.2),
            blurRadius: 24 * r,
            spreadRadius: 2 * r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fire bar ──────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: Stack(
              children: [
                // Background
                Container(height: 6, color: Colors.black12),
                // Animated fill
                AnimatedContainer(
                  duration: 900.ms,
                  curve: Curves.easeOut,
                  height: 6,
                  width: (MediaQuery.of(context).size.width - 32) * r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber, Colors.deepOrange, fireColor]),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flame emoji row
                Row(
                  children: [
                    ...List.generate(flameCount, (i) => Text(
                      '🔥',
                      style: TextStyle(fontSize: 14 + (r * 6)),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05),
                            duration: (400 + i * 60).ms)),
                    const Spacer(),
                    Text(
                      timeago.format(p.postedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  p.content,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),

                // ── Stats row ────────────────────────────────────────────────
                Row(
                  children: [
                    _Stat(icon: Icons.favorite, value: p.likes, color: Colors.red),
                    const SizedBox(width: 16),
                    _Stat(icon: Icons.chat_bubble, value: p.comments, color: Colors.blue),
                    const SizedBox(width: 16),
                    _Stat(icon: Icons.bar_chart, value: p.views, color: Colors.grey),
                    const Spacer(),
                    // "Who saw this?" button
                    GestureDetector(
                      onTap: () => setState(() => _showViewers = !_showViewers),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showViewers
                              ? fireColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          border: Border.all(color: fireColor.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showViewers ? Icons.visibility_off : Icons.visibility,
                              size: 14, color: fireColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showViewers ? 'Hide' : 'Who saw this',
                              style: TextStyle(fontSize: 12, color: fireColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Viewers list ──────────────────────────────────────────────
                if (_showViewers) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    'Seen by ${p.viewers.length} people',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: p.viewers.map((v) {
                      if (v.isHidden) {
                        return const Chip(
                          avatar: Icon(Icons.visibility_off, size: 14),
                          label: Text('Hidden user', style: TextStyle(fontSize: 11)),
                          padding: EdgeInsets.symmetric(horizontal: 4),
                        );
                      }
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.orange.withValues(alpha: 0.3),
                          child: Text(
                            v.username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                        ),
                        label: Text('@${v.username}', style: const TextStyle(fontSize: 11)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, end: 0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  const _Stat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text('$value', style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
    ],
  );
}
