import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/services/room_share_service.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/comments_sheet.dart';
import '../profile/user_profile_details_screen.dart';

/// Redesigned Full-Screen Vertical Moments / Reels UI
/// Matching reference screenshot and requirements:
/// - Exactly 3 category tabs: "For You" | "Following" | "Community" as a transparent overlay on top of video
/// - Selected tab highlighted with pink/magenta glowing underline bar
/// - No extra categories (Trending, Live removed from Reels)
/// - Completely removed: Recommend / Moments / Friends tabs, search icon, post button, segmented progress lines, top creator header
/// - Full-screen vertical video feed (PageView.builder, Axis.vertical)
/// - Right-side action panel: Creator avatar with pink (+) follow badge, Heart like button with count, Comment button with count, Share button with count, Animated music disc
/// - Bottom-left caption & music info: Title, post text, and music track with pink note icon
/// - Fixed bottom navigation bar remains visible
class MomentsFeedScreen extends StatefulWidget {
  final bool isEmbeddedInHome;
  final VoidCallback? onBackToRecommend;
  const MomentsFeedScreen({
    super.key,
    this.isEmbeddedInHome = false,
    this.onBackToRecommend,
  });

  @override
  State<MomentsFeedScreen> createState() => _MomentsFeedScreenState();
}

class _MomentsFeedScreenState extends State<MomentsFeedScreen> with SingleTickerProviderStateMixin {
  int _selectedCategoryIndex = 0; // 0: For You, 1: Following, 2: Community
  final List<String> _categories = ['For You', 'Following', 'Community'];

  late PageController _pageController;
  late AnimationController _discAnimController;
  int _currentPageIndex = 0;
  bool _isPlaying = true;

  // Local interaction tracking
  final Set<String> _likedPostIds = {};
  final Set<String> _followedUserIds = {'22773864'};
  final Set<String> _hiddenPostIds = {};
  final Set<String> _blockedUserIds = {};
  final List<Offset> _doubleTapHearts = [];

