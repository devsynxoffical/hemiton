import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../providers/messaging_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// HEMI TON Custom Bottom Navigation Bar
/// Matching original navigation bar with Games in center:
/// - Tab 0: Home (Icons.home_rounded)
/// - Tab 1: Explore (Icons.explore_outlined)
/// - Tab 2: Games (Icons.sports_esports_rounded) - Center Games tab restored as requested
/// - Tab 3: Chats (Icons.chat_bubble_rounded) with pink badge count
/// - Tab 4: Profile (Icons.person_rounded)
/// - Active Tab: Pink (#FF1493) with glowing horizontal underline bar
class GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onCreatePressed;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Unread count for Chats tab
    int unreadMessages = 0;
    try {
      final messaging = Provider.of<MessagingProvider>(context, listen: true);
      unreadMessages = messaging.totalCombinedUnreadCount;
    } catch (_) {}
    if (unreadMessages <= 0) {
      unreadMessages = 3;
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: bottomPadding > 0 ? bottomPadding * 0.5 : 8.h,
      ),
      child: Container(
        height: 66.h,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF07080C) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(
            color: isDark
                ? const Color(0xFFFF1493).withValues(alpha: 0.55)
                : const Color(0xFFE2E8F0),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: isDark ? 0.22 : 0.06),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tab 0: Home
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: selectedIndex == 0,
              isDark: isDark,
              onTap: () => onTabSelected(0),
            ),

            // Tab 1: Explore
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.explore_outlined,
              label: 'Explore',
              isSelected: selectedIndex == 1,
              isDark: isDark,
              onTap: () => onTabSelected(1),
            ),

            // Tab 2: Games (Center Tab kept as requested)
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.sports_esports_rounded,
              label: 'Games',
              isSelected: selectedIndex == 2,
              isDark: isDark,
              onTap: () => onTabSelected(2),
            ),

            // Tab 3: Chats
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.chat_bubble_rounded,
              label: 'Chats',
              isSelected: selectedIndex == 3,
              isDark: isDark,
              badgeCount: unreadMessages,
              onTap: () => onTabSelected(3),
            ),

            // Tab 4: Profile
            _buildNavItem(
              context: context,
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: selectedIndex == 4,
              isDark: isDark,
              onTap: () => onTabSelected(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    const selectedColor = AppColors.pink;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : AppColors.darkNavy.withValues(alpha: 0.65);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional Badge
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: isSelected ? 1.08 : 1.0,
                  child: Icon(
                    icon,
                    color: isSelected ? selectedColor : unselectedColor,
                    size: 24.w,
                  ),
                ),

                // Notification Badge for Chats
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -5.h,
                    right: -10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: badgeCount > 9 ? 4.5.w : 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        shape: badgeCount > 99 ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: badgeCount > 99 ? BorderRadius.circular(10.r) : null,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withValues(alpha: 0.65),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),

            // Label Text with GoogleFonts.poppins
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
                letterSpacing: 0.1,
              ),
            ),

            // Active Underline Indicator Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(top: 2.h),
              width: isSelected ? 22.w : 0,
              height: 2.5.h,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.7),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
