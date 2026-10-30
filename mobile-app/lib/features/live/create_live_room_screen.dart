import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/repositories/room_repository.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../models/live_room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/live_party_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/room_overlay_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/design/gold_button.dart';
import 'live_room_screen.dart';

class CreateLiveRoomScreen extends StatefulWidget {
  final bool initialAudioMode;
  final bool isDailyLive;

  const CreateLiveRoomScreen({
    super.key,
    this.initialAudioMode = false,
    this.isDailyLive = false,
  });

  @override
  State<CreateLiveRoomScreen> createState() => _CreateLiveRoomScreenState();
}

class _CreateLiveRoomScreenState extends State<CreateLiveRoomScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController(text: '🔥 HEMI TON Official Live Stream! Join In!');
  String _selectedCategory = 'Music';
  bool _isPrivate = false;
  final List<String> _categories = ['Music', 'Gaming', 'Chat', 'PK', 'Live'];

  // Dual Broadcast Mode: Audio Live vs Video Live
  late bool _isAudioMode;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isCreating = false;

  XFile? _coverImage;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _isAudioMode = false;

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _initCamera();

    // Daily Live creation guard: Strictly restricted to female creators
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isDailyLive && mounted) {
        final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
        final isFemale = currentUser.gender.trim().toLowerCase() == 'female';
        if (!isFemale) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Daily Live creation is reserved for female creators. Male users can watch and browse Daily Live broadcasts.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pop(context);
        }
      }
    });
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
      debugPrint('Camera init error: $e');
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
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera controller init error: $e');
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

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick cover image: $e')),
      );
    }
  }

  @override
  void dispose() {
    _waveAnimController.dispose();
    _cameraController?.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.getPrimary(isDark);
    final currentUser = Provider.of<AuthProvider>(context).currentUser;
    final hostAvatar = currentUser.avatarUrl.isNotEmpty
        ? currentUser.avatarUrl
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(isDark),
        title: Text(
          'Create Broadcast',
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Strictly Video Live Mode (Dual audio/video options are in Create Broadcast) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF1493).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF1493).withValues(alpha: 0.4), width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.videocam_rounded, color: Color(0xFFFF1493), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video Live Stream',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Broadcast live video directly from your camera to your followers.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Main Live Preview Box (Responsive to Audio vs Video Mode) ──
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (_isAudioMode ? const Color(0xFF8A2BE2) : primary).withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: AppColors.primaryGlow(isDark, alpha: 0.25, blur: 16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: _isAudioMode
                    ? _buildAudioLivePreview(hostAvatar)
                    : _buildVideoLivePreview(primary, isDark),
              ),
            ),

            const SizedBox(height: 20),

            // Cover Image Selector Box
            InkWell(
              onTap: _pickCoverImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.getCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _coverImage != null ? primary : AppColors.getBorder(isDark),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    _coverImage != null && File(_coverImage!.path).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_coverImage!.path),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add_a_photo_rounded, size: 24, color: primary),
                          ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _coverImage != null ? 'Cover Photo Selected' : 'Tap to select room cover image',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _coverImage != null ? _coverImage!.name : 'Choose from your Photo Library',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.getTextSecondary(isDark)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            CustomTextField(
              label: 'Broadcast Title',
              hint: _isAudioMode ? 'Enter audio broadcast title' : 'Enter live stream title',
              controller: _titleController,
            ),

            const SizedBox(height: 20),

            Text(
              'Select Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: primary,
                  backgroundColor: AppColors.getCard(isDark),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.onPrimary(isDark: isDark) : AppColors.getTextSecondary(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  title: Text(
                    'Private Room',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                  subtitle: Text(
                    'Only invited users can enter',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                  value: _isPrivate,
                  activeTrackColor: primary,
                  onChanged: (val) => setState(() => _isPrivate = val),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Prominent Go Live Button
            GoldButton(
              text: _isAudioMode ? 'Go Live on Audio Live' : 'Go Live on Video Live',
              icon: _isAudioMode ? Icons.mic_rounded : Icons.videocam_rounded,
              isLoading: _isCreating,
              onPressed: _isCreating ? null : _handleGoLive,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }



  Widget _buildAudioLivePreview(String hostAvatar) {
    return Container(
      color: const Color(0xFF0F0B1E),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background concentric rings
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveAnimController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AudioPreviewPainter(progress: _waveAnimController.value),
                );
              },
            ),
          ),

          // Center Host Avatar with Glowing Border
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFF8A2BE2), Color(0xFF00BFFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: ClipOval(
                  child: Image.network(
                    hostAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Animated wave bars
              AnimatedBuilder(
                animation: _waveAnimController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(16, (i) {
                      final wave = math.sin((_waveAnimController.value * 2 * math.pi) + (i * 0.4)).abs();
                      return Container(
                        width: 3,
                        height: 5.0 + (wave * 16.0),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BFFF), Color(0xFFFF1493)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Audio Live Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, color: Color(0xFF00E676), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'AUDIO BROADCAST READY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
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

  Widget _buildVideoLivePreview(Color primary, bool isDark) {
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_isCameraInitialized &&
                  _cameraController != null &&
                  _cameraController!.value.isInitialized) {
                final cameraRatio = _cameraController!.value.aspectRatio;
                final previewRatio = 1 / cameraRatio;

                return SizedOverflowBox(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxWidth / previewRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                );
              } else {
                return Container(
                  color: AppColors.getCard(isDark),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_rounded, size: 52, color: primary),
                      const SizedBox(height: 10),
                      Text(
                        _cameras.isEmpty
                            ? 'Live Camera Ready (Simulation Mode)'
                            : 'Initializing Camera...',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),

        if (_cameras.length > 1)
          Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 20),
                onPressed: _switchCamera,
                tooltip: 'Flip Camera',
              ),
            ),
          ),

        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.liveRed.withValues(alpha: 0.6)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseAnimation(
                  minScale: 0.6,
                  maxScale: 1.0,
                  duration: Duration(milliseconds: 900),
                  child: Icon(Icons.fiber_manual_record, color: AppColors.liveRed, size: 12),
                ),
                SizedBox(width: 5),
                Text(
                  'VIDEO PREVIEW ACTIVE',
                  style: TextStyle(color: AppColors.liveRed, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleGoLive() async {
    setState(() => _isCreating = true);
    try {
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

      if (currentUser.id.isEmpty) {
        if (mounted) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in before starting a live stream.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        return;
      }

      if (widget.isDailyLive) {
        final isFemale = currentUser.gender.trim().toLowerCase() == 'female';
        if (!isFemale) {
          if (mounted) {
            setState(() => _isCreating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Daily Live creation is strictly reserved for female creators.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      }

      // Check if user already has an active host room
      final overlayProvider = Provider.of<RoomOverlayProvider>(context, listen: false);
      final partyProvider = Provider.of<LivePartyProvider>(context, listen: false);
      final liveProvider = Provider.of<LiveProvider>(context, listen: false);

      final currentUserId = currentUser.id;
      await BackendRepository.instance.fetchLiveRooms();

      LiveRoomModel? existingRoom = BackendRepository.instance.liveRooms.where((r) {
        final isMyHost = r.host.id == currentUserId || (r.creatorUserId != null && r.creatorUserId == currentUserId);
        return isMyHost && r.status.toUpperCase() == 'LIVE';
      }).firstOrNull;

      if (existingRoom == null) {
        for (final r in [overlayProvider.activeRoom, partyProvider.activeRoom, liveProvider.activeRoom]) {
          if (r != null && (r.host.id == currentUserId || r.creatorUserId == currentUserId) && r.status.toUpperCase() == 'LIVE') {
            existingRoom = r;
            break;
          }
        }
      }

      if (existingRoom != null) {
        if (mounted) {
          setState(() => _isCreating = false);
          final choice = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF161129),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.live_tv_rounded, color: Colors.amber, size: 24),
                  SizedBox(width: 10),
                  Text('Active Room Found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                'You already have an active live stream:\n"${existingRoom!.title}"\n\nWould you like to return to your previous room, or end it and start a new broadcast?',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'cancel'),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx, 'rejoin'),
                  child: const Text('Rejoin Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx, 'close_old'),
                  child: const Text('End Old & Start New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );

          if (choice == 'rejoin') {
            if (_cameraController != null) {
              try {
                await _cameraController!.dispose();
                _cameraController = null;
              } catch (_) {}
            }
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveRoomScreen(room: existingRoom!, isHost: true),
                ),
              );
            }
            return;
          } else if (choice == 'close_old') {
            setState(() => _isCreating = true);
            try {
              await RoomRepository.instance.leaveRoom(existingRoom.id);
            } catch (_) {}
            BackendRepository.instance.removeLiveRoom(existingRoom.id);
          } else {
            return;
          }
        }
      }

      final rawTitle = _titleController.text.trim();
      final hostDisplayName = currentUser.displayName.isNotEmpty
          ? currentUser.displayName
          : (currentUser.name.isNotEmpty ? currentUser.name : (currentUser.username.isNotEmpty ? currentUser.username : 'Host'));
      final title = rawTitle.isNotEmpty
          ? rawTitle
          : (_isAudioMode ? "$hostDisplayName's Audio Live" : "$hostDisplayName's Live Stream");
      final coverUrl = _coverImage != null
          ? 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=600&q=80'
          : (currentUser.avatarUrl.isNotEmpty ? currentUser.avatarUrl : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=600&q=80');

      LiveRoomModel roomToJoin;

      try {
        roomToJoin = await RoomRepository.instance.createRoom(
          title: title,
          coverImageUrl: coverUrl,
          roomType: _isAudioMode ? 'AUDIO_LIVE' : 'LIVE_VIDEO',
          category: _selectedCategory,
          isPrivate: _isPrivate,
          hostUser: currentUser,
        );
      } catch (e) {
        debugPrint('[CreateLiveRoom] Backend createRoom error: $e');

        final errStr = e.toString();
        final errLower = errStr.toLowerCase();
        final isAlreadyActive = (e is ApiException && (e.code == 'ROOM_ALREADY_ACTIVE' || e.message.toLowerCase().contains('already active'))) ||
            errLower.contains('already active') ||
            errLower.contains('chal rahi hai');
        if (isAlreadyActive) {
          if (mounted) {
            setState(() => _isCreating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e is ApiException ? e.message : 'You already have an active live stream. Please end the previous stream first.'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }

        if (mounted) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize broadcast: ${e is ApiException ? e.message : e.toString()}'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      BackendRepository.instance.addLiveRoom(roomToJoin);

      // Cleanly dispose preview camera so iOS AVFoundation releases hardware lock
      if (_cameraController != null) {
        try {
          await _cameraController!.dispose();
          _cameraController = null;
          await Future.delayed(const Duration(milliseconds: 350));
        } catch (_) {}
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => LiveRoomScreen(room: roomToJoin, isHost: true)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

class _AudioPreviewPainter extends CustomPainter {
  final double progress;

  _AudioPreviewPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 20);
    final radii = [45.0, 65.0, 88.0];

    for (int i = 0; i < radii.length; i++) {
      final baseRadius = radii[i];
      final waveOffset = math.sin((progress * 2 * math.pi) + (i * 0.8)) * 3;
      final radius = baseRadius + waveOffset;

      final paint = Paint()
        ..color = Color(0xFF8A2BE2).withValues(alpha: 0.12 - (i * 0.03))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AudioPreviewPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
