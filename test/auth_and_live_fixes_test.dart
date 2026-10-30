import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/room_overlay_provider.dart';
import 'package:hemiton/features/live/widgets/broadcast_bottom_toolbar.dart';
import 'package:hemiton/features/live/widgets/broadcast_host_header.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  const testHost = UserModel(
    id: 'test_host_1',
    name: 'Sarah Connor',
    username: 'sarahc',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
  );

  final testRoom = LiveRoomModel(
    id: 'room_unit_test_999',
    title: 'Testing Live Room',
    host: testHost,
    coverUrl: '',
    viewerCount: 120,
    category: 'Music',
    startTime: DateTime.now(),
    roomType: 'AUDIO_LIVE',
  );

  group('Authentication Flow & Local Registry Tests', () {
    test('1. Signup creates new account and saves it to local registry', () async {
      final auth = AuthProvider();

      final success = await auth.signup(
        name: 'Alex Mercer',
        username: 'alexmercer',
        email: 'alex@example.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser.email, equals('alex@example.com'));
      expect(auth.currentUser.name, equals('Alex Mercer'));
    });

    test('2. Signup rejects duplicate email addresses', () async {
      final auth = AuthProvider();

      // First signup succeeds
      await auth.signup(
        name: 'User One',
        email: 'duplicate@example.com',
        password: 'password123',
      );

      // Second signup with same email fails
      final duplicateRes = await auth.signup(
        name: 'User Two',
        email: 'duplicate@example.com',
        password: 'differentPassword456',
      );

      expect(duplicateRes, isFalse);
      expect(auth.errorMessage, contains('already registered'));
    });

    test('3. Login verifies valid registered credentials', () async {
      final auth = AuthProvider();

      // Register an account first
      await auth.signup(
        name: 'Bob Builder',
        username: 'bobbuilder',
        email: 'bob@builder.com',
        password: 'mySecretPassword',
      );
      await auth.logout();
      expect(auth.isAuthenticated, isFalse);

      // Login with correct credentials
      final loginSuccess = await auth.login('bob@builder.com', 'mySecretPassword');
      expect(loginSuccess, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser.name, equals('Bob Builder'));
    });

    test('4. Login displays clear error for incorrect password', () async {
      final auth = AuthProvider();

      // Register account
      await auth.signup(
        name: 'Charlie Brown',
        username: 'charlieb',
        email: 'charlie@brown.com',
        password: 'correctPassword',
      );
      await auth.logout();

      // Login with wrong password
      final loginFail = await auth.login('charlie@brown.com', 'wrongPassword123');
      expect(loginFail, isFalse);
      expect(auth.errorMessage, equals('Incorrect password. Please try again.'));
    });

    test('5. Login displays clear error for unregistered user', () async {
      final auth = AuthProvider();

      final result = await auth.login('nonexistent_user@nobody.com', 'password123');
      expect(result, isFalse);
      expect(auth.errorMessage, contains('No account found for'));
    });
  });

  group('Live Broadcast UI & Floating Window Tests', () {
    testWidgets('6. BroadcastBottomToolbar renders input without black container & has functional send button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 200));

      final textController = TextEditingController();
      bool sendTriggered = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BroadcastBottomToolbar(
            textController: textController,
            isAudioMode: true,
            isMuted: false,
            onSendMessage: () {
              sendTriggered = true;
            },
            onEmojiTap: () {},
            onMicToggle: () {},
            onGiftsTap: () {},
            onSoundToggle: () {},
            onMoreTap: () {},
          ),
        ),
      ));
      await tester.pump();

      // Verify "Type a message..." hint is present
      expect(find.text('Type a message...'), findsOneWidget);

      // Verify Send icon button (Icons.send_rounded) is present
      final sendFinder = find.byIcon(Icons.send_rounded);
      expect(sendFinder, findsOneWidget);

      // Type text into field and tap send
      textController.text = 'Hello everyone in the live room!';
      await tester.tap(sendFinder);
      await tester.pump();

      expect(sendTriggered, isTrue);
    });

    testWidgets('7. BroadcastHostHeader renders minimize arrow button and triggers onMinimize callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 200));

      bool minimized = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BroadcastHostHeader(
            room: testRoom,
            isAudioMode: true,
            onBack: () {},
            onMore: () {},
            onMinimize: () {
              minimized = true;
            },
          ),
        ),
      ));
      await tester.pump();

      // Verify minimize button is rendered
      final minimizeFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
      expect(minimizeFinder, findsOneWidget);

      // Tap minimize
      await tester.tap(minimizeFinder);
      await tester.pump();

      expect(minimized, isTrue);
    });

    test('8. RoomOverlayProvider activates floating overlay for live room and expands cleanly', () {
      final overlay = RoomOverlayProvider();

      expect(overlay.isMinimized, isFalse);

      // Minimize live broadcast as host
      overlay.minimizeRoom(
        roomType: 'BROADCAST',
        room: testRoom,
        isHost: true,
        isAudioMode: true,
      );

      expect(overlay.isMinimized, isTrue);
      expect(overlay.isHost, isTrue);
      expect(overlay.isAudioMode, isTrue);
      expect(overlay.activeRoom?.id, equals(testRoom.id));

      // Expand overlay restores full screen mode
      overlay.expandRoom();
      expect(overlay.isMinimized, isFalse);
    });
  });
}
