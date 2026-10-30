import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/live_room_model.dart';
import '../core/services/room_lock_manager.dart';
import '../providers/game_provider.dart';

/// Module 04: Redesigned LiveRoomCard with Full Room DP as Primary Visual
/// Ensures consistent Room DP presentation and separate metadata area across all room listing tabs.
class LiveRoomCard extends StatelessWidget {
  final LiveRoomModel room;
  final VoidCallback? onTap;

  const LiveRoomCard({super.key, required this.room, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gameProvider = Provider.of<GameProvider>(context);
    final bool isParty = room.category.toLowerCase() == 'party' || room.category.toLowerCase() == 'voice';
    final effectiveDp = gameProvider.getEffectiveRoomDp(
      room.id,
      room.coverUrl,
      room.host.region,
      hostAvatarUrl: room.host.avatarUrl,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.getCard(true) : AppColors.getCard(false),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            width: 1.5,
            color: Colors.cyanAccent.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Primary Visual: Full Clear Room DP (Square / Rounded Square) ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Image.network(
                      effectiveDp,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.network(
                        room.host.avatarUrl.isNotEmpty
                            ? room.host.avatarUrl
                            : gameProvider.globalDefaultRoomDp,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Approved Corner Badges
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded, color: Colors.cyanAccent, size: 10.w),
                          SizedBox(width: 2.w),
                          Text(
                            isParty ? '< Party >' : '< Live >',
                            style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Room Lock & Privacy Badge (Feature 6: Private Hangout Rooms)
                  if (RoomLockManager.instance.isRoomLocked(room.id) ||
                      room.isPrivate ||
                      room.roomMode == 'Lock mode' ||
                      RoomLockManager.instance.getRoomPrivacyLevel(room.id) !=
                          RoomPrivacyLevel.public)
                    Builder(builder: (ctx) {
                      final priv =
                          RoomLockManager.instance.getRoomPrivacyLevel(room.id);
                      final badgeText = priv != RoomPrivacyLevel.public &&
                              priv.badgeText.isNotEmpty
                          ? priv.badgeText
                          : 'Locked';
                      final icon = priv != RoomPrivacyLevel.public
                          ? priv.icon
                          : Icons.lock_rounded;
                      final badgeColor = priv == RoomPrivacyLevel.friendsOnly
                          ? const Color(0xFF00F5D4)
                          : priv == RoomPrivacyLevel.inviteOnly
                              ? const Color(0xFFFF007A)
                              : Colors.cyanAccent;

                      return Positioned(
                        top: 30.h,
                        left: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: badgeColor, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 8.sp, color: badgeColor),
                              SizedBox(width: 2.w),
                              Text(
                                badgeText,
                                style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.equalizer_rounded, color: Colors.amberAccent, size: 10.w),
                          SizedBox(width: 2.w),
                          Text(
                            _formatViewers(room.viewerCount),
                            style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Separate Metadata Area Below Room DP ──
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text('🇵🇰 ', style: TextStyle(fontSize: 10.sp)),
                      Expanded(
                        child: Text(
                          room.host.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.getTextSecondary(isDark),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  String _formatViewers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
