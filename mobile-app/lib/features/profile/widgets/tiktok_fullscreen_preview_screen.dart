import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TikTokMediaItem {
  final String id;
  final String mediaUrl;
  final List<String> photoUrls;
  final String title;
  final String creatorName;
  final String creatorAvatar;
  final String views;
  final String initialLikes;
  final String commentsCount;
  final String favoritesCount;
  final String sharesCount;
  final bool isVideo;
  final String soundTitle;

  const TikTokMediaItem({
    required this.id,
    required this.mediaUrl,
    this.photoUrls = const [],
    required this.title,
    required this.creatorName,
    required this.creatorAvatar,
    required this.views,
    required this.initialLikes,
    this.commentsCount = '428',
    this.favoritesCount = '1.2K',
    this.sharesCount = '890',
    required this.isVideo,
    this.soundTitle = 'Original Sound - HemiTon Studio Mix',
  });
}

class TikTokFullScreenPreviewScreen extends StatefulWidget {
  final TikTokMediaItem item;
  final List<TikTokMediaItem>? playlist;
  final int initialIndex;

  const TikTokFullScreenPreviewScreen({
    super.key,
    required this.item,
    this.playlist,
    this.initialIndex = 0,
  });

  @override
  State<TikTokFullScreenPreviewScreen> createState() => _TikTokFullScreenPreviewScreenState();
}

