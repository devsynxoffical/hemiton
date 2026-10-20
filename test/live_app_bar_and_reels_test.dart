import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/features/live/live_explore_screen.dart';
import 'package:hemiton/features/social/moments_feed_screen.dart';
import 'package:hemiton/features/home/home_screen.dart';
import 'package:hemiton/features/messages/inbox_screen.dart';
import 'package:hemiton/widgets/glass_nav_bar.dart';

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
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44,
    0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F,
    0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00,
    0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Live App Bar Add Button & Popup Menu Tests', () {
    testWidgets('Live App Bar shows Live ✨, removes tagline, displays Add (+), Trophy, Search, Notification', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
            ChangeNotifierProvider(create: (_) => SocialProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: LiveExploreScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify "Live ✨" is removed from header per user requirement
      expect(find.text('Live'), findsNothing);

      // 2. Verify tagline is completely removed
      expect(find.text('Real People • Real Moments • Live Now'), findsNothing);

      // 3. Verify top action icons: Add (+) on the left, Trophy, Search, Notification on the right
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // Left Add (+) button
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget); // Golden trophy
      expect(find.byIcon(Icons.search_rounded), findsOneWidget); // Search
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget); // Notifications

      // 4. Tap the Add (+) button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      // 5. Verify Floating Popup Menu appears with 4 options: Go Live, Create Broadcast, Upload Video, Create Post
      expect(find.text('Go Live'), findsOneWidget);
      expect(find.text('Start a live session'), findsOneWidget);
      expect(find.text('Create Broadcast'), findsOneWidget);
      expect(find.text('Plan & share broadcast'), findsOneWidget);
      expect(find.text('Upload Video'), findsOneWidget);
      expect(find.text('Share video / reel'), findsOneWidget);
      expect(find.text('Create Post'), findsOneWidget);
      expect(find.text('Share photos & text'), findsOneWidget);
      expect(find.byIcon(Icons.sensors_rounded), findsWidgets);
      expect(find.byIcon(Icons.live_tv_rounded), findsOneWidget);
      expect(find.byIcon(Icons.video_library_rounded), findsOneWidget);
      expect(find.byIcon(Icons.post_add_rounded), findsOneWidget);
    });
  });

  group('GlassNavBar Games Navigation & Removed Center Plus Tests', () {
    testWidgets('GlassNavBar renders 5 tabs: Home, Live, Games, Chats, Profile; no center plus button', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int selected = 1;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              home: Scaffold(
                bottomNavigationBar: GlassNavBar(
                  selectedIndex: selected,
                  onTabSelected: (idx) => selected = idx,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify 5 navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // 2. Verify game controller icon for Games
      expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);

      // 3. Tap Games tab
      await tester.tap(find.text('Games'));
      expect(selected, 2);
    });
  });

  group('Full-Screen Moments / Reels UI Tests', () {
    testWidgets('MomentsFeedScreen displays For You | Following | Community with no extra categories or old tabs', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
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
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: MomentsFeedScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify only 3 categories in top transparent overlay
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);

      // 2. Verify removed extra categories and old tabs
      expect(find.text('Recommend'), findsNothing);
      expect(find.text('Moments'), findsNothing);
      expect(find.text('Friends'), findsNothing);
      expect(find.text('Trending'), findsNothing);

      // 3. Verify Anam reel content
      expect(find.text('Anam'), findsWidgets);
      expect(find.textContaining("Friend's Home"), findsWidgets);
      expect(find.textContaining('Hanging out with the squad in our party room tonight!'), findsOneWidget);
      expect(find.textContaining('Chill Vibes — The Night'), findsOneWidget);

      // 4. Verify right action panel controls
      expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsWidgets);
      expect(find.byIcon(Icons.send_rounded), findsWidgets);
      expect(find.byIcon(Icons.music_note_rounded), findsWidgets);

      // 5. Test Like toggle
      final likeBtn = find.byIcon(Icons.favorite_border_rounded).first;
      await tester.tap(likeBtn);
      await tester.pump();

      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);

      // 6. Test Switching Category Tab to "Community"
      await tester.tap(find.text('Community'));
      await tester.pump();
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('HomeScreen displays Recommend, Moments, Friends; Recommend shows Feed without Popular Live, and Moments shows Reels', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
            ChangeNotifierProvider(create: (_) => SocialProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: HomeScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify header tabs: Recommend, Moments, Friends
      expect(find.text('Recommend'), findsOneWidget);
      expect(find.text('Moments'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);

      // 2. On Recommend tab (initial): Popular Live is removed!
      expect(find.text('Popular Live'), findsNothing);

      // 3. Feeds are displayed directly with user posts, while Feed & View All headers are removed
      expect(find.text('Feed'), findsNothing);
      expect(find.text('View All'), findsNothing);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('Zainab'), findsWidgets);

      // 4. Tap Moments tab in header
      await tester.tap(find.text('Moments'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 5. Verify Moments shows 3 categories: For You | Following | Community
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
    });

    testWidgets('InboxScreen displays Chats header, LIVE buttons on cards, and chat rows', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MessagingProvider()),
            ChangeNotifierProvider(create: (_) => SocialProvider()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => const MaterialApp(
              home: InboxScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify Chats & Friends tabs
      expect(find.text('Chats'), findsWidgets);
      expect(find.text('Friends'), findsOneWidget);

      // 2. Verify LIVE badges on top cards
      expect(find.text('LIVE'), findsWidgets);
      expect(find.text('suman'), findsOneWidget);
      expect(find.text('MK KHAN'), findsOneWidget);

      // 3. Verify chats list
      expect(find.text('Mr.Shehryar'), findsOneWidget);
    });
  });
}
