import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          _SideNav(isDark: isDark),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideNav extends ConsumerWidget {
  final bool isDark;
  const _SideNav({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      _NavItem(icon: Icons.local_fire_department_rounded, label: 'Feed', route: '/feed'),
      _NavItem(icon: Icons.whatshot_rounded, label: 'SocialFire', route: '/socialfire'),
      _NavItem(icon: Icons.auto_graph_rounded, label: 'Insights', route: '/insights'),
      _NavItem(icon: Icons.videocam_rounded, label: 'Go Live', route: '/golive'),
      _NavItem(icon: Icons.emoji_events_rounded, label: 'Leaderboard', route: '/leaderboard'),
      _NavItem(icon: Icons.groups_rounded, label: 'Communities', route: '/communities'),
      _NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', route: '/chat'),
      _NavItem(icon: Icons.notifications_rounded, label: 'Notifications', route: '/notifications'),
      _NavItem(icon: Icons.favorite_rounded, label: 'Confessions', route: '/confessions'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile', route: '/profile/me'),
      _NavItem(icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
      _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin', route: '/admin'),
    ];

    return Container(
      width: 72,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo mark
          _SocFirLogoMark()
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.7, 0.7)),
          const SizedBox(height: 32),
          ...items.map((item) {
            final isActive = location.startsWith(item.route.split('/:').first);
            return _NavButton(item: item, isActive: isActive, isDark: isDark);
          }),
          const Spacer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDark;
  const _NavButton({required this.item, required this.isActive, required this.isDark});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.route),
        child: AnimatedContainer(
          duration: 200.ms,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accentGlow
                : _hovered
                    ? (widget.isDark ? Colors.white10 : Colors.black.withOpacity(0.05))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Tooltip(
            message: widget.item.label,
            preferBelow: false,
            child: Icon(
              widget.item.icon,
              size: 24,
              color: widget.isActive
                  ? AppColors.accent
                  : widget.isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocFirLogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final double r = size.width * 0.12;
    final double spacing = size.width * 0.32;
    final double startX = size.width * 0.18;
    final double circleY = size.height * 0.28;
    final double lineEndY = size.height * 0.85;

    // Draw 3 circles + lines (the SocFir logo mark)
    for (int i = 0; i < 3; i++) {
      final cx = startX + i * spacing;
      canvas.drawCircle(Offset(cx, circleY), r, fillPaint);
      canvas.drawLine(Offset(cx, circleY + r), Offset(cx, lineEndY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
