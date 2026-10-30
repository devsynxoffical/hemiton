import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/live_gift_event_model.dart';
import 'user_avatar.dart';

/// Rich Interactive Jackpot & Particle Animator for Lucky Gifts.
/// Used when Lucky Gifts (or gifts without dedicated MP4 videos) are sent.
/// Features 3D rotating sunburst rays, floating gold coin particles,
/// pulsating jackpot banner, and sleek sender glass pill.
class LuckyJackpotGiftAnimator extends StatefulWidget {
  final LiveGiftEventModel event;
  final VoidCallback onComplete;

  const LuckyJackpotGiftAnimator({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<LuckyJackpotGiftAnimator> createState() => _LuckyJackpotGiftAnimatorState();
}

class _LuckyJackpotGiftAnimatorState extends State<LuckyJackpotGiftAnimator>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rayRotationController;
  late AnimationController _coinPulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _badgeSlideAnimation;
  late Animation<double> _coinsExplosionAnimation;

  final List<_CoinParticle> _particles = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();

    // 1. Generate 24 gold coin explosion particles
    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * math.pi + (_random.nextDouble() * 0.2 - 0.1);
      final distance = 110.0 + _random.nextDouble() * 110.0;
      final size = 18.0 + _random.nextDouble() * 16.0;
      final rotationSpeed = _random.nextDouble() * 4 - 2;
      _particles.add(_CoinParticle(
        angle: angle,
        maxDistance: distance,
        size: size,
        rotationSpeed: rotationSpeed,
        isDiamond: i % 4 == 0,
      ));
    }

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    _rayRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _coinPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 0.12),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.76),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)), weight: 0.12),
    ]).animate(_mainController);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 0.22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.18,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.48),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.12,
      ),
    ]).animate(_mainController);

    _badgeSlideAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 0.35,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.53),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.12,
      ),
    ]).animate(_mainController);

    _coinsExplosionAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.12, 0.70, curve: Curves.easeOutCubic),
    );

    _mainController.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rayRotationController.dispose();
    _coinPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _rayRotationController, _coinPulseController]),
      builder: (context, _) {
        final opacity = _fadeAnimation.value.clamp(0.0, 1.0);
        final scale = _scaleAnimation.value;
        final coinProgress = _coinsExplosionAnimation.value;

        return Opacity(
          opacity: opacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Top Glass Sender Pill
              Positioned(
                top: size.height * 0.20,
                child: _buildSenderPill(),
              ),

              // 2. Rotating Radiant Sunburst Ray Background
              Center(
                child: CustomPaint(
                  size: const Size(360, 360),
                  painter: _SunburstRayPainter(
                    rotation: _rayRotationController.value * 2 * math.pi,
                  ),
                ),
              ),

              // 3. Floating Gold Coin & Sparkle Explosion Particles
              Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: _particles.map((p) {
                      final currentDist = p.maxDistance * coinProgress;
                      final dx = 160 + math.cos(p.angle) * currentDist - (p.size / 2);
                      final dy = 160 + math.sin(p.angle) * currentDist - (p.size / 2);
                      final pOpacity = coinProgress < 0.2
                          ? coinProgress / 0.2
                          : (coinProgress > 0.85 ? (1.0 - coinProgress) / 0.15 : 1.0);

                      return Positioned(
                        left: dx,
                        top: dy,
                        child: Opacity(
                          opacity: pOpacity.clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: coinProgress * p.rotationSpeed * math.pi,
                            child: p.isDiamond
                                ? const Text('💎', style: TextStyle(fontSize: 22))
                                : Container(
                                    width: p.size,
                                    height: p.size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        colors: [Color(0xFFFFEA79), Color(0xFFFF9800)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                                          blurRadius: 8,
                                        ),
                                      ],
                                      border: Border.all(color: Colors.white, width: 1.2),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text('🪙', style: TextStyle(fontSize: 12)),
                                  ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 4. Hero Gift Icon with Golden Glow and Scale Bounce
              Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF4081).withValues(alpha: 0.35),
                          blurRadius: 48,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _buildGiftVisual(),
                  ),
                ),
              ),

              // 5. Pulsing Lucky Jackpot Multiplier Badge
              Positioned(
                top: (size.height * 0.50) + 95,
                child: Transform.scale(
                  scale: _badgeSlideAnimation.value,
                  child: _buildJackpotBanner(),
                ),
              ),

              // 6. Combo Counter if > 1
              if (widget.event.comboCount > 1)
                Positioned(
                  bottom: size.height * 0.22,
                  child: _buildComboBadge(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGiftVisual() {
    final icon = widget.event.giftIcon;
    if (icon.startsWith('assets/')) {
      return Image.asset(
        icon,
        width: 175,
        height: 175,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Text('🎁', style: TextStyle(fontSize: 90)),
      );
    }
    return Text(icon, style: const TextStyle(fontSize: 100));
  }

  Widget _buildJackpotBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFB300),
            Color(0xFFFF6F00),
            Color(0xFFE91E63),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withValues(alpha: 0.6),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🍀', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text(
            'LUCKY JACKPOT GIFT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text('✨', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSenderPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E1065),
            Color(0xFF4A148C),
            Color(0xFF880E4F),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            imageUrl: widget.event.senderAvatarUrl,
            radius: 14,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${widget.event.senderName} sent ${widget.event.giftName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.event.giftIcon.startsWith('assets/')) ...[
            const SizedBox(width: 6),
            Image.asset(widget.event.giftIcon, width: 22, height: 22, fit: BoxFit.contain),
          ],
        ],
      ),
    );
  }

  Widget _buildComboBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF1493), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1493).withValues(alpha: 0.6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Text(
        'COMBO x${widget.event.comboCount}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CoinParticle {
  final double angle;
  final double maxDistance;
  final double size;
  final double rotationSpeed;
  final bool isDiamond;

  const _CoinParticle({
    required this.angle,
    required this.maxDistance,
    required this.size,
    required this.rotationSpeed,
    required this.isDiamond,
  });
}

class _SunburstRayPainter extends CustomPainter {
  final double rotation;

  const _SunburstRayPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const rayCount = 14;
    final rayPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x77FFD700),
          Color(0x33FFA000),
          Color(0x00FF6F00),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(radius * math.cos(angle - 0.12), radius * math.sin(angle - 0.12))
        ..lineTo(radius * math.cos(angle + 0.12), radius * math.sin(angle + 0.12))
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunburstRayPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
