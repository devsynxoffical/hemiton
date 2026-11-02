import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/repositories/backend_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/wallet_provider.dart';
import '../settings/settings_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../wallet/gold_coins_screen.dart';
import '../wallet/diamonds_wallet_screen.dart';
import '../store/store_screen.dart';
import '../svip/svip_center_screen.dart';
import 'level_center_screen.dart';
import '../live_host/live_host_center_screen.dart';
import '../../widgets/user_list_sheet.dart';
import '../social/create_post_screen.dart';
import '../social/upload_video_screen.dart';
import '../social/camera_recorder_screen.dart';
import '../live/create_live_room_screen.dart';
import '../party_room/create_party_screen.dart';
import '../party_room/group_video_party_room_screen.dart';
import '../../models/live_room_model.dart';
import 'widgets/tiktok_fullscreen_preview_screen.dart';

/// HEMI TON Profile ("Me") Screen
/// Layout & Features:
/// - Top Half (Compact Proportions):
///     • Customizable Cover Photo (tap to change via Camera/Gallery) + Settings (⚙️)
///     • Circular Avatar with green Online dot + tap to change profile picture
///     • Name + Verified Checkmark + ID with copy button
///     • Interactive Clickable Badges:
///         - SVIP 6 & SVIP 3 -> SVIPCenterScreen
///         - Level 50 & Beginner -> LevelCenterScreen
///         - TOP HOST -> LiveHostCenterScreen
///         - Agent / Seller / Employee / super-agent
///     • Location (📍 New Delhi, India) + green [Online] badge + Bio
///     • 4 Interactive Stats with Full User Previews:
///         - Friends (532) -> UserListSheet('Friends')
///         - Followers (128) -> UserListSheet('Followers')
///         - Following (98) -> UserListSheet('Following')
///         - Likes (1.2K) -> Likes summary
///     • Expandable Dropdown (Services & Features) with Hide/Unhide toggle:
///         - Store, SVIPs, Gold Coins, Diamonds, Friends, Edit Profile, Settings
/// - Lower Half (Scrollable Media):
///     • Photos & Videos tabs with full-height scrollable media grid
/// - Floating Action Button (+) to post photos, videos, or record
/// - Bottom Floating Action Bar REMOVED as requested.
class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _mediaTabController;
  bool _isDropdownOpen = false; // Default hidden/collapsed as requested
  String? _customCoverPath;

  @override
  void initState() {
    super.initState();
    _mediaTabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser.id.isNotEmpty) {
        context.read<WalletProvider>().syncWithUser(auth.currentUser);
      }
    });
  }

  @override
  void dispose() {
    _mediaTabController.dispose();
    super.dispose();
  }

  // ── Cover Photo Picker (Camera / Gallery) ──────────────────────────────────
  Future<void> _pickCoverPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161928),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Choose Cover from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked != null && mounted) {
                  setState(() => _customCoverPath = picked.path);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover photo updated! 🌄')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF1493)),
              title: const Text('Take New Cover Photo', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                if (picked != null && mounted) {
                  setState(() => _customCoverPath = picked.path);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover photo updated! 🌄')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar Photo Picker (Camera / Gallery) ─────────────────────────────────
  Future<void> _pickProfileAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161928),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00E5FF)),
              title: const Text('Choose Avatar from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked != null && mounted) {
                  await context.read<AuthProvider>().updateAvatar(picked.path);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated! 👤')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFFF1493)),
              title: const Text('Take New Avatar Photo', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                if (picked != null && mounted) {
                  await context.read<AuthProvider>().updateAvatar(picked.path);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated! 👤')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateLiveAndPostOptions(BuildContext context, bool isDark, bool isFemale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161129) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: const Color(0xFF8A2BE2).withValues(alpha: 0.3)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Center(
                  child: Text(
                    'Create Live & Moments ✨',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── LIVE CREATION OPTIONS (Permission Matrix Gated) ──
                Text(
                  'GO LIVE NOW',
                  style: TextStyle(
                    fontSize: 11.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
                SizedBox(height: 10.h),

                // Live types row: Daily Live (Female only), Audio Group Live (Both), Video Group Live (Both), Video Live (Both)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // 1. Daily Live: Strictly Female Only
                      if (isFemale) ...[
                        _buildLiveCreationCard(
                          ctx,
                          title: 'Daily Live',
                          subtitle: 'Solo Female Live',
                          badgeText: 'FEMALE',
                          icon: Icons.sensors_rounded,
                          gradient: const [Color(0xFFFF007F), Color(0xFFFF1493)],
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateLiveRoomScreen(
                                  initialAudioMode: false,
                                  isDailyLive: true,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10.w),
                      ],

                      // 2. Audio Group Live: Both Genders
                      _buildLiveCreationCard(
                        ctx,
                        title: 'Audio Group',
                        subtitle: 'Multi-Seat Party',
                        badgeText: 'AUDIO',
                        icon: Icons.record_voice_over_rounded,
                        gradient: const [Color(0xFF8A2BE2), Color(0xFF6C63FF)],
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePartyScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10.w),

                      // 3. Video Group Live: Both Genders
                      _buildLiveCreationCard(
                        ctx,
                        title: 'Video Group',
                        subtitle: '8-Seat Cam Grid',
                        badgeText: 'GROUP CAM',
                        icon: Icons.grid_view_rounded,
                        gradient: const [Color(0xFF00B0FF), Color(0xFF00E5FF)],
                        onTap: () {
                          Navigator.pop(ctx);
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          final newRoom = LiveRoomModel(
                            id: 'group_vid_${DateTime.now().millisecondsSinceEpoch}',
                            title: "${auth.currentUser.displayName.isNotEmpty ? auth.currentUser.displayName : 'Host'}'s Video Stage",
                            host: auth.currentUser,
                            coverUrl: auth.currentUser.avatarUrl,
                            roomType: 'GROUP_VIDEO',
                            status: 'LIVE',
                            category: 'Chat',
                            viewerCount: 1,
                            startTime: DateTime.now(),
                          );
                          BackendRepository.instance.addLiveRoom(newRoom);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupVideoPartyRoomScreen(room: newRoom, isHost: true),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10.w),

                      // 4. Video Live: Both Genders
                      _buildLiveCreationCard(
                        ctx,
                        title: 'Video Live',
                        subtitle: 'Solo Broadcast',
                        badgeText: 'VIDEO',
                        icon: Icons.videocam_rounded,
                        gradient: const [Color(0xFFFF007F), Color(0xFF7928CA)],
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateLiveRoomScreen(
                                initialAudioMode: false,
                                isDailyLive: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),
                Divider(color: Colors.white12, height: 1),
                SizedBox(height: 14.h),

                // ── POST & MOMENTS OPTIONS ──
                Text(
                  'SHARE MOMENTS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCreatePostItem(
                      ctx,
                      icon: Icons.photo_library_rounded,
                      label: 'Photo Post',
                      gradient: const [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                      },
                    ),
                    _buildCreatePostItem(
                      ctx,
                      icon: Icons.videocam_rounded,
                      label: 'Record Video',
                      gradient: const [Color(0xFF00E5FF), Color(0xFF0072FF)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraRecorderScreen()));
                      },
                    ),
                    _buildCreatePostItem(
                      ctx,
                      icon: Icons.upload_file_rounded,
                      label: 'Upload Video',
                      gradient: const [Color(0xFF00E676), Color(0xFF00B0FF)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadVideoScreen()));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveCreationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 106.w,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A34),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: gradient.first.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = widget.user ?? authProvider.currentUser;

    final String displayName = user.name.isNotEmpty ? user.name : 'Raj';
    final String displayId = user.id.isNotEmpty
        ? (user.id.replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty
            ? user.id.replaceAll(RegExp(r'[^0-9]'), '')
            : '20574255')
        : '20574255';
    final int age = user.age > 0 ? user.age : 26;
    final bool isFemale = user.gender.toLowerCase() == 'female';
    final String avatarUrl = user.avatarUrl.isNotEmpty
        ? user.avatarUrl
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80';
    final String location = user.region.isNotEmpty ? user.region : 'New Delhi, India';
    final String bio = user.bio.isNotEmpty ? user.bio : 'Love to live, live to love. ❤️';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 74.h),
        child: FloatingActionButton(
          onPressed: () => _showCreateLiveAndPostOptions(context, isDark, isFemale),
          backgroundColor: Colors.transparent,
          elevation: 6,
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top Cover Banner (Compact Height ~120.h) ──────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120.h,
                  width: double.infinity,
                  color: const Color(0xFF1E2235),
                  child: _customCoverPath != null
                      ? Image.file(File(_customCoverPath!), fit: BoxFit.cover)
                      : Image.network(
                          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE65100), Color(0xFF880E4F), Color(0xFF1A237E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                ),

                // Ambient gradient overlay on cover
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        isDark ? const Color(0xFF0F111A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Top Right Action Icons (Cover Photo Picker & Settings)
                Positioned(
                  top: 28.h,
                  right: 14.w,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickCoverPhoto,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text('Cover', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.all(7.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings_outlined, color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular Avatar overlapping cover with Green Online Dot
                Positioned(
                  left: 18.w,
                  bottom: -28.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: _pickProfileAvatar,
                        child: Container(
                          width: 68.w,
                          height: 68.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF0F111A) : Colors.white,
                              width: 2.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF232738),
                                child: const Icon(Icons.person, color: Colors.white54, size: 36),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Green Online Dot Indicator
                      Positioned(
                        right: 2.w,
                        bottom: 3.h,
                        child: Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF0F111A) : Colors.white,
                              width: 2.0,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF00E676), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // ── 2. Upper Half Content (Identity, Badges, Stats, Actions) ─────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Blue Verified Badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(Icons.verified_rounded, color: const Color(0xFF1877F2), size: 18.sp),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // ID + Copy Icon + Edit Profile Icon
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'ID: $displayId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: displayId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ID $displayId copied to clipboard! 📋'),
                              backgroundColor: const Color(0xFF9C27B0),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Icon(Icons.copy_rounded, size: 13.sp, color: Colors.grey.shade400),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        child: Icon(Icons.edit_note_rounded, size: 16.sp, color: const Color(0xFFFF1493)),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // ── Clickable Badges (SVIP, Level, Host Center, etc.) ─────────
                  // Row 1: BEGINNER
                  _buildClickablePillBadge(
                    label: 'BEGINNER',
                    icon: Icons.brightness_1_rounded,
                    bgGradient: const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                    textColor: Colors.white,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelCenterScreen(initialTab: 0))),
                  ),

                  SizedBox(height: 5.h),

                  // Row 2: Gender/Age + Wealth Level + SVIP 6 + TOP HOST
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 5.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildClickablePillBadge(
                        label: '$age',
                        icon: isFemale ? Icons.female_rounded : Icons.male_rounded,
                        bgGradient: isFemale
                            ? const [Color(0xFFFF4081), Color(0xFFF50057)]
                            : const [Color(0xFF29B6F6), Color(0xFF0288D1)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      ),
                      _buildClickablePillBadge(
                        label: '50',
                        icon: Icons.local_fire_department_rounded,
                        bgGradient: const [Color(0xFF880E4F), Color(0xFFC2185B)],
                        textColor: const Color(0xFFFFD700),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelCenterScreen(initialTab: 1))),
                      ),
                      _buildClickablePillBadge(
                        label: 'SVIP 6',
                        icon: Icons.diamond_rounded,
                        bgGradient: const [Color(0xFF00838F), Color(0xFF00ACC1)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SVIPCenterScreen())),
                      ),
                      _buildClickablePillBadge(
                        label: 'TOP HOST',
                        icon: Icons.mic_rounded,
                        bgGradient: const [Color(0xFF1565C0), Color(0xFF1E88E5)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveHostCenterScreen())),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  // Row 3: Role & Agency Badges
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 5.h,
                    children: [
                      _buildClickablePillBadge(
                        label: 'MASTER',
                        icon: Icons.shield_rounded,
                        bgGradient: const [Color(0xFFBA68C8), Color(0xFFAB47BC)],
                        textColor: Colors.white,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Master Tier Streamer Rank 🏆'))),
                      ),
                      _buildClickablePillBadge(
                        label: 'Agent',
                        icon: Icons.person_rounded,
                        bgGradient: const [Color(0xFF81C784), Color(0xFF4CAF50)],
                        textColor: Colors.white,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verified Talent Agent 🤝'))),
                      ),
                      _buildClickablePillBadge(
                        label: 'Seller',
                        icon: Icons.storefront_rounded,
                        bgGradient: const [Color(0xFFFFB74D), Color(0xFFFFA726)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
                      ),
                      _buildClickablePillBadge(
                        label: 'Employee',
                        icon: Icons.badge_rounded,
                        bgGradient: const [Color(0xFFF48FB1), Color(0xFFEC407A)],
                        textColor: Colors.white,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Platform Certified Staff'))),
                      ),
                      _buildClickablePillBadge(
                        label: 'super-agent',
                        icon: Icons.star_rounded,
                        bgGradient: const [Color(0xFFE57373), Color(0xFFEF5350)],
                        textColor: Colors.white,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Super Agent Guild Manager 👑'))),
                      ),
                      _buildClickablePillBadge(
                        label: 'SVIP 3',
                        icon: Icons.workspace_premium_rounded,
                        bgGradient: const [Color(0xFF4DB6AC), Color(0xFF00897B)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SVIPCenterScreen())),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Location + Online Badge
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14.sp, color: Colors.grey.shade400),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFF00E676), width: 0.8),
                        ),
                        child: Text(
                          'Online',
                          style: TextStyle(color: const Color(0xFF00E676), fontSize: 9.5.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Tagline / Bio
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── 4 Clickable Stats: Visitors, Followers, Following, Likes ─
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161928) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildClickableStatItem(
                          '532',
                          'Visitors',
                          Icons.visibility_rounded,
                          const Color(0xFF8E24AA),
                          () => UserListSheet.show(context, 'Visitors', userId: user.id),
                        ),
                        _buildClickableStatItem(
                          '128',
                          'Followers',
                          Icons.favorite_rounded,
                          const Color(0xFFFF4081),
                          () => UserListSheet.show(context, 'Followers', userId: user.id),
                        ),
                        _buildClickableStatItem(
                          '98',
                          'Following',
                          Icons.person_add_alt_1_rounded,
                          const Color(0xFFFF9800),
                          () => UserListSheet.show(context, 'Following', userId: user.id),
                        ),
                        _buildClickableStatItem(
                          '1.2K',
                          'Likes',
                          Icons.favorite_border_rounded,
                          const Color(0xFFF44336),
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('You have received 1,200 likes across posts & moments! ❤️'),
                                backgroundColor: const Color(0xFFFF1493),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ── Expandable Dropdown Menu (Hide / Unhide) ────────────────
                  _buildExpandableServicesDropdown(context, isDark),

                  SizedBox(height: 16.h),

                  // ── Lower Half: TikTok-Style Media Tabs (Videos, Photos, Favorites, Liked) ─
                  Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161928) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _mediaTabController,
                      indicatorColor: const Color(0xFFFF007F),
                      indicatorWeight: 2.8,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
                      labelColor: const Color(0xFFFF007F),
                      unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF64748B),
                      tabs: const [
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.grid_on_rounded, size: 14),
                                SizedBox(width: 3),
                                Text('Videos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library_outlined, size: 14),
                                SizedBox(width: 3),
                                Text('Photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_outline_rounded, size: 14),
                                SizedBox(width: 3),
                                Text('Favorite', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_border_rounded, size: 14),
                                SizedBox(width: 3),
                                Text('Liked', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // TikTok-Style Media Grid View inside Lower Half
                  SizedBox(
                    height: 520.h,
                    child: TabBarView(
                      controller: _mediaTabController,
                      children: [
                        _buildVideosGrid(isDark, displayName, avatarUrl),
                        _buildPhotosGrid(isDark, displayName, avatarUrl),
                        _buildFavoritesGrid(isDark, displayName, avatarUrl),
                        _buildLikedGrid(isDark, displayName, avatarUrl),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Expandable Dropdown (Services & Features)
  // Store, SVIPs, Gold Coins, Diamonds, Friends, Edit Profile, Settings
  // ===========================================================================
  Widget _buildExpandableServicesDropdown(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161928) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Dropdown Trigger Header
          InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.apps_rounded, color: const Color(0xFFFF1493), size: 18.sp),
                      SizedBox(width: 7.w),
                      Text(
                        'Services & Tools',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isDropdownOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Items
          if (_isDropdownOpen) ...[
            Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDropdownItem(
                        icon: Icons.storefront_rounded,
                        label: 'Store',
                        color: const Color(0xFF9C27B0),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
                      ),
                      _buildDropdownItem(
                        icon: Icons.diamond_rounded,
                        label: 'SVIPs',
                        color: const Color(0xFFFFD700),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SVIPCenterScreen())),
                      ),
                      _buildDropdownItem(
                        icon: Icons.monetization_on_rounded,
                        label: 'Coins',
                        color: const Color(0xFFFFB300),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoldCoinsScreen())),
                      ),
                      _buildDropdownItem(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Diamonds',
                        color: const Color(0xFF00E5FF),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiamondsWalletScreen())),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDropdownItem(
                        icon: Icons.visibility_outlined,
                        label: 'Visitors',
                        color: const Color(0xFF00E676),
                        onTap: () => UserListSheet.show(context, 'Visitors'),
                      ),
                      _buildDropdownItem(
                        icon: Icons.edit_note_rounded,
                        label: 'Edit Profile',
                        color: const Color(0xFFFF1493),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      ),
                      _buildDropdownItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        color: const Color(0xFF78909C),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                      _buildDropdownItem(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        color: const Color(0xFF29B6F6),
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: 'https://zeparty.app/me'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile link copied! 🔗')));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.1),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TikTok-Style Media Section (Videos, Photos, Favorites, Liked)
  // ===========================================================================
  void _openFullScreenMedia({
    required BuildContext context,
    required List<TikTokMediaItem> playlist,
    required int initialIndex,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TikTokFullScreenPreviewScreen(
          item: playlist[initialIndex],
          playlist: playlist,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildVideosGrid(bool isDark, String displayName, String avatarUrl) {
    final List<Map<String, dynamic>> videos = [
      {
        'thumb': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&q=80',
        'views': '124.5K',
        'isPinned': true,
        'likes': '8.4K',
        'duration': '00:15',
        'title': 'Saturday Night Vibe in HemiTon 🔥',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
        'views': '45.2K',
        'isPinned': true,
        'likes': '3.1K',
        'duration': '00:28',
        'title': 'Sunset at the beach with friends 🌅',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=500&q=80',
        'views': '89.1K',
        'isPinned': false,
        'likes': '6.9K',
        'duration': '01:02',
        'title': 'Motorcycle ride across the city 🏍️',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
        'views': '12.8K',
        'isPinned': false,
        'likes': '1.2K',
        'duration': '00:45',
        'title': 'Late night neon room chill 🎧',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80',
        'views': '210.4K',
        'isPinned': false,
        'likes': '19.8K',
        'duration': '00:22',
        'title': 'Concert stage light show 💥',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80',
        'views': '34.6K',
        'isPinned': false,
        'likes': '2.9K',
        'duration': '00:30',
        'title': 'Acoustic guitar live acoustic jam 🎸',
      },
    ];

    final playlist = videos.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return TikTokMediaItem(
        id: 'video_$idx',
        mediaUrl: item['thumb'] as String,
        title: item['title'] as String,
        creatorName: displayName,
        creatorAvatar: avatarUrl,
        views: item['views'] as String,
        initialLikes: item['likes'] as String,
        isVideo: true,
      );
    }).toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final v = videos[index];
        return GestureDetector(
          onTap: () => _openFullScreenMedia(
            context: context,
            playlist: playlist,
            initialIndex: index,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                v['thumb'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              if (v['isPinned'] == true)
                Positioned(
                  top: 5.h,
                  left: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF007F),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Text(
                      'Pinned',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Text(
                    v['duration'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5.h,
                left: 6.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(
                      v['views'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotosGrid(bool isDark, String displayName, String avatarUrl) {
    final List<Map<String, dynamic>> photos = [
      {
        'thumb': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
        'likes': '4.2K',
        'multi': 3,
        'title': 'New studio photoshoot session ✨',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=80',
        'likes': '1.8K',
        'multi': 1,
        'title': 'Weekend coffee & coding ☕',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80',
        'likes': '950',
        'multi': 4,
        'title': 'Mountains trip memories 🏔️',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80',
        'likes': '7.1K',
        'multi': 2,
        'title': 'Concert night vibes 🎶',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&q=80',
        'likes': '3.3K',
        'multi': 1,
        'title': 'Street fashion in neon lights 🌆',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
        'likes': '12.4K',
        'multi': 5,
        'title': 'Summer memories album 🌴',
      },
    ];

    final playlist = photos.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      final multi = item['multi'] as int? ?? 1;
      return TikTokMediaItem(
        id: 'photo_$idx',
        mediaUrl: item['thumb'] as String,
        photoUrls: List.generate(multi, (_) => item['thumb'] as String),
        title: item['title'] as String,
        creatorName: displayName,
        creatorAvatar: avatarUrl,
        views: '35.4K',
        initialLikes: item['likes'] as String,
        isVideo: false,
      );
    }).toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final p = photos[index];
        final multi = p['multi'] as int? ?? 1;
        return GestureDetector(
          onTap: () => _openFullScreenMedia(
            context: context,
            playlist: playlist,
            initialIndex: index,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                p['thumb'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              if (multi > 1)
                Positioned(
                  top: 5.h,
                  right: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers_rounded, color: Colors.white, size: 10.sp),
                        SizedBox(width: 2.w),
                        Text(
                          '$multi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 5.h,
                left: 6.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: const Color(0xFFFF007F), size: 12.sp),
                    SizedBox(width: 3.w),
                    Text(
                      p['likes'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesGrid(bool isDark, String displayName, String avatarUrl) {
    final List<Map<String, dynamic>> favorites = [
      {
        'thumb': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80',
        'views': '58.2K',
        'likes': '7.4K',
        'title': 'Night Vibes & Chill Beats ✨',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&q=80',
        'views': '19.4K',
        'likes': '2.1K',
        'title': 'Gaming Room Setup Tour 🎮',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
        'views': '73.1K',
        'likes': '9.8K',
        'title': 'Tropical Sunset Live Mix 🌅',
      },
    ];

    final playlist = favorites.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return TikTokMediaItem(
        id: 'fav_$idx',
        mediaUrl: item['thumb'] as String,
        title: item['title'] as String,
        creatorName: displayName,
        creatorAvatar: avatarUrl,
        views: item['views'] as String,
        initialLikes: item['likes'] as String,
        isVideo: true,
      );
    }).toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: favorites.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return GestureDetector(
          onTap: () => _openFullScreenMedia(
            context: context,
            playlist: playlist,
            initialIndex: index,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                fav['thumb'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: const Color(0xFFFFD700),
                    size: 13.sp,
                  ),
                ),
              ),
              Positioned(
                bottom: 5.h,
                left: 6.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(
                      fav['views'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLikedGrid(bool isDark, String displayName, String avatarUrl) {
    final List<Map<String, dynamic>> liked = [
      {
        'thumb': 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80',
        'views': '88.3K',
        'likes': '14.2K',
        'title': 'Best live festival crowd ever! 🎉',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500&q=80',
        'views': '41.6K',
        'likes': '5.8K',
        'title': 'Cozy coffee shop acoustics ☕',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=500&q=80',
        'views': '104.9K',
        'likes': '22.1K',
        'title': 'Golden hour motorcycle run 🚀',
      },
      {
        'thumb': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
        'views': '31.0K',
        'likes': '3.9K',
        'title': 'Studio portrait series 📸',
      },
    ];

    final playlist = liked.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      return TikTokMediaItem(
        id: 'liked_$idx',
        mediaUrl: item['thumb'] as String,
        title: item['title'] as String,
        creatorName: displayName,
        creatorAvatar: avatarUrl,
        views: item['views'] as String,
        initialLikes: item['likes'] as String,
        isVideo: true,
      );
    }).toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: liked.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.h,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = liked[index];
        return GestureDetector(
          onTap: () => _openFullScreenMedia(
            context: context,
            playlist: playlist,
            initialIndex: index,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item['thumb'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5.h,
                left: 6.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded, color: const Color(0xFFFF1744), size: 12.sp),
                    SizedBox(width: 3.w),
                    Text(
                      item['likes'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================
  Widget _buildClickablePillBadge({
    required String label,
    required IconData icon,
    required List<Color> bgGradient,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bgGradient),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: bgGradient.first.withValues(alpha: 0.3), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10.5.sp, color: textColor),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 9.5.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableStatItem(String count, String label, IconData icon, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 17.sp),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                count,
                style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 1.5.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
