import 'package:flutter/material.dart';
import '../models/social_circle_model.dart';

class SocialCircleSheet extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const SocialCircleSheet({
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
      builder: (ctx) => SocialCircleSheet(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  State<SocialCircleSheet> createState() => _SocialCircleSheetState();
}

class _SocialCircleSheetState extends State<SocialCircleSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SocialCircleModel> _myCircles = [];
  final List<SocialCircleModel> _discoverCircles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initDemoCircles();
  }

  void _initDemoCircles() {
    _myCircles.addAll([
      SocialCircleModel(
        id: 'circle_01',
        name: 'Night Owls Chill 🌙',
        description: 'Late night lofi music, chill talks, and gaming hangouts.',
        avatarUrl: '',
        creatorId: widget.currentUserId,
        creatorName: widget.currentUserName,
        privacy: SocialCirclePrivacy.open,
        memberCount: 8,
        tags: ['Chill', 'LateNight', 'Music'],
        activeRoomId: 'room_owls_1',
        activeRoomTitle: 'Midnight Vibes & Lofi Beats',
        members: [
          SocialCircleMember(userId: widget.currentUserId, name: widget.currentUserName, role: 'owner'),
          SocialCircleMember(userId: 'u_sophia', name: 'Sophia', role: 'admin'),
          SocialCircleMember(userId: 'u_alex', name: 'Alex K.', role: 'member'),
        ],
      ),
      SocialCircleModel(
        id: 'circle_02',
        name: 'The Elite Squad 👑',
        description: 'Private hangouts for the core inner squad. Invite only.',
        avatarUrl: '',
        creatorId: 'u_sophia',
        creatorName: 'Sophia',
        privacy: SocialCirclePrivacy.inviteOnly,
        memberCount: 5,
        tags: ['Besties', 'VIP', 'Hangout'],
        members: [
          SocialCircleMember(userId: 'u_sophia', name: 'Sophia', role: 'owner'),
          SocialCircleMember(userId: widget.currentUserId, name: widget.currentUserName, role: 'member'),
        ],
      ),
    ]);

    _discoverCircles.addAll([
      SocialCircleModel(
        id: 'circle_03',
        name: 'Global Gaming Den 🎮',
        description: 'Multiplayer battles, trivia showdowns, and live streams.',
        avatarUrl: '',
        creatorId: 'u_leo',
        creatorName: 'Leo Gamer',
        privacy: SocialCirclePrivacy.open,
        memberCount: 24,
        tags: ['Gaming', 'Trivia', 'Battle'],
        activeRoomId: 'room_gaming_9',
        activeRoomTitle: 'Hangout Trivia Championship!',
      ),
      SocialCircleModel(
        id: 'circle_04',
        name: 'Anime & Manga Fanatics ⚡',
        description: 'Discussing weekly anime episodes, cosplay, and OSTs.',
        avatarUrl: '',
        creatorId: 'u_emma',
        creatorName: 'Emma R.',
        privacy: SocialCirclePrivacy.open,
        memberCount: 19,
        tags: ['Anime', 'Manga', 'Otaku'],
      ),
      SocialCircleModel(
        id: 'circle_05',
        name: 'Acoustic Sessions 🎸',
        description: 'Live singing, guitar sessions, and karaoke hangout.',
        avatarUrl: '',
        creatorId: 'u_liam',
        creatorName: 'Liam Music',
        privacy: SocialCirclePrivacy.open,
        memberCount: 14,
        tags: ['Singing', 'Acoustic', 'Karaoke'],
      ),
    ]);
  }

  void _joinCircle(SocialCircleModel circle) {
    setState(() {
      _discoverCircles.remove(circle);
      final joined = circle.copyWith(
        memberCount: circle.memberCount + 1,
        members: [
          ...circle.members,
          SocialCircleMember(userId: widget.currentUserId, name: widget.currentUserName, role: 'member'),
        ],
      );
      _myCircles.add(joined);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Joined "${circle.name}"!'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
    );
  }

  void _leaveCircle(SocialCircleModel circle) {
    setState(() {
      _myCircles.remove(circle);
      final left = circle.copyWith(
        memberCount: (circle.memberCount - 1).clamp(0, 9999),
        members: circle.members.where((m) => m.userId != widget.currentUserId).toList(),
      );
      _discoverCircles.add(left);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Left "${circle.name}".'),
        backgroundColor: Colors.white24,
      ),
    );
  }

  void _showCreateCircleDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    SocialCirclePrivacy selectedPrivacy = SocialCirclePrivacy.open;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1A30),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Social Circle',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Circle Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'e.g. Night Owls Gang',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'What is this squad all about?',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Gaming, Chill, Beats',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Privacy Setting', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: SocialCirclePrivacy.values.map((p) {
                    final isSel = selectedPrivacy == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p.label, style: TextStyle(color: isSel ? Colors.white : Colors.white60, fontSize: 11)),
                        selected: isSel,
                        selectedColor: const Color(0xFF6C5CE7),
                        backgroundColor: const Color(0xFF261D3B),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedPrivacy = p);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final tags = tagCtrl.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final newCircle = SocialCircleModel(
                        id: 'circle_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        description: descCtrl.text.trim(),
                        creatorId: widget.currentUserId,
                        creatorName: widget.currentUserName,
                        privacy: selectedPrivacy,
                        memberCount: 1,
                        tags: tags.isNotEmpty ? tags : ['Hangout'],
                        members: [
                          SocialCircleMember(
                            userId: widget.currentUserId,
                            name: widget.currentUserName,
                            role: 'owner',
                          ),
                        ],
                      );

                      setState(() {
                        _myCircles.insert(0, newCircle);
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✨ Created Circle "$name"!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Create Circle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                    color: const Color(0xFF8A2387).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.groups_rounded, color: Color(0xFFE94057), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Social Circles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Exclusive hangout squads, spaces & close friends',
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _showCreateCircleDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: [
                Tab(text: 'My Circles (${_myCircles.length})'),
                Tab(text: 'Discover (${_discoverCircles.length})'),
              ],
            ),
          ),

          // Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCircleList(_myCircles, isMyCircles: true),
                _buildCircleList(_discoverCircles, isMyCircles: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleList(List<SocialCircleModel> list, {required bool isMyCircles}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 50, color: Colors.white.withValues(alpha: 0.25)),
            const SizedBox(height: 10),
            Text(
              isMyCircles ? 'You have not joined any circles yet' : 'No circles found',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final circle = list[index];
        return _buildCircleCard(circle, isMyCircles: isMyCircles);
      },
    );
  }

  Widget _buildCircleCard(SocialCircleModel circle, {required bool isMyCircles}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: circle.hasActiveHangout
              ? const Color(0xFFE94057).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circle avatar representation
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circle.name,
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
                      '${circle.memberCount} members • ${circle.privacy.label}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMyCircles)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _leaveCircle(circle),
                  child: const Text('Leave', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () => _joinCircle(circle),
                  child: const Text('Join', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          if (circle.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              circle.description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (circle.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: circle.tags.map((t) {
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

          // Active Hangout banner if room is live
          if (circle.hasActiveHangout) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE94057).withValues(alpha: 0.2),
                    const Color(0xFF8A2387).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE94057).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors_rounded, color: Color(0xFFE94057), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SQUAD LIVE HANGOUT',
                          style: TextStyle(
                            color: Color(0xFFE94057),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          circle.activeRoomTitle ?? 'Squad Room',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94057),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🚀 Entering ${circle.name} hangout room!'),
                          backgroundColor: const Color(0xFFE94057),
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
