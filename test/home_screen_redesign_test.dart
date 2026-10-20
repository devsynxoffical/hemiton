import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/widgets/story_viewer_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StoryService Tests', () {
    test('hasActiveStory returns true for demo users (Zainab, Mrs manson, suman)', () {
      final service = StoryService.instance;
      expect(service.hasActiveStory(userId: 'u_zainab', userName: 'Zainab'), isTrue);
      expect(service.hasActiveStory(userId: 'u_manson', userName: 'Mrs manson'), isTrue);
      expect(service.hasActiveStory(userId: 'u_suman', userName: 'suman'), isTrue);
      expect(service.hasActiveStory(userId: 'u_riya', userName: '🌸🌸riya🌸🌸'), isTrue);
      expect(service.hasActiveStory(userId: 'u_unknown_random', userName: 'random_nonexistent_user'), isFalse);
    });

    test('getActiveStoriesForUser returns correct active stories for Zainab', () {
      final service = StoryService.instance;
      final stories = service.getActiveStoriesForUser(userId: 'u_zainab', userName: 'Zainab');
      expect(stories.isNotEmpty, isTrue);
      expect(stories.length, 2);
      expect(stories.first.userName, 'Zainab');
      expect(stories.first.mediaUrl, contains('unsplash.com'));
    });

    test('getActiveStoriesForUser recognizes real active story from backend posts list', () {
      final service = StoryService.instance;
      const customUser = UserModel(
        id: 'user_real_999',
        username: 'real_artist',
        name: 'Real Artist',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final realStoryPost = PostModel(
        id: 'post_story_123',
        author: customUser,
        content: '[STORY] Hello from my studio!',
        imageUrls: const ['https://example.com/story.jpg'],
        likes: 10,
        comments: 2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        visibility: 'STORY',
      );

      final stories = service.getActiveStoriesForUser(
        userId: 'user_real_999',
        userName: 'Real Artist',
        allPosts: [realStoryPost],
      );

      expect(stories.length, 1);
      expect(stories.first.id, 'post_story_123');
      expect(stories.first.caption, 'Hello from my studio!');
    });

    test('Expired story (>24h) is not recognized as active story', () {
      final service = StoryService.instance;
      const customUser = UserModel(
        id: 'user_expired_1',
        username: 'expired_user',
        name: 'Expired User',
        avatarUrl: '',
      );

      final oldStoryPost = PostModel(
        id: 'post_old_story',
        author: customUser,
        content: '[STORY] Yesterday story',
        imageUrls: const ['https://example.com/old.jpg'],
        likes: 5,
        comments: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 26)),
        visibility: 'STORY',
      );

      final hasStory = service.hasActiveStory(
        userId: 'user_expired_1',
        userName: 'Expired User',
        allPosts: [oldStoryPost],
      );

      expect(hasStory, isFalse);
    });
  });

  group('StoryViewerScreen Navigation and Gesture Tests', () {
    testWidgets('StoryViewer displays stories with progress bars, user header, and close button', (tester) async {
      final testStories = [
        StoryItem(
          id: 'test_1',
          userId: 'u1',
          userName: 'Tester',
          userAvatar: '',
          mediaUrl: '',
          caption: 'Testing story 1',
          createdAt: DateTime.now(),
        ),
        StoryItem(
          id: 'test_2',
          userId: 'u1',
          userName: 'Tester',
          userAvatar: '',
          mediaUrl: '',
          caption: 'Testing story 2',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: StoryViewerScreen(stories: testStories),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify username and caption are displayed
      expect(find.text('Tester'), findsOneWidget);
      expect(find.text('Testing story 1'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Verify reply input exists
      expect(find.text('Reply to Tester...'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });
  });
}
