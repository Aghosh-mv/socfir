import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/post_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/age_blur_wrapper.dart';
import '../../../shared/widgets/pop_out_avatar.dart';
import '../../../shared/widgets/hero_image_viewer.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  int _currentImageIndex = 0;
  bool _isLiked = false;
  int _likesCount = 0;
  int _sparksCount = 0;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked == true;
    _likesCount = widget.post.likesCount;
    _sparksCount = widget.post.sparksCount;
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
  }

  void _handleDoubleTap() {
    if (!_isLiked) {
      _toggleLike();
    }
    setState(() => _showHeartAnimation = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  void _giveSpark() {
    HapticFeedback.mediumImpact();
    setState(() {
      _sparksCount += 1;
    });
    // Add visual spark explosion here if desired
  }

  void _showQuickReactions(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black45)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['❤️', '😂', '🔥', '🚀', '😢', '👀'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    if (emoji == '❤️' && !_isLiked) _toggleLike();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reacted with $emoji')));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ).animate().scale(delay: 50.ms, duration: 200.ms, curve: Curves.easeOutBack);
              }).toList(),
            ),
          ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.2, end: 0, duration: 150.ms),
        ),
      ),
    );
  }

  void _openImage(String url, String tag) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (BuildContext context, _, __) {
        return HeroImageViewer(imageUrl: url, tag: tag);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isShitpost = widget.post.type == PostType.shitpost;
    final isCollab = widget.post.coAuthorUsername != null;
    
    final contentStyle = isShitpost
        ? GoogleFonts.comicNeue(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)
        : const TextStyle(fontSize: 15);

    return GestureDetector(
      onLongPress: () => _showQuickReactions(context),
      child: Container(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        decoration: BoxDecoration(
          color: isShitpost ? AppColors.accent.withValues(alpha: 0.05) : Colors.transparent,
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5), width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (isCollab)
                        Positioned(
                          left: 20,
                          child: PopOutAvatar(
                            imageUrl: widget.post.coAuthorAvatarUrl,
                            radius: 20,
                            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                      PopOutAvatar(
                        imageUrl: widget.post.authorAvatarUrl,
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: isCollab ? 32 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isCollab 
                                  ? '${widget.post.authorDisplayName ?? 'Unknown'} & ${widget.post.coAuthorDisplayName ?? 'Unknown'}'
                                  : widget.post.authorDisplayName ?? widget.post.authorUsername ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isShitpost) ...[
                              const SizedBox(width: 6),
                              const Text('💩', style: TextStyle(fontSize: 14)),
                            ],
                            const SizedBox(width: 6),
                            Text(
                              '· ${timeago.format(widget.post.createdAt, locale: 'en_short')}',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          isCollab 
                              ? '@${widget.post.authorUsername} & @${widget.post.coAuthorUsername}'
                              : '@${widget.post.authorUsername ?? 'unknown'}',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey), 
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Content
              if (widget.post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 52.0), // Align with text, skipping avatar
                  child: Text(widget.post.content, style: contentStyle),
                ),
              
              // Media & Carousel
              if (widget.post.mediaUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 52.0), // Align media with text
                  child: _buildMediaGallery(),
                ),
                
              const SizedBox(height: 8),
              
              // Actions (Decluttered to 4 items)
              Padding(
                padding: const EdgeInsets.only(left: 44.0), // Align actions underneath content nicely
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAction(Icons.chat_bubble_outline, widget.post.commentsCount.toString(), onTap: () {}),
                    // Like Button
                    GestureDetector(
                      onTap: _toggleLike,
                      child: _buildAction(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        _likesCount.toString(),
                        color: _isLiked ? Colors.red : null,
                      ).animate(target: _isLiked ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 150.ms, curve: Curves.bounceOut).then().scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 150.ms),
                    ),
                    // Sparks (Micro-economy tipping)
                    GestureDetector(
                      onTap: _giveSpark,
                      child: _buildAction(
                        Icons.electric_bolt, 
                        _sparksCount.toString(),
                        color: _sparksCount > 0 ? Colors.amber : null,
                      ),
                    ),
                    _buildAction(Icons.ios_share, '', onTap: () {}),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    final urls = widget.post.mediaUrls;
    Widget gallery;
    
    if (urls.length == 1) {
      final tag = 'image_${widget.post.id}_0';
      gallery = GestureDetector(
        onTap: () => _openImage(urls.first, tag),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Hero(
            tag: tag,
            child: Image.network(urls.first, width: double.infinity, fit: BoxFit.cover, height: 200),
          ),
        ),
      );
    } else {
      // Carousel for multiple images (Card Type)
      gallery = Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: urls.length,
                onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                itemBuilder: (context, index) {
                  final tag = 'image_${widget.post.id}_$index';
                  return GestureDetector(
                    onTap: () => _openImage(urls[index], tag),
                    child: Hero(
                      tag: tag,
                      child: Image.network(urls[index], fit: BoxFit.cover, width: double.infinity),
                    ),
                  );
                },
              ),
            ),
          ),
          // Hover controls
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                urls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index ? Theme.of(context).primaryColor : Colors.white.withValues(alpha: 0.5),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2)],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return AgeBlurWrapper(
      isSensitive: widget.post.isSensitive,
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            gallery,
            if (_showHeartAnimation)
              const Icon(Icons.favorite, color: Colors.white, size: 100)
                  .animate()
                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 200.ms, curve: Curves.easeOutBack)
                  .then(delay: 400.ms)
                  .fadeOut(duration: 200.ms)
                  .scale(end: const Offset(0.5, 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String count, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey),
            if (count.isNotEmpty && count != '0') ...[
              const SizedBox(width: 6),
              Text(count, style: TextStyle(color: color ?? Colors.grey, fontSize: 13)),
            ]
          ],
        ),
      ),
    );
  }
}