  // Demonstration and default reels
  final List<_MomentPostData> _demoPosts = [
    _MomentPostData(
      id: 'm1',
      userId: '22773864',
      userName: 'Anam',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      title: "Friend's Home 🔥",
      gender: 'female',
      age: 21,
      caption: "Friend's Home 🔥 Hanging out with the squad in our party room tonight!",
      musicTitle: 'Chill Vibes — The Night',
      mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=85',
      isVideo: true,
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      dateText: '10/03',
      likes: 12400,
      comments: 245,
      shares: 1200,
      category: 'Following',
    ),
    _MomentPostData(
      id: 'm2',
      userId: '22219520',
      userName: 'Mr.Shehryar',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      title: 'Squad Vibes 🚀',
      gender: 'male',
      age: 24,
      caption: 'Happy birthday leader bhaiya 🎂 Wishing you endless success & happiness in our community!',
      musicTitle: 'Celebration Beats • Shehryar',
      mediaUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=85',
      isVideo: true,
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      dateText: '10/03',
      likes: 8500,
      comments: 130,
      shares: 410,
      category: 'Community',
    ),
    _MomentPostData(
      id: 'm3',
      userId: '22889911',
      userName: 'Sonia Malik',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      title: 'City Lights 🌸',
      gender: 'female',
      age: 22,
      caption: "Cruising through the city lights ✨ Ready for tonight's special live stream! Who is joining? 🚀",
      musicTitle: 'Midnight Drive • Sonia',
      mediaUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=85',
      isVideo: false,
      dateText: 'Today 12:45',
      likes: 19800,
      comments: 520,
      shares: 2300,
      category: 'For You',
    ),
    _MomentPostData(
      id: 'm4',
      userId: 'streamer_2',
      userName: 'Sakshi',
      userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
      title: 'Just Chilling 💙',
      gender: 'female',
      age: 23,
      caption: 'Casual moments with good music and good energy. Enjoying the weekend vibe!',
      musicTitle: 'Lo-Fi Chill Hop — Sakshi Mix',
      mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      isVideo: false,
      dateText: 'Yesterday',
      likes: 15200,
      comments: 310,
      shares: 890,
      category: 'For You',
    ),
    _MomentPostData(
      id: 'm5',
      userId: '22219521',
      userName: 'Community Squad',
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
      title: 'Community Meetup 🎉',
      gender: 'other',
      age: 25,
      caption: 'Huge shoutout to all community members who joined our group celebration today! 🚀 #community #party',
      musicTitle: 'Anthem of Friends • Beats',
      mediaUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800&q=85',
      isVideo: false,
      dateText: 'Today',
      likes: 24100,
      comments: 670,
      shares: 3100,
      category: 'Community',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final social = Provider.of<SocialProvider>(context, listen: false);
      if (!social.feedLoaded && !social.feedLoading) {
        social.loadFeed();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discAnimController.dispose();
    super.dispose();
  }

  List<_MomentPostData> _getFilteredPosts(SocialProvider? social, AuthProvider? auth) {
    // 1. Newly uploaded reels/videos from BackendRepository
    final backendVideos = BackendRepository.instance.shortVideos.map((v) => _MomentPostData(
      id: v.id,
      userId: v.creator.id,
      userName: v.creator.displayName.isNotEmpty ? v.creator.displayName : (v.creator.name.isNotEmpty ? v.creator.name : 'Creator'),
      userAvatar: v.creator.avatarUrl.isNotEmpty ? v.creator.avatarUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      title: v.caption,
      gender: v.creator.gender.isNotEmpty ? v.creator.gender : 'female',
      age: v.creator.age > 0 ? v.creator.age : 22,
      caption: v.caption,
      musicTitle: v.musicTitle.isNotEmpty ? v.musicTitle : 'Original Sound',
      mediaUrl: v.videoUrl,
      isVideo: true,
      videoUrl: v.videoUrl,
      dateText: 'Just now',
      likes: v.likes > 0 ? v.likes : 150,
      comments: v.comments > 0 ? v.comments : 12,
      shares: 45,
      category: 'For You',
    )).toList();

    // 2. Real posts from SocialProvider - STRICTLY EXCLUDE STATUS / STORIES (Status must only show in Status / Story viewer)
    final realPosts = (social?.posts ?? [])
        .where((p) {
          // Strictly exclude stories and status posts from Moments reels
          if (p.isStory ||
              p.visibility == 'STORY' ||
              p.content.startsWith('[STORY]') ||
              p.content.contains('#story') ||
              p.content.toLowerCase().contains('#status')) {
            return false;
          }
          final media = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
          final lower = media.toLowerCase();
          return lower.endsWith('.mp4') ||
              lower.endsWith('.mov') ||
              lower.endsWith('.webm') ||
              lower.contains('video') ||
              p.content.toLowerCase().contains('#video');
        })
        .map((p) => _MomentPostData.fromPostModel(p))
        .where((m) => m.isVideo && (m.videoUrl?.isNotEmpty ?? false))
        .toList();

    // Combine user's uploaded videos and video posts at the very top of For You reels
    final combined = <_MomentPostData>[];
    for (final v in backendVideos) {
      if (v.isVideo && (v.videoUrl?.isNotEmpty ?? false) && !combined.any((e) => e.id == v.id)) {
        combined.add(v);
      }
    }
    for (final p in realPosts) {
      if (p.isVideo && (p.videoUrl?.isNotEmpty ?? false) && !combined.any((e) => e.id == p.id)) {
        combined.add(p);
      }
    }
    for (final d in _demoPosts) {
      if (d.isVideo && (d.videoUrl?.isNotEmpty ?? false) && !combined.any((e) => e.id == d.id)) {
        combined.add(d);
      }
    }

    // Filter out user dismissed "Not Interested" or blocked creators
    combined.removeWhere((p) => _hiddenPostIds.contains(p.id) || _blockedUserIds.contains(p.userId));

    if (_selectedCategoryIndex == 1) {
      // "Following": Reels from accounts followed by user
      final followingPosts = combined.where((p) {
        final isAuthFollow = auth != null && auth.isFollowing(p.userId);
        return isAuthFollow || _followedUserIds.contains(p.userId) || p.category == 'Following';
      }).toList();
      return followingPosts.isNotEmpty ? followingPosts : combined.take(2).toList();
    } else if (_selectedCategoryIndex == 2) {
      // "Community": Reels tagged/categorized as Community or party rooms
      final communityPosts = combined.where((p) {
        final text = (p.caption + p.title + p.category).toLowerCase();
        return p.category == 'Community' ||
            text.contains('community') ||
            text.contains('squad') ||
            text.contains('party') ||
            text.contains('home') ||
            text.contains('friend');
      }).toList();
      return communityPosts.isNotEmpty ? communityPosts : combined.where((p) => p.category == 'Community').toList();
    } else {
      // "For You": Recommended public reels (all posts)
      return combined;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  void _onDoubleTap(TapDownDetails details, String postId) {
    setState(() {
      _likedPostIds.add(postId);
      _doubleTapHearts.add(details.localPosition);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted && _doubleTapHearts.isNotEmpty) {
        setState(() => _doubleTapHearts.removeAt(0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final social = Provider.of<SocialProvider?>(context);
    final auth = Provider.of<AuthProvider?>(context);

    return ListenableBuilder(
      listenable: BackendRepository.instance,
      builder: (context, _) {
        final displayedPosts = _getFilteredPosts(social, auth);

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
          // ── 1. Full-Screen Vertical Scrolling Video PageView ────────────────
          if (displayedPosts.isEmpty)
            _buildEmptyState()
          else
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: displayedPosts.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                  _isPlaying = true;
                });
              },
              itemBuilder: (context, index) {
                final post = displayedPosts[index];
                final isCurrent = index == _currentPageIndex;
                return _buildReelPage(post, isCurrent);
              },
            ),

          // ── 2. Top Transparent Overlay: For You | Following | Community ─────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCategoryTabsHeader(),
          ),

          // ── 3. Double-Tap Floating Hearts Animation ─────────────────────────
          ..._doubleTapHearts.map((pos) => Positioned(
                left: pos.dx - 40,
                top: pos.dy - 40,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.3),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Opacity(
                      opacity: (1.3 - scale).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF1493),
                          size: 80,
                          shadows: [
                            BoxShadow(
                              color: Color(0xFFFF1493),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Top Categories Transparent Header: For You | Following | Community
  // ===========================================================================
  Widget _buildCategoryTabsHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding + 4.h : 10.h,
        bottom: 12.h,
        left: 12.w,
        right: 12.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Back button to return to Recommend tab if embedded in Home
          if (widget.isEmbeddedInHome && widget.onBackToRecommend != null)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: widget.onBackToRecommend,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16.w,
                    ),
                  ),
                ),
              ),
            ),

          // Center: For You | Following | Community
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _currentPageIndex = 0;
                      });
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.75),
                              fontSize: 14.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              letterSpacing: 0.2,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Neon Pink/Purple glowing underline indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            width: isSelected ? 22.w : 0,
                            height: 2.5.h,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(2.r),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF007F).withValues(alpha: 0.85),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Individual Full-Screen Reel Page
  // ===========================================================================
  Widget _buildReelPage(_MomentPostData post, bool isCurrent) {
    final isLiked = _likedPostIds.contains(post.id);
    final isFollowing = _followedUserIds.contains(post.userId);
    final displayLikes = post.likes + (isLiked ? 1 : 0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video / Media Background with Tap to Play/Pause & Double-Tap Heart ──
        Positioned.fill(
          child: post.isVideo
              ? _ReelVideoPlayerView(
                  mediaUrl: post.videoUrl?.isNotEmpty == true ? post.videoUrl! : post.mediaUrl,
                  isPlaying: _isPlaying && isCurrent,
                  onTap: () {
                    setState(() => _isPlaying = !_isPlaying);
                  },
                  onDoubleTapDown: (details) => _onDoubleTap(details, post.id),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() => _isPlaying = !_isPlaying);
                  },
                  onDoubleTapDown: (details) => _onDoubleTap(details, post.id),
                  onDoubleTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: post.mediaUrl.startsWith('http')
                      ? Image.network(
                          post.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF0F1117),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 64),
                            ),
                          ),
                        )
                      : Image.file(
                          File(post.mediaUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF0F1117),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_rounded, color: Colors.white24, size: 64),
                            ),
                          ),
                        ),
                ),
        ),

          // ── Bottom Dark Gradient for Caption and Controls Contrast ────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.35, 0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Centered Play / Pause Indicator Overlay ────────────────────────
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 56,
                  color: Colors.white70,
                ),
              ),
            ),

          // ── Right-Side Action Panel (TikTok / iOS Style) ─────────────────────
          Positioned(
            right: 12.w,
            bottom: 96.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Creator Avatar + Pink (+) Follow Badge
                _buildCreatorAvatar(post, isFollowing),
                SizedBox(height: 16.h),

                // 2. TikTok / iOS Like Button + Count (Crisp White / Vibrant #FE2C55 Heart)
                _buildTikTokActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isLiked ? const Color(0xFFFE2C55) : Colors.white,
                  label: _formatCount(displayLikes),
                  onTap: () {
                    setState(() {
                      if (isLiked) {
                        _likedPostIds.remove(post.id);
                      } else {
                        _likedPostIds.add(post.id);
                      }
                    });
                  },
                ),
                SizedBox(height: 14.h),

                // 3. Comments Action Button (Clean crisp chat bubble icon matching comment sheet)
                _buildTikTokActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  label: _formatCount(post.comments),
                  onTap: () {
                    CommentsSheet.show(
                      context,
                      targetId: post.id,
                      isPost: true,
                      title: 'Reel Comments',
                    );
                  },
                ),
                SizedBox(height: 14.h),

                // 4. TikTok / iOS Curved Share Arrow Button + Count
                _buildTikTokActionButton(
                  icon: Icons.reply_rounded,
                  flipX: true,
                  color: Colors.white,
                  label: _formatCount(post.shares),
                  onTap: () {
                    RoomShareService.shareText(
                      context,
                      'Check out this reel by ${post.userName} on HEMI TON: "${post.caption}"',
                    );
                  },
                ),
                SizedBox(height: 14.h),

                // 5. TikTok / iOS More Options (...) Button
                _buildTikTokActionButton(
                  icon: Icons.more_horiz_rounded,
                  color: Colors.white,
                  label: 'More',
                  onTap: () => _showTikTokMoreBottomSheet(post),
                ),
                SizedBox(height: 16.h),

                // 6. Spinning Music Disc
                _buildMusicDisc(post),
              ],
            ),
          ),

          // ── Bottom-Left Caption & Music Information ────────────────────────
          Positioned(
            left: 16.w,
            right: 88.w,
            bottom: 96.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Creator Profile / Username & Title
                GestureDetector(
                  onTap: () => _openUserProfile(post),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          post.userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.title.isNotEmpty && post.title != post.userName) ...[
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            '• ${post.title}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 5.h),

                // Caption / Post text
                Text(
                  post.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 13.5.sp,
                    height: 1.35,
                    shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: 8.h),

                // Music Track Information with Pink Musical Note
                Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 15.w,
                      color: const Color(0xFFFF1493),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        post.musicTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
  }

  // ── Creator Avatar with Follow (+) Badge ─────────────────────────────────────
  Widget _buildCreatorAvatar(_MomentPostData post, bool isFollowing) {
    return GestureDetector(
      onTap: () => _openUserProfile(post),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 23.r,
              backgroundImage: NetworkImage(post.userAvatar),
              backgroundColor: const Color(0xFF1E2330),
            ),
          ),

          // Overlapping Pink Follow (+) Badge
          if (!isFollowing)
            Positioned(
              bottom: -6.h,
              child: GestureDetector(
                onTap: () {
                  setState(() => _followedUserIds.add(post.userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Following ${post.userName} ✨'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFFFF1493),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFFFF2A9D)],
                    ),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── TikTok / iOS Style Action Panel Button with Count ───────────────────────
  Widget _buildTikTokActionButton({
    IconData? icon,
    Widget? customIcon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    bool flipX = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null)
            customIcon
          else if (icon != null)
            Transform.flip(
              flipX: flipX,
              child: Icon(
                icon,
                size: 32.w,
                color: color,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
            ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(color: Colors.black87, blurRadius: 5, offset: Offset(0, 1)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── TikTok / iOS Style More (...) Options Bottom Sheet ───────────────────────
  void _showTikTokMoreBottomSheet(_MomentPostData post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161823),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag pill
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 14.h),

                // Reel Info Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17.r,
                      backgroundImage: NetworkImage(post.userAvatar),
                      backgroundColor: const Color(0xFF222638),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${post.userName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            post.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                SizedBox(height: 6.h),

                // 1. Not Interested
                _buildTikTokOptionTile(
                  icon: Icons.heart_broken_rounded,
                  title: 'Not Interested',
                  subtitle: "We'll show fewer videos like this",
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _hiddenPostIds.add(post.id);
                    });
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("We'll show fewer videos like this"),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF222638),
                      ),
                    );
                  },
                ),

                // 2. Save Video / Bookmark
                _buildTikTokOptionTile(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Save to Bookmarks',
                  subtitle: 'Save this reel to your favorites',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Video saved to bookmarks 📌'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFFFF1493),
                      ),
                    );
                  },
                ),

                // 3. Copy Link
                _buildTikTokOptionTile(
                  icon: Icons.link_rounded,
                  title: 'Copy Link',
                  subtitle: 'Share video link with friends',
                  color: Colors.white,
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: 'https://zeparty.app/reel/${post.id}'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard 📋'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF00C853),
                      ),
                    );
                  },
                ),

                // 4. Report
                _buildTikTokOptionTile(
                  icon: Icons.flag_outlined,
                  title: 'Report',
                  subtitle: 'Report inappropriate or harmful content',
                  color: const Color(0xFFFFB300),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you! Video has been flagged for review.'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFFE65100),
                      ),
                    );
                  },
                ),

                // 5. Block User
                _buildTikTokOptionTile(
                  icon: Icons.block_rounded,
                  title: 'Block @${post.userName}',
                  subtitle: "You won't see posts or reels from this user",
                  color: const Color(0xFFFF4D4F),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _blockedUserIds.add(post.userId);
                    });
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('@${post.userName} blocked'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFD32F2F),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),

                // Cancel Button
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTikTokOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      leading: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color == const Color(0xFFFF4D4F) ? color : Colors.white,
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 11.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  // ── Rotating Music Disc ──────────────────────────────────────────────────────
  Widget _buildMusicDisc(_MomentPostData post) {
    return RotationTransition(
      turns: _discAnimController,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF2B2E38), Color(0xFF111319), Color(0xFF000000)],
            stops: [0.3, 0.7, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFFFF1493).withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1E222D),
            ),
            child: Icon(
              Icons.music_note_rounded,
              color: const Color(0xFFFF1493),
              size: 11.w,
            ),
          ),
        ),
      ),
    );
  }

  // ── Open User Profile ────────────────────────────────────────────────────────
  void _openUserProfile(_MomentPostData post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileDetailsScreen(
          user: UserModel(
            id: post.userId,
            username: post.userName.toLowerCase().replaceAll(' ', '_'),
            name: post.userName,
            avatarUrl: post.userAvatar,
            gender: post.gender,
          ),
        ),
      ),
    );
  }

  // ── Empty State for Filtered Categories ──────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_collection_outlined, size: 64.w, color: Colors.white24),
            SizedBox(height: 16.h),
            Text(
              _selectedCategoryIndex == 1
                  ? 'No Reels From Followed Accounts'
                  : 'No Community Reels Available',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              _selectedCategoryIndex == 1
                  ? 'Follow creators from the "For You" tab to see their latest reels here.'
                  : 'Check out recommended reels on For You to join the latest community events.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1493),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
              onPressed: () {
                setState(() => _selectedCategoryIndex = 0);
              },
              child: const Text('Explore For You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentPostData {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String gender;
  final int age;
  final String caption;
  final String musicTitle;
  final String mediaUrl;
  final bool isVideo;
  final String? videoUrl;
  final String dateText;
  final int likes;
  final int comments;
  final int shares;
  final String category;

  _MomentPostData({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.title = '',
    required this.gender,
    required this.age,
    required this.caption,
    this.musicTitle = 'Original Sound',
    required this.mediaUrl,
    required this.isVideo,
    this.videoUrl,
    required this.dateText,
    required this.likes,
    required this.comments,
    this.shares = 100,
    this.category = 'For You',
  });

  factory _MomentPostData.fromPostModel(PostModel post) {
    return _MomentPostData(
      id: post.id,
      userId: post.author.id,
      userName: post.author.displayName.isNotEmpty ? post.author.displayName : post.author.username,
      userAvatar: post.author.avatarUrl,
      title: post.author.displayName.isNotEmpty ? post.author.displayName : post.author.username,
      gender: post.author.gender.isNotEmpty ? post.author.gender : 'other',
      age: post.author.age > 0 ? post.author.age : 21,
      caption: post.content,
      musicTitle: 'Original Audio • ${post.author.displayName.isNotEmpty ? post.author.displayName : post.author.name}',
      mediaUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : '',
      isVideo: post.imageUrls.any((u) => u.toLowerCase().endsWith('.mp4') || u.toLowerCase().endsWith('.mov') || u.toLowerCase().endsWith('.webm') || u.contains('video')) || post.content.toLowerCase().contains('#video'),
      videoUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
      dateText: '${post.createdAt.month}/${post.createdAt.day}',
      likes: post.likes,
      comments: post.comments,
      shares: (post.likes / 5).round() + 10,
      category: 'For You',
    );
  }
}

class _ReelVideoPlayerView extends StatefulWidget {
  final String mediaUrl;
  final bool isPlaying;
  final VoidCallback onTap;
  final Function(TapDownDetails) onDoubleTapDown;

  const _ReelVideoPlayerView({
    required this.mediaUrl,
    required this.isPlaying,
    required this.onTap,
    required this.onDoubleTapDown,
  });

  @override
  State<_ReelVideoPlayerView> createState() => _ReelVideoPlayerViewState();
}

class _ReelVideoPlayerViewState extends State<_ReelVideoPlayerView> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _ReelVideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrl != widget.mediaUrl) {
      _controller?.dispose();
      _controller = null;
      _initialized = false;
      _initVideo();
    } else if (_initialized && _controller != null) {
      if (widget.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!widget.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  void _initVideo() async {
    try {
      if (widget.mediaUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
      } else {
        _controller = VideoPlayerController.file(File(widget.mediaUrl));
      }
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (widget.isPlaying) {
        await _controller!.play();
      }
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint('[ReelVideoPlayer] Init error: $e');
      if (mounted) setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: widget.onDoubleTapDown,
      onDoubleTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 400,
                height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 600,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            Container(
              color: const Color(0xFF0F1117),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF1493),
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Image 2 Exact Comment Icon: White Outline Speech Bubble with 3 Dots Inside
// =============================================================================
class _Image2CommentIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _Image2CommentIcon({
    this.size = 32,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _Image2CommentIconPainter(color: color),
          ),
        ],
      ),
    );
  }
}

class _Image2CommentIconPainter extends CustomPainter {
  final Color color;

  _Image2CommentIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.088;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw shadow behind outline for video contrast
    final shadowPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.46;
    final r = w * 0.40;

    final path = Path();
    // Arc for circular body with corner tail at bottom-left
    path.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.65 * 3.14159,
      1.58 * 3.14159,
    );
    // Tail pointing down-left
    path.quadraticBezierTo(
      w * 0.16,
      h * 0.82,
      w * 0.12,
      h * 0.90,
    );
    path.quadraticBezierTo(
      w * 0.28,
      h * 0.86,
      cx + (r * -0.32),
      cy + (r * 0.94),
    );

    // Draw shadow first, then white stroke
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, strokePaint);

    // 3 Solid Dots inside horizontally
    final dotRadius = size.width * 0.052;
    final dotY = cy + (size.height * 0.01);
    final spacing = size.width * 0.155;

    // Shadow behind dots
    final dotShadowPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final x in [cx - spacing, cx, cx + spacing]) {
      canvas.drawCircle(Offset(x, dotY + 1), dotRadius, dotShadowPaint);
      canvas.drawCircle(Offset(x, dotY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _Image2CommentIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
