import 'package:flutter/material.dart';

/// Modal sheet showcasing User Level, XP Progress, Trophy Achievements, and Leaderboard Rank
class LevelAndTrophySheet extends StatelessWidget {
  final int currentLevel;
  final int currentXp;
  final int targetXp;
  final int rankNumber;
  final String streamerName;

  const LevelAndTrophySheet({
    super.key,
    this.currentLevel = 12,
    this.currentXp = 3840,
    this.targetXp = 5000,
    this.rankNumber = 12,
    this.streamerName = 'Ayesha Live',
  });

  static void show(
    BuildContext context, {
    int currentLevel = 12,
    int currentXp = 3840,
    int targetXp = 5000,
    int rankNumber = 12,
    String streamerName = 'Host',
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LevelAndTrophySheet(
        currentLevel: currentLevel,
        currentXp: currentXp,
        targetXp: targetXp,
        rankNumber: rankNumber,
        streamerName: streamerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (currentXp / targetXp).clamp(0.0, 1.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF100E24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Level & Trophy Achievements',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Level & Trophy Banner Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF281E4B), Color(0xFF1B1438), Color(0xFF120E26)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Glowing Trophy Icon
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8F00).withValues(alpha: 0.5),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.emoji_events_rounded, color: Colors.black87, size: 30),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Level Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    'Level $currentLevel',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD54F),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF1493).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFF1493), width: 0.8),
                                    ),
                                    child: Text(
                                      'Rank #$rankNumber',
                                      style: const TextStyle(
                                        color: Color(0xFFFF69B4),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Gold Star Streamer • $streamerName',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // XP Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'XP Progress',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        Text(
                          '$currentXp / $targetXp XP',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Level Perks Grid ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Current Level Perks',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPerkTile(
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFFFF1493),
                      title: 'VIP Entrance',
                      subtitle: 'Custom animation upon joining live rooms',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPerkTile(
                      icon: Icons.military_tech_rounded,
                      color: const Color(0xFF00E5FF),
                      title: 'Exclusive Badge',
                      subtitle: 'Crown badge shown next to username',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPerkTile(
                      icon: Icons.card_giftcard_rounded,
                      color: const Color(0xFFFFD54F),
                      title: 'Gift Multiplier',
                      subtitle: 'Earn 1.5x experience from every gift',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildPerkTile(
                      icon: Icons.verified_user_rounded,
                      color: const Color(0xFF00E676),
                      title: 'Stage Priority',
                      subtitle: 'Priority speaking mic in party rooms',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Level Up Tasks ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Daily XP Tasks',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _buildTaskTile('Watch live broadcasts for 10 minutes', '+50 XP', true),
              _buildTaskTile('Send any gift in an audio or video live room', '+100 XP', true),
              _buildTaskTile('Host a live broadcast session for 15 minutes', '+200 XP', false),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerkTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1633),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String title, String xpReward, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF17132B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isCompleted ? const Color(0xFF00E676) : Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.white70 : Colors.white,
                fontSize: 11.5,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              xpReward,
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
