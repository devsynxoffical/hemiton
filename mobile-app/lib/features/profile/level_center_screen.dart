import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/svip_provider.dart';
import '../svip/svip_center_screen.dart';


class LevelCenterScreen extends StatefulWidget {
  final int initialTab;

  const LevelCenterScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<LevelCenterScreen> createState() => _LevelCenterScreenState();
}

class _LevelCenterScreenState extends State<LevelCenterScreen> with SingleTickerProviderStateMixin {
  Color _getLevelColor(int level) {
    if (level <= 1) return const Color(0xFF607D8B); // Grey for 0 and 1
    if (level < 10) return const Color(0xFF29B6F6);
    if (level < 20) return const Color(0xFF66BB6A);
    if (level < 30) return const Color(0xFFFFA726);
    if (level < 40) return const Color(0xFFAB47BC);
    if (level < 50) return const Color(0xFFEF5350);
    if (level < 60) return const Color(0xFF26A69A);
    if (level < 70) return const Color(0xFFEC407A);
    if (level < 80) return const Color(0xFF5C6BC0);
    if (level < 90) return const Color(0xFFFF7043);
    return const Color(0xFFFFCA28);
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 4),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final svip = context.watch<SVIPProvider>();


    return Scaffold(
      backgroundColor: const Color(0xFF090616),
      appBar: AppBar(
        title: const Text('Level Center & Tiers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF090616),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded, color: AppColors.pink),
            tooltip: 'SVIP Privilege Center',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SVIPCenterScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.pink,
          labelColor: AppColors.pink,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Wealth'),
            Tab(text: 'Charm'),
            Tab(text: 'Game'),
            Tab(text: 'Account'),
            Tab(text: 'SVIP Tier'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Wealth Track (Sending History)
          _buildLevelTrackView(
            context,
            title: 'Wealth Level Track',
            subtitle: 'Calculated from total sending history & gifts',
            level: user.computedWealthLevel,
            currentXp: user.wealthLevelXp,
            requiredXp: 10000,
            icon: Icons.diamond_rounded,
            imagePath: 'assets/images/level_logo_wealth.png',
            color: const Color(0xFF00E5FF),
            perks: [
              '💎 Gold Crown Mic Frame',
              '👑 Wealth Rank Leaderboard Badge',
              '✨ High-Value Room Entry Banner',
              '💬 Highlighted Gold Chat Bubble',
              '⚡ Seating Priority in Voice Rooms',
            ],
            isDark: isDark,
          ),

          // 2. Charm Track (Receiving History)
          _buildLevelTrackView(
            context,
            title: 'Charm Level Track',
            subtitle: 'Calculated from gifts received & popularity',
            level: user.computedCharmLevel,
            currentXp: user.charmLevelXp,
            requiredXp: 10000,
            icon: Icons.favorite_rounded,
            imagePath: 'assets/images/level_logo_charm.png',
            color: const Color(0xFFFF4081),
            perks: [
              '💖 Sweet Heart Avatar Frame',
              '🌹 Charm Superstar Rank Badge',
              '🎉 Popularity Entry Announcement',
              '🎙️ Stage Host Mic Glow Effect',
            ],
            isDark: isDark,
          ),

          // 3. Game Track (Game Volume & Win History)
          _buildLevelTrackView(
            context,
            title: 'Game Level Track',
            subtitle: 'Calculated from game participation & win volume',
            level: user.computedGameLevel,
            currentXp: user.gameLevelXp,
            requiredXp: 10000,
            icon: Icons.sports_esports_rounded,
            imagePath: 'assets/images/level_logo_game.png',
            color: const Color(0xFFB388FF),
            perks: [
              '🎮 Game Master Profile Badge',
              '🎰 Super Wheel Spin Multiplier Boost',
              '🚀 Rocket Launch Bonus Coins',
              '🏆 Victory Soundboard Sound Unlock',
            ],
            isDark: isDark,
          ),

          // 4. Account Level Track (Overall Platform Activity)
          _buildLevelTrackView(
            context,
            title: 'Account Level Track',
            subtitle: 'Calculated from total platform activity & tenure',
            level: user.computedAccountLevel,
            currentXp: user.accountLevelXp,
            requiredXp: 10000,
            icon: Icons.stars_rounded,
            imagePath: 'assets/images/level_logo_account.png',
            color: const Color(0xFF00E676),
            perks: [
              '⭐ Veteran Account Status Badge',
              '🛡️ Enhanced Profile Security Perks',
              '🎁 Daily Loyalty Bonus Multiplier',
              '💬 Priority Customer Support Response',
            ],
            isDark: isDark,
          ),

          // 5. SVIP Track
          _buildSvipTrackView(context, user, svip, isDark),
        ],
      ),
    );
  }

