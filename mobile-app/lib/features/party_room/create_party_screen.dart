import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/repositories/room_repository.dart';
import '../../core/services/api_client.dart';
import '../../core/services/media_upload_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/live_party_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/room_overlay_provider.dart';
import '../../models/live_room_model.dart';
import 'live_party_room_screen.dart';
import 'group_video_party_room_screen.dart';

class CreatePartyScreen extends StatefulWidget {
  final String? initialRoomType;
  const CreatePartyScreen({super.key, this.initialRoomType});

  @override
  State<CreatePartyScreen> createState() => _CreatePartyScreenState();
}

class _CreatePartyScreenState extends State<CreatePartyScreen> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Music';
  late String _roomType;
  int _capacity = 8;
  String _privacy = 'Public';
  String? _selectedCoverUrl;
  File? _selectedLocalImageFile;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _roomType = widget.initialRoomType ?? 'AUDIO_PARTY';
  }
  
  final List<String> _dummyCovers = [
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=600&q=80',
  ];

  // CR 31 Upload Party DP Modal & Picker Logic
  Future<void> _showDPPickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Party DP',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Free cover upload for live party creators (0 Coins)',
                style: TextStyle(color: Colors.pinkAccent, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF2A2640), shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library_rounded, color: Colors.amber),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                subtitle: const Text('JPG, PNG, WEBP supported', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF2A2640), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.cyanAccent),
                ),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Capture using device camera', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageSource(ImageSource.camera);
                },
              ),
              if (_selectedCoverUrl != null || _selectedLocalImageFile != null) ...[
                const Divider(color: Colors.white10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF3D1E2A), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  ),
                  title: const Text('Remove Party DP', style: TextStyle(color: Colors.redAccent)),
                  subtitle: const Text('Revert to default party cover', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedCoverUrl = null;
                      _selectedLocalImageFile = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Party DP removed. Default cover will be used.')),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 1080,
        maxHeight: 1080,
      );

      if (picked == null) return; // User cancelled picker

      // Validate format / extension
      final ext = picked.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        if (mounted) {
          _showInvalidImageDialog('Unsupported format (.$ext). Please select a JPG, PNG, or WEBP image.');
        }
        return;
      }

      final file = File(picked.path);
      final sizeInBytes = await file.length();
      if (sizeInBytes > 10 * 1024 * 1024) { // 10MB limit check
        if (mounted) {
          _showInvalidImageDialog('Selected image is too large (${(sizeInBytes / 1024 / 1024).toStringAsFixed(1)} MB). Maximum size is 10 MB.');
        }
        return;
      }

      // Show Crop & Preview Modal Dialog
      if (mounted) {
        _showImageCropPreviewDialog(file);
      }
    } catch (e) {
      debugPrint('[CreateParty] Pick image error: $e');
      if (mounted) {
        _showInvalidImageDialog('Failed to access camera or gallery: ${e.toString()}');
      }
    }
  }

  void _showInvalidImageDialog(String message) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Invalid Image', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(d);
              _showDPPickerOptions();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB524E4)),
            child: const Text('Retry Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showImageCropPreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Square Preview & Crop', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(imageFile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1:1 Aspect Ratio Party Cover DP',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Replace', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(d);
              setState(() {
                _selectedLocalImageFile = imageFile;
                _selectedCoverUrl = imageFile.path;
              });

              // Optional background upload to backend media server
              try {
                final result = await MediaUploadService.instance.uploadFile(
                  filePath: imageFile.path,
                  folder: 'party_dps',
                );
                if (result.url.isNotEmpty && mounted) {
                  setState(() {
                    _selectedCoverUrl = result.url;
                  });
                }
              } catch (e) {
                debugPrint('[CreatePartyDP] Remote upload note: using local path $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            child: const Text('Confirm DP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _createParty() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    if (currentUser.id.isEmpty) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in before creating a party room.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
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
      final activeOldRoom = existingRoom;
      if (mounted) {
        setState(() => _isCreating = false);
        final isExistingVideo = (activeOldRoom.roomType == 'LIVE_VIDEO');
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
                Icon(Icons.mic_external_on_rounded, color: Colors.amber, size: 24),
                SizedBox(width: 10),
                Text('Active Room Found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'You already have an active live/party stream:\n"${activeOldRoom.title}"\n\nWould you like to return to your previous room, or end it and start a new party room?',
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
                child: const Text('Rejoin Host Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => isExistingVideo
                    ? GroupVideoPartyRoomScreen(room: activeOldRoom, isHost: true)
                    : LivePartyRoomScreen(room: activeOldRoom),
              ),
            );
          }
          return;
        } else if (choice == 'close_old') {
          setState(() => _isCreating = true);
          try {
            await RoomRepository.instance.closeRoom(activeOldRoom.id);
            BackendRepository.instance.removeLiveRoom(activeOldRoom.id);
          } catch (_) {}
        } else {
          return;
        }
      }
    }

    final rawTitle = _nameController.text.trim();
    final hostDisplayName = currentUser.displayName.isNotEmpty
        ? currentUser.displayName
        : (currentUser.name.isNotEmpty ? currentUser.name : (currentUser.username.isNotEmpty ? currentUser.username : 'Host'));
    final title = rawTitle.isNotEmpty ? rawTitle : "$hostDisplayName's Party";
    final coverUrl = _selectedCoverUrl ?? (currentUser.avatarUrl.isNotEmpty ? currentUser.avatarUrl : _dummyCovers[0]);
    final isVideo = _roomType == 'LIVE_VIDEO' || _roomType == 'GROUP_VIDEO';

    LiveRoomModel roomToJoin;

    try {
      roomToJoin = await RoomRepository.instance.createRoom(
        title: title,
        coverImageUrl: coverUrl,
        roomType: _roomType,
        category: _selectedCategory,
        isPrivate: _privacy != 'Public',
        hostUser: currentUser,
      );
    } catch (e) {
      debugPrint('[CreateParty] Backend createRoom error: $e');

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
              content: Text(e is ApiException ? e.message : 'You already have an active party room. Please end your previous party before creating a new one.'),
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
            content: Text('Failed to initialize room: ${e is ApiException ? e.message : e.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _createParty,
            ),
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }

    roomToJoin = roomToJoin.copyWith(
      isPrivate: _privacy != 'Public',
      roomType: isVideo ? 'GROUP_VIDEO' : roomToJoin.roomType,
    );

    BackendRepository.instance.addLiveRoom(roomToJoin);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isVideo
              ? GroupVideoPartyRoomScreen(room: roomToJoin, isHost: true)
              : LivePartyRoomScreen(room: roomToJoin),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Create Live Party', style: TextStyle(color: AppColors.getTextPrimary(isDark))),
        iconTheme: IconThemeData(color: AppColors.getTextPrimary(isDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CR 31 Square Party Image DP with Pencil Overlay
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showDPPickerOptions,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppColors.getCard(isDark),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primaryGold, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
                            ],
                            image: _selectedLocalImageFile != null
                                ? DecorationImage(
                                    image: FileImage(_selectedLocalImageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : (_selectedCoverUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_selectedCoverUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (_selectedCoverUrl == null && _selectedLocalImageFile == null)
                              ? Center(
                                  child: Text(
                                    'Upload Party DP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade300, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.black.withValues(alpha: 0.25),
                                  ),
                                ),
                        ),
                        // Single Clean Pencil Overlay Icon
                        Positioned(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to Upload Party DP (Free)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Party Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Party Name',
                filled: true,
                fillColor: AppColors.getCard(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              isExpanded: true,
              items: ['Music', 'Chat', 'Games', 'PK Battle', 'Entertainment', 'Friends', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: AppColors.getCard(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Room Type: Group Audio Live vs Group Video Live
            DropdownButtonFormField<String>(
              initialValue: _roomType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'AUDIO_PARTY',
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '🎙️ Group Audio Live (8 - 10 Seats)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'GROUP_VIDEO',
                  child: Row(
                    children: [
                      Icon(Icons.videocam_rounded, color: Colors.pinkAccent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '📹 Group Video Live (8 - 10 Seats)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _roomType = val!),
              decoration: InputDecoration(
                labelText: 'Group Live Format',
                helperText: 'Select Audio or Video multi-seat live stream',
                filled: true,
                fillColor: AppColors.getCard(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Capacity (Strictly 8 to 10 Seats)
            DropdownButtonFormField<int>(
              initialValue: _capacity > 10 ? 10 : (_capacity < 8 ? 8 : _capacity),
              isExpanded: true,
              items: [8, 10].map((c) => DropdownMenuItem(value: c, child: Text('$c Seats (Max 10)'))).toList(),
              onChanged: (val) => setState(() => _capacity = val!),
              decoration: InputDecoration(
                labelText: 'Group Live Seat Capacity',
                helperText: 'Audio & Video group live allows max 8 to 10 people',
                filled: true,
                fillColor: AppColors.getCard(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy
            DropdownButtonFormField<String>(
              initialValue: _privacy,
              isExpanded: true,
              items: ['Public', 'Followers Only', 'Private']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => setState(() => _privacy = val!),
              decoration: InputDecoration(
                labelText: 'Privacy',
                filled: true,
                fillColor: AppColors.getCard(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createParty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCreating
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _roomType == 'LIVE_VIDEO' ? Icons.videocam_rounded : Icons.mic_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _roomType == 'LIVE_VIDEO' ? 'Start Video Live Room' : 'Start Voice Party Room',
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
}
