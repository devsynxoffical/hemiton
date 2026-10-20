import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/hangout_community_model.dart';
import 'package:hemiton/widgets/hangout_communities_sheet.dart';

void main() {
  group('Feature 14: Interest-Based Hangout Communities Tests', () {
    test('HangoutCommunity model serialization and toggleMembership logic', () {
      final community = HangoutCommunity(
        id: 'c_1',
        name: 'The Gaming Guild',
        category: 'Gaming',
        description: 'Multiplayer squad hangouts',
        icon: '🎮',
        memberCount: 50,
        isMember: false,
        activeRoomsCount: 2,
        tags: ['Gaming', 'Trivia'],
        featuredRoomId: 'room_1',
        featuredRoomTitle: 'Guild Battle',
      );

      expect(community.hasActiveRooms, isTrue);
      expect(community.isMember, isFalse);
      expect(community.memberCount, 50);

      // Join
      final joined = community.toggleMembership();
      expect(joined.isMember, isTrue);
      expect(joined.memberCount, 51);

      // Leave
      final left = joined.toggleMembership();
      expect(left.isMember, isFalse);
      expect(left.memberCount, 50);

      final json = community.toJson();
      final fromJson = HangoutCommunity.fromJson(json);
      expect(fromJson.id, 'c_1');
      expect(fromJson.name, 'The Gaming Guild');
      expect(fromJson.category, 'Gaming');
    });

    testWidgets('HangoutCommunitiesSheet renders categories and community cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutCommunitiesSheet(
              currentUserId: 'user_tester',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hangout Communities'), findsOneWidget);
      expect(find.text('The Gaming Guild 🎮'), findsOneWidget);
      expect(find.text('Anime & Otaku Lounge 🌸'), findsOneWidget);
      expect(find.text('Gaming'), findsWidgets);
      expect(find.text('COMMUNITY LIVE HANGOUT'), findsWidgets);
    });

    testWidgets('HangoutCommunitiesSheet toggling membership updates Join state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutCommunitiesSheet(
              currentUserId: 'user_tester',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find first "Join" button (for Anime & Otaku Lounge)
      final joinBtn = find.text('Join').first;
      expect(joinBtn, findsOneWidget);

      await tester.tap(joinBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
