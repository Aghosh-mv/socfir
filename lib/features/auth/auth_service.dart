import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../../supabase/supabase_service.dart';
import '../../shared/utils/app_providers.dart';
import '../../shared/utils/email_verifier.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider), ref);
});

class AuthService {
  final SupabaseClient _client;
  final Ref _ref;

  AuthService(this._client, this._ref);

  /// Hash password using a salted base64 encoding
  String _hashPassword(String email, String password) {
    final salt = 'socfir_salt_${email.toLowerCase()}';
    return base64.encode(utf8.encode('$salt:$password'));
  }

  /// Helper to get local user database from SharedPreferences
  List<Map<String, dynamic>> _getLocalAccounts() {
    final prefs = _ref.read(sharedPrefsProvider);
    final raw = prefs.getString('registered_users_db');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List decoded = jsonDecode(raw);
        return decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  /// Ensure dev account exists (debug mode only)
  Future<void> _ensureDevAccount() async {
    if (!kDebugMode) return;
    final accounts = _getLocalAccounts();
    final has = accounts.any((a) => a['email'] == 'aghoshpratheesh@gmail.com');
    if (!has) {
      accounts.add({
        'id': 'dev_user_1',
        'email': 'aghoshpratheesh@gmail.com',
        'password': _hashPassword('aghoshpratheesh@gmail.com', '123123123'),
        'username': 'socfirdev',
        'display_name': 'socfirdev',
        'age': 21,
        'bio': 'Developer & Founder of SocFir 🔥',
        'created_at': DateTime.now().toIso8601String(),
      });
      await _saveLocalAccounts(accounts);
    }
  }

  /// Helper to save local user database to SharedPreferences
  Future<void> _saveLocalAccounts(List<Map<String, dynamic>> accounts) async {
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.setString('registered_users_db', jsonEncode(accounts));
  }

  /// Current user ID: try Supabase first, then fall back to SharedPreferences
  String? get currentUserId {
    try {
      final sbId = _client.auth.currentUser?.id;
      if (sbId != null) return sbId;
    } catch (_) {}
    return _ref.read(sharedPrefsProvider).getString('current_user_id');
  }

  /// Real Account Registration
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required int age,
    String? displayName,
    String? bio,
    String? education,
    List<String> hobbies = const [],
    List<String> projects = const [],
    List<String> jobs = const [],
  }) async {
    // 1. Email verification & domain check (live DNS verification)
    final verification = await EmailVerifier.verifyEmailLive(email);
    if (!verification.isValid) {
      throw Exception(verification.errorMessage ?? 'Invalid email address.');
    }

    // 2. Age cross-check against email birth year
    final ageMismatch = EmailVerifier.verifyAgeMatch(email: email, enteredAge: age);
    if (ageMismatch != null) {
      throw Exception(ageMismatch);
    }

    // 3. Password length check
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    // 4. Username check
    if (username.trim().isEmpty) {
      throw Exception('Username cannot be empty.');
    }

    await _ensureDevAccount();
    final localAccounts = _getLocalAccounts();

    // Check for duplicate username or email
    final exists = localAccounts.any((acc) =>
        acc['email'].toString().toLowerCase() == email.toLowerCase() ||
        acc['username'].toString().toLowerCase() == username.toLowerCase());

    if (exists) {
      throw Exception('An account with this email or username already exists.');
    }

    String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Try live Supabase Auth
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        userId = res.user!.id;

        await _client.from('socfir_users').insert({
          'id': userId,
          'username': username,
          'display_name': displayName,
          'email': email,
          'avatar_url': null,
          'age': age,
          'bio': bio ?? '',
          'education': education ?? '',
          'hobbies': hobbies,
          'projects': projects,
          'jobs': jobs,
          'is_onboarded': true,
        });
      }
    } catch (_) {
      // Supabase is offline or using placeholder keys
    }

    final newUser = SocFirUser(
      id: userId,
      username: username,
      email: email,
      displayName: displayName?.isNotEmpty == true ? displayName : username,
      avatarUrl: null, // Blank until user adds a profile picture
      age: age,
      bio: bio ?? '',
      education: education ?? '',
      hobbies: hobbies,
      projects: projects,
      jobs: jobs,
      isOnboarded: true,
      createdAt: DateTime.now(),
    );

    // Save to local user database with hashed password
    final accountRecord = {
      'id': userId,
      'email': email.toLowerCase(),
      'password': _hashPassword(email, password),
      'username': username,
      'display_name': displayName ?? username,
      'age': age,
      'user_data': newUser.toJson(),
      'created_at': DateTime.now().toIso8601String(),
    };

    localAccounts.add(accountRecord);
    await _saveLocalAccounts(localAccounts);

    // Persist current_user_id for local use
    await _ref.read(sharedPrefsProvider).setString('current_user_id', userId);

    // Set active user & login state
    _ref.read(isLoggedInProvider.notifier).login();
    _ref.read(currentUserProvider.notifier).setUser(newUser);
  }

  /// Real Account Authentication (Sign In)
  Future<void> signIn(String emailOrUsername, String password) async {
    final query = emailOrUsername.trim().toLowerCase();
    final pass = password; // Do NOT trim passwords

    if (query.isEmpty || pass.isEmpty) {
      throw Exception('Please fill in both email/username and password.');
    }

    await _ensureDevAccount();

    bool supabaseSuccess = false;

    // Try live Supabase Auth first (only if it looks like an email)
    if (query.contains('@')) {
      try {
        final res = await _client.auth.signInWithPassword(
          email: query,
          password: pass,
        );
        if (res.user != null) {
          supabaseSuccess = true;
        }
      } catch (_) {}
    }

    if (supabaseSuccess) {
      final userId = _client.auth.currentUser?.id;
      if (userId != null) {
        await _ref.read(sharedPrefsProvider).setString('current_user_id', userId);
      }
      _ref.read(isLoggedInProvider.notifier).login();
      await _ref.read(currentUserProvider.notifier).refresh();
      return;
    }

    // Local database authentication
    final localAccounts = _getLocalAccounts();

    // Debug mode: allow dev account with hashed password check
    Map<String, dynamic> match = {};

    if (kDebugMode) {
      // Check dev account
      final devHash = _hashPassword('aghoshpratheesh@gmail.com', '123123123');
      final devAcc = localAccounts.firstWhere(
        (acc) =>
            (acc['email'].toString().toLowerCase() == 'aghoshpratheesh@gmail.com' ||
             acc['username'].toString().toLowerCase() == 'socfirdev') &&
            acc['password'].toString() == devHash,
        orElse: () => {},
      );
      if (devAcc.isNotEmpty &&
          (query == 'aghoshpratheesh@gmail.com' || query == 'socfirdev') &&
          devAcc['password'] == _hashPassword('aghoshpratheesh@gmail.com', pass)) {
        match = devAcc;
      }
    }

    // Regular local account lookup (hashed password comparison)
    if (match.isEmpty) {
      match = localAccounts.firstWhere(
        (acc) =>
            (acc['email'].toString().toLowerCase() == query ||
             acc['username'].toString().toLowerCase() == query) &&
            acc['password'].toString() == _hashPassword(acc['email'].toString(), pass),
        orElse: () => {},
      );
    }

    if (match.isEmpty) {
      throw Exception('Account not found. Please sign up first.');
    }

    final userId = match['id']?.toString() ?? 'local_user';

    final userData = SocFirUser(
      id: userId,
      username: match['username'] ?? query,
      email: match['email'] ?? query,
      displayName: match['display_name'] ?? match['username'] ?? query,
      avatarUrl: match['avatar_url'], // Null / blank if no photo was uploaded
      age: match['age'] ?? 21,
      bio: match['bio'] ?? '',
      isOnboarded: true,
      createdAt: DateTime.now(),
    );

    // Persist current_user_id for local posts/feed
    await _ref.read(sharedPrefsProvider).setString('current_user_id', userId);

    _ref.read(isLoggedInProvider.notifier).login();
    _ref.read(currentUserProvider.notifier).setUser(userData);
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    final prefs = _ref.read(sharedPrefsProvider);
    await prefs.remove('current_user_id');
    _ref.read(isLoggedInProvider.notifier).logout();
    _ref.read(currentUserProvider.notifier).clear();
  }
}
