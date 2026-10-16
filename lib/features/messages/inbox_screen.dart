import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../profile/user_profile_details_screen.dart';
import '../profile/visitors_screen.dart';
import 'chat_screen.dart';

/// Attractive Chats & Friends Screen
/// Inspired by Image 3 & Image 4 reference design:
/// - Top Tab Bar: [Chats, Friends] with active glowing neon indicator
/// - Top Actions: Clean inbox / sweep icon + Search icon (with toggleable search bar)
/// - Chats Tab:
///   * "Recent Visitors" glowing card at the top (with eye icon, visitor name, and "just now")
///   * Rich conversation list with online dots, last message preview, unread badges, timestamps
/// - Friends Tab:
///   * Category pills: [Following, Friends, Followers]
///   * Friends list with gender/age badges, VIP flame indicators, and one-tap profile navigation
/// - High-end modern aesthetics (glassmorphism, smooth animations, dark & light mode)
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMainTab = 0; // 0: Chats, 1: Friends
  int _selectedFriendsFilter = 1; // 0: Following, 1: Friends, 2: Followers
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Demo conversations matching Image 3 reference
  final List<_ConversationData> _demoChats = [
    _ConversationData(
      id: 'c1',
      userId: '22219520',
      name: 'Mr.Shehryar',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      lastMessage: "You've become friends now, audio/video call ready...",
      timeText: 'just now',
      unreadCount: 2,
      isOnline: true,
      gender: 'male',
      age: 24,
    ),
    _ConversationData(
      id: 'c2',
      userId: '22334455',
      name: 'Shanzay',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      lastMessage: 'hi! Are you joining the live room tonight? ✨',
      timeText: '2h ago',
      unreadCount: 1,
      isOnline: true,
      gender: 'female',
      age: 21,
    ),
    _ConversationData(
      id: 'c3',
      userId: '22445566',
      name: 'Sonia Malik',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      lastMessage: 'hi, loved your new moment post! ❤️',
      timeText: '2h ago',
      unreadCount: 0,
      isOnline: false,
      gender: 'female',
      age: 22,
    ),
    _ConversationData(
      id: 'c4',
      userId: '22556677',
      name: 'Neha Fatima',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
      lastMessage: 'hy, see you in PK battle at 9 PM!',
      timeText: '2h ago',
      unreadCount: 0,
      isOnline: true,
      gender: 'female',
      age: 20,
    ),
    _ConversationData(
      id: 'c5',
      userId: '22667788',
      name: 'Queen girl',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
      lastMessage: 'Dear mujhe ek loyal aur supportive host chahiye...',
      timeText: '2h ago',
      unreadCount: 0,
      isOnline: false,
      gender: 'female',
      age: 23,
    ),
    _ConversationData(
      id: 'c6',
      userId: '22778899',
      name: 'AYESHA SHAHZ...',
      avatarUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200&q=80',
      lastMessage: 'hi kesy ho aap? subah live streaming kab hy?',
      timeText: '2h ago',
      unreadCount: 0,
      isOnline: true,
      gender: 'female',
      age: 21,
    ),
    _ConversationData(
      id: 'c7',
      userId: '22889900',
      name: 'Alishbha',
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=200&q=80',
      lastMessage: 'how are you? can you share room link',
      timeText: '3h ago',
      unreadCount: 0,
      isOnline: false,
      gender: 'female',
      age: 22,
    ),
    _ConversationData(
      id: 'c8',
      userId: '22990011',
      name: 'Hina',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      lastMessage: 'Mujhe apse dosti krni hai plz reply do',
      timeText: '3h ago',
      unreadCount: 0,
      isOnline: true,
      gender: 'female',
      age: 19,
    ),
  ];

  // Demo Friends list matching Image 4 reference
  final List<_FriendData> _demoFriends = [
    _FriendData(
      id: 'f1',
      name: 'Mr.Shehryar',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      gender: 'male',
      age: 24,
      isOnline: true,
      hasFlame: true,
      category: 'Friends',
    ),
    _FriendData(
      id: 'f2',
      name: 'Shanzay',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      gender: 'female',
      age: 21,
      isOnline: true,
      hasFlame: false,
      category: 'Friends',
    ),
    _FriendData(
      id: 'f3',
      name: 'Sonia Malik',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      gender: 'female',
      age: 22,
      isOnline: false,
      hasFlame: true,
      category: 'Following',
    ),
    _FriendData(
      id: 'f4',
      name: 'Neha Fatima',
      avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200&q=80',
      gender: 'female',
      age: 20,
      isOnline: true,
      hasFlame: false,
      category: 'Followers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07060E) : const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 1. Top Header: [Chats, Friends] + Actions (Search & Clear) ──
            _buildTopHeader(isDark),

            // ── Optional Search Bar ─────────────────────────────────────────
            if (_isSearching) _buildSearchBar(isDark),

            // ── 2. Main Tab Body (Chats vs Friends) ─────────────────────────
            Expanded(
              child: _selectedMainTab == 0
                  ? _buildChatsTab(isDark)
                  : _buildFriendsTab(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Top Header: Tabs [Chats, Friends] + Icons
  // ===========================================================================
  Widget _buildTopHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: isDark ? const Color(0xFF07060E) : Colors.white,
      child: Row(
        children: [
          // Chats Tab
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMainTab = 0;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Chats',
                      style: TextStyle(
                        fontSize: _selectedMainTab == 0 ? 20.sp : 16.sp,
                        fontWeight: _selectedMainTab == 0 ? FontWeight.w800 : FontWeight.w500,
                        color: _selectedMainTab == 0
                            ? (isDark ? Colors.white : AppColors.darkNavy)
                            : (isDark ? Colors.white38 : Colors.grey),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1493),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _selectedMainTab == 0 ? 24.w : 0,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    borderRadius: BorderRadius.circular(2.r),
                    boxShadow: _selectedMainTab == 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 22.w),

          // Friends Tab
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMainTab = 1;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: _selectedMainTab == 1 ? 20.sp : 16.sp,
                    fontWeight: _selectedMainTab == 1 ? FontWeight.w800 : FontWeight.w500,
                    color: _selectedMainTab == 1
                        ? (isDark ? Colors.white : AppColors.darkNavy)
                        : (isDark ? Colors.white38 : Colors.grey),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _selectedMainTab == 1 ? 24.w : 0,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676),
                    borderRadius: BorderRadius.circular(2.r),
                    boxShadow: _selectedMainTab == 1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Clean / Sweep Messages Icon Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read! 🧹'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF00E676),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9),
              ),
              child: Icon(
                Icons.mark_chat_read_outlined,
                size: 20.sp,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // Search Toggle Button
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
            child: Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSearching
                    ? const Color(0xFFFF1493)
                    : (isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9)),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 20.sp,
                color: _isSearching ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: isDark ? const Color(0xFF07060E) : Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: 'Search chats or friends...',
          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12.5.sp),
          prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey, size: 20.sp),
          filled: true,
          fillColor: isDark ? const Color(0xFF131522) : const Color(0xFFF1F5F9),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Chats Tab: "Recent Visitors" Card + Conversations
  // ===========================================================================
  Widget _buildChatsTab(bool isDark) {
    final filteredChats = _demoChats.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.lastMessage.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      children: [
        // ── Recent Visitors Banner (Matching Image 3) ────────────────────────
        _buildRecentVisitorsCard(isDark),

        SizedBox(height: 10.h),

        // ── Conversations List ──────────────────────────────────────────────
        ...filteredChats.map((chat) => _buildConversationTile(chat, isDark)),
      ],
    );
  }

  Widget _buildRecentVisitorsCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VisitorsScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121420) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Eye Icon on glowing circular background
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 24.sp),
              ),
            ),

            SizedBox(width: 12.w),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Visitors',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Mr.Shehryar just visited your homepage',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Time & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'just now',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.grey, size: 18.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(_ConversationData chat, bool isDark) {
    return GestureDetector(
      onTap: () {
        final peer = UserModel(
          id: chat.userId,
          name: chat.name,
          username: chat.name.toLowerCase().replaceAll(' ', '_'),
          email: '${chat.name.toLowerCase()}@hemiton.com',
          avatarUrl: chat.avatarUrl,
          dateOfBirth: DateTime(DateTime.now().year - chat.age, 1, 1),
          gender: chat.gender,
          region: 'Islamabad, Pakistan',
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(user: peer)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10121C) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Avatar with Green Online Dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFF00BFFF)],
                    ),
                  ),
                  padding: EdgeInsets.all(1.8.w),
                  child: ClipOval(
                    child: Image.network(
                      chat.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey,
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 13.w,
                      height: 13.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF10121C) : Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 12.w),

            // Name & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? const Color(0xFF8C9BAE) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Time & Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.timeText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 5.h),
                if (chat.unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1493),
                      borderRadius: BorderRadius.circular(10.r),
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
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Friends Tab (Image 4): Category Pills [Following, Friends, Followers]
  // ===========================================================================
  Widget _buildFriendsTab(bool isDark) {
    final categories = ['Following', 'Friends', 'Followers'];
    final currentCategory = categories[_selectedFriendsFilter];

    final filteredFriends = _demoFriends.where((f) {
      final matchesCat = f.category == currentCategory;
      if (_searchQuery.isEmpty) return matchesCat;
      return matchesCat && f.name.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Category Pills (Matching Image 4)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: List.generate(categories.length, (index) {
              final isSelected = _selectedFriendsFilter == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFriendsFilter = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? const Color(0xFF00E676).withValues(alpha: 0.2) : const Color(0xFFE8F5E9))
                        : (isDark ? const Color(0xFF141724) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF00E676)
                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Friends List
        Expanded(
          child: filteredFriends.isEmpty
              ? Center(
                  child: Text(
                    'No users in $currentCategory yet',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: filteredFriends.length,
                  separatorBuilder: (context, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return _buildFriendTile(friend, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFriendTile(_FriendData friend, bool isDark) {
    return GestureDetector(
      onTap: () {
        final authorUser = UserModel(
          id: friend.id,
          name: friend.name,
          username: friend.name.toLowerCase().replaceAll(' ', '_'),
          email: '${friend.name.toLowerCase()}@hemiton.com',
          avatarUrl: friend.avatarUrl,
          dateOfBirth: DateTime(DateTime.now().year - friend.age, 1, 1),
          gender: friend.gender,
          region: 'Islamabad, Pakistan',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileDetailsScreen(
              userId: friend.id,
              user: authorUser,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10121C) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(friend.avatarUrl),
                ),
                if (friend.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),

            // Name + Flame + Gender Badge
            Expanded(
              child: Row(
                children: [
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  if (friend.hasFlame) ...[
                    SizedBox(width: 4.w),
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                  ],
                  SizedBox(width: 8.w),

                  // Gender / Age Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: friend.gender == 'female'
                          ? const Color(0xFFFF4081)
                          : const Color(0xFF00B0FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          friend.gender == 'female' ? Icons.female_rounded : Icons.male_rounded,
                          size: 10.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${friend.age}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chat action icon
            IconButton(
              icon: Icon(Icons.chat_bubble_outline_rounded, color: const Color(0xFF00E676), size: 20.sp),
              onPressed: () {
                final peer = UserModel(
                  id: friend.id,
                  name: friend.name,
                  username: friend.name.toLowerCase().replaceAll(' ', '_'),
                  email: '${friend.name.toLowerCase()}@hemiton.com',
                  avatarUrl: friend.avatarUrl,
                  dateOfBirth: DateTime(DateTime.now().year - friend.age, 1, 1),
                  gender: friend.gender,
                  region: 'Islamabad, Pakistan',
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(user: peer)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationData {
  final String id;
  final String userId;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String timeText;
  final int unreadCount;
  final bool isOnline;
  final String gender;
  final int age;

  _ConversationData({
    required this.id,
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timeText,
    required this.unreadCount,
    required this.isOnline,
    required this.gender,
    required this.age,
  });
}

class _FriendData {
  final String id;
  final String name;
  final String avatarUrl;
  final String gender;
  final int age;
  final bool isOnline;
  final bool hasFlame;
  final String category;

  _FriendData({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.gender,
    required this.age,
    required this.isOnline,
    required this.hasFlame,
    required this.category,
  });
}
