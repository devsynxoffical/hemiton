import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/hangout_challenge_model.dart';
import 'package:hemiton/widgets/hangout_challenges_sheet.dart';

void main() {
  group('Feature 10: Hangout Challenges Tests', () {
    test('HangoutChallenge model serialization and progress logic', () {
      final challenge = HangoutChallenge(
        id: 'c_test_1',
        title: 'Squad Fireworks Quest',
        description: 'Send 20 gifts collectively',
        icon: '🎆',
        targetCount: 20,
        currentProgress: 15,
        durationSeconds: 300,
        remainingSeconds: 120,
        rewardDescription: 'Fireworks Animation & +500 XP',
        rewardBadge: '🌟',
      );

      expect(challenge.isCompleted, isFalse);
      expect(challenge.progressRatio, 0.75);
      expect(challenge.percentComplete, 75);

      // Increment progress to reach target
      final completed = challenge.incrementProgress(5, 'user_dave');
      expect(completed.isCompleted, isTrue);
      expect(completed.currentProgress, 20);
      expect(completed.status, HangoutChallengeStatus.completed);
      expect(completed.contributors.contains('user_dave'), isTrue);

      final json = challenge.toJson();
      final fromJson = HangoutChallenge.fromJson(json);
      expect(fromJson.id, 'c_test_1');
      expect(fromJson.title, 'Squad Fireworks Quest');
      expect(fromJson.targetCount, 20);
      expect(fromJson.currentProgress, 15);
    });

    testWidgets('HangoutChallengesSheet displays header, challenge cards, and rewards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutChallengesSheet(
              currentUserId: 'user_tester',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hangout Room Challenges'), findsOneWidget);
      expect(find.text('Squad Gift Shower 🎁'), findsOneWidget);
      expect(find.text('Mic Marathon 🎙️'), findsOneWidget);

      final thirdCard = find.text('Emoji Avalanche 🎉');
      await tester.scrollUntilVisible(thirdCard, 200);
      expect(thirdCard, findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('HangoutChallengesSheet contribute button increments progress', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutChallengesSheet(
              currentUserId: 'user_tester',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final contributeBtn = find.text('Contribute +10').first;
      expect(contributeBtn, findsOneWidget);

      await tester.tap(contributeBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
