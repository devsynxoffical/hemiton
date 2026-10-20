import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/friendship_level_model.dart';
import '../models/friendship_journey_model.dart';
import 'friendship_journey_sheet.dart';
import 'user_avatar.dart';

/// Feature 5: Friendship Levels - Dedicated Milestone Modal Sheet
/// Visualizes relationship progress, stats (hours together, games, gifts, messages),
/// level unlock badges, and social XP boost opportunities.
class FriendshipMilestoneSheet extends StatelessWidget {
  final FriendshipLevelModel friendship;
  final String otherUserName;
  final String otherUserAvatar;
  final String currentUserName;
  final String currentUserAvatar;

  const FriendshipMilestoneSheet({
    super.key,
    required this.friendship,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.currentUserName,
    required this.currentUserAvatar,
  });

  static Future<void> show(
    BuildContext context, {
    required FriendshipLevelModel friendship,
    required String otherUserName,
    required String otherUserAvatar,
    required String currentUserName,
    required String currentUserAvatar,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FriendshipMilestoneSheet(
        friendship: friendship,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
        currentUserName: currentUserName,
        currentUserAvatar: currentUserAvatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = friendship.tier;
    final progress = friendship.progressToNextTier;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF130E24).withValues(alpha: 0.98),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(
                              gradient:
                                  LinearGradient(colors: tier.gradientColors),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              tier.iconEmoji,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Friendship Journey',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Dynamic social bond milestones',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

              SizedBox(height: 16.h),

              // Connected Avatars & Level Crest
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      UserAvatar(imageUrl: currentUserAvatar, radius: 26.r),
                      SizedBox(height: 4.h),
                      Text(
                        currentUserName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: tier.gradientColors),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: tier.gradientColors),
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: tier.gradientColors.first
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            'Lv. ${friendship.level}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      UserAvatar(imageUrl: otherUserAvatar, radius: 26.r),
                      SizedBox(height: 4.h),
                      Text(
                        otherUserName,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Tier Name & XP Progress Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tier.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${friendship.xp} / ${tier.nextLevelXp} XP',
                          style: TextStyle(
                            color: tier.gradientColors.first,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tier.gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Interaction Stats Grid (4 items)
              Row(
                children: [
                  _buildStatCard(
                    '⏱️ In Rooms',
                    '${friendship.hoursTogether.toStringAsFixed(1)} hrs',
                    const Color(0xFF4A90E2),
                  ),
                  SizedBox(width: 8.w),
                  _buildStatCard(
                    '🎮 Games Played',
                    '${friendship.gamesPlayedTogether}',
                    const Color(0xFF00F5D4),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildStatCard(
                    '🎁 Gifts Sent',
                    '${friendship.giftsExchanged}',
                    const Color(0xFFFF007A),
                  ),
                  SizedBox(width: 8.w),
                  _buildStatCard(
                    '💬 Chat Messages',
                    '${friendship.messagesExchanged}',
                    const Color(0xFFFFD700),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // XP Boost Tips Row
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Colors.amberAccent,
                      size: 16,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Boost level: Hangout together (+10 XP/hr) • Co-play games (+25 XP)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Feature 12: Friendship Journey Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6C5CE7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    FriendshipJourneySheet.show(
                      context,
                      journey: FriendshipJourney.sample(
                        friendship.userIdA,
                        friendship.userIdB,
                        otherUserName,
                        otherUserAvatar,
                      ),
                      currentUserName: currentUserName,
                      currentUserAvatar: currentUserAvatar,
                    );
                  },
                  icon: const Icon(Icons.auto_stories_rounded, color: Color(0xFFA29BFE), size: 16),
                  label: const Text(
                    'View Friendship Journey 📖',
                    style: TextStyle(color: Color(0xFFA29BFE), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: accentColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
