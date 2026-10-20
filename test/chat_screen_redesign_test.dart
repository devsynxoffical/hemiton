import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/features/messages/inbox_screen.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/messaging_provider.dart';
import 'package:hemiton/providers/social_provider.dart';

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

  group('InboxScreen Redesign with WhatsApp-Style Status & Chats Tests', () {
    testWidgets('Header displays Updates title, badge, camera, and search icons', (tester) async {
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

      // 1. Verify Top Header
      expect(find.text('Updates'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // 2. Verify Status section
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Share your day with friends'), findsOneWidget);
      expect(find.text('Add status'), findsOneWidget);
      expect(find.text('Hussnain'), findsOneWidget);
      expect(find.text('Abid Net'), findsOneWidget);

      // 3. Verify Chats section
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Your personal messages'), findsOneWidget);
      expect(find.text('Ayesha Khan'), findsOneWidget);
      expect(find.text('Hey! How are you?'), findsOneWidget);
      expect(find.text('Usman Ali'), findsOneWidget);
      expect(find.text('Okay, sure!'), findsOneWidget);
      expect(find.text('Sara Malik'), findsOneWidget);
      expect(find.text('Zain Ahmad'), findsOneWidget);

      // 4. Verify Channels section is completely absent
      expect(find.text('Channels'), findsNothing);
      expect(find.text('Find channels'), findsNothing);
      expect(find.text('Stay updated on topics'), findsNothing);
    });

    testWidgets('Tapping search icon toggles the search bar', (tester) async {
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

      expect(find.text('Search chats & friends...'), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();

      // Search bar now visible
      expect(find.text('Search chats & friends...'), findsOneWidget);
    });
  });
}