  Widget _buildLevelTrackView(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int level,
    required int currentXp,
    required int requiredXp,
    required IconData icon,
    String? imagePath,
    required Color color,
    required List<String> perks,
    required bool isDark,
  }) {
    final progress = (currentXp / requiredXp).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.22), const Color(0xFF140D28)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: imagePath != null
                      ? Image.asset(imagePath, width: 36, height: 36,
                          errorBuilder: (_, __, ___) => Icon(icon, size: 28, color: color))
                      : Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 8),
                      Text('Active Level: Lv. $level', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Server-Authoritative Progress Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF130E26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8A2BE2).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Server XP Progression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                    Text('Lv. $level ➔ Lv. ${level + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current XP: ${AppFormatters.formatNumber(currentXp)}',
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                    Text(
                      'Target XP: ${AppFormatters.formatNumber(requiredXp)}',
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Unlocked Perks Section
          const Text('Unlocked Privileges & Perks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ...perks.map((p) => Card(
                color: const Color(0xFF16102C),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: ListTile(
                  leading: Icon(Icons.check_circle_rounded, color: color),
                  title: Text(p, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
                  subtitle: const Text('Server Authoritative Privilege Unlocked', style: TextStyle(fontSize: 10, color: Color(0xFF00E5FF))),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSvipTrackView(BuildContext context, UserModel user, SVIPProvider svip, bool isDark) {
    final expiry = svip.expiryDate;
    final formattedExpiry = '${expiry.year}.${expiry.month.toString().padLeft(2, '0')}.${expiry.day.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVIP Tier Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFFF1493), Color(0xFF7A00E6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF1493).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SVIP ${svip.currentLevel}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        AnimatedVipTag(level: svip.currentLevel > 0 ? svip.currentLevel : 1, height: 26),
                      ],
                    ),
                    const Text('👑', style: TextStyle(fontSize: 32)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Active Points: ${AppFormatters.formatNumber(svip.currentPoints)} Points', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Renewal Countdown: Expires on $formattedExpiry', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8A2BE2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SVIPCenterScreen()));
                  },
                  child: const Text('Open SVIP Privilege Center ➔', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('SVIP Tier Roadmap & Privilege Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ...svip.levels.take(6).map((lvl) {
            final isUnlocked = lvl.level <= svip.currentLevel;
            return Card(
              color: const Color(0xFF16102C),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isUnlocked ? const Color(0xFF8A2BE2).withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isUnlocked ? const Color(0xFF8A2BE2).withValues(alpha: 0.25) : Colors.white12,
                  child: Icon(Icons.workspace_premium_rounded, color: isUnlocked ? const Color(0xFF00E5FF) : Colors.grey),
                ),
                title: Text(lvl.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text('Required: ${AppFormatters.formatNumber(lvl.requiredPoints)} Points', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                trailing: Text(
                  isUnlocked ? 'UNLOCKED' : 'LOCKED',
                  style: TextStyle(color: isUnlocked ? const Color(0xFF00E5FF) : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
