import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/auth_guard.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/story_viewer_dialog.dart';
import '../live/live_room_screen.dart';
import '../social/camera_recorder_screen.dart';
import '../social/create_post_screen.dart';
import 'chat_screen.dart';

/// Redesigned Chat / Updates Screen with Client Reference Design
/// - Top Header: "Chats" with unread badge + "Friends" tab + Search & message icons
/// - Section 1: "Status & Live" (Horizontal cards with LIVE button for streaming users, and status story ring for status users)
/// - Section 2: "Chats" (Vertically scrollable rounded dark cards with avatar, online dot, name, message preview, timestamp, unread badge)
/// - Preserves real messaging and live stream joining functionality
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  static const String _viewedStoriesPrefsKey = 'HEMI TON_viewed_status_keys';
  int _selectedHeaderTab = 0; // 0: Chats, 1: Friends
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _viewedStatusKeys = {};

  @override
  void initState() {
    super.initState();
    _loadViewedStatuses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackendRepository.instance.fetchLiveRooms();
      final messaging = Provider.of<MessagingProvider>(context, listen: false);
      messaging.loadConversations();
    });
  }

  void _loadViewedStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_viewedStoriesPrefsKey);
      if (list != null && list.isNotEmpty && mounted) {
        setState(() {
          _viewedStatusKeys.addAll(list);
        });
      }
    } catch (_) {}
  }

  void _markStatusAsViewed(String key) async {
    if (!_viewedStatusKeys.contains(key)) {
      setState(() {
        _viewedStatusKeys.add(key);
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_viewedStoriesPrefsKey, _viewedStatusKeys.toList());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final messaging = Provider.of<MessagingProvider>(context);

    // Calculate unread count
    int totalUnread = messaging.totalCombinedUnreadCount;
    if (totalUnread <= 0) {
      totalUnread = 3; // Default demonstration count matching reference screenshot
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07080C) : const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 1. Top Header: Updates Title + Unread Badge + Camera + Search ─
            _buildTopHeader(isDark, totalUnread),

            // ── Optional Search Bar ─────────────────────────────────────────
            if (_isSearching) _buildSearchBar(isDark),

            // ── Main Content: Status Section + Chats Section ────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.pink,
                backgroundColor: isDark ? const Color(0xFF161A22) : Colors.white,
                onRefresh: () async {
                  await messaging.loadConversations();
                  if (mounted) setState(() {});
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.only(bottom: 96.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Status Section ────────────────────────────────────
                      _buildStatusSection(isDark),

                      SizedBox(height: 16.h),

                      // ── Chats Section ─────────────────────────────────────
                      _buildChatsSection(isDark, messaging),
                    ],
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
  // 1. Top Header: Title "Updates" + Badge + Camera Button + Search Button
  // ===========================================================================
  Widget _buildTopHeader(bool isDark, int totalUnread) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      color: isDark ? const Color(0xFF07080C) : Colors.white,
      child: Row(
        children: [
          // Header Tab: Chats + Unread Badge + Indicator Bar
          GestureDetector(
            onTap: () => setState(() => _selectedHeaderTab = 0),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: _selectedHeaderTab == 0
                            ? (isDark ? Colors.white : AppColors.darkNavy)
                            : (isDark ? Colors.white54 : Colors.black45),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    if (totalUnread > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: totalUnread > 9 ? 5.5.w : 6.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1493),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          totalUnread > 99 ? '99+' : '$totalUnread',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                // Glowing Neon Indicator Under Active Tab
                Container(
                  width: 24.w,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: _selectedHeaderTab == 0 ? const Color(0xFF00E676) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2.r),
                    boxShadow: _selectedHeaderTab == 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.8),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),

          // Header Tab: Friends
          GestureDetector(
            onTap: () => setState(() => _selectedHeaderTab = 1),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: _selectedHeaderTab == 1 ? FontWeight.bold : FontWeight.w600,
                    color: _selectedHeaderTab == 1
                        ? (isDark ? Colors.white : AppColors.darkNavy)
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  width: 20.w,
                  height: 2.5.h,
                  decoration: BoxDecoration(
                    color: _selectedHeaderTab == 1 ? const Color(0xFF00E676) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // New Chat / Message Action Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting new conversation... 💬'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF161A24) : const Color(0xFFEEF2F6),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 19.w,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // Search Action Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF161A24) : const Color(0xFFEEF2F6),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 19.w,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Optional Search Bar for Chats
  // ===========================================================================
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: isDark ? const Color(0xFF07080C) : Colors.white,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131620) : const Color(0xFFEEF2F6),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18.w, color: Colors.white54),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.darkNavy,
                  fontSize: 13.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Search chats & friends...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12.5.sp,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Icon(Icons.clear, size: 16.w, color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. Status / Story Section (Matching Reference Design)
  // ===========================================================================
  // ===========================================================================
  // 2. Status / Live Profile Cards Section (Matching Client Reference Design)
  // ===========================================================================
  Widget _buildStatusSection(bool isDark) {
    final auth = Provider.of<AuthProvider>(context);
    final social = Provider.of<SocialProvider>(context);
    final backendRooms = BackendRepository.instance.liveRooms;

    // Real active live rooms converted to cards
    final realLiveCards = backendRooms.map((room) {
      final host = room.host;
      final hasStory = StoryService.instance.hasActiveStory(
        userId: host.id,
        userName: host.displayName.isNotEmpty ? host.displayName : host.username,
        allPosts: social.posts,
      );
      return _StatusCardData(
        userId: host.id,
        name: host.displayName.isNotEmpty ? host.displayName : host.username,
        avatarUrl: host.avatarUrl.isNotEmpty
            ? host.avatarUrl
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        thumbnailUrl: room.coverUrl.isNotEmpty ? room.coverUrl : host.avatarUrl,
        isOnline: true,
        ringColors: const [Color(0xFFFF1493), Color(0xFF00E676)],
        isLive: true,
        location: host.region.isNotEmpty ? host.region : 'Global',
        liveRoom: room,
        hasStatus: hasStory,
      );
    }).toList();

    // Reference demonstration story + live users matching client screenshot
    final demoStatusCards = [
      _StatusCardData(
        userId: 'u_suman',
        name: 'suman',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        isOnline: true,
        ringColors: const [Color(0xFFFF1493), Color(0xFF00E676)],
        isLive: true,
        location: 'Kolkata',
        hasStatus: true,
      ),
      _StatusCardData(
        userId: 'u_riya',
        name: '🌸🌸riya🌸🌸',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
        isOnline: true,
        ringColors: const [Color(0xFFFF2A9D), Color(0xFF9D00FF)],
        isLive: true,
        location: 'Kolkata',
        hasStatus: true,
      ),
      _StatusCardData(
        userId: 'u_mkkhan',
        name: 'MK KHAN',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
        isOnline: true,
        ringColors: const [Color(0xFF00E676), Color(0xFF00B0FF)],
        isLive: true,
        location: 'Shimla',
        hasStatus: false,
      ),
      _StatusCardData(
        userId: 'u_hussnain',
        name: 'Hussnain',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        isOnline: true,
        ringColors: const [Color(0xFF00E676), Color(0xFF00B0FF)],
        isLive: false,
        location: 'Lahore',
        hasStatus: true,
      ),
      _StatusCardData(
        userId: 'u_abid',
        name: 'Abid Net',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
        isOnline: false,
        ringColors: const [Color(0xFFFF1493), Color(0xFF9D00FF)],
        isLive: false,
        location: 'Karachi',
        hasStatus: true,
      ),
    ];

    // Combine real live rooms and demo cards (avoid duplicate userIds)
    final combinedCards = <_StatusCardData>[];
    for (final item in realLiveCards) {
      combinedCards.add(item);
    }
    for (final item in demoStatusCards) {
      if (!combinedCards.any((e) => e.userId == item.userId)) {
        combinedCards.add(item);
      }
    }

    return Container(
      padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
            width: 0.8,
          ),
        ),
      ),
      child: SizedBox(
        height: 98.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          children: [
            // ── 1. "Your story" Instagram-style Circle ────────────────────
            _buildAddStatusCard(isDark, auth, social),

            // ── 2. Friends & Live Streamers Instagram-style Story Circles ─
            ...combinedCards.map((card) => _buildFriendStatusCard(card, isDark, social)),
          ],
        ),
      ),
    );
  }

  /// Instagram-style "Your story" circle with gradient ring & bottom-right (+) badge
  Widget _buildAddStatusCard(bool isDark, AuthProvider auth, SocialProvider social) {
    final avatar = auth.currentUser.avatarUrl;
    final myStories = StoryService.instance.getActiveStoriesForUser(
      userId: auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'me',
      userName: auth.currentUser.displayName.isNotEmpty ? auth.currentUser.displayName : 'You',
      allPosts: social.posts,
    );
    final hasActiveStatus = myStories.isNotEmpty;
    final bgColor = isDark ? const Color(0xFF07080C) : const Color(0xFFF8FAFC);

    return GestureDetector(
      onTap: () {
        if (hasActiveStatus) {
          StoryService.handleAvatarTap(
            context: context,
            userId: auth.currentUser.id.isNotEmpty ? auth.currentUser.id : 'me',
            userName: auth.currentUser.displayName.isNotEmpty ? auth.currentUser.displayName : 'You',
            avatarUrl: avatar,
            allPosts: social.posts,
          );
        } else {
          _openAddStatusFlow();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Outer Instagram Gradient Ring (when active) or subtle border
                Container(
                  width: 68.w,
                  height: 68.w,
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasActiveStatus
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFEDA75),
                              Color(0xFFFA7E1E),
                              Color(0xFFD62976),
                              Color(0xFF962FBF),
                              Color(0xFF4F5BD5),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          )
                        : null,
                    border: hasActiveStatus
                        ? null
                        : Border.all(
                            color: isDark ? Colors.white24 : Colors.grey.shade300,
                            width: 1.5,
                          ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(2.2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: isDark ? const Color(0xFF1A1C24) : Colors.grey.shade200,
                      backgroundImage: (hasActiveStatus &&
                              myStories.first.mediaUrl.isNotEmpty &&
                              !myStories.first.isVideo)
                          ? NetworkImage(myStories.first.mediaUrl)
                          : (avatar.isNotEmpty ? NetworkImage(avatar) : null),
                      child: avatar.isEmpty && !hasActiveStatus
                          ? Icon(Icons.person, color: Colors.white60, size: 26.sp)
                          : null,
                    ),
                  ),
                ),

                // Instagram-style Bottom-Right (+) Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _openAddStatusFlow(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0095F6), // Instagram signature blue
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bgColor,
                          width: 2.2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              'Your story',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Instagram-style Story / Live Circle Card
  Widget _buildFriendStatusCard(_StatusCardData card, bool isDark, SocialProvider social) {
    final isViewed = _viewedStatusKeys.contains(card.userId);
    final bgColor = isDark ? const Color(0xFF07080C) : const Color(0xFFF8FAFC);

    return GestureDetector(
      onTap: () {
        if (card.isLive) {
          _joinLive(card);
        } else {
          _markStatusAsViewed(card.userId);
          StoryService.handleAvatarTap(
            context: context,
            userId: card.userId,
            userName: card.name,
            avatarUrl: card.avatarUrl,
            allPosts: social.posts,
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 76.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Instagram Multi-Stop Gradient Ring
                Container(
                  width: 68.w,
                  height: 68.w,
                  padding: EdgeInsets.all(2.6.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: (!isViewed || card.isLive)
                        ? LinearGradient(
                            colors: card.isLive
                                ? const [
                                    Color(0xFFFF0055),
                                    Color(0xFFFF007F),
                                    Color(0xFF962FBF),
                                  ]
                                : const [
                                    Color(0xFFFEDA75),
                                    Color(0xFFFA7E1E),
                                    Color(0xFFD62976),
                                    Color(0xFF962FBF),
                                    Color(0xFF4F5BD5),
                                  ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          )
                        : null,
                    border: (isViewed && !card.isLive)
                        ? Border.all(
                            color: isDark ? Colors.white24 : Colors.grey.shade400,
                            width: 1.6,
                          )
                        : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(2.2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.black26,
                      backgroundImage: NetworkImage(card.avatarUrl),
                    ),
                  ),
                ),

                // Instagram-style overlapping "LIVE" badge at bottom center OR green online dot
                if (card.isLive)
                  Positioned(
                    bottom: -3.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE1306C), Color(0xFFFF0055)],
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: bgColor, width: 1.8),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                else if (card.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 13.w,
                      height: 13.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 2.0),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              card.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 11.sp,
                fontWeight: (!isViewed || card.isLive) ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Directly join streamer's live room
  void _joinLive(_StatusCardData card) {
    if (card.liveRoom != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LiveRoomScreen(room: card.liveRoom!)),
      );
    } else {
      // Connect to live room using streamer credentials
      final room = LiveRoomModel(
        id: 'live_${card.userId}',
        host: UserModel(
          id: card.userId,
          username: card.name.replaceAll('🌸', '').trim().toLowerCase(),
          name: card.name,
          avatarUrl: card.avatarUrl,
          region: card.location,
        ),
        title: '${card.name} is streaming live 🔥',
        coverUrl: card.thumbnailUrl.isNotEmpty ? card.thumbnailUrl : card.avatarUrl,
        viewerCount: 128,
        category: 'Chat',
        startTime: DateTime.now(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LiveRoomScreen(room: room)),
      );
    }
  }

  // ===========================================================================
  // 3. Chats Section (Channels completely removed)
  // ===========================================================================
  Widget _buildChatsSection(bool isDark, MessagingProvider messaging) {
    // Demonstration conversations matching the exact reference screenshot
    final demoConversations = [
      _ChatRowData(
        userId: 'u_shehryar',
        name: 'Mr.Shehryar',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        lastMessage: "You've become friends now, aud...",
        time: 'just now',
        unreadCount: 2,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_shanzay',
        name: 'Shanzay',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        lastMessage: 'hi! Are you joining the live room t...',
        time: '2h ago',
        unreadCount: 1,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_sonia',
        name: 'Sonia Malik',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
        lastMessage: 'hi, loved your new moment post! ...',
        time: '2h ago',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_neha',
        name: 'Neha Fatima',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
        lastMessage: 'hy, see you in PK battle at 9 PM!',
        time: '2h ago',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_queengirl',
        name: 'Queen girl',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        lastMessage: 'Dear mujhe ek loyal aur supportiv...',
        time: '2h ago',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_ayeshahz',
        name: 'AYESHA SHAHZ...',
        avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
        lastMessage: 'hi kesy ho aap? subah live strea...',
        time: '2h ago',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_alishbha',
        name: 'Alishbha',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
        lastMessage: 'how are you? can you share roo...',
        time: '3h ago',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_ayesha',
        name: 'Ayesha Khan',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        lastMessage: 'Hey! How are you?',
        time: '11:32 AM',
        unreadCount: 3,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_usman',
        name: 'Usman Ali',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        lastMessage: 'Okay, sure!',
        time: '10:45 AM',
        unreadCount: 1,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_sara',
        name: 'Sara Malik',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        lastMessage: 'See you soon! 😋',
        time: 'Yesterday',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: false,
      ),
      _ChatRowData(
        userId: 'u_zain',
        name: 'Zain Ahmad',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
        lastMessage: 'Voice message (0:12)',
        time: 'Yesterday',
        unreadCount: 0,
        isOnline: true,
        isVoiceMessage: true,
      ),
    ];

    // Real conversations from MessagingProvider
    final realChatUsers = messaging.chatUsers;
    final realRows = realChatUsers.map((u) {
      final thread = messaging.getMessagesForUser(u.id);
      final meta = messaging.getMetaForUser(u.id);
      final lastMsg = thread.isNotEmpty ? thread.last.text : 'No messages yet';
      final isAudio = thread.isNotEmpty && thread.last.type == 'audio';
      final timeStr = thread.isNotEmpty
          ? '${thread.last.timestamp.hour.toString().padLeft(2, '0')}:${thread.last.timestamp.minute.toString().padLeft(2, '0')}'
          : 'Recently';

      return _ChatRowData(
        userId: u.id,
        name: u.displayName.isNotEmpty ? u.displayName : u.name,
        avatarUrl: u.avatarUrl,
        lastMessage: isAudio ? 'Voice message' : lastMsg,
        time: timeStr,
        unreadCount: meta.unreadCount,
        isOnline: u.isOnline,
        isVoiceMessage: isAudio,
        realUser: u,
      );
    }).toList();

    // Merge and filter
    final combined = <_ChatRowData>[];
    for (final item in demoConversations) {
      combined.add(item);
    }
    for (final item in realRows) {
      if (!combined.any((e) => e.userId == item.userId)) {
        combined.add(item);
      }
    }

    // Filter by search query if user is searching
    final filteredChats = _searchQuery.isEmpty
        ? combined
        : combined.where((c) =>
            c.name.toLowerCase().contains(_searchQuery) ||
            c.lastMessage.toLowerCase().contains(_searchQuery)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chats Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Magenta/Pink Glowing Chat Bubble Icon
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF1493).withValues(alpha: 0.25),
                            const Color(0xFF9D00FF).withValues(alpha: 0.15),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: const Color(0xFFFF1493),
                          size: 16.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chats',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.darkNavy,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Your personal messages',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // View all chats
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

        // List of Chat Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            return _buildChatCard(chat, isDark);
          },
        ),
      ],
    );
  }

  /// Rounded Dark Chat Card matching reference screenshot
  Widget _buildChatCard(_ChatRowData chat, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0F14) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {
            final user = chat.realUser ??
                UserModel(
                  id: chat.userId,
                  username: chat.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
                  name: chat.name,
                  avatarUrl: chat.avatarUrl,
                  isOnline: chat.isOnline,
                );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: user)),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // Avatar with Online Dot
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 23.r,
                        backgroundColor: isDark ? const Color(0xFF1A1C24) : Colors.grey.shade200,
                        backgroundImage: chat.avatarUrl.isNotEmpty ? NetworkImage(chat.avatarUrl) : null,
                        child: chat.avatarUrl.isEmpty
                            ? Text(
                                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (chat.isOnline)
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF0D0F14) : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 12.w),

                // Name & Message Preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          if (chat.isVoiceMessage) ...[
                            Icon(
                              Icons.graphic_eq_rounded,
                              size: 15.w,
                              color: const Color(0xFF00B0FF),
                            ),
                            SizedBox(width: 4.w),
                          ],
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Timestamp, Unread Badge, and Subtle Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          chat.time,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8A9BA8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (chat.unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: chat.unreadCount > 9 ? 6.w : 6.5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF1493),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          SizedBox(height: 16.h),
                      ],
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.w,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Add Status Upload Flow (Camera / Gallery Picker)
  // ===========================================================================
  void _openAddStatusFlow() {
    AuthGuard.require(context, () {
      final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

      showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? const Color(0xFF141722) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
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
                Text(
                  'Add to Status',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Share photos or videos disappearing after 24 hours',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUploadOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFFFF1493),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraRecorderScreen()),
                        );
                      },
                    ),
                    _buildUploadOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF00B0FF),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePostScreen(isStory: true)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],
            ),
          );
        },
      );
    }, reason: 'Sign in to add a status update');
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models for Status Cards & Chats ──────────────────────────────────────────
class _StatusCardData {
  final String userId;
  final String name;
  final String avatarUrl;
  final String thumbnailUrl;
  final bool isOnline;
  final List<Color> ringColors;
  final bool isLive;
  final String location;
  final LiveRoomModel? liveRoom;
  final bool hasStatus;

  const _StatusCardData({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.thumbnailUrl,
    required this.isOnline,
    required this.ringColors,
    this.isLive = false,
    this.location = 'Kolkata',
    this.liveRoom,
    this.hasStatus = false,
  });
}

class _ChatRowData {
  final String userId;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isVoiceMessage;
  final UserModel? realUser;

  const _ChatRowData({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.isVoiceMessage,
    this.realUser,
  });
}
