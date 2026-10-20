import 'package:flutter/material.dart';
import '../models/hangout_media_queue_model.dart';
import '../providers/live_party_provider.dart';

class HangoutTogetherSheet extends StatefulWidget {
  final LivePartyProvider? partyProvider;
  final String currentUserId;
  final String currentUserName;
  final bool isHost;

  const HangoutTogetherSheet({
    super.key,
    this.partyProvider,
    this.currentUserId = 'me_user',
    this.currentUserName = 'Me',
    this.isHost = true,
  });

  static Future<void> show(
    BuildContext context, {
    LivePartyProvider? partyProvider,
    String currentUserId = 'me_user',
    String currentUserName = 'Me',
    bool isHost = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HangoutTogetherSheet(
        partyProvider: partyProvider,
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        isHost: isHost,
      ),
    );
  }

  @override
  State<HangoutTogetherSheet> createState() => _HangoutTogetherSheetState();
}

class _HangoutTogetherSheetState extends State<HangoutTogetherSheet> {
  final TextEditingController _urlController = TextEditingController();
  double _mediaVolume = 0.7;
  double _voiceVolume = 0.9;
  bool _isPlaying = true;
  int _currentPositionSeconds = 45;

  HangoutMediaItem? _currentTrack;
  final List<HangoutMediaItem> _queue = [];

  final List<Map<String, String>> _presets = [
    {'title': 'Lofi Chill Beats ☕', 'videoId': 'jfKfPfyJRdk', 'duration': '240'},
    {'title': 'Top Party Anthems 💃', 'videoId': '2Vv-BfVoq4g', 'duration': '210'},
    {'title': 'Deep Synthwave Ride 🌃', 'videoId': '4xDzrJKXOOY', 'duration': '195'},
    {'title': 'Acoustic Coffee Hangout 🎸', 'videoId': 'eBGIQ7ZuuiU', 'duration': '225'},
  ];

  @override
  void initState() {
    super.initState();
    _initDefaultTracks();
  }

  void _initDefaultTracks() {
    final provider = widget.partyProvider;
    if (provider != null && provider.youtubeVideoId != null) {
      _currentTrack = HangoutMediaItem(
        id: 'active_1',
        videoId: provider.youtubeVideoId!,
        title: provider.youtubeTitle.isNotEmpty ? provider.youtubeTitle : 'YouTube Hangout Stream',
        thumbnailUrl: 'https://img.youtube.com/vi/${provider.youtubeVideoId}/hqdefault.jpg',
        durationSeconds: 240,
        addedById: widget.currentUserId,
        addedByName: widget.currentUserName,
        upvotedByUserIds: [widget.currentUserId, 'friend_1'],
      );
      _isPlaying = provider.youtubePlayState == 'playing';
      _currentPositionSeconds = provider.youtubePositionSeconds;
    } else {
      _currentTrack = HangoutMediaItem(
        id: 'cur_01',
        videoId: 'jfKfPfyJRdk',
        title: 'Lofi Hip Hop Radio — Beats to Relax & Study',
        thumbnailUrl: 'https://img.youtube.com/vi/jfKfPfyJRdk/hqdefault.jpg',
        durationSeconds: 300,
        addedById: widget.currentUserId,
        addedByName: widget.currentUserName,
        upvotedByUserIds: [widget.currentUserId, 'user_2'],
      );
    }

    _queue.addAll([
      HangoutMediaItem(
        id: 'q_01',
        videoId: '2Vv-BfVoq4g',
        title: 'Ed Sheeran — Shape of You (Party Remix)',
        thumbnailUrl: 'https://img.youtube.com/vi/2Vv-BfVoq4g/hqdefault.jpg',
        durationSeconds: 235,
        addedById: 'user_sophia',
        addedByName: 'Sophia',
        upvotedByUserIds: ['user_sophia', 'user_leo', 'user_emma'],
      ),
      HangoutMediaItem(
        id: 'q_02',
        videoId: '4xDzrJKXOOY',
        title: 'The Weeknd — Blinding Lights (Hangout Live)',
        thumbnailUrl: 'https://img.youtube.com/vi/4xDzrJKXOOY/hqdefault.jpg',
        durationSeconds: 200,
        addedById: 'user_alex',
        addedByName: 'Alex K.',
        upvotedByUserIds: ['user_alex'],
      ),
    ]);
    _sortQueue();
  }

  void _sortQueue() {
    _queue.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (widget.partyProvider != null) {
      widget.partyProvider!.setYouTubePlayState(_isPlaying ? 'playing' : 'paused');
    }
  }

