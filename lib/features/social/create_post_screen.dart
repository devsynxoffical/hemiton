import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/local_media_service.dart';
import '../../widgets/design/gold_button.dart';
import '../../widgets/user_avatar.dart';

class CreatePostScreen extends StatefulWidget {
  final bool isStory;
  const CreatePostScreen({super.key, this.isStory = false});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPublishing = false;
  String? _errorMessage;

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> pickedList = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedList.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedList);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select photos: $e')),
      );
    }
  }

  Future<void> _pickCameraImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImages.add(picked);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        setState(() {
          _selectedImages.add(video);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select video: $e')),
      );
    }
  }

  void _removeImageAt(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  Future<void> _publishPost() async {
    if (_isPublishing) return;

    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or select at least one photo')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      final List<String> persistentMediaPaths = [];

      // 1. Save all selected images to persistent local storage
      for (final image in _selectedImages) {
        try {
          final savedPath = await LocalMediaService.instance.saveMediaFile(
            image.path,
            subFolder: widget.isStory ? 'stories' : 'posts',
          );
          persistentMediaPaths.add(savedPath);
        } catch (saveErr) {
          debugPrint('[CreatePost] Failed to copy image to persistent storage: $saveErr');
          // Fall back to original file if readable
          if (File(image.path).existsSync()) {
            persistentMediaPaths.add(image.path);
          }
        }
      }

      // If user selected photos but none could be saved, halt and warn
      if (_selectedImages.isNotEmpty && persistentMediaPaths.isEmpty) {
        throw Exception('Unable to save selected photos to device storage. Please check permissions.');
      }

      if (!mounted) return;
      final finalContent = widget.isStory
          ? (content.isNotEmpty ? '[STORY] $content' : '[STORY] Shared a 24h story ✨')
          : (content.isNotEmpty ? content : 'Shared a moment ✨');

      final auth = context.read<AuthProvider>();
      final currentUser = auth.currentUser.id.isNotEmpty
          ? auth.currentUser
          : const UserModel(
              id: 'me',
              username: 'you',
              name: 'You',
              avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
              profileCompleted: true,
            );

      final visibility = widget.isStory ? 'STORY' : 'PUBLIC';

      // 2. Persist post model to shared local storage & feed immediately
      await context.read<SocialProvider>().createPost(
            content: finalContent,
            mediaUrls: persistentMediaPaths.isEmpty ? null : persistentMediaPaths,
            visibility: visibility,
            author: currentUser,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isStory ? 'Story shared successfully! 🌟' : 'Post shared successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[CreatePost] Publish error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to share: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.getPrimary(isDark);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isStory ? 'Create Story' : 'Create New Post'),
        actions: [
          _isPublishing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: GoldButton(
                    text: widget.isStory ? 'Share' : 'Post',
                    height: 36,
                    expand: false,
                    onPressed: _publishPost,
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(imageUrl: auth.currentUser.avatarUrl, radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: widget.isStory
                          ? "What's on your mind for this 24-hour story?"
                          : "What's happening in your live party world today?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            // Multiple Selected Photos Grid / Strip
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Photos (${_selectedImages.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _selectedImages.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      // Add more button
                      return GestureDetector(
                        onTap: _pickMultipleImages,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF13151D) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: primary.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, color: primary, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final file = _selectedImages[index];
                    final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                        file.path.toLowerCase().endsWith('.mov') ||
                        file.path.toLowerCase().endsWith('.m4v') ||
                        file.path.toLowerCase().endsWith('.webm');
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 120,
                            height: 140,
                            color: Colors.black26,
                            child: isVideo
                                ? const Center(
                                    child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 40),
                                  )
                                : Image.file(
                                    File(file.path),
                                    width: 120,
                                    height: 140,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        if (isVideo)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.videocam_rounded, color: Colors.white, size: 12),
                                  SizedBox(width: 3),
                                  Text('VIDEO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImageAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xB3000000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library_rounded, color: primary, size: 26),
                  tooltip: 'Add Photos',
                  onPressed: _pickMultipleImages,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_rounded, color: Color(0xFF00E676), size: 26),
                  tooltip: 'Add Video',
                  onPressed: _pickVideo,
                ),
                IconButton(
                  icon: Icon(Icons.camera_alt_rounded, color: isDark ? AppColors.metallicGold : AppColors.metallicBlue, size: 26),
                  tooltip: 'Take Photo',
                  onPressed: _pickCameraImage,
                ),
                IconButton(
                  icon: Icon(Icons.emoji_emotions_rounded, color: primary, size: 26),
                  tooltip: 'Add Emoji',
                  onPressed: () {
                    _contentController.text += ' 🔥✨';
                  },
                ),
                const Spacer(),
                if (_selectedImages.isNotEmpty)
                  Text(
                    '${_selectedImages.length} media attached',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
