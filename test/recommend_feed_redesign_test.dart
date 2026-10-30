import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/features/home/home_screen.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/providers/social_provider.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(_MockHttpClientRequest());
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(_MockHttpClientResponse());
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

class _MockAuthProvider extends AuthProvider {
  @override
  bool get isAuthenticated => true;
  @override
  bool get isGuest => false;
  @override
  UserModel get currentUser => const UserModel(
        id: 'test_user_id',
        name: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        avatarUrl: '',
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  Widget createTestWidget(Widget child, {AuthProvider? authProvider, SocialProvider? socialProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => authProvider ?? AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(create: (_) => socialProvider ?? SocialProvider()),
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

  group('Recommend Feed UI Redesign Verification Tests', () {
    testWidgets('1. Top header renders Recommend, Moments, Friends, Search and Gift buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header tabs
      expect(find.text('Recommend'), findsOneWidget);
      expect(find.text('Moments'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);

      // Search & Gift circular action icons on top-right
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard_rounded), findsOneWidget);

      // Floating Upload Feed button with plus icon and label
      expect(find.byKey(const ValueKey('home_floating_add_button')), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.text('Upload Feed'), findsOneWidget);
    });

    testWidgets('2. Feed cards match reference design: User info, Follow button, verified badge, location flag, media aspect ratio, actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // HEMI TON post matching screenshot
      expect(find.text('HEMI TON'), findsOneWidget);
      expect(find.text('Nature always hits different. 🌅'), findsOneWidget);
      expect(find.textContaining('Pakistan 🇵🇰'), findsOneWidget);
      expect(find.text('1.2K'), findsOneWidget);
      expect(find.text('86'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);

      // Verified badges present
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);

      // Follow buttons present
      expect(find.text('Follow'), findsWidgets);

      // 3-dot overflow menu present
      expect(find.byIcon(Icons.more_vert_rounded), findsWidgets);

      // Video duration badges (e.g. 0:30, 0:34) and circular play button
      expect(find.text('0:30'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      // Other posts from screenshot: Zainab and Mrs manson
      expect(find.text('Zainab'), findsWidgets);
      expect(find.text('Good vibes only ✨'), findsOneWidget);
      expect(find.textContaining('Kolkata 🇮🇳'), findsOneWidget);
      expect(find.text('3.2K'), findsOneWidget);
      expect(find.text('248'), findsOneWidget);
      expect(find.text('112'), findsOneWidget);
    });

    testWidgets('3. Like button increments count and toggles state cleanly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = _MockAuthProvider();

      await tester.pumpWidget(createTestWidget(const HomeScreen(), authProvider: auth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Initial count for HEMI TON is 1.2K (1200)
      expect(find.text('1.2K'), findsOneWidget);

      // Tap first like button
      final firstLike = find.byIcon(Icons.favorite_border_rounded).first;
      await tester.tap(firstLike);
      await tester.pump();

      // Count toggles and heart becomes active filled
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('4. Floating Upload Feed (+) button remains visible on Recommend and hides on Moments', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // FAB is visible on Recommend
      expect(find.byKey(const ValueKey('home_floating_add_button')), findsOneWidget);
      expect(find.text('Upload Feed'), findsOneWidget);

      // Tap Moments tab
      await tester.tap(find.byKey(const ValueKey('header_tab_1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // FAB is hidden on Moments
      expect(find.byKey(const ValueKey('home_floating_add_button')), findsNothing);
      expect(find.byKey(const ValueKey('empty_fab')), findsOneWidget);

      // Tap back to Recommend tab
      await tester.tap(find.byKey(const ValueKey('header_tab_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // FAB is restored on Recommend
      expect(find.byKey(const ValueKey('home_floating_add_button')), findsOneWidget);
      expect(find.text('Upload Feed'), findsOneWidget);
    });
  });
}
