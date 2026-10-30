import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/repositories/backend_repository.dart';
import '../../core/services/local_media_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/design/gold_button.dart';
import '../../providers/social_provider.dart';
import '../../models/user_model.dart';
import 'music_picker_sheet.dart';
import '../main_layout.dart';

class UploadVideoScreen extends StatefulWidget {
  final String? videoPath;
  final bool isStory;
  const UploadVideoScreen({super.key, this.videoPath, this.isStory = false});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final _captionController = TextEditingController(text: 'Check out my new video! 🔥 #HEMI TON #trending');
  bool _isStoryUpload = false;
  String _privacySetting = 'Public';
  final List<Map<String, dynamic>> _privacyOptions = [
    {'title': 'Public', 'icon': Icons.public_rounded, 'desc': 'Everyone can view this video'},
    {'title': 'Followers', 'icon': Icons.group_rounded, 'desc': 'Only your followers can view'},
    {'title': 'Private', 'icon': Icons.lock_rounded, 'desc': 'Only you can view this video'},
  ];

  bool _allowComments = true;
  bool _allowDuet = true;
  bool _saveToDevice = false;
  String? _selectedVideoPath;
  String _selectedMusic = 'Original Sound';
  VideoPlayerController? _previewController;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusText = 'Preparing media...';
  Timer? _uploadTimer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isStoryUpload = widget.isStory;
    if (_isStoryUpload) {
      _captionController.text = 'My 24h video story ✨';
    }
    _selectedVideoPath = widget.videoPath;
    _initThumbnailPlayer();
  }

  Future<void> _initThumbnailPlayer() async {
    final path = _selectedVideoPath;
    if (path != null && path.isNotEmpty) {
      try {
        _previewController?.dispose();
        if (path.startsWith('http')) {
          _previewController = VideoPlayerController.networkUrl(Uri.parse(path));
        } else {
          _previewController = VideoPlayerController.file(File(path));
        }
        await _previewController?.initialize();
        _previewController?.setLooping(true);
        await _previewController?.play();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Thumbnail controller error: $e');
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _previewController?.dispose();
    _uploadTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null && mounted) {
        _previewController?.dispose();
        _previewController = null;
        setState(() {
          _selectedVideoPath = video.path;
        });
        await _initThumbnailPlayer();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video selection failed: $e')),
      );
    }
  }

  void _addHashtag(String tag) {
    setState(() {
      if (!_captionController.text.contains(tag)) {
        _captionController.text = '${_captionController.text.trim()} $tag';
      }
    });
  }

  Future<void> _startUploadProcess() async {
    if (_isUploading) return;

    if (_selectedVideoPath == null || _selectedVideoPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video from your gallery before publishing')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.2;
      _uploadStatusText = 'Saving video to persistent storage...';
    });

    try {
      final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final safeUser = currentUser.id.isNotEmpty
          ? currentUser
          : const UserModel(id: 'me', name: 'You', username: 'you', avatarUrl: '');

      // 1. Copy video to persistent storage so it survives cache cleanup & app restart
      final subFolder = _isStoryUpload ? 'stories' : 'videos';
      String targetVideoPath = _selectedVideoPath!;
      try {
        targetVideoPath = await LocalMediaService.instance.saveMediaFile(
          _selectedVideoPath!,
          subFolder: subFolder,
        );
      } catch (saveErr) {
        debugPrint('[UploadVideo] Persistent save error, using source: $saveErr');
      }

      setState(() {
        _uploadProgress = 0.75;
        _uploadStatusText = _isStoryUpload ? 'Publishing to 24h Status...' : 'Publishing to Moments...';
      });

      final caption = _captionController.text.trim();
      final music = _selectedMusic == 'Original Sound' ? 'Original Sound - ${safeUser.name}' : _selectedMusic;
      final realPostId = 'video_${DateTime.now().millisecondsSinceEpoch}';

      if (_isStoryUpload) {
        // 2a. Status / 24h Story: Isolate strictly to Story feed, DO NOT register in Reels / ShortVideos!
        if (mounted) {
          final social = Provider.of<SocialProvider>(context, listen: false);
          final storyCaption = caption.isNotEmpty ? '[STORY] $caption' : '[STORY] Shared a 24h video story ✨';
          await social.createPost(
            id: realPostId,
            content: storyCaption,
            mediaUrls: [targetVideoPath],
            visibility: 'STORY',
            author: safeUser,
          );
        }
      } else {
        // 2b. Register in short video feed with local persistence & notify Moments immediately
        await BackendRepository.instance.publishVideo(
          id: realPostId,
          creator: safeUser,
          videoUrl: targetVideoPath,
          caption: caption.isNotEmpty ? caption : 'Shared a new video! 🔥',
          musicTitle: music,
        );

        // 3. Register post model in SocialProvider using the same ID so it does not duplicate
        if (mounted) {
          final social = Provider.of<SocialProvider>(context, listen: false);
          await social.createPost(
            id: realPostId,
            content: caption.isNotEmpty ? caption : 'Shared a new video! 🔥',
            mediaUrls: [targetVideoPath],
            visibility: _privacySetting.toUpperCase(),
            author: safeUser,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _uploadProgress = 1.0;
        _uploadStatusText = 'Video published successfully!';
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isStoryUpload
              ? '🎉 Your video story was published to 24h Status!'
              : '🎉 Your Reel was uploaded & published to Moments!'),
          backgroundColor: AppColors.success,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final primary = AppColors.getPrimary(isDark);

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(isDark),
        title: Text(
          'Post Video',
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Selector: Reels/Moments vs 24h Story/Status
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isStoryUpload = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isStoryUpload ? const Color(0xFFFF1493) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_creation_rounded,
                              size: 16,
                              color: !_isStoryUpload ? Colors.white : AppColors.getTextSecondary(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reel / Moments',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !_isStoryUpload ? Colors.white : AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isStoryUpload = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isStoryUpload ? const Color(0xFF00B0FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_edu_rounded,
                              size: 16,
                              color: _isStoryUpload ? Colors.white : AppColors.getTextSecondary(isDark),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '24h Story / Status',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isStoryUpload ? Colors.white : AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Preview & Caption Input Section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Caption Input Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _captionController,
                              maxLines: 4,
                              maxLength: 150,
                              style: TextStyle(color: AppColors.getTextPrimary(isDark), fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Write a catchy caption & #hashtags...',
                                hintStyle: TextStyle(color: AppColors.getTextSecondary(isDark), fontSize: 13),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                counterStyle: TextStyle(color: AppColors.getTextSecondary(isDark), fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Video Cover Thumbnail Card
                      GestureDetector(
                        onTap: _pickVideo,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 95,
                            height: 130,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : AppColors.black,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primary.withValues(alpha: 0.5), width: 1.2),
                            ),
                            child: Stack(
                              children: [
                                if (_previewController != null && _previewController!.value.isInitialized)
                                  Positioned.fill(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _previewController!.value.size.width,
                                        height: _previewController!.value.size.height,
                                        child: VideoPlayer(_previewController!),
                                      ),
                                    ),
                                  ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black.withValues(alpha: 0.35),
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: primary.withValues(alpha: 0.85),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _selectedVideoPath != null ? 'Selected 🎥' : '00:15',
                                  style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

                  const Divider(height: 16),

                  // Quick Hashtag Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['#HEMI TON', '#Trending', '#LiveStream', '#Viral', '#Dance'].map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(tag),
                            labelStyle: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.bold),
                            backgroundColor: primary.withValues(alpha: 0.12),
                            side: BorderSide(color: primary.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            onPressed: () => _addHashtag(tag),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Music Selection Pill
            GestureDetector(
              onTap: () {
                MusicPickerSheet.show(context, onTrackSelected: (track) {
                  setState(() {
                    _selectedMusic = track.title;
                  });
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.getCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.music_note_rounded, color: primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Background Music: $_selectedMusic',
                        style: TextStyle(
                          color: AppColors.getTextPrimary(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Change',
                        style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // PRIVACY SETTING SELECTOR
            Text(
              'Who can watch this video',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: _privacyOptions.map((opt) {
                    final isSelected = _privacySetting == opt['title'];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? primary.withValues(alpha: 0.15) : AppColors.getSurface(isDark),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          opt['icon'] as IconData,
                          color: isSelected ? primary : AppColors.getTextSecondary(isDark),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        opt['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      subtitle: Text(
                        opt['desc'] as String,
                        style: TextStyle(
                          color: AppColors.getTextSecondary(isDark),
                          fontSize: 11,
                        ),
                      ),
                      trailing: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? primary : AppColors.getBorder(isDark),
                            width: isSelected ? 6 : 1.5,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() => _privacySetting = opt['title'] as String);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Additional Video Settings Switches
            Container(
              decoration: BoxDecoration(
                color: AppColors.getCard(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.getBorder(isDark)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Allow Comments',
                        style: TextStyle(color: AppColors.getTextPrimary(isDark), fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      value: _allowComments,
                      activeTrackColor: primary,
                      onChanged: (val) => setState(() => _allowComments = val),
                    ),
                    Divider(height: 1, color: AppColors.getBorder(isDark)),
                    SwitchListTile(
                      title: Text(
                        'Allow Duet / Stitches',
                        style: TextStyle(color: AppColors.getTextPrimary(isDark), fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      value: _allowDuet,
                      activeTrackColor: primary,
                      onChanged: (val) => setState(() => _allowDuet = val),
                    ),
                    Divider(height: 1, color: AppColors.getBorder(isDark)),
                    SwitchListTile(
                      title: Text(
                        'Save Video to Device',
                        style: TextStyle(color: AppColors.getTextPrimary(isDark), fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      value: _saveToDevice,
                      activeTrackColor: primary,
                      onChanged: (val) => setState(() => _saveToDevice = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // UPLOADING PROGRESS OR POST BUTTON
            if (_isUploading) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.getCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.getBorder(isDark)),
                ),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _uploadProgress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.getBorder(isDark),
                      color: primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _uploadStatusText,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GoldButton(
                text: 'POST VIDEO NOW',
                icon: Icons.send_rounded,
                onPressed: _startUploadProcess,
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
