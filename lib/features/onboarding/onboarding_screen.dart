import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/utils/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.local_fire_department_rounded,
      'title': 'Welcome to SocFir 🔥',
      'desc': 'Like Twitter, Instagram, and LinkedIn had a really cool, chaotic baby. You’ll love it.',
    },
    {
      'icon': Icons.auto_awesome_motion_rounded,
      'title': 'Cards & Carousels',
      'desc': 'Upload multiple images, and we’ll magically turn them into interactive Cards. Hover over them and see the magic.',
    },
    {
      'icon': Icons.groups_3_rounded,
      'title': 'Communities & Vibes',
      'desc': 'Join spaces that match your energy. 13+? 18+? We blur the bad stuff automatically based on your age.',
    },
    {
      'icon': Icons.leaderboard_rounded,
      'title': 'Climb the Ranks',
      'desc': 'A global popularity leaderboard. Post fire, get likes, and become the main character of the universe.',
    }
  ];

  void _next() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      ref.read(sharedPrefsProvider).setBool('is_first_launch', false);
      context.go('/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      slide['icon'],
                      size: 100,
                      color: AppColors.accent,
                    ).animate().scale(delay: 100.ms, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 48),
                    Text(
                      slide['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().slideY(begin: 0.5, end: 0, duration: 400.ms).fadeIn(),
                    const SizedBox(height: 16),
                    Text(
                      slide['desc'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ).animate().slideY(begin: 0.5, end: 0, delay: 100.ms, duration: 400.ms).fadeIn(),
                  ],
                ),
              );
            },
          ),
          
          // Navigation controls
          Positioned(
            bottom: 48,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.accent
                            : AppColors.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next Button
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _slides.length - 1 ? 'Start Setup' : 'Next',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

