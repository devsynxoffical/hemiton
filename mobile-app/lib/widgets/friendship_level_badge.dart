import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/friendship_level_model.dart';
import 'friendship_milestone_sheet.dart';

/// Feature 5: Friendship Level Badge Widget
/// Compact chip displayed on profile cards and chat comments.
/// Tapping it opens the detailed FriendshipMilestoneSheet.
class FriendshipLevelBadge extends StatelessWidget {
  final FriendshipLevelModel friendship;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserName;
  final String currentUserAvatar;

  const FriendshipLevelBadge({
    super.key,
    required this.friendship,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.currentUserName,
    required this.currentUserAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final tier = friendship.tier;

    return GestureDetector(
      onTap: () {
        FriendshipMilestoneSheet.show(
          context,
          friendship: friendship,
          otherUserName: otherUserName,
          otherUserAvatar: otherUserAvatar,
          currentUserName: currentUserName,
          currentUserAvatar: currentUserAvatar,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: tier.gradientColors),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: tier.gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tier.iconEmoji,
              style: TextStyle(fontSize: 10.sp),
            ),
            SizedBox(width: 4.w),
            Text(
              tier.badgeLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
