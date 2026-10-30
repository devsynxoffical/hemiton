import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/live_room_model.dart';
import '../../models/party_room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../live/create_live_room_screen.dart';
import '../live/live_room_screen.dart';
import '../notifications/notifications_screen.dart';
import '../party_room/create_party_screen.dart';
import '../party_room/party_room_screen.dart';
import '../party_room/group_video_party_room_screen.dart';
import '../party_room/live_party_room_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

/// LiveHomeScreen - Reactive Live Discovery Hub:
/// - Top Bar: Live Add (+) button on left, Search, Notification bell with neon pink badge, User Avatar
/// - Cohesive Palette: Neon Pink (#FF007F / #FF1493), Electric Purple (#8A2BE2 / #9D00FF), Neon Magenta (#E000FF)
/// - Top 3 Switcher Pills: Daily Live, Group Live, Video Live (unified neon gradients)
/// - Reactive to BackendRepository: User's created live streams appear IMMEDIATELY at the top of Live sections!
/// - Daily Live View:
///     • Image 1: "Live Now" Hero + Sub-cards, "Trending Live" Carousel
///     • Image 2: Category Filter Chips (All, Music, Chat, Talent, PK) + 2-Column Live Grid
/// - Group Live View:
///     • Image 3: 2x2 Multi-host participant grid & PK Battle (with VS badge & crown), glowing circular '+' button
/// - Video Live View:
///     • Image 4: Full portrait video cards with live badges, topics, and glowing neon heart action buttons
/// - Typography: Google Fonts Poppins throughout
class LiveHomeScreen extends StatefulWidget {
  const LiveHomeScreen({super.key});

  @override
  State<LiveHomeScreen> createState() => _LiveHomeScreenState();
}

class _LiveHomeScreenState extends State<LiveHomeScreen> {
  // Active top mode: 0 = Daily Live, 1 = Group Live, 2 = Video Live
  int _selectedMode = 0;

  // Filter chips for each mode
  int _dailySubCategory = 0;
  final List<String> _dailyCategories = ['All', 'Music', 'Chat', 'Talent', 'PK'];

  int _groupSubCategory = 0;
  final List<String> _groupCategories = ['All', 'Talk Show', 'Talent', 'PK', 'Fun'];

