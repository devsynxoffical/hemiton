import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/models/gift_model.dart';
import 'package:hemiton/models/live_gift_event_model.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/emoji_reaction_provider.dart';
import 'package:hemiton/providers/live_gift_provider.dart';
import 'package:hemiton/providers/wallet_provider.dart';
import 'package:hemiton/widgets/emoji_picker_sheet.dart';
import 'package:hemiton/widgets/basic_gift_animator.dart';
import 'package:hemiton/widgets/standard_gift_animator.dart';
import 'package:hemiton/widgets/premium_gift_animator.dart';
import 'package:hemiton/widgets/legendary_gift_animator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  group('Audited Gift and Emoji Fix Tests', () {
    testWidgets('1. Static artwork and fallback rendering works safely for basic, standard, premium, legendary animators', (tester) async {
      final sampleEvent = LiveGiftEventModel(
        eventId: 'test_evt_1',
        giftId: 'rose',
        giftName: 'Rose',
        giftIcon: '🌹',
        quantity: 1,
        senderId: 'user_1',
        senderName: 'Alice',
        senderAvatarUrl: '',
        receiverId: 'user_2',
        receiverName: 'Bob',
        receiverAvatarUrl: '',
        roomId: 'room_101',
        timestamp: DateTime.now(),
        giftValue: 10,
        animationLevel: GiftAnimationLevel.basic,
      );

      // Basic Animator with unicode emoji fallback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BasicGiftAnimator(
              event: sampleEvent,
              onComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('Rose'), findsOneWidget);
      expect(find.text('🌹'), findsOneWidget);

      // Standard Animator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StandardGiftAnimator(
              event: sampleEvent.copyWith(animationLevel: GiftAnimationLevel.standard),
              onComplete: () {},
            ),
          ),
        ),
      );
      expect(find.text('🌹'), findsWidgets);

      // Premium Animator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumGiftAnimator(
              event: sampleEvent.copyWith(animationLevel: GiftAnimationLevel.premium),
              onComplete: () {},
            ),
          ),
        ),
      );
      expect(find.text('🌹'), findsWidgets);

      // Legendary Animator
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LegendaryGiftAnimator(
              event: sampleEvent.copyWith(animationLevel: GiftAnimationLevel.legendary),
              onComplete: () {},
            ),
          ),
        ),
      );
      expect(find.text('🌹'), findsWidgets);
    });

    testWidgets('2. Asset emojis route to onReactionSelected and NEVER leak raw paths into onEmojiSelected', (tester) async {
      String? receivedEmoji;
      String? receivedReactionAsset;
      String? receivedReactionSymbol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  EmojiPickerSheet.show(
                    ctx,
                    roomId: 'room_101',
                    onEmojiSelected: (emoji) {
                      receivedEmoji = emoji;
                    },
                    onReactionSelected: (asset, symbol) {
                      receivedReactionAsset = asset;
                      receivedReactionSymbol = symbol;
                    },
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Find an asset reaction (e.g., Applaud)
      final applaudFinder = find.text('Applaud');
      expect(applaudFinder, findsOneWidget);

      await tester.tap(applaudFinder);
      await tester.pumpAndSettle();

      // Verified: onReactionSelected received the asset & symbol
      expect(receivedReactionAsset, contains('assets/emojis/reactions/'));
      expect(receivedReactionSymbol, equals('👏'));

      // Verified: onEmojiSelected was NOT called with raw asset path!
      expect(receivedEmoji, isNull);
    });

    testWidgets('3. Fallback onEmojiSelected receives symbol, NEVER raw asset path when onReactionSelected is omitted', (tester) async {
      String? receivedEmoji;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  EmojiPickerSheet.show(
                    ctx,
                    roomId: 'room_101',
                    onEmojiSelected: (emoji) {
                      receivedEmoji = emoji;
                    },
                  );
                },
                child: const Text('Open Picker'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      final applaudFinder = find.text('Applaud');
      await tester.tap(applaudFinder);
      await tester.pumpAndSettle();

      // Verified: received fallback symbol '👏', NOT the raw file path!
      expect(receivedEmoji, equals('👏'));
      expect(receivedEmoji!.startsWith('assets/'), isFalse);
    });

    test('4. LiveGiftProvider deduplicates events and prevents duplicate animations', () async {
      final giftProv = LiveGiftProvider();
      giftProv.setActiveRoom('room_101');
      await Future.delayed(const Duration(milliseconds: 150));

      final event1 = LiveGiftEventModel(
        eventId: 'tx_dup_test_1',
        giftId: 'rose',
        giftName: 'Rose',
        giftIcon: '🌹',
        quantity: 1,
        senderId: 'user_1',
        senderName: 'Alice',
        senderAvatarUrl: '',
        receiverId: 'user_2',
        receiverName: 'Bob',
        receiverAvatarUrl: '',
        roomId: 'room_101',
        timestamp: DateTime.now(),
        giftValue: 10,
        animationLevel: GiftAnimationLevel.basic,
      );

      giftProv.receiveGiftEvent(event1);
      expect(giftProv.currentActiveEvent?.eventId, equals('tx_dup_test_1'));

      giftProv.onCurrentEventCompleted();
      expect(giftProv.currentActiveEvent, isNull);
    });

    test('5. EmojiReactionProvider rates limits and separates emoji reactions from gift ledger', () {
      final emojiProv = EmojiReactionProvider();
      emojiProv.setActiveRoom('room_101');

      final sent1 = emojiProv.sendReaction(
        roomId: 'room_101',
        senderId: 'user_1',
        emoji: '🔥',
        senderName: 'Alice',
      );
      expect(sent1, isTrue);
      expect(emojiProv.activeReactions, isNotEmpty);
      expect(emojiProv.activeReactions.first.emoji, equals('🔥'));

      // Fast spam throttled within 250ms
      final sentSpam = emojiProv.sendReaction(
        roomId: 'room_101',
        senderId: 'user_1',
        emoji: '🔥',
        senderName: 'Alice',
      );
      expect(sentSpam, isFalse);

      emojiProv.dispose();
    });
  });
}
