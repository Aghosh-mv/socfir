import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase/supabase_service.dart';
import '../../models/user_model.dart';
import '../../shared/theme/app_theme.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  List<SocFirUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await ref.read(supabaseClientProvider).from('socfir_users').select();
      setState(() {
        _users = (data as List).map((json) => SocFirUser.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard (Customers)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final u = _users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                  backgroundImage: u.avatarUrl != null ? NetworkImage(u.avatarUrl!) : null,
                  child: u.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${u.email}\nAge: ${u.age} | Tier: ${u.contentTier}'),
                trailing: Text('Score: ${u.leaderboardScore.toStringAsFixed(0)}'),
                isThreeLine: true,
              );
            },
          ),
    );
  }
}
