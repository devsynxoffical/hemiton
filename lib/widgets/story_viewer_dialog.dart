import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_colors.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/messaging_provider.dart';
import '../features/profile/user_profile_details_screen.dart';

/// Single Story Item Model
class StoryItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String mediaUrl;
  final bool isVideo;
  final String? caption;
  final DateTime createdAt;
  final Duration duration;

  const StoryItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.mediaUrl,
    this.isVideo = false,
    this.caption,
    required this.createdAt,
    this.duration = const Duration(seconds: 5),
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Service providing story queries and active demo stories matching reference design
class StoryService {
  static final StoryService instance = StoryService._internal();
  StoryService._internal();

  // Reference demo stories matching the home screen feeds
  static final Map<String, List<StoryItem>> _demoUserStories = {
    'zainab': [
      StoryItem(
        id: 's_zainab_1',
        userId: 'u_zainab',
        userName: 'Zainab',
        userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1000&q=85',
        isVideo: false,
        caption: 'Good vibes only ✨ Sunny day in Kolkata!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      StoryItem(
        id: 's_zainab_2',
        userId: 'u_zainab',
        userName: 'Zainab',
        userAvatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1000&q=85',
        isVideo: false,
        caption: 'Getting ready for tonight\'s special broadcast 🌸',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    'mrs manson': [
      StoryItem(
        id: 's_manson_1',
        userId: 'u_manson',
        userName: 'Mrs manson',
        userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1000&q=85',
        isVideo: false,
        caption: 'Life is better when you smile 😌 Wishing you all a blessed day!',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'suman': [
      StoryItem(
        id: 's_suman_1',
        userId: 'u_suman',
        userName: 'suman',
        userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1000&q=85',
        isVideo: false,
        caption: 'Beautiful sunset vibes at the sea 🌅✨',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ],
    'riya': [
      StoryItem(
        id: 's_riya_1',
        userId: 'u_riya',
        userName: '🌸🌸riya🌸🌸',
        userAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1000&q=85',
        isVideo: false,
        caption: 'Live session starting in 15 minutes! Don\'t miss out 💕',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
    'mk khan': [
      StoryItem(
        id: 's_mk_1',
        userId: 'u_mk',
        userName: 'MK KHAN',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=1000&q=85',
        isVideo: false,
        caption: 'Chilly morning greetings from Shimla mountains 🏔️❄️',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
    'hussnain': [
      StoryItem(
        id: 's_hussnain_1',
        userId: 'u_hussnain',
        userName: 'Hussnain',
        userAvatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&q=80',
        isVideo: false,
        caption: 'City exploration with friends! ✨🏙️',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
    'abid net': [
      StoryItem(
        id: 's_abid_1',
        userId: 'u_abid',
        userName: 'Abid Net',
        userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
        isVideo: false,
        caption: 'Sunset peace at the lake 🌅',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
    'huzaifa': [
      StoryItem(
        id: 's_huzaifa_1',
        userId: 'u_huzaifa',
        userName: 'Huzaifa',
        userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
        isVideo: false,
        caption: 'Nature trip weekend 🌲🌊',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'haral': [
      StoryItem(
        id: 's_haral_1',
        userId: 'u_haral',
        userName: 'Haral',
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
        mediaUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=800&q=80',
        isVideo: false,
        caption: 'High mountain serenity 🏔️',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ],
  };

  /// Returns active stories for a specific user ID or username
  List<StoryItem> getActiveStoriesForUser({
    required String userId,
    required String userName,
    List<PostModel>? allPosts,
  }) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    // 1. Check real posts from SocialProvider
    if (allPosts != null && allPosts.isNotEmpty) {
      final realStories = allPosts.where((p) {
        final matchesUser = (userId.isNotEmpty && p.author.id == userId) ||
            (userName.isNotEmpty &&
                (p.author.displayName.toLowerCase() == userName.toLowerCase() ||
                    p.author.name.toLowerCase() == userName.toLowerCase() ||
                    p.author.username.toLowerCase() == userName.toLowerCase()));

        final isStoryPost = p.createdAt.isAfter(cutoff) &&
            (p.visibility == 'STORY' ||
                p.content.startsWith('[STORY]') ||
                p.content.contains('#story'));
        return matchesUser && isStoryPost;
      }).map((p) {
        final media = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
        final isVideo = media.endsWith('.mp4') ||
            media.endsWith('.mov') ||
            media.endsWith('.m4v') ||
            media.endsWith('.webm');
        return StoryItem(
          id: p.id,
          userId: p.author.id,
          userName: p.author.displayName.isNotEmpty
              ? p.author.displayName
              : (p.author.name.isNotEmpty ? p.author.name : userName),
          userAvatar: p.author.avatarUrl,
          mediaUrl: media,
          isVideo: isVideo,
          caption: p.content.replaceAll('[STORY]', '').replaceAll('#story', '').trim(),
          createdAt: p.createdAt,
        );
      }).toList();

      if (realStories.isNotEmpty) {
        return realStories;
      }
    }

    // 2. Fall back to demo active stories
    final normalized = userName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
    for (final entry in _demoUserStories.entries) {
      if (normalized.contains(entry.key) || entry.key.contains(normalized)) {
        return entry.value;
      }
    }

    if (userId.isNotEmpty) {
      for (final list in _demoUserStories.values) {
        if (list.any((s) => s.userId == userId)) {
          return list;
        }
      }
    }

    return [];
  }

  /// Checks whether a given user has an active story
  bool hasActiveStory({
    required String userId,
    required String userName,
    List<PostModel>? allPosts,
  }) {
    return getActiveStoriesForUser(
      userId: userId,
      userName: userName,
      allPosts: allPosts,
    ).isNotEmpty;
  }

  /// Helper to handle avatar tap: opens StoryViewer if active stories exist, else opens UserProfileDetailsScreen
  static void handleAvatarTap({
    required BuildContext context,
    required String userId,
    required String userName,
    required String avatarUrl,
    List<PostModel>? allPosts,
  }) {
    final stories = instance.getActiveStoriesForUser(
      userId: userId,
      userName: userName,
      allPosts: allPosts,
    );

    if (stories.isNotEmpty) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.95),
          pageBuilder: (_, anim, secondaryAnim) => FadeTransition(
            opacity: anim,
            child: StoryViewerScreen(stories: stories),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileDetailsScreen(
            userId: userId,
            user: UserModel(
              id: userId,
              username: userName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
              name: userName,
              avatarUrl: avatarUrl,
            ),
          ),
        ),
      );
    }
  }
}

/// Fullscreen Instagram-Style Story Viewer Screen
class StoryViewerScreen extends StatefulWidget {
  final List<StoryItem> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late int _currentIndex;
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  final TextEditingController _replyController = TextEditingController();
  bool _isPaused = false;
  bool _isLoading = false;
  bool _hasError = false;

  StoryItem get _currentStory =>
      widget.stories[_currentIndex.clamp(0, widget.stories.length - 1)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onStoryFinished();
      }
    });

    _loadCurrentStory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pausePlayback();
    } else if (state == AppLifecycleState.resumed && !_isPaused) {
      _resumePlayback();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressController.dispose();
    _videoController?.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _pausePlayback() {
    _progressController.stop();
    _videoController?.pause();
  }

  void _resumePlayback() {
    if (!_isPaused && mounted) {
      _progressController.forward();
      _videoController?.play();
    }
  }

  Future<void> _loadCurrentStory() async {
    _progressController.reset();
    _videoController?.dispose();
    _videoController = null;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final story = _currentStory;
    if (story.isVideo && story.mediaUrl.isNotEmpty) {
      try {
        if (story.mediaUrl.startsWith('http')) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl));
        } else {
          _videoController = VideoPlayerController.file(File(story.mediaUrl));
        }
        await _videoController!.initialize();
        final duration = _videoController!.value.duration;
        _progressController.duration = duration > Duration.zero
            ? duration
            : const Duration(seconds: 5);
        _videoController!.setLooping(false);
        if (!_isPaused) {
          await _videoController!.play();
        }
      } catch (_) {
        _hasError = true;
        _progressController.duration = const Duration(seconds: 5);
      }
    } else {
      _progressController.duration = story.duration;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (!_isPaused) {
        _progressController.forward(from: 0.0);
      }
    }
  }

  void _onStoryFinished() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadCurrentStory();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _nextStory() {
    _pausePlayback();
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadCurrentStory();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _previousStory() {
    _pausePlayback();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _loadCurrentStory();
    } else {
      _loadCurrentStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = _currentStory;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            Navigator.pop(context);
          }
        },
        onLongPressStart: (_) {
          setState(() {
            _isPaused = true;
          });
          _pausePlayback();
        },
        onLongPressEnd: (_) {
          setState(() {
            _isPaused = false;
          });
          _resumePlayback();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Story Media Content ──────────────────────────────────────────
            Positioned.fill(
              child: _buildMediaView(story),
            ),

            // ── Tap zones: Left (back) & Right (next) ───────────────────────
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _previousStory,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _nextStory,
                    ),
                  ),
                ],
              ),
            ),

            // ── Top Gradient Overlay ─────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140.h,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Top Bar: Segmented Progress Lines + User Header ──────────────
            Positioned(
              top: topPadding + 8.h,
              left: 14.w,
              right: 14.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Indicators
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return Row(
                        children: List.generate(widget.stories.length, (index) {
                          double fill = 0.0;
                          if (index < _currentIndex) {
                            fill = 1.0;
                          } else if (index == _currentIndex) {
                            fill = _progressController.value;
                          }
                          return Expanded(
                            child: Container(
                              height: 2.8.h,
                              margin: EdgeInsets.symmetric(horizontal: 2.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: fill.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  // User Info Row
                  Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.pink,
                        ),
                        child: CircleAvatar(
                          radius: 17.r,
                          backgroundColor: Colors.grey.shade900,
                          backgroundImage: story.userAvatar.isNotEmpty
                              ? NetworkImage(story.userAvatar)
                              : null,
                          child: story.userAvatar.isEmpty
                              ? Text(
                                  story.userName.isNotEmpty ? story.userName[0].toUpperCase() : '?',
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // User Name + Time ago
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    story.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(color: Colors.black54, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.pink,
                                  size: 13.sp,
                                ),
                              ],
                            ),
                            Text(
                              story.timeAgo,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11.sp,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Caption (if any) ─────────────────────────────────────────────
            if (story.caption != null && story.caption!.isNotEmpty)
              Positioned(
                bottom: bottomPadding + 70.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    story.caption!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // ── Bottom Reply & Reaction Bar ──────────────────────────────────
            Positioned(
              bottom: bottomPadding + 14.h,
              left: 14.w,
              right: 14.w,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _replyController,
                        cursorColor: Colors.white,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (text) {
                          _sendReply(text, story);
                        },
                        decoration: InputDecoration(
                          hintText: 'Reply to ${story.userName}...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13.sp,
                          ),
                          isDense: true,
                          filled: false,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      _sendReply(_replyController.text, story);
                    },
                    child: Container(
                      width: 42.h,
                      height: 42.h,
                      decoration: const BoxDecoration(
                        color: AppColors.pink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Liked ${story.userName}\'s story! ❤️'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.pink,
                        ),
                      );
                    },
                    child: Container(
                      width: 42.h,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_rounded, color: const Color(0xFFFF2D55), size: 22.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendReply(String text, StoryItem story) {
    if (text.trim().isEmpty) return;
    final trimmed = text.trim();
    _replyController.clear();
    try {
      final currentUserId = context.read<AuthProvider>().currentUser.id;
      context.read<MessagingProvider>().sendMessage(
            story.userId,
            '📸 Replied to your story: "$trimmed"',
            currentUserId: currentUserId,
          );
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reply sent to ${story.userName}! ✨'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMediaView(StoryItem story) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.pink),
        ),
      );
    }

    if (_hasError) {
      return Container(
        color: const Color(0xFF111116),
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_rounded, color: Colors.white38, size: 54.sp),
              SizedBox(height: 12.h),
              Text(
                'Story unavailable',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    if (story.isVideo && _videoController != null && _videoController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }

    if (story.mediaUrl.isNotEmpty) {
      final isNetwork = story.mediaUrl.startsWith('http://') || story.mediaUrl.startsWith('https://');
      if (isNetwork) {
        return Image.network(
          story.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildErrorFallback(story),
        );
      } else {
        return Image.file(
          File(story.mediaUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildErrorFallback(story),
        );
      }
    }

    return _buildErrorFallback(story);
  }

  Widget _buildErrorFallback(StoryItem story) {
    return Container(
      color: const Color(0xFF1A1C24),
      padding: EdgeInsets.all(24.w),
      child: Center(
        child: Text(
          story.caption ?? 'HEMI TON Story',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
