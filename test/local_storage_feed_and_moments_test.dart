import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hemiton/core/services/local_media_service.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/models/short_video_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/core/repositories/backend_repository.dart';
import 'package:hemiton/features/home/home_screen.dart';
import 'package:hemiton/features/social/upload_video_screen.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/wallet_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/widgets/story_viewer_dialog.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  group('1. LocalMediaService Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hemiton_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Saves media file to persistent directory and verifies existence', () async {
      final sampleFile = File('${tempDir.path}/sample_picker_image.png');
      await sampleFile.writeAsString('sample_png_bytes_data');

      final savedPath = await LocalMediaService.instance.saveMediaFile(
        sampleFile.path,
        subFolder: 'posts',
      );

      expect(savedPath, isNotNull);
      final savedFile = File(savedPath);
      expect(await savedFile.exists(), isTrue);
      expect(await savedFile.readAsString(), equals('sample_png_bytes_data'));
      expect(savedPath.contains('hemiton_persistent_media'), isTrue);
      expect(savedPath.contains('posts'), isTrue);

      // Verify deletion
      await LocalMediaService.instance.deleteMediaFile(savedPath);
      expect(await savedFile.exists(), isFalse);
    });

    test('Gracefully throws FileSystemException on nonexistent source files', () async {
      final invalidPath = '${tempDir.path}/non_existent_file_xyz.jpg';
      expect(
        () => LocalMediaService.instance.saveMediaFile(
          invalidPath,
          subFolder: 'stories',
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('Helper isLocalPath correctly identifies local files vs URLs', () {
      expect(LocalMediaService.instance.isLocalPath('https://example.com/pic.jpg'), isFalse);
      expect(LocalMediaService.instance.isLocalPath('http://cdn.com/vid.mp4'), isFalse);
      expect(LocalMediaService.instance.isLocalPath('C:\\Users\\test\\media.jpg'), isTrue);
      expect(LocalMediaService.instance.isLocalPath('/data/user/0/app/media.jpg'), isTrue);
    });
  });

  group('2. PostModel & ShortVideoModel Serialization Tests', () {
    test('PostModel round-trip JSON serialization preserves all metadata', () {
      const author = UserModel(
        id: 'u_123',
        name: 'Alice Wonder',
        username: 'alice',
        avatarUrl: 'https://example.com/avatar.jpg',
        region: 'Lahore',
      );

      final post = PostModel(
        id: 'post_test_999',
        author: author,
        content: 'Check out my persistent post! #hemiton',
        imageUrls: ['/persistent/path/image1.jpg'],
        likes: 42,
        comments: 7,
        shares: 3,
        isLiked: true,
        createdAt: DateTime(2026, 10, 22, 12, 0),
        visibility: 'PUBLIC',
      );

      final jsonMap = post.toJson();
      final restored = PostModel.fromJson(jsonMap);

      expect(restored.id, equals('post_test_999'));
      expect(restored.author.id, equals('u_123'));
      expect(restored.author.name, equals('Alice Wonder'));
      expect(restored.content, equals('Check out my persistent post! #hemiton'));
      expect(restored.imageUrls, contains('/persistent/path/image1.jpg'));
      expect(restored.likes, equals(42));
      expect(restored.comments, equals(7));
      expect(restored.shares, equals(3));
      expect(restored.isLiked, isTrue);
      expect(restored.visibility, equals('PUBLIC'));
    });

    test('ShortVideoModel round-trip JSON serialization preserves all metadata', () {
      const creator = UserModel(
        id: 'u_creator_55',
        name: 'Video Master',
        username: 'videomaster',
        avatarUrl: 'https://example.com/c.jpg',
      );

      final video = ShortVideoModel(
        id: 'video_test_101',
        creator: creator,
        videoUrl: '/persistent/path/clip.mp4',
        caption: 'Epic sunset moment 🔥',
        musicTitle: 'Sunset Beats',
        likes: 120,
        comments: 15,
        gifts: 8,
        isLiked: true,
      );

      final jsonMap = video.toJson();
      final restored = ShortVideoModel.fromJson(jsonMap);

      expect(restored.id, equals('video_test_101'));
      expect(restored.creator.id, equals('u_creator_55'));
      expect(restored.videoUrl, equals('/persistent/path/clip.mp4'));
      expect(restored.caption, equals('Epic sunset moment 🔥'));
      expect(restored.musicTitle, equals('Sunset Beats'));
      expect(restored.likes, equals(120));
      expect(restored.comments, equals(15));
      expect(restored.gifts, equals(8));
      expect(restored.isLiked, isTrue);
    });
  });

  group('3. SocialProvider Persistence & Round-Trip Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('createPost persists to SharedPreferences and survives re-initialization', () async {
      final provider = SocialProvider();

      // Create a local post
      const testAuthor = UserModel(
        id: 'local_user_1',
        name: 'Local Creator',
        username: 'localcreator',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      await provider.createPost(
        content: 'Local persistent post test content',
        mediaUrls: ['/persistent/media/photo.jpg'],
        visibility: 'PUBLIC',
        author: testAuthor,
      );

      // Verify immediate shared state update
      expect(provider.posts.isNotEmpty, isTrue);
      expect(provider.posts.first.content, equals('Local persistent post test content'));
      expect(provider.posts.first.imageUrls, contains('/persistent/media/photo.jpg'));

      // Verify SharedPreferences contains the serialized post
      final prefs = await SharedPreferences.getInstance();
      final savedRaw = prefs.getString('hemiton_local_posts_v1');
      expect(savedRaw, isNotNull);
      final decoded = jsonDecode(savedRaw!) as List;
      expect(decoded.length, greaterThanOrEqualTo(1));
      expect(decoded.first['content'], equals('Local persistent post test content'));

      // Simulate App Restart by instantiating a new SocialProvider
      final restoredProvider = SocialProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(restoredProvider.posts.isNotEmpty, isTrue);
      expect(restoredProvider.posts.first.content, equals('Local persistent post test content'));
      expect(restoredProvider.posts.first.imageUrls, contains('/persistent/media/photo.jpg'));
    });
  });

  group('4. BackendRepository & Moments Reels Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('publishVideo persists to SharedPreferences and updates shortVideos', () async {
      const creator = UserModel(
        id: 'reels_author_1',
        name: 'Reel Star',
        username: 'reelstar',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final published = await BackendRepository.instance.publishVideo(
        id: 'reel_persistent_test_01',
        creator: creator,
        videoUrl: '/persistent/videos/test_reel.mp4',
        caption: 'Fresh Moment Reel Uploaded Locally',
        musicTitle: 'Original Audio',
      );

      expect(published.id, equals('reel_persistent_test_01'));
      expect(BackendRepository.instance.shortVideos.any((v) => v.id == 'reel_persistent_test_01'), isTrue);

      // Verify SharedPreferences persistence
      final prefs = await SharedPreferences.getInstance();
      final savedVideosRaw = prefs.getString('hemiton_local_short_videos_v1');
      expect(savedVideosRaw, isNotNull);
      final decoded = jsonDecode(savedVideosRaw!) as List;
      expect(decoded.any((item) => item['id'] == 'reel_persistent_test_01'), isTrue);
    });
  });

  group('5. Story 24h Expiry & Query Tests', () {
    test('StoryService filters expired stories (>24h) and returns active stories (<24h)', () {
      final now = DateTime.now();
      final activeStoryPost = PostModel(
        id: 'story_active_01',
        author: const UserModel(
          id: 'story_user_1',
          name: 'Story User',
          username: 'storyuser',
          avatarUrl: 'https://example.com/u1.jpg',
        ),
        content: '[STORY] Active story post today!',
        imageUrls: ['/persistent/stories/story_img.jpg'],
        likes: 5,
        comments: 0,
        createdAt: now.subtract(const Duration(hours: 4)),
        visibility: 'STORY',
      );

      final expiredStoryPost = PostModel(
        id: 'story_expired_02',
        author: const UserModel(
          id: 'story_user_1',
          name: 'Story User',
          username: 'storyuser',
          avatarUrl: 'https://example.com/u1.jpg',
        ),
        content: '[STORY] Expired story from yesterday',
        imageUrls: ['/persistent/stories/expired_img.jpg'],
        likes: 12,
        comments: 1,
        createdAt: now.subtract(const Duration(hours: 26)), // 26 hours ago!
        visibility: 'STORY',
      );

      final posts = [activeStoryPost, expiredStoryPost];

      final activeStories = StoryService.instance.getActiveStoriesForUser(
        userId: 'story_user_1',
        userName: 'Story User',
        allPosts: posts,
      );

      expect(activeStories.length, equals(1));
      expect(activeStories.first.id, equals('story_active_01'));
      expect(activeStories.first.mediaUrl, equals('/persistent/stories/story_img.jpg'));
    });
  });

  group('6. Moments Post Button Navigation Test', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Moments tab displays Post button which navigates to UploadVideoScreen', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => SocialProvider()),
            ChangeNotifierProvider(create: (_) => WalletProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: HomeScreen(),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // On Recommend tab (0), moments post button should NOT exist
      expect(find.byKey(const ValueKey('moments_header_post_button')), findsNothing);

      // Switch to Moments tab (1)
      final momentsTabFinder = find.byKey(const ValueKey('header_tab_1'));
      expect(momentsTabFinder, findsOneWidget);
      await tester.tap(momentsTabFinder);
      await tester.pump(const Duration(milliseconds: 350));

      // Moments Post button MUST now be visible in the header
      final momentsPostBtnFinder = find.byKey(const ValueKey('moments_header_post_button'));
      expect(momentsPostBtnFinder, findsOneWidget);
      expect(find.text('Post'), findsOneWidget);

      // Tap Moments Post button
      await tester.tap(momentsPostBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that UploadVideoScreen opened (NOT CreatePostScreen)
      expect(find.byType(UploadVideoScreen), findsOneWidget);
      expect(find.text('Post Video'), findsOneWidget);
      expect(find.text('POST VIDEO NOW'), findsOneWidget);
    });
  });
}
