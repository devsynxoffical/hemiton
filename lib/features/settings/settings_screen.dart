import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';
import 'community_guidelines_screen.dart';
import 'feedback_contact_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

/// Attractive Settings Screen inspired by Image 3:
/// - List items matching Image 3 with modern premium card design:
///   1. Contact Us / FeedBack >
///   2. Privacy Policy >
///   3. Term of Service >
///   4. Community Guidelines >
///   5. Email: danialamjad36@gmail.com
///   6. Language: System Language >
///   7. Theme Mode: Interactive Light & Dark Mode switch (Instant toggle across app)
///   8. Version: 2.1.600
///   9. Log out >
///   10. Delete your account (subtle centered button with 3-day recovery notice)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'System Language';

  void _showLanguageDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languages = [
      'System Language',
      'English (US)',
      'Urdu (اردو)',
      'Arabic (العربية)',
      'Spanish (Español)',
      'French (Français)',
      'Chinese (中文)',
    ];

    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161824) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(
            'Select Language',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkNavy,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  lang,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF00E676)
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676))
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(c);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language set to $lang'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showEmailDialog(String currentEmail) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161824) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.email_outlined, color: Color(0xFF00B0FF)),
            SizedBox(width: 8.w),
            const Text('Account Email', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your registered email address:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2030) : const Color(0xFFF2F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B0FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email updated successfully!'),
                  backgroundColor: Color(0xFF00E676),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161824) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent),
            SizedBox(width: 8.w),
            const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to log out of your HEMI TON account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen(initialMode: AuthMode.login)),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161824) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⏳ 3-Day Recovery Window',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Your account will enter a 3-day recovery holding period. If you log back in within 3 days, your account will be restored. After 3 days, it will be permanently deleted.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Enter password to confirm:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Your password',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E2030) : const Color(0xFFF2F4F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = context.read<AuthProvider>();
              await authProvider.deleteAccount(password: passwordController.text);
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen(initialMode: AuthMode.login)),
                  (route) => false,
                );
              }
            },
            child: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final auth = context.watch<AuthProvider>();
    final email = auth.currentUser.email?.isNotEmpty == true
        ? auth.currentUser.email!
        : 'danialamjad36@gmail.com';

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
          'Setting',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // ── Item 1: Contact Us / FeedBack ────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Contact Us / FeedBack',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackContactScreen()),
                );
              },
            ),

            // ── Item 2: Privacy Policy ───────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                );
              },
            ),

            // ── Item 3: Term of Service ──────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Term of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                );
              },
            ),

            // ── Item 4: Community Guidelines ─────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Community Guidelines',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityGuidelinesScreen()),
                );
              },
            ),

            // ── Item 5: Email ────────────────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Email',
              trailingText: email,
              showChevron: false,
              onTap: () => _showEmailDialog(email),
            ),

            // ── Item 6: Language ─────────────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Language',
              trailingText: _selectedLanguage,
              showChevron: true,
              onTap: _showLanguageDialog,
            ),

            // ── Item 7: Theme Mode (Light / Dark Mode Switch) ────────────────
            _buildThemeCard(themeProvider, isDark),

            // ── Item 8: Version ──────────────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Version',
              trailingText: '2.1.600',
              showChevron: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('HEMI TON is up to date (Version 2.1.600)'),
                    backgroundColor: Color(0xFF00E676),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // ── Item 9: Log out ──────────────────────────────────────────────
            _buildSettingCard(
              isDark: isDark,
              title: 'Log out',
              titleColor: Colors.redAccent,
              showChevron: true,
              onTap: _showLogoutConfirmation,
            ),

            SizedBox(height: 36.h),

            // ── Item 10: Delete your account (Subtle text at bottom) ─────────
            GestureDetector(
              onTap: _showDeleteAccountConfirmation,
              child: Text(
                'Delete your account',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white38 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required bool isDark,
    required String title,
    String? trailingText,
    Color? titleColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141624) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? (isDark ? Colors.white : AppColors.darkNavy),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white60 : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                size: 20.sp,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeCard(ThemeProvider themeProvider, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141624) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        leading: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: isDark ? const Color(0xFF00E676) : const Color(0xFFFFB300),
          size: 22.sp,
        ),
        title: Text(
          'Theme Mode',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.darkNavy,
          ),
        ),
        subtitle: Text(
          isDark ? 'Dark Mode' : 'Light Mode',
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.white54 : Colors.grey.shade600,
          ),
        ),
        trailing: Switch(
          value: isDark,
          activeThumbColor: const Color(0xFF00E676),
          inactiveThumbColor: const Color(0xFFFFB300),
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: (val) {
            themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
          },
        ),
      ),
    );
  }
}
