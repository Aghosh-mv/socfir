import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/post_model.dart';
import '../../../shared/theme/app_theme.dart';

import '../posts_service.dart';

class CreatePostDialog extends ConsumerStatefulWidget {
  const CreatePostDialog({super.key});

  @override
  ConsumerState<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<CreatePostDialog> {
  final _contentCtrl = TextEditingController();
  PostType _selectedType = PostType.text;
  bool _isSensitive = false;
  bool _isPosting = false;

  Future<void> _post() async {
    final text = _contentCtrl.text.trim();
    if (text.isEmpty) return;
    
    setState(() => _isPosting = true);
    try {
      await ref.read(postsServiceProvider).createPost(
        type: _selectedType,
        content: text,
        isSensitive: _isSensitive,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔥 Post published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Create Post', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind? 🔥',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(),
            Row(
              children: [
                DropdownButton<PostType>(
                  value: _selectedType,
                  underline: const SizedBox(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                  items: PostType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()));
                  }).toList(),
                ),
                const Spacer(),
                const Text('18+'),
                Switch(
                  value: _isSensitive,
                  onChanged: (val) => setState(() => _isSensitive = val),
                  activeThumbColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _post,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Post to Universe 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
