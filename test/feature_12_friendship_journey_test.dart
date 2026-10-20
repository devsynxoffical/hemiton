import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/friendship_journey_model.dart';
import 'package:hemiton/widgets/friendship_journey_sheet.dart';

void main() {
  group('Feature 12: Friendship Journey Tests', () {
    test('FriendshipJourney and FriendshipMilestoneEvent model serialization', () {
      final now = DateTime(2026, 10, 19);
      final journey = FriendshipJourney(
        userId1: 'user_a',
        userId2: 'user_b',
        friendName: 'Sophia Lee',
        friendAvatar: 'https://images.unsplash.com/photo-1534528741775',
        startedAt: now.subtract(const Duration(days: 30)),
        totalHoursTogether: 25.5,
        totalGiftsExchanged: 14,
        gamesPlayed: 8,
        milestones: [
          FriendshipMilestoneEvent(
            id: 'm1',
            title: 'First Encounter',
            description: 'Met in room',
            achievedAt: now.subtract(const Duration(days: 30)),
          ),
        ],
      );

      expect(journey.daysTogether, 30);
      expect(journey.milestones.length, 1);
      expect(journey.milestones.first.title, 'First Encounter');

      final json = journey.toJson();
      final fromJson = FriendshipJourney.fromJson(json);
      expect(fromJson.userId1, 'user_a');
      expect(fromJson.friendName, 'Sophia Lee');
      expect(fromJson.totalHoursTogether, 25.5);
      expect(fromJson.totalGiftsExchanged, 14);
      expect(fromJson.gamesPlayed, 8);
    });

    testWidgets('FriendshipJourneySheet renders hero card, metrics, and timeline events', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final journey = FriendshipJourney.sample(
        'me_1',
        'friend_1',
        'Sophia Lee',
        'https://images.unsplash.com/photo-1534528741775',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendshipJourneySheet(
              journey: journey,
              currentUserName: 'Dave',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Friendship Journey'), findsOneWidget);
      expect(find.textContaining('Sophia Lee'), findsWidgets);
      expect(find.text('Hangout Time'), findsOneWidget);
      expect(find.text('Gifts Exchanged'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('Milestone Timeline'), findsOneWidget);
      expect(find.text('First Hangout Room Encounter 🎙️'), findsOneWidget);
      expect(find.text('Hangout Trivia Duo 🧠'), findsOneWidget);
    });
  });
}
