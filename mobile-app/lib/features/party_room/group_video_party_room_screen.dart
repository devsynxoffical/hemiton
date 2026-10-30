import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/repositories/backend_repository.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/double_tap_like_overlay.dart';
import '../../widgets/gift_dialog.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/bring_my_friend_sheet.dart';
import '../../widgets/hangout_games_sheet.dart';
import '../../widgets/profile_frame_picker_sheet.dart';
import '../../widgets/live_toolbar_icons.dart';
import '../../widgets/tiktok_gift_overlay.dart';
import '../../widgets/emoji_reaction_overlay.dart';
import '../messages/inbox_screen.dart';

/// Sleek Multi-Guest Video Grid Room for Group Video Live broadcasts.
/// - Public Mode: Any user can immediately join any available video seat.
/// - Private Mode: Joining a video seat requires host permission approval.
/// - Double-Tap to Like: Spawns floating 3D hearts and increments live likes.
/// - Per-User Gifting: Send gifts to any seated user via seat gift button or GiftDialog recipient bar.
class GroupVideoPartyRoomScreen extends StatefulWidget {
  final LiveRoomModel room;
  final bool isHost;

  const GroupVideoPartyRoomScreen({
    super.key,
    required this.room,
    this.isHost = false,
  });

  @override
  State<GroupVideoPartyRoomScreen> createState() => _GroupVideoPartyRoomScreenState();
}

class _GroupVideoGuestSeat {
  final int seatIndex;
  final UserModel? user;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeaking;
  final int giftCoinsReceived;

  const _GroupVideoGuestSeat({
    required this.seatIndex,
    this.user,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeaking = false,
    this.giftCoinsReceived = 0,
  });

  _GroupVideoGuestSeat copyWith({
    UserModel? user,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeaking,
    int? giftCoinsReceived,
    bool clearUser = false,
  }) {
    return _GroupVideoGuestSeat(
      seatIndex: seatIndex,
      user: clearUser ? null : (user ?? this.user),
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      giftCoinsReceived: giftCoinsReceived ?? this.giftCoinsReceived,
    );
  }
}

