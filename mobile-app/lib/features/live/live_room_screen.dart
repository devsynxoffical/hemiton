import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../models/live_room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emoji_reaction_provider.dart';
import '../../providers/live_gift_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/gift_dialog.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/bring_my_friend_sheet.dart';
import '../../widgets/hangout_games_sheet.dart';
import '../../widgets/profile_frame_picker_sheet.dart';
import '../../widgets/live_toolbar_icons.dart';
import '../../widgets/icebreaker_sheet.dart';
import '../../widgets/emoji_reaction_overlay.dart';
import '../../widgets/tiktok_gift_overlay.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/repositories/room_repository.dart';
import '../../providers/room_overlay_provider.dart';
import '../../models/user_model.dart';
import '../profile/user_profile_details_screen.dart';
import '../messages/inbox_screen.dart';

class LiveRoomScreen extends StatefulWidget {
  final LiveRoomModel room;
  final bool isHost;

  const LiveRoomScreen({super.key, required this.room, this.isHost = false});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isFollowing = false;
  bool _isMuted = false;
  bool _isInputExpanded = false;
  int _viewerCount = 2400;
  final List<_FloatingHeart> _floatingHearts = [];
  Timer? _heartStreamTimer;
  final List<Timer> _heartTimers = [];

  // Camera fields for host live broadcasting
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  // Exact live chat messages from Image 1 reference
  late List<_LiveChatMessage> _chatMessages;
  bool _isExitDialogShowing = false;

  void _minimizeToOverlay() {
    Provider.of<RoomOverlayProvider>(context, listen: false).minimizeRoom(
      roomType: 'LIVE',
      room: widget.room,
      isHost: widget.isHost,
      isAudioMode: false,
    );
    Navigator.pop(context);
  }

  Future<void> _confirmExit() async {
    if (_isExitDialogShowing) return;
    _isExitDialogShowing = true;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161129),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'Live Broadcast Options',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: const Text(
          'Would you like to continue watching/streaming, leave the room, or end the live broadcast?',
          style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: const Text(
              'Continue Live',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, 'leave'),
            child: const Text('Leave Live', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, 'end'),
            child: const Text('End Live', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    _isExitDialogShowing = false;

    if (!mounted || action == null || action == 'continue') return;

    if (action == 'end') {
      try {
        BackendRepository.instance.removeLiveRoom(widget.room.id);
      } catch (_) {}
      try {
        await RoomRepository.instance.closeRoom(widget.room.id);
      } catch (_) {}
      if (mounted) {
        try {
          await Provider.of<RoomOverlayProvider>(context, listen: false).closeRoom(context);
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live broadcast has ended.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } else if (action == 'leave') {
      try {
        await RoomRepository.instance.leaveRoom(widget.room.id);
      } catch (_) {}
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _initLiveCamera();
    }

    _commentFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isInputExpanded = _commentFocusNode.hasFocus;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmojiReactionProvider>().setActiveRoom(widget.room.id);
        context.read<LiveGiftProvider>().setActiveRoom(widget.room.id);
      }
    });

    // Initial chat feed matching Image 1
    _chatMessages = [
      _LiveChatMessage(
        senderName: 'Rohan',
        message: 'sent a Rose 🌹 x10',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80',
        isGift: true,
      ),
      _LiveChatMessage(
        senderName: 'Neha',
        message: 'Hi Priya!',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
      ),
      _LiveChatMessage(
        senderName: 'Amit',
        message: 'You are amazing!',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
      ),
      _LiveChatMessage(
        senderName: 'Sara',
        message: 'Lovely stream 💜',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
      ),
      _LiveChatMessage(
        senderName: 'Vikram',
        message: 'Can you sing a song?',
        avatarUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120&q=80',
      ),
      _LiveChatMessage(
        senderName: 'Tanya',
        message: '❤️❤️❤️',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=120&q=80',
      ),
    ];

    // Continuous rising hearts stream matching Image 1
    _heartStreamTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (mounted) {
        _addRandomFloatingHeart();
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    _heartStreamTimer?.cancel();
    for (final t in _heartTimers) {
      t.cancel();
    }
    _heartTimers.clear();
    super.dispose();
  }

  void _addRandomFloatingHeart() {
    final rand = Random();
    final id = UniqueKey();
    final double startX = 310.w + rand.nextDouble() * 25.w;
    final heart = _FloatingHeart(
      id: id,
      startX: startX,
      color: [
        Colors.white,
        const Color(0xFFFFB6C1),
        const Color(0xFFFF4081),
        const Color(0xFFFF007F),
        const Color(0xFFFF1744),
      ][rand.nextInt(5)],
      icon: rand.nextBool() ? Icons.favorite_rounded : Icons.favorite,
    );

    setState(() {
      _floatingHearts.add(heart);
      if (_floatingHearts.length > 20) {
        _floatingHearts.removeAt(0);
      }
    });

    Timer? t;
    t = Timer(const Duration(milliseconds: 2200), () {
      _heartTimers.remove(t);
      if (mounted) {
        setState(() {
          _floatingHearts.removeWhere((h) => h.id == id);
        });
      }
    });
    _heartTimers.add(t);
  }

  void _sendMessage() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser;

    setState(() {
      _chatMessages.add(
        _LiveChatMessage(
          senderName: currentUser.name.isNotEmpty ? currentUser.name : 'You',
          message: text,
          avatarUrl: currentUser.avatarUrl.isNotEmpty
              ? currentUser.avatarUrl
              : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=120&q=80',
          nameColor: AppColors.blue,
        ),
      );
      _commentController.clear();
      _isInputExpanded = false;
    });

    _commentFocusNode.unfocus();

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initLiveCamera() async {
    try {
      await Permission.camera.request();
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        int frontIndex = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;
        await _setupCameraController(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('[LiveRoom] Camera initialization error: $e');
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _setupCameraController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      try {
        await _cameraController!.dispose();
      } catch (_) {}
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[LiveRoom] CameraController setup error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  void _switchCamera() async {
    if (_cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      setState(() {
        _isCameraInitialized = false;
      });
      await _setupCameraController(_cameras[_selectedCameraIndex]);
    }
  }


  @override
  Widget build(BuildContext context) {
    final String hostName = widget.room.host.name.isNotEmpty
        ? widget.room.host.name
        : 'Priya';
    final String hostId = widget.room.host.id.isNotEmpty
        ? widget.room.host.id.replaceAll(RegExp(r'[^0-9]'), '')
        : '1132236473';
    final String displayId = hostId.isNotEmpty ? hostId : '1132236473';

    final String coverImage = widget.room.coverUrl.isNotEmpty
        ? widget.room.coverUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1000&q=85';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Fullscreen Host Video / Image Background ─────────────────────
          if (widget.isHost &&
              _isCameraInitialized &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 720,
                  height: _cameraController!.value.previewSize?.width ?? 1280,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Image.network(
              coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E0854), Color(0xFF0F051D), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.person, color: Colors.white24, size: 80.w),
                ),
              ),
            ),

          // Ambient Dark Vignette for contrast
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Double-Tap anywhere to send live heart likes
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: () {
                _addRandomFloatingHeart();
                _addRandomFloatingHeart();
              },
              child: const SizedBox.expand(),
            ),
          ),