  int _videoSubCategory = 0;
  final List<String> _videoCategories = ['All', 'Solo', 'Couple', 'Talent', 'Random'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackendRepository.instance.fetchLiveRooms();
    });
  }

  Widget _buildSafeNetworkImage(String url, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFF140F26),
        child: Center(
          child: Icon(Icons.person_rounded, color: Colors.white24, size: 22.w),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgDarkColor = const Color(0xFF090A14);
    final bgColor = isDark ? bgDarkColor : const Color(0xFFF8F9FD);
    final authProv = Provider.of<AuthProvider>(context);
    final currentUser = authProv.currentUser;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top App Bar
                _buildTopBar(isDark),

                // Top 3 Mode Switcher Pills: [Daily Live] [Group Live] [Video Live]
                _buildModePillsBar(),

                SizedBox(height: 10.h),

                // Active Tab Content - Reactive to BackendRepository for immediate live room preview!
                Expanded(
                  child: ListenableBuilder(
                    listenable: BackendRepository.instance,
                    builder: (context, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _buildSelectedModeContent(isDark),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Bottom-Right Floating Create Button (Tab-Specific & Gender Restricted)
            _buildFloatingCreateButton(currentUser),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Top App Bar: "LIVE" branding on Left, Search, Bell, and Avatar on Right
  // ===========================================================================
  Widget _buildTopBar(bool isDark) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProv.currentUser;
    final avatarUrl = currentUser.avatarUrl.isNotEmpty
        ? currentUser.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Stylish Live Branding Badge (Moved create button to bottom-right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFF00E5FF)],
                ).createShader(bounds),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.poppins(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF007F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right: Search, Notification Bell with Neon Pink Dot, User Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Icon Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131126),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Notification Bell with Neon Pink Badge
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131126),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF007F),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // User Avatar with Neon Pink/Purple Ring
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(1.4),
                  child: ClipOval(
                    child: _buildSafeNetworkImage(
                      avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Top 3 Mode Switcher Pills: Unified Neon Pink / Neon Purple / Cyber Palette
  // ===========================================================================
  Widget _buildModePillsBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          // 0: Daily Live (Neon Rose to Magenta Gradient)
          Expanded(
            child: _buildModePill(
              index: 0,
              title: 'Daily Live',
              icon: Icons.podcasts_rounded,
              activeGradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFFFF1493), Color(0xFFE000FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              activeShadowColor: const Color(0xFFFF007F),
            ),
          ),
          SizedBox(width: 8.w),

          // 1: Group Live (Electric Purple to Neon Pink Gradient)
          Expanded(
            child: _buildModePill(
              index: 1,
              title: 'Group Live',
              icon: Icons.groups_rounded,
              activeGradient: const LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFB000FF), Color(0xFFFF1493)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              activeShadowColor: const Color(0xFF8A2BE2),
            ),
          ),
          SizedBox(width: 8.w),

          // 2: Video Live (Cyber Magenta to Deep Neon Violet Gradient)
          Expanded(
            child: _buildModePill(
              index: 2,
              title: 'Video Live',
              icon: Icons.videocam_rounded,
              activeGradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF7928CA), Color(0xFF9D00FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              activeShadowColor: const Color(0xFF9D00FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required int index,
    required String title,
    required IconData icon,
    required LinearGradient activeGradient,
    required Color activeShadowColor,
  }) {
    final isSelected = _selectedMode == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : const Color(0xFF131126),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.35)
                : const Color(0xFF282245),
            width: 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeShadowColor.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 19.w,
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Selected Mode Content
  // ===========================================================================
  Widget _buildSelectedModeContent(bool isDark) {
    switch (_selectedMode) {
      case 0:
        return _buildDailyLiveMode(isDark);
      case 1:
        return _buildGroupLiveMode(isDark);
      case 2:
        return _buildVideoLiveMode(isDark);
      default:
        return _buildDailyLiveMode(isDark);
    }
  }

  // ===========================================================================
  // 1. DAILY LIVE MODE (Images 1 & 2)
  // ===========================================================================
  Widget _buildDailyLiveMode(bool isDark) {
    final showOverview = _dailySubCategory == 0;

    // Check if user has an active live room in BackendRepository
    final backendRooms = BackendRepository.instance.liveRooms
        .where((r) => r.status.toUpperCase() == 'LIVE')
        .toList();

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final myLiveRoom = backendRooms.where((r) => r.host.id == authProv.currentUser.id || r.creatorUserId == authProv.currentUser.id).firstOrNull;

    return SingleChildScrollView(
      key: const ValueKey('daily_live_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter category chips row (All, Music, Chat, Talent, PK)
          _buildFilterChips(
            categories: _dailyCategories,
            selectedIndex: _dailySubCategory,
            onSelect: (idx) {
              setState(() {
                _dailySubCategory = idx;
              });
            },
          ),

          SizedBox(height: 12.h),

          // If 'All' is selected, display Image 1 Featured Live Now Hero + Trending Section
          if (showOverview) ...[
            // Section Header: 🔥 Live Now
            _buildSectionHeader(
              title: 'Live Now',
              iconEmoji: '🔥',
              onSeeAll: () {
                setState(() {
                  _dailySubCategory = 1;
                });
              },
            ),
            SizedBox(height: 8.h),

            // Hero Featured Card: My Room if live, otherwise Sana Malik (Image 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: myLiveRoom != null
                  ? _buildHeroLiveCardFromModel(myLiveRoom)
                  : _buildHeroLiveCard(
                      name: 'Sana Malik',
                      category: 'Chill Vibes & Music',
                      categoryIcon: Icons.music_note_rounded,
                      viewers: '2.4K',
                      coverUrl:
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900&q=80',
                      avatarUrl:
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
                      isVerified: true,
                    ),
            ),

            SizedBox(height: 12.h),

            // Two Sub-grid Medium Cards: Ali Raza & Maya Queen (Image 1)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMediumLiveCard(
                      name: 'Ali Raza',
                      category: 'Let\'s Talk',
                      categoryIcon: Icons.mic_rounded,
                      viewers: '1.8K',
                      coverUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80',
                      avatarUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
                      isVerified: true,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildMediumLiveCard(
                      name: 'Maya Queen',
                      category: 'Q&A Session',
                      categoryIcon: Icons.chat_bubble_rounded,
                      viewers: '956',
                      coverUrl:
                          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&q=80',
                      avatarUrl:
                          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
                      isVerified: true,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Section Header: 🔥 Trending Live (Image 1)
            _buildSectionHeader(
              title: 'Trending Live',
              iconEmoji: '🔥',
              onSeeAll: () {
                setState(() {
                  _dailySubCategory = 1;
                });
              },
            ),
            SizedBox(height: 8.h),

            // Horizontal Carousel of Compact Cards: Zain Khan, Hira Khan, Arjun
            _buildTrendingLiveRow(),

            SizedBox(height: 20.h),
          ],

          // 2-Column Grid of Daily Live Streamers (Image 2) - Merged with user's real created rooms!
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _buildDailyStreamersGrid(backendRooms),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. GROUP LIVE MODE (Image 3)
  // ===========================================================================
  Widget _buildGroupLiveMode(bool isDark) {
    final backendRooms = BackendRepository.instance.liveRooms
        .where((r) => r.status.toUpperCase() == 'LIVE')
        .toList();

    return SingleChildScrollView(
      key: const ValueKey('group_live_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips: All, Talk Show, Talent, PK, Fun
          _buildFilterChips(
            categories: _groupCategories,
            selectedIndex: _groupSubCategory,
            onSelect: (idx) {
              setState(() {
                _groupSubCategory = idx;
              });
            },
          ),

          SizedBox(height: 12.h),

          // 2-Column Grid of Multi-Host & PK Rooms (Image 3)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _buildGroupStreamersGrid(backendRooms),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. VIDEO LIVE MODE (Image 4)
  // ===========================================================================
  Widget _buildVideoLiveMode(bool isDark) {
    final backendRooms = BackendRepository.instance.liveRooms
        .where((r) => r.status.toUpperCase() == 'LIVE')
        .toList();

    return SingleChildScrollView(
      key: const ValueKey('video_live_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips: All, Solo, Couple, Talent, Random
          _buildFilterChips(
            categories: _videoCategories,
            selectedIndex: _videoSubCategory,
            onSelect: (idx) {
              setState(() {
                _videoSubCategory = idx;
              });
            },
          ),

          SizedBox(height: 12.h),

          // 2-Column Grid of Video Streamers (Image 4)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _buildVideoStreamersGrid(backendRooms),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Sub-Category Filter Chips Row (Unified Neon Palette)
  // ===========================================================================
  Widget _buildFilterChips({
    required List<String> categories,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF131126),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.35)
                      : const Color(0xFF282245),
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Section Header: Icon + Title + "See All >"
  // ===========================================================================
  Widget _buildSectionHeader({
    required String title,
    required String iconEmoji,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(iconEmoji, style: TextStyle(fontSize: 15.sp)),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE000FF),
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFE000FF),
                  size: 16.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HERO LIVE CARD FROM REAL USER ROOM
  // ===========================================================================
  Widget _buildHeroLiveCardFromModel(LiveRoomModel room) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final isHost = room.host.id == authProv.currentUser.id || room.creatorUserId == authProv.currentUser.id;

    return _buildHeroLiveCard(
      name: '${room.host.name.isNotEmpty ? room.host.name : room.host.username} (You)',
      category: room.category.isNotEmpty ? room.category : 'Live Stream',
      categoryIcon: Icons.sensors_rounded,
      viewers: '${room.viewerCount}',
      coverUrl: room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl,
      avatarUrl: room.host.avatarUrl,
      isVerified: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room, isHost: isHost)),
        );
      },
    );
  }

  // ===========================================================================
  // HERO LIVE CARD (Image 1: Sana Malik with "▶ Watch Live" button)
  // ===========================================================================
  Widget _buildHeroLiveCard({
    required String name,
    required String category,
    required IconData categoryIcon,
    required String viewers,
    required String coverUrl,
    required String avatarUrl,
    required bool isVerified,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _openLiveStream(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl),
      child: Container(
        height: 152.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFFF007F).withValues(alpha: 0.4),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF007F).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover Photo
              _buildSafeNetworkImage(coverUrl),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Top Left Badges: "LIVE" + Eye Viewer Count
              Positioned(
                top: 10.h,
                left: 10.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLiveBadge(),
                    SizedBox(width: 5.w),
                    _buildViewerCountBadge(viewers),
                  ],
                ),
              ),

              // Top Right 3-Dots
              Positioned(
                top: 10.h,
                right: 10.w,
                child: GestureDetector(
                  onTap: () => _showLiveRoomOptionsSheet(
                    hostName: name,
                    roomTitle: category,
                    roomId: 'hero_$name',
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 16.w,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Info: Avatar, Name, Category + "Watch Live" Button
              Positioned(
                left: 10.w,
                right: 10.w,
                bottom: 10.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar with glowing ring
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF007F),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildSafeNetworkImage(avatarUrl),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Name + Verified + Category Tag
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isVerified) ...[
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.verified_rounded,
                                  color: const Color(0xFF1D9BF0),
                                  size: 13.sp,
                                ),
                              ],
                              SizedBox(width: 4.w),
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF007F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                categoryIcon,
                                color: const Color(0xFFE000FF),
                                size: 11.sp,
                              ),
                              SizedBox(width: 3.w),
                              Flexible(
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5.sp,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // "▶ Watch Live" Neon Pill Button
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007F).withValues(alpha: 0.55),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 15.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Watch Live',
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
  // MEDIUM LIVE CARD (Image 1: Ali Raza, Maya Queen)
  // ===========================================================================
  Widget _buildMediumLiveCard({
    required String name,
    required String category,
    required IconData categoryIcon,
    required String viewers,
    required String coverUrl,
    required String avatarUrl,
    required bool isVerified,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _openLiveStream(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl),
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
            width: 1.1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildSafeNetworkImage(coverUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLiveBadge(),
                    SizedBox(width: 4.w),
                    _buildViewerCountBadge(viewers),
                  ],
                ),
              ),
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF007F), width: 1.2),
                      ),
                      child: ClipOval(
                        child: _buildSafeNetworkImage(avatarUrl),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isVerified) ...[
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.verified_rounded,
                                  color: const Color(0xFF1D9BF0),
                                  size: 11.sp,
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                categoryIcon,
                                color: const Color(0xFFE000FF),
                                size: 10.sp,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5.sp,
                                    color: Colors.white70,
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
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TRENDING LIVE HORIZONTAL ROW (Image 1: Zain Khan, Hira Khan, Arjun)
  // ===========================================================================
  Widget _buildTrendingLiveRow() {
    final trendingList = [
      {
        'name': 'Zain Khan',
        'category': 'Gaming',
        'icon': Icons.sports_esports_rounded,
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80',
      },
      {
        'name': 'Hira Khan',
        'category': 'Music',
        'icon': Icons.music_note_rounded,
        'image':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
      },
      {
        'name': 'Arjun',
        'category': 'Chatting',
        'icon': Icons.chat_bubble_outline_rounded,
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      },
    ];

    return SizedBox(
      height: 115.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: trendingList.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final item = trendingList[index];
          return GestureDetector(
            onTap: () => _openLiveStream(
              name: item['name'] as String,
              avatarUrl: item['image'] as String,
              coverUrl: item['image'] as String,
            ),
            child: Container(
              width: 88.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.3), width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSafeNetworkImage(item['image'] as String),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6.w,
                      right: 6.w,
                      bottom: 6.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: ClipOval(
                                  child: _buildSafeNetworkImage(item['image'] as String),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  item['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: const Color(0xFFE000FF),
                                size: 9.sp,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  item['category'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.sp,
                                    color: Colors.white70,
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
        },
      ),
    );
  }

  // ===========================================================================
  // 2-COLUMN GRID OF DAILY LIVE STREAMERS (Image 2) - Reactive to Real Rooms
  // ===========================================================================
  Widget _buildDailyStreamersGrid(List<LiveRoomModel> backendRooms) {
    final defaultDailyList = [
      {
        'name': 'Sana Malik',
        'category': 'Chill Vibes & Music',
        'icon': Icons.music_note_rounded,
        'viewers': '2.4K',
        'image':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
        'verified': true,
      },
      {
        'name': 'Ayesha Khan',
        'category': 'Daily Talk & Fun',
        'icon': Icons.music_note_rounded,
        'viewers': '1.9K',
        'image':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80',
        'verified': true,
      },
      {
        'name': 'Ali Raza',
        'category': 'Let\'s Talk',
        'icon': Icons.mic_rounded,
        'viewers': '1.8K',
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80',
        'verified': true,
      },
      {
        'name': 'Maya Queen',
        'category': 'Q&A Session',
        'icon': Icons.chat_bubble_rounded,
        'viewers': '1.4K',
        'image':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&q=80',
        'verified': true,
      },
      {
        'name': 'Hira Khan',
        'category': 'Singing Live',
        'icon': Icons.mic_rounded,
        'viewers': '1.2K',
        'image':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&q=80',
        'verified': false,
      },
      {
        'name': 'Zain Khan',
        'category': 'Open Chat',
        'icon': Icons.forum_rounded,
        'viewers': '980',
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&q=80',
        'verified': true,
      },
    ];

    // Combine backend real rooms at top so user sees their own created stream!
    final totalCount = backendRooms.length + defaultDailyList.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.90,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        if (index < backendRooms.length) {
          final r = backendRooms[index];
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final isMyRoom = r.host.id == auth.currentUser.id || r.creatorUserId == auth.currentUser.id;
          return _buildDailyStreamerCard(
            name: isMyRoom ? '${r.host.name} (You)' : (r.host.name.isNotEmpty ? r.host.name : r.host.username),
            category: r.category.isNotEmpty ? r.category : 'Live',
            categoryIcon: Icons.sensors_rounded,
            viewers: '${r.viewerCount}',
            coverUrl: r.coverUrl.isNotEmpty ? r.coverUrl : r.host.avatarUrl,
            avatarUrl: r.host.avatarUrl,
            isVerified: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveRoomScreen(room: r, isHost: isMyRoom)),
              );
            },
          );
        }

        final demoIndex = index - backendRooms.length;
        final item = defaultDailyList[demoIndex];
        return _buildDailyStreamerCard(
          name: item['name'] as String,
          category: item['category'] as String,
          categoryIcon: item['icon'] as IconData,
          viewers: item['viewers'] as String,
          coverUrl: item['image'] as String,
          avatarUrl: item['image'] as String,
          isVerified: item['verified'] as bool,
        );
      },
    );
  }

  Widget _buildDailyStreamerCard({
    required String name,
    required String category,
    required IconData categoryIcon,
    required String viewers,
    required String coverUrl,
    required String avatarUrl,
    required bool isVerified,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _openLiveStream(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildSafeNetworkImage(coverUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Top Left: "LIVE" + Viewers
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLiveBadge(),
                    SizedBox(width: 4.w),
                    _buildViewerCountBadge(viewers),
                  ],
                ),
              ),

              // Top Right: 3-Dots
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => _showLiveRoomOptionsSheet(
                    hostName: name,
                    roomTitle: category,
                    roomId: 'daily_$name',
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white70,
                      size: 16.w,
                    ),
                  ),
                ),
              ),

              // Bottom Info: Avatar, Name, Category
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF007F), width: 1.2),
                      ),
                      child: ClipOval(
                        child: _buildSafeNetworkImage(avatarUrl),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isVerified) ...[
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.verified_rounded,
                                  color: const Color(0xFF1D9BF0),
                                  size: 11.sp,
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                categoryIcon,
                                color: const Color(0xFFE000FF),
                                size: 10.sp,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5.sp,
                                    color: Colors.white70,
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
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2-COLUMN GRID OF GROUP LIVE CARDS (Image 3: Multi-seat & PK Battle)
  // ===========================================================================
  Widget _buildGroupStreamersGrid(List<LiveRoomModel> backendRooms) {
    final groupList = <Map<String, dynamic>>[];

    // 1. Add active backend group rooms at the very top
    for (final room in backendRooms) {
      if (room.roomType == 'AUDIO_PARTY' || room.roomType == 'GROUP_VIDEO' || room.roomType == 'Open Group Live') {
        final isVideo = room.roomType == 'GROUP_VIDEO';
        groupList.add({
          'title': room.title,
          'subtitle': isVideo ? 'Group Video Live 📹' : 'Party Room 🎙️',
          'viewers': '${room.viewerCount}',
          'isPK': false,
          'verified': true,
          'isVideo': isVideo,
          'roomModel': room,
          'images': [
            room.coverUrl.isNotEmpty ? room.coverUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
            room.host.avatarUrl.isNotEmpty ? room.host.avatarUrl : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          ],
        });
      }
    }

    // 2. Demo group stream cards
    groupList.addAll([
      {
        'title': 'Friends Forever',
        'subtitle': 'Fun Chat & Games',
        'viewers': '3.5K',
        'isPK': false,
        'verified': true,
        'images': [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
        ],
      },
      {
        'title': 'Chill Vibes',
        'subtitle': 'Music & Talk',
        'viewers': '2.8K',
        'isPK': false,
        'verified': false,
        'images': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&q=80',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
        ],
      },
      {
        'title': 'Talent Show',
        'subtitle': 'Singing & Entertainment',
        'viewers': '1.9K',
        'isPK': false,
        'verified': false,
        'images': [
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&q=80',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&q=80',
        ],
      },
      {
        'title': 'Open Talk',
        'subtitle': 'Life & Opinions',
        'viewers': '1.6K',
        'isPK': false,
        'verified': false,
        'images': [
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&q=80',
        ],
      },
      {
        'title': 'Game Room',
        'subtitle': 'Play & Win',
        'viewers': '1.2K',
        'isPK': false,
        'verified': false,
        'images': [
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&q=80',
        ],
      },
      {
        'title': 'PK Battle',
        'subtitle': 'Team Challenge',
        'viewers': '980',
        'isPK': true,
        'verified': false,
        'images': [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
        ],
      },
    ]);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        final item = groupList[index];
        final isPK = item['isPK'] as bool;
        final images = item['images'] as List<String>;

        return GestureDetector(
          onTap: () {
            if (item['roomModel'] != null) {
              final r = item['roomModel'] as LiveRoomModel;
              if (item['isVideo'] == true || r.roomType == 'LIVE_VIDEO' || r.roomType == 'GROUP_VIDEO') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GroupVideoPartyRoomScreen(room: r, isHost: false)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LivePartyRoomScreen(room: r)),
                );
              }
            } else {
              _openPartyRoom(
                title: item['title'] as String,
                isVideo: item['isVideo'] == true || _selectedMode == 2,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Upper Grid / Split photo area
                  Positioned.fill(
                    bottom: 46.h,
                    child: isPK
                        ? _buildPKSplitView(images)
                        : (images.length == 4
                            ? _build4SplitView(images)
                            : _build2SplitView(images)),
                  ),

                  // Gradient Dark Overlay for bottom text
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 60.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F1224).withValues(alpha: 0.95),
                            const Color(0xFF0F1224),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Top Left Badges: "LIVE" + Viewers
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLiveBadge(),
                        SizedBox(width: 4.w),
                        _buildViewerCountBadge(item['viewers'] as String),
                      ],
                    ),
                  ),

                  // Top Right 3-Dots or Crown if PK
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: isPK
                        ? Icon(
                            Icons.emoji_events_rounded,
                            color: const Color(0xFFFFD700),
                            size: 19.w,
                          )
                        : GestureDetector(
                            onTap: () => _showLiveRoomOptionsSheet(
                              hostName: item['host'] as String? ?? 'Group Host',
                              roomTitle: item['title'] as String? ?? 'Group Live',
                              roomId: 'group_$index',
                            ),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white70,
                                size: 16.w,
                              ),
                            ),
                          ),
                  ),

                  // Bottom Info & Circular '+' Button (Neon Pink-Purple Gradient)
                  Positioned(
                    left: 8.w,
                    right: 8.w,
                    bottom: 8.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item['title'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (item['verified'] == true) ...[
                                    SizedBox(width: 2.w),
                                    Icon(
                                      Icons.verified_rounded,
                                      color: const Color(0xFF1D9BF0),
                                      size: 11.sp,
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.group_rounded,
                                    color: const Color(0xFFE000FF),
                                    size: 10.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                  Flexible(
                                    child: Text(
                                      item['subtitle'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Glowing Circular '+' Join Seat Button (Neon Gradient)
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007F).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 2x2 Split View for 4 participants
  Widget _build4SplitView(List<String> images) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSafeNetworkImage(images[0])),
              Container(width: 1, color: Colors.black45),
              Expanded(child: _buildSafeNetworkImage(images[1])),
            ],
          ),
        ),
        Container(height: 1, color: Colors.black45),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSafeNetworkImage(images[2])),
              Container(width: 1, color: Colors.black45),
              Expanded(child: _buildSafeNetworkImage(images[3])),
            ],
          ),
        ),
      ],
    );
  }

  // 2-Split View for 2 participants
  Widget _build2SplitView(List<String> images) {
    return Row(
      children: [
        Expanded(child: _buildSafeNetworkImage(images[0])),
        Container(width: 1, color: Colors.black45),
        Expanded(child: _buildSafeNetworkImage(images[1])),
      ],
    );
  }

  // PK Battle Split View with Central "VS" Badge
  Widget _buildPKSplitView(List<String> images) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _buildSafeNetworkImage(images[0])),
            Container(width: 1, color: Colors.black45),
            Expanded(child: _buildSafeNetworkImage(images[1])),
          ],
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF7928CA)],
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'VS',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 2-COLUMN GRID OF VIDEO LIVE STREAMERS (Image 4) - Merged with Real Video Rooms
  // ===========================================================================
  Widget _buildVideoStreamersGrid(List<LiveRoomModel> backendRooms) {
    final videoList = [
      {
        'name': 'Nida Sheikh',
        'category': 'Dance & Fun',
        'viewers': '1.9K',
        'hasHeart': false,
        'image':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
      },
      {
        'name': 'Rohan',
        'category': 'Travel Vlog',
        'viewers': '1.3K',
        'hasHeart': true,
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80',
      },
      {
        'name': 'Hira Khan',
        'category': 'Fitness & Lifestyle',
        'viewers': '1.1K',
        'hasHeart': true,
        'image':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&q=80',
      },
      {
        'name': 'Zain Khan',
        'category': 'Daily Vlog',
        'viewers': '980',
        'hasHeart': true,
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&q=80',
      },
      {
        'name': 'Alisha',
        'category': 'Beauty Tips',
        'viewers': '860',
        'hasHeart': true,
        'image':
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=600&q=80',
      },
      {
        'name': 'Kabir',
        'category': 'Tech Talk',
        'viewers': '720',
        'hasHeart': true,
        'image':
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80',
      },
    ];

    final videoRooms = backendRooms.where((r) => !r.roomType.toUpperCase().contains('AUDIO')).toList();
    final totalCount = videoRooms.length + videoList.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        if (index < videoRooms.length) {
          final r = videoRooms[index];
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final isMyRoom = r.host.id == auth.currentUser.id || r.creatorUserId == auth.currentUser.id;
          return _buildVideoStreamerCard(
            name: isMyRoom ? '${r.host.name} (You)' : (r.host.name.isNotEmpty ? r.host.name : r.host.username),
            category: r.category.isNotEmpty ? r.category : 'Video Live',
            viewers: '${r.viewerCount}',
            hasHeart: true,
            imageUrl: r.coverUrl.isNotEmpty ? r.coverUrl : r.host.avatarUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveRoomScreen(room: r, isHost: isMyRoom)),
              );
            },
          );
        }

        final demoIndex = index - videoRooms.length;
        final item = videoList[demoIndex];
        return _buildVideoStreamerCard(
          name: item['name'] as String,
          category: item['category'] as String,
          viewers: item['viewers'] as String,
          hasHeart: item['hasHeart'] as bool,
          imageUrl: item['image'] as String,
          onTap: () => _openLiveStream(
            name: item['name'] as String,
            avatarUrl: item['image'] as String,
            coverUrl: item['image'] as String,
          ),
        );
      },
    );
  }

  Widget _buildVideoStreamerCard({
    required String name,
    required String category,
    required String viewers,
    required bool hasHeart,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildSafeNetworkImage(imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Top Left: "LIVE" + Viewers
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLiveBadge(),
                    SizedBox(width: 4.w),
                    _buildViewerCountBadge(viewers),
                  ],
                ),
              ),

              // Top Right: 3-Dots
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => _showLiveRoomOptionsSheet(
                    hostName: name,
                    roomTitle: category,
                    roomId: 'video_$name',
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white70,
                      size: 16.w,
                    ),
                  ),
                ),
              ),

              // Bottom Info & Glowing Heart Icon (Neon Hot Pink)
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF007F), width: 1.2),
                      ),
                      child: ClipOval(
                        child: _buildSafeNetworkImage(imageUrl),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.videocam_rounded,
                                color: const Color(0xFFE000FF),
                                size: 10.sp,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Glowing Neon Hot Pink Heart
                    if (hasHeart)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: const Color(0xFFFF007F),
                          size: 16.sp,
                        ),
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
  // BADGES: LIVE & VIEWER COUNT
  // ===========================================================================
  Widget _buildLiveBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0055),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0055).withValues(alpha: 0.55),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        'LIVE',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildViewerCountBadge(String viewers) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_rounded,
            color: Colors.white,
            size: 10.sp,
          ),
          SizedBox(width: 3.w),
          Text(
            viewers,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3-DOTS LIVE ROOM OPTIONS MODAL SHEET
  // ===========================================================================
  void _showLiveRoomOptionsSheet({
    required String hostName,
    required String roomTitle,
    required String roomId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141026),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pull bar
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 14.h),

                // Stream Info Header
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFFB000FF)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          hostName.isNotEmpty ? hostName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hostName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            roomTitle,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),

                // Option 1: Share Room
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: Color(0xFFFF1493)),
                  title: const Text('Share Live Stream', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stream link for $hostName copied to clipboard! 📋'),
                        backgroundColor: const Color(0xFFFF1493),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                // Option 2: Not Interested
                ListTile(
                  leading: const Icon(Icons.visibility_off_rounded, color: Color(0xFF64B5F6)),
                  title: const Text('Not Interested', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text('See fewer streams like this', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stream hidden. We will tune your recommendations.'),
                        backgroundColor: Color(0xFF1E293B),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                // Option 3: Report Stream
                ListTile(
                  leading: const Icon(Icons.flag_rounded, color: Colors.orangeAccent),
                  title: const Text('Report Live Stream', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you. Stream reported for review.'),
                        backgroundColor: Colors.orangeAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BOTTOM-RIGHT FLOATING CREATE BUTTON (Tab-Specific & Gender Restricted)
  // ===========================================================================
  Widget _buildFloatingCreateButton(UserModel currentUser) {
    final gender = currentUser.gender.trim().toLowerCase();
    final isFemale = gender == 'female';

    // DAILY LIVE (Tab 0): Exclusively for female creators!
    // Male users can watch/browse daily live, but cannot create.
    if (_selectedMode == 0 && !isFemale) {
      return const SizedBox.shrink();
    }

    String label = 'Go Live';
    if (_selectedMode == 0) {
      label = 'Daily Live';
    } else if (_selectedMode == 1) {
      label = 'Group Live';
    } else {
      label = 'Video Live';
    }

    return Positioned(
      key: const ValueKey('live_floating_create_button'),
      bottom: 88.h,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleCreateAction(currentUser),
          borderRadius: BorderRadius.circular(28.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF007F), // Neon Rose
                  Color(0xFFFF1493), // Neon Pink
                  Color(0xFF8A2BE2), // Electric Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.55),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreateAction(UserModel currentUser) {
    if (_selectedMode == 0) {
      // 1. Daily Live Tab: Exclusively for female accounts
      final isFemale = currentUser.gender.trim().toLowerCase() == 'female';
      if (!isFemale) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily Live creation is exclusively available for verified female creators.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF007F),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateLiveRoomScreen(initialAudioMode: false, isDailyLive: true),
        ),
      );
    } else if (_selectedMode == 1) {
      // 2. Group Live Tab: For both male & female -> Audio Group Live or Video Group Live
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          side: const BorderSide(color: Color(0xFF8A2BE2), width: 1.2),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Create Group Live',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF00E5FF)),
                  ),
                  title: Text('Audio Party Stage', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('8-10 Audio seats with live gifts & chat', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePartyScreen(initialRoomType: 'AUDIO_PARTY'),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white12, height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Color(0xFFFF007F)),
                  ),
                  title: Text('Group Video Stage', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('8-10 Multi-camera video live boxes', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatePartyScreen(initialRoomType: 'GROUP_VIDEO'),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      );
    } else {
      // 3. Video Live Tab: For both male & female -> Solo/Broadcast Video Live
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateLiveRoomScreen(initialAudioMode: false, isDailyLive: false),
        ),
      );
    }
  }

  // ===========================================================================
  // NAVIGATION HELPERS
  // ===========================================================================
  void _openLiveStream({
    required String name,
    required String avatarUrl,
    required String coverUrl,
  }) {
    final room = LiveRoomModel(
      id: 'room_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      title: '$name\'s Live Stream',
      host: UserModel(
        id: 'host_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        username: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
        name: name,
        avatarUrl: avatarUrl,
        region: 'Global 🌍',
      ),
      coverUrl: coverUrl,
      viewerCount: 1420,
      category: 'Live',
      startTime: DateTime.now(),
      roomType: 'LIVE_VIDEO',
      status: 'LIVE',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
    );
  }

  void _openPartyRoom({required String title, bool isVideo = false}) {
    if (isVideo) {
      final room = LiveRoomModel(
        id: 'party_video_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        title: title,
        coverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
        category: 'Live Video',
        startTime: DateTime.now(),
        host: const UserModel(
          id: 'host_group',
          username: 'group_host',
          name: 'Group Host',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        ),
        roomType: 'GROUP_VIDEO',
        status: 'LIVE',
        viewerCount: 120,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupVideoPartyRoomScreen(room: room, isHost: false)),
      );
      return;
    }

    final room = PartyRoomModel(
      id: 'party_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      title: title,
      host: const UserModel(
        id: 'host_group',
        username: 'group_host',
        name: 'Group Host',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      ),
      roomType: 'Open Group Live',
      seats: const [],
      totalListeners: 120,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PartyRoomScreen(partyRoom: room)),
    );
  }
}
