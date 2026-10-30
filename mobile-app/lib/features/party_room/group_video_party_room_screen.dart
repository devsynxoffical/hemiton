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
import '../../widgets/gift_dialog.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/bring_my_friend_sheet.dart';
import '../../widgets/hangout_games_sheet.dart';
import '../../widgets/profile_frame_picker_sheet.dart';
import '../messages/inbox_screen.dart';
import '../profile/modules/outfit_screen.dart';

/// A sleek, high-end Multi-Guest Video Grid Room for Group Video Live broadcasts.
/// Supports 8 to 10 video guest seats arranged in neat camera grid boxes with
/// interactive mic/cam controls, guest joining, live chat, and gift interactions.
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

  const _GroupVideoGuestSeat({
    required this.seatIndex,
    this.user,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeaking = false,
  });

  _GroupVideoGuestSeat copyWith({
    UserModel? user,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeaking,
    bool clearUser = false,
  }) {
    return _GroupVideoGuestSeat(
      seatIndex: seatIndex,
      user: clearUser ? null : (user ?? this.user),
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class _GroupVideoPartyRoomScreenState extends State<GroupVideoPartyRoomScreen>
    with SingleTickerProviderStateMixin {
  late List<_GroupVideoGuestSeat> _seats;
  bool _isMicMuted = false;
  final bool _isCameraOff = false;
  bool _isFrontCamera = true;
  int _viewerCount = 340;
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

    // Initialize 8 or 10 video seats
    final capacity = 8; // Default neat 8 video boxes (2x4)
    _seats = List.generate(capacity, (index) {
      if (index == 0) {
        // Seat 0 is the Host
        return _GroupVideoGuestSeat(
          seatIndex: 0,
          user: widget.room.host,
          isMuted: false,
          isCameraOff: false,
          isSpeaking: true,
        );
      } else if (index == 1) {
        // Sample Co-Host guest for realistic demo
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
        );
      } else if (index == 2) {
        // Sample Guest 2
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
        );
      } else {
        return _GroupVideoGuestSeat(seatIndex: index);
      }
    });

    // Populate initial chat
    _messages.addAll([
      {'user': 'System', 'text': 'Welcome to ${widget.room.title}! Keep chats friendly. 🌟', 'isSystem': 'true'},
      {'user': 'Maya ✨', 'text': 'Hey everyone! Excited for the video live! 🎉', 'isSystem': 'false'},
      {'user': 'Sara_K', 'text': 'Sending gifts to all guests! 💖', 'isSystem': 'false'},
      {'user': 'Rohan99', 'text': 'Can I join seat 4? 🙋‍♂️', 'isSystem': 'false'},
    ]);

    // Fluctuating viewer count
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
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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

  void _onSeatTap(int index) {
    final seat = _seats[index];
    final currentUser = context.read<AuthProvider>().currentUser;

    if (seat.user == null) {
      // Empty video seat -> Join Dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1B1433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(color: Color(0xFF8A2BE2), width: 1.2),
          ),
          title: Row(
            children: [
              const Icon(Icons.videocam_rounded, color: Color(0xFFFF007F)),
              SizedBox(width: 8.w),
              Text('Take Video Seat ${index + 1}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Would you like to turn on your camera and join video slot ${index + 1}?',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _seats[index] = seat.copyWith(
                    user: currentUser,
                    isMuted: _isMicMuted,
                    isCameraOff: _isCameraOff,
                  );
                  _messages.add({
                    'user': 'System',
                    'text': '${currentUser.name} joined Video Seat ${index + 1}! 📹✨',
                    'isSystem': 'true',
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF007F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Join Seat', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      // Occupied seat -> Profile or seat actions
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        builder: (ctx) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 14.h),
              CircleAvatar(radius: 28.r, backgroundImage: NetworkImage(seat.user!.avatarUrl)),
              SizedBox(height: 8.h),
              Text(seat.user!.name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Text('Seat ${index + 1} • ${seat.user!.region.isNotEmpty ? seat.user!.region : "Global"}',
                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12.sp)),
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
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => GiftDialog(streamerName: seat.user!.name),
                      );
                    },
                  ),
                  if (widget.isHost || seat.user!.id == currentUser.id) ...[
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
    if (widget.isHost) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1B1433),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('End Group Video Live?', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to end this group video live session for all participants?',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                BackendRepository.instance.removeLiveRoom(widget.room.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text('End Live', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A14),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF140D2B),
                    Color(0xFF090A14),
                    Color(0xFF07050E),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── 1. Top Bar (Host Info, Live Badge, Viewers, Exit) ───────
                _buildTopHeader(),

                SizedBox(height: 8.h),

                // ── 2. Video Seats Grid Box Stage (8-10 Boxes) ──────────────
                Expanded(
                  flex: 12,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: _buildVideoGrid(),
                  ),
                ),

                SizedBox(height: 6.h),

                // ── 3. Live Chat Stream Overlay ─────────────────────────────
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildChatStream(),
                  ),
                ),

                // ── 4. Bottom Interactive Control Bar ───────────────────────
                _buildBottomControlBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TOP BAR
  // ===========================================================================
  Widget _buildTopHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Row(
        children: [
          // Host Capsule
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.3), width: 1.0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14.r,
                    backgroundImage: NetworkImage(widget.room.host.avatarUrl),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.room.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Group Video Live • 8 Seats',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(color: const Color(0xFF00E5FF), fontSize: 9.sp, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Live Viewers Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                ),
                SizedBox(width: 5.w),
                Text('$_viewerCount', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // Flip Camera Button
          GestureDetector(
            onTap: _switchCamera,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: Icon(
                _isFrontCamera ? Icons.cameraswitch_rounded : Icons.camera_front_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Close / Leave Button
          GestureDetector(
            onTap: _leaveRoom,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MULTI-GUEST VIDEO GRID BOXES
  // ===========================================================================
  Widget _buildVideoGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _seats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.18,
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

    final borderColor = isHostSeat
        ? const Color(0xFFFFD700)
        : (isSpeaking
            ? const Color(0xFF00E5FF)
            : (isOccupied
                ? const Color(0xFF8A2BE2).withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.12)));

    final card = Container(
      decoration: BoxDecoration(
        color: isOccupied ? const Color(0xFF131024) : const Color(0xFF0D0B1A),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor,
          width: isHostSeat ? 1.8 : (isSpeaking ? 1.6 : 1.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isHostSeat
                ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                : (isSpeaking
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.3)),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isOccupied) ...[
              // Video Feed / Avatar Background / Camera Preview
              seat.isCameraOff
                  ? Container(
                      color: const Color(0xFF191630),
                      child: Center(
                        child: CircleAvatar(
                          radius: 24.r,
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

              // Ambient gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Top Seat / Host Badge
              Positioned(
                top: 6.h,
                left: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isHostSeat
                        ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                        : Colors.black54,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHostSeat) ...[
                        const Text('👑', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 3.w),
                      ],
                      Text(
                        isHostSeat ? 'HOST' : 'Seat ${index + 1}',
                        style: GoogleFonts.poppins(
                          color: isHostSeat ? Colors.black : Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Label & Mic Status
              Positioned(
                bottom: 6.h,
                left: 8.w,
                right: 8.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        seat.user!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: seat.isMuted ? Colors.redAccent : const Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        seat.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Empty Slot (Join Video Seat Box)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8A2BE2).withValues(alpha: 0.2),
                        border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.5)),
                      ),
                      child: Icon(Icons.videocam_outlined, color: const Color(0xFF00E5FF), size: 18.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Seat ${index + 1}',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '+ Join Video',
                      style: GoogleFonts.poppins(color: const Color(0xFFFF007F), fontSize: 9.5.sp, fontWeight: FontWeight.w600),
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
  // [ Type a message...  😊 ] (Expanded: + Send) -> 🎙️ (Mic) -> 💬 (Outside Chat) -> 🎮 (Games) -> 👑 (Frame/Outfit) -> 🎁 (Gift) -> ✈️ (Share)
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
      decoration: BoxDecoration(
        color: const Color(0xFF070913).withValues(alpha: 0.92),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ── 1. Capsule Text Field with integrated Emoji section (Expands on focus/click, revealing Send icon) ──
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 42.h,
                padding: EdgeInsets.only(left: 14.w, right: 6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2235).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: _isInputExpanded
                        ? const Color(0xFF2979FF).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.16),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        cursorColor: const Color(0xFF2979FF),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.sp),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12.5.sp,
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

                    // Inside emoji picker icon (matching reference smile)
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
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Colors.white70,
                          size: 22.sp,
                        ),
                      ),
                    ),

                    // When expanded or text entered: Show inside Send button!
                    if (_isInputExpanded || _commentController.text.trim().isNotEmpty) ...[
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          _sendMessage();
                          _commentFocusNode.unfocus();
                        },
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                            ),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // If input is expanded, user is focused on typing - collapse other action icons or show tight icons
            if (!_isInputExpanded) ...[
              SizedBox(width: 7.w),

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
                      backgroundColor: const Color(0xFF2979FF),
                    ),
                  );
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isMicMuted
                          ? [const Color(0xFFFF1744), const Color(0xFFD50000)]
                          : [const Color(0xFF2979FF), const Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isMicMuted ? const Color(0xFFFF1744) : const Color(0xFF2979FF)).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7.w),

              // ── 3. Outside Chat Icon: White circular bubble with lines, Green dot if outside unread msg else Red ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InboxScreen()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: const Color(0xFF1E2235),
                          size: 19.sp,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasUnread ? const Color(0xFF00E676) : const Color(0xFFFF1744),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 7.w),

              // ── 4. Games Gamepad Icon (White controller with crown) ──
              GestureDetector(
                onTap: () {
                  HangoutGamesSheet.show(
                    context,
                    roomId: widget.room.id,
                    roomTitle: widget.room.title,
                  );
                },
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 21.sp,
                        ),
                        Positioned(
                          top: -6.h,
                          child: const Text('👑', style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7.w),

              // ── 5. Frame Laurel / Crown Icon (Outfit & Frame equipping shop) ──
              GestureDetector(
                onTap: () {
                  ProfileFramePickerSheet.show(context);
                },
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.military_tech_rounded,
                      color: const Color(0xFFFFB300),
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 7.w),

              // ── 6. Gift Icon (Hot pink box with gold ribbon 🎁) ──
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => GiftDialog(streamerName: widget.room.title),
                  );
                },
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎁', style: TextStyle(fontSize: 22)),
                  ),
                ),
              ),
              SizedBox(width: 7.w),

              // ── 7. Share Icon (White paper airplane ✈️ / telegram arrow) ──
              GestureDetector(
                onTap: () {
                  BringMyFriendSheet.show(
                    context,
                    roomId: widget.room.id,
                    roomTitle: widget.room.title,
                  );
                },
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 19.sp,
                      ),
                    ),
                  ),
                ),
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
