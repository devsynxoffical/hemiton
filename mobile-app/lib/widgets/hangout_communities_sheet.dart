import 'package:flutter/material.dart';
import '../models/hangout_community_model.dart';

class HangoutCommunitiesSheet extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const HangoutCommunitiesSheet({
    super.key,
    this.currentUserId = 'me_user',
    this.currentUserName = 'Me',
  });

  static Future<void> show(
    BuildContext context, {
    String currentUserId = 'me_user',
    String currentUserName = 'Me',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HangoutCommunitiesSheet(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  State<HangoutCommunitiesSheet> createState() => _HangoutCommunitiesSheetState();
}

class _HangoutCommunitiesSheetState extends State<HangoutCommunitiesSheet> {
  String _selectedCategory = 'All';
  final List<HangoutCommunity> _communities = [];

  final List<String> _categories = [
    'All',
    'Gaming',
    'Anime',
    'Music',
    'Tech',
    'Lifestyle',
  ];

  @override
  void initState() {
    super.initState();
    _initCommunities();
  }

  void _initCommunities() {
    _communities.addAll([
      HangoutCommunity(
        id: 'comm_01',
        name: 'The Gaming Guild 🎮',
        category: 'Gaming',
        description: 'Multiplayer squads, tournament discussions, and live gameplay hangouts.',
        icon: '🎮',
        memberCount: 342,
        isMember: true,
        activeRoomsCount: 2,
        tags: ['Valorant', 'Minecraft', 'TriviaBattle'],
        featuredRoomId: 'room_gaming_1',
        featuredRoomTitle: 'Guild Midnight Tournament 🏆',
      ),
      HangoutCommunity(
        id: 'comm_02',
        name: 'Anime & Otaku Lounge 🌸',
        category: 'Anime',
        description: 'Watch anime together, discuss season finals, and voice act your favorite scenes.',
        icon: '🌸',
        memberCount: 280,
        isMember: false,
        activeRoomsCount: 1,
        tags: ['Jujutsu', 'DemonSlayer', 'Cosplay'],
        featuredRoomId: 'room_anime_1',
        featuredRoomTitle: 'Anime OST Karaoke & Chill 🎤',
      ),
      HangoutCommunity(
        id: 'comm_03',
        name: 'Lofi & Acoustic Corner ☕',
        category: 'Music',
        description: 'Chill beats, study sessions, and synchronized hangout music with friends.',
        icon: '☕',
        memberCount: 415,
        isMember: true,
        activeRoomsCount: 3,
        tags: ['LofiChill', 'StudyWithMe', 'Beats'],
        featuredRoomId: 'room_lofi_1',
        featuredRoomTitle: '24/7 Lofi Study Hangout 🎧',
      ),
      HangoutCommunity(
        id: 'comm_04',
        name: 'Tech & Code Lab 💻',
        category: 'Tech',
        description: 'Collaborate on side projects, share developer tips, and talk AI.',
        icon: '💻',
        memberCount: 190,
        isMember: false,
        activeRoomsCount: 0,
        tags: ['Flutter', 'AI', 'FullStack'],
      ),
      HangoutCommunity(
        id: 'comm_05',
        name: 'Fitness & Mindful Living 🏃',
        category: 'Lifestyle',
        description: 'Daily workout check-ins, healthy habits, and positive group motivation.',
        icon: '🏃',
        memberCount: 145,
        isMember: false,
        activeRoomsCount: 1,
        tags: ['Workout', 'Wellness', 'Motivation'],
        featuredRoomId: 'room_fitness_1',
        featuredRoomTitle: 'Morning Motivation & Q&A ☀️',
      ),
    ]);
  }

  void _toggleMembership(int index) {
    setState(() {
      final updated = _communities[index].toggleMembership();
      _communities[index] = updated;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isMember
                ? '🎉 Joined "${updated.name}"!'
                : 'Left "${updated.name}".',
          ),
          backgroundColor: updated.isMember ? const Color(0xFF6C5CE7) : Colors.white24,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _communities
        : _communities.where((c) => c.category == _selectedCategory).toList();

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hangout Communities',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Interest-based squads, clubs & live rooms',
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

          // Category Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C5CE7),
                  backgroundColor: const Color(0xFF1E1A30),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6C5CE7) : Colors.white.withValues(alpha: 0.08),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),

          // Communities List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final community = filtered[index];
                final realIndex = _communities.indexOf(community);
                return _buildCommunityCard(community, realIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(HangoutCommunity community, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: community.hasActiveRooms
              ? const Color(0xFF6C5CE7).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(community.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${community.memberCount} members • ${community.category}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: community.isMember ? const Color(0xFF261D3B) : const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => _toggleMembership(index),
                child: Text(
                  community.isMember ? 'Joined' : 'Join',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            community.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (community.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: community.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$t',
                    style: const TextStyle(color: Color(0xFFA29BFE), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],

          // Featured Active Room if any
          if (community.featuredRoomId != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                    const Color(0xFF8A2387).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors_rounded, color: Color(0xFFA29BFE), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'COMMUNITY LIVE HANGOUT',
                          style: TextStyle(
                            color: Color(0xFFA29BFE),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          community.featuredRoomTitle ?? 'Club Room',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🚀 Entering ${community.name} live room!'),
                          backgroundColor: const Color(0xFF6C5CE7),
                        ),
                      );
                    },
                    child: const Text('Enter', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
