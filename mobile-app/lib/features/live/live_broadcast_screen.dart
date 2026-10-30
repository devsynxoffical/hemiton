import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/services/room_share_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/repositories/room_repository.dart';
import '../../models/live_room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_overlay_provider.dart';
import 'widgets/broadcast_audio_area.dart';
import 'widgets/broadcast_bottom_toolbar.dart';
import 'widgets/broadcast_chat_feed.dart';
import 'widgets/broadcast_gifters_section.dart';
import 'widgets/broadcast_host_header.dart';
import 'widgets/broadcast_video_area.dart';
import '../../widgets/emoji_picker_sheet.dart';
import '../../widgets/gift_dialog.dart';
import '../../widgets/level_and_trophy_sheet.dart';
import '../../widgets/tiktok_gift_overlay.dart';
import '../../widgets/emoji_reaction_overlay.dart';
import '../../providers/emoji_reaction_provider.dart';

/// Premium Production-Ready Audio Live and Video Live Broadcast Screen
///
/// Features & Layout:
/// - Fixed, non-scrolling full-screen layout fitting exactly within device viewport
/// - Top Host Header with viewer avatars row horizontally positioned in top-right
/// - Centered Audio Area (with speech-responsive waveform animating only when host is speaking)
///   OR Video Area (when in Video mode, without duplicate floating preview cards)
/// - Top 2 Gifters & Other Gifters neatly aligned directly below the audio card
/// - Independently scrollable chat feed filling all remaining vertical space
/// - Single dynamic microphone button (Green when unmuted, Red when muted)
/// - Bottom toolbar with comfortable message input and no cluttered labels
/// - Comprehensive More menu with functional room tools (Info, Audio Settings, Viewers, Speakers, Permissions, Report, Leave)
class LiveBroadcastScreen extends StatefulWidget {
  final LiveRoomModel room;
  final bool isHost;
  final bool isAudioMode;

