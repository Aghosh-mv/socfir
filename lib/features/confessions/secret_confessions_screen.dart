import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/theme/app_theme.dart';

// ─── PROVIDERS ───────────────────────────────────────────────────────────────

// Stores up to 3 crush usernames
class CrushListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void add(String username) { if (state.length < 3 && !state.contains(username)) state = [...state, username]; }
  void remove(int index) { final updated = [...state]; updated.removeAt(index); state = updated; }
}
final crushedUsernamesProvider = NotifierProvider<CrushListNotifier, List<String>>(CrushListNotifier.new);

class HeartbeatNotifier extends Notifier<bool> {
  @override bool build() => true;
  void toggle() => state = !state;
}
final heartbeatSyncEnabledProvider = NotifierProvider<HeartbeatNotifier, bool>(HeartbeatNotifier.new);

class CrushMatchNotifier extends Notifier<String?> {
  @override String? build() => null;
  void set(String? v) => state = v;
}
final crushMatchProvider = NotifierProvider<CrushMatchNotifier, String?>(CrushMatchNotifier.new);

// ─── SCREEN ──────────────────────────────────────────────────────────────────

class SecretConfessionsScreen extends ConsumerWidget {
  const SecretConfessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crushes = ref.watch(crushedUsernamesProvider);
    final heartbeatOn = ref.watch(heartbeatSyncEnabledProvider);
    final match = ref.watch(crushMatchProvider);

    // Show match overlay when a mutual crush is detected
    if (match != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMatchOverlay(context, ref, match);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🤫', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Secret Confessions', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heartbeat Sync Toggle ──────────────────────────────────────
            _SectionCard(
              icon: Icons.favorite,
              iconColor: Colors.redAccent,
              title: 'Heartbeat Sync',
              subtitle: 'When you\'re both in the same DM at the same time, your phones pulse together. Only you two will know.',
              trailing: Switch.adaptive(
                value: heartbeatOn,
                activeThumbColor: Colors.redAccent,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  ref.read(heartbeatSyncEnabledProvider.notifier).toggle();
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Secret Crushes ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💘', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Secret Crushes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            SizedBox(height: 2),
                            Text('Tag up to 3 people. They\'ll never know… unless they tag you back.',
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Crush slots
                  ...List.generate(3, (i) {
                    final hasCrush = i < crushes.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CrushSlot(
                        index: i,
                        username: hasCrush ? crushes[i] : null,
                        onAdd: () => _showAddCrushDialog(context, ref, crushes),
                        onRemove: () {
                          ref.read(crushedUsernamesProvider.notifier).remove(i);
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  // Simulate match button (demo only)
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.auto_awesome, color: Colors.pinkAccent),
                      label: const Text('Simulate a Match (Demo)', style: TextStyle(color: Colors.pinkAccent)),
                      onPressed: () {
                        if (crushes.isNotEmpty) {
                          ref.read(crushMatchProvider.notifier).set(crushes.first);
                          _showMatchOverlay(context, ref, crushes.first);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add a crush first!')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tip banner ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Text('🔒', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your confessions are encrypted. Nobody — not even SocFir — can read who you tagged. '
                      'Only a mutual match breaks the seal.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCrushDialog(BuildContext context, WidgetRef ref, List<String> current) {
    if (current.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 3 secret crushes!')));
      return;
    }
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Secret Crush 💘'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '@username',
            prefixText: '@',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final username = ctrl.text.trim();
              if (username.isNotEmpty && !current.contains(username)) {
                ref.read(crushedUsernamesProvider.notifier).add(username);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMatchOverlay(BuildContext context, WidgetRef ref, String username) {
    ref.read(crushMatchProvider.notifier).set(null);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim, _) => _MatchOverlay(username: username, ref: ref),
      transitionBuilder: (ctx, anim, _, child) {
        return ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut), child: child);
      },
    );
  }
}

// ─── CRUSH SLOT ───────────────────────────────────────────────────────────────

class _CrushSlot extends StatelessWidget {
  final int index;
  final String? username;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _CrushSlot({required this.index, this.username, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        color: username != null
            ? Colors.pinkAccent.withValues(alpha: 0.08)
            : Theme.of(context).dividerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: username != null ? Colors.pinkAccent.withValues(alpha: 0.35) : Theme.of(context).dividerColor,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: username != null
              ? Colors.pinkAccent.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          child: Text(
            username != null ? username![0].toUpperCase() : '${index + 1}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: username != null ? Colors.pinkAccent : Colors.grey,
            ),
          ),
        ),
        title: Text(
          username != null ? '@$username' : 'Empty slot — tap to add',
          style: TextStyle(
            color: username != null ? null : Colors.grey,
            fontStyle: username != null ? FontStyle.normal : FontStyle.italic,
            fontSize: 14,
          ),
        ),
        trailing: username != null
            ? IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.grey), onPressed: onRemove)
            : IconButton(icon: const Icon(Icons.add, color: Colors.pinkAccent), onPressed: onAdd),
        onTap: username == null ? onAdd : null,
      ),
    );
  }
}

// ─── MATCH OVERLAY ────────────────────────────────────────────────────────────

class _MatchOverlay extends StatelessWidget {
  final String username;
  final WidgetRef ref;
  const _MatchOverlay({required this.username, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💘', style: TextStyle(fontSize: 80))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 600.ms),
            const SizedBox(height: 24),
            const Text(
              'IT\'S A MATCH!',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ).animate().shimmer(duration: 1200.ms, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              '@$username secretly tagged you too.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              icon: const Icon(Icons.mic),
              label: const Text('Open Voice Room together', style: TextStyle(fontSize: 16)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe later', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION CARD HELPER ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SectionCard({required this.icon, required this.iconColor, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