class _TikTokFullScreenPreviewScreenState extends State<TikTokFullScreenPreviewScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late List<TikTokMediaItem> _items;

  // Interaction State for current item
  bool _isLiked = false;
  int _likesCount = 0;
  bool _isFavorited = false;
  bool _isPlaying = true;
  bool _isMuted = false;
  bool _isFollowed = false;

  late AnimationController _discAnimController;
  late AnimationController _heartAnimController;
  final List<Offset> _floatingHearts = [];
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.playlist ?? [widget.item];
    _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    _initItemState(_items[_currentIndex]);

    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _initItemState(TikTokMediaItem item) {
    _isLiked = false;
    _isFavorited = false;
    _isPlaying = true;
    _currentPhotoIndex = 0;

    final raw = item.initialLikes.replaceAll('K', '').replaceAll('M', '').trim();
    final parsed = double.tryParse(raw) ?? 1.0;
    if (item.initialLikes.contains('K')) {
      _likesCount = (parsed * 1000).toInt();
    } else if (item.initialLikes.contains('M')) {
      _likesCount = (parsed * 1000000).toInt();
    } else {
      _likesCount = parsed.toInt();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discAnimController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }

  void _handleDoubleTap(TapDownDetails details) {
    setState(() {
      _floatingHearts.add(details.localPosition);
      if (!_isLiked) {
        _isLiked = true;
        _likesCount++;
      }
    });

    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _floatingHearts.remove(details.localPosition);
        });
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount = math.max(0, _likesCount - 1);
      }
    });
  }

  void _showCommentsSheet(BuildContext context, TikTokMediaItem item) {
    final List<Map<String, String>> comments = [
      {'user': 'Sara_K', 'text': 'This is pure fire! 🔥😍', 'time': '2m ago', 'likes': '24'},
      {'user': 'Alex_Live', 'text': 'The lighting and beat drop are unreal!!', 'time': '15m ago', 'likes': '12'},
      {'user': 'Ahmad', 'text': 'Welcome to HemiTon family 👑', 'time': '1h ago', 'likes': '89'},
      {'user': 'Elena', 'text': 'Need this sound on repeat 🎧', 'time': '3h ago', 'likes': '6'},
    ];
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFF130A24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            border: Border.all(
              color: const Color(0xFFFF007F).withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              // Grabber Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.commentsCount} Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Comments List
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (context, idx) {
                    final c = comments[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 17.r,
                          backgroundColor: const Color(0xFFFF007F).withValues(alpha: 0.3),
                          child: Text(
                            c['user']![0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['user']!,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                c['text']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${c['time']!} • Reply',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.favorite_border_rounded, color: Colors.white38, size: 16),
                            SizedBox(height: 2.h),
                            Text(
                              c['likes']!,
                              style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Bottom Input Bar
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0616),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: TextField(
                            controller: commentCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(0xFFFF007F)),
                        onPressed: () {
                          if (commentCtrl.text.trim().isNotEmpty) {
                            setSheetState(() {
                              comments.insert(0, {
                                'user': 'You',
                                'text': commentCtrl.text.trim(),
                                'time': 'Just now',
                                'likes': '0',
                              });
                            });
                            commentCtrl.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _items.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _initItemState(_items[index]);
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          return _buildSingleMediaPage(item);
        },
      ),
    );
  }

  Widget _buildSingleMediaPage(TikTokMediaItem item) {
    final photoList = item.photoUrls.isNotEmpty
        ? item.photoUrls
        : [item.mediaUrl];

    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      onTap: () {
        if (item.isVideo) {
          setState(() {
            _isPlaying = !_isPlaying;
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Fullscreen Media Content ──────────────────────────────────
          if (item.isVideo) ...[
            Image.network(
              item.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF130A24)),
            ),
            // Play/Pause State indicator overlay
            if (!_isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF007F), width: 2),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 54),
                ),
              ),
          ] else ...[
            PageView.builder(
              itemCount: photoList.length,
              onPageChanged: (pIdx) => setState(() => _currentPhotoIndex = pIdx),
              itemBuilder: (context, pIdx) {
                return Image.network(
                  photoList[pIdx],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF130A24)),
                );
              },
            ),
          ],

          // ── 2. Top & Bottom Ambient Gradient Shadows ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 240.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Top Navigation Bar ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (!item.isVideo && photoList.length > 1)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        '${_currentPhotoIndex + 1} / ${photoList.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Floating Double Tap Hearts ─────────────────────────────────
          for (final pos in _floatingHearts)
            Positioned(
              left: pos.dx - 45,
              top: pos.dy - 45,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.4),
                duration: const Duration(milliseconds: 600),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF007F), Color(0xFFFF1744)],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  );
                },
              ),
            ),

          // ── 5. Right TikTok Action Column ────────────────────────────────
          Positioned(
            right: 12.w,
            bottom: 24.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator Avatar with + Follow Button
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF007F), width: 1.5),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          item.creatorAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ),
                    if (!_isFollowed)
                      Positioned(
                        bottom: -7.h,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isFollowed = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Following ${item.creatorName}! 💖'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF007F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 15),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 18.h),

                // Like Button (Animated)
                _buildActionColumnBtn(
                  icon: Icons.favorite_rounded,
                  label: _formatNumber(_likesCount),
                  color: _isLiked ? const Color(0xFFFF007F) : Colors.white,
                  onTap: _toggleLike,
                ),
                SizedBox(height: 16.h),

                // Comments Button
                _buildActionColumnBtn(
                  icon: Icons.chat_bubble_rounded,
                  label: item.commentsCount,
                  color: Colors.white,
                  onTap: () => _showCommentsSheet(context, item),
                ),
                SizedBox(height: 16.h),

                // Favorites / Bookmark Button
                _buildActionColumnBtn(
                  icon: Icons.bookmark_rounded,
                  label: item.favoritesCount,
                  color: _isFavorited ? const Color(0xFFFFD700) : Colors.white,
                  onTap: () {
                    setState(() => _isFavorited = !_isFavorited);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorited ? 'Added to Favorites! ⭐' : 'Removed from Favorites'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // Share Button
                _buildActionColumnBtn(
                  icon: Icons.share_rounded,
                  label: item.sharesCount,
                  color: Colors.white,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post link copied to clipboard! 🔗'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                SizedBox(height: 18.h),

                // Spinning Vinyl Disc
                RotationTransition(
                  turns: _discAnimController,
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF22133D), Color(0xFF07040C)],
                      ),
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        item.creatorAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.music_note_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 6. Bottom Creator Details & Caption ──────────────────────────
          Positioned(
            left: 14.w,
            right: 80.w,
            bottom: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator Handle & Verified Tag
                Row(
                  children: [
                    Text(
                      '@${item.creatorName.replaceAll(' ', '_').toLowerCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(Icons.verified_rounded, color: const Color(0xFF1877F2), size: 16.sp),
                  ],
                ),
                SizedBox(height: 6.h),

                // Caption / Title + Hashtags
                Text(
                  '${item.title} #HemiTon #Viral #Trending ✨',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8.h),

                // Sound Ticker
                Row(
                  children: [
                    Icon(Icons.music_note_rounded, color: Colors.white70, size: 14.sp),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        item.soundTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionColumnBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 0.8),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

