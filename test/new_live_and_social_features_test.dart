import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/social_provider.dart';
import 'package:hemiton/providers/live_party_provider.dart';
import 'package:hemiton/providers/room_overlay_provider.dart';
import 'package:hemiton/providers/emoji_reaction_provider.dart';
import 'package:hemiton/providers/live_gift_provider.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/models/post_model.dart';
import 'package:hemiton/features/live/live_room_screen.dart';
import 'package:hemiton/features/social/moments_feed_screen.dart';
import 'package:hemiton/features/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/core/config/app_config.dart';

final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = _TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Widget buildTestableWidget(Widget child, {SocialProvider? socialProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => socialProvider ?? SocialProvider()),
        ChangeNotifierProvider(create: (_) => LivePartyProvider()),
        ChangeNotifierProvider(create: (_) => RoomOverlayProvider()),
        ChangeNotifierProvider(create: (_) => EmojiReactionProvider()),
        ChangeNotifierProvider(create: (_) => LiveGiftProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('New Live & Social Features Verification', () {
    testWidgets('LiveRoomScreen has Mic Mute/Unmute toggle and Gift Button above send button', (tester) async {
      final mockRoom = LiveRoomModel(
        id: 'test_live_1',
        title: 'VIP Lounge',
        host: const UserModel(
          id: 'host_1',
          username: 'alia_khan',
          name: 'Alia Khan',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
        ),
        coverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
        viewerCount: 120,
        category: 'Talent',
        startTime: DateTime.now(),
      );

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(LiveRoomScreen(room: mockRoom, isHost: false)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify Image 1 bottom bar Gift button is present
      expect(find.text('🎁'), findsOneWidget);
      expect(find.text('Gift'), findsOneWidget);

      // 2. Verify 'More' (3-dots) is present in bottom bar
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // 3. Open More sheet and toggle Mic Mute/Unmute
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify toggled to mic off and SnackBar shown
      expect(find.text('Microphone Muted'), findsOneWidget);
    });

    testWidgets('MomentsFeedScreen strictly excludes status/story posts and renders TikTok action icons', (tester) async {
      final social = SocialProvider();
      social.addTestPost(
        PostModel(
          id: 'status_post_1',
          author: const UserModel(id: 'u1', username: 'user1', name: 'User 1', avatarUrl: ''),
          content: '[STORY] My exciting 24h story!',
          imageUrls: ['https://example.com/story.jpg'],
          likes: 10,
          comments: 2,
          createdAt: DateTime.now(),
          visibility: 'STORY',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(const MomentsFeedScreen(isEmbeddedInHome: true), socialProvider: social),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verify story caption does NOT appear in Moments reels
      expect(find.text('[STORY] My exciting 24h story!'), findsNothing);

      // Verify TikTok More (...) button is present
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('HomeScreen Recommended tab renders Facebook-style post card and actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(const HomeScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Facebook public globe icon is rendered in post header
      expect(find.byIcon(Icons.public_rounded), findsWidgets);

      // 2. Verify Facebook 3 action buttons: Like, Comment, Share
      expect(find.text('Like'), findsWidgets);
      expect(find.text('Comment'), findsWidgets);
      expect(find.text('Share'), findsWidgets);

      // 3. Verify Facebook multi-image collage '+N' overlay badge is present for 5-image demo post
      expect(find.text('+1'), findsOneWidget);
    });
  });
}
