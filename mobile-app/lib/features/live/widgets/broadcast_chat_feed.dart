import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../profile/user_profile_details_screen.dart';

/// Model representing a single broadcast chat/notification/gift entry
class BroadcastFeedItem {
  final String id;
  final String senderName;
  final String avatarUrl;
  final String text;
  final String timestamp;
  final bool isJoin;
  final bool isGift;
  final String? giftName;
  final String? giftEmoji;
  final int giftQuantity;
  final String? badgeText;
  final Color? nameColor;
  final bool isAudioAnnouncement;

  const BroadcastFeedItem({
    required this.id,
    required this.senderName,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
    this.isJoin = false,
    this.isGift = false,
    this.giftName,
    this.giftEmoji,
    this.giftQuantity = 1,
    this.badgeText,
    this.nameColor,
    this.isAudioAnnouncement = false,
  });
}

/// Broadcast Chat and Live Activity Feed matching the exact screenshot
class BroadcastChatFeed extends StatefulWidget {
  final ScrollController scrollController;
  final List<BroadcastFeedItem> items;

  const BroadcastChatFeed({
    super.key,
    required this.scrollController,
    required this.items,
  });

  @override
  State<BroadcastChatFeed> createState() => _BroadcastChatFeedState();
}

class _BroadcastChatFeedState extends State<BroadcastChatFeed> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white],
          stops: [0.0, 0.08, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.separated(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: widget.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 5),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return _buildFeedItem(item);
        },
      ),
    );
  }

  Widget _buildFeedItem(BroadcastFeedItem item) {
    // 1. Gift Notification Pill (Gradient Banner)
    if (item.isGift) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2C1B69),
                Color(0xFF4A148C),
                Color(0xFF880E4F),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF1493).withValues(alpha: 0.5),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A2BE2).withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(item.avatarUrl),
              const SizedBox(width: 5),
              const Text('🎁', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  item.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64B5F6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.badgeText != null) ...[
                const SizedBox(width: 2),
                Text(item.badgeText!, style: const TextStyle(fontSize: 8.5)),
              ],
              const SizedBox(width: 3),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'sent ${item.giftName ?? 'Gift'} ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.giftEmoji != null && item.giftEmoji!.startsWith('assets/'))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Image.asset(
                          item.giftEmoji!,
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Text('🎁', style: TextStyle(fontSize: 10)),
                        ),
                      )
                    else
                      Text(
                        '${item.giftEmoji ?? '🌹'} ',
                        style: const TextStyle(fontSize: 10.5),
                      ),
                    Text(
                      ' x${item.giftQuantity}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.timestamp,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 8.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Audio Join Announcement Banner (e.g. 🔊 Minal joined the live)
    if (item.isAudioAnnouncement) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E284A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF00BFFF).withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, color: Color(0xFF00BFFF), size: 14),
              const SizedBox(width: 6),
              Text(
                item.senderName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'joined the live',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                item.timestamp,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ],
          ),
        ),
      );
    }

    // 3. User Join / Entry Message
    if (item.isJoin) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(item.avatarUrl),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  item.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.nameColor ?? const Color(0xFF64B5F6),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (item.badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  item.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.timestamp,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Regular Chat Message
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          final targetUser = UserModel(
            id: 'user_${item.senderName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
            name: item.senderName,
            username: item.senderName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
            avatarUrl: item.avatarUrl,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileDetailsScreen(
                user: targetUser,
                userId: targetUser.id,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(item.avatarUrl),
              const SizedBox(width: 5),
              Text(
                item.senderName,
                style: TextStyle(
                  color: item.nameColor ?? const Color(0xFF00E5FF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.timestamp,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(
            Icons.person,
            color: Colors.white70,
            size: 13,
          ),
        ),
      ),
    );
  }
}

/// Floating animated emoji stream on right side
class FloatingReactionsStream extends StatefulWidget {
  final List<String> icons;

  const FloatingReactionsStream({
    super.key,
    this.icons = const ['🌹', '💖', '🏰', '🚀', '🔥', '✨'],
  });

  @override
  State<FloatingReactionsStream> createState() => _FloatingReactionsStreamState();
}

class _FloatingReactionsStreamState extends State<FloatingReactionsStream>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 220,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Stack(
            children: List.generate(widget.icons.length, (index) {
              final offsetRatio = (index / widget.icons.length);
              final progress = (_animController.value + offsetRatio) % 1.0;
              final y = 220.0 * (1.0 - progress);
              final xOffset = math.sin(progress * 2 * math.pi) * 6.0;
              final opacity = (progress < 0.2 ? progress / 0.2 : (1.0 - progress)).clamp(0.0, 1.0);

              return Positioned(
                bottom: y,
                left: 6 + xOffset,
                child: Opacity(
                  opacity: opacity,
                  child: Text(
                    widget.icons[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