  void _skipTrack() {
    if (_queue.isEmpty) return;
    setState(() {
      _currentTrack = _queue.removeAt(0);
      _isPlaying = true;
      _currentPositionSeconds = 0;
    });
    if (widget.partyProvider != null && _currentTrack != null) {
      widget.partyProvider!.startYouTubeTrack(
        videoId: _currentTrack!.videoId,
        title: _currentTrack!.title,
        sessionId: 'yt_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  void _addTrack(String title, String videoId, int durationSeconds) {
    final newItem = HangoutMediaItem(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      title: title,
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      durationSeconds: durationSeconds,
      addedById: widget.currentUserId,
      addedByName: widget.currentUserName,
      upvotedByUserIds: [widget.currentUserId],
    );

    setState(() {
      _queue.add(newItem);
      _sortQueue();
      _urlController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎶 Added "$title" to shared queue!'),
        backgroundColor: const Color(0xFF6C5CE7),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleUpvote(int index) {
    setState(() {
      _queue[index] = _queue[index].toggleUpvote(widget.currentUserId);
      _sortQueue();
    });
  }

  void _removeTrack(int index) {
    setState(() {
      _queue.removeAt(index);
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF161224),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_video_rounded, color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hangout Together Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Synchronized audio & video streaming with friends',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Now Playing Card
                  if (_currentTrack != null) _buildNowPlayingCard(),

                  const SizedBox(height: 18),

                  // Volume Balance Sliders
                  _buildVolumeBalanceCard(),

                  const SizedBox(height: 20),

                  // Quick Suggestion Chips
                  const Text(
                    'Quick Add Presets',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _presets.map((preset) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            backgroundColor: const Color(0xFF261D3B),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            avatar: const Icon(Icons.add, size: 16, color: Colors.amber),
                            label: Text(
                              preset['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            onPressed: () {
                              _addTrack(
                                preset['title']!,
                                preset['videoId']!,
                                int.parse(preset['duration']!),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Add YouTube URL or Search
                  _buildAddTrackInput(),

                  const SizedBox(height: 24),

                  // Queue Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Shared Queue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_queue.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Upvoted plays next',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Queue List
                  if (_queue.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.playlist_play_rounded, size: 40, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: 8),
                          const Text(
                            'Shared queue is empty',
                            style: TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add YouTube links or tap presets above!',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._queue.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildQueueItem(index, item);
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlayingCard() {
    final track = _currentTrack!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE94057).withValues(alpha: 0.25),
            const Color(0xFF8A2387).withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE94057).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'STREAMING LIVE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Added by ${track.addedByName}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 54,
                  height: 54,
                  color: Colors.black38,
                  child: const Icon(Icons.music_note_rounded, color: Colors.amber, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_currentPositionSeconds)} / ${_formatDuration(track.durationSeconds)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          LinearProgressIndicator(
            value: track.durationSeconds > 0 ? (_currentPositionSeconds / track.durationSeconds).clamp(0.0, 1.0) : 0.0,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 4,
          ),
          const SizedBox(height: 10),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 24),
                onPressed: () {
                  setState(() {
                    _currentPositionSeconds = (_currentPositionSeconds - 10).clamp(0, track.durationSeconds);
                  });
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                  color: Colors.amber,
                  size: 44,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 24),
                onPressed: () {
                  setState(() {
                    _currentPositionSeconds = (_currentPositionSeconds + 10).clamp(0, track.durationSeconds);
                  });
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                onPressed: _queue.isNotEmpty ? _skipTrack : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Audio Balance Mixer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Media ${( _mediaVolume * 100).round()}% | Voice ${(_voiceVolume * 100).round()}%',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Media Volume Slider
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              const SizedBox(
                width: 50,
                child: Text('Music', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.amber,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: Colors.amber,
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _mediaVolume,
                    onChanged: (v) => setState(() => _mediaVolume = v),
                  ),
                ),
              ),
            ],
          ),
          // Voice Volume Slider
          Row(
            children: [
              const Icon(Icons.mic_rounded, color: Color(0xFF6C5CE7), size: 18),
              const SizedBox(width: 8),
              const SizedBox(
                width: 50,
                child: Text('Voice', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6C5CE7),
                    inactiveTrackColor: Colors.white12,
                    thumbColor: const Color(0xFF6C5CE7),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _voiceVolume,
                    onChanged: (v) => setState(() => _voiceVolume = v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddTrackInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: Colors.white60, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Paste YouTube link or song name...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              final text = _urlController.text.trim();
              if (text.isEmpty) return;
              final videoId = text.contains('v=') ? text.split('v=').last.split('&').first : 'dQw4w9WgXcQ';
              _addTrack(text, videoId, 190);
            },
            child: const Text('Queue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItem(int index, HangoutMediaItem item) {
    final isUpvoted = item.isUpvotedBy(widget.currentUserId);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUpvoted ? const Color(0xFF6C5CE7).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Track rank number
          Text(
            '#${index + 1}',
            style: TextStyle(
              color: index == 0 ? Colors.amber : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 10),
          // Track icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note_rounded, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 12),
          // Title & Added by
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Added by ${item.addedByName} • ${_formatDuration(item.durationSeconds)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          ),
          // Upvote button
          InkWell(
            onTap: () => _toggleUpvote(index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isUpvoted ? const Color(0xFF6C5CE7).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUpvoted ? const Color(0xFF6C5CE7) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUpvoted ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                    color: isUpvoted ? const Color(0xFFA29BFE) : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.upvoteCount}',
                    style: TextStyle(
                      color: isUpvoted ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isHost || item.addedById == widget.currentUserId) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeTrack(index),
            ),
          ],
        ],
      ),
    );
  }
}
