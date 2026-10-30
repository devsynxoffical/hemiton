import 'package:flutter/material.dart';
import '../../../../models/live_room_model.dart';
import '../../../../widgets/level_and_trophy_sheet.dart';
import '../../profile/user_profile_details_screen.dart';

/// Top Host Header for Audio Live and Video Live Broadcast screens
/// Displays:
/// - Back button
/// - Host avatar with glowing ring & green online dot
/// - Host name with verified badge and mode subtitle
/// - Viewer avatars row horizontally at the top-right (+N indicator & count)
/// - Rank 12 pill
/// - More options (⋮) button
class BroadcastHostHeader extends StatelessWidget {
  final LiveRoomModel room;
  final bool isAudioMode;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback? onMinimize;
  final VoidCallback? onRankTap;
  final VoidCallback? onViewerCountTap;
  final VoidCallback? onViewersTap;
  final VoidCallback? onModeToggle;
  final int viewerCount;
  final int rankNumber;
  final List<String> viewerAvatars;

  const BroadcastHostHeader({
    super.key,
    required this.room,
    required this.isAudioMode,
    required this.onBack,
    required this.onMore,
    this.onMinimize,
    this.onRankTap,
    this.onViewerCountTap,
    this.onViewersTap,
    this.onModeToggle,
    this.viewerCount = 2800,
    this.rankNumber = 12,
    this.viewerAvatars = const [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
    ],
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hostName = room.host.name.isNotEmpty
        ? room.host.name
        : (room.host.displayName.isNotEmpty
            ? room.host.displayName
            : (room.host.username.isNotEmpty ? room.host.username : 'Ayesha Live'));

    final hostAvatar = room.host.avatarUrl.isNotEmpty
        ? room.host.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. Back Button ──
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 2),

          // ── 2. Host Avatar with Glowing Purple Border & Green Online Indicator ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileDetailsScreen(
                    user: room.host,
                    userId: room.host.id,
                  ),
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFF8A2BE2), Color(0xFF00BFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A2BE2).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(
                      hostAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A2050),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
                // Green Online Dot
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D0B18), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // ── 3. Host Name & Subtitle (Flexible to prevent any RenderFlex overflow) ──
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileDetailsScreen(
                      user: room.host,
                      userId: room.host.id,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Host Name + Verified Checkmark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00BFFF),
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Subtitle: Audio Live / Video Live + Host Badge (horizontal scroll safe)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onModeToggle,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAudioMode ? Icons.podcasts_rounded : Icons.videocam_rounded,
                              color: Colors.white70,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isAudioMode ? 'Audio Live' : 'Video Live',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // 👑 Host Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A2BE2), Color(0xFF6B21A8)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👑', style: TextStyle(fontSize: 7.5)),
                            SizedBox(width: 2),
                            Text(
                              'Host',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),

          // ── 4. Viewer Avatars (Top Right) ──
          InkWell(
            onTap: onViewersTap ?? onViewerCountTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Horizontal overlapping viewer avatars (2 avatars)
                  SizedBox(
                    height: 18,
                    width: 28,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0D0B18), width: 1),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                viewerAvatars.isNotEmpty ? viewerAvatars[0] : hostAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white60, size: 10),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 11,
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0D0B18), width: 1),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                viewerAvatars.length > 1 ? viewerAvatars[1] : hostAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white60, size: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // +12 overflow badge
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1738),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 0.7),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),

                  // Viewer count number
                  Text(
                    _formatCount(viewerCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),

          // ── 5. Rank Pill ("🔥 Rank 12 >") — Tap opens Level & Trophy Sheet ──
          InkWell(
            onTap: onRankTap ?? () {
              LevelAndTrophySheet.show(
                context,
                currentLevel: rankNumber,
                rankNumber: rankNumber,
                streamerName: hostName,
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 8.5)),
                  const SizedBox(width: 2),
                  Text(
                    'Rank $rankNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 1),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white60,
                    size: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),

          // ── 6. Minimize Button (Mini floating window) ──
          if (onMinimize != null)
            InkWell(
              onTap: onMinimize,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 22,
                height: 22,
                child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 22),
              ),
            ),

          const SizedBox(width: 2),

          // ── 7. More Options Button (⋮) ──
          InkWell(
            onTap: onMore,
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: Icon(Icons.more_vert_rounded, color: Colors.white, size: 19),
            ),
          ),
        ],
      ),
    );
  }
}
