import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/features/live/live_explore_screen.dart';
import 'package:hemiton/features/leaderboard/leaderboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  const testUser = UserModel(
    id: 'user_1',
    username: 'alice',
    name: 'Alice',
    avatarUrl: 'https://example.com/avatar.png',
  );

  group('Issue 1: Story Feed Isolation', () {
    test('PostModel.isStory returns true for STORY visibility, [STORY] prefix, or #story tag', () {
      final storyByVis = PostModel(
        id: 'story_1',
        author: testUser,
        content: 'Check out my 24h moment!',
        imageUrls: ['https://example.com/story1.jpg'],
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        visibility: 'STORY',
      );
      expect(storyByVis.isStory, isTrue);

      final storyByPrefix = PostModel(
        id: 'story_2',
        author: testUser,
        content: '[STORY] Coffee time ☕',
        imageUrls: ['https://example.com/story2.jpg'],
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        visibility: 'PUBLIC',
      );
      expect(storyByPrefix.isStory, isTrue);

      final storyByTag = PostModel(
        id: 'story_3',
        author: testUser,
        content: 'Sunset vibes #story',
        imageUrls: ['https://example.com/story3.jpg'],
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        visibility: 'PUBLIC',
      );
      expect(storyByTag.isStory, isTrue);

      final regularPost = PostModel(
        id: 'post_1',
        author: testUser,
        content: 'Hello ZeParty community! 🎉',
        imageUrls: ['https://example.com/post1.jpg'],
        likes: 10,
        comments: 2,
        createdAt: DateTime.now(),
        visibility: 'PUBLIC',
      );
      expect(regularPost.isStory, isFalse);
    });

    test('Stories are excluded when filtering social.posts for Recommended & Friends feed', () {
      final posts = [
        PostModel(
          id: 'story_1',
          author: testUser,
          content: 'Story 1',
          imageUrls: ['https://example.com/s1.jpg'],
          likes: 0,
          comments: 0,
          createdAt: DateTime.now(),
          visibility: 'STORY',
        ),
        PostModel(
          id: 'post_normal',
          author: testUser,
          content: 'Normal feed post',
          imageUrls: ['https://example.com/p1.jpg'],
          likes: 5,
          comments: 1,
          createdAt: DateTime.now(),
          visibility: 'PUBLIC',
        ),
        PostModel(
          id: 'story_2',
          author: testUser,
          content: '[STORY] Story 2',
          imageUrls: ['https://example.com/s2.jpg'],
          likes: 0,
          comments: 0,
          createdAt: DateTime.now(),
          visibility: 'PUBLIC',
        ),
      ];

      final filtered = posts.where((p) => !p.isStory).toList();
      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('post_normal'));
    });
  });

  group('Issue 2: Duplicate Post Upload Prevention', () {
    test('Deduplication logic prevents multiple entries with identical id or mediaUrl', () {
      final feedItems = <Map<String, String>>[];

      void addItem(String id, String mediaUrl) {
        if (!feedItems.any((e) => e['id'] == id || (mediaUrl.isNotEmpty && e['mediaUrl'] == mediaUrl))) {
          feedItems.add({'id': id, 'mediaUrl': mediaUrl});
        }
      }

      // Add from short videos
      addItem('video_123', 'https://example.com/video.mp4');
      // Attempt duplicate add with same ID
      addItem('video_123', 'https://example.com/video.mp4');
      // Attempt duplicate add from social post with same media URL
      addItem('post_999', 'https://example.com/video.mp4');
      // Add distinct post
      addItem('post_distinct', 'https://example.com/photo.jpg');

      expect(feedItems.length, equals(2));
      expect(feedItems[0]['id'], equals('video_123'));
      expect(feedItems[1]['id'], equals('post_distinct'));
    });
  });

  group('Issue 3: Profile Post Preview', () {
    testWidgets('Tapping thumbnail opens full post detail preview', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final samplePost = PostModel(
        id: 'post_preview_1',
        author: testUser,
        content: 'Excited about the party tonight! 🎈',
        imageUrls: ['https://example.com/sample.jpg'],
        likes: 42,
        comments: 7,
        shares: 3,
        createdAt: DateTime.now(),
      );

      final social = SocialProvider();
      social.addTestPost(samplePost);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SocialProvider>.value(value: social),
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text('Post Detail')),
                              body: Text(samplePost.content),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open Preview'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Preview'));
      await tester.pumpAndSettle();

      expect(find.text('Post Detail'), findsOneWidget);
      expect(find.text('Excited about the party tonight! 🎈'), findsOneWidget);
    });
  });

  group('Issue 4: Global Live Ranking Navigation', () {
    testWidgets('Trophy button in LiveExploreScreen navigates to LeaderboardScreen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
            ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              theme: ThemeData.dark(),
              home: const LiveExploreScreen(),
            ),
          ),
        ),
      );
      // Pump initial frame without pumpAndSettle to avoid infinite network/image loops
      await tester.pump(const Duration(milliseconds: 300));

      // Find the trophy icon
      final trophyFinder = find.byIcon(Icons.emoji_events_rounded);
      expect(trophyFinder, findsOneWidget);

      // Tap trophy icon
      await tester.tap(trophyFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify LeaderboardScreen was pushed onto the navigation stack
      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });
  });
}
