import 'package:flutter/material.dart';
import '../models/friend_live_notification_model.dart';
import 'user_avatar.dart';

class FriendLiveBanner extends StatefulWidget {
  final FriendLiveAlert alert;
  final VoidCallback? onJoin;
  final VoidCallback? onDismiss;

  const FriendLiveBanner({
    super.key,
    required this.alert,
    this.onJoin,
    this.onDismiss,
  });

  @override
  State<FriendLiveBanner> createState() => _FriendLiveBannerState();
}

class _FriendLiveBannerState extends State<FriendLiveBanner> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final alert = widget.alert;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE94057).withValues(alpha: 0.25),
            const Color(0xFF1E1A30),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE94057).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE94057).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Friend Avatar with pulsating live dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE94057), width: 1.8),
                ),
                child: UserAvatar(
                  imageUrl: alert.friendAvatar,
                  radius: 20,
                ),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),

          // Friend Info & Live Room Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        alert.friendName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          alert.relationshipBadge,
                          style: const TextStyle(
                            color: Color(0xFFA29BFE),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Hanging out in "${alert.roomTitle}"',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Join Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94057),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              if (widget.onJoin != null) {
                widget.onJoin!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🚀 Joining ${alert.friendName}\'s hangout room!'),
                    backgroundColor: const Color(0xFFE94057),
                  ),
                );
              }
            },
            child: const Text(
              'Join',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),

          // Close button
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() => _isVisible = false);
              if (widget.onDismiss != null) widget.onDismiss!();
            },
          ),
        ],
      ),
    );
  }
}
