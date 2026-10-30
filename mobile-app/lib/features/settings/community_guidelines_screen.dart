import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final guidelines = [
      {
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFFF4081),
        'title': 'Respect & Kindness',
        'desc':
            'Treat all creators, hosts, and audience members with kindness. Harassment, derogatory comments, and toxic behavior are strictly prohibited across all party rooms and chats.',
      },
      {
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF00E676),
        'title': 'Broadcast Standards & Decency',
        'desc':
            'Broadcasters must maintain proper attire and ethical standards during live streams. Nudity, suggestive or sexually explicit acts, and dangerous activities will result in immediate termination of the live stream.',
      },
      {
        'icon': Icons.shield_rounded,
        'color': const Color(0xFF00B0FF),
        'title': 'Anti-Bullying & Hate Speech',
        'desc':
            'We have zero tolerance for hate speech attacking race, ethnicity, religion, disability, or gender. Any speech inciting hatred or violence will result in permanent device bans.',
      },
      {
        'icon': Icons.lock_rounded,
        'color': const Color(0xFFFFB300),
        'title': 'Anti-Scam & Real-Money Safety',
        'desc':
            'Do not engage in unverified off-platform transactions, unauthorized coin reselling, or phishing attempts. All virtual coin transfers must occur through verified HEMI TON channels.',
      },
      {
        'icon': Icons.flag_rounded,
        'color': const Color(0xFFAB47BC),
        'title': 'Reporting & Moderation',
        'desc':
            'Our 24/7 moderation team and AI filters actively protect the platform. Use the in-app Report button (•••) on any post, profile, or live room to flag violations immediately.',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E15) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.darkNavy,
            size: 19.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Community Guidelines',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Welcome Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1B2332), const Color(0xFF141724)]
                      : [const Color(0xFFE1F5FE), const Color(0xFFE8EAF6)],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0xFF00B0FF).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.diversity_3_rounded, color: const Color(0xFF00B0FF), size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Building a Safe & Fun Community',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Our guidelines ensure HEMI TON remains a vibrant, welcoming, and safe entertainment hub for everyone.',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Guidelines Cards
            ...guidelines.map((item) {
              final Color iconColor = item['color'] as Color;
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141624) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: iconColor,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.darkNavy,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item['desc'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.45,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
