import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart via ProviderScope overrides');
});

/// Tracks whether this is the user's first launch
final isFirstLaunchProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('is_first_launch') ?? true;
});

// ─── Theme Mode ───────────────────────────────────────────────────────────────

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool('is_dark_mode') ?? true;
  }

  void toggle() {
    state = !state;
    ref.read(sharedPrefsProvider).setBool('is_dark_mode', state);
  }

  void set(bool isDark) {
    state = isDark;
    ref.read(sharedPrefsProvider).setBool('is_dark_mode', isDark);
  }
}

/// Theme mode: true = dark, false = light
final isDarkModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

class AccentColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final colorVal = prefs.getInt('accent_color');
    return colorVal != null ? Color(colorVal) : const Color(0xFFFF4E00);
  }

  void setColor(Color color) {
    state = color;
    ref.read(sharedPrefsProvider).setInt('accent_color', color.value);
  }
}

final accentColorProvider = NotifierProvider<AccentColorNotifier, Color>(
  AccentColorNotifier.new,
);

class HeartbeatSyncNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool('heartbeat_sync') ?? true; // Default true
  }

  void toggle() {
    final newValue = !state;
    state = newValue;
    ref.read(sharedPrefsProvider).setBool('heartbeat_sync', newValue);
  }
}

final heartbeatSyncProvider = NotifierProvider<HeartbeatSyncNotifier, bool>(
  HeartbeatSyncNotifier.new,
);

class AuthStatusNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider);
    return prefs.getBool('is_logged_in') ?? false;
  }

  void login() {
    state = true;
    ref.read(sharedPrefsProvider).setBool('is_logged_in', true);
  }

  void logout() {
    state = false;
    ref.read(sharedPrefsProvider).setBool('is_logged_in', false);
  }
}

final isLoggedInProvider = NotifierProvider<AuthStatusNotifier, bool>(
  AuthStatusNotifier.new,
);