          // ── 2. Top Header Bar (Priya Host Capsule + PiP + Exit) ───────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopHeader(hostName, displayId),
            ),
          ),

          // ── 3. Live Chat Message Stream (Bottom Left - positioned above Input Row) ──
          Positioned(
            left: 12.w,
            right: 75.w,
            bottom: MediaQuery.of(context).padding.bottom + 58.h,
            child: SizedBox(
              height: 210.h,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white, Colors.white],
                    stops: [0.0, 0.15, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _chatMessages.length,
                  separatorBuilder: (context, index) => SizedBox(height: 5.h),
                  itemBuilder: (context, index) {
                    final msg = _chatMessages[index];
                    return _buildChatMessageItem(msg);
                  },
                ),
              ),
            ),
          ),

          // ── 4. Floating Hearts Continuous Rising Stream (Right Edge) ────────
          ..._floatingHearts.map((h) => _buildAnimatedHeart(h)),

          // ── Live Animated Gifts Overlay ──────────────────────────────────────
          TikTokGiftOverlay(roomId: widget.room.id),

          // ── Live Animated Emojis & Reactions Overlay ─────────────────────────
          EmojiReactionOverlay(roomId: widget.room.id),

          // ── 5. Bottom Interactive Toolbar (7 Items matching reference image exactly) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _buildBottomControlBar(),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── Top Header Bar (Image 1 Exact Priya Host Capsule + PiP + Exit) ───────
  Widget _buildTopHeader(String hostName, String hostId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Host Capsule: Circular Avatar + Priya + 👁 2.4K + + Follow pill
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 4.w, right: 6.w, top: 3.h, bottom: 3.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileDetailsScreen(
                              user: widget.room.host,
                              userId: widget.room.host.id,
                            ),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Host Avatar
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.network(
                                widget.room.host.avatarUrl.isNotEmpty
                                    ? widget.room.host.avatarUrl
                                    : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),

                          // Name ("Priya") + Viewer count ("👁 2.4K")
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hostName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_rounded, color: Colors.white70, size: 9.sp),
                                    SizedBox(width: 2.w),
                                    Text(
                                      _viewerCount >= 1000
                                          ? '${(_viewerCount / 1000).toStringAsFixed(1)}K'
                                          : '$_viewerCount',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),

                // "+ Follow" purple gradient pill button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                      _viewerCount += _isFollowing ? 1 : -1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFollowing ? 'Followed $hostName! ❤️' : 'Unfollowed'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF8A2BE2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isFollowing
                            ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                            : [const Color(0xFF8A2BE2), const Color(0xFF6C63FF)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      _isFollowing ? '✓ Following' : '+ Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

          // Right Icons: Picture-in-picture & Close ✕
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flip Camera Button for Host
              if (widget.isHost && _cameras.length > 1) ...[
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],

              // Picture-in-Picture / overlay floating window
              GestureDetector(
                onTap: _minimizeToOverlay,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_in_picture_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Close ✕ button
              GestureDetector(
                onTap: _confirmExit,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chat Message Item (Image 1 translucent pill with gold gifts) ────────────
  Widget _buildChatMessageItem(_LiveChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          final targetUser = UserModel(
            id: 'user_${msg.senderName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
            name: msg.senderName,
            username: msg.senderName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
            avatarUrl: msg.avatarUrl,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileDetailsScreen(
                user: targetUser,
                userId: targetUser.id,
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.5.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sender Avatar
            Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.network(
                  msg.avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: Colors.white, size: 12),
                ),
              ),
            ),
            SizedBox(width: 6.w),

            // Sender Name + Message
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${msg.senderName}  ',
                      style: TextStyle(
                        color: msg.nameColor ?? Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (msg.message.isNotEmpty)
                      TextSpan(
                        text: msg.message,
                        style: TextStyle(
                          color: msg.isGift
                              ? const Color(0xFFFFD700) // Golden yellow highlight for gifts
                              : Colors.white.withValues(alpha: 0.95),
                          fontSize: 11.sp,
                          fontWeight: msg.isGift ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Animated Heart Floating Widget ──────────────────────────────────────────
  Widget _buildAnimatedHeart(_FloatingHeart heart) {
    return TweenAnimationBuilder<double>(
      key: heart.id,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      builder: (context, value, child) {
        final double bottom = 70.h + (value * 300.h);
        final double opacity = value < 0.2 ? (value / 0.2) : (1.0 - value);
        final double wobble = sin(value * pi * 3) * 12.w;

        return Positioned(
          left: heart.startX + wobble,
          bottom: bottom,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.7 + (value * 0.5),
              child: Icon(
                heart.icon,
                color: heart.color,
                size: 24.w,
                shadows: [
                  Shadow(
                    color: heart.color.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Interactive Control Bar (7 items matching reference image exactly) ───
  Widget _buildBottomControlBar() {
    MessagingProvider? messaging;
    try {
      messaging = Provider.of<MessagingProvider?>(context, listen: true);
    } catch (_) {}
    final hasUnread = (messaging?.totalCombinedUnreadCount ?? 0) > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. Expanding Capsule Chat Input with Smiley Emoji ──
          Expanded(
            flex: _isInputExpanded ? 10 : 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 38.h,
              padding: EdgeInsets.only(left: 14.w, right: 6.w),
              decoration: BoxDecoration(
                color: const Color(0xFF222634).withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      cursorColor: Colors.white,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5.sp),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12.sp,
                        ),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      onTap: () {
                        setState(() => _isInputExpanded = true);
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),

                  // Emoji Icon inside the text field capsule (smiling face matching reference)
                  GestureDetector(
                    onTap: () {
                      EmojiPickerSheet.show(
                        context,
                        roomId: widget.room.id,
                        onEmojiSelected: (emoji) {
                          if (mounted) {
                            setState(() {
                              _commentController.text += emoji;
                            });
                          }
                        },
                        onReactionSelected: (reactionAsset, symbol) {
                          final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
                          context.read<EmojiReactionProvider>().sendReaction(
                            roomId: widget.room.id,
                            senderId: user.id,
                            emoji: reactionAsset,
                            senderName: user.name,
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: Colors.white.withValues(alpha: 0.88),
                        size: 20.sp,
                      ),
                    ),
                  ),

                  if (_isInputExpanded) ...[
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
                          ),
                        ),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // If input is expanded, collapse other action icons or show cancel button
          if (!_isInputExpanded) ...[
            SizedBox(width: 6.w),

            // ── 2. Blue Circular Mic Icon Button ──
            GestureDetector(
              onTap: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isMuted ? 'Microphone Muted 🔇' : 'Microphone Unmuted 🎙️'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF007AFF),
                  ),
                );
              },
              child: Container(
                width: 29.w,
                height: 29.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isMuted ? const Color(0xFFFF1744) : const Color(0xFF007AFF),
                ),
                child: Center(
                  child: Icon(
                    _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 16.5.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),

            // ── 3. Outside Chat Icon: White speech bubble with two lines & Green/Red dot ──
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InboxScreen()),
                );
              },
              child: NextChatBubbleIcon(hasUnread: hasUnread, size: 27),
            ),
            SizedBox(width: 6.w),

            // ── 4. Games Gamepad Icon (White controller with golden crown, no circle) ──
            GestureDetector(
              onTap: () {
                HangoutGamesSheet.show(
                  context,
                  roomId: widget.room.id,
                  roomTitle: widget.room.title,
                );
              },
              child: const GamesCrownIcon(size: 28),
            ),
            SizedBox(width: 6.w),

            // ── 5. Frame Laurel Wreath Icon (Golden laurel wreath ring, no circle) ──
            GestureDetector(
              onTap: () {
                ProfileFramePickerSheet.show(context);
              },
              child: const GoldenLaurelWreathIcon(size: 27),
            ),
            SizedBox(width: 6.w),

            // ── 6. Gift Icon (Hot pink gift box with gold ribbon, no circle) ──
            GestureDetector(
              onTap: () {
                final hostName = widget.room.host.name.isNotEmpty
                    ? widget.room.host.name
                    : 'Priya';
                _addRandomFloatingHeart();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => GiftDialog(streamerName: hostName),
                );
              },
              child: const PinkGiftBoxIcon(size: 26),
            ),
            SizedBox(width: 6.w),

            // ── 7. Share Icon (White paper airplane, no circle) ──
            GestureDetector(
              onTap: () {
                BringMyFriendSheet.show(
                  context,
                  roomId: widget.room.id,
                  roomTitle: widget.room.title,
                );
              },
              child: const PaperPlaneShareIcon(size: 24),
            ),
          ] else ...[
            // Collapsed cancel focus button when expanded
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                _commentFocusNode.unfocus();
                setState(() => _isInputExpanded = false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.sp),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openMoreSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: const Color(0xFF161129),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Room Controls & Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 18.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: _buildMoreOption(
                          icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                          color: _isMuted ? Colors.redAccent : const Color(0xFF00E676),
                          label: _isMuted ? 'Unmute' : 'Mute Mic',
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _isMuted = !_isMuted);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isMuted ? 'Microphone Muted' : 'Microphone Unmuted'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      if (widget.isHost && _cameras.length > 1)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: _buildMoreOption(
                            icon: Icons.flip_camera_ios_rounded,
                            color: Colors.cyanAccent,
                            label: 'Flip Camera',
                            onTap: () {
                              Navigator.pop(ctx);
                              _switchCamera();
                            },
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: _buildMoreOption(
                          icon: Icons.person_add_rounded,
                          color: const Color(0xFFFF4081),
                          label: 'Invite Friends',
                          onTap: () {
                            Navigator.pop(ctx);
                            BringMyFriendSheet.show(
                              context,
                              roomId: widget.room.id,
                              roomTitle: widget.room.title,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: _buildMoreOption(
                          icon: Icons.sports_esports_rounded,
                          color: const Color(0xFF64B5F6),
                          label: 'Icebreaker',
                          onTap: () {
                            Navigator.pop(ctx);
                            IcebreakerSheet.show(
                              context,
                              roomId: widget.room.id,
                              currentSpeakerName: widget.room.host.name,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHeart {
  final Key id;
  final double startX;
  final Color color;
  final IconData icon;

  _FloatingHeart({
    required this.id,
    required this.startX,
    required this.color,
    required this.icon,
  });
}

class _LiveChatMessage {
  final String senderName;
  final String message;
  final String avatarUrl;
  final Color? nameColor;
  final String? levelBadge;
  final String? starBadge;
  final String? extraBadge;
  final bool isNotice;
  final bool isArabic;
  final bool isHost;
  final bool isGift;

  _LiveChatMessage({
    required this.senderName,
    required this.message,
    required this.avatarUrl,
    this.nameColor,
    this.levelBadge,
    this.starBadge,
    this.extraBadge,
    this.isNotice = false,
    this.isArabic = false,
    this.isHost = false,
    this.isGift = false,
  });
}

