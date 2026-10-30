import 'package:flutter/material.dart';
import '../models/matchmaking_profile_model.dart';

class FindSomeoneSheet extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String? activeRoomId;

  const FindSomeoneSheet({
    super.key,
    this.currentUserId = 'me_user',
    this.currentUserName = 'Me',
    this.activeRoomId,
  });

  static Future<void> show(
    BuildContext context, {
    String currentUserId = 'me_user',
    String currentUserName = 'Me',
    String? activeRoomId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FindSomeoneSheet(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        activeRoomId: activeRoomId,
      ),
    );
  }

  @override
  State<FindSomeoneSheet> createState() => _FindSomeoneSheetState();
}

class _FindSomeoneSheetState extends State<FindSomeoneSheet> {
  String _selectedMood = 'Chill Vibes ☕';
  final Set<String> _selectedInterests = {'Gaming', 'Anime', 'Lofi'};
  bool _isSearching = false;
  final List<MatchmakingProfile> _matches = [];

  final List<String> _moodOptions = [
    'Chill Vibes ☕',
    'Party Mode 🎉',
    'Deep Chat 🌌',
    'Gaming 🎮',
    'Music Jam 🎸',
  ];

  final List<String> _availableInterests = [
    'Gaming',
    'Anime',
    'Lofi',
    'Travel',
    'Tech',
    'Fitness',
    'Singing',
    'Art',
    'Movies',
    'Cooking',
  ];

  @override
  void initState() {
    super.initState();
    _performMatchmaking();
  }

  MatchmakingProfile get _myProfile => MatchmakingProfile(
        userId: widget.currentUserId,
        name: widget.currentUserName,
        mood: _selectedMood,
        interests: _selectedInterests.toList(),
        languages: ['English', 'Spanish'],
      );

  void _performMatchmaking() {
    final pool = [
      MatchmakingProfile(
        userId: 'match_01',
        name: 'Aria Vance',
        gender: 'female',
        age: 22,
        country: 'Canada',
        mood: 'Chill Vibes ☕',
        languages: ['English'],
        interests: ['Gaming', 'Anime', 'Lofi', 'Art'],
        bio: 'Cozy gamer & anime fanatic looking for hangout squads! 🌸',
        activeRoomId: 'room_aria_1',
      ),
      MatchmakingProfile(
        userId: 'match_02',
        name: 'Kenji Sato',
        gender: 'male',
        age: 24,
        country: 'Japan',
        mood: 'Gaming 🎮',
        languages: ['English', 'Japanese'],
        interests: ['Gaming', 'Tech', 'Music Jam 🎸'],
        bio: 'Competitive gamer & synthwave producer. Let’s play! 🕹️',
      ),
      MatchmakingProfile(
        userId: 'match_03',
        name: 'Elena Rostova',
        gender: 'female',
        age: 21,
        country: 'Germany',
        mood: 'Deep Chat 🌌',
        languages: ['English', 'German'],
        interests: ['Lofi', 'Travel', 'Art'],
        bio: 'Late night wanderer & philosophy lover. ☕',
      ),
      MatchmakingProfile(
        userId: 'match_04',
        name: 'Zack Miller',
        gender: 'male',
        age: 23,
        country: 'USA',
        mood: 'Party Mode 🎉',
        languages: ['English', 'Spanish'],
        interests: ['Gaming', 'Singing', 'Movies'],
        bio: 'Always down for party rooms and multiplayer battles! 🚀',
      ),
    ];

    setState(() {
      _isSearching = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final myProfile = _myProfile;
      pool.sort((a, b) => myProfile.calculateCompatibilityWith(b).compareTo(myProfile.calculateCompatibilityWith(a)));
      setState(() {
        _matches.clear();
        _matches.addAll(pool);
        _isSearching = false;
      });
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        if (_selectedInterests.length > 1) {
          _selectedInterests.remove(interest);
        }
      } else {
        _selectedInterests.add(interest);
      }
    });
    _performMatchmaking();
  }

  void _sendInvitation(MatchmakingProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💌 Sent hangout invitation to ${profile.name}!'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myProfile = _myProfile;

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
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radar_rounded, color: Color(0xFFA29BFE), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find Someone Like Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Smart social matchmaking by vibes, mood & interests',
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

          // Scrollable filter & matches area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood Selector
                  const Text(
                    'What’s your hangout mood right now?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _moodOptions.map((mood) {
                        final isSel = _selectedMood == mood;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              mood,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: const Color(0xFF6C5CE7),
                            backgroundColor: const Color(0xFF1E1A30),
                            side: BorderSide(
                              color: isSel ? const Color(0xFF6C5CE7) : Colors.white.withValues(alpha: 0.08),
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedMood = mood);
                                _performMatchmaking();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Interest Selector
                  const Text(
                    'Your Interest Tags (Tap to toggle)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _availableInterests.map((interest) {
                      final isSel = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(
                          '#$interest',
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.white60,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: const Color(0xFFE94057),
                        backgroundColor: const Color(0xFF1E1A30),
                        side: BorderSide(
                          color: isSel ? const Color(0xFFE94057) : Colors.white.withValues(alpha: 0.08),
                        ),
                        onSelected: (_) => _toggleInterest(interest),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Header with match count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Matches (${_matches.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isSearching)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C5CE7)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Match Cards
                  ..._matches.map((profile) {
                    final score = myProfile.calculateCompatibilityWith(profile);
                    return _buildMatchCard(profile, score);
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

  Widget _buildMatchCard(MatchmakingProfile profile, int score) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.greenAccent;
    } else if (score >= 60) {
      scoreColor = Colors.amberAccent;
    } else {
      scoreColor = const Color(0xFFA29BFE);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: score >= 80 ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar representation
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    profile.name.isNotEmpty ? profile.name[0] : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name, Age, Country
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: profile.gender == 'female' ? Colors.pinkAccent : Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${profile.age}',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.country} • ${profile.mood}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Compatibility Score Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '$score% Match',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          if (profile.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 10),

          // Shared Interests Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: profile.interests.map((t) {
              final isShared = _selectedInterests.contains(t);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isShared ? const Color(0xFF6C5CE7).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isShared ? const Color(0xFF6C5CE7) : Colors.transparent,
                  ),
                ),
                child: Text(
                  '#$t',
                  style: TextStyle(
                    color: isShared ? Colors.white : Colors.white60,
                    fontSize: 10,
                    fontWeight: isShared ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6C5CE7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('👋 Said Hi to ${profile.name}!')),
                    );
                  },
                  icon: const Icon(Icons.waving_hand_rounded, size: 14, color: Color(0xFFA29BFE)),
                  label: const Text('Say Hi', style: TextStyle(color: Color(0xFFA29BFE), fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: () => _sendInvitation(profile),
                  icon: const Icon(Icons.person_add_rounded, size: 14, color: Colors.white),
                  label: const Text('Invite', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
