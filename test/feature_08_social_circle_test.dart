import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/social_circle_model.dart';
import 'package:hemiton/widgets/social_circle_badge.dart';
import 'package:hemiton/widgets/social_circle_sheet.dart';

void main() {
  group('Feature 08: Social Circle Tests', () {
    test('SocialCircleModel serialization and member roles', () {
      final circle = SocialCircleModel(
        id: 'circle_test_1',
        name: 'The Gaming Guild',
        description: 'Elite gamers squad for late night hangouts',
        creatorId: 'user_boss',
        creatorName: 'Boss Gamer',
        privacy: SocialCirclePrivacy.inviteOnly,
        memberCount: 2,
        tags: ['Gaming', 'Squad'],
        activeRoomId: 'room_123',
        activeRoomTitle: 'Nightly Battle',
        members: [
          SocialCircleMember(userId: 'user_boss', name: 'Boss Gamer', role: 'owner'),
          SocialCircleMember(userId: 'user_member', name: 'Member Pete', role: 'member'),
        ],
      );

      expect(circle.hasActiveHangout, isTrue);
      expect(circle.isUserMember('user_boss'), isTrue);
      expect(circle.isUserMember('user_member'), isTrue);
      expect(circle.isUserMember('random_user'), isFalse);
      expect(circle.isUserOwner('user_boss'), isTrue);
      expect(circle.isUserAdmin('user_boss'), isTrue);
      expect(circle.isUserOwner('user_member'), isFalse);

      final json = circle.toJson();
      final fromJson = SocialCircleModel.fromJson(json);
      expect(fromJson.id, 'circle_test_1');
      expect(fromJson.name, 'The Gaming Guild');
      expect(fromJson.privacy, SocialCirclePrivacy.inviteOnly);
      expect(fromJson.members.length, 2);
      expect(fromJson.members.first.isOwner, isTrue);
    });

    testWidgets('SocialCircleBadge renders name and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SocialCircleBadge(
                circleName: 'Night Owls Chill 🌙',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Night Owls Chill 🌙'), findsOneWidget);
    });

    testWidgets('SocialCircleSheet displays header, tabs, and circle cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialCircleSheet(
              currentUserId: 'test_user_1',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Social Circles'), findsOneWidget);
      expect(find.textContaining('My Circles'), findsOneWidget);
      expect(find.textContaining('Discover'), findsOneWidget);
      expect(find.text('Night Owls Chill 🌙'), findsOneWidget);
      expect(find.text('SQUAD LIVE HANGOUT'), findsOneWidget);
    });

    testWidgets('SocialCircleSheet switches to Discover tab and joins a circle', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialCircleSheet(
              currentUserId: 'test_user_1',
              currentUserName: 'Tester',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Discover tab
      final discoverTab = find.textContaining('Discover');
      await tester.tap(discoverTab);
      await tester.pumpAndSettle();

      // Verify discover circles are shown
      expect(find.text('Global Gaming Den 🎮'), findsOneWidget);

      // Tap Join on the first discover circle
      final joinButton = find.text('Join').first;
      await tester.tap(joinButton);
      await tester.pumpAndSettle();

      // SnackBar confirming join appears
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
