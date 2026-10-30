import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/emoji_reaction_provider.dart';
import 'package:hemiton/providers/live_gift_provider.dart';
import 'package:hemiton/providers/live_party_provider.dart';
import 'package:hemiton/providers/live_provider.dart';
import 'package:hemiton/providers/room_overlay_provider.dart';
import 'package:hemiton/providers/wallet_provider.dart';

import 'package:hemiton/features/live/create_broadcast_screen.dart';
import 'package:hemiton/features/live/live_broadcast_screen.dart';
import 'package:hemiton/features/live/widgets/broadcast_host_header.dart';
import 'package:hemiton/features/live/widgets/broadcast_audio_area.dart';
import 'package:hemiton/features/live/widgets/broadcast_video_area.dart';
import 'package:hemiton/features/live/widgets/broadcast_gifters_section.dart';
import 'package:hemiton/features/live/widgets/broadcast_bottom_toolbar.dart';

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

class _TestLiveProvider extends LiveProvider {
  @override
  Future<void> joinRoom(LiveRoomModel room, {UserModel? currentUser}) async {
    // No-op for broadcast UI layout test to avoid unhandled network timers
  }
}

class _TestLiveGiftProvider extends LiveGiftProvider {
  @override
  Future<void> fetchCatalog({String? category, bool refresh = false}) async {
    // No-op for broadcast UI layout test to avoid unhandled network timers
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    HttpOverrides.global = _MockHttpOverrides();
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  const testHost = UserModel(
    id: 'host_ayesha_1',
    name: 'Ayesha Live',
    username: 'ayeshalive',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
  );

  final testAudioRoom = LiveRoomModel(
    id: 'room_audio_101',
    title: 'Ayesha Live Vocal Room',
    host: testHost,
    coverUrl: '',
    viewerCount: 2800,
    category: 'Music',
    startTime: DateTime.now(),
    roomType: 'AUDIO_LIVE',
  );

  final testVideoRoom = LiveRoomModel(
    id: 'room_video_102',
    title: 'Ayesha Official Video Stream',
    host: testHost,
    coverUrl: '',
    viewerCount: 2800,
    category: 'Live',
    startTime: DateTime.now(),
    roomType: 'LIVE_VIDEO',
  );

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LiveProvider>(create: (_) => _TestLiveProvider()),
        ChangeNotifierProvider(create: (_) => LivePartyProvider()),
        ChangeNotifierProvider<LiveGiftProvider>(create: (_) => _TestLiveGiftProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => EmojiReactionProvider()),
        ChangeNotifierProvider(create: (_) => RoomOverlayProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(450, 950),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('Broadcast Integration UI Tests', () {
    testWidgets('1. CreateBroadcastScreen renders both Audio Live and Video Live broadcast options', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 950));
      await tester.pumpWidget(createTestWidget(const CreateBroadcastScreen()));
      await tester.pump();

      // Verify the two broadcast options exist
      expect(find.text('Select Broadcast Mode'), findsOneWidget);
      expect(find.text('Video Live'), findsOneWidget);
      expect(find.text('Audio Live'), findsOneWidget);

      // Tap Audio Live option
      await tester.tap(find.text('Audio Live'));
      await tester.pump();

      // Verify title switches to Audio Hangout
      expect(find.text('🎙️ Late Night Chill & Audio Hangout'), findsOneWidget);

      // Tap Video Live option
      await tester.tap(find.text('Video Live'));
      await tester.pump();

      // Verify title switches to Video Hangout
      expect(find.text('✨ Late Night Melodies & Chill Hangout'), findsOneWidget);
    });

    testWidgets('2. BroadcastHostHeader renders profile, badges, Audio/Video label, and rank', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 400));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BroadcastHostHeader(
            room: testAudioRoom,
            isAudioMode: true,
            onBack: () {},
            onMore: () {},
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Ayesha Live'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      expect(find.text('Audio Live'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      expect(find.text('Rank 12'), findsOneWidget);
      expect(find.text('+12'), findsOneWidget);
      expect(find.text('2.8K'), findsOneWidget);
    });

    testWidgets('3. BroadcastAudioArea renders animated waveform, audio button, and Top Gifter card', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 400));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BroadcastAudioArea(
            room: testAudioRoom,
            topGifterName: 'Queen',
            topGifterGifts: 528,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Audio Broadcast'), findsOneWidget);
      expect(find.text('Top Gifter'), findsOneWidget);
      expect(find.text('Queen'), findsOneWidget);
      expect(find.text('x 528'), findsOneWidget);
    });

    testWidgets('4. BroadcastVideoArea renders camera container and floating Video Preview tile', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 400));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BroadcastVideoArea(
            room: testVideoRoom,
            isCameraInitialized: false,
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Video Preview'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_full_rounded), findsOneWidget);
    });

    testWidgets('5. BroadcastGiftersSection renders Top 2 Gifters and Other Gifters cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 450));

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BroadcastGiftersSection(),
        ),
      ));
      await tester.pump();

      expect(find.text('Top 2 Gifters'), findsOneWidget);
      expect(find.text('Queen'), findsOneWidget);
      expect(find.text('x 528'), findsOneWidget);
      expect(find.text('Hassan'), findsOneWidget);
      expect(find.text('x 342'), findsOneWidget);

      expect(find.text('Other Gifters'), findsOneWidget);
      expect(find.text('+12'), findsOneWidget);
    });

    testWidgets('6. BroadcastBottomToolbar renders single dynamic mic button without cluttered labels', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 300));

      final textController = TextEditingController();
      bool isMuted = false;

      await tester.pumpWidget(StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              bottomNavigationBar: BroadcastBottomToolbar(
                textController: textController,
                isAudioMode: true,
                isMuted: isMuted,
                onSendMessage: () {},
                onEmojiTap: () {},
                onMicToggle: () {
                  setState(() => isMuted = !isMuted);
                },
                onGiftsTap: () {},
                onSoundToggle: () {},
                onMoreTap: () {},
              ),
            ),
          );
        },
      ));
      await tester.pump();

      // Flexible comfortable message input
      expect(find.text('Type a message...'), findsOneWidget);

      // Verify unmuted mic icon is present (Icons.mic_rounded)
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_off_rounded), findsNothing);

      // Verify cluttered text labels are REMOVED
      expect(find.text('Mic\n(Audio)'), findsNothing);
      expect(find.text('Sound\n(Audio On)'), findsNothing);
      expect(find.text('Mute\n(Audio On)'), findsNothing);

      // Tap single dynamic mic button to toggle to muted
      await tester.tap(find.byIcon(Icons.mic_rounded));
      await tester.pump();

      // Now muted red icon should appear
      expect(find.byIcon(Icons.mic_off_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsNothing);
    });

    testWidgets('7. LiveBroadcastScreen renders complete Audio Broadcast experience matching reference design', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 950));

      await tester.pumpWidget(createTestWidget(LiveBroadcastScreen(
        room: testAudioRoom,
        isHost: true,
        isAudioMode: true,
      )));
      await tester.pump();

      // Header components
      expect(find.text('Ayesha Live'), findsOneWidget);
      expect(find.text('Audio Live'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      expect(find.text('2.8K'), findsOneWidget);
      expect(find.text('Rank 12'), findsOneWidget);
      expect(find.text('+12'), findsNWidgets(2)); // in top-right header and in other gifters

      // Audio Area components
      expect(find.text('Audio Broadcast'), findsOneWidget);
      expect(find.text('Top Gifter'), findsOneWidget);

      // Gifters section
      expect(find.text('Top 2 Gifters'), findsOneWidget);
      expect(find.text('Other Gifters'), findsOneWidget);

      // Sample chat messages from reference screenshot
      expect(find.text('Mashallah your voice is amazing! ❤️'), findsOneWidget);
      expect(find.text("Bro you're the best! 🙌"), findsOneWidget);

      // Bottom bar
      expect(find.text('Type a message...'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });
  });
}
