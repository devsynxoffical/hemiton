import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
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
  const MomentsFeedScreen({super.key, this.isEmbeddedInHome = false});

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
    final realPosts = (social?.posts ?? []).map((p) => _MomentPostData.fromPostModel(p)).toList();
    // Prioritize user's own created posts at the top
    final combined = [...realPosts, ..._demoPosts];

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
  }

  // ===========================================================================
  // Top Categories Transparent Header: For You | Following | Community
  // ===========================================================================
  Widget _buildCategoryTabsHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: widget.isEmbeddedInHome ? 6.h : (MediaQuery.of(context).padding.top + 6.h),
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.25),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
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
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.75),
                      fontSize: 13.5.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Pink/magenta underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: isSelected ? 18.w : 0,
                    height: 2.h,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF1493) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF1493).withValues(alpha: 0.8),
                                blurRadius: 6,
                                spreadRadius: 0.5,
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
          child: GestureDetector(
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
                        child: Icon(Icons.videocam_outlined, color: Colors.white24, size: 64),
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
                        child: Icon(Icons.videocam_outlined, color: Colors.white24, size: 64),
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

          // ── Right-Side Action Panel ────────────────────────────────────────
          Positioned(
            right: 12.w,
            bottom: 96.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Creator Avatar + Pink (+) Follow Badge
                _buildCreatorAvatar(post, isFollowing),
                SizedBox(height: 18.h),

                // 2. Like Button + Count
                _buildActionButton(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? const Color(0xFFFF1493) : Colors.white,
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
                SizedBox(height: 16.h),

                // 3. Comments Button + Count
                _buildActionButton(
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
                SizedBox(height: 16.h),

                // 4. Share Button + Count (Paper Plane icon matching screenshot)
                _buildActionButton(
                  icon: Icons.send_rounded,
                  color: Colors.white,
                  label: _formatCount(post.shares),
                  onTap: () {
                    RoomShareService.shareText(
                      context,
                      'Check out this reel by ${post.userName} on HEMI TON: "${post.caption}"',
                    );
                  },
                ),
                SizedBox(height: 18.h),

                // 5. Spinning Music Disc
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

  // ── Action Panel Button with Count ───────────────────────────────────────────
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30.w,
            color: color,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ],
      ),
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
      musicTitle: 'Original Audio • ${post.author.displayName}',
      mediaUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : '',
      isVideo: post.imageUrls.any((u) => u.endsWith('.mp4') || u.endsWith('.mov') || u.contains('/video')),
      videoUrl: post.imageUrls.isNotEmpty ? post.imageUrls.first : null,
      dateText: '${post.createdAt.month}/${post.createdAt.day}',
      likes: post.likes,
      comments: post.comments,
      shares: (post.likes / 5).round() + 10,
      category: 'For You',
    );
  }
}