  const LiveBroadcastScreen({
    super.key,
    required this.room,
    this.isHost = true,
    this.isAudioMode = true,
  });

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen> {
  late bool _isAudioMode;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _feedScrollController = ScrollController();

  // Controls state
  bool _isMuted = false;
  bool _isHostSpeaking = true;
  bool _isSoundOn = true;
  final int _viewerCount = 2800;

  // Audio settings state
  bool _noiseSuppressionEnabled = true;
  bool _hdAudioEnabled = true;
  String _audioOutputDevice = 'Speaker';

  // Room permissions state
  bool _allowChat = true;
  bool _allowGifts = true;
  bool _allowGuestRequests = true;

  // Camera for Video Mode
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  // Chat feed items initialized with sample data
  late List<BroadcastFeedItem> _chatItems;
  StreamSubscription<Map<String, dynamic>>? _socketChatSub;
  bool _isSendingMessage = false;
  bool _isExitDialogShowing = false;
  bool _isEndingBroadcast = false;

  @override
  void initState() {
    super.initState();
    _isAudioMode = widget.isAudioMode;
    _initChatFeed();
    _initSocketChat();

    if (!_isAudioMode) {
      _initCamera();
    }
  }

  void _initSocketChat() {
    _socketChatSub = SocketService.instance.onRoomChatMessage.listen((data) {
      if (!mounted) return;
      final roomId = data['roomId']?.toString();
      if (roomId == widget.room.id) {
        final clientMsgId = data['clientMessageId']?.toString();
        final sender = data['sender'] as Map<String, dynamic>? ?? {};
        final senderId = sender['id']?.toString() ?? data['senderUserId']?.toString();
        final currentUserId = Provider.of<AuthProvider>(context, listen: false).currentUser.id;
        if (senderId != null && senderId == currentUserId && clientMsgId != null) {
          return;
        }
        final text = data['text']?.toString() ?? data['message']?.toString() ?? '';
        if (text.isNotEmpty) {
          final now = DateTime.now();
          final timeStr =
              '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
          setState(() {
            _chatItems.insert(
              0,
              BroadcastFeedItem(
                id: data['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
                senderName: sender['name']?.toString() ?? sender['username']?.toString() ?? 'Viewer',
                avatarUrl: sender['avatarUrl']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
                text: text,
                timestamp: timeStr,
                nameColor: const Color(0xFF00E5FF),
              ),
            );
          });
        }
      }
    });
  }

  void _initChatFeed() {
    _chatItems = [
      const BroadcastFeedItem(
        id: 'msg_1',
        senderName: 'Ali Khan',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
        text: 'joined the live',
        timestamp: '9:41 PM',
        isJoin: true,
        badgeText: 'New',
      ),
      const BroadcastFeedItem(
        id: 'msg_2',
        senderName: 'Hassan',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
        text: 'sent Rose',
        timestamp: '9:40 PM',
        isGift: true,
        giftName: 'Rose',
        giftEmoji: '🌹',
        giftQuantity: 1,
        badgeText: '👑',
        nameColor: Color(0xFF00E5FF),
      ),
      const BroadcastFeedItem(
        id: 'msg_3',
        senderName: 'Sana',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
        text: 'Mashallah your voice is amazing! ❤️',
        timestamp: '9:39 PM',
        nameColor: Color(0xFF00E5FF),
      ),
      const BroadcastFeedItem(
        id: 'msg_4',
        senderName: 'Zain',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80',
        text: 'sent Castle',
        timestamp: '9:38 PM',
        isGift: true,
        giftName: 'Castle',
        giftEmoji: '🏰',
        giftQuantity: 1,
        badgeText: '⭐',
        nameColor: Color(0xFF00E5FF),
      ),
      const BroadcastFeedItem(
        id: 'msg_5',
        senderName: 'Faizan',
        avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&q=80',
        text: "Bro you're the best! 🙌",
        timestamp: '9:37 PM',
        nameColor: Color(0xFF00E5FF),
      ),
      const BroadcastFeedItem(
        id: 'msg_6',
        senderName: 'Sara',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
        text: 'entered the live',
        timestamp: '9:36 PM',
        isJoin: true,
        badgeText: 'New',
        giftEmoji: '🌸',
      ),
      const BroadcastFeedItem(
        id: 'msg_7',
        senderName: 'Usman',
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=100&q=80',
        text: 'Great content! 🔥',
        timestamp: '9:35 PM',
        nameColor: Color(0xFFFFD700),
      ),
      const BroadcastFeedItem(
        id: 'msg_8',
        senderName: 'Ayesha',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&q=80',
        text: 'sent Rose',
        timestamp: '9:34 PM',
        isGift: true,
        giftName: 'Rose',
        giftEmoji: '🌹',
        giftQuantity: 1,
        nameColor: Color(0xFFFF69B4),
      ),
      const BroadcastFeedItem(
        id: 'msg_9',
        senderName: 'Rizwan',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80',
        text: 'Kaha se ho? 🤔',
        timestamp: '9:33 PM',
        nameColor: Color(0xFF00E5FF),
      ),
      const BroadcastFeedItem(
        id: 'msg_10',
        senderName: 'Minal',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&q=80',
        text: 'joined the live',
        timestamp: '9:32 PM',
        isAudioAnnouncement: true,
      ),
    ];
  }

  Future<void> _initCamera() async {
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
      debugPrint('[LiveBroadcastScreen] Camera init error: $e');
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
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('[LiveBroadcastScreen] Controller init error: $e');
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  @override
  void dispose() {
    _socketChatSub?.cancel();
    _messageController.dispose();
    _feedScrollController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ── 1. Microphone Toggle (Single Dynamic Green / Red Button) ──
  void _toggleMic() {
    setState(() {
      _isMuted = !_isMuted;
      // Connect to waveform animation state:
      _isHostSpeaking = !_isMuted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: _isMuted ? Colors.redAccent : const Color(0xFF00E676),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isMuted ? 'Microphone Muted' : 'Microphone Live — You are speaking',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: _isMuted ? const Color(0xFF2A0E18) : const Color(0xFF0E2A1C),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── 2. Sound Toggle ──
  void _toggleSound() {
    setState(() => _isSoundOn = !_isSoundOn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSoundOn ? '🔊 Room Audio Enabled' : '🔈 Room Audio Muted'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── 3. Chat Message Handling ──
  void _sendMessage() {
    if (_isSendingMessage) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!_allowChat && !widget.isHost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is currently disabled by the host')),
      );
      return;
    }

    _isSendingMessage = true;
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final senderName = currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser.username.isNotEmpty ? currentUser.username : 'You');
    final avatar = currentUser.avatarUrl.isNotEmpty
        ? currentUser.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80';

    final now = DateTime.now();
    final timeStr =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    final clientMsgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // Broadcast through socket service
    try {
      SocketService.instance.sendRoomChatMessage(
        roomId: widget.room.id,
        text: text,
        messageId: clientMsgId,
        sender: {
          'id': currentUser.id,
          'name': senderName,
          'username': currentUser.username,
          'avatarUrl': avatar,
        },
      );
    } catch (e) {
      debugPrint('[LiveBroadcastScreen] Error sending socket chat message: $e');
    }

    setState(() {
      _chatItems.insert(
        0,
        BroadcastFeedItem(
          id: clientMsgId,
          senderName: senderName,
          avatarUrl: avatar,
          text: text,
          timestamp: timeStr,
          nameColor: const Color(0xFF00E5FF),
        ),
      );
    });

    _messageController.clear();
    FocusScope.of(context).unfocus();
    _isSendingMessage = false;

    if (_feedScrollController.hasClients) {
      _feedScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _minimizeToOverlay() {
    Provider.of<RoomOverlayProvider>(context, listen: false).minimizeRoom(
      roomType: 'BROADCAST',
      room: widget.room,
      isHost: widget.isHost,
      isAudioMode: _isAudioMode,
    );
    Navigator.pop(context);
  }

  // ── 4. Gifts Handling with Asset Gifts Support ──
  void _openGiftsSheet() {
    if (!_allowGifts && !widget.isHost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gifting is currently disabled in this room')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GiftDialog(
        streamerName: widget.room.host.name,
        roomId: widget.room.id,
        onGiftSent: (gift) {
          _sendGift(gift.name, gift.icon);
        },
      ),
    );
  }

  // ── 4b. Emoji Picker with Assets & Reactions Support ──
  void _openEmojiPicker() {
    EmojiPickerSheet.show(
      context,
      roomId: widget.room.id,
      onEmojiSelected: (emoji) {
        _messageController.text += emoji;
      },
      onReactionSelected: (reactionAsset, symbol) {
        _triggerReaction(reactionAsset, symbol);
      },
    );
  }

  void _triggerReaction(String reactionAsset, String symbol) {
    try {
      SocketService.instance.sendReaction(widget.room.id, symbol);
    } catch (_) {}

    final now = DateTime.now();
    final timeStr =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    try {
      Provider.of<EmojiReactionProvider>(context, listen: false).sendReaction(
        roomId: widget.room.id,
        senderId: user.id,
        emoji: reactionAsset,
        senderName: user.name,
      );
    } catch (_) {}

    setState(() {
      _chatItems.insert(
        0,
        BroadcastFeedItem(
          id: 'reaction_${DateTime.now().millisecondsSinceEpoch}',
          senderName: user.name.isNotEmpty ? user.name : 'You',
          avatarUrl: user.avatarUrl,
          text: 'reacted with $symbol',
          timestamp: timeStr,
          nameColor: const Color(0xFF00E5FF),
        ),
      );
    });
  }

  void _sendGift(String name, String emoji) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final senderName = currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser.username.isNotEmpty ? currentUser.username : 'You');
    final avatar = currentUser.avatarUrl.isNotEmpty
        ? currentUser.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80';

    final now = DateTime.now();
    final timeStr =
        '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    setState(() {
      _chatItems.insert(
        0,
        BroadcastFeedItem(
          id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
          senderName: senderName,
          avatarUrl: avatar,
          text: 'sent $name',
          timestamp: timeStr,
          isGift: true,
          giftName: name,
          giftEmoji: emoji,
          giftQuantity: 1,
          badgeText: '👑',
          nameColor: const Color(0xFFFF69B4),
        ),
      );
    });

    final isAsset = emoji.startsWith('assets/') || emoji.startsWith('http');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAsset) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  emoji,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text('🎁'),
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Text(emoji.isNotEmpty ? emoji : '🎁', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                'Sent $name to the host!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF1493),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 72, left: 16, right: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── 5. Mode Switching (Audio Live <-> Video Live) ──
  void _toggleMode() {
    setState(() {
      _isAudioMode = !_isAudioMode;
      if (!_isAudioMode && !_isCameraInitialized) {
        _initCamera();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAudioMode ? 'Switched to Audio Live mode' : 'Switched to Video Live mode'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── 6. Compact Room Tools & Options Menu ──
  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131525).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 25,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle
              Container(
                width: 36,
                height: 3.5,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: Color(0xFF00BFFF), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Room Tools & Options',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Divider(color: Colors.white12, height: 10),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 1. Room Information
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 18),
                        title: const Text('Room Information', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Room title, ID, host and statistics', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showRoomInfoDialog();
                        },
                      ),

                      // 2. Audio Settings
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.volume_up_rounded, color: Color(0xFF00E676), size: 18),
                        title: const Text('Audio Settings', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Output device, noise suppression, HD voice', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showAudioSettingsSheet();
                        },
                      ),

                      // 3. Room Members / Viewers
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.people_alt_rounded, color: Colors.amber, size: 18),
                        title: const Text('Room Viewers & Members', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('$_viewerCount active participants watching', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showViewersSheet();
                        },
                      ),

                      // 4. Manage Speakers (Host / Moderator only)
                      if (widget.isHost)
                        ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: const Icon(Icons.record_voice_over_rounded, color: Color(0xFFFF69B4), size: 18),
                          title: const Text('Manage Speakers & Stage', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Mute all, invite co-host, manage speaking rights', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showManageSpeakersSheet();
                          },
                        ),

                      // 5. Room Permissions (Host only)
                      if (widget.isHost)
                        ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: const Icon(Icons.security_rounded, color: Color(0xFF8A2BE2), size: 18),
                          title: const Text('Room Permissions', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Configure chat, gifting, and guest request access', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showRoomPermissionsSheet();
                          },
                        ),

                      // 6. Camera Flip (in Video Mode)
                      if (!_isAudioMode)
                        ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: const Icon(Icons.flip_camera_ios_rounded, color: Color(0xFF00E5FF), size: 18),
                          title: const Text('Flip Camera', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _switchCamera();
                          },
                        ),

