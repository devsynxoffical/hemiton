import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../settings/settings_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../wallet/diamonds_wallet_screen.dart';
import '../store/store_screen.dart';
import 'visitors_screen.dart';
import '../../widgets/user_list_sheet.dart';
import 'modules/invite_code_screen.dart';
import '../social/create_post_screen.dart';
import '../social/upload_video_screen.dart';
import '../social/camera_recorder_screen.dart';

/// HEMI TON Profile ("Me") Screen
/// Features:
/// - User Uploadable Cover Image (Sea image removed; customizable via camera button)
/// - Crystal-Clear High-Contrast Username & ID on frosted glass with strong text shadow
/// - 3 Stat Capsules ("Following", "Followers", "Visits") with Neon Glowing Borders
/// - Golden Metallic SVIP Card ("Exclusive for top clients.") + "GO" Golden Pill
/// - "Gold coins" Capsule with "Bonus" Red Pill & Balance
/// - 2x2 Feature Grid: [Store, Diamonds, Personal Details, Share Invitation]
/// - User's Uploaded Posts Grid below 2x2 grid (Instagram / TikTok aesthetic)
/// - Floating Action Button (+) to post photos, videos, or record
/// - Supports Pure Dark Mode & Light Mode
class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser.id.isNotEmpty) {
        context.read<WalletProvider>().syncWithUser(auth.currentUser);
      }
    });
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        await context.read<AuthProvider>().updateAvatar(pickedFile.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Profile picture updated successfully!'),
              backgroundColor: Color(0xFF00E676),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update picture: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAvatarPickerOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF13151D) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFFFF1493)),
                  title: Text('Take Photo', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickProfileImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00E5FF)),
                  title: Text('Choose from Gallery', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickProfileImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePostOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161928) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
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
                SizedBox(height: 14.h),
                Text(
                  'Create New Post / Moment ✨',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                SizedBox(height: 18.h),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                        );
                      },
                    ),
                    _buildCreatePostItem(
                      ctx,
                      icon: Icons.videocam_rounded,
                      label: 'Record Video',
                      gradient: const [Color(0xFF00E5FF), Color(0xFF0072FF)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraRecorderScreen()),
                        );
                      },
                    ),
                    _buildCreatePostItem(
                      ctx,
                      icon: Icons.upload_file_rounded,
                      label: 'Upload Video',
                      gradient: const [Color(0xFF00E676), Color(0xFF00B0FF)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UploadVideoScreen()),
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
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = widget.user ?? authProvider.currentUser;

    final String displayName = user.name.isNotEmpty ? user.name : 'danial';
    final String displayId = user.id.isNotEmpty
        ? (user.id.replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty
            ? user.id.replaceAll(RegExp(r'[^0-9]'), '')
            : '22773864')
        : '22773864';
    final int age = user.age > 0 ? user.age : 21;
    final String avatarUrl = user.avatarUrl.isNotEmpty
        ? user.avatarUrl
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07060E) : const Color(0xFFF6F8FB),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostOptions(context, isDark),
        backgroundColor: Colors.transparent,
        elevation: 6,
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF1493), Color(0xFF8A2BE2), Color(0xFF00BFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Settings Icon (Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: const Color(0xFF00E5FF),
                        size: 20.w,
                      ),
                    ),
                  ),
                ],
              ),

                  SizedBox(height: 12.h),

                  // ── User Header: Avatar, Name, Gender, ID & Copy Button ─────
                  _buildUserHeader(context, isDark, user, displayName, displayId, age, avatarUrl),

                  SizedBox(height: 20.h),

                  // ── 3 Stat Capsules: Following, Followers, Visits ──────────
                  _buildStatCapsules(context, isDark, user),

                  SizedBox(height: 16.h),

                  // ── SVIP Metallic Golden Banner ────────────────────────────
                  _buildSvipBanner(context),

                  SizedBox(height: 14.h),

                  // ── Gold Coins Capsule Row (with Bonus Badge) ───────────────
                  _buildGoldCoinsRow(context, isDark, user),

                  SizedBox(height: 14.h),

                  // ── 2x2 Feature Grid (Store, Diamonds, Personal Details, Share) ─
                  _buildTwoByTwoFeatureGrid(context, isDark, user),

                  SizedBox(height: 22.h),

                  // ── User's Uploaded Posts Grid (Instagram / TikTok aesthetic) ─
                  _buildUserPostsSection(context, isDark),

                  SizedBox(height: 70.h),
                ],
              ),
            ),
          ),
        );
  }

  // ===========================================================================
  // User Header (High-contrast, crystal-clear text visibility for Name & ID)
  // ===========================================================================
  Widget _buildUserHeader(
    BuildContext context,
    bool isDark,
    UserModel user,
    String displayName,
    String displayId,
    int age,
    String avatarUrl,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Double Neon Ring (Magenta & Cyan) + Camera Badge
          GestureDetector(
            onTap: () => _showAvatarPickerOptions(context, isDark),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76.w,
                  height: 76.w,
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF1E2235),
                          child: Icon(Icons.person, color: Colors.white70, size: 38.w),
                        ),
                      ),
                    ),
                  ),
                ),

                // Camera Badge on bottom right
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E30),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: const Color(0xFF00E5FF),
                        size: 13.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          // User Info Details with strong shadows & contrast for 100% visibility
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username (Bold, pure bright white with shadow for extreme visibility)
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        offset: const Offset(0, 1.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // Gender, Age & Height ("♂ 21 • 173cm >")
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Icon(
                        Icons.male_rounded,
                        color: const Color(0xFF00E5FF),
                        size: 16.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '$age • 173cm',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white60 : Colors.grey,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),

                // ID Row + Cyan/Purple Glowing "Copy" Pill Button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'ID: $displayId',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: displayId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID $displayId copied to clipboard! 📋'),
                            backgroundColor: const Color(0xFF00E5FF),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131526).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00E5FF),
                          ),
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
    );
  }

  // ===========================================================================
  // 3 Stat Capsules: Following, Followers, Visits
  // ===========================================================================
  Widget _buildStatCapsules(BuildContext context, bool isDark, UserModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F101A) : Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: const Color(0xFFFF1493).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1493).withValues(alpha: 0.25),
            blurRadius: 14,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // 0 Following
          Expanded(
            child: _buildSingleStatPill(
              context,
              count: 0,
              label: 'Following',
              isDark: isDark,
              onTap: () {
                UserListSheet.show(context, 'Following');
              },
            ),
          ),
          _buildStatDivider(isDark),

          // 0 Followers
          Expanded(
            child: _buildSingleStatPill(
              context,
              count: 0,
              label: 'Followers',
              isDark: isDark,
              onTap: () {
                UserListSheet.show(context, 'Followers');
              },
            ),
          ),
          _buildStatDivider(isDark),

          // 3 Visits
          Expanded(
            child: _buildSingleStatPill(
              context,
              count: 3,
              label: 'Visits',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VisitorsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStatPill(
    BuildContext context, {
    required int count,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFFF4081),
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1.w,
      height: 32.h,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }

  // ===========================================================================
  // SVIP Metallic Golden Banner
  // ===========================================================================
  Widget _buildSvipBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SVIP Privileges Center Coming Soon!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFE082),
              Color(0xFFFFC107),
              Color(0xFFFFA000),
              Color(0xFFFF8F00),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB300).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SVIP',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF4E342E),
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Exclusive for top clients.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4E342E),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Golden GO Pill Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white70, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8D6E63).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'GO',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF5D4037),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Gold Coins Capsule Row (with Bonus Badge)
  // ===========================================================================
  Widget _buildGoldCoinsRow(BuildContext context, bool isDark, UserModel user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
        );
      },
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F101A) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF1493).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gold Coin Icon
            Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFFEE58), Color(0xFFF57F17)],
                ),
              ),
              child: Center(
                child: Icon(Icons.star_rounded, color: Colors.white, size: 18.sp),
              ),
            ),
            SizedBox(width: 10.w),

            // "Gold coins" text
            Text(
              'Gold coins',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            SizedBox(width: 8.w),

            // "Bonus" Red Pill Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1744), Color(0xFFD50000)],
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1744).withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                'Bonus',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const Spacer(),

            // Coin Balance
            Text(
              '🪙 ${user.coins}',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white54 : Colors.grey,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2x2 Feature Grid (Store, Diamonds, Personal Details, Share Invitation)
  // ===========================================================================
  Widget _buildTwoByTwoFeatureGrid(BuildContext context, bool isDark, UserModel user) {
    return Column(
      children: [
        // Row 1: Store & Diamonds
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                isDark: isDark,
                iconWidget: Text('🛍️', style: TextStyle(fontSize: 26.sp)),
                title: 'Store',
                trailingWidget: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.grey,
                  size: 18.sp,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoreScreen()),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildFeatureCard(
                context,
                isDark: isDark,
                iconWidget: Text('💎', style: TextStyle(fontSize: 26.sp)),
                title: 'Diamonds',
                trailingWidget: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.grey,
                  size: 18.sp,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiamondsWalletScreen()),
                  );
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Row 2: Personal Details & Share Invitation
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                isDark: isDark,
                iconWidget: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.article_rounded,
                      color: const Color(0xFF00E676),
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'Personal\nDetails',
                trailingWidget: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202330) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildFeatureCard(
                context,
                isDark: isDark,
                iconWidget: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: const Color(0xFFBA68C8),
                      size: 22.sp,
                    ),
                  ),
                ),
                title: 'Share\nInvitation',
                trailingWidget: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.grey,
                  size: 18.sp,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InviteCodeScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required bool isDark,
    required Widget iconWidget,
    required String title,
    required Widget trailingWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F101A) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF1493).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconWidget,
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: trailingWidget,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // User Uploaded Posts Section (Instagram / TikTok Grid Aesthetic)
  // ===========================================================================
  Widget _buildUserPostsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view_rounded, color: const Color(0xFFFF1493), size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  'My Moments & Posts',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showCreatePostOptions(context, isDark),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 14.sp),
                    SizedBox(width: 3.w),
                    Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // 3-Column Posts Thumbnail Grid
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildPostThumbnailItem(
              'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
              views: '1.4K',
              isVideo: false,
            ),
            _buildPostThumbnailItem(
              'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&q=80',
              views: '2.8K',
              isVideo: true,
            ),
            _buildPostThumbnailItem(
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
              views: '980',
              isVideo: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostThumbnailItem(String imageUrl, {required String views, required bool isVideo}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E2235)),
          ),
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ),
            ),
          Positioned(
            bottom: 5,
            left: 6,
            child: Row(
              children: [
                Icon(isVideo ? Icons.play_arrow : Icons.favorite, color: Colors.white, size: 12.sp),
                const SizedBox(width: 3),
                Text(
                  views,
                  style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
