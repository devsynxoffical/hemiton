import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../models/live_room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emoji_reaction_provider.dart';
import '../../providers/live_gift_provider.dart';
import '../../widgets/gift_dialog.dart';
import '../../widgets/bring_my_friend_sheet.dart';
import '../../widgets/icebreaker_sheet.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/emoji_reaction_overlay.dart';
import '../../widgets/tiktok_gift_overlay.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isFollowing = false;
  int _diamonds = 17;
  int _stars = 17;
  int _viewerCount = 127;
  final List<_FloatingHeart> _floatingHearts = [];
  Timer? _heartStreamTimer;

  // Camera fields for host live broadcasting
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  // Exact live chat messages from Image 3 reference
  late List<_LiveChatMessage> _chatMessages;

  // 4 Top Viewers for Header from Image 3
  final List<String> _topViewers = const [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=120&q=80',
  ];

  late AnimationController _flameAnimController;
  late Animation<double> _flameScaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _initLiveCamera();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EmojiReactionProvider>().setActiveRoom(widget.room.id);
        context.read<LiveGiftProvider>().setActiveRoom(widget.room.id);
      }
    });

    // Pulse animation for 3D Flame reaction
    _flameAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _flameScaleAnimation = Tween<double>(begin: 0.95, end: 1.12).animate(
      CurvedAnimation(parent: _flameAnimController, curve: Curves.easeInOut),
    );

    // Initial chat feed exactly matching Image 3
    _chatMessages = [
      _LiveChatMessage(
        senderName: 'Assalamu Alaikum',
        message: '',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80',
        levelBadge: '💎 11',
        starBadge: '⭐ B',
        extraBadge: '❤️ ♍',
        isNotice: false,
      ),
      _LiveChatMessage(
        senderName: 'ID:1113870305',
        message: 'aswrwb akami fayyakeri',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80',
        nameColor: const Color(0xFF00E5FF),
      ),
      _LiveChatMessage(
        senderName: 'سفر الجزیره',
        message: 'سلام علیکم .',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&q=80',
        levelBadge: '💎 1',
        isArabic: true,
      ),
      _LiveChatMessage(
        senderName: 'Zamzm Muhammad',
        message: '📍 Ad Diriyah, Saudi Arabia',
        avatarUrl:
            'https://images.unsplash.com/photo-1584999734482-05c3adac4f0c?w=120&q=80',
        nameColor: const Color(0xFFFF4081),
        isHost: true,
      ),
      _LiveChatMessage(
        senderName: 'ID:1136516679',
        message: 'sent a like to the host. ❤️',
        avatarUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=120&q=80',
        nameColor: const Color(0xFF00E5FF),
      ),
      _LiveChatMessage(
        senderName: 'Meera',
        message: 'So calming ❤️',
        avatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=120&q=80',
        nameColor: const Color(0xFF64B5F6),
      ),
      _LiveChatMessage(
        senderName: 'Arjun',
        message: 'Your voice is magical ✨',
        avatarUrl:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120&q=80',
        nameColor: const Color(0xFFFFB74D),
      ),
      _LiveChatMessage(
        senderName: 'Rohit_09',
        message: 'MashaAllah beautiful ❤️',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&q=80',
        nameColor: const Color(0xFF81C784),
      ),
    ];

    // Floating hearts will only trigger on user double-tap or button tap (not automatically)
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _flameAnimController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    _heartStreamTimer?.cancel();
    super.dispose();
  }

  void _addRandomFloatingHeart() {
    final rand = Random();
    final id = UniqueKey();
    final double startX = 310.w + rand.nextDouble() * 30.w;
    final heart = _FloatingHeart(
      id: id,
      startX: startX,
      color: [
        const Color(0xFFFF1493),
        const Color(0xFFFF007F),
        const Color(0xFFFF4081),
        const Color(0xFFFF69B4),
      ][rand.nextInt(4)],
      icon: rand.nextBool() ? Icons.favorite_rounded : Icons.favorite,
    );

    setState(() {
      _floatingHearts.add(heart);
      if (_floatingHearts.length > 15) {
        _floatingHearts.removeAt(0);
      }
    });

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _floatingHearts.removeWhere((h) => h.id == id);
        });
      }
    });
  }

  void _sendMessage() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).currentUser;

    setState(() {
      _diamonds += 1;
      _stars += 1;
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
    });

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
        : 'Zamzm Muhammad';
    final String hostId = widget.room.host.id.isNotEmpty
        ? widget.room.host.id.replaceAll(RegExp(r'[^0-9]'), '')
        : '1132236473';
    final String displayId = hostId.isNotEmpty ? hostId : '1132236473';

    final String coverImage = widget.room.coverUrl.isNotEmpty
        ? widget.room.coverUrl
        : 'https://images.unsplash.com/photo-1584999734482-05c3adac4f0c?w=1000&q=85';

    return Scaffold(
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

          // Double-Tap anywhere to send live heart likes (only on double-tap)
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

          // ── 2. Top Header Bar ──────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopHeader(hostName, displayId),
            ),
          ),

          // ── 3. Floating 3D Flame Reaction (Center Left) ─────────────────────
          Positioned(
            left: 24.w,
            top: 130.h,
            child: ScaleTransition(
              scale: _flameScaleAnimation,
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 38)),
                ),
              ),
            ),
          ),

          // ── 4. Live Chat Message Stream (Bottom Left) ───────────────────────
          Positioned(
            left: 14.w,
            right: 80.w,
            bottom: 74.h,
            child: SizedBox(
              height: 250.h,
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

          // ── 5. Floating Pink Hearts Rising Up (Right Edge) ──────────────────
          ..._floatingHearts.map((h) => _buildAnimatedHeart(h)),

          // ── 6. Circular Glowing Gift Button (Bottom Right) ──────────────────
          Positioned(
            right: 14.w,
            bottom: 74.h,
            child: GestureDetector(
              onTap: () {
                _addRandomFloatingHeart();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => GiftDialog(streamerName: hostName),
                );
              },
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)],
                    radius: 0.85,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF00FF).withValues(alpha: 0.7),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text('🎁', style: TextStyle(fontSize: 26.sp)),
                ),
              ),
            ),
          ),

          // ── Live Animated Gifts Overlay ──────────────────────────────────────
          TikTokGiftOverlay(roomId: widget.room.id),

          // ── Live Animated Emojis & Reactions Overlay ─────────────────────────
          EmojiReactionOverlay(roomId: widget.room.id),

          // ── 7. Bottom Action Bar ───────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomActionBar(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Header Bar ──────────────────────────────────────────────────────────
  Widget _buildTopHeader(String hostName, String hostId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Host Pill (Avatar + Name + ID + Follow Button)
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 3.w,
                    right: 4.w,
                    top: 2.5.h,
                    bottom: 2.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Host Avatar with Pink Ring
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            widget.room.host.avatarUrl.isNotEmpty
                                ? widget.room.host.avatarUrl
                                : 'https://images.unsplash.com/photo-1584999734482-05c3adac4f0c?w=120&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 15,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),

                      // Name + ID
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
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.room.isFriendOfFriend &&
                                      widget.room.mutualFriendName != null
                                  ? '👥 ${widget.room.mutualFriendName}'
                                  : 'ID:$hostId',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.room.isFriendOfFriend
                                    ? const Color(0xFFE9D5FF)
                                    : Colors.white70,
                                fontSize: 8.sp,
                                fontWeight: widget.room.isFriendOfFriend
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5.w),

                      // Round Pink "+" Follow Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFollowing = !_isFollowing;
                            _viewerCount += _isFollowing ? 1 : -1;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isFollowing
                                    ? 'Followed $hostName! ❤️'
                                    : 'Unfollowed',
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.pink,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: _isFollowing
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFF1493),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              _isFollowing ? Icons.check : Icons.add,
                              color: Colors.white,
                              size: 14.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 4.w),
              const Spacer(),

              // Right side items (Viewers + Count + Flip camera + Close)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Viewers Circles (up to 2 if host has flip camera, or 3 for viewers)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _topViewers.take(widget.isHost ? 2 : 3).map((url) {
                      return Container(
                        margin: EdgeInsets.only(left: 2.w),
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1.0),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 12,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 4.w),

                  // Total Viewers Badge ("127")
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$_viewerCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Host Camera Flip Button
                  if (widget.isHost && _cameras.length > 1) ...[
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.cameraswitch_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],

                  // Close "✕" Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
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
          SizedBox(height: 5.h),

          // Diamonds + Stars Pills Row
          Row(
            children: [
              // Diamonds Pill ("💎 17")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 4.w),
                    Text(
                      '$_diamonds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),

              // Stars / Points Pill ("⭐ 17/50")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 4.w),
                    Text(
                      '$_stars/50',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Chat Message Item (Semi-transparent bubble) ─────────────────────────────
  Widget _buildChatMessageItem(_LiveChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(14.r),
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
            SizedBox(width: 5.w),

            // Optional Level Badge (e.g. 💎 11)
            if (msg.levelBadge != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  msg.levelBadge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
            ],

            // Optional Star Badge (e.g. ⭐ B)
            if (msg.starBadge != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  msg.starBadge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
            ],

            // Optional Extra Badge (e.g. ❤️ ♍)
            if (msg.extraBadge != null) ...[
              Text(msg.extraBadge!, style: TextStyle(fontSize: 9.sp)),
              SizedBox(width: 3.w),
            ],

            // Sender Name + Message
            Flexible(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${msg.senderName} ',
                      style: TextStyle(
                        color: msg.nameColor ?? Colors.white,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (msg.message.isNotEmpty)
                      TextSpan(
                        text: msg.message,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 10.5.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
        final double bottom = 90.h + (value * 280.h);
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
                size: 22.w,
                shadows: [
                  Shadow(
                    color: const Color(0xFFFF00FF).withValues(alpha: 0.8),
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

  // ── Bottom Action Bar (Image 3 exact icons & style) ──────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      color: Colors.transparent,
      child: Row(
        children: [
          // "Type a message..." Input Box with Smiley Face
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      cursorColor: const Color(0xFFFF1493),
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12.sp,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _commentController.text += ' 😊';
                    },
                    child: const Text('😊', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Bring My Friend / Invite Icon (👥)
          _buildActionButton(
            icon: Icons.person_add_rounded,
            onTap: () {
              BringMyFriendSheet.show(
                context,
                roomId: widget.room.id,
                roomTitle: widget.room.title,
              );
            },
          ),
          SizedBox(width: 4.w),

          // Gamepad Controller Icon (🎮 / 🧠 Icebreaker & Minigames)
          _buildActionButton(
            icon: Icons.sports_esports_rounded,
            color: const Color(0xFF64B5F6),
            onTap: () {
              IcebreakerSheet.show(
                context,
                roomId: widget.room.id,
                currentSpeakerName: widget.room.host.name,
              );
            },
          ),
          SizedBox(width: 4.w),

          // Golden Laurel Wreath / Trophy (🏆)
          _buildActionButton(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFFFD700),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room Leaderboard & Rankings 🏆'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.gold,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          SizedBox(width: 4.w),

          // Gift Box Icon with Ribbon (🎁)
          GestureDetector(
            onTap: () {
              _addRandomFloatingHeart();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => GiftDialog(
                  streamerName: widget.room.host.name.isNotEmpty
                      ? widget.room.host.name
                      : 'Zamzm Muhammad',
                ),
              );
            },
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('🎁', style: TextStyle(fontSize: 17.sp)),
              ),
            ),
          ),
          SizedBox(width: 4.w),

          // Paper Plane Send / Share Icon (➤)
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFF8A2BE2)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 16.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: color, size: 18.w),
        ),
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
  });
}