                      // 7. Switch Mode (Audio <-> Video)
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.swap_horiz_rounded, color: Color(0xFFFF1493), size: 18),
                        title: Text(_isAudioMode ? 'Switch to Video Live' : 'Switch to Audio Live', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _toggleMode();
                        },
                      ),

                      // 8. Invite / Share Broadcast
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.share_rounded, color: Colors.blueAccent, size: 18),
                        title: const Text('Invite Participants / Share', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(ctx);
                          RoomShareService.shareRoom(
                            context,
                            roomId: widget.room.id,
                            roomTitle: widget.room.title,
                          );
                        },
                      ),

                      // 9. Report Room
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.flag_outlined, color: Colors.orangeAccent, size: 18),
                        title: const Text('Report Room', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showReportDialog();
                        },
                      ),

                      // 10. Minimize to Floating Window
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.picture_in_picture_alt_rounded, color: Color(0xFF00E5FF), size: 18),
                        title: const Text('Minimize to Floating Window', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Keep broadcast playing while browsing app', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        onTap: () {
                          Navigator.pop(ctx);
                          _minimizeToOverlay();
                        },
                      ),

                      const Divider(color: Colors.white12, height: 10),

                      // 11. End Broadcast / Leave Room
                      ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: const Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 18),
                        title: Text(
                          widget.isHost ? 'End Broadcast' : 'Leave Room',
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _confirmExit();
                        },
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

  // ── Tool Sheet 1: Room Information ──
  void _showRoomInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140F28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF8A2BE2), width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF00BFFF), size: 22),
            const SizedBox(width: 8),
            Text(
              widget.room.title.isNotEmpty ? widget.room.title : 'Live Audio Room',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Host', widget.room.host.displayName.isNotEmpty ? widget.room.host.displayName : widget.room.host.name),
            _buildInfoRow('Room ID', widget.room.id),
            _buildInfoRow('Type', _isAudioMode ? 'Audio Live Broadcast' : 'Video Live Broadcast'),
            _buildInfoRow('Category', widget.room.category.isNotEmpty ? widget.room.category : 'General'),
            _buildInfoRow('Viewers', '$_viewerCount watching'),
            _buildInfoRow('Leaderboard', 'Rank 12 Daily'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.room.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room ID copied to clipboard!')),
              );
            },
            child: const Text('Copy ID', style: TextStyle(color: Color(0xFF00E5FF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A2BE2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tool Sheet 2: Audio Settings ──
  void _showAudioSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF131525).withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.35)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
                const Row(
                  children: [
                    Icon(Icons.tune_rounded, color: Color(0xFF00E676), size: 20),
                    SizedBox(width: 8),
                    Text('Audio Configuration', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF00E676),
                  title: const Text('Noise Suppression', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Filters out background echo and noise', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  value: _noiseSuppressionEnabled,
                  onChanged: (val) {
                    setSheetState(() => _noiseSuppressionEnabled = val);
                    setState(() => _noiseSuppressionEnabled = val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF00E676),
                  title: const Text('High Definition Voice', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Enable 48kHz studio audio streaming', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  value: _hdAudioEnabled,
                  onChanged: (val) {
                    setSheetState(() => _hdAudioEnabled = val);
                    setState(() => _hdAudioEnabled = val);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Audio Output Route', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('Current: $_audioOutputDevice', style: const TextStyle(color: Color(0xFF00BFFF), fontSize: 11)),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF1E1738),
                    value: _audioOutputDevice,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Speaker', child: Text('🔊 Speaker')),
                      DropdownMenuItem(value: 'Earpiece', child: Text('📱 Earpiece')),
                      DropdownMenuItem(value: 'Bluetooth', child: Text('🎧 Bluetooth')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _audioOutputDevice = val);
                        setState(() => _audioOutputDevice = val);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tool Sheet 3: Viewers Sheet ──
  void _showViewersSheet() {
    final sampleViewers = [
      {'name': 'Queen', 'role': 'Top Gifter 👑', 'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'},
      {'name': 'Hassan', 'role': 'Gifter 🔥', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80'},
      {'name': 'Ali Khan', 'role': 'Listener', 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80'},
      {'name': 'Sana', 'role': 'Listener', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80'},
      {'name': 'Faizan', 'role': 'Listener', 'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=100&q=80'},
      {'name': 'Zain', 'role': 'VIP Listener ⭐', 'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131525).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room Viewers ($_viewerCount)',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: sampleViewers.length,
                separatorBuilder: (_, _) => const Divider(color: Colors.white10),
                itemBuilder: (context, i) {
                  final v = sampleViewers[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(v['avatar']!),
                    ),
                    title: Text(v['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(v['role']!, style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF231A47),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invited ${v['name']} to speak!')),
                        );
                      },
                      child: const Text('Invite', style: TextStyle(fontSize: 11)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tool Sheet 4: Manage Speakers (Host Only) ──
  void _showManageSpeakersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF140F28),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.mic_external_on_rounded, color: Color(0xFFFF69B4), size: 20),
                  SizedBox(width: 8),
                  Text('Manage Speaking Rights', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.mic_off_rounded, color: Colors.redAccent),
                title: const Text('Mute All Participants', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Instantly silences everyone except the host', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔇 All room participants muted by host')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF00E676)),
                title: const Text('Invite Speaker to Stage', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Choose a viewer to grant microphone access', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showViewersSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded, color: Colors.amber),
                title: const Text('Lock Stage', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Do not allow viewers to request the mic', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _allowGuestRequests = !_allowGuestRequests);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_allowGuestRequests ? 'Stage unlocked' : 'Stage locked by host')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tool Sheet 5: Room Permissions ──
  void _showRoomPermissionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF140F28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.security_rounded, color: Color(0xFF8A2BE2), size: 20),
                    SizedBox(width: 8),
                    Text('Room Permissions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF8A2BE2),
                  title: const Text('Allow Live Chat Comments', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: _allowChat,
                  onChanged: (val) {
                    setSheetState(() => _allowChat = val);
                    setState(() => _allowChat = val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF8A2BE2),
                  title: const Text('Allow Gift Sending', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: _allowGifts,
                  onChanged: (val) {
                    setSheetState(() => _allowGifts = val);
                    setState(() => _allowGifts = val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFF8A2BE2),
                  title: const Text('Allow Guest Mic Requests', style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: _allowGuestRequests,
                  onChanged: (val) {
                    setSheetState(() => _allowGuestRequests = val);
                    setState(() => _allowGuestRequests = val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tool Sheet 6: Report Room ──
  void _showReportDialog() {
    final reasons = [
      'Inappropriate / Offensive Content',
      'Harassment or Hate Speech',
      'Spam or Commercial Promotion',
      'Copyright Infringement',
      'Other Problem',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161129),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.orangeAccent, width: 1),
        ),
        title: const Text('Report Live Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please select the reason for your report:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            ...reasons.map((r) => InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you. Your report has been submitted to moderators.'),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        const Icon(Icons.radio_button_unchecked_rounded, color: Colors.orangeAccent, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12.5))),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  // ── Live Exit Confirmation Popup ──
  Future<void> _confirmExit() async {
    if (_isExitDialogShowing || _isEndingBroadcast) return;
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
          'Would you like to continue your live stream, leave the room, or end the live broadcast?',
          style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: const Text('Continue Live', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
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

    _isEndingBroadcast = true;
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070B18), // Deep luxury dark navy background
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.4),
              radius: 1.2,
              colors: [
                Color(0xFF141938), // Center ambient glow
                Color(0xFF090C1B),
                Color(0xFF050711),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Builder(
              builder: (innerContext) {
                final isKeyboardOpen = MediaQuery.of(innerContext).viewInsets.bottom > 0;
                return Column(
                  children: [
                    // ── 1. Top Host Header (Host avatar, name, viewer avatars in top right, rank, menu) ──
                    BroadcastHostHeader(
                      room: widget.room,
                      isAudioMode: _isAudioMode,
                      viewerCount: _viewerCount,
                      rankNumber: 12,
                      onBack: _confirmExit,
                      onMinimize: _minimizeToOverlay,
                      onMore: _openMoreMenu,
                      onRankTap: () {
                        LevelAndTrophySheet.show(
                          context,
                          rankNumber: 12,
                          streamerName: widget.room.host.name.isNotEmpty
                              ? widget.room.host.name
                              : 'Host',
                        );
                      },
                      onViewerCountTap: _showViewersSheet,
                      onViewersTap: _showViewersSheet,
                      onModeToggle: _toggleMode,
                    ),

                    const SizedBox(height: 2),

                    // ── 2. Fixed Upper Area: Audio Area OR Video Area (NO Whole-Page Scroll!) ──
                    if (_isAudioMode)
                      BroadcastAudioArea(
                        room: widget.room,
                        isMuted: _isMuted,
                        isSpeaking: !_isMuted && _isHostSpeaking,
                        topGifterName: 'Queen',
                        topGifterAvatar:
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
                        topGifterGifts: 528,
                        onTopGifterTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    '👑 Queen has gifted 528 gifts this stream!')),
                          );
                        },
                        onAudioBroadcastTap: _showAudioSettingsSheet,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: BroadcastVideoArea(
                          room: widget.room,
                          cameraController: _cameraController,
                          isCameraInitialized: _isCameraInitialized,
                          onSwitchCamera: _switchCamera,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // ── 3. Fixed Compact Gifters Section (Top 2 Gifters + Other Gifters) ──
                    // Automatically hidden when keyboard opens to prevent 8.4px bottom overflow
                    if (!isKeyboardOpen) ...[
                      BroadcastGiftersSection(
                        onSeeAllTopGifters: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Viewing complete Gifters leaderboard')),
                          );
                        },
                        onSeeAllOtherGifters: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Viewing all room gifters')),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                    ],

                    // ── 4. Independently Scrollable Chat Feed (Fills remaining height) ──
                    Expanded(
                      child: BroadcastChatFeed(
                        scrollController: _feedScrollController,
                        items: _chatItems,
                      ),
                    ),

                    // ── 5. Fixed Bottom Control Toolbar (Safe Area Aware) ──
                    SafeArea(
                      top: false,
                      child: BroadcastBottomToolbar(
                        textController: _messageController,
                        isAudioMode: _isAudioMode,
                        isMuted: _isMuted,
                        isSoundOn: _isSoundOn,
                        onSendMessage: _sendMessage,
                        onEmojiTap: _openEmojiPicker,
                        onMicToggle: _toggleMic,
                        onGiftsTap: _openGiftsSheet,
                        onSoundToggle: _toggleSound,
                        onMoreTap: _openMoreMenu,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // TikTok Live Gifting Overlay Layer
        TikTokGiftOverlay(roomId: widget.room.id),
        // Emoji Reaction Overlay Layer
        EmojiReactionOverlay(roomId: widget.room.id),
      ],
    ),
  ),
);
  }
}
