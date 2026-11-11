import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../live/create_live_room_screen.dart';
import '../live/live_room_screen.dart';
import '../notifications/notifications_screen.dart';
import '../party_room/create_party_screen.dart';
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

  bool _isCurrentUserHost(LiveRoomModel room, String currentUserId) {
    final cleanId = currentUserId.trim();
    if (cleanId.isEmpty) return false;
    final hostId = room.host.id.trim();
    final creatorId = room.creatorUserId?.trim() ?? '';
    return (hostId.isNotEmpty && hostId == cleanId) ||
           (creatorId.isNotEmpty && creatorId == cleanId);
  }

  void _openRoomScreen(LiveRoomModel room, {required bool isHost}) {
    if (room.roomType == 'AUDIO_PARTY' || room.roomType.toUpperCase().contains('PARTY')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LivePartyRoomScreen(room: room)),
      );
    } else if (room.roomType == 'GROUP_VIDEO') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupVideoPartyRoomScreen(room: room, isHost: isHost)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room, isHost: isHost)),
      );
    }
  }

  Widget _buildSafeNetworkImage(String url, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (url.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFF140F26),
        child: Center(
          child: Icon(Icons.person_rounded, color: Colors.white24, size: 22.w),
        ),
      );
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final f = File(url);
      if (f.existsSync()) {
        return Image.file(
          f,
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
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
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
    final avatarUrl = currentUser.avatarUrl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: HEMI TON Neon Branding Logo Image in place of LIVE text (Larger size)
          Image.asset(
            'assets/images/hemiton_top_logo.png',
            height: 52.h,
            width: 155.w,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) => ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF00E5FF)],
              ).createShader(bounds),
              child: Text(
                'HEMI TON',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
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
    final currentUserId = authProv.currentUser.id.trim();
    final myLiveRoom = currentUserId.isEmpty
        ? null
        : backendRooms.where((r) => _isCurrentUserHost(r, currentUserId)).firstOrNull;

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

          // If 'All' is selected, display Live Now Hero + Trending Section when real streams exist
          if (showOverview) ...[
            if (backendRooms.isNotEmpty) ...[
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

              // Hero Featured Card: My Room if live, otherwise top active room
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: _buildHeroLiveCardFromModel(myLiveRoom ?? backendRooms.first),
              ),

              if (backendRooms.length > 1) ...[
                SizedBox(height: 12.h),

                // Sub-grid Medium Cards: Next active real broadcasts
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMediumLiveCardFromModel(backendRooms[1]),
                      ),
                      if (backendRooms.length > 2) ...[
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildMediumLiveCardFromModel(backendRooms[2]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (backendRooms.length > 3) ...[
                SizedBox(height: 18.h),

                // Section Header: 🔥 Trending Live
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

                // Horizontal Carousel of real rooms
                _buildTrendingLiveRow(backendRooms.sublist(3)),
              ],

              SizedBox(height: 20.h),
            ],
          ] else ...[
            // Active category banner header for selected sub-tab (Music, Chat, Talent, PK)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: _buildCategoryHeaderBanner(_dailyCategories[_dailySubCategory]),
            ),
            SizedBox(height: 14.h),
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

          if (_groupSubCategory != 0) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: _buildCategoryHeaderBanner(_groupCategories[_groupSubCategory]),
            ),
            SizedBox(height: 14.h),
          ],

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

          if (_videoSubCategory != 0) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: _buildCategoryHeaderBanner(_videoCategories[_videoSubCategory]),
            ),
            SizedBox(height: 14.h),
          ],

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
  // Category Header Banner for Active Subcategory
  // ===========================================================================
  Widget _buildCategoryHeaderBanner(String category) {
    IconData icon;
    String description;
    List<Color> gradientColors;

    switch (category) {
      case 'Music':
        icon = Icons.music_note_rounded;
        description = 'Singing, acoustic jams & live concerts';
        gradientColors = const [Color(0xFF8A2BE2), Color(0xFFFF007F)];
        break;
      case 'Chat':
        icon = Icons.chat_bubble_rounded;
        description = 'Open talk, friendly chit-chat & chill Q&A';
        gradientColors = const [Color(0xFF00C6FF), Color(0xFF0072FF)];
        break;
      case 'Talent':
        icon = Icons.auto_awesome_rounded;
        description = 'Dance, magic, comedy & creative performances';
        gradientColors = const [Color(0xFFFF8C00), Color(0xFFFF007F)];
        break;
      case 'PK':
        icon = Icons.flash_on_rounded;
        description = '1v1 Live Battles, high stakes & team rivalry';
        gradientColors = const [Color(0xFFFF1361), Color(0xFFFFF800)];
        break;
      case 'Talk Show':
        icon = Icons.record_voice_over_rounded;
        description = 'Multi-guest roundtables, life topics & open voice';
        gradientColors = const [Color(0xFF00E5FF), Color(0xFF1200FF)];
        break;
      case 'Fun':
        icon = Icons.celebration_rounded;
        description = 'Party games, jokes, and interactive fun rooms';
        gradientColors = const [Color(0xFFFF007F), Color(0xFFFFB800)];
        break;
      case 'Solo':
        icon = Icons.person_rounded;
        description = 'Solo creators streaming live portrait video';
        gradientColors = const [Color(0xFF8A2BE2), Color(0xFF00E5FF)];
        break;
      case 'Couple':
        icon = Icons.favorite_rounded;
        description = 'Duo hosts, couple chats & shared moments';
        gradientColors = const [Color(0xFFFF007F), Color(0xFFFF4081)];
        break;
      case 'Random':
        icon = Icons.shuffle_rounded;
        description = 'Connect with mystery creators & surprise stages';
        gradientColors = const [Color(0xFF7928CA), Color(0xFFFF0080)];
        break;
      default:
        icon = Icons.sensors_rounded;
        description = 'Explore top live streams in real-time';
        gradientColors = const [Color(0xFFFF007F), Color(0xFFB000FF)];
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withValues(alpha: 0.35),
            gradientColors[1].withValues(alpha: 0.12),
            const Color(0xFF131126),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradientColors[0].withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradientColors),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 19.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '$category Live',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFF0055), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.w,
                            height: 5.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF0055),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'ONLINE',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
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
    final isHost = _isCurrentUserHost(room, authProv.currentUser.id);
    final hostName = room.host.name.isNotEmpty ? room.host.name : (room.host.username.isNotEmpty ? room.host.username : 'Host');

    return _buildHeroLiveCard(
      name: isHost ? '$hostName (You)' : hostName,
      category: room.category.isNotEmpty ? room.category : 'Live Stream',
      categoryIcon: _getCategoryIcon(room.category),
      viewers: '${room.viewerCount}',
      coverUrl: room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl,
      avatarUrl: room.host.avatarUrl,
      isVerified: true,
      onTap: () {
        _openRoomScreen(room, isHost: isHost);
      },
    );
  }

  Widget _buildMediumLiveCardFromModel(LiveRoomModel room) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final isHost = _isCurrentUserHost(room, authProv.currentUser.id);
    final hostName = room.host.name.isNotEmpty ? room.host.name : (room.host.username.isNotEmpty ? room.host.username : 'Host');

    return _buildMediumLiveCard(
      name: isHost ? '$hostName (You)' : hostName,
      category: room.category.isNotEmpty ? room.category : 'Live',
      categoryIcon: _getCategoryIcon(room.category),
      viewers: '${room.viewerCount}',
      coverUrl: room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl,
      avatarUrl: room.host.avatarUrl,
      isVerified: true,
      onTap: () {
        _openRoomScreen(room, isHost: isHost);
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
  // REUSABLE CLEAN EMPTY STATE (No Mock Data)
  // ===========================================================================
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF131126),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.25),
          width: 1.1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 11.5.sp,
            ),
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFF7928CA)],
                ),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TRENDING LIVE HORIZONTAL ROW (Real Backend Rooms Only)
  // ===========================================================================
  Widget _buildTrendingLiveRow([List<LiveRoomModel> rooms = const []]) {
    if (rooms.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 115.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: rooms.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final isMyRoom = _isCurrentUserHost(room, auth.currentUser.id);
          final cat = room.category.isNotEmpty ? room.category : 'Live';
          final img = room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl;
          final name = isMyRoom ? '${room.host.name} (You)' : (room.host.name.isNotEmpty ? room.host.name : room.host.username);

          return GestureDetector(
            onTap: () {
              _openRoomScreen(room, isHost: isMyRoom);
            },
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
                    _buildSafeNetworkImage(img),
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
                                  child: _buildSafeNetworkImage(room.host.avatarUrl),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  name,
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
                                _getCategoryIcon(cat),
                                color: const Color(0xFFE000FF),
                                size: 9.sp,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  cat,
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
  // 2-COLUMN GRID OF DAILY LIVE STREAMERS - Filtered by Active Tab (Real Data)
  // ===========================================================================
  Widget _buildDailyStreamersGrid(List<LiveRoomModel> backendRooms) {
    final selectedCategory = _dailyCategories[_dailySubCategory];

    // Filter real backend rooms matching selected category
    final filteredBackendRooms = backendRooms.where((r) {
      if (_dailySubCategory == 0) return true; // 'All'
      final cat = selectedCategory.toLowerCase();
      final roomCat = r.category.toLowerCase();
      final roomTitle = r.title.toLowerCase();
      if (cat == 'music') {
        return roomCat.contains('music') ||
            roomCat.contains('song') ||
            roomCat.contains('sing') ||
            roomTitle.contains('music') ||
            roomTitle.contains('song') ||
            roomTitle.contains('sing') ||
            r.roomType.toUpperCase().contains('AUDIO');
      } else if (cat == 'chat') {
        return roomCat.contains('chat') ||
            roomCat.contains('talk') ||
            roomCat.contains('chill') ||
            roomCat.contains('q&a') ||
            roomTitle.contains('chat') ||
            roomTitle.contains('talk');
      } else if (cat == 'talent') {
        return roomCat.contains('talent') ||
            roomCat.contains('dance') ||
            roomCat.contains('art') ||
            roomCat.contains('magic') ||
            roomCat.contains('comedy') ||
            roomTitle.contains('talent') ||
            roomTitle.contains('dance');
      } else if (cat == 'pk') {
        return roomCat.contains('pk') ||
            roomCat.contains('battle') ||
            roomTitle.contains('pk') ||
            roomTitle.contains('battle');
      }
      return roomCat.contains(cat) || roomTitle.contains(cat);
    }).toList();

    if (filteredBackendRooms.isEmpty) {
      return _buildEmptyState(
        icon: _getCategoryIcon(selectedCategory),
        title: _dailySubCategory == 0
            ? 'No Live Streams Active'
            : 'No $selectedCategory Streams Active',
        subtitle: 'Be the first to start a live stream and connect with your audience!',
        buttonText: 'Go Live Now',
        onAction: () => _openCreateLiveRoom(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredBackendRooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.90,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        final r = filteredBackendRooms[index];
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isMyRoom = _isCurrentUserHost(r, auth.currentUser.id);
        final cat = r.category.isNotEmpty ? r.category : selectedCategory;
        return _buildDailyStreamerCard(
          name: isMyRoom ? '${r.host.name} (You)' : (r.host.name.isNotEmpty ? r.host.name : r.host.username),
          category: cat,
          categoryIcon: _getCategoryIcon(cat),
          viewers: '${r.viewerCount}',
          coverUrl: r.coverUrl.isNotEmpty ? r.coverUrl : r.host.avatarUrl,
          avatarUrl: r.host.avatarUrl,
          isVerified: true,
          onTap: () {
            _openRoomScreen(r, isHost: isMyRoom);
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('music') || lower.contains('song')) return Icons.music_note_rounded;
    if (lower.contains('chat') || lower.contains('talk')) return Icons.chat_bubble_rounded;
    if (lower.contains('talent') || lower.contains('dance')) return Icons.auto_awesome_rounded;
    if (lower.contains('pk') || lower.contains('battle')) return Icons.flash_on_rounded;
    return Icons.sensors_rounded;
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
      onTap: onTap ?? () => _openLiveStream(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl, category: category),
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
  // 2-COLUMN GRID OF GROUP LIVE CARDS (Multi-seat & Real Party Rooms)
  // ===========================================================================
  Widget _buildGroupStreamersGrid(List<LiveRoomModel> backendRooms) {
    final groupList = <Map<String, dynamic>>[];

    // Add active backend group rooms
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
          'isPrivate': room.isPrivate,
          'roomModel': room,
          'images': [
            room.coverUrl.isNotEmpty ? room.coverUrl : room.host.avatarUrl,
            room.host.avatarUrl.isNotEmpty ? room.host.avatarUrl : room.coverUrl,
          ],
        });
      }
    }

    final selectedGroupCategory = _groupCategories[_groupSubCategory];

    final filteredList = groupList.where((item) {
      if (_groupSubCategory == 0) return true; // 'All'
      final title = (item['title'] as String? ?? '').toLowerCase();
      final subtitle = (item['subtitle'] as String? ?? '').toLowerCase();
      final isPK = item['isPK'] == true;

      switch (selectedGroupCategory) {
        case 'Talk Show':
          return !isPK &&
              (subtitle.contains('talk') ||
                  subtitle.contains('chat') ||
                  subtitle.contains('opinions') ||
                  subtitle.contains('podcast') ||
                  title.contains('talk') ||
                  title.contains('podcast'));
        case 'Talent':
          return !isPK &&
              (subtitle.contains('talent') ||
                  subtitle.contains('stage') ||
                  subtitle.contains('singers') ||
                  title.contains('talent') ||
                  subtitle.contains('music'));
        case 'PK':
          return isPK || title.contains('pk') || subtitle.contains('challenge') || subtitle.contains('war');
        case 'Fun':
          return !isPK &&
              (subtitle.contains('fun') ||
                  subtitle.contains('game') ||
                  title.contains('game') ||
                  title.contains('friends'));
        default:
          return true;
      }
    }).toList();

    if (filteredList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.groups_rounded,
        title: _groupSubCategory == 0
            ? 'No Party Rooms Active'
            : 'No $selectedGroupCategory Party Rooms',
        subtitle: 'Start an audio party or group video room with friends!',
        buttonText: 'Create Party Room',
        onAction: () => _openCreateLiveRoom(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final isPK = item['isPK'] as bool;
        final isPrivate = item['isPrivate'] == true;
        final images = item['images'] as List<String>;

        void enterGroupRoom() {
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
              isPrivate: isPrivate,
            );
          }
        }

        return GestureDetector(
          onTap: () {
            if (isPrivate) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF17122E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: const BorderSide(color: Color(0xFFFF007F), width: 1.2),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.lock_person_rounded, color: Color(0xFFFF007F)),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Private Group Live',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.5.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Permission is required to join "${item['title']}". Would you like to request permission from the host?',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.5.sp),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF007F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.verified_user_rounded, size: 16),
                      label: Text('Request & Join', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        enterGroupRoom();
                      },
                    ),
                  ],
                ),
              );
            } else {
              enterGroupRoom();
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

                  // Top Left Badges: "LIVE" + Viewers (No Public/Private text tags)
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

                  // Top Right: Lock Icon ONLY if Private, or Crown if PK, or 3-Dots
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPrivate)
                          Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.7),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.amber,
                              size: 13.w,
                            ),
                          )
                        else if (isPK)
                          Icon(
                            Icons.emoji_events_rounded,
                            color: const Color(0xFFFFD700),
                            size: 19.w,
                          )
                        else
                          GestureDetector(
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
                      ],
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
  // 2-COLUMN GRID OF VIDEO LIVE STREAMERS - Real Video Rooms Only
  // ===========================================================================
  Widget _buildVideoStreamersGrid(List<LiveRoomModel> backendRooms) {
    final selectedVideoCategory = _videoCategories[_videoSubCategory];

    final videoRooms = backendRooms.where((r) {
      if (r.roomType.toUpperCase().contains('AUDIO')) return false;
      if (_videoSubCategory == 0) return true; // 'All'
      final cat = selectedVideoCategory.toLowerCase();
      final roomCat = r.category.toLowerCase();
      final roomTitle = r.title.toLowerCase();
      return roomCat.contains(cat) || roomTitle.contains(cat);
    }).toList();

    if (videoRooms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.videocam_rounded,
        title: _videoSubCategory == 0
            ? 'No Video Streams Active'
            : 'No $selectedVideoCategory Video Streams',
        subtitle: 'Go live on video to interact with viewers in real-time!',
        buttonText: 'Start Video Live',
        onAction: () => _openCreateLiveRoom(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videoRooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.88,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) {
        final r = videoRooms[index];
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isMyRoom = _isCurrentUserHost(r, auth.currentUser.id);
        return _buildVideoStreamerCard(
          name: isMyRoom ? '${r.host.name} (You)' : (r.host.name.isNotEmpty ? r.host.name : r.host.username),
          category: r.category.isNotEmpty ? r.category : selectedVideoCategory,
          viewers: '${r.viewerCount}',
          hasHeart: true,
          imageUrl: r.coverUrl.isNotEmpty ? r.coverUrl : r.host.avatarUrl,
          onTap: () {
            _openRoomScreen(r, isHost: isMyRoom);
          },
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

    return Positioned(
      key: const ValueKey('live_floating_create_button'),
      bottom: 88.h,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleCreateAction(currentUser),
          customBorder: const CircleBorder(),
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF007F), // Neon Rose
                  Color(0xFFFF1493), // Neon Pink
                  Color(0xFF8A2BE2), // Electric Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreateAction(UserModel currentUser) {
    final isFemale = currentUser.gender.trim().toLowerCase() == 'female';

    if (_selectedMode == 0 && !isFemale) {
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

    String popupTitle = 'Create Live Stream';
    String popupSubtitle = 'Choose your live broadcast format';
    if (_selectedMode == 0) {
      popupTitle = 'Create Daily Live';
      popupSubtitle = 'Exclusive Daily Live for female creators';
    } else if (_selectedMode == 1) {
      popupTitle = 'Create Group Live';
      popupSubtitle = 'Choose Audio or Video Group Live stage';
    } else {
      popupTitle = 'Create Video & Audio Live';
      popupSubtitle = 'Choose Video or Audio broadcast mode';
    }

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
                popupTitle,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                popupSubtitle,
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp),
              ),
              SizedBox(height: 16.h),
              if (_selectedMode == 0) ...[
                // 1. Daily Live Tab (Female Only): Video or Audio Daily Live
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Color(0xFFFF007F)),
                  ),
                  title: Text('Daily Video Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('Go live on camera in Daily Live feed', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateLiveRoomScreen(initialAudioMode: false, isDailyLive: true),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white12, height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF00E5FF)),
                  ),
                  title: Text('Daily Audio Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('Start voice-only Daily Live broadcast', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateLiveRoomScreen(initialAudioMode: true, isDailyLive: true),
                      ),
                    );
                  },
                ),
              ] else if (_selectedMode == 1) ...[
                // 2. Group Live Tab (Both Male & Female): Audio Group Live or Video Group Live
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF00E5FF)),
                  ),
                  title: Text('Audio Group Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  title: Text('Video Group Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
              ] else ...[
                // 3. Video Live Tab (Both Male & Female): Video Live or Audio Live
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam_rounded, color: Color(0xFFFF007F)),
                  ),
                  title: Text('Video Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('Start solo HD camera live broadcast', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateLiveRoomScreen(initialAudioMode: false, isDailyLive: false),
                      ),
                    );
                  },
                ),
                Divider(color: Colors.white12, height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic_rounded, color: Color(0xFF00E5FF)),
                  ),
                  title: Text('Audio Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('Start voice-only live broadcast', style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateLiveRoomScreen(initialAudioMode: true, isDailyLive: false),
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // NAVIGATION HELPERS
  // ===========================================================================
  void _openCreateLiveRoom() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _handleCreateAction(auth.currentUser);
  }

  void _openLiveStream({
    required String name,
    required String avatarUrl,
    required String coverUrl,
    String category = 'Live',
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
      category: category,
      startTime: DateTime.now(),
      roomType: 'LIVE_VIDEO',
      status: 'LIVE',
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
    );
  }

  void _openPartyRoom({required String title, bool isVideo = false, bool isPrivate = false}) {
    final room = LiveRoomModel(
      id: 'party_video_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      title: title,
      coverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
      category: 'Group Live',
      startTime: DateTime.now(),
      host: const UserModel(
        id: 'host_group',
        username: 'group_host',
        name: 'Group Host',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      ),
      roomType: 'GROUP_VIDEO',
      status: 'LIVE',
      viewerCount: 120,
      isPrivate: isPrivate,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupVideoPartyRoomScreen(room: room, isHost: false)),
    );
  }
}
