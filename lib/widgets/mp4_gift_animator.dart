import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';
import '../models/live_gift_event_model.dart';
import 'user_avatar.dart';

/// Screen Blend Compositor for MP4 Video Gifts.
/// Mathematically removes black video background (0x000000) using BlendMode.screen
/// so gift animations, 3D models, glows, and particles float seamlessly over the live room.
class ScreenBlendWidget extends SingleChildRenderObjectWidget {
  const ScreenBlendWidget({super.key, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderScreenBlend();
}

class _RenderScreenBlend extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.canvas.saveLayer(
        offset & size,
        Paint()..blendMode = BlendMode.screen,
      );
      context.paintChild(child!, offset);
      context.canvas.restore();
    }
  }
}

/// MP4 Video Player Overlay for Animated Gifts.
/// Plays MP4 animations from assets/gifts/ (Classic, Event, Lucky, Privilege, Special)
/// with zero control blockage, smooth fade-in/out, combo counter, and safety timeout.
class Mp4GiftAnimator extends StatefulWidget {
  final LiveGiftEventModel event;
  final VoidCallback onComplete;

  const Mp4GiftAnimator({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<Mp4GiftAnimator> createState() => _Mp4GiftAnimatorState();
}

class _Mp4GiftAnimatorState extends State<Mp4GiftAnimator> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  Timer? _safetyTimeout;
  bool _completedCalled = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _initVideo();

    // Safety timeout: dismiss if video takes longer than 6 seconds or fails silently
    _safetyTimeout = Timer(const Duration(milliseconds: 6000), () {
      _finishAnimation();
    });
  }

  String _resolveMp4Path() {
    if (widget.event.animationUrl != null && widget.event.animationUrl!.isNotEmpty) {
      final anim = widget.event.animationUrl!;
      if (anim.toLowerCase().endsWith('.mp4')) {
        return anim;
      }
    }

    final icon = widget.event.giftIcon;
    if (icon.toLowerCase().endsWith('.png')) {
      return '${icon.substring(0, icon.length - 4)}.mp4';
    }

    return '';
  }

  Future<void> _initVideo() async {
    final path = _resolveMp4Path();
    if (path.isEmpty) {
      if (mounted) {
        setState(() => _hasError = true);
        _finishAnimation();
      }
      return;
    }

    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else if (path.startsWith('assets/')) {
        _controller = VideoPlayerController.asset(path);
      } else {
        _controller = VideoPlayerController.file(File(path));
      }

      await _controller!.initialize();
      _controller!.setLooping(false);
      _controller!.setVolume(1.0);

      _controller!.addListener(_checkVideoProgress);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _fadeController.forward();
        await _controller!.play();
      }
    } catch (e) {
      debugPrint('[Mp4GiftAnimator] Failed to initialize video: $e');
      if (mounted) {
        setState(() => _hasError = true);
        _finishAnimation();
      }
    }
  }

  void _checkVideoProgress() {
    if (_controller == null || _completedCalled) return;

    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;

    if (_controller!.value.isInitialized && dur > Duration.zero) {
      if (pos >= dur - const Duration(milliseconds: 150) || !_controller!.value.isPlaying && pos > Duration.zero) {
        _finishAnimation();
      }
    }
  }

  void _finishAnimation() {
    if (_completedCalled) return;
    _completedCalled = true;
    _safetyTimeout?.cancel();

    if (mounted) {
      _fadeController.reverse().then((_) {
        widget.onComplete();
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _safetyTimeout?.cancel();
    _controller?.removeListener(_checkVideoProgress);
    _controller?.pause();
    _controller?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Fallback: render thumbnail image with nice glow
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSenderPill(),
              const SizedBox(height: 16),
              if (widget.event.giftIcon.startsWith('assets/'))
                Image.asset(widget.event.giftIcon, width: 140, height: 140, fit: BoxFit.contain)
              else
                Text(widget.event.giftIcon, style: const TextStyle(fontSize: 80)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Top/Center Floating Sender & Gift Banner
          Positioned(
            top: size.height * 0.22,
            child: _buildSenderPill(),
          ),

          // 2. High-Fidelity MP4 Video Player
          Center(
            child: SizedBox(
              width: size.width * 0.90,
              height: size.height * 0.50,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: ScreenBlendWidget(
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Combo Badge if combo > 1
          if (widget.event.comboCount > 1)
            Positioned(
              bottom: size.height * 0.25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.5),
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSenderPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          color: const Color(0xFFFF4081).withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.4),
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
}
