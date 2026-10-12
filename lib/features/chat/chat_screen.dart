import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/theme/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  bool _isWhisperMode = false;
  
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey! How is the new app?', 'isMe': false, 'isWhisper': false},
    {'text': 'It is amazing. So smooth.', 'isMe': true, 'isWhisper': false},
  ];

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _msgCtrl.text.trim(),
        'isMe': true,
        'isWhisper': _isWhisperMode,
        'whisperOpened': false,
      });
      _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Jane Dev', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            // Heartbeat Sync Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 12)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), curve: Curves.easeInOut, duration: 400.ms),
                const SizedBox(width: 4),
                const Text('Heartbeat Sync Active', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.local_fire_department, color: Colors.orange), tooltip: 'Dare Mode', onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔥 Dare Mode Activated!')));
          }),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _MessageBubble(
                  message: msg,
                  onWhisperOpened: () {
                    setState(() {
                      msg['whisperOpened'] = true;
                    });
                    // Self destruct after 5 seconds
                    Future.delayed(const Duration(seconds: 5), () {
                      if (mounted) {
                        setState(() {
                          _messages.removeAt(index);
                        });
                      }
                    });
                  },
                );
              },
            ),
          ),
          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isWhisperMode ? Icons.visibility_off : Icons.visibility,
                      color: _isWhisperMode ? Colors.purpleAccent : Colors.grey,
                    ),
                    tooltip: 'Whisper Mode (Self-Destruct)',
                    onPressed: () => setState(() => _isWhisperMode = !_isWhisperMode),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: _isWhisperMode ? 'Send a secret whisper...' : 'Type a message...',
                        hintStyle: TextStyle(color: _isWhisperMode ? Colors.purpleAccent.withValues(alpha: 0.5) : null),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: _isWhisperMode ? Colors.purpleAccent.withValues(alpha: 0.1) : Theme.of(context).scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final VoidCallback onWhisperOpened;

  const _MessageBubble({required this.message, required this.onWhisperOpened});

  @override
  Widget build(BuildContext context) {
    final isMe = message['isMe'] == true;
    final isWhisper = message['isWhisper'] == true;
    final whisperOpened = message['whisperOpened'] == true;

    Widget bubbleContent;

    if (isWhisper && !whisperOpened) {
      bubbleContent = GestureDetector(
        onTap: onWhisperOpened,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Tap to view whisper', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    } else {
      bubbleContent = Text(
        message['text'],
        style: TextStyle(color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isWhisper 
              ? Colors.purpleAccent.withValues(alpha: 0.8)
              : isMe 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: bubbleContent,
      ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0, duration: 200.ms),
    );
  }
}
