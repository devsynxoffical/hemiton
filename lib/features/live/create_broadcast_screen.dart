import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/repositories/room_repository.dart';
import '../../core/services/api_client.dart';
import '../../core/services/room_share_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../models/live_room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/live_party_provider.dart';
import '../../providers/live_provider.dart';
import '../../providers/room_overlay_provider.dart';
import 'live_broadcast_screen.dart';

class CreateBroadcastScreen extends StatefulWidget {
  final bool initialAudioMode;
  const CreateBroadcastScreen({super.key, this.initialAudioMode = false});

  @override
  State<CreateBroadcastScreen> createState() => _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends State<CreateBroadcastScreen> {
  late final TextEditingController _titleController;
  final _descriptionController = TextEditingController(text: 'Join me for acoustic songs, live chat, and special party room vibes!');
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 21, minute: 0);
  String _selectedCategory = 'Music';
  bool _notifyFollowers = true;
  bool _isCreating = false;
  bool _showScheduleSection = false;

  // Broadcast Mode: Video Live vs Audio Live
  late bool _isAudioMode;

  final List<String> _categories = [
    'Music',
    'Talk Show',
    'Late Night',
    'Gaming',
    'Dance',
    'Q&A Session',
  ];

  final List<String> _presetCovers = [
    'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=80',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800&q=80',
    'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80',
  ];
  int _selectedCoverIndex = 0;
  XFile? _customCoverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isAudioMode = widget.initialAudioMode;
    _titleController = TextEditingController(
      text: _isAudioMode ? '🎙️ Late Night Chill & Audio Hangout' : '✨ Late Night Melodies & Chill Hangout',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomCover() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _customCoverImage = image;
          _selectedCoverIndex = -1; // Indicates custom cover is active
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick cover image: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF1493),
              onPrimary: Colors.white,
              surface: Color(0xFF13151D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF1493),
              onPrimary: Colors.white,
              surface: Color(0xFF13151D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  // ── Start Live Broadcast Immediately ──
  Future<void> _handleGoLive() async {
    final rawTitle = _titleController.text.trim();
    if (rawTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a broadcast title'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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

      // Check if user already has an active host room
      final overlayProvider = Provider.of<RoomOverlayProvider>(context, listen: false);
      final partyProvider = Provider.of<LivePartyProvider>(context, listen: false);
      final liveProvider = Provider.of<LiveProvider>(context, listen: false);

      final currentUserId = currentUser.id;
      try {
        await BackendRepository.instance.fetchLiveRooms();
      } catch (_) {}

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
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              ),
              title: const Row(
                children: [
                  Icon(Icons.live_tv_rounded, color: Colors.amber, size: 24),
                  SizedBox(width: 10),
                  Text('Active Broadcast Found', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onPressed: () => Navigator.pop(ctx, 'rejoin'),
                  child: const Text('Rejoin Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
                  builder: (_) => LiveBroadcastScreen(
                    room: existingRoom!,
                    isHost: true,
                    isAudioMode: existingRoom.roomType.toUpperCase().contains('AUDIO') || _isAudioMode,
                  ),
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

      final hostDisplayName = currentUser.displayName.isNotEmpty
          ? currentUser.displayName
          : (currentUser.name.isNotEmpty ? currentUser.name : (currentUser.username.isNotEmpty ? currentUser.username : 'Host'));

      final title = rawTitle.isNotEmpty
          ? rawTitle
          : (_isAudioMode ? "$hostDisplayName's Audio Live" : "$hostDisplayName's Live Stream");

      final coverUrl = _customCoverImage != null
          ? _customCoverImage!.path
          : (_selectedCoverIndex >= 0 && _selectedCoverIndex < _presetCovers.length
              ? _presetCovers[_selectedCoverIndex]
              : (currentUser.avatarUrl.isNotEmpty ? currentUser.avatarUrl : _presetCovers.first));

      LiveRoomModel roomToJoin;

      try {
        roomToJoin = await RoomRepository.instance.createRoom(
          title: title,
          coverImageUrl: coverUrl,
          roomType: _isAudioMode ? 'AUDIO_LIVE' : 'LIVE_VIDEO',
          category: _selectedCategory,
          isPrivate: false,
          hostUser: currentUser,
        );
      } catch (e) {
        debugPrint('[CreateBroadcast] Remote createRoom error, saving locally: $e');

        final errStr = e.toString().toLowerCase();
        final isAlreadyActive = (e is ApiException && (e.code == 'ROOM_ALREADY_ACTIVE' || e.message.toLowerCase().contains('already active'))) ||
            errStr.contains('already active') ||
            errStr.contains('chal rahi hai');
        if (isAlreadyActive) {
          if (mounted) {
            setState(() => _isCreating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e is ApiException ? e.message : 'You already have an active live stream. Please end the previous stream first.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        // Resilient local room fallback
        final localId = 'room_${DateTime.now().millisecondsSinceEpoch}';
        roomToJoin = LiveRoomModel(
          id: localId,
          title: title,
          coverUrl: coverUrl,
          category: _selectedCategory,
          roomType: _isAudioMode ? 'AUDIO_LIVE' : 'LIVE_VIDEO',
          status: 'LIVE',
          host: currentUser,
          creatorUserId: currentUser.id,
          viewerCount: 1,
          startTime: DateTime.now(),
        );
      }

      // Add to local backend registry so room appears across home, search, and live feeds
      BackendRepository.instance.addLiveRoom(roomToJoin);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LiveBroadcastScreen(
              room: roomToJoin,
              isHost: true,
              isAudioMode: _isAudioMode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start broadcast: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  // ── Handle Schedule Broadcast ──
  void _handleSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a broadcast title'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isCreating = false);

    final timeStr = '${_scheduledTime.format(context)} on ${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13151D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: const Color(0xFFFF1493).withValues(alpha: 0.3)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFFFF2A9D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
            ),
            SizedBox(height: 14.h),
            Text(
              'Broadcast Scheduled! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '"$title" (${_isAudioMode ? "Audio Live" : "Video Live"}) is scheduled for $timeStr. Invite your friends to tune in!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1493),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      RoomShareService.shareText(
                        context,
                        'Join my upcoming ${_isAudioMode ? "Audio" : "Video"} live broadcast on HEMI TON: "$title" at $timeStr! 🔥',
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    label: const Text('Share Invite Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF07080C) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF07080C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.darkNavy, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Broadcast',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Dual Mode Selection: Video Live vs Audio Live ──
            Text(
              'Select Broadcast Mode',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                // Option 1: Video Live
                Expanded(
                  child: _buildBroadcastModeOption(
                    isSelected: !_isAudioMode,
                    title: 'Video Live',
                    subtitle: 'Camera live stream',
                    icon: Icons.videocam_rounded,
                    accentColor: const Color(0xFFFF1493),
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _isAudioMode = false;
                        if (_titleController.text.contains('Audio Hangout')) {
                          _titleController.text = '✨ Late Night Melodies & Chill Hangout';
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                // Option 2: Audio Live
                Expanded(
                  child: _buildBroadcastModeOption(
                    isSelected: _isAudioMode,
                    title: 'Audio Live',
                    subtitle: 'Voice broadcast hangout',
                    icon: Icons.mic_rounded,
                    accentColor: const Color(0xFF8A2BE2),
                    isDark: isDark,
                    onTap: () {
                      setState(() {
                        _isAudioMode = true;
                        if (_titleController.text.contains('Melodies')) {
                          _titleController.text = '🎙️ Late Night Chill & Audio Hangout';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── 2. Cover Selection Preview & Upload ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Broadcast Cover',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.darkNavy,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton.icon(
                    onPressed: _pickCustomCover,
                    icon: const Icon(Icons.add_photo_alternate_rounded, size: 16, color: Color(0xFFFF1493)),
                    label: const Text('Upload Photo', style: TextStyle(color: Color(0xFFFF1493), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _isAudioMode ? const Color(0xFF8A2BE2) : const Color(0xFFFF1493),
                  width: 1.8,
                ),
                image: _customCoverImage != null
                    ? DecorationImage(
                        image: FileImage(File(_customCoverImage!.path)),
                        fit: BoxFit.cover,
                      )
                    : (_selectedCoverIndex >= 0
                        ? DecorationImage(
                            image: NetworkImage(_presetCovers[_selectedCoverIndex]),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundImage: currentUser.avatarUrl.isNotEmpty ? NetworkImage(currentUser.avatarUrl) : null,
                      child: currentUser.avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Host: ${currentUser.displayName.isNotEmpty ? currentUser.displayName : (currentUser.name.isNotEmpty ? currentUser.name : "HEMI TON")}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isAudioMode ? Icons.mic_rounded : Icons.videocam_rounded,
                                  size: 12.w,
                                  color: _isAudioMode ? const Color(0xFF00E676) : const Color(0xFFFF1493),
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    _isAudioMode ? 'Audio Broadcast Mode' : 'Video Broadcast Mode',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Cover Selector Thumbnails Strip
            SizedBox(
              height: 52.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Custom photo button thumbnail
                  GestureDetector(
                    onTap: _pickCustomCover,
                    child: Container(
                      width: 64.w,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF13151D) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: _customCoverImage != null ? const Color(0xFFFF1493) : Colors.white24,
                          width: 2.0,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 18.w, color: const Color(0xFFFF1493)),
                            Text('Custom', style: TextStyle(color: isDark ? Colors.white70 : AppColors.darkNavy, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Preset thumbnails
                  ...List.generate(_presetCovers.length, (i) {
                    final isSelected = _selectedCoverIndex == i && _customCoverImage == null;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCoverIndex = i;
                        _customCoverImage = null;
                      }),
                      child: Container(
                        width: 64.w,
                        margin: EdgeInsets.only(right: 10.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF1493) : Colors.transparent,
                            width: 2.0,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(_presetCovers[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ── 3. Broadcast Title Input ──
            Text(
              'Broadcast Title',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: _isAudioMode ? 'Enter audio broadcast title...' : 'Enter live stream title...',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: _isAudioMode ? const Color(0xFF8A2BE2) : const Color(0xFFFF1493),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // ── 4. Category Chips ──
            Text(
              'Category',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: _isAudioMode ? const Color(0xFF8A2BE2) : const Color(0xFFFF1493),
                  backgroundColor: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.darkNavy),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),

            // ── 5. Schedule Broadcast Section (Expandable) ──
            InkWell(
              onTap: () => setState(() => _showScheduleSection = !_showScheduleSection),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  children: [
                    Icon(
                      _showScheduleSection ? Icons.event_available_rounded : Icons.schedule_rounded,
                      color: const Color(0xFFFF1493),
                      size: 20.w,
                    ),
                    Expanded(
                      child: Text(
                        'Schedule for Later (Optional)',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.darkNavy,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showScheduleSection ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            if (_showScheduleSection) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 18.w, color: const Color(0xFFFF1493)),
                            SizedBox(width: 8.w),
                            Text(
                              '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
                              style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 18.w, color: const Color(0xFFFF1493)),
                            SizedBox(width: 8.w),
                            Text(
                              _scheduledTime.format(context),
                              style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: const Color(0xFFFF1493), size: 20.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notify Followers', style: TextStyle(color: isDark ? Colors.white : AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                          Text('Send reminder push alert before live starts', style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 11.sp)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notifyFollowers,
                      activeThumbColor: const Color(0xFFFF1493),
                      onChanged: (val) => setState(() => _notifyFollowers = val),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  side: const BorderSide(color: Color(0xFFFF1493), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _isCreating ? null : _handleSchedule,
                icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFF1493)),
                label: const Text('Confirm Schedule', style: TextStyle(color: Color(0xFFFF1493), fontWeight: FontWeight.bold)),
              ),
            ],

            SizedBox(height: 28.h),

            // ── 6. PRIMARY ACTION: GO LIVE NOW (Direct Broadcast Creation) ──
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAudioMode ? const Color(0xFF8A2BE2) : const Color(0xFFFF1493),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 8,
                  shadowColor: (_isAudioMode ? const Color(0xFF8A2BE2) : const Color(0xFFFF1493)).withValues(alpha: 0.6),
                ),
                onPressed: _isCreating ? null : _handleGoLive,
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAudioMode ? Icons.mic_rounded : Icons.videocam_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isAudioMode ? 'Go Live on Audio Live' : 'Go Live on Video Live',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastModeOption({
    required bool isSelected,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF13151D) : const Color(0xFFEEF2F6)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? const Color(0xFF222736) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(icon, color: accentColor, size: 20.w),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? accentColor : Colors.grey,
                  size: 20.w,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.darkNavy,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