class _GroupVideoPartyRoomScreenState extends State<GroupVideoPartyRoomScreen>
    with SingleTickerProviderStateMixin {
  late List<_GroupVideoGuestSeat> _seats;
  late bool _isPrivateRoom;
  final Set<int> _pendingPermissionSeats = {};
  bool _isMicMuted = false;
  final bool _isCameraOff = false;
  bool _isFrontCamera = true;
  int _viewerCount = 340;
  int _likeCount = 1280;
  Timer? _viewerTimer;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isInputExpanded = false;
  final List<Map<String, String>> _messages = [];
  final ScrollController _chatScrollController = ScrollController();

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isPrivateRoom = widget.room.isPrivate;

    _commentFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isInputExpanded = _commentFocusNode.hasFocus || _commentController.text.isNotEmpty;
        });
      }
    });
    _commentController.addListener(() {
      if (mounted) {
        final shouldExpand = _commentFocusNode.hasFocus || _commentController.text.isNotEmpty;
        if (_isInputExpanded != shouldExpand) {
          setState(() {
            _isInputExpanded = shouldExpand;
          });
        }
      }
    });
    _initLiveCamera();
    _viewerCount = widget.room.viewerCount > 0 ? widget.room.viewerCount : 340;

    final capacity = 8;
    _seats = List.generate(capacity, (index) {
      if (index == 0) {
        return _GroupVideoGuestSeat(
          seatIndex: 0,
          user: widget.room.host,
          isMuted: false,
          isCameraOff: false,
          isSpeaking: true,
          giftCoinsReceived: 520,
        );
      } else if (index == 1) {
        return const _GroupVideoGuestSeat(
          seatIndex: 1,
          user: UserModel(
            id: 'guest_maya',
            username: 'maya_vip',
            name: 'Maya ✨',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
            region: 'Dubai, UAE',
          ),
          isMuted: false,
          isCameraOff: false,
          isSpeaking: false,
          giftCoinsReceived: 240,
        );
      } else if (index == 2) {
        return const _GroupVideoGuestSeat(
          seatIndex: 2,
          user: UserModel(
            id: 'guest_alex',
            username: 'alex_star',
            name: 'Alex 🎸',
            avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
            region: 'London, UK',
          ),
          isMuted: true,
          isCameraOff: false,
          isSpeaking: false,
          giftCoinsReceived: 110,
        );
      } else {
        return _GroupVideoGuestSeat(seatIndex: index);
      }
    });

    _messages.addAll([
      {
        'user': 'System',
        'text': _isPrivateRoom
            ? 'Welcome to ${widget.room.title} (Private Group Live 🔒 — Host permission required for seats)'
            : 'Welcome to ${widget.room.title} (Public Group Live 🔓 — Tap any open seat to join!)',
        'isSystem': 'true',
      },
      {'user': 'Maya ✨', 'text': 'Hey everyone! Double tap the screen to send likes! ❤️', 'isSystem': 'false'},
      {'user': 'Sara_K', 'text': 'Sending gifts to everyone on stage! 🎁💖', 'isSystem': 'false'},
    ]);

    _viewerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _viewerCount += (DateTime.now().second % 2 == 0) ? 2 : -1;
          if (_viewerCount < 10) _viewerCount = 10;
        });
      }
    });

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  List<UserModel> _getAllRoomUsers() {
    final Map<String, UserModel> map = {};
    map[widget.room.host.id] = widget.room.host;
    for (final s in _seats) {
      if (s.user != null && s.user!.id.isNotEmpty) {
        map[s.user!.id] = s.user!;
      }
    }
    return map.values.toList();
  }

  void _openGiftDialogForUser({UserModel? targetUser}) {
    final allUsers = _getAllRoomUsers();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GiftDialog(
        streamerName: targetUser?.name ?? widget.room.host.name,
        targetReceiver: targetUser ?? widget.room.host,
        roomUsers: allUsers,
        roomId: widget.room.id,
        onGiftSentToUsers: (gift, recipients) {
          if (!mounted) return;
          final coinVal = gift.priceCoins > 0 ? gift.priceCoins : gift.diamondPrice;
          setState(() {
            for (int i = 0; i < _seats.length; i++) {
              final seatUser = _seats[i].user;
              if (seatUser != null && recipients.any((r) => r.id == seatUser.id)) {
                _seats[i] = _seats[i].copyWith(
                  giftCoinsReceived: _seats[i].giftCoinsReceived + coinVal,
                );
              }
            }
            final names = recipients.map((r) => r.name).join(', ');
            _messages.add({
              'user': 'Gift 🎁',
              'text': 'Sent ${gift.icon} ${gift.name} to $names!',
              'isSystem': 'true',
            });
          });
          _scrollToBottom();
        },
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initLiveCamera() async {
    try {
      await Permission.camera.request();
      await Permission.microphone.request();
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        int frontIdx = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _selectedCameraIndex = frontIdx != -1 ? frontIdx : 0;
        await _setupCamera(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Group video camera init error: $e');
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _setupCamera(CameraDescription desc) async {
    if (_cameraController != null) {
      try {
        await _cameraController!.dispose();
      } catch (_) {}
    }
    _cameraController = CameraController(
      desc,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isFrontCamera = desc.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      debugPrint('Group video camera setup error: $e');
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length <= 1) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _viewerTimer?.cancel();
    _pulseController.dispose();
    _commentFocusNode.dispose();
    _commentController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    final name = currentUser.displayName.isNotEmpty
        ? currentUser.displayName
        : (currentUser.name.isNotEmpty ? currentUser.name : 'Me');

    setState(() {
      _messages.add({'user': name, 'text': text, 'isSystem': 'false'});
      _commentController.clear();
    });
    _scrollToBottom();
  }

  void _joinSeatDirectly(int index, UserModel currentUser) {
    setState(() {
      // Vacate any existing seat held by currentUser
      for (int i = 0; i < _seats.length; i++) {
        if (i != 0 && _seats[i].user?.id == currentUser.id) {
          _seats[i] = _GroupVideoGuestSeat(seatIndex: i);
        }
      }
      _seats[index] = _seats[index].copyWith(
        user: currentUser,
        isMuted: _isMicMuted,
        isCameraOff: _isCameraOff,
      );
      _pendingPermissionSeats.remove(index);
      _messages.add({
        'user': 'System',
        'text': '${currentUser.name} joined Video Seat ${index + 1}! 📹✨',
        'isSystem': 'true',
      });
    });
    _scrollToBottom();
  }

  void _joinFirstAvailableSeat() {
    final emptyIdx = _seats.indexWhere((s) => s.user == null);
    if (emptyIdx == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All video seats are currently full!'),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _onSeatTap(emptyIdx);
  }

  void _onSeatTap(int index) {
    final seat = _seats[index];
    final currentUser = context.read<AuthProvider>().currentUser;
    final isHostUser = widget.isHost || widget.room.host.id == currentUser.id;

    if (seat.user == null) {
      // 1. PUBLIC GROUP LIVE (or Host): Any user can immediately join if seat is available!
      if (!_isPrivateRoom || isHostUser) {
        _joinSeatDirectly(index, currentUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined Video Seat ${index + 1}! 📹'),
            backgroundColor: const Color(0xFF00E676),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // 2. PRIVATE GROUP LIVE: Permission is required from Host!
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF17122E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: const BorderSide(color: Color(0xFFFF007F), width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF007F).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_rounded, color: Color(0xFFFF007F), size: 20),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Private Group Live',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15.5.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'This is a private group live. Host permission is required to join Video Seat ${index + 1}.',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.5.sp, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: const Icon(Icons.pan_tool_alt_rounded, size: 16),
              label: Text(
                'Request Permission',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _pendingPermissionSeats.add(index);
                  _messages.add({
                    'user': 'System',
                    'text': '✋ ${currentUser.name} requested host permission for Seat ${index + 1}.',
                    'isSystem': 'true',
                  });
                });
                _scrollToBottom();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Permission request sent to ${widget.room.host.name} for Seat ${index + 1}.'),
                    backgroundColor: const Color(0xFF8A2BE2),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Host Approve',
                      textColor: const Color(0xFF00E676),
                      onPressed: () {
                        if (mounted) {
                          _joinSeatDirectly(index, currentUser);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      // Occupied seat -> Profile & Gift / Mic / Leave actions
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        builder: (ctx) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFFFF007F), Color(0xFF00E5FF)]),
                ),
                child: CircleAvatar(radius: 28.r, backgroundImage: NetworkImage(seat.user!.avatarUrl)),
              ),
              SizedBox(height: 8.h),
              Text(
                seat.user!.name,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '${index == 0 ? "Host" : "Seat ${index + 1}"} • 🎁 ${seat.giftCoinsReceived} Coins',
                style: GoogleFonts.poppins(color: const Color(0xFF00E5FF), fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModalAction(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Send Gift',
                    color: const Color(0xFFFF007F),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGiftDialogForUser(targetUser: seat.user);
                    },
                  ),
                  if (isHostUser || seat.user!.id == currentUser.id) ...[
                    _buildModalAction(
                      icon: seat.isMuted ? Icons.mic_rounded : Icons.mic_off_rounded,
                      label: seat.isMuted ? 'Unmute' : 'Mute',
                      color: const Color(0xFF00E5FF),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _seats[index] = seat.copyWith(isMuted: !seat.isMuted);
                        });
                      },
                    ),
                    if (index != 0)
                      _buildModalAction(
                        icon: Icons.logout_rounded,
                        label: 'Leave Seat',
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _seats[index] = _GroupVideoGuestSeat(seatIndex: index);
                          });
                        },
                      ),
                  ],
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildModalAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.5.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _leaveRoom() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1433),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: Text(
          'Live Broadcast Options',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        content: Text(
          'Would you like to continue in this group video live, leave the room, or end the live session?',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Continue Live', style: GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Leave Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              BackendRepository.instance.removeLiveRoom(widget.room.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Group video live has ended.'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('End Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leaveRoom();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070510),
        body: DoubleTapLikeOverlay(
          roomId: widget.room.id,
          onLiked: () {
            if (mounted) {
              setState(() => _likeCount++);
            }
          },
          child: Stack(
            children: [
              // ── Rich Neon-Aurora Stage Background ──────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A0E36),
                        Color(0xFF0B081B),
                        Color(0xFF06050D),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF007F).withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 140,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                  ),
                ),
              ),

              // Gift & Emoji Overlays
              TikTokGiftOverlay(roomId: widget.room.id),
              EmojiReactionOverlay(roomId: widget.room.id),

              SafeArea(
                child: Column(
                  children: [
                    // ── 1. Sleek Top Header & Room Status Strip ─────────────
                    _buildTopHeader(),

                    SizedBox(height: 6.h),

                    // ── 2. Multi-Guest Video Grid Stage (8 Seats) ───────────
                    Expanded(
                      flex: 13,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: _buildVideoGrid(),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // ── 3. Live Chat Stream Overlay ─────────────────────────
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: _buildChatStream(),
                      ),
                    ),

                    // ── 4. Bottom Interactive Control Bar ───────────────────
                    _buildBottomControlBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP HEADER WITH PUBLIC/PRIVATE PERMISSION MODE & QUICK JOIN
  // ===========================================================================
  Widget _buildTopHeader() {
    final openSeatsCount = _seats.where((s) => s.user == null).length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Column(
        children: [
          Row(
            children: [
              // Host Glass Capsule
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF007F)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 14.r,
                          backgroundImage: NetworkImage(widget.room.host.avatarUrl),
                        ),
                      ),
                      SizedBox(width: 7.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.room.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.favorite_rounded, color: const Color(0xFFFF007F), size: 10.sp),
                                SizedBox(width: 3.w),
                                Text(
                                  '$_likeCount',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                GestureDetector(
                                  onTap: _joinFirstAvailableSeat,
                                  child: Text(
                                    '• $openSeatsCount Open',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF00E5FF),
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
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

              // Public / Private Permission Mode Badge (Tappable to toggle for demo/host)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isPrivateRoom = !_isPrivateRoom;
                    _messages.add({
                      'user': 'System',
                      'text': _isPrivateRoom
                          ? '🔒 Room switched to PRIVATE mode (Host permission required to join seats).'
                          : '🔓 Room switched to PUBLIC mode (Anyone can join available seats!).',
                      'isSystem': 'true',
                    });
                  });
                  _scrollToBottom();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: _isPrivateRoom
                        ? Colors.amber.withValues(alpha: 0.18)
                        : const Color(0xFF00E676).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _isPrivateRoom ? Colors.amber : const Color(0xFF00E676),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPrivateRoom ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: _isPrivateRoom ? Colors.amber : const Color(0xFF00E676),
                        size: 12.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _isPrivateRoom ? 'Private' : 'Public',
                        style: GoogleFonts.poppins(
                          color: _isPrivateRoom ? Colors.amber : const Color(0xFF00E676),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Live Viewers Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '$_viewerCount',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              // Flip Camera Button
              GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFrontCamera ? Icons.cameraswitch_rounded : Icons.camera_front_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Close / Leave Button
              GestureDetector(
                onTap: _leaveRoom,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 18.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MULTI-GUEST VIDEO GRID BOXES (ATTRACTIVE NEON STAGE)
  // ===========================================================================
  Widget _buildVideoGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _seats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.22,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemBuilder: (context, index) {
        final seat = _seats[index];
        return GestureDetector(
          onTap: () => _onSeatTap(index),
          child: _buildVideoCard(seat, index),
        );
      },
    );
  }

  Widget _buildVideoCard(_GroupVideoGuestSeat seat, int index) {
    final isHostSeat = index == 0;
    final isOccupied = seat.user != null;
    final isSpeaking = seat.isSpeaking;
    final isPendingApproval = _pendingPermissionSeats.contains(index);

    final borderColor = isHostSeat
        ? const Color(0xFFFFD700)
        : (isSpeaking
            ? const Color(0xFF00E5FF)
            : (isOccupied
                ? const Color(0xFFFF007F).withValues(alpha: 0.7)
                : (_isPrivateRoom
                    ? Colors.amber.withValues(alpha: 0.25)
                    : const Color(0xFF8A2BE2).withValues(alpha: 0.35))));

    final card = Container(
      decoration: BoxDecoration(
        gradient: isOccupied
            ? const LinearGradient(
                colors: [Color(0xFF1D1536), Color(0xFF0E0B1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  const Color(0xFF16112B).withValues(alpha: 0.85),
                  const Color(0xFF0C0919).withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: borderColor,
          width: isHostSeat ? 1.8 : (isSpeaking ? 1.6 : 1.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isHostSeat
                ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                : (isSpeaking
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.35)),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isOccupied) ...[
              // Video Feed / Camera Preview / Avatar
              seat.isCameraOff
                  ? Container(
                      color: const Color(0xFF191630),
                      child: Center(
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundImage: NetworkImage(seat.user!.avatarUrl),
                        ),
                      ),
                    )
                  : ((isHostSeat || widget.isHost) &&
                          _isCameraInitialized &&
                          _cameraController != null &&
                          _cameraController!.value.isInitialized
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _cameraController!.value.previewSize?.height ?? 100,
                            height: _cameraController!.value.previewSize?.width ?? 100,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      : Image.network(
                          seat.user!.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF191630),
                            child: const Icon(Icons.person, color: Colors.white38),
                          ),
                        )),

              // Gradient Vignette
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Top Left: Host Crown or Seat Number + Gift Counter
              Positioned(
                top: 6.h,
                left: 6.w,
                right: 6.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: isHostSeat
                            ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)])
                            : null,
                        color: isHostSeat ? null : Colors.black54,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isHostSeat) ...[
                            const Text('👑', style: TextStyle(fontSize: 9.5)),
                            SizedBox(width: 3.w),
                          ],
                          Text(
                            isHostSeat ? 'HOST' : '#${index + 1}',
                            style: GoogleFonts.poppins(
                              color: isHostSeat ? Colors.black : Colors.white,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Send Gift Pill on every occupied seat!
                    GestureDetector(
                      onTap: () => _openGiftDialogForUser(targetUser: seat.user),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007F).withValues(alpha: 0.45),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🎁', style: TextStyle(fontSize: 9.5)),
                            SizedBox(width: 3.w),
                            Text(
                              seat.giftCoinsReceived > 0 ? '${seat.giftCoinsReceived}' : 'Gift',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Glass User Bar & Mic Status
              Positioned(
                bottom: 6.h,
                left: 7.w,
                right: 7.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              seat.user!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isSpeaking && !seat.isMuted) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.graphic_eq_rounded, color: const Color(0xFF00E5FF), size: 13.sp),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(3.5.w),
                      decoration: BoxDecoration(
                        color: seat.isMuted ? Colors.redAccent : const Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        seat.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Empty Video Slot (Public Instant Join vs Private Request Permission)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isPrivateRoom
                              ? [Colors.amber.withValues(alpha: 0.22), Colors.orange.withValues(alpha: 0.1)]
                              : [const Color(0xFFFF007F).withValues(alpha: 0.22), const Color(0xFF8A2BE2).withValues(alpha: 0.22)],
                        ),
                        border: Border.all(
                          color: _isPrivateRoom
                              ? Colors.amber.withValues(alpha: 0.6)
                              : const Color(0xFF00E5FF).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        isPendingApproval
                            ? Icons.hourglass_top_rounded
                            : (_isPrivateRoom ? Icons.lock_person_rounded : Icons.videocam_rounded),
                        color: _isPrivateRoom ? Colors.amber : const Color(0xFF00E5FF),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Seat ${index + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isPendingApproval
                          ? 'Pending Approval...'
                          : (_isPrivateRoom ? '🔒 Request Join' : '+ Join Video'),
                      style: GoogleFonts.poppins(
                        color: _isPrivateRoom ? Colors.amber : const Color(0xFFFF007F),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isSpeaking) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: card,
      );
    }
    return card;
  }

  // ===========================================================================
  // LIVE CHAT STREAM
  // ===========================================================================
  Widget _buildChatStream() {
    return ListView.builder(
      controller: _chatScrollController,
      padding: EdgeInsets.zero,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isSystem = msg['isSystem'] == 'true';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isSystem
                  ? const Color(0xFFFF007F).withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSystem ? const Color(0xFFFF007F).withValues(alpha: 0.3) : Colors.white10,
                width: 0.8,
              ),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${msg['user']}: ',
                    style: GoogleFonts.poppins(
                      color: isSystem ? const Color(0xFFFFD700) : const Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                  TextSpan(
                    text: msg['text'] ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BOTTOM CONTROL BAR (Pixel-Perfect Reference Design)
  // ===========================================================================
  Widget _buildBottomControlBar() {
    int unreadOutsideMessages = 0;
    try {
      final messaging = Provider.of<MessagingProvider>(context, listen: true);
      unreadOutsideMessages = messaging.totalCombinedUnreadCount;
    } catch (_) {}

    final bool hasUnread = unreadOutsideMessages > 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 1. Capsule Text Field with integrated Emoji section ──
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

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

                    if (_isInputExpanded || _commentController.text.trim().isNotEmpty) ...[
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          _sendMessage();
                          _commentFocusNode.unfocus();
                        },
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

            if (!_isInputExpanded) ...[
              SizedBox(width: 6.w),

              // ── 2. Blue Circular Mic Icon Button ──
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMicMuted = !_isMicMuted;
                    if (widget.isHost) {
                      _seats[0] = _seats[0].copyWith(isMuted: _isMicMuted);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isMicMuted ? 'Microphone Muted 🔇' : 'Microphone Unmuted 🎙️'),
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
                    color: _isMicMuted ? const Color(0xFFFF1744) : const Color(0xFF007AFF),
                  ),
                  child: Center(
                    child: Icon(
                      _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 16.5.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),

              // ── 3. Outside Chat Icon ──
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

              // ── 4. Games Gamepad Icon ──
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

              // ── 5. Frame Laurel Wreath Icon ──
              GestureDetector(
                onTap: () {
                  ProfileFramePickerSheet.show(context);
                },
                child: const GoldenLaurelWreathIcon(size: 27),
              ),
              SizedBox(width: 6.w),

              // ── 6. Gift Icon (Opens GiftDialog with all Group Live users) ──
              GestureDetector(
                onTap: () => _openGiftDialogForUser(),
                child: const PinkGiftBoxIcon(size: 26),
              ),
              SizedBox(width: 6.w),

              // ── 7. Share Icon ──
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
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.5.sp),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
