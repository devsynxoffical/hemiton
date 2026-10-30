import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/features/home/home_screen.dart';
import 'package:hemiton/features/social/moments_feed_screen.dart';
import 'package:hemiton/widgets/level_and_trophy_sheet.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  static final _kTransparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
    0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_kTransparentImage).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('Phase 2 User Requests Verification Tests', () {
    testWidgets('1. HomeScreen uses PageView allowing swipe-to-slide between Recommend, Moments, and Friends', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify header tabs are rendered
      expect(find.text('Recommend'), findsOneWidget);
      expect(find.text('Moments'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);

      // Verify PageView is present
      expect(find.byType(PageView), findsWidgets);

      // Perform horizontal swipe gesture to slide from Recommend to Moments
      await tester.drag(find.byType(PageView).first, const Offset(-600, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify MomentsFeedScreen is rendered
      expect(find.byType(MomentsFeedScreen), findsOneWidget);
    });

    testWidgets('2. MomentsFeedScreen filters out photo-only posts so only video reels appear', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final socialProvider = SocialProvider();
      // Add a photo-only post and a video post
      socialProvider.addTestPost(
        PostModel(
          id: 'photo_only_post',
          author: const UserModel(id: 'u1', username: 'user1', name: 'User 1', avatarUrl: ''),
          content: 'Just a photo moment',
          imageUrls: ['https://example.com/photo.jpg'],
          likes: 10,
          comments: 2,
          createdAt: DateTime.now(),
        ),
      );
      socialProvider.addTestPost(
        PostModel(
          id: 'video_post',
          author: const UserModel(id: 'u2', username: 'user2', name: 'User 2', avatarUrl: ''),
          content: 'Cool video #video',
          imageUrls: ['https://example.com/video.mp4'],
          likes: 25,
          comments: 5,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider.value(value: socialProvider),
          ],
          child: ScreenUtilInit(
            designSize: const Size(393, 852),
            builder: (context, _) => const MaterialApp(
              home: Scaffold(
                body: MomentsFeedScreen(isEmbeddedInHome: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Photo-only post should NOT be rendered in reels
      expect(find.text('Just a photo moment'), findsNothing);
    });

    testWidgets('3. LevelAndTrophySheet renders current level, trophy icon, XP progress and perks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, _) => const MaterialApp(
            home: Scaffold(
              body: LevelAndTrophySheet(
                currentLevel: 12,
                currentXp: 3840,
                targetXp: 5000,
                rankNumber: 12,
                streamerName: 'Ayesha Live',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Level 12'), findsOneWidget);
      expect(find.text('3840 / 5000 XP'), findsOneWidget);
      expect(find.text('Rank #12'), findsOneWidget);
      expect(find.text('Daily XP Tasks'), findsOneWidget);
      expect(find.text('Current Level Perks'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsWidgets);
    });
  });
}
