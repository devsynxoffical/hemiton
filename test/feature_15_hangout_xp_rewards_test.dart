import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/hangout_xp_reward_model.dart';
import 'package:hemiton/widgets/hangout_xp_rewards_sheet.dart';

void main() {
  group('Feature 15: Hangout XP & Social Rewards Tests', () {
    test('HangoutXpRewardModel correctly computes levels, streaks, and claims', () {
      final initial = HangoutXpRewardModel.defaultForUser('user_test_123');

      expect(initial.userId, 'user_test_123');
      expect(initial.currentXp, 420);
      expect(initial.currentLevel, 2); // 420 ~/ 300 + 1 = 2
      expect(initial.tierTitle, 'Social Butterfly');
      expect(initial.streakDays, 3);
      expect(initial.hasCheckedInToday, false);

      // 1. Daily Check-in adds streak and XP
      final checkedIn = initial.checkInToday();
      expect(checkedIn.streakDays, 4);
      expect(checkedIn.hasCheckedInToday, true);
      // XP bonus = 20 * (3 + 1) = 80 -> 420 + 80 = 500
      expect(checkedIn.currentXp, 500);

      // Checking in again on same day should not double reward
      final doubleCheckIn = checkedIn.checkInToday();
      expect(doubleCheckIn.currentXp, 500);

      // 2. Claiming completed mission
      final claimed = checkedIn.claimMission('m1'); // m1 gives 50 XP
      expect(claimed.currentXp, 550);
      final mission1 = claimed.missions.firstWhere((m) => m.id == 'm1');
      expect(mission1.isClaimed, true);

      // 3. Level-up automatically unlocks badge
      // Level 3 requirement is 600 XP ( (600 ~/ 300) + 1 = 3 )
      final leveledUp = claimed.addXp(100); // 550 + 100 = 650 XP -> Level 3
      expect(leveledUp.currentLevel, 3);
      expect(leveledUp.tierTitle, 'Social Butterfly');
      final badge3 = leveledUp.badges.firstWhere((b) => b.id == 'b3');
      expect(badge3.isUnlocked, true);
    });

    test('HangoutXpRewardModel serialization toJson and fromJson roundtrip', () {
      final model = HangoutXpRewardModel.defaultForUser('user_456');
      final json = model.toJson();
      final revived = HangoutXpRewardModel.fromJson(json);

      expect(revived.userId, 'user_456');
      expect(revived.currentXp, 420);
      expect(revived.missions.length, model.missions.length);
      expect(revived.badges.length, model.badges.length);
      expect(revived.currentLevel, model.currentLevel);
    });

    testWidgets('HangoutXpRewardsSheet renders level progress and missions correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final model = HangoutXpRewardModel.defaultForUser('u1');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HangoutXpRewardsSheet(
              userId: 'u1',
              userName: 'Danial',
              initialModel: model,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header and Level
      expect(find.text('Hangout XP & Rewards'), findsOneWidget);
      expect(find.text('Social Butterfly'), findsOneWidget);
      expect(find.text('420 XP'), findsOneWidget);
      expect(find.text('Lv.2'), findsOneWidget);

      // Verify Streak Row
      expect(find.text('3-Day Hangout Streak'), findsOneWidget);
      expect(find.textContaining('Check In'), findsOneWidget);

      // Verify Daily Missions Tab
      expect(find.text('Daily Missions'), findsOneWidget);
      expect(find.text('Hangout Explorer'), findsOneWidget);
      expect(find.text('Icebreaker Champion'), findsOneWidget);

      // Tap Check In
      await tester.tap(find.textContaining('Check In'));
      await tester.pumpAndSettle();

      expect(find.text('Checked In ✓'), findsOneWidget);
      expect(find.text('4-Day Hangout Streak'), findsOneWidget);

      // Tap Claim on the first claimable mission ('Hangout Explorer' is completed)
      final claimButtons = find.widgetWithText(ElevatedButton, 'Claim');
      expect(claimButtons, findsWidgets);

      await tester.tap(claimButtons.first);
      await tester.pumpAndSettle();

      // Should now show Claimed for that mission
      expect(find.text('Claimed'), findsWidgets);

      // Switch to Perks & Badges Tab
      await tester.tap(find.text('Perks & Badges'));
      await tester.pumpAndSettle();

      expect(find.text('First Handshake'), findsOneWidget);
      expect(find.text('Party Spark'), findsOneWidget);
      expect(find.text('Legendary Host'), findsOneWidget);
    });
  });
}
