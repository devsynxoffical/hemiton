import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/friend_live_notification_model.dart';
import 'package:hemiton/widgets/friend_live_banner.dart';

void main() {
  group('Feature 13: Someone You Know Is Live Tests', () {
    test('FriendLiveAlert model serialization', () {
      final now = DateTime(2026, 10, 19);
      final alert = FriendLiveAlert(
        friendId: 'f_10',
        friendName: 'Aria Vance',
        relationshipBadge: 'Bestie 💖',
        roomId: 'room_99',
        roomTitle: 'Gaming & Lofi Chill',
        friendAvatar: 'https://images.unsplash.com/photo-1534528741775',
        viewerCount: 42,
        startedAt: now,
      );

      expect(alert.friendId, 'f_10');
      expect(alert.friendName, 'Aria Vance');
      expect(alert.relationshipBadge, 'Bestie 💖');
      expect(alert.roomTitle, 'Gaming & Lofi Chill');
      expect(alert.viewerCount, 42);

      final json = alert.toJson();
      final fromJson = FriendLiveAlert.fromJson(json);
      expect(fromJson.friendId, 'f_10');
      expect(fromJson.friendName, 'Aria Vance');
      expect(fromJson.relationshipBadge, 'Bestie 💖');
      expect(fromJson.roomTitle, 'Gaming & Lofi Chill');
    });

    testWidgets('FriendLiveBanner renders friend info, room title, and join action', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      bool joinClicked = false;
      final alert = FriendLiveAlert(
        friendId: 'f_10',
        friendName: 'Aria Vance',
        relationshipBadge: 'Bestie 💖',
        roomId: 'room_99',
        roomTitle: 'Gaming & Lofi Chill',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendLiveBanner(
              alert: alert,
              onJoin: () => joinClicked = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aria Vance'), findsOneWidget);
      expect(find.text('Bestie 💖'), findsOneWidget);
      expect(find.text('Hanging out in "Gaming & Lofi Chill"'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);

      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();

      expect(joinClicked, isTrue);
    });

    testWidgets('FriendLiveBanner dismiss button hides the banner', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      bool dismissed = false;
      final alert = FriendLiveAlert(
        friendId: 'f_10',
        friendName: 'Aria Vance',
        relationshipBadge: 'Bestie 💖',
        roomId: 'room_99',
        roomTitle: 'Gaming & Lofi Chill',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FriendLiveBanner(
              alert: alert,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final closeBtn = find.byIcon(Icons.close_rounded);
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('Aria Vance'), findsNothing);
    });
  });
}
