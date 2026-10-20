import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/utils/auth_guard.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/comments_sheet.dart';
import '../../widgets/report_sheet.dart';
import '../../widgets/story_viewer_dialog.dart';
import '../search/search_screen.dart';
import '../store/store_screen.dart';
import '../live/live_room_screen.dart';
import '../live/live_explore_screen.dart';
import '../profile/user_profile_details_screen.dart';
import '../social/camera_recorder_screen.dart';
import '../social/upload_video_screen.dart';
import '../social/moments_feed_screen.dart';
import '../social/create_post_screen.dart';

/// HEMI TON Modern Home Screen
/// Matches reference UI design:
/// - Top Navigation: [Recommend, Moments, Friends] with glowing pink underline + Search & Gift buttons
/// - Section 1: "Popular Live" (Horizontal cards with green LIVE badges, Streamer Name, Location; no viewer count)
/// - Section 2: "Feed" (Vertical post cards with media background, Avatar story tap, Follow button, 3-dots, Captions, Hashtags, Likes/Comments/Shares, Video Play button & duration)
/// - Instagram-style Story Viewer when avatar is tapped if user has active stories; otherwise opens UserProfileDetailsScreen
/// - Fixed Bottom Navigation Bar matching screenshot design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedHeaderTab = 0; // 0: Recommend, 1: Moments, 2: Friends
  final List<String> _headerTabs = ['Recommend', 'Moments', 'Friends'];

  // Local interaction tracking for demonstration posts
  final Set<String> _likedPostIds = {};
  final Map<String, int> _demoLikesCount = {
    'post_1': 3200,
    'post_2': 2800,
    'post_3': 4100,
  };
  final Map<String, int> _demoSharesCount = {
    'post_1': 112,
    'post_2': 96,
    'post_3': 154,
  };
  final Set<String> _followedAuthorIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackendRepository.instance.fetchLiveRooms();
      final social = Provider.of<SocialProvider>(context, listen: false);
      if (!social.feedLoaded && !social.feedLoading) {
        social.loadFeed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final backendRooms = BackendRepository.instance.liveRooms;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.lightBackground,
      body: Stack(
        children: [
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                // Top App Bar & Header Tabs [Recommend, Moments, Friends] + Search & Store/Post
                _buildTopHeader(isDark),

                // Tab Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedHeaderTab,
                    children: [
                      // Tab 0: Recommend (Feeds with all user-uploaded posts: videos, images, text; Popular Live removed)
                      _buildRecommendTab(isDark, backendRooms),

                      // Tab 1: Moments (Full-screen vertical reels with For You | Following | Community matching Image 1)
                      const MomentsFeedScreen(isEmbeddedInHome: true),

                      // Tab 2: Friends
                      _buildFriendsTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Add (+) Button in right corner above bottom bar to post video, pic, text
          Positioned(
            right: 16.w,
            bottom: 96.h,
            child: _buildFloatingAddButton(isDark),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Floating Add (+) Button (Above bottom navigation bar to post video, pic, etc.)
  // ===========================================================================
  Widget _buildFloatingAddButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        AuthGuard.require(context, () {
          _showPostCreationSheet(context, isDark);
        }, reason: 'Sign in to post photos, videos, and moments');
      },
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1493), Color(0xFF9D00FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: 0.6),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ),
    );
  }

  void _showPostCreationSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF11141C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Create & Share',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPostOption(
                      ctx: ctx,
                      icon: Icons.photo_camera_rounded,
                      label: 'Photo / Pic',
                      color: const Color(0xFFFF1493),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePostScreen(isStory: false)),
                        );
                        if (created == true && mounted) setState(() {});
                      },
                    ),
                    _buildPostOption(
                      ctx: ctx,
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: const Color(0xFF00E676),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadVideoScreen()),
                        );
                        if (created == true && mounted) setState(() {});
                      },
                    ),
                    _buildPostOption(
                      ctx: ctx,
                      icon: Icons.history_edu_rounded,
                      label: '24h Story',
                      color: const Color(0xFF00B0FF),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePostScreen(isStory: true)),
                        );
                        if (created == true && mounted) setState(() {});
                      },
                    ),
                    _buildPostOption(
                      ctx: ctx,
                      icon: Icons.mic_rounded,
                      label: 'Record',
                      color: const Color(0xFFFF9100),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraRecorderScreen()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostOption({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Top App Bar & Header Tabs [Recommend, Moments, Friends] + Search & Store
  // ===========================================================================
  Widget _buildTopHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: isDark ? AppColors.black : AppColors.lightBackground,
      child: Row(
        children: [
          // Header Tabs (Recommend, Moments, Friends)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_headerTabs.length, (index) {
                  final isSelected = _selectedHeaderTab == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHeaderTab = index;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                      child: Container(
                        margin: EdgeInsets.only(right: index == _headerTabs.length - 1 ? 4.w : 10.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _headerTabs[index],
                            style: TextStyle(
                              fontSize: isSelected ? 16.sp : 14.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.darkNavy)
                                  : (isDark ? const Color(0xFF7A8B9E) : const Color(0xFF8A9BA8)),
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3.5.h),
                          // Active Pink Glowing Underline Indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            width: isSelected ? 22.w : 0,
                            height: 2.8.h,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.pink : Colors.transparent,
                              borderRadius: BorderRadius.circular(2.r),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.pink.withValues(alpha: 0.8),
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
                  ),
                );
              }),
              ),
            ),
          ),
          SizedBox(width: 6.w),

          // Search Icon Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF161A22) : const Color(0xFFF0F4F8),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 21.w,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // If on Moments: show Post button; otherwise Store/Gift button
          if (_selectedHeaderTab == 1)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF007F),
                      Color(0xFFFF1493),
                      Color(0xFFFF2A9D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.55),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me_rounded, color: Colors.white, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF161A22) : const Color(0xFFF0F4F8),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 21.w,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Recommend Tab Body: Popular Live + Feed Section
  // ===========================================================================
  Widget _buildRecommendTab(bool isDark, List<LiveRoomModel> backendRooms) {
    final social = Provider.of<SocialProvider>(context);

    return RefreshIndicator(
      color: AppColors.pink,
      backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
      onRefresh: () async {
        await Future.wait([
          BackendRepository.instance.fetchLiveRooms(),
          social.loadFeed(refresh: true),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(bottom: 96.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Feed Section with all user-uploaded posts (Popular Live removed per requirement) ──
            _buildFeedSection(isDark, social),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. Popular Live Section (Preserved helper)
  // ===========================================================================
  // ignore: unused_element
  Widget _buildPopularLiveSection(bool isDark, List<LiveRoomModel> backendRooms) {
    // Demonstration stream models matching the exact names & visuals from the screenshot
    final defaultLiveList = [
      const _PopularLiveItem(
        id: 'live_suman',
        name: 'suman',
        location: 'Kolkata',
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
      ),
      const _PopularLiveItem(
        id: 'live_riya',
        name: '🌸🌸riya🌸🌸',
        location: 'Kolkata',
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80',
      ),
      const _PopularLiveItem(
        id: 'live_mk_khan',
        name: 'MK KHAN',
        location: 'Shimla',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
      ),
      const _PopularLiveItem(
        id: 'live_sonia',
        name: 'sonia',
        location: 'Delhi',
        imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&q=80',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sensors_rounded,
                      color: AppColors.pink,
                      size: 18.w,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Popular Live',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LiveExploreScreen()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16.w,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal List of Live Cards
        SizedBox(
          height: 158.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: backendRooms.isNotEmpty ? backendRooms.length : defaultLiveList.length,
            itemBuilder: (context, index) {
              if (backendRooms.isNotEmpty) {
                final room = backendRooms[index];
                return _buildLiveCardFromModel(room, isDark);
              }
              final item = defaultLiveList[index];
              return _buildPopularLiveCard(item, isDark);
            },
          ),
        ),
      ],
    );
  }

  /// Popular Live Card matching reference screenshot:
  /// - Portrait image with rounded corners
  /// - Clear green LIVE badge at top-left
  /// - Streamer's name and location visible at the bottom
  /// - Viewer count and user icon removed as specifically required
  Widget _buildPopularLiveCard(_PopularLiveItem item, bool isDark) {
    return GestureDetector(
      onTap: () {
        final room = LiveRoomModel(
          id: item.id,
          title: '${item.name}\'s Live',
          host: UserModel(
            id: 'host_${item.id}',
            username: item.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
            name: item.name,
            avatarUrl: item.imageUrl,
            region: item.location,
          ),
          coverUrl: item.imageUrl,
          viewerCount: 850,
          category: 'LIVE',
          startTime: DateTime.now(),
          roomType: 'LIVE_VIDEO',
          status: 'LIVE',
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
        );
      },
      child: Container(
        width: 108.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover Photo
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Icon(Icons.person, color: Colors.white, size: 40.w),
                  ),
                ),
              ),

              // Bottom Shadow Gradient for Text Contrast
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Top-Left LIVE Badge (ılı LIVE)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853), // Crisp green matching reference
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.equalizer_rounded, color: Colors.white, size: 11.w),
                      SizedBox(width: 3.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Details: Name & Location (Viewer count removed per requirement)
              Positioned(
                bottom: 8.h,
                left: 8.w,
                right: 8.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 10.w),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.5.sp,
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
        ),
      ),
    );
  }

  Widget _buildLiveCardFromModel(LiveRoomModel room, bool isDark) {
    final location = room.host.region.isNotEmpty ? room.host.region : 'Global';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
        );
      },
      child: Container(
        width: 108.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 40.w),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(7.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.equalizer_rounded, color: Colors.white, size: 11.w),
                      SizedBox(width: 3.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                left: 8.w,
                right: 8.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      room.host.name.isNotEmpty ? room.host.name : room.host.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white70, size: 10.w),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9.5.sp,
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
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. Feed Section matching Reference Screenshot
  // ===========================================================================
  Widget _buildFeedSection(bool isDark, SocialProvider social) {
    // Demonstration posts matching the exact reference screenshot
    final demoFeedPosts = [
      _FeedPostItem(
        id: 'post_1',
        authorId: 'u_zainab',
        authorName: 'Zainab',
        authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        isVerified: true,
        timeAgo: '2h ago',
        location: 'Kolkata',
        mediaUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1000&q=85',
        caption: 'Good vibes only ✨',
        hashtags: '#lifestyle  #vibes  #foryou',
        likes: _demoLikesCount['post_1'] ?? 3200,
        comments: 248,
        shares: _demoSharesCount['post_1'] ?? 112,
        durationText: '0:34',
        isVideo: true,
      ),
      _FeedPostItem(
        id: 'post_2',
        authorId: 'u_manson',
        authorName: 'Mrs manson',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        isVerified: true,
        timeAgo: '5h ago',
        location: 'Lahore',
        mediaUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1000&q=85',
        caption: 'Life is better when you smile 😌',
        hashtags: '#motivation  #smile  #goodvibes',
        likes: _demoLikesCount['post_2'] ?? 2800,
        comments: 176,
        shares: _demoSharesCount['post_2'] ?? 96,
        durationText: '0:28',
        isVideo: true,
      ),
      _FeedPostItem(
        id: 'post_3',
        authorId: 'u_suman',
        authorName: 'suman',
        authorAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
        isVerified: true,
        timeAgo: '8h ago',
        location: 'Karachi',
        mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1000&q=85',
        caption: 'Beautiful sunset 🌅',
        hashtags: '#nature  #sunset  #travel',
        likes: _demoLikesCount['post_3'] ?? 4100,
        comments: 312,
        shares: _demoSharesCount['post_3'] ?? 154,
        durationText: '0:42',
        isVideo: true,
      ),
    ];

    // Convert real backend posts to feed items if available
    final realFeedItems = social.posts.map((p) {
      final media = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
      final isVideo = media.endsWith('.mp4') || media.endsWith('.mov') || media.endsWith('.webm');
      final diff = DateTime.now().difference(p.createdAt);
      final timeStr = diff.inHours < 24 ? '${diff.inHours}h ago' : '${diff.inDays}d ago';

      return _FeedPostItem(
        id: p.id,
        authorId: p.author.id,
        authorName: p.author.displayName.isNotEmpty ? p.author.displayName : (p.author.name.isNotEmpty ? p.author.name : 'Creator'),
        authorAvatar: p.author.avatarUrl,
        isVerified: true,
        timeAgo: timeStr,
        location: p.author.region.isNotEmpty ? p.author.region : 'Global',
        mediaUrl: media.isNotEmpty ? media : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1000&q=85',
        caption: p.content,
        hashtags: '#explore #trending #hemiton',
        likes: p.likes,
        comments: p.comments,
        shares: p.shares,
        durationText: '0:30',
        isVideo: isVideo,
        realPost: p,
      );
    }).toList();

    // Combine real posts and default reference posts (putting real posts first so user's new posts appear immediately at top)
    final combinedPosts = <_FeedPostItem>[];
    for (final item in realFeedItems) {
      combinedPosts.add(item);
    }
    for (final item in demoFeedPosts) {
      if (!combinedPosts.any((e) => e.id == item.id)) {
        combinedPosts.add(item);
      }
    }

    // Feed and View All section header removed as requested in prompt (Feed list directly rendered)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 4.h, bottom: 96.h),
      itemCount: combinedPosts.length,
      itemBuilder: (context, index) {
        final post = combinedPosts[index];
        return _buildFeedPostCard(post, isDark);
      },
    );
  }

  // ===========================================================================
  // Feed Post Card matching exact reference design
  // ===========================================================================
  Widget _buildFeedPostCard(_FeedPostItem post, bool isDark) {
    final auth = Provider.of<AuthProvider>(context);
    final social = Provider.of<SocialProvider>(context, listen: false);

    final isFollowing = auth.isFollowing(post.authorId) || _followedAuthorIds.contains(post.authorId);
    final isLiked = post.realPost?.isLiked == true || _likedPostIds.contains(post.id);

    // Check if author has an active story
    final hasActiveStory = StoryService.instance.hasActiveStory(
      userId: post.authorId,
      userName: post.authorName,
      allPosts: social.posts,
    );

    return Container(
      height: 232.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0F14) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF20232B) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background Media / Video / Image / Text Card ──────────────────
            if (post.mediaUrl.isNotEmpty)
              post.mediaUrl.startsWith('http')
                  ? Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.image_outlined, color: Colors.white24, size: 40.w),
                        ),
                      ),
                    )
                  : Image.file(
                      File(post.mediaUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.image_outlined, color: Colors.white24, size: 40.w),
                        ),
                      ),
                    )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
                alignment: Alignment.center,
                child: Text(
                  post.caption,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.45,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 6),
                    ],
                  ),
                ),
              ),

            // ── Top Gradient Overlay for Header Readability ──────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 72.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Bottom Gradient Overlay for Captions & Controls Readability ───
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ── Top Row: Avatar + Username + Subtitle + Follow + 3-Dots ──────
            Positioned(
              top: 10.h,
              left: 10.w,
              right: 10.w,
              child: Row(
                children: [
                  // Profile Avatar with active story ring (tapping opens story viewer or profile)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      StoryService.handleAvatarTap(
                        context: context,
                        userId: post.authorId,
                        userName: post.authorName,
                        avatarUrl: post.authorAvatar,
                        allPosts: social.posts,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasActiveStory
                            ? const LinearGradient(
                                colors: [AppColors.pink, AppColors.neonPink],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        border: hasActiveStory
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                      ),
                      child: CircleAvatar(
                        radius: 17.r,
                        backgroundColor: Colors.black26,
                        backgroundImage: post.authorAvatar.isNotEmpty
                            ? NetworkImage(post.authorAvatar)
                            : null,
                        child: post.authorAvatar.isEmpty
                            ? Text(
                                post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Username + Location / Time Subtitle
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileDetailsScreen(
                              userId: post.authorId,
                              user: UserModel(
                                id: post.authorId,
                                username: post.authorName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
                                name: post.authorName,
                                avatarUrl: post.authorAvatar,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (post.isVerified) ...[
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.pink,
                                  size: 13.5.w,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '${post.timeAgo}  •  ${post.location}',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: Colors.white.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Pink Outlined Follow Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      AuthGuard.require(context, () {
                        if (isFollowing) {
                          _followedAuthorIds.remove(post.authorId);
                          auth.unfollowUser(post.authorId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unfollowed ${post.authorName}'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          _followedAuthorIds.add(post.authorId);
                          auth.followUser(post.authorId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Followed ${post.authorName} ❤️'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.pink,
                            ),
                          );
                        }
                        setState(() {});
                      }, reason: 'Sign in to follow creators');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.5.h),
                      decoration: BoxDecoration(
                        color: isFollowing ? AppColors.pink.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.pink,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: AppColors.pink,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Three-Dot Overflow Menu
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _showPostOptionsSheet(post);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Content: Caption, Hashtags, Actions (Left) & Play Button (Right)
            Positioned(
              bottom: 10.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left side: Caption, Hashtags, Interaction counts (Likes, Comments, Shares)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Caption
                        Text(
                          post.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.1,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Hashtags
                        Text(
                          post.hashtags,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 7.h),

                        // Actions Row: Like, Comment, Share with counts
                        Row(
                          children: [
                            // Like
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _handleLike(post);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isLiked ? const Color(0xFFFF2D55) : Colors.white,
                                    size: 15.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatCount(isLiked ? post.likes + 1 : post.likes),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Comment
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _handleComment(post);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white,
                                    size: 14.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatCount(post.comments),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Share
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _handleShare(post);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.flip(
                                    flipX: true,
                                    child: Icon(
                                      Icons.reply_rounded,
                                      color: Colors.white,
                                      size: 16.w,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _formatCount(post.shares),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right side: Circular Play Button & Duration (Only for videos)
                  if (post.isVideo)
                    Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _openVideoPlayback(post);
                        },
                        child: Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.62),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22.w,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        post.durationText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Post Interactions (Like, Comment, Share, Video Playback)
  // ===========================================================================
  void _handleLike(_FeedPostItem post) {
    AuthGuard.require(context, () {
      final isCurrentlyLiked = _likedPostIds.contains(post.id) || post.realPost?.isLiked == true;

      if (post.realPost != null) {
        context.read<SocialProvider>().toggleLikePost(post.realPost!.id);
      } else {
        setState(() {
          if (isCurrentlyLiked) {
            _likedPostIds.remove(post.id);
            _demoLikesCount[post.id] = (_demoLikesCount[post.id] ?? post.likes) - 1;
          } else {
            _likedPostIds.add(post.id);
            _demoLikesCount[post.id] = (_demoLikesCount[post.id] ?? post.likes) + 1;
          }
        });
      }
    }, reason: 'Sign in to like posts');
  }

  void _handleComment(_FeedPostItem post) {
    CommentsSheet.show(
      context,
      targetId: post.realPost?.id ?? post.id,
    );
  }

  void _handleShare(_FeedPostItem post) {
    if (post.realPost != null) {
      context.read<SocialProvider>().sharePost(post.realPost!.id);
    } else {
      setState(() {
        _demoSharesCount[post.id] = (_demoSharesCount[post.id] ?? post.shares) + 1;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post by ${post.authorName} shared successfully! 🚀'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.pink,
      ),
    );
  }

  void _openVideoPlayback(_FeedPostItem post) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => _VideoPlayerModal(
        post: post,
      ),
    );
  }

  void _showPostOptionsSheet(_FeedPostItem post) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser.id;
    final isOwner = currentUserId.isNotEmpty && post.authorId == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141720) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppColors.pink),
                title: Text(
                  'Share Post',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleShare(post);
                },
              ),
              ListTile(
                leading: Icon(Icons.link_rounded, color: isDark ? Colors.white70 : Colors.black54),
                title: Text(
                  'Copy Link',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post link copied to clipboard! 📋'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text(
                    'Delete Post',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (post.realPost != null) {
                      context.read<SocialProvider>().deletePost(post.realPost!.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post deleted successfully.')),
                    );
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.amberAccent),
                  title: Text(
                    'Report Post',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ReportSheet.show(
                      context,
                      targetTitle: 'Post by ${post.authorName}',
                      reportedPostId: post.realPost?.id ?? post.id,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '$count';
    }
  }

  // ===========================================================================
  // Friends Tab
  // ===========================================================================
  Widget _buildFriendsTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64.w,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          SizedBox(height: 16.h),
          Text(
            'Connect with Friends',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkNavy,
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Follow other creators and hosts on HEMI TON to see their updates here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? const Color(0xFF7A8B9E) : const Color(0xFF8A9BA8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feed Post Item Model ──────────────────────────────────────────────────────
class _FeedPostItem {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final bool isVerified;
  final String timeAgo;
  final String location;
  final String mediaUrl;
  final String caption;
  final String hashtags;
  final int likes;
  final int comments;
  final int shares;
  final String durationText;
  final bool isVideo;
  final PostModel? realPost;

  const _FeedPostItem({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.isVerified,
    required this.timeAgo,
    required this.location,
    required this.mediaUrl,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.durationText,
    required this.isVideo,
    this.realPost,
  });
}

// ── Models for Popular Live ───────────────────────────────────────────────────
class _PopularLiveItem {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  const _PopularLiveItem({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });
}

// ── Video Player Modal Dialog for Post Playback ───────────────────────────────
class _VideoPlayerModal extends StatefulWidget {
  final _FeedPostItem post;

  const _VideoPlayerModal({required this.post});

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() async {
    final url = widget.post.mediaUrl;
    if (url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.m4v')) {
      try {
        if (url.startsWith('http')) {
          _controller = VideoPlayerController.networkUrl(Uri.parse(url));
        } else {
          _controller = VideoPlayerController.file(File(url));
        }
        await _controller!.initialize();
        _controller!.setLooping(true);
        await _controller!.play();
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _initialized = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_initialized && _controller != null)
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              else
                Image.network(
                  widget.post.mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 60),
                    ),
                  ),
                ),

              // Controls Overlay
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),

              // Play / Pause Toggle
              if (_initialized && _controller != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                        _isPlaying = false;
                      } else {
                        _controller!.play();
                        _isPlaying = true;
                      }
                    });
                  },
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
