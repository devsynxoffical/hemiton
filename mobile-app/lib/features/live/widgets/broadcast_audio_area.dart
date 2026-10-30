import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/live_room_model.dart';

/// Main Audio Area for Audio Live Broadcast Screen
/// Features:
/// - Circular host avatar with glowing gradient ring
/// - Subtle animated concentric rings (active only when speaking)
/// - Speech-responsive animated audio waveform equalizer bars
///     • Animates when host is speaking and unmuted
///     • Pauses/flattens smoothly into an inactive resting state when silent or muted
/// - Compact "Audio Broadcast" pill button
/// - Floating "Top Gifter" card on the right
/// - NO floating video preview card in Audio Broadcast mode!
class BroadcastAudioArea extends StatefulWidget {
  final LiveRoomModel room;
  final String topGifterName;
  final String topGifterAvatar;
  final int topGifterGifts;
  final VoidCallback? onTopGifterTap;
  final VoidCallback? onAudioBroadcastTap;
  final bool isSpeaking;
  final bool isMuted;

  const BroadcastAudioArea({
    super.key,
    required this.room,
    this.topGifterName = 'Queen',
    this.topGifterAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
    this.topGifterGifts = 528,
    this.onTopGifterTap,
    this.onAudioBroadcastTap,
    this.isSpeaking = true,
    this.isMuted = false,
  });

  @override
  State<BroadcastAudioArea> createState() => _BroadcastAudioAreaState();
}

class _BroadcastAudioAreaState extends State<BroadcastAudioArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  bool get _isActive => widget.isSpeaking && !widget.isMuted;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (_isActive) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(BroadcastAudioArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = oldWidget.isSpeaking && !oldWidget.isMuted;
    final nowActive = _isActive;

    if (wasActive != nowActive) {
      if (nowActive) {
        if (!_animController.isAnimating) {
          _animController.repeat();
        }
      } else {
        _animController.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostAvatar = widget.room.host.avatarUrl.isNotEmpty
        ? widget.room.host.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=250&q=80';

    final active = _isActive;

    return Container(
      width: double.infinity,
      height: 195,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── 1. Concentric Radar Wave Rings (Active only when speaking) ──
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final val = active ? _animController.value : 0.0;
              return CustomPaint(
                size: const Size(double.infinity, 195),
                painter: _ConcentricRingsPainter(progress: val, isActive: active),
              );
            },
          ),

          // ── 2. Host Avatar in Center ──
          Positioned(
            top: 10,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF1493),
                    Color(0xFF8A2BE2),
                    Color(0xFF00BFFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A2BE2).withValues(alpha: active ? 0.6 : 0.25),
                    blurRadius: active ? 18 : 8,
                    spreadRadius: active ? 2 : 0,
                  ),
                  if (active)
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: ClipOval(
                child: Image.network(
                  hostAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF231A47),
                    child: const Icon(Icons.person, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Audio Waveform Bars (Smoothly animates only when active) ──
          Positioned(
            top: 104,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return _buildWaveformBars(active ? _animController.value : 0.0, active);
              },
            ),
          ),

          // ── 4. Compact "Audio Broadcast" Pill ──
          Positioned(
            top: 148,
            child: InkWell(
              onTap: widget.onAudioBroadcastTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                      color: active ? const Color(0xFF00E676) : Colors.white70,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Audio Broadcast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 5. Floating "Top Gifter" Card on Right ──
          Positioned(
            right: 0,
            top: 22,
            child: GestureDetector(
              onTap: widget.onTopGifterTap,
              child: Container(
                width: 120,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF281845).withValues(alpha: 0.92),
                      const Color(0xFF191233).withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Tag: 👑 Top Gifter
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('👑', style: TextStyle(fontSize: 9.5)),
                        SizedBox(width: 2),
                        Text(
                          'Top Gifter',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Top Gifter Avatar + Name & Gift Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.topGifterAvatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.topGifterName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Text('👑', style: TextStyle(fontSize: 7.5)),
                                ],
                              ),
                              const SizedBox(height: 1),
                              // 🎁 x 528
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🎁', style: TextStyle(fontSize: 8.5)),
                                  const SizedBox(width: 2),
                                  Text(
                                    'x ${widget.topGifterGifts}',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformBars(double progress, bool isActive) {
    const barCount = 28;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barCount, (i) {
        double barHeight;
        if (isActive) {
          final wave = math.sin((progress * 2 * math.pi) + (i * 0.35)).abs();
          final centerWeight = 1.0 - ((i - (barCount / 2)).abs() / (barCount / 2)) * 0.45;
          barHeight = (4.0 + (wave * 18.0 * centerWeight)).clamp(3.5, 22.0);
        } else {
          // Subtle static resting height when silent or muted
          barHeight = 3.2;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 2.2,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: isActive
                ? const LinearGradient(
                    colors: [
                      Color(0xFF00BFFF),
                      Color(0xFF8A2BE2),
                      Color(0xFFFF1493),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          ),
        );
      }),
    );
  }
}

/// Custom painter for concentric rings radiating outward
class _ConcentricRingsPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _ConcentricRingsPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 50);
    final radii = [52.0, 76.0, 102.0, 130.0];

    for (int i = 0; i < radii.length; i++) {
      final baseRadius = radii[i];
      final waveOffset = isActive ? math.sin((progress * 2 * math.pi) + (i * 0.8)) * 2.5 : 0.0;
      final radius = baseRadius + waveOffset;

      final alpha = isActive
          ? (0.13 - (i * 0.025)).clamp(0.02, 0.2)
          : (0.05 - (i * 0.01)).clamp(0.01, 0.08);

      final paint = Paint()
        ..color = const Color(0xFF8A2BE2).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
