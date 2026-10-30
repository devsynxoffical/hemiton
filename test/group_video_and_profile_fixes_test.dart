import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/features/party_room/group_video_party_room_screen.dart';
import 'package:hemiton/features/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    void Function(List<int>)? onData, {
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

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  testWidgets('GroupVideoPartyRoomScreen renders video seats grid and controls', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final host = const UserModel(
      id: 'host_101',
      username: 'host_test',
      name: 'Host Alex',
      avatarUrl: 'https://example.com/avatar.jpg',
      region: 'Global',
    );
    final room = LiveRoomModel(
      id: 'video_room_1',
      title: 'Squad Video Live',
      host: host,
      coverUrl: 'https://example.com/cover.jpg',
      viewerCount: 250,
      category: 'Party',
      startTime: DateTime.now(),
      roomType: 'LIVE_VIDEO',
      status: 'LIVE',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: GroupVideoPartyRoomScreen(room: room, isHost: true),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title and Host badge
    expect(find.text('Squad Video Live'), findsOneWidget);
    expect(find.text('HOST'), findsOneWidget);

    // Verify empty video seat indicator
    expect(find.byIcon(Icons.videocam_outlined), findsWidgets);
    expect(find.textContaining('Seat 4'), findsOneWidget);

    // Verify bottom control bar controls (mic, outside chat, games, frame, gift, share)
    expect(find.byIcon(Icons.mic_rounded), findsWidgets);
    expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);
    expect(find.byIcon(Icons.military_tech_rounded), findsOneWidget);
    expect(find.text('🎁'), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('ProfileScreen dropdown has no Hide/Unhide text and TabBar has Photos and Videos', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      ),
    );

    await tester.pump();

    // Ensure Hide/Unhide text does NOT exist
    expect(find.text('Hide'), findsNothing);
    expect(find.text('Unhide'), findsNothing);

    // Ensure Services & Tools dropdown header exists
    expect(find.text('Services & Tools'), findsOneWidget);

    // Ensure TabBar has Photos and Videos
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
  });
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}
