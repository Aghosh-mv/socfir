import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../supabase/supabase_service.dart';

class AgeBlurWrapper extends ConsumerWidget {
  final Widget child;
  final bool isSensitive;

  const AgeBlurWrapper({super.key, required this.child, this.isSensitive = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isSensitive) return child;

    final user = ref.watch(currentUserProvider);
    // If not logged in or tier < 2 (under 18), apply blur
    final shouldBlur = user == null || user.contentTier < 2;

    if (!shouldBlur) return child;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Sensitive Content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
