import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../shared/theme/app_theme.dart';
import '../../shared/utils/app_providers.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _starsController;      // twinkling stars
  late final AnimationController _astronautController;  // astronaut float
  late final AnimationController _zoomController;       // turbo zoom
  late final AnimationController _pulseController;      // pulse at white space
  late final AnimationController _logoController;       // logo appear + morph

  // Stars data
  final List<_Star> _stars = [];
  final math.Random _rng = math.Random(42);

  // Phase state
  _IntroPhase _phase = _IntroPhase.space;

  @override
  void initState() {
    super.initState();

    _generateStars();

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _astronautController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _runSequence();
  }

  void _generateStars() {
    for (int i = 0; i < 220; i++) {
      _stars.add(_Star(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: _rng.nextDouble() * 1.8 + 0.4,
        twinkleOffset: _rng.nextDouble(),
        speed: _rng.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  Future<void> _runSequence() async {
    // Phase 1: Space + astronaut floats by (0 → 1.3s)
    setState(() => _phase = _IntroPhase.space);
    _astronautController.forward();
    await Future.delayed(const Duration(milliseconds: 1300));

    // Phase 2: Turbo zoom (1.3s → 2.5s)
    setState(() => _phase = _IntroPhase.zoom);
    _zoomController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));

    // Phase 3: White space + abrupt stop + pulse (2.5s → 2.85s)
    setState(() => _phase = _IntroPhase.whiteSpace);
    _pulseController.forward();
    await Future.delayed(const Duration(milliseconds: 350));

    // Phase 4: Logo appears (2.85s → 3.1s)
    setState(() => _phase = _IntroPhase.logo);
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Phase 5: Morph to humans (3.1s → 3.4s)
    setState(() => _phase = _IntroPhase.humans);
    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 6: Navigate to app
    if (mounted) {
      final isFirst = ref.read(isFirstLaunchProvider);
      if (isFirst) {
        context.go('/onboarding');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _starsController.dispose();
    _astronautController.dispose();
    _zoomController.dispose();
    _pulseController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.universeBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Cinematic Space Nebula Artwork
          if (_phase == _IntroPhase.space || _phase == _IntroPhase.zoom)
            Image.network(
              'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),

          // Layer 1: Dynamic Star field & cosmic glow overlay
          if (_phase == _IntroPhase.space || _phase == _IntroPhase.zoom)
            AnimatedBuilder(
              animation: _starsController,
              builder: (_, __) => CustomPaint(
                painter: _StarFieldPainter(
                  stars: _stars,
                  progress: _starsController.value,
                  zoomProgress: _phase == _IntroPhase.zoom ? _zoomController.value : 0.0,
                ),
              ),
            ),

          // Layer 2: Astronaut
          if (_phase == _IntroPhase.space)
            AnimatedBuilder(
              animation: _astronautController,
              builder: (_, __) {
                final t = _astronautController.value;
                return Positioned(
                  left: MediaQuery.of(context).size.width * (0.15 + t * 0.72),
                  top: MediaQuery.of(context).size.height * (0.45 + math.sin(t * math.pi) * 0.06),
                  child: Opacity(
                    opacity: t < 0.1 ? t / 0.1 : (t > 0.85 ? (1 - t) / 0.15 : 1.0),
                    child: Transform.rotate(
                      angle: math.sin(t * math.pi * 2) * 0.08,
                      child: const _AstronautWidget(),
                    ),
                  ),
                );
              },
            ),

          // Layer 3: Zoom motion blur overlay
          if (_phase == _IntroPhase.zoom)
            AnimatedBuilder(
              animation: _zoomController,
              builder: (_, __) => CustomPaint(
                painter: _ZoomBlurPainter(progress: _zoomController.value),
              ),
            ),

          // Layer 4: White space flash
          if (_phase == _IntroPhase.whiteSpace || _phase == _IntroPhase.logo || _phase == _IntroPhase.humans)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final pulse = math.sin(_pulseController.value * math.pi);
                return Container(
                  color: Color.lerp(Colors.white, const Color(0xFFF8F8FF), 1 - pulse * 0.3),
                );
              },
            ),

          // Layer 5: SocFir Logo
          if (_phase == _IntroPhase.logo)
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (_, __) => Opacity(
                  opacity: _logoController.value,
                  child: Transform.scale(
                    scale: 0.7 + _logoController.value * 0.3,
                    child: const _SocFirLogo(showHumans: false),
                  ),
                ),
              ),
            ),

          // Layer 6: Morphed humans
          if (_phase == _IntroPhase.humans)
            Center(
              child: const _SocFirLogo(showHumans: true)
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ),
        ],
      ),
    );
  }
}

enum _IntroPhase { space, zoom, whiteSpace, logo, humans }

// ─── Star data model ──────────────────────────────────────────────────────────
class _Star {
  final double x, y, radius, twinkleOffset, speed;
  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.twinkleOffset,
    required this.speed,
  });
}

