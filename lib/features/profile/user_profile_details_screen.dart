import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../messages/chat_screen.dart';
import '../settings/edit_profile_screen.dart';

/// User Profile Details Screen matching Image 5:
/// - Top App Bar with Back Button (←) and Options Menu (•••)
/// - Top Cover Image with Blur / Dark Vignette
/// - Large Avatar overlapping cover with clean circular border
/// - Username (e.g. "Mr.Shehryar"), Following pill badge, Gender/Age badge ("♂ 24")
/// - Location info: IP ("Islamabad, Pakistan"), Hometown ("Islamabad"), ID ("22219520")
/// - Tab: Profile | Honor
/// - Personal details: Height (175cm), Weight (55-60KG), Profession (Developer)
/// - Personality and traits: Romantic, Patient, Adventurous, Ambitious
/// - User's Uploaded Moments / Posts Grid below
/// - Sticky Bottom Bar: Glowing Green "💬 Chat" Button to message immediately
class UserProfileDetailsScreen extends StatefulWidget {
  final String userId;
  final UserModel? user;

  UserProfileDetailsScreen({super.key, String? userId, this.user})
      : userId = userId ?? user?.id ?? '';

  @override
  State<UserProfileDetailsScreen> createState() => _UserProfileDetailsScreenState();
}

