import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import 'live_room_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';

class LiveExploreScreen extends StatefulWidget {
  const LiveExploreScreen({super.key});

  @override
  State<LiveExploreScreen> createState() => _LiveExploreScreenState();
}

class _LiveExploreScreenState extends State<LiveExploreScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, String>> _categories = [
    {'icon': '🔥', 'title': 'All'},
    {'icon': '📍', 'title': 'Nearby'},
    {'icon': '✨', 'title': 'New'},
    {'icon': '🎵', 'title': 'Music'},
    {'icon': '💬', 'title': 'Chat'},
    {'icon': '👑', 'title': 'Talent'},
    {'icon': '🎮', 'title': 'Gaming'},
    {'icon': '💃', 'title': 'Dance'},
  ];

  // Demonstration streamers matching Image 2
  final List<_StreamerGridItem> _streamers = const [
    _StreamerGridItem(
      id: 'streamer_1',
      name: 'Neha ✨ 🎤',
      tags: 'Music • Life • Love',
      location: 'Pune',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      viewers: '1.4K',
      diamonds: 320,
    ),
    _StreamerGridItem(
      id: 'streamer_2',
      name: 'Sakshi 💙',
      tags: 'Just Chilling',
      location: 'Delhi',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      viewers: '980',
      diamonds: 180,
    ),
    _StreamerGridItem(
      id: 'streamer_3',
      name: 'Priya 🌸',
      tags: 'Dance • Fun • Chat',
      location: 'Mumbai',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
      viewers: '2.1K',
      diamonds: 540,
    ),
    _StreamerGridItem(
      id: 'streamer_4',
      name: 'Soni 💬',
      tags: 'Let\'s Talk',
      location: 'Hyderabad',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
      viewers: '850',
      diamonds: 210,
    ),
    _StreamerGridItem(
      id: 'streamer_5',
      name: 'Radhika',
      tags: 'Travel • Stories • You',
      location: 'Kolkata',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
      viewers: '1.2K',
      diamonds: 410,
    ),
    _StreamerGridItem(
      id: 'streamer_6',
      name: 'Seema',
      tags: 'Bhakti • Peace • Life',
      location: 'Varanasi',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
      viewers: '620',
      diamonds: 95,
    ),
    _StreamerGridItem(
      id: 'streamer_7',
      name: 'MK KHAN 🔥',
      tags: 'Singing • Guitar',
      location: 'Shimla',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      viewers: '890',
      diamonds: 280,
    ),
    _StreamerGridItem(
      id: 'streamer_8',
      name: 'Ayesha 🎧',
      tags: 'DJ Nights • EDM',
      location: 'Bangalore',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
      coverUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80',
      viewers: '3.4K',
      diamonds: 890,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(isDark),

            // Horizontal Categories Pills
            _buildCategoriesBar(isDark),

            SizedBox(height: 10.h),

            // 2-Column Grid of Live Streamers
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 4.h, bottom: 95.h),
                physics: const BouncingScrollPhysics(),
                itemCount: _streamers.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 12.h,
                ),
                itemBuilder: (context, index) {
                  final s = _streamers[index];
                  return _buildStreamerCard(s, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title + Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  const Text('✨', style: TextStyle(fontSize: 18)),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Real People • Real Moments • Live Now',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF8A9BA8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          // Right Icons: Trophy, Search, Notification
          Row(
            children: [
              // Golden Trophy Icon
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Top Streamers Leaderboard ✨'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.purple,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.gold,
                    size: 24.w,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Search Icon
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    size: 24.w,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Notification Bell with Pink Dot
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                        size: 24.w,
                      ),
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.pink,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Categories Pills Bar ────────────────────────────────────────────────────
  Widget _buildCategoriesBar(bool isDark) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF1493), Color(0xFFFF4081)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9)),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark ? const Color(0xFF202636) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat['icon']!,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      cat['title']!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : const Color(0xFF475569)),
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

  // ── Streamer Grid Card ──────────────────────────────────────────────────────
  Widget _buildStreamerCard(_StreamerGridItem s, bool isDark) {
    return GestureDetector(
      onTap: () {
        // Open the matching Live Room Screen (Image 3)
        final room = LiveRoomModel(
          id: s.id,
          title: '${s.name}\'s Live Room',
          host: UserModel(
            id: 'host_${s.id}',
            username: s.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
            name: s.name,
            avatarUrl: s.avatarUrl,
            region: s.location,
          ),
          coverUrl: s.coverUrl,
          viewerCount: 127,
          category: 'Live',
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Host Cover Photo
              Image.network(
                s.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Icon(Icons.videocam_rounded, color: Colors.white, size: 40.w),
                  ),
                ),
              ),

              // Top Left: "🔥 LIVE" Pill
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFFFF2A85)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🔥', style: TextStyle(fontSize: 9.sp)),
                      SizedBox(width: 3.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dark Bottom Gradient for clear readable text
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.55, 0.78, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Overlay: Avatar + Name + Tags + Location
              Positioned(
                left: 8.w,
                right: 8.w,
                bottom: 8.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Streamer Round Avatar with Ring
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          s.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.pink,
                            child: const Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),

                    // Name + Tags + Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            s.tags,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 9.5.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: Colors.white70,
                                size: 9.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                s.location,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9.sp,
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
}

class _StreamerGridItem {
  final String id;
  final String name;
  final String tags;
  final String location;
  final String avatarUrl;
  final String coverUrl;
  final String viewers;
  final int diamonds;

  const _StreamerGridItem({
    required this.id,
    required this.name,
    required this.tags,
    required this.location,
    required this.avatarUrl,
    required this.coverUrl,
    required this.viewers,
    required this.diamonds,
  });
}