// ─── Star field painter ───────────────────────────────────────────────────────
class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  final double zoomProgress;

  _StarFieldPainter({required this.stars, required this.progress, required this.zoomProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final twinkle = (math.sin((progress * star.speed + star.twinkleOffset) * math.pi * 2) + 1) / 2;
      final opacity = (0.4 + twinkle * 0.6).clamp(0.0, 1.0);

      double x = star.x * size.width;
      double y = star.y * size.height;
      double r = star.radius;

      // During zoom: stars streak horizontally from center
      if (zoomProgress > 0) {
        final cx = size.width / 2;
        final cy = size.height / 2;
        final dx = x - cx;
        final dy = y - cy;
        final stretch = 1 + zoomProgress * 18;
        x = cx + dx * stretch;
        y = cy + dy * stretch;
        r = (star.radius * (1 + zoomProgress * 2)).clamp(0.5, 4.0);

        // Draw streaks
        if (zoomProgress > 0.1) {
          final streakPaint = Paint()
            ..color = Colors.white.withOpacity(opacity * 0.6)
            ..strokeWidth = r * 0.6
            ..style = PaintingStyle.stroke;
          canvas.drawLine(
            Offset(cx + dx, cy + dy),
            Offset(x, y),
            streakPaint,
          );
        }
      }

      paint.color = Colors.white.withOpacity(opacity.toDouble());
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => true;
}

// ─── Zoom blur overlay ────────────────────────────────────────────────────────
class _ZoomBlurPainter extends CustomPainter {
  final double progress;
  _ZoomBlurPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Radial vignette that intensifies as we zoom
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.6,
      colors: [
        Colors.transparent,
        AppColors.universeBg.withOpacity((progress * 0.7).clamp(0.0, 0.7)),
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // White flash at end
    if (progress > 0.8) {
      final flash = (progress - 0.8) / 0.2;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(flash),
      );
    }
  }

  @override
  bool shouldRepaint(_ZoomBlurPainter old) => old.progress != progress;
}

// ─── Astronaut widget ─────────────────────────────────────────────────────────
class _AstronautWidget extends StatelessWidget {
  const _AstronautWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(56, 72),
      painter: _AstronautPainter(),
    );
  }
}

class _AstronautPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final visor = Paint()..color = const Color(0xFF88CCFF)..style = PaintingStyle.fill;
    final darkBlue = Paint()..color = const Color(0xFF1A3A5C)..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Body (suit)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.5), const Radius.circular(10)),
      white,
    );

    // Helmet
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.28, white);

    // Visor
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.2), width: w * 0.32, height: h * 0.18), visor);

    // Reflection on visor
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.44, h * 0.16), width: w * 0.08, height: h * 0.05),
      Paint()..color = Colors.white60,
    );

    // Arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.35, w * 0.18, h * 0.22), const Radius.circular(6)),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.82, h * 0.35, w * 0.18, h * 0.22), const Radius.circular(6)),
      white,
    );

    // Legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.76, w * 0.22, h * 0.2), const Radius.circular(5)),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.56, h * 0.76, w * 0.22, h * 0.2), const Radius.circular(5)),
      white,
    );

    // Backpack (jetpack)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.7, h * 0.36, w * 0.16, h * 0.28), const Radius.circular(5)),
      darkBlue,
    );

    // Chest badge (SocFir accent dot)
    canvas.drawCircle(Offset(w * 0.5, h * 0.52), w * 0.07, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── SocFir Logo ──────────────────────────────────────────────────────────────
class _SocFirLogo extends StatelessWidget {
  final bool showHumans;
  const _SocFirLogo({required this.showHumans});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(160, 120),
          painter: showHumans ? _HumansPainter() : _LogoMarkPainter(),
        ),
        if (!showHumans) ...[
          const SizedBox(height: 20),
          const Text(
            'SocFir',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Text(
            'SocialFire',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 6,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.black87..style = PaintingStyle.fill;
    final line = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double r = size.width * 0.1;
    final double spacing = size.width * 0.35;
    final double startX = size.width * 0.15;
    final double cy = size.height * 0.25;
    final double lineEnd = size.height * 0.88;

    for (int i = 0; i < 3; i++) {
      final cx = startX + i * spacing;
      canvas.drawCircle(Offset(cx, cy), r, fill);
      canvas.drawLine(Offset(cx, cy + r + 2), Offset(cx, lineEnd), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _HumansPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final accent = Paint()..color = AppColors.accent..style = PaintingStyle.fill;
    final accentLine = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final double r = size.width * 0.095;
    final double spacing = size.width * 0.35;
    final double startX = size.width * 0.15;
    final double cy = size.height * 0.22;
    final double shoulderY = cy + r + 6;
    final double hipY = shoulderY + size.height * 0.28;
    final double footY = hipY + size.height * 0.28;

    for (int i = 0; i < 3; i++) {
      final cx = startX + i * spacing;

      // Head
      canvas.drawCircle(Offset(cx, cy), r, accent);

      // Body
      canvas.drawLine(Offset(cx, shoulderY), Offset(cx, hipY), accentLine);

      // Arms (spread out)
      canvas.drawLine(Offset(cx - r * 1.6, shoulderY + size.height * 0.08), Offset(cx, shoulderY + size.height * 0.04), accentLine);
      canvas.drawLine(Offset(cx, shoulderY + size.height * 0.04), Offset(cx + r * 1.6, shoulderY + size.height * 0.08), accentLine);

      // Legs
      canvas.drawLine(Offset(cx, hipY), Offset(cx - r * 1.2, footY), accentLine);
      canvas.drawLine(Offset(cx, hipY), Offset(cx + r * 1.2, footY), accentLine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
