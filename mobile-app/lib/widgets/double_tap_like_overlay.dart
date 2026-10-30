import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emoji_reaction_provider.dart';

class _FloatingHeart {
  final int id;
  final Offset position;
  final double angle;
  final Color primaryColor;
  final Color secondaryColor;
  final double size;

  const _FloatingHeart({
    required this.id,
    required this.position,
    required this.angle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.size,
  });
}

/// Wraps any Live screen to enable TikTok/Instagram-style Double-Tap to Like
/// with animated floating gradient hearts at the tap point.
class DoubleTapLikeOverlay extends StatefulWidget {
  final Widget child;
  final String? roomId;
  final VoidCallback? onLiked;

  const DoubleTapLikeOverlay({
    super.key,
    required this.child,
    this.roomId,
    this.onLiked,
  });

  @override
  State<DoubleTapLikeOverlay> createState() => _DoubleTapLikeOverlayState();
}

class _DoubleTapLikeOverlayState extends State<DoubleTapLikeOverlay> {
  final List<_FloatingHeart> _hearts = [];
  Offset _lastTapPosition = const Offset(180, 320);
  int _heartCounter = 0;
  final math.Random _rng = math.Random();

  static const List<List<Color>> _heartPalettes = [
    [Color(0xFFFF007F), Color(0xFFFF5252)],
    [Color(0xFFFF1493), Color(0xFF8A2BE2)],
    [Color(0xFFFF4081), Color(0xFFFFD700)],
    [Color(0xFFE040FB), Color(0xFF00E5FF)],
  ];

  void _spawnHeartBurst(Offset localPos) {
    final palette = _heartPalettes[_rng.nextInt(_heartPalettes.length)];
    final baseId = ++_heartCounter * 10;

    setState(() {
      // Main large heart at tap location
      _hearts.add(
        _FloatingHeart(
          id: baseId,
          position: localPos,
          angle: (_rng.nextDouble() - 0.5) * 0.45,
          primaryColor: palette[0],
          secondaryColor: palette[1],
          size: 74,
        ),
      );
      // Two smaller companion hearts
      _hearts.add(
        _FloatingHeart(
          id: baseId + 1,
          position: localPos + Offset((_rng.nextDouble() - 0.5) * 54, -18),
          angle: (_rng.nextDouble() - 0.5) * 0.65,
          primaryColor: palette[1],
          secondaryColor: palette[0],
          size: 42,
        ),
      );
    });

    try {
      if (widget.roomId != null && widget.roomId!.isNotEmpty) {
        context.read<EmojiReactionProvider>().sendReaction(
          roomId: widget.roomId!,
          senderId: 'double_tap_like',
          emoji: '❤️',
        );
      }
    } catch (_) {}

    widget.onLiked?.call();
  }

  void _removeHeart(int id) {
    if (!mounted) return;
    setState(() {
      _hearts.removeWhere((h) => h.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: (details) {
        _lastTapPosition = details.localPosition;
      },
      onDoubleTap: () {
        _spawnHeartBurst(_lastTapPosition);
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          ..._hearts.map(
            (heart) => _AnimatedTapHeart(
              key: ValueKey('double_tap_heart_${heart.id}'),
              heart: heart,
              onComplete: () => _removeHeart(heart.id),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedTapHeart extends StatefulWidget {
  final _FloatingHeart heart;
  final VoidCallback onComplete;

  const _AnimatedTapHeart({
    super.key,
    required this.heart,
    required this.onComplete,
  });

  @override
  State<_AnimatedTapHeart> createState() => _AnimatedTapHeartState();
}

class _AnimatedTapHeartState extends State<_AnimatedTapHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _dy;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.25).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 0.95).chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(_controller);

    _dy = Tween<double>(begin: 0, end: -110).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final half = widget.heart.size / 2;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Positioned(
          left: widget.heart.position.dx - half,
          top: widget.heart.position.dy - half + _dy.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacity.value.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: widget.heart.angle,
                child: Transform.scale(
                  scale: _scale.value,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [widget.heart.primaryColor, widget.heart.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: widget.heart.size,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: widget.heart.primaryColor.withValues(alpha: 0.65),
                          blurRadius: 18,
                        ),
                      ],
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

