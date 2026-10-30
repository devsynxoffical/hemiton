import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = [
      {
        'title': '1. Agreement to Terms',
        'content':
            'By accessing or using HEMI TON, you agree to be bound by these Terms of Service. If you do not agree to all terms, you may not access or use the application or any services provided.',
      },
      {
        'title': '2. Age Requirement (18+)',
        'content':
            'HEMI TON is strictly intended for individuals who are at least 18 years of age. Live video streaming, party room hosting, and virtual gift transactions require users to be at least 18 years old.',
      },
      {
        'title': '3. Virtual Items, Diamonds & Coins',
        'content':
            'Gold coins and Diamonds are virtual digital goods with no real-world monetary redemption outside authorized withdrawal mechanisms for verified hosts and sellers. Store items, rides, and frames expire according to their designated validity period.',
      },
      {
        'title': '4. User Conduct & Content Standards',
        'content':
            'Users must not broadcast harmful, hateful, sexually explicit, abusive, or copyright-infringing content. Any violation will result in immediate room termination, mic muting, or permanent account ban.',
      },
      {
        'title': '5. Account Security & Verification',
        'content':
            'You are responsible for safeguarding your login credentials. Any activity conducted under your account is your sole responsibility. Suspected unauthorized access should be reported immediately via Contact Us.',
      },
      {
        'title': '6. Termination & Deletion Policy',
        'content':
            'We reserve the right to suspend or terminate accounts that breach these terms. When you delete your account, a 3-day holding period applies during which you can cancel deletion by logging back in.',
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
          'Term of Service',
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
            // Top Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF261D10), const Color(0xFF16151E)]
                      : [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: const Color(0xFFFFB300), size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'HEMI TON User Agreement',
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
                    'Please review these terms before participating in live rooms or purchasing virtual goods.',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Terms Sections
            ...sections.map((section) {
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141624) : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title']!,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      section['content']!,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        height: 1.45,
                        color: isDark ? Colors.white70 : Colors.black87,
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
