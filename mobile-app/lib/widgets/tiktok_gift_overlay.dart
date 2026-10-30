import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gift_model.dart';
import '../models/live_gift_event_model.dart';
import '../providers/live_gift_provider.dart';
import 'basic_gift_animator.dart';
import 'standard_gift_animator.dart';
import 'premium_gift_animator.dart';
import 'legendary_gift_animator.dart';
import 'mp4_gift_animator.dart';
import 'lucky_jackpot_gift_animator.dart';

/// TikTok-Style Live Gifting Animation Stack Overlay Layer.
/// Manages MP4 video gift animations, Lucky Jackpot particle animations,
/// and 4-level fallback gift animations without blocking live room controls.
class TikTokGiftOverlay extends StatelessWidget {
  final String roomId;

  const TikTokGiftOverlay({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveGiftProvider>(
      builder: (context, provider, child) {
        final activeEvent = provider.currentActiveEvent;
        if (activeEvent == null) return const SizedBox.shrink();

        return IgnorePointer(
          ignoring: activeEvent.animationLevel != GiftAnimationLevel.legendary,
          child: _buildLevelAnimator(context, provider, activeEvent),
        );
      },
    );
  }

  Widget _buildLevelAnimator(
    BuildContext context,
    LiveGiftProvider provider,
    LiveGiftEventModel event,
  ) {
    void onComplete() {
      provider.onCurrentEventCompleted();
    }

    // 1. Dedicated Rich Particle & Jackpot Animation for Lucky Gifts
    final isLuckyGift = event.giftId.startsWith('lucky_') ||
        event.giftIcon.contains('/lucky/') ||
        event.giftName.toLowerCase().contains('lucky');

    if (isLuckyGift) {
      return LuckyJackpotGiftAnimator(
        key: ValueKey('anim_lucky_${event.eventId}_${event.comboCount}'),
        event: event,
        onComplete: onComplete,
      );
    }

    // 2. Check if MP4 video animation is available (Classic, Event, Privilege, Special)
    final hasMp4 = (event.animationUrl != null &&
            event.animationUrl!.toLowerCase().endsWith('.mp4')) ||
        (event.giftIcon.toLowerCase().endsWith('.png') &&
            event.giftIcon.startsWith('assets/gifts/') &&
            !event.giftIcon.contains('/lucky/'));

    if (hasMp4) {
      return Mp4GiftAnimator(
        key: ValueKey('anim_mp4_${event.eventId}_${event.comboCount}'),
        event: event,
        onComplete: onComplete,
      );
    }

    switch (event.animationLevel) {
      case GiftAnimationLevel.basic:
        return BasicGiftAnimator(
          key: ValueKey('anim_${event.eventId}_${event.comboCount}'),
          event: event,
          onComplete: onComplete,
        );
      case GiftAnimationLevel.standard:
        return StandardGiftAnimator(
          key: ValueKey('anim_${event.eventId}_${event.comboCount}'),
          event: event,
          onComplete: onComplete,
        );
      case GiftAnimationLevel.premium:
        return PremiumGiftAnimator(
          key: ValueKey('anim_${event.eventId}_${event.comboCount}'),
          event: event,
          onComplete: onComplete,
        );
      case GiftAnimationLevel.legendary:
        return LegendaryGiftAnimator(
          key: ValueKey('anim_${event.eventId}_${event.comboCount}'),
          event: event,
          onComplete: onComplete,
        );
    }
  }
}
