import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = [
      {
        'title': '1. Information We Collect',
        'content':
            'We collect information you provide directly to us when creating an account, editing your profile, or streaming live. This includes your username, nickname, date of birth, gender, profile photo, and voluntarily uploaded moments or videos. We also collect device identifiers, IP address, and general location.',
      },
      {
        'title': '2. Live Video & Voice Streaming',
        'content':
            'When you broadcast or speak in party rooms, audio and video streams are transmitted to participants in real time. We do not sell your personal live streams to third parties. Automated moderation is used to ensure community safety and prevent inappropriate broadcasts.',
      },
      {
        'title': '3. Virtual Items, Coins & Diamonds',
        'content':
            'Transactions involving Gold Coins, Diamonds, and SVIP store items are securely recorded to verify your in-app balances and wealth levels. We do not store sensitive credit card or banking details directly on our servers; payments are processed via verified third-party payment gateways.',
      },
      {
        'title': '4. Data Protection & Encryption',
        'content':
            'All communications and media transmissions between your device and our platform are encrypted using industry-standard TLS/SSL encryption protocols. We take stringent security measures to protect against unauthorized access.',
      },
      {
        'title': '5. Account Deletion & 3-Day Recovery Window',
        'content':
            'If you request account deletion from Settings, your profile will immediately enter a 3-day recovery holding period. If you log in within 3 days, your account is seamlessly restored. After 3 days, all personal data is permanently deleted from our active databases.',
      },
      {
        'title': '6. Contact Our Privacy Team',
        'content':
            'If you have any questions or concerns regarding our privacy practices, please contact our Data Protection Officer at privacy@hemiton.com or reach out via the Contact Us screen.',
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
          'Privacy Policy',
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
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1B1D30), const Color(0xFF131522)]
                      : [const Color(0xFFE8F5E9), const Color(0xFFE0F7FA)],
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF00B0FF).withValues(alpha: 0.3) : const Color(0xFF00B0FF).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: const Color(0xFF00B0FF), size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'HEMI TON Privacy Statement',
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
                    'Last updated: October 2026 • Effective Worldwide',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Policy Sections
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
                        color: isDark ? const Color(0xFF00E676) : const Color(0xFF00897B),
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
