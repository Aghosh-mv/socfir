import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/intro/intro_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/setup_wizard_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/communities/communities_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../shared/widgets/main_shell.dart';

import '../features/auth/login_screen.dart';
import '../features/admin/admin_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/golive/go_live_screen.dart';
import '../features/socialfire/social_fire_screen.dart';
import '../features/confessions/secret_confessions_screen.dart';

import '../shared/utils/app_providers.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(isLoggedInProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    initialLocation: '/intro',
    refreshListenable: notifier,
    redirect: (context, state) {
      bool isAuthenticated = false;
      try {
        isAuthenticated = Supabase.instance.client.auth.currentSession != null;
      } catch (_) {}
      if (!isAuthenticated) {
        isAuthenticated = ref.read(isLoggedInProvider);
      }

      final path = state.matchedLocation;
      final isIntro = path == '/intro';
      final isAuth = path.startsWith('/onboarding') || path.startsWith('/setup') || path == '/login';

      if (isIntro || isAuth) return null;
      if (!isAuthenticated) return '/intro';
      return null;
    },
    routes: [
      GoRoute(path: '/intro', builder: (ctx, state) => const IntroScreen()),
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (ctx, state) => const OnboardingScreen()),
      GoRoute(path: '/setup', builder: (ctx, state) => const SetupWizardScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (ctx, state) => const FeedScreen()),
          GoRoute(
            path: '/profile/:username',
            builder: (ctx, state) => ProfileScreen(username: state.pathParameters['username']!),
          ),
          GoRoute(path: '/leaderboard', builder: (ctx, state) => const LeaderboardScreen()),
          GoRoute(path: '/communities', builder: (ctx, state) => const CommunitiesScreen()),
          GoRoute(path: '/chat', builder: (ctx, state) => const ChatScreen()),
          GoRoute(path: '/notifications', builder: (ctx, state) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
          GoRoute(path: '/insights', builder: (ctx, state) => const InsightsScreen()),
          GoRoute(path: '/golive', builder: (ctx, state) => const GoLiveScreen()),
          GoRoute(path: '/admin', builder: (ctx, state) => const AdminScreen()),
          GoRoute(path: '/socialfire', builder: (ctx, state) => const SocialFireScreen()),
          GoRoute(path: '/confessions', builder: (ctx, state) => const SecretConfessionsScreen()),
        ],
      ),
    ],
  );
});
