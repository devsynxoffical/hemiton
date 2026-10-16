import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/repositories/backend_repository.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../search/search_screen.dart';
import '../store/store_screen.dart';
import '../live/live_room_screen.dart';
import '../messages/chat_screen.dart';
import '../messages/inbox_screen.dart';
import '../social/social_feed_screen.dart';

/// HEMI TON Modern Home Screen
/// Matches the exact reference design:
/// - Top Tab Bar: [Recommend, Moments, Friends] + Search & Store Icons
/// - Section 1: "Popular Live" (Horizontal cards with Live badges, Viewers, Location)
/// - Section 2: "Recommended for you" (User portrait cards with Age, Bio, 'Hi' / 'Live' action)
/// - Section 3: "Chats" (Recent conversations with SVIP badges & Unread indicators)
/// - Supports Pure Black (#000000) Dark Mode & Pure White (#FFFFFF) Light Mode
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedHeaderTab = 0; // 0: Recommend, 1: Moments, 2: Friends
  final List<String> _headerTabs = ['Recommend', 'Moments', 'Friends'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackendRepository.instance.fetchLiveRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backend = Provider.of<BackendRepository>(context);
    final liveRooms = backend.liveRooms;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Navigation Header ─────────────────────────────────────────
            _buildTopHeader(isDark),

            // ── Main Body Content ─────────────────────────────────────────────
            Expanded(
              child: _selectedHeaderTab == 0
                  ? _buildRecommendTab(isDark, liveRooms)
                  : _selectedHeaderTab == 1
                      ? const SocialFeedScreen(isScreenActive: true)
                      : _buildFriendsTab(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Top App Bar & Header Tabs [Recommend, Moments, Friends] + Search & Store
  // ===========================================================================
  Widget _buildTopHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: isDark ? AppColors.black : AppColors.lightBackground,
      child: Row(
        children: [
          // Header Tabs (Recommend, Moments, Friends)
          Expanded(
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
                  child: Container(
                    margin: EdgeInsets.only(right: 18.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _headerTabs[index],
                          style: TextStyle(
                            fontSize: isSelected ? 18.sp : 15.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.darkNavy)
                                : (isDark ? const Color(0xFF7A8B9E) : const Color(0xFF8A9BA8)),
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Active Pink Underline Indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: isSelected ? 22.w : 0,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.pink : Colors.transparent,
                            borderRadius: BorderRadius.circular(2.r),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.pink.withValues(alpha: 0.65),
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

          // Search Icon Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF14171F) : const Color(0xFFF0F4F8),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 22.w,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Store / Gift Box Icon Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF14171F) : const Color(0xFFF0F4F8),
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 22.w,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Recommend Tab Body: Popular Live + Recommended For You + Chats
  // ===========================================================================
  Widget _buildRecommendTab(bool isDark, List<LiveRoomModel> backendRooms) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. POPULAR LIVE SECTION ────────────────────────────────────────
          _buildPopularLiveSection(isDark, backendRooms),

          SizedBox(height: 18.h),

          // ── 2. RECOMMENDED FOR YOU SECTION ─────────────────────────────────
          _buildRecommendedForYouSection(isDark),

          SizedBox(height: 22.h),

          // ── 3. CHATS SECTION ───────────────────────────────────────────────
          _buildChatsSection(isDark),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. Popular Live Section
  // ===========================================================================
  Widget _buildPopularLiveSection(bool isDark, List<LiveRoomModel> backendRooms) {
    // Demonstration stream models matching the exact names & tags in user's image
    final defaultLiveList = [
      _PopularLiveItem(
        id: 'live_1',
        name: 'suman',
        viewers: '1.2K',
        location: 'Kolkata',
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
      ),
      _PopularLiveItem(
        id: 'live_2',
        name: '🌸🌸riya🌸🌸',
        viewers: '856',
        location: 'Kolkata',
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80',
      ),
      _PopularLiveItem(
        id: 'live_3',
        name: 'MK KHAN',
        viewers: '642',
        location: 'Shimla',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
      ),
      _PopularLiveItem(
        id: 'live_4',
        name: 'sonia',
        viewers: '980',
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
                    padding: EdgeInsets.all(4.w),
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
                  // Navigate to Live tab
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
          height: 185.h,
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

  Widget _buildPopularLiveCard(_PopularLiveItem item, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Open live room screen simulation
        final room = LiveRoomModel(
          id: item.id,
          title: '${item.name}\'s Live Party',
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
        width: 130.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
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
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
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
                        Colors.black.withValues(alpha: 0.85),
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
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.92), // Crisp Green matching image
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.equalizer_rounded, color: Colors.white, size: 12.w),
                      SizedBox(width: 3.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Details: Name, Viewers, Location
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
                        Icon(Icons.person, color: Colors.white70, size: 10.w),
                        SizedBox(width: 3.w),
                        Text(
                          item.viewers,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
        );
      },
      child: Container(
        width: 130.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
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
                room.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
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
                        Colors.black.withValues(alpha: 0.85),
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
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.equalizer_rounded, color: Colors.white, size: 12.w),
                      SizedBox(width: 3.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
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
                      room.host.name,
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
                        Icon(Icons.person, color: Colors.white70, size: 10.w),
                        SizedBox(width: 3.w),
                        Text(
                          '${room.viewerCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
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
      ),
    );
  }

  // ===========================================================================
  // 2. Recommended For You Section
  // ===========================================================================
  Widget _buildRecommendedForYouSection(bool isDark) {
    // Demonstration profile items matching user's image exactly
    final profiles = [
      _RecommendedProfileItem(
        id: 'rec_1',
        name: 'Zainab',
        gender: '♀',
        age: 41,
        height: '160cm',
        tag: 'Small Business',
        isOnline: true,
        actionType: 'Hi',
        imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&q=80',
      ),
      _RecommendedProfileItem(
        id: 'rec_2',
        name: '" Mrs mansoori 🐱"',
        gender: '♀',
        age: 31,
        height: '159cm',
        tag: 'Business',
        isOnline: true,
        actionType: 'Hi',
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
      ),
      _RecommendedProfileItem(
        id: 'rec_3',
        name: 'suman',
        gender: '♀',
        age: 36,
        height: '161cm',
        tag: 'Cute pie',
        isOnline: true,
        actionType: 'Live',
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
      ),
      _RecommendedProfileItem(
        id: 'rec_4',
        name: 'MK KHAN',
        gender: '♀',
        age: 32,
        height: '160cm',
        tag: 'Small Business',
        isOnline: true,
        actionType: 'Hi',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
      ),
      _RecommendedProfileItem(
        id: 'rec_5',
        name: '🌸🌸riya🌸🌸',
        gender: '♀',
        age: 34,
        height: '158cm',
        tag: 'Small Business',
        isOnline: true,
        actionType: 'Live',
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80',
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
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.pink,
                    size: 19.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
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

        // Horizontal Profiles List
        SizedBox(
          height: 205.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final p = profiles[index];
              return _buildRecommendedProfileCard(p, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedProfileCard(_RecommendedProfileItem p, bool isDark) {
    return Container(
      width: 124.w,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Photo with Online Indicator Dot
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  p.imageUrl,
                  width: double.infinity,
                  height: 82.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 82.h,
                    color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEEF2F6),
                    child: Center(
                      child: Icon(Icons.person, color: AppColors.pink, size: 30.w),
                    ),
                  ),
                ),
              ),
              if (p.isOnline)
                Positioned(
                  bottom: 4.h,
                  right: 4.w,
                  child: Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF111111) : Colors.white,
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 6.h),

          // User Name
          Text(
            p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkNavy,
            ),
          ),

          SizedBox(height: 2.h),

          // Demographics: Gender, Age, Height
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${p.gender} ${p.age}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' · ${p.height}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Bio / Category Tag
          Text(
            p.tag,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5.sp,
              color: isDark ? const Color(0xFF718096) : const Color(0xFF8A9BA8),
            ),
          ),

          const Spacer(),

          // Action Button: "💬 Hi" or "ılı Live"
          GestureDetector(
            onTap: () {
              if (p.actionType == 'Hi') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sent greeting to ${p.name}! ✨'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.pink,
                    duration: const Duration(seconds: 1),
                  ),
                );
              } else {
                final room = LiveRoomModel(
                  id: 'room_${p.id}',
                  title: '${p.name}\'s Live',
                  host: UserModel(
                    id: p.id,
                    username: p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
                    name: p.name,
                    avatarUrl: p.imageUrl,
                  ),
                  coverUrl: p.imageUrl,
                  viewerCount: 520,
                  category: 'LIVE',
                  startTime: DateTime.now(),
                  roomType: 'LIVE_VIDEO',
                  status: 'LIVE',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: 26.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: p.actionType == 'Hi'
                      ? const Color(0xFFFFB300) // Golden Orange border
                      : const Color(0xFF00C853), // Green live border
                  width: 1.2,
                ),
                color: p.actionType == 'Hi'
                    ? const Color(0xFFFFB300).withValues(alpha: 0.08)
                    : const Color(0xFF00C853).withValues(alpha: 0.08),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.actionType == 'Hi') ...[
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 11.w, color: const Color(0xFFFFB300)),
                      SizedBox(width: 4.w),
                      Text(
                        'Hi',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFB300),
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.equalizer_rounded,
                          size: 12.w, color: const Color(0xFF00C853)),
                      SizedBox(width: 3.w),
                      Text(
                        'Live',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00C853),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. Chats Section
  // ===========================================================================
  Widget _buildChatsSection(bool isDark) {
    // Demonstration chat conversations matching the exact names, badges and messages
    final chats = [
      _ChatItem(
        id: 'c1',
        name: '▞▞:Ł€AĐ€Ř .☑...',
        vipBadge: 'SVIP 3',
        vipColor: const Color(0xFF1E88E5), // Blue/Purple SVIP
        lastMessage: 'battery nahi ha ma be band ker raha ho',
        time: '12h ago',
        unreadCount: 3,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
      ),
      _ChatItem(
        id: 'c2',
        name: '@❤️🔥AFZAL...',
        vipBadge: 'SVIP 2',
        vipColor: const Color(0xFF00897B),
        lastMessage: '🌹',
        time: '13h ago',
        unreadCount: 8,
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&q=80',
      ),
      _ChatItem(
        id: 'c3',
        name: '⚡Numan kin...',
        vipBadge: null,
        vipColor: null,
        lastMessage: '[audio]',
        time: '13h ago',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=200&q=80',
      ),
      _ChatItem(
        id: 'c4',
        name: 'MR ʔALO...',
        vipBadge: 'SVIP 1',
        vipColor: const Color(0xFF2E7D32),
        lastMessage: 'cm',
        time: '13h ago',
        unreadCount: 4,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      ),
      _ChatItem(
        id: 'c5',
        name: '💔 👁️‍🗨️ آ تیرے...',
        vipBadge: null,
        vipColor: null,
        lastMessage: 'ok',
        time: '13h ago',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      ),
      _ChatItem(
        id: 'c6',
        name: 'Malik..Sajid...',
        vipBadge: 'SVIP 1',
        vipColor: const Color(0xFF2E7D32),
        lastMessage: 'Malik',
        time: '13h ago',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200&q=80',
      ),
      _ChatItem(
        id: 'c7',
        name: 'adi jee',
        vipBadge: 'SVIP 4',
        vipColor: const Color(0xFF8E24AA), // Purple SVIP
        lastMessage: 'janab kasa ha',
        time: '13h ago',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200&q=80',
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
              Text(
                'Chats',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InboxScreen()),
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

        // Vertical List of Chat Conversations
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          itemCount: chats.length,
          separatorBuilder: (context, index) => Divider(
            height: 14.h,
            color: isDark ? const Color(0xFF161616) : const Color(0xFFF1F5F9),
          ),
          itemBuilder: (context, index) {
            final c = chats[index];
            return _buildChatTile(c, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildChatTile(_ChatItem c, bool isDark) {
    return GestureDetector(
      onTap: () {
        final chatUser = UserModel(
          id: c.id,
          username: c.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
          name: c.name,
          avatarUrl: c.avatarUrl,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(user: chatUser)),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            // Avatar with optional online status indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Image.network(
                    c.avatarUrl,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          c.name.isNotEmpty ? c.name[0] : '?',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.black : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),

            // Name + VIP Badge + Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // User Name
                      Flexible(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                      ),

                      // SVIP Badge (e.g. SVIP 1, SVIP 2, SVIP 3, SVIP 4)
                      if (c.vipBadge != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                c.vipColor ?? AppColors.purple,
                                AppColors.gold,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            c.vipBadge!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    c.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFF8A9BA8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Timestamp + Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c.time,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 6.h),
                if (c.unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: c.unreadCount > 9 ? 6.w : 5.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pink.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '${c.unreadCount}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  SizedBox(height: 16.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Friends Tab Placeholder
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
          Text(
            'Follow other creators and hosts on HEMI TON to see their updates here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? const Color(0xFF7A8B9E) : const Color(0xFF8A9BA8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models for Demonstration ──────────────────────────────────────────────────
class _PopularLiveItem {
  final String id;
  final String name;
  final String viewers;
  final String location;
  final String imageUrl;

  const _PopularLiveItem({
    required this.id,
    required this.name,
    required this.viewers,
    required this.location,
    required this.imageUrl,
  });
}

class _RecommendedProfileItem {
  final String id;
  final String name;
  final String gender;
  final int age;
  final String height;
  final String tag;
  final bool isOnline;
  final String actionType; // 'Hi' or 'Live'
  final String imageUrl;

  const _RecommendedProfileItem({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.height,
    required this.tag,
    required this.isOnline,
    required this.actionType,
    required this.imageUrl,
  });
}

class _ChatItem {
  final String id;
  final String name;
  final String? vipBadge;
  final Color? vipColor;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  const _ChatItem({
    required this.id,
    required this.name,
    this.vipBadge,
    this.vipColor,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarUrl,
  });
}
