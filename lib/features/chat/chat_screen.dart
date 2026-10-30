import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/utils/app_providers.dart';
import '../../supabase/supabase_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  bool _isWhisperMode = false;
  
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString('chat_messages_history');
    if (raw != null && raw.isNotEmpty) {
      try {
        final List list = jsonDecode(raw);
        setState(() {
          _messages = list.cast<Map<String, dynamic>>();
        });
      } catch (_) {}
    }
  }

  Future<void> _saveMessages() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString('chat_messages_history', jsonEncode(_messages));
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'isWhisper': _isWhisperMode,
        'whisperOpened': false,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _msgCtrl.clear();
    });
    _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final peerName = 'SocFir Global Lounge';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          IconButton(
            icon: const Icon(Icons.local_fire_department, color: Colors.orange),
            tooltip: 'Dare Mode',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔥 Dare Mode Activated!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() => _messages.clear());
              _saveMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome to the SocFir Lounge, @${currentUser?.username ?? 'you'}!\nSend your first message or whisper.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade400, height: 1.4),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                          _saveMessages();
                          // Self destruct after 5 seconds
                          Future.delayed(const Duration(seconds: 5), () {
                            if (mounted) {
                              setState(() {
                                _messages.removeAt(index);
                              });
                              _saveMessages();
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
