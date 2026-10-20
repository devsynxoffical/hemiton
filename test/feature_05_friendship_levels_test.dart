import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/friendship_level_model.dart';
import 'package:hemiton/widgets/friendship_level_badge.dart';
import 'package:hemiton/widgets/friendship_milestone_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 5: Friendship Levels Tests', () {
    test('FriendshipTier progression and XP thresholds', () {
      final f = FriendshipLevelModel(userIdA: 'u1', userIdB: 'u2', xp: 50);
      expect(f.tier, equals(FriendshipTier.buddy));
      expect(f.level, equals(1));

      f.addXp(100); // 150 XP
      expect(f.tier, equals(FriendshipTier.pal));
      expect(f.level, equals(2));

      f.addXp(200); // 350 XP
      expect(f.tier, equals(FriendshipTier.closeFriend));
      expect(f.level, equals(3));

      f.addXp(300); // 650 XP
      expect(f.tier, equals(FriendshipTier.bestie));
      expect(f.level, equals(4));

      f.addXp(400); // 1050 XP
      expect(f.tier, equals(FriendshipTier.soulmate));
      expect(f.level, equals(5));
    });

    test('Social activity tracking correctly increases XP and stats', () {
      final f = FriendshipLevelModel(userIdA: 'u1', userIdB: 'u2');

      // 60 minutes in rooms -> +12 XP
      f.recordRoomTime(60);
      expect(f.minutesTogetherInRooms, equals(60));
      expect(f.hoursTogether, equals(1.0));
      expect(f.xp, equals(12));

      // 2 games played -> +50 XP
      f.recordGamePlayed();
      f.recordGamePlayed();
      expect(f.gamesPlayedTogether, equals(2));
      expect(f.xp, equals(62));

      // 1 gift sent -> +50 XP
      f.recordGiftSent();
      expect(f.giftsExchanged, equals(1));
      expect(f.xp, equals(112));
      expect(f.tier, equals(FriendshipTier.pal)); // Tier 2 unlocked

      // 5 messages -> +10 XP
      for (int i = 0; i < 5; i++) {
        f.recordMessage();
      }
      expect(f.messagesExchanged, equals(5));
      expect(f.xp, equals(122));
    });

    test('FriendshipLevelModel JSON serialization and deserialization', () {
      final json = {
        'userIdA': 'user_danial',
        'userIdB': 'user_neha',
        'xp': 420,
        'minutesTogetherInRooms': 540,
        'gamesPlayedTogether': 6,
        'giftsExchanged': 15,
        'messagesExchanged': 88,
        'establishedAt': '2026-01-01T12:00:00.000Z',
      };

      final model = FriendshipLevelModel.fromJson(json);
      expect(model.userIdA, equals('user_danial'));
      expect(model.userIdB, equals('user_neha'));
      expect(model.xp, equals(420));
      expect(model.tier, equals(FriendshipTier.closeFriend));
      expect(model.hoursTogether, equals(9.0));

      final serialized = model.toJson();
      expect(serialized['xp'], equals(420));
      expect(serialized['giftsExchanged'], equals(15));
    });

    testWidgets('FriendshipLevelBadge renders correctly and taps to open milestone sheet', (tester) async {
      final sample = FriendshipLevelModel.sampleBetween('u1', 'u2');

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: FriendshipLevelBadge(
                  friendship: sample,
                  otherUserName: 'Neha',
                  otherUserAvatar: '',
                  currentUserName: 'Danial',
                  currentUserAvatar: '',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FriendshipLevelBadge), findsOneWidget);
      expect(find.text(sample.tier.badgeLabel), findsOneWidget);

      // Tap badge to open bottom sheet
      await tester.tap(find.byType(FriendshipLevelBadge));
      await tester.pumpAndSettle();

      expect(find.byType(FriendshipMilestoneSheet), findsOneWidget);
      expect(find.text('Friendship Journey'), findsOneWidget);
      expect(find.text('Neha'), findsOneWidget);
      expect(find.text('Danial'), findsOneWidget);
    });
  });
}
