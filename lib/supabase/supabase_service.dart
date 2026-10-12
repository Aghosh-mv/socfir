import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

class CurrentUserNotifier extends Notifier<SocFirUser?> {
  @override
  SocFirUser? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final client = ref.read(supabaseClientProvider);
    final authUser = client.auth.currentUser;
    if (authUser == null) return;
    try {
      final data = await client
          .from('socfir_users')
          .select()
          .eq('id', authUser.id)
          .single();
      state = SocFirUser.fromJson(data);
    } catch (_) {}
  }

  Future<void> refresh() => _load();

  void setUser(SocFirUser user) => state = user;
  void clear() => state = null;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, SocFirUser?>(
  CurrentUserNotifier.new,
);
