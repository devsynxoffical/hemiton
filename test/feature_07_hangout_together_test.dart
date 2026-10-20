import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/hangout_media_queue_model.dart';
import 'package:hemiton/widgets/hangout_together_sheet.dart';

void main() {
  group('Feature 07: Hangout Together Mode Tests', () {
    test('HangoutMediaItem model serialization and upvote toggle test', () {
      final item = HangoutMediaItem(
        id: 'track_1',
        videoId: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        addedById: 'user_1',
        addedByName: 'Rick',
        upvotedByUserIds: ['user_1'],
      );

      expect(item.upvoteCount, 1);
      expect(item.isUpvotedBy('user_1'), isTrue);
      expect(item.isUpvotedBy('user_2'), isFalse);

      // Toggle upvote by user_2 -> count should become 2
      final upvoted = item.toggleUpvote('user_2');
      expect(upvoted.upvoteCount, 2);
      expect(upvoted.isUpvotedBy('user_2'), isTrue);

      // Toggle user_1 off -> count becomes 1
      final unvoted = upvoted.toggleUpvote('user_1');
      expect(unvoted.upvoteCount, 1);
      expect(unvoted.isUpvotedBy('user_1'), isFalse);

      // JSON serialization
      final json = item.toJson();
      final fromJson = HangoutMediaItem.fromJson(json);
      expect(fromJson.id, 'track_1');
      expect(fromJson.videoId, 'dQw4w9WgXcQ');
      expect(fromJson.title, 'Never Gonna Give You Up');
      expect(fromJson.addedByName, 'Rick');
    });

    testWidgets('HangoutTogetherSheet renders header, now playing, and mixer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutTogetherSheet(
              currentUserId: 'me_1',
              currentUserName: 'Host Dave',
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hangout Together Mode'), findsOneWidget);
      expect(find.text('STREAMING LIVE'), findsOneWidget);
      expect(find.text('Audio Balance Mixer'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
      expect(find.text('Shared Queue'), findsOneWidget);
    });

    testWidgets('HangoutTogetherSheet upvoting reorders or increments count', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutTogetherSheet(
              currentUserId: 'me_1',
              currentUserName: 'Host Dave',
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find initial upvote buttons
      final upvoteButtons = find.byIcon(Icons.thumb_up_alt_outlined);
      expect(upvoteButtons, findsWidgets);

      await tester.ensureVisible(upvoteButtons.first);
      await tester.pumpAndSettle();

      // Tap the upvote button for Alex K's track
      await tester.tap(upvoteButtons.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify thumb up active icon appears
      expect(find.byIcon(Icons.thumb_up_alt_rounded), findsWidgets);
    });

    testWidgets('HangoutTogetherSheet add track via preset chip', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HangoutTogetherSheet(
              currentUserId: 'me_1',
              currentUserName: 'Host Dave',
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final presetChip = find.text('Lofi Chill Beats ☕');
      expect(presetChip, findsOneWidget);

      await tester.ensureVisible(presetChip);
      await tester.pumpAndSettle();

      await tester.tap(presetChip, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // SnackBar should appear confirming addition
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
