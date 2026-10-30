import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/features/home/live_home_screen.dart';
import 'package:hemiton/widgets/glass_nav_bar.dart';

import 'package:hemiton/models/user_model.dart';

// 1x1 transparent png for test mocks
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
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  Widget createTestWidget(Widget child, {AuthProvider? authProvider}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => authProvider ?? AuthProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) {
          return MaterialApp(
            home: child,
          );
        },
      ),
    );
  }

  group('New Live Home Screen & Explore UI Tests', () {
    testWidgets('LiveHomeScreen renders Top Bar, 3 Mode Pills, and Live Now Hero', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final auth = AuthProvider();
      auth.mockSetCurrentUser(const UserModel(
        id: 'female_user',
        username: 'sara_khan',
        name: 'Sara Khan',
        gender: 'Female',
        avatarUrl: '',
      ));

      await tester.pumpWidget(createTestWidget(const LiveHomeScreen(), authProvider: auth));
      await tester.pumpAndSettle();

      // 1. Verify Top Bar: Header LIVE text badge, Search, Bell, no 'Hangout' text
      expect(find.text('LIVE'), findsWidgets);
      expect(find.byIcon(Icons.search_rounded), findsWidgets);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('Hangout'), findsNothing);

      // Verify bottom-right floating create button for female creator
      expect(find.byKey(const ValueKey('live_floating_create_button')), findsOneWidget);
      expect(find.text('Daily Live'), findsWidgets);

      // 2. Verify 3 Mode Switcher Pills
      expect(find.text('Daily Live'), findsWidgets);
      expect(find.text('Group Live'), findsOneWidget);
      expect(find.text('Video Live'), findsOneWidget);

      // 3. Verify Image 1 Section: "Live Now" with "Watch Live"
      expect(find.text('Live Now'), findsOneWidget);
      expect(find.text('Sana Malik'), findsWidgets);
      expect(find.text('Watch Live'), findsOneWidget);
      expect(find.text('Ali Raza'), findsWidgets);
      expect(find.text('Maya Queen'), findsWidgets);

      // 4. Verify Trending Live Section
      expect(find.text('Trending Live'), findsOneWidget);
      expect(find.text('Zain Khan'), findsWidgets);
    });

    testWidgets('Daily Live Create Button is hidden for male users and shown for female users', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Male User
      final maleAuth = AuthProvider();
      maleAuth.mockSetCurrentUser(const UserModel(
        id: 'male_user',
        username: 'ali_khan',
        name: 'Ali Khan',
        gender: 'Male',
        avatarUrl: '',
      ));

      await tester.pumpWidget(createTestWidget(const LiveHomeScreen(), authProvider: maleAuth));
      await tester.pumpAndSettle();

      // Male cannot see Daily Live floating create button
      expect(find.byKey(const ValueKey('live_floating_create_button')), findsNothing);

      // Group Live tab: Male CAN see Group Live create button
      await tester.tap(find.text('Group Live'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('live_floating_create_button')), findsOneWidget);

      // Video Live tab: Male CAN see Video Live create button
      await tester.tap(find.text('Video Live'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('live_floating_create_button')), findsOneWidget);
    });

    testWidgets('LiveHomeScreen switches to Group Live mode (Image 3)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const LiveHomeScreen()));
      await tester.pumpAndSettle();

      // Tap 'Group Live'
      await tester.tap(find.text('Group Live'));
      await tester.pumpAndSettle();

      // Verify Group Live items from Image 3
      expect(find.text('Friends Forever'), findsOneWidget);
      expect(find.text('Chill Vibes'), findsOneWidget);
      expect(find.text('Talent Show'), findsOneWidget);
      expect(find.text('Open Talk'), findsOneWidget);
      expect(find.text('PK Battle'), findsOneWidget);
      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('LiveHomeScreen switches to Video Live mode (Image 4)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(const LiveHomeScreen()));
      await tester.pumpAndSettle();

      // Tap 'Video Live'
      await tester.tap(find.text('Video Live'));
      await tester.pumpAndSettle();

      // Verify Video Live items from Image 4
      expect(find.text('Nida Sheikh'), findsOneWidget);
      expect(find.text('Rohan'), findsOneWidget);
      expect(find.text('Hira Khan'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('GlassNavBar renders Home, Explore, Center Plus, Inbox, Profile', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int selected = 0;
      bool createPressed = false;

      await tester.pumpWidget(
        createTestWidget(
          Scaffold(
            bottomNavigationBar: GlassNavBar(
              selectedIndex: selected,
              onTabSelected: (idx) => selected = idx,
              onCreatePressed: () => createPressed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify navigation labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // 2. Verify Games icon
      expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);

      // 3. Tap Explore tab
      await tester.tap(find.text('Explore'));
      expect(selected, 1);

      // 4. Tap Games tab
      await tester.tap(find.text('Games'));
      expect(selected, 2);
    });
  });
}
