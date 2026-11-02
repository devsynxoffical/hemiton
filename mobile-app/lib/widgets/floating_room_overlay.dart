import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/services/room_config_manager.dart';
import '../core/repositories/backend_repository.dart';
import '../core/repositories/room_repository.dart';
import '../providers/room_overlay_provider.dart';
import '../providers/live_provider.dart';
import '../providers/live_party_provider.dart';
import '../providers/auth_provider.dart';

class FloatingRoomOverlay extends StatefulWidget {
  const FloatingRoomOverlay({super.key});

  @override
  State<FloatingRoomOverlay> createState() => _FloatingRoomOverlayState();
}

class _FloatingRoomOverlayState extends State<FloatingRoomOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleClose(BuildContext context, RoomOverlayProvider overlayProvider) async {
    final activeRoom = overlayProvider.activeRoom;
    final activeRoomId = activeRoom?.id;
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final isHostUser = activeRoom != null &&
        ((currentUser.id.isNotEmpty && (activeRoom.host.id == currentUser.id || activeRoom.creatorUserId == currentUser.id)) ||
            (currentUser.username.trim().isNotEmpty &&
                activeRoom.host.username.trim().isNotEmpty &&
                activeRoom.host.username.trim().toLowerCase() == currentUser.username.trim().toLowerCase()));

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF22133D),
                Color(0xFF130B24),
                Color(0xFF0B0616),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: const Color(0xFFFF007F).withValues(alpha: 0.45),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF007F).withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF007F), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isHostUser ? 'Live Broadcast Options' : 'Leave Live Room?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isHostUser
                    ? 'Would you like to continue in this live room, leave temporarily, or end the live broadcast for everyone?'
                    : 'Would you like to stay and continue watching, or leave this live room?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),

              // 1. Continue Live
              GestureDetector(
                onTap: () => Navigator.pop(ctx, 'continue'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 19),
                      SizedBox(width: 8),
                      Text(
                        'Continue Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Leave Live
              GestureDetector(
                onTap: () => Navigator.pop(ctx, 'leave'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Leave Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. End Live (ONLY visible to Host)
              if (isHostUser) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx, 'end'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF1744), Color(0xFFFF007F)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF1744).withValues(alpha: 0.38),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'End Live',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (action == 'leave' && context.mounted) {
      overlayProvider.closeRoom(context);
    } else if (action == 'end' && context.mounted) {
      if (activeRoomId != null) {
        BackendRepository.instance.removeLiveRoom(activeRoomId);
        await RoomRepository.instance.closeRoom(activeRoomId);
      }
      if (context.mounted) {
        overlayProvider.closeRoom(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live broadcast has ended.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomOverlayProvider>(
      builder: (context, overlayProvider, child) {
        if (!overlayProvider.isMinimized || overlayProvider.activeRoom == null) {
          return const SizedBox.shrink();
        }

        final room = RoomConfigManager.instance.applyOverrides(overlayProvider.activeRoom!);
        final isLive = overlayProvider.roomType == 'LIVE';
        final screenSize = MediaQuery.of(context).size;

        return Positioned(
          left: overlayProvider.position.dx,
          top: overlayProvider.position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              overlayProvider.updatePosition(details.delta, screenSize);
            },
            onTap: () {
              overlayProvider.expandRoom(context);
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 145,
                height: 195,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.purple.shade900.withValues(alpha: 0.65),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isLive
                              ? AppColors.liveRed.withValues(alpha: 0.6)
                              : Colors.amber.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Image or Avatar Blur
                          if (room.coverUrl.isNotEmpty)
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.35,
                                child: Builder(
                                  builder: (context) {
                                    if (room.coverUrl.startsWith('http')) {
                                      return Image.network(
                                        room.coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                      );
                                    } else if (room.coverUrl.startsWith('assets')) {
                                      return Image.asset(room.coverUrl, fit: BoxFit.cover);
                                    } else {
                                      final f = File(room.coverUrl);
                                      if (f.existsSync()) {
                                        return Image.file(f, fit: BoxFit.cover);
                                      }
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ),
                            ),

                          // Content Column
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top Header Row: Room Type Pill & Close Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Room Type Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLive ? AppColors.liveRed : Colors.amber.shade700,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ScaleTransition(
                                            scale: _pulseAnimation,
                                            child: Container(
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            isLive ? 'LIVE' : 'PARTY',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Close Button (X)
                                    GestureDetector(
                                      onTap: () => _handleClose(context, overlayProvider),
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Center Host Avatar & Pulsing Audio Ring
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 54,
                                        height: 54,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isLive
                                                ? AppColors.liveRed.withValues(alpha: 0.8)
                                                : Colors.amberAccent.withValues(alpha: 0.8),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 23,
                                      backgroundColor: Colors.grey.shade800,
                                      backgroundImage: room.host.avatarUrl.isNotEmpty
                                          ? NetworkImage(room.host.avatarUrl)
                                          : null,
                                      child: room.host.avatarUrl.isEmpty
                                          ? Text(
                                              room.host.name.isNotEmpty
                                                  ? room.host.name[0].toUpperCase()
                                                  : 'Z',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),

                                // Room Title & Host Name
                                Column(
                                  children: [
                                    Text(
                                      room.title.isNotEmpty ? room.title : room.host.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.remove_red_eye_rounded,
                                          color: Colors.white70,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${room.viewerCount}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Bottom Action Controls: Expand & Mic Toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Expand Full Screen Button
                                    GestureDetector(
                                      onTap: () => overlayProvider.expandRoom(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.open_in_full_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              'Expand',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Quick Mic Mute Toggle
                                    Consumer2<LiveProvider, LivePartyProvider>(
                                      builder: (ctx, liveProv, partyProv, _) {
                                        final isMicMuted = isLive
                                            ? liveProv.isMicMuted
                                            : partyProv.isLocalMicMuted;

                                        return GestureDetector(
                                          onTap: () {
                                            if (isLive) {
                                              liveProv.toggleLocalMic();
                                            } else {
                                              partyProv.toggleLocalMic();
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isMicMuted
                                                  ? Colors.red.withValues(alpha: 0.5)
                                                  : Colors.green.withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isMicMuted
                                                  ? Icons.mic_off_rounded
                                                  : Icons.mic_rounded,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
