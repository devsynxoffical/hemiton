import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/matchmaking_profile_model.dart';
import 'package:hemiton/widgets/find_someone_sheet.dart';

void main() {
  group('Feature 09: Find Someone Like Me Tests', () {
    test('MatchmakingProfile model serialization and compatibility calculation', () {
      final userA = MatchmakingProfile(
        userId: 'u_1',
        name: 'Alex',
        mood: 'Chill Vibes ☕',
        languages: ['English', 'Spanish'],
        interests: ['Gaming', 'Anime', 'Lofi'],
      );

      final userB = MatchmakingProfile(
        userId: 'u_2',
        name: 'Maria',
        mood: 'Chill Vibes ☕',
        languages: ['English', 'French'],
        interests: ['Anime', 'Lofi', 'Art'],
      );

      final score = userA.calculateCompatibilityWith(userB);
      // Base: 40 + Mood (20) + Shared lang: English (10) + Shared interests: Anime, Lofi (20) = 90
      expect(score, 90);

      final json = userA.toJson();
      final fromJson = MatchmakingProfile.fromJson(json);
      expect(fromJson.userId, 'u_1');
      expect(fromJson.name, 'Alex');
      expect(fromJson.mood, 'Chill Vibes ☕');
      expect(fromJson.interests, ['Gaming', 'Anime', 'Lofi']);
    });

    testWidgets('FindSomeoneSheet renders header, mood selector, and interest chips', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FindSomeoneSheet(
              currentUserId: 'me_1',
              currentUserName: 'Tester Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Find Someone Like Me'), findsOneWidget);
      expect(find.text('What’s your hangout mood right now?'), findsOneWidget);
      expect(find.text('Chill Vibes ☕'), findsWidgets);
      expect(find.text('#Gaming'), findsWidgets);
      expect(find.text('#Anime'), findsWidgets);
      expect(find.text('#Lofi'), findsWidgets);
      expect(find.textContaining('Top Matches'), findsOneWidget);
    });

    testWidgets('FindSomeoneSheet displays compatibility match badges and allows inviting', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FindSomeoneSheet(
              currentUserId: 'me_1',
              currentUserName: 'Tester Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check match card presence
      expect(find.text('Aria Vance'), findsOneWidget);
      expect(find.textContaining('Match'), findsWidgets);

      // Tap Invite button
      final inviteButton = find.text('Invite').first;
      await tester.tap(inviteButton);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('FindSomeoneSheet toggling mood triggers matchmaking re-calculation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FindSomeoneSheet(
              currentUserId: 'me_1',
              currentUserName: 'Tester Host',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gamingMood = find.text('Gaming 🎮');
      expect(gamingMood, findsOneWidget);

      await tester.tap(gamingMood);
      await tester.pumpAndSettle();

      // Top matches should still be displayed
      expect(find.textContaining('Top Matches'), findsOneWidget);
    });
  });
}
