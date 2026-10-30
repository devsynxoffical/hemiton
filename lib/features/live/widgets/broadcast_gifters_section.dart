import 'package:flutter/material.dart';

/// Top 2 Gifters and Other Gifters section for Broadcast Screen
/// Compact, responsive, and aligned without overflowing or overlapping
class BroadcastGiftersSection extends StatelessWidget {
  final VoidCallback? onSeeAllTopGifters;
  final VoidCallback? onSeeAllOtherGifters;
  final VoidCallback? onViewersTap;

  const BroadcastGiftersSection({
    super.key,
    this.onSeeAllTopGifters,
    this.onSeeAllOtherGifters,
    this.onViewersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. Top 2 Gifters Card ──
          _buildTop2GiftersCard(),
          const SizedBox(height: 6),

          // ── 2. Other Gifters Card (Directly below Top 2 Gifters) ──
          _buildOtherGiftersCard(),
        ],
      ),
    );
  }

  // ── Top 2 Gifters ──
  Widget _buildTop2GiftersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF140F28).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: 🏆 Top 2 Gifters ... See All >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 5),
                  Text(
                    'Top 2 Gifters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSeeAllTopGifters,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white60, size: 13),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Two ranking cards side-by-side
          Row(
            children: [
              // Rank 1: Queen
              Expanded(
                child: _buildRankCard(
                  rank: 1,
                  ribbonColor: const Color(0xFFFFB300),
                  ribbonBg: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  ),
                  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
                  name: 'Queen',
                  badgeEmoji: '👑',
                  giftCount: 528,
                  borderColor: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(width: 8),

              // Rank 2: Hassan
              Expanded(
                child: _buildRankCard(
                  rank: 2,
                  ribbonColor: const Color(0xFF90CAF9),
                  ribbonBg: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                  ),
                  avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
                  name: 'Hassan',
                  badgeEmoji: '🔥',
                  giftCount: 342,
                  borderColor: const Color(0xFF64B5F6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard({
    required int rank,
    required Color ribbonColor,
    required LinearGradient ribbonBg,
    required String avatarUrl,
    required String name,
    required String badgeEmoji,
    required int giftCount,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B1E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Rank Ribbon Badge
          Container(
            width: 17,
            height: 22,
            decoration: BoxDecoration(
              gradient: ribbonBg,
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 5),

          // User Avatar with Ring
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.3),
            ),
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Colors.white60,
                  size: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Name and Gift Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(badgeEmoji, style: const TextStyle(fontSize: 8.5)),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 8.5)),
                    const SizedBox(width: 2),
                    Text(
                      'x $giftCount',
                      style: const TextStyle(
                        color: Color(0xFFFF69B4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Other Gifters ──
  Widget _buildOtherGiftersCard() {
    final otherGifterAvatars = [
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
      'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&q=80',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&q=80',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=100&q=80',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF140F28).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: 🎁 Other Gifters ... See All >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 5),
                  Text(
                    'Other Gifters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onSeeAllOtherGifters,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Colors.white60, size: 13),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Horizontal row of 6 avatars + +12 pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...otherGifterAvatars.map((url) {
                return Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: Colors.white60,
                        size: 15,
                      ),
                    ),
                  ),
                );
              }),

              // +12 overflow badge
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF26194A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '+12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