class _UserProfileDetailsScreenState extends State<UserProfileDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserModel _user;
  bool _isFollowing = true;
  UserPersonalDetails? _details;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Populate user details from passed user or realistic defaults matching Image 5
    if (widget.user != null) {
      _user = widget.user!;
    } else {
      _user = UserModel(
        id: widget.userId.isNotEmpty ? widget.userId : '22219520',
        name: 'Mr.Shehryar',
        username: 'shehryar',
        email: 'shehryar@hemiton.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
        dateOfBirth: DateTime(2000, 1, 1),
        gender: 'male',
        bio: 'Developer & Streamer',
        region: 'Islamabad, Pakistan',
      );
    }

    PersonalDetailsService.instance.getDetails(_user).then((d) {
      if (mounted) setState(() => _details = d);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser.id;
    final bool isMe = (currentUserId.isNotEmpty && (_user.id == currentUserId || widget.userId == currentUserId)) ||
        (widget.userId.isEmpty && widget.user == null);
    final UserModel targetUser = isMe && auth.currentUser.id.isNotEmpty ? auth.currentUser : _user;

    final String displayName = targetUser.name.isNotEmpty ? targetUser.name : 'Mr.Shehryar';
    final String displayId = targetUser.id.isNotEmpty
        ? (targetUser.id.replaceAll(RegExp(r'[^0-9]'), '').isNotEmpty
            ? targetUser.id.replaceAll(RegExp(r'[^0-9]'), '')
            : '22219520')
        : '22219520';
    final int age = targetUser.age > 0 ? targetUser.age : 24;
    final bool isFemale = targetUser.gender.toLowerCase() == 'female' ||
        displayName.toLowerCase().contains('anam') ||
        displayName.toLowerCase().contains('shanzay') ||
        displayName.toLowerCase().contains('sonia') ||
        displayName.toLowerCase().contains('neha') ||
        displayName.toLowerCase().contains('queen') ||
        displayName.toLowerCase().contains('ayesha') ||
        displayName.toLowerCase().contains('alishbha') ||
        displayName.toLowerCase().contains('hina');
    final String avatarUrl = targetUser.avatarUrl.isNotEmpty
        ? targetUser.avatarUrl
        : (isFemale
            ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80'
            : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80');
    final String location = _details?.location ?? (targetUser.region.isNotEmpty ? targetUser.region : 'Islamabad, Pakistan');
    final String hometown = _details?.hometown ?? (targetUser.region.isNotEmpty ? targetUser.region.split(',').first.trim() : 'Islamabad');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      body: Stack(
        children: [
          // ── Scrollable Body Content ────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 90.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Cover Header (Image with subtle blur) ─────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2235) : const Color(0xFFCFD8DC),
                      ),
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? const Color(0xFF161928) : const Color(0xFFB0BEC5),
                        ),
                      ),
                    ),

                    // Ambient overlay on cover
                    Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.black.withValues(alpha: 0.15),
                            isDark
                                ? const Color(0xFF0F111A).withValues(alpha: 0.95)
                                : Colors.white.withValues(alpha: 0.95),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),

                    // Top Bar Actions (Back Button & 3-Dots Menu)
                    Positioned(
                      top: 40.h,
                      left: 14.w,
                      right: 14.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showProfileOptions(context, isDark, isMe),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Circular Avatar overlapping the cover bottom (matching Image 5)
                    Positioned(
                      left: 18.w,
                      bottom: -46.h,
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F111A) : Colors.white,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? const Color(0xFF232738) : const Color(0xFFCFD8DC),
                              child: const Icon(Icons.person, color: Colors.white54, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 52.h),

                // ── 2. User Info Section (Name, Following pill, Gender, Location) ─
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Following Badge
                      Row(
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: 10.w),

                          if (isMe)
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                );
                                final updated = await PersonalDetailsService.instance.getDetails(auth.currentUser);
                                if (mounted) setState(() => _details = updated);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2435) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 11.sp, color: const Color(0xFFFF1493)),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFF1493),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Following Pill Badge
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFollowing = !_isFollowing;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_isFollowing ? 'Followed $displayName! ❤️' : 'Unfollowed'),
                                    backgroundColor: AppColors.pink,
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: _isFollowing
                                      ? (isDark ? const Color(0xFF1E2435) : const Color(0xFFF1F5F9))
                                      : AppColors.pink,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: _isFollowing
                                        ? (isDark ? Colors.white24 : const Color(0xFFCBD5E1))
                                        : Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  _isFollowing ? 'Following' : '+ Follow',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _isFollowing
                                        ? (isDark ? Colors.white70 : const Color(0xFF64748B))
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 6.h),

                      // Gender / Age Badge (Dynamic Male ♂ or Female ♀)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isFemale ? const Color(0xFFFF4081) : const Color(0xFF29B6F6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isFemale ? Icons.female_rounded : Icons.male_rounded, size: 12.sp, color: Colors.white),
                            SizedBox(width: 2.w),
                            Text(
                              '$age',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // IP, Hometown, ID rows
                      _buildInfoRow(Icons.location_on_outlined, 'IP: $location', isDark),
                      SizedBox(height: 5.h),
                      _buildInfoRow(Icons.home_outlined, 'Hometown: $hometown', isDark),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 14.sp, color: isDark ? Colors.white38 : Colors.grey),
                          SizedBox(width: 6.w),
                          Text(
                            'ID: $displayId',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? const Color(0xFF8B9BB4) : const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: displayId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ID $displayId copied! 📋'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Icon(Icons.copy_rounded, size: 13.sp, color: const Color(0xFF00E5FF)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18.h),
                Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF1F5F9)),

                // ── 3. Tabs: Profile | Honor (matching Image 5) ──────────────
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: 22.w,
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF1493),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        'Honor',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 4. Personal Details Section ─────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal details',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          _buildDetailItem(Icons.height_rounded, _details?.height ?? (isFemale ? '165cm' : '175cm'), isDark),
                          SizedBox(width: 35.w),
                          _buildDetailItem(Icons.speed_rounded, _details?.weight ?? (isFemale ? '50-54KG' : '60-65KG'), isDark),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildDetailItem(Icons.work_outline_rounded, _details?.occupation ?? (isFemale ? 'Streamer & Creator' : 'Developer'), isDark),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // ── 5. Personality and traits Section ───────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personality and traits',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: (_details?.traits ?? ['Romantic', 'Patient', 'Adventurous', 'Ambitious'])
                            .map((t) => _TraitChip(label: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── 6. User's Moments / Posts Grid ──────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Moments & Posts',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '3 Posts',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // 3-Column Image Grid
                      GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildPostThumbnail(
                            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
                            likes: 124,
                            isVideo: false,
                          ),
                          _buildPostThumbnail(
                            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&q=80',
                            likes: 89,
                            isVideo: true,
                          ),
                          _buildPostThumbnail(
                            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400&q=80',
                            likes: 215,
                            isVideo: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky Bottom Bar: Glowing Chat or Edit Profile Button ────────
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: 18.h,
            child: GestureDetector(
              onTap: () {
                if (isMe) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ).then((_) async {
                    final updated = await PersonalDetailsService.instance.getDetails(auth.currentUser);
                    if (mounted) setState(() => _details = updated);
                  });
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        user: _user,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFF7928CA)],
                  ),
                  borderRadius: BorderRadius.circular(26.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMe ? Icons.edit_note_rounded : Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 19.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isMe ? 'Edit Profile Details' : 'Chat',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: isDark ? Colors.white38 : Colors.grey),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? const Color(0xFF8B9BB4) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: isDark ? Colors.white60 : const Color(0xFF475569)),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildPostThumbnail(String imageUrl, {required int likes, required bool isVideo}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          if (isVideo)
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
            ),
          Positioned(
            bottom: 4,
            left: 6,
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 12),
                const SizedBox(width: 3),
                Text(
                  '$likes',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileOptions(BuildContext context, bool isDark, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161928) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Color(0xFF00B0FF)),
              title: Text(isMe ? 'Share My Profile' : 'Share Profile', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile link copied! 🔗')));
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFFFF1493)),
                title: Text('Edit Profile Details', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                },
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.report_problem_rounded, color: Colors.orange),
                title: Text('Report User', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                title: Text('Block User', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final String label;
  const _TraitChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1E2E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
      ),
    );
  }
}
