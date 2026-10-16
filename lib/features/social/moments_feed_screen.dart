import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/comments_sheet.dart';

/// Attractive Moments feed screen matching Image 1 layout with enhanced modern aesthetics.
class MomentsFeedScreen extends StatefulWidget {
  const MomentsFeedScreen({super.key});

  @override
  State<MomentsFeedScreen> createState() => _MomentsFeedScreenState();
}

class _MomentsFeedScreenState extends State<MomentsFeedScreen> {
  // Built-in curated attractive moment posts (matching Image 1)
  final List<_MomentPostData> _demoPosts = [
    _MomentPostData(
      id: 'm1',
      userName: 'Anam',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      gender: 'female',
      age: 21,
      caption: "Friend's Home 🔥 Hanging out with the squad in our party room tonight!",
      mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=85',
      isVideo: false,
      dateText: '10/03',
      likes: 8,
      comments: 2,
    ),
    _MomentPostData(
      id: 'm2',
      userName: 'Anam',
      userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      gender: 'female',
      age: 21,
      caption: 'Happy birthday leader bhaiya 🎂🎂 Wishing you endless success & happiness!',
      mediaUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=85',
      isVideo: true,
      dateText: '10/03',
      likes: 14,
      comments: 5,
    ),
    _MomentPostData(
      id: 'm3',
      userName: 'danial',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      gender: 'male',
      age: 21,
      caption: 'Cruising through the city lights ✨ Ready for tonight\'s special live stream! Who is joining? 🚀',
      mediaUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=85',
      isVideo: false,
      dateText: 'Today 12:45',
      likes: 29,
      comments: 7,
    ),
  ];

  final Set<String> _likedPostIds = {};
  final Set<String> _sentHiIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() {});
      },
      color: AppColors.pink,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        physics: const BouncingScrollPhysics(),
        itemCount: _demoPosts.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final post = _demoPosts[index];
          return _buildMomentCard(context, post, isDark);
        },
      ),
    );
  }

  Widget _buildMomentCard(BuildContext context, _MomentPostData post, bool isDark) {
    final isLiked = _likedPostIds.contains(post.id);
    final hasSentHi = _sentHiIds.contains(post.id);
    final displayLikes = post.likes + (isLiked ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13151D) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar, Name, Gender Badge & 3-Dots Menu ───────────────
          Row(
            children: [
              // Avatar with glowing neon ring
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFF8A2BE2), Color(0xFF00BFFF)],
                  ),
                ),
                padding: EdgeInsets.all(2.w),
                child: ClipOval(
                  child: Image.network(
                    post.userAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF222634) : const Color(0xFFE2E8F0),
                      child: Icon(Icons.person, color: isDark ? Colors.white54 : Colors.grey, size: 22.w),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Username + Gender Tag
              Expanded(
                child: Row(
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.darkNavy,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 6.w),

                    // Gender / Age Badge (♀ 21 pink or ♂ 21 cyan)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: post.gender == 'female'
                              ? [const Color(0xFFFF4081), const Color(0xFFFF1493)]
                              : [const Color(0xFF00B0FF), const Color(0xFF0081CB)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: (post.gender == 'female'
                                    ? const Color(0xFFFF1493)
                                    : const Color(0xFF00B0FF))
                                .withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.gender == 'female' ? Icons.female_rounded : Icons.male_rounded,
                            size: 11.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${post.age}',
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

              // 3-Dots Menu Button
              GestureDetector(
                onTap: () => _showPostOptionsSheet(context, post, isDark),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    size: 22.w,
                  ),
                ),
              ),
            ],
          ),

          // ── Caption / Text Description ──────────────────────────────────────
          if (post.caption.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              post.caption,
              style: TextStyle(
                fontSize: 13.5.sp,
                height: 1.4,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],

          // ── Media Card (Photo / Video Container) ───────────────────────────
          if (post.mediaUrl.isNotEmpty) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                _showMediaPreview(context, post);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: 280.h,
                    minHeight: 180.h,
                  ),
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      Image.network(
                        post.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200.h,
                          color: const Color(0xFF1E2230),
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, color: Colors.white30, size: 40),
                          ),
                        ),
                      ),

                      // Video Play Icon Overlay (matching Image 1)
                      if (post.isVideo)
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1.5),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30.w,
                            ),
                          ),
                        ),

                      // Subtle gradient at bottom of media
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ── Date Stamp (e.g. 10/03) ────────────────────────────────────────
          SizedBox(height: 10.h),
          Text(
            post.dateText,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: isDark ? const Color(0xFF718096) : const Color(0xFFA0AEC0),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 10.h),

          // ── Bottom Action Row: Likes, Comments, & "Hi" Button ──────────────
          Row(
            children: [
              // Like Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      _likedPostIds.remove(post.id);
                    } else {
                      _likedPostIds.add(post.id);
                    }
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isLiked ? const Color(0xFFFF1493) : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                      size: 20.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '$displayLikes',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isLiked
                            ? const Color(0xFFFF1493)
                            : (isDark ? Colors.white70 : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 22.w),

              // Comment Button
              GestureDetector(
                onTap: () {
                  CommentsSheet.show(context, targetId: post.id);
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      size: 19.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '${post.comments}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // "😊 Hi" Pill Button on the right (matching Image 1)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sentHiIds.add(post.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Text('👋 ', style: TextStyle(fontSize: 18)),
                          Text('Greeting sent to ${post.userName}! 😊'),
                        ],
                      ),
                      backgroundColor: const Color(0xFFFF6D00),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      duration: const Duration(milliseconds: 1400),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: hasSentHi
                        ? (isDark ? const Color(0xFF263238) : const Color(0xFFECEFF1))
                        : (isDark ? const Color(0xFF2A1C14) : const Color(0xFFFFF3E0)),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: hasSentHi
                          ? (isDark ? Colors.white24 : Colors.grey)
                          : const Color(0xFFFF9100),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasSentHi ? '✅' : '😊',
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        hasSentHi ? 'Sent' : 'Hi',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: hasSentHi
                              ? (isDark ? Colors.white60 : Colors.grey)
                              : const Color(0xFFFF9100),
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

  void _showPostOptionsSheet(BuildContext context, _MomentPostData post, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161822) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: AppColors.blue),
                  title: Text('Share Moment', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Moment link copied! 🔗')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: AppColors.purple),
                  title: Text('Copy Caption', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Caption copied to clipboard!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_rounded, color: Colors.redAccent),
                  title: Text('Report Content', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted. Thank you!')),
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

  void _showMediaPreview(BuildContext context, _MomentPostData post) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  post.mediaUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 16.w,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentPostData {
  final String id;
  final String userName;
  final String userAvatar;
  final String gender;
  final int age;
  final String caption;
  final String mediaUrl;
  final bool isVideo;
  final String dateText;
  final int likes;
  final int comments;

  _MomentPostData({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.gender,
    required this.age,
    required this.caption,
    required this.mediaUrl,
    required this.isVideo,
    required this.dateText,
    required this.likes,
    required this.comments,
  });
}
