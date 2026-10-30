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
  // Facebook Reactions tracking per post: e.g. 'like', 'love', 'haha', 'wow', 'sad', 'angry'
  final Map<String, String> _postReactions = {};
  final Map<String, int> _demoLikesCount = {
    'post_hemi': 1200,
    'post_1': 3200,
    'post_2': 842,
    'post_3': 4100,
  };
  final Map<String, int> _demoSharesCount = {
    'post_hemi': 42,
    'post_1': 112,
    'post_2': 18,
    'post_3': 154,
  };
  final Set<String> _followedAuthorIds = {};

  String _formatLocationWithFlag(String location) {
    if (location.isEmpty) return 'Global 🌍';
    final lower = location.toLowerCase();
    if (lower.contains('pakistan') || lower.contains('lahore') || lower.contains('karachi') || lower.contains('islamabad')) {
      if (!location.contains('🇵🇰')) return '$location 🇵🇰';
    } else if (lower.contains('india') || lower.contains('kolkata') || lower.contains('delhi') || lower.contains('mumbai')) {
      if (!location.contains('🇮🇳')) return '$location 🇮🇳';
    } else if (lower.contains('bangladesh') || lower.contains('dhaka')) {
      if (!location.contains('🇧🇩')) return '$location 🇧🇩';
    } else if (lower.contains('dubai') || lower.contains('uae')) {
      if (!location.contains('🇦🇪')) return '$location 🇦🇪';
    } else if (lower.contains('usa') || lower.contains('america') || lower.contains('california')) {
      if (!location.contains('🇺🇸')) return '$location 🇺🇸';
    } else if (lower.contains('uk') || lower.contains('london')) {
      if (!location.contains('🇬🇧')) return '$location 🇬🇧';
    }
    return location;
  }

  late final PageController _headerPageController;

  @override
  void initState() {
    super.initState();
    _headerPageController = PageController(initialPage: _selectedHeaderTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackendRepository.instance.fetchLiveRooms();
      final social = Provider.of<SocialProvider>(context, listen: false);
      if (!social.feedLoaded && !social.feedLoading) {
        social.loadFeed();
      }
    });
  }

  @override
  void dispose() {
    _headerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final backendRooms = BackendRepository.instance.liveRooms;

    return PopScope(
      canPop: _selectedHeaderTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedHeaderTab != 0) {
          setState(() {
            _selectedHeaderTab = 0;
          });
          if (_headerPageController.hasClients) {
            _headerPageController.jumpToPage(0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF070913) : AppColors.lightBackground,
        body: Stack(
          children: [
            SafeArea(
              top: _selectedHeaderTab != 1,
              bottom: false,
              child: Column(
                children: [
                  // Top App Bar & Header Tabs [Recommend, Moments, Friends]
                  // Completely hidden when on Moments tab so double tabs never appear!
                  if (_selectedHeaderTab != 1)
                    _buildTopHeader(isDark),

                  // Tab Content - Horizontal PageView for smooth swipe-to-slide navigation
                  Expanded(
                    child: PageView(
                      controller: _headerPageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _selectedHeaderTab = index;
                        });
                      },
                      children: [
                        // Tab 0: Recommend (Feeds with all user-uploaded posts: videos, images, text; Popular Live removed)
                        _buildRecommendTab(isDark, backendRooms),

                        // Tab 1: Moments (Full-screen vertical reels with For You | Following | Community)
                        MomentsFeedScreen(
                          isEmbeddedInHome: true,
                          onBackToRecommend: () {
                            setState(() {
                              _selectedHeaderTab = 0;
                            });
                            if (_headerPageController.hasClients) {
                              _headerPageController.jumpToPage(0);
                            }
                          },
                        ),

                        // Tab 2: Friends
                        _buildFriendsTab(isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Upload Feed Button in right corner (Visible ONLY when Recommended tab is active)
            Positioned(
              right: 18.w,
              bottom: 84.h,
              child: IgnorePointer(
                ignoring: _selectedHeaderTab != 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _selectedHeaderTab == 0 ? 1.0 : 0.0,
                  curve: Curves.easeOut,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _selectedHeaderTab == 0 ? 1.0 : 0.0,
                    curve: Curves.easeOut,
                    child: _selectedHeaderTab == 0
                        ? KeyedSubtree(
                            key: const ValueKey('home_floating_add_button'),
                            child: _buildFloatingAddButton(isDark),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty_fab')),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 27.sp,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFF101424).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF242B46),
                width: 1.0,
              ),
            ),
            child: Text(
              'Upload Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: isDark ? const Color(0xFF070913) : AppColors.lightBackground,
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
                    key: ValueKey('header_tab_$index'),
                    onTap: () {
                      setState(() {
                        _selectedHeaderTab = index;
                      });
                      if (_headerPageController.hasClients) {
                        _headerPageController.jumpToPage(index);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                      child: Container(
                        margin: EdgeInsets.only(right: index == _headerTabs.length - 1 ? 4.w : 18.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headerTabs[index],
                              style: TextStyle(
                                fontSize: isSelected ? 17.5.sp : 15.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? Colors.white : AppColors.darkNavy)
                                    : (isDark ? const Color(0xFF8896A8) : const Color(0xFF718096)),
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Active Pink / Purple Gradient Indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              width: isSelected ? 32.w : 0,
                              height: 3.2.h,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(2.r),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFF007F).withValues(alpha: 0.65),
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
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Search Icon Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF141829) : const Color(0xFFF1F5F9),
                border: Border.all(
                  color: isDark ? const Color(0xFF222842) : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.search_rounded,
                  size: 20.sp,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // If on Moments: show Post button; otherwise Store/Gift button
          if (_selectedHeaderTab == 1)
            GestureDetector(
              key: const ValueKey('moments_header_post_button'),
              onTap: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadVideoScreen()),
                );
                if (created == true && mounted) {
                  setState(() {});
                }
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
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF141829) : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: isDark ? const Color(0xFF222842) : const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: 19.sp,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
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
      backgroundColor: isDark ? const Color(0xFF0F1322) : Colors.white,
      onRefresh: () async {
        await Future.wait([
          BackendRepository.instance.fetchLiveRooms(),
          social.loadFeed(refresh: true),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(top: 4.h, bottom: 110.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feed Section with all user-uploaded posts & videos (reactive to BackendRepository)
            ListenableBuilder(
              listenable: BackendRepository.instance,
              builder: (context, _) => _buildFeedSection(isDark, social),
            ),
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
        id: 'post_hemi',
        authorId: 'u_hemiton',
        authorName: 'HEMI TON',
        authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        isVerified: true,
        timeAgo: '19h ago',
        location: 'Pakistan',
        mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=85',
        caption: 'Nature always hits different. 🌅',
        hashtags: '',
        likes: _demoLikesCount['post_hemi'] ?? 1200,
        comments: 86,
        shares: _demoSharesCount['post_hemi'] ?? 42,
        durationText: '0:30',
        isVideo: true,
      ),
      _FeedPostItem(
        id: 'post_1',
        authorId: 'u_zainab',
        authorName: 'Zainab',
        authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        isVerified: true,
        timeAgo: '2h ago',
        location: 'Kolkata',
        mediaUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&q=85',
        mediaUrls: const [
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&q=85',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1200&q=85',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200&q=85',
        ],
        caption: 'Good vibes only ✨ Amazing evening with friends!',
        hashtags: '',
        likes: _demoLikesCount['post_1'] ?? 3200,
        comments: 248,
        shares: _demoSharesCount['post_1'] ?? 112,
        durationText: '0:34',
        isVideo: false,
      ),
      _FeedPostItem(
        id: 'post_2',
        authorId: 'u_manson',
        authorName: 'Mrs manson',
        authorAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        isVerified: true,
        timeAgo: '5h ago',
        location: 'Lahore',
        mediaUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=85',
        mediaUrls: const [
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=85',
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=85',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200&q=85',
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200&q=85',
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200&q=85',
        ],
        caption: 'Somewhere between dreams and reality. 🌴✨',
        hashtags: '',
        likes: _demoLikesCount['post_2'] ?? 842,
        comments: 45,
        shares: _demoSharesCount['post_2'] ?? 18,
        durationText: '0:28',
        isVideo: false,
      ),
    ];

    // 1. Convert real uploaded short videos/reels from BackendRepository
    final backendVideoItems = BackendRepository.instance.shortVideos.map((v) {
      return _FeedPostItem(
        id: v.id,
        authorId: v.creator.id,
        authorName: v.creator.displayName.isNotEmpty
            ? v.creator.displayName
            : (v.creator.name.isNotEmpty ? v.creator.name : 'Creator'),
        authorAvatar: v.creator.avatarUrl.isNotEmpty
            ? v.creator.avatarUrl
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        isVerified: true,
        timeAgo: 'Just now',
        location: 'Trending',
        mediaUrl: v.videoUrl,
        caption: v.caption,
        hashtags: '',
        likes: v.likes > 0 ? v.likes : 150,
        comments: v.comments > 0 ? v.comments : 12,
        shares: 45,
        durationText: '0:30',
        isVideo: true,
      );
    }).toList();

    // 2. Convert real backend/local social posts to feed items (exclude stories)
    final realFeedItems = social.posts.where((p) => !p.isStory).map((p) {
      final media = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
      final isVideo = media.toLowerCase().endsWith('.mp4') ||
          media.toLowerCase().endsWith('.mov') ||
          media.toLowerCase().endsWith('.webm') ||
          media.contains('video') ||
          p.content.toLowerCase().contains('#video');
      final diff = DateTime.now().difference(p.createdAt);
      final timeStr = diff.inHours < 24 ? (diff.inHours == 0 ? 'Just now' : '${diff.inHours}h ago') : '${diff.inDays}d ago';

      return _FeedPostItem(
        id: p.id,
        authorId: p.author.id,
        authorName: p.author.displayName.isNotEmpty ? p.author.displayName : (p.author.name.isNotEmpty ? p.author.name : 'Creator'),
        authorAvatar: p.author.avatarUrl,
        isVerified: true,
        timeAgo: timeStr,
        location: p.author.region.isNotEmpty ? p.author.region : 'Global',
        mediaUrl: media,
        mediaUrls: p.imageUrls,
        caption: p.content,
        hashtags: '',
        likes: p.likes,
        comments: p.comments,
        shares: p.shares,
        durationText: '0:30',
        isVideo: isVideo,
        realPost: p,
      );
    }).toList();

    // Combine: user's newly uploaded videos & posts appear FIRST at top of Recommend feed
    // Deduplicate by ID and non-empty media URL so duplicate upload registers never render twice
    final combinedPosts = <_FeedPostItem>[];
    for (final item in backendVideoItems) {
      if (!combinedPosts.any((e) => e.id == item.id || (e.mediaUrl.isNotEmpty && e.mediaUrl == item.mediaUrl))) {
        combinedPosts.add(item);
      }
    }
    for (final item in realFeedItems) {
      if (!combinedPosts.any((e) => e.id == item.id || (e.mediaUrl.isNotEmpty && e.mediaUrl == item.mediaUrl))) {
        combinedPosts.add(item);
      }
    }
    for (final item in demoFeedPosts) {
      if (!combinedPosts.any((e) => e.id == item.id || (e.mediaUrl.isNotEmpty && e.mediaUrl == item.mediaUrl))) {
        combinedPosts.add(item);
      }
    }

    if (combinedPosts.isEmpty) {
      if (social.feedLoading) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 48.h),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.pink, strokeWidth: 2.5),
          ),
        );
      }
      if (social.feedError != null) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.8), size: 48.w),
                SizedBox(height: 12.h),
                Text(
                  'Could not load posts',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink),
                  onPressed: () => social.loadFeed(refresh: true),
                  child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.feed_outlined, color: Colors.white24, size: 54.w),
              SizedBox(height: 12.h),
              Text(
                'No Posts Yet',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                'Be the first to share a moment with the community!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      );
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
  // Feed Post Card matchi  // ===========================================================================
  // Feed Post Card matching Facebook Style Social Design
  // ===========================================================================
  Widget _buildFeedPostCard(_FeedPostItem post, bool isDark) {
    final auth = Provider.of<AuthProvider>(context);
    final social = Provider.of<SocialProvider>(context, listen: false);

    final isFollowing = auth.isFollowing(post.authorId) || _followedAuthorIds.contains(post.authorId);
    final isLiked = _likedPostIds.contains(post.id) ||
        (post.realPost?.isLiked == true && !_likedPostIds.contains('unliked_${post.id}'));
    final int displayLikes = _demoLikesCount[post.id] ?? post.likes;

    final allImages = post.mediaUrls.isNotEmpty
        ? post.mediaUrls
        : (post.mediaUrl.isNotEmpty && !post.isVideo ? [post.mediaUrl] : <String>[]);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101424) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF1D233D) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Facebook-Style Header: Avatar + Name + Timestamp + Public Globe + 3-Dots ──
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
            child: Row(
              children: [
                GestureDetector(
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
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 1.0,
                      ),
                    ),
                    child: ClipOval(
                      child: post.authorAvatar.isNotEmpty
                          ? Image.network(
                              post.authorAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(post.authorName),
                            )
                          : _buildAvatarFallback(post.authorName),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
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
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.darkNavy,
                                ),
                              ),
                            ),
                            if (post.isVerified) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.check_circle_rounded,
                                color: const Color(0xFFFF1493),
                                size: 14.w,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              post.timeAgo,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? const Color(0xFF7E8B9F) : const Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '  •  ',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? const Color(0xFF7E8B9F) : const Color(0xFF64748B),
                              ),
                            ),
                            Icon(
                              Icons.public_rounded,
                              size: 11.5.sp,
                              color: isDark ? const Color(0xFF7E8B9F) : const Color(0xFF64748B),
                            ),
                            if (post.location.isNotEmpty && post.location != 'Global') ...[
                              Text(
                                '  •  ${_formatLocationWithFlag(post.location)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark ? const Color(0xFF7E8B9F) : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Follow Button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AuthGuard.require(context, () {
                      if (isFollowing) {
                        _followedAuthorIds.remove(post.authorId);
                        auth.unfollowUser(post.authorId);
                      } else {
                        _followedAuthorIds.add(post.authorId);
                        auth.followUser(post.authorId);
                      }
                      setState(() {});
                    }, reason: 'Sign in to follow creators');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.5.h),
                    decoration: BoxDecoration(
                      color: isFollowing ? const Color(0xFFFF1493).withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFFF1493),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: const Color(0xFFFF1493),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                // Facebook 3-Horizontal-Dots Menu
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showPostOptionsSheet(post),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. Facebook-Style Caption: Placed ABOVE Media! ──────────────────
          if (post.caption.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
              child: Text(
                post.caption,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (post.hashtags.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 6.h),
              child: Text(
                post.hashtags,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFFFF1493),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // ── 3. Facebook-Style Media Section (Collage Grid or Video Preview) ─
          if (post.isVideo && post.mediaUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _FeedVideoCardPreview(videoUrl: post.mediaUrl),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          post.durationText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () => _openVideoPlayback(post),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.65),
                            border: Border.all(color: Colors.white24, width: 1.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (allImages.isNotEmpty) ...[
            _FacebookCollageGrid(
              mediaUrls: allImages,
              onImageTap: (index) => _openImageGallery(allImages, index),
            ),
          ] else if (post.caption.isEmpty) ...[
            _buildTextPostFallback(post.caption),
          ],

          // ── 4. Facebook Reactions & Engagement Summary Row ──────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stacked Facebook Reactions (👍 Blue + ❤️ Pink)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34.w,
                      height: 18.w,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1877F2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.thumb_up_rounded, color: Colors.white, size: 10.w),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14.w,
                            child: Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF1493),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(Icons.favorite_rounded, color: Colors.white, size: 10.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatCount(displayLikes),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Comments & Shares Counters
                Flexible(
                  child: Text(
                    '${_formatCount(post.comments)} comments  •  ${_formatCount(post.shares)} shares',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 5. Facebook Thin Divider ─────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.6,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            indent: 14.w,
            endIndent: 14.w,
          ),

          // ── 6. Facebook 3-Button Action Bar (Like | Comment | Share) ─────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                // Facebook Like Action Button with Long-Press Reactions (👍 ❤️ 😆 😮 😢 😡)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () => _handleLike(post),
                    onLongPress: () => _showFacebookReactionsPopup(post),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: _buildReactionButtonContent(post, isLiked, isDark),
                    ),
                  ),
                ),

                // Facebook Comment Action Button
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () => _handleComment(post),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 17.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Comment',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFCBD5E1) : AppColors.darkNavy,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Facebook Share Action Button
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: () => _handleShare(post),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFCBD5E1) : AppColors.darkNavy,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openImageGallery(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) => _FullScreenGalleryDialog(images: images, initialIndex: initialIndex),
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      color: const Color(0xFF161A28),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1322), Color(0xFF181E35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 40.w),
      ),
    );
  }

  Widget _buildTextPostFallback(String caption) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF101528), Color(0xFF181F38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      alignment: Alignment.center,
      child: Text(
        caption,
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  // ===========================================================================
  // Post Interactions (Like, Comment, Share, Video Playback)
  // ===========================================================================
  void _handleLike(_FeedPostItem post) {
    AuthGuard.require(context, () {
      final isCurrentlyLiked = _likedPostIds.contains(post.id) ||
          (post.realPost?.isLiked == true && !_likedPostIds.contains('unliked_${post.id}'));

      setState(() {
        if (isCurrentlyLiked) {
          _likedPostIds.remove(post.id);
          _likedPostIds.add('unliked_${post.id}');
          _postReactions.remove(post.id);
          final current = _demoLikesCount[post.id] ?? post.likes;
          _demoLikesCount[post.id] = (current > 0) ? current - 1 : 0;
        } else {
          _likedPostIds.remove('unliked_${post.id}');
          _likedPostIds.add(post.id);
          _postReactions[post.id] = 'like';
          final current = _demoLikesCount[post.id] ?? post.likes;
          _demoLikesCount[post.id] = current + 1;
        }
      });

      if (post.realPost != null) {
        context.read<SocialProvider>().toggleLikePost(post.realPost!.id);
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

  // ===========================================================================
  // Top Story / Status Tray (Facebook & Instagram Style)
  // ===========================================================================
  Widget _buildTopStoryTray(bool isDark, SocialProvider social) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final myStories = StoryService.instance.getActiveStoriesForUser(
      userId: auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'me',
      userName: auth.currentUser.displayName.isNotEmpty ? auth.currentUser.displayName : 'You',
      allPosts: social.posts,
    );
    final hasMyStory = myStories.isNotEmpty;
    final avatar = auth.currentUser.avatarUrl;

    // Distinct demo stories matching top feed
    final demoAuthors = [
      {'id': 'u_zainab', 'name': 'Zainab', 'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80'},
      {'id': 'u_suman', 'name': 'Suman', 'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80'},
      {'id': 'u_riya', 'name': 'Riya', 'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80'},
      {'id': 'u_manson', 'name': 'Mrs manson', 'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'},
      {'id': 'u_mk', 'name': 'MK KHAN', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80'},
    ];

    return Container(
      height: 104.h,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        children: [
          // ── 1. My Story Card ──
          GestureDetector(
            onTap: () {
              if (hasMyStory) {
                StoryService.handleAvatarTap(
                  context: context,
                  userId: auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'me',
                  userName: auth.currentUser.displayName.isNotEmpty ? auth.currentUser.displayName : 'You',
                  avatarUrl: avatar,
                  allPosts: social.posts,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen(isStory: true)),
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: hasMyStory
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF007F), Color(0xFFFF1493), Color(0xFF00E676)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          border: hasMyStory
                              ? null
                              : Border.all(
                                  color: isDark ? const Color(0xFF2C324B) : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                        ),
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: isDark ? const Color(0xFF1E2336) : Colors.grey.shade200,
                          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar.isEmpty
                              ? Icon(Icons.person, color: Colors.white70, size: 24.sp)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePostScreen(isStory: true)),
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
                              border: Border.all(color: isDark ? const Color(0xFF070913) : Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.add_rounded, color: Colors.white, size: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    hasMyStory ? 'Your Story' : 'Add Story',
                    style: TextStyle(
                      color: hasMyStory ? const Color(0xFFFF1493) : (isDark ? Colors.white70 : AppColors.darkNavy),
                      fontSize: 11.5.sp,
                      fontWeight: hasMyStory ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Other Users' Stories ──
          ...demoAuthors.map((authorData) {
            final aId = authorData['id']!;
            final aName = authorData['name']!;
            final aAvatar = authorData['avatar']!;

            return GestureDetector(
              onTap: () {
                StoryService.handleAvatarTap(
                  context: context,
                  userId: aId,
                  userName: aName,
                  avatarUrl: aAvatar,
                  allPosts: social.posts,
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFFB000FF), Color(0xFF00E5FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26.r,
                        backgroundColor: isDark ? const Color(0xFF1E2336) : Colors.grey.shade200,
                        backgroundImage: NetworkImage(aAvatar),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        aName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }


  // ===========================================================================
  // Facebook Reactions Logic & Popup Bar
  // ===========================================================================
  Widget _buildReactionButtonContent(_FeedPostItem post, bool isLiked, bool isDark) {
    final reaction = _postReactions[post.id];
    if (reaction == 'love') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_rounded, color: const Color(0xFFFE2C55), size: 18.sp),
          SizedBox(width: 6.w),
          Text('Love', style: TextStyle(color: const Color(0xFFFE2C55), fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (reaction == 'haha') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('😆', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 6.w),
          Text('Haha', style: TextStyle(color: const Color(0xFFFFB300), fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (reaction == 'wow') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('😮', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 6.w),
          Text('Wow', style: TextStyle(color: const Color(0xFFFB8C00), fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (reaction == 'sad') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('😢', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 6.w),
          Text('Sad', style: TextStyle(color: const Color(0xFF039BE5), fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (reaction == 'angry') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('😡', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 6.w),
          Text('Angry', style: TextStyle(color: const Color(0xFFE53935), fontSize: 12.sp, fontWeight: FontWeight.bold)),
        ],
      );
    }

    final liked = isLiked || reaction == 'like';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          liked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_off_alt_rounded,
          color: liked
              ? (isDark ? const Color(0xFFFF1493) : const Color(0xFF1877F2))
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          size: 18.sp,
        ),
        SizedBox(width: 6.w),
        Text(
          'Like',
          style: TextStyle(
            color: liked
                ? (isDark ? const Color(0xFFFF1493) : const Color(0xFF1877F2))
                : (isDark ? const Color(0xFFCBD5E1) : AppColors.darkNavy),
            fontSize: 12.sp,
            fontWeight: liked ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFacebookReactionsPopup(_FeedPostItem post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E2E),
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReactionEmojiItem(ctx, post, 'like', '👍', 'Like'),
              _buildReactionEmojiItem(ctx, post, 'love', '❤️', 'Love'),
              _buildReactionEmojiItem(ctx, post, 'haha', '😆', 'Haha'),
              _buildReactionEmojiItem(ctx, post, 'wow', '😮', 'Wow'),
              _buildReactionEmojiItem(ctx, post, 'sad', '😢', 'Sad'),
              _buildReactionEmojiItem(ctx, post, 'angry', '😡', 'Angry'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionEmojiItem(BuildContext ctx, _FeedPostItem post, String key, String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          _postReactions[post.id] = key;
          _likedPostIds.remove('unliked_${post.id}');
          _likedPostIds.add(post.id);
          final current = _demoLikesCount[post.id] ?? post.likes;
          _demoLikesCount[post.id] = current + 1;
        });
        if (post.realPost != null) {
          context.read<SocialProvider>().toggleLikePost(post.realPost!.id);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 28.sp)),
          SizedBox(height: 3.h),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.w600)),
        ],
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
  // Friends Tab (Swipe-to-scroll with horizontal friends strip & vertical feed)
  // ===========================================================================
  Widget _buildFriendsTab(bool isDark) {
    final auth = Provider.of<AuthProvider>(context);
    final social = Provider.of<SocialProvider>(context);

    // Online/Active friends for horizontal strip
    final onlineFriends = [
      {
        'id': 'u_zainab',
        'name': 'Zainab',
        'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        'online': true,
      },
      {
        'id': 'u_manson',
        'name': 'Mrs manson',
        'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        'online': true,
      },
      {
        'id': 'u_suman',
        'name': 'Suman',
        'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
        'online': true,
      },
      {
        'id': '22773864',
        'name': 'Anam',
        'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        'online': false,
      },
      {
        'id': '22219520',
        'name': 'Shehryar',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        'online': true,
      },
      {
        'id': '22889911',
        'name': 'Sonia',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
        'online': true,
      },
    ];

    // Filter followed posts or show curated community posts (exclude stories)
    final allFeedItems = social.posts.where((p) => !p.isStory).map((p) {
      final media = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
      final isVideo = media.toLowerCase().endsWith('.mp4') ||
          media.toLowerCase().endsWith('.mov') ||
          media.toLowerCase().endsWith('.webm') ||
          media.contains('video') ||
          p.content.toLowerCase().contains('#video');
      final diff = DateTime.now().difference(p.createdAt);
      final timeStr = diff.inHours < 24 ? (diff.inHours == 0 ? 'Just now' : '${diff.inHours}h ago') : '${diff.inDays}d ago';

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
        hashtags: '#friends #moments',
        likes: p.likes,
        comments: p.comments,
        shares: p.shares,
        durationText: '0:30',
        isVideo: isVideo,
        realPost: p,
      );
    }).toList();

    // Default reference feed posts
    final defaultFriendPosts = [
      _FeedPostItem(
        id: 'post_1',
        authorId: 'u_zainab',
        authorName: 'Zainab',
        authorAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        isVerified: true,
        timeAgo: '2h ago',
        location: 'Kolkata',
        mediaUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1000&q=85',
        caption: 'Good vibes only ✨ Hanging out with friends!',
        hashtags: '#friends  #vibes  #hangout',
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
        caption: 'Life is better when you smile with friends 😌',
        hashtags: '#friendship  #smile  #goodvibes',
        likes: _demoLikesCount['post_2'] ?? 2800,
        comments: 176,
        shares: _demoSharesCount['post_2'] ?? 96,
        durationText: '0:28',
        isVideo: true,
      ),
    ];

    final followedPosts = allFeedItems.where((p) => auth.isFollowing(p.authorId) || _followedAuthorIds.contains(p.authorId)).toList();
    final displayPosts = followedPosts.isNotEmpty ? followedPosts : (allFeedItems.isNotEmpty ? allFeedItems : defaultFriendPosts);

    return RefreshIndicator(
      color: AppColors.pink,
      backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
      onRefresh: () async {
        await social.loadFeed(refresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(top: 8.h, bottom: 96.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Horizontal Swipe-to-Scroll Friends & Story Strip ──────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Friends',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Online Now',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF00E676),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // Horizontal Friend Avatars
            SizedBox(
              height: 88.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: onlineFriends.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Find Friends / Add Friend Action
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 54.w,
                              height: 54.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF1B1E28) : const Color(0xFFF1F5F9),
                                border: Border.all(
                                  color: AppColors.pink.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(Icons.person_add_alt_1_rounded, color: AppColors.pink, size: 22.sp),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Find Friends',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final friend = onlineFriends[index - 1];
                  final isOnline = friend['online'] == true;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileDetailsScreen(
                              userId: friend['id'] as String,
                              user: UserModel(
                                id: friend['id'] as String,
                                name: friend['name'] as String,
                                avatarUrl: friend['avatar'] as String,
                                username: (friend['name'] as String).toLowerCase().replaceAll(' ', '_'),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 54.w,
                                height: 54.w,
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF1493), Color(0xFF00E5FF)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    friend['avatar'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.white24),
                                  ),
                                ),
                              ),
                              if (isOnline)
                                Positioned(
                                  bottom: 1.w,
                                  right: 1.w,
                                  child: Container(
                                    width: 12.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF0D0F14) : Colors.white,
                                        width: 2.w,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            width: 62.w,
                            child: Text(
                              friend['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Divider(color: isDark ? Colors.white10 : Colors.black12, height: 18.h),

            // ── 2. Vertical Feed Section (Friends & Connections Posts) ────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: Text(
                'Friends Updates',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: 4.h),
              itemCount: displayPosts.length,
              itemBuilder: (context, index) {
                final post = displayPosts[index];
                return _buildFeedPostCard(post, isDark);
              },
            ),
          ],
        ),
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
  final List<String> mediaUrls;
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
    this.mediaUrls = const [],
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
    final lower = url.toLowerCase();
    final isVideo = widget.post.isVideo ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm') ||
        lower.contains('video');
    if (isVideo && url.isNotEmpty) {
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
      } catch (e) {
        debugPrint('[VideoPlayerModal] Error playing video: $e');
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
              else if (widget.post.mediaUrl.startsWith('http'))
                Image.network(
                  widget.post.mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.pink, strokeWidth: 2),
                    ),
                  ),
                )
              else if (widget.post.mediaUrl.isNotEmpty && !widget.post.isVideo)
                Image.file(
                  File(widget.post.mediaUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.pink, strokeWidth: 2),
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.pink, strokeWidth: 2),
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

// ── Video Preview Card for Recommended Feed ──────────────────────────────────
class _FeedVideoCardPreview extends StatefulWidget {
  final String videoUrl;
  const _FeedVideoCardPreview({required this.videoUrl});

  @override
  State<_FeedVideoCardPreview> createState() => _FeedVideoCardPreviewState();
}

class _FeedVideoCardPreviewState extends State<_FeedVideoCardPreview> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  @override
  void didUpdateWidget(covariant _FeedVideoCardPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _initialized = false;
      _initPreview();
    }
  }

  void _initPreview() async {
    if (widget.videoUrl.isEmpty) return;
    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        _controller = VideoPlayerController.file(File(widget.videoUrl));
      }
      await _controller!.initialize();
      _controller!.setVolume(0);
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialized && _controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 400,
          height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 600,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.videocam_rounded, color: Colors.white30, size: 48.w),
      ),
    );
  }
}

// ── Facebook Style Multi-Image Collage Grid for Feed Posts ───────────────────
class _FacebookCollageGrid extends StatelessWidget {
  final List<String> mediaUrls;
  final ValueChanged<int> onImageTap;

  const _FacebookCollageGrid({
    required this.mediaUrls,
    required this.onImageTap,
  });

  Widget _buildImageItem(String url, int index, {bool isLastWithOverlay = false, int extraCount = 0}) {
    return GestureDetector(
      onTap: () => onImageTap(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          url.startsWith('http')
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                )
              : Image.file(
                  File(url),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                ),
          if (isLastWithOverlay && extraCount > 0)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              alignment: Alignment.center,
              child: Text(
                '+$extraCount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(color: Colors.black87, blurRadius: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF2E1065), Color(0xFF0F172A)],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 36.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    final count = mediaUrls.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: () {
        if (count == 1) {
          // 1 Image: Full Card Width with Natural Aspect Ratio
          return SizedBox(
            height: 260.h,
            width: double.infinity,
            child: _buildImageItem(mediaUrls[0], 0),
          );
        } else if (count == 2) {
          // 2 Images: 2 Columns Side-by-Side (50/50 Split)
          return SizedBox(
            height: 220.h,
            child: Row(
              children: [
                Expanded(child: _buildImageItem(mediaUrls[0], 0)),
                SizedBox(width: 3.w),
                Expanded(child: _buildImageItem(mediaUrls[1], 1)),
              ],
            ),
          );
        } else if (count == 3) {
          // 3 Images: 1 Large on Top + 2 Side-by-Side Underneath
          return SizedBox(
            height: 260.h,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildImageItem(mediaUrls[0], 0),
                  ),
                ),
                SizedBox(height: 3.h),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(child: _buildImageItem(mediaUrls[1], 1)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildImageItem(mediaUrls[2], 2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (count == 4) {
          // 4 Images: 2x2 Symmetrical Grid
          return SizedBox(
            height: 260.h,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageItem(mediaUrls[0], 0)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildImageItem(mediaUrls[1], 1)),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageItem(mediaUrls[2], 2)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildImageItem(mediaUrls[3], 3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // 5+ Images: Top 2 Images + Bottom 3 Images with '+N' Overlay on the 5th image
          final extraCount = count - 4;
          return SizedBox(
            height: 260.h,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(child: _buildImageItem(mediaUrls[0], 0)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildImageItem(mediaUrls[1], 1)),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(child: _buildImageItem(mediaUrls[2], 2)),
                      SizedBox(width: 3.w),
                      Expanded(child: _buildImageItem(mediaUrls[3], 3)),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildImageItem(
                          mediaUrls[4],
                          4,
                          isLastWithOverlay: true,
                          extraCount: extraCount,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }(),
    );
  }
}

// ── Full-Screen Photo Gallery Dialog with Swipe & Zoom ────────────────────────
class _FullScreenGalleryDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGalleryDialog({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGalleryDialog> createState() => _FullScreenGalleryDialogState();
}

class _FullScreenGalleryDialogState extends State<_FullScreenGalleryDialog> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Swipeable Fullscreen Image PageView with Pinch-to-Zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final url = widget.images[index];
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: Center(
                  child: url.startsWith('http')
                      ? Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white54,
                            size: 64,
                          ),
                        )
                      : Image.file(
                          File(url),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white54,
                            size: 64,
                          ),
                        ),
                ),
              );
            },
          ),

          // 2. Top Header Overlay (Counter + Close Button)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close '✕' Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
                      ),
                    ),
                    // Image Counter Badge (e.g. 2 / 5)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 36.w), // Spacer
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

