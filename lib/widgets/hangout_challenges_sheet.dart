import 'package:flutter/material.dart';
import '../models/hangout_challenge_model.dart';

class HangoutChallengesSheet extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const HangoutChallengesSheet({
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
      builder: (ctx) => HangoutChallengesSheet(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
      ),
    );
  }

  @override
  State<HangoutChallengesSheet> createState() => _HangoutChallengesSheetState();
}

class _HangoutChallengesSheetState extends State<HangoutChallengesSheet> {
  final List<HangoutChallenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _initDefaultChallenges();
  }

  void _initDefaultChallenges() {
    _challenges.addAll([
      HangoutChallenge(
        id: 'c_01',
        title: 'Squad Gift Shower 🎁',
        description: 'Send 50 room gifts collectively to unlock fireworks!',
        icon: '🎁',
        targetCount: 50,
        currentProgress: 38,
        durationSeconds: 600,
        remainingSeconds: 340,
        rewardDescription: 'Room Fireworks & 2x Social XP',
        rewardBadge: '🎆',
        status: HangoutChallengeStatus.active,
        contributors: ['user_sophia', 'user_alex'],
      ),
      HangoutChallenge(
        id: 'c_02',
        title: 'Mic Marathon 🎙️',
        description: 'Have 4+ participants speak on open mic for 5 mins.',
        icon: '🎙️',
        targetCount: 300,
        currentProgress: 210,
        durationSeconds: 900,
        remainingSeconds: 450,
        rewardDescription: 'Golden Mic Halo & Top Room Rank',
        rewardBadge: '👑',
        status: HangoutChallengeStatus.active,
        contributors: ['user_host', 'user_sophia'],
      ),
      HangoutChallenge(
        id: 'c_03',
        title: 'Emoji Avalanche 🎉',
        description: 'Drop 100 live reactions to ignite the ambient neon glow.',
        icon: '⚡',
        targetCount: 100,
        currentProgress: 100,
        durationSeconds: 300,
        remainingSeconds: 0,
        rewardDescription: 'Neon Cyber Glow Unlocked',
        rewardBadge: '✨',
        status: HangoutChallengeStatus.completed,
        contributors: ['user_sophia', 'user_emma', 'user_alex'],
      ),
    ]);
  }

  void _contributeToChallenge(int index) {
    final challenge = _challenges[index];
    if (challenge.isCompleted) return;

    setState(() {
      final updated = challenge.incrementProgress(10, widget.currentUserId);
      _challenges[index] = updated;

      if (updated.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 CHALLENGE COMPLETED: "${challenge.title}"! Unlocked: ${challenge.rewardDescription}!'),
            backgroundColor: const Color(0xFF6C5CE7),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Contributed +10 to "${challenge.title}"! (${updated.currentProgress}/${updated.targetCount})'),
            backgroundColor: Colors.amber[800],
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hangout Room Challenges',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Complete group goals to unlock room rewards & celebrations',
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

          // Body
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                return _buildChallengeCard(challenge, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(HangoutChallenge challenge, int index) {
    final isDone = challenge.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : Colors.amber.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(challenge.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDone ? Colors.greenAccent : Colors.amber,
                  ),
                ),
                child: Text(
                  isDone ? 'COMPLETED' : _formatTime(challenge.remainingSeconds),
                  style: TextStyle(
                    color: isDone ? Colors.greenAccent : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar with counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${challenge.currentProgress} / ${challenge.targetCount}',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                '${challenge.percentComplete}%',
                style: TextStyle(
                  color: isDone ? Colors.greenAccent : Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: challenge.progressRatio,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? Colors.greenAccent : const Color(0xFFFF9F43),
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // Reward strip & Action button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(challenge.rewardBadge, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reward: ${challenge.rewardDescription}',
                    style: const TextStyle(color: Color(0xFFA29BFE), fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isDone)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () => _contributeToChallenge(index),
                    child: const Text('Contribute +10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  )
                else
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 4),
                      Text('Claimed', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
