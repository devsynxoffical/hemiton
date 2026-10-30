class HangoutMission {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final int currentProgress;
  final int targetProgress;
  final bool isClaimed;

  const HangoutMission({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '🎯',
    required this.xpReward,
    required this.currentProgress,
    required this.targetProgress,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetProgress;
  double get progressRatio => targetProgress > 0 ? (currentProgress / targetProgress).clamp(0.0, 1.0) : 0.0;
  int get percentComplete => (progressRatio * 100).round();

  HangoutMission copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? xpReward,
    int? currentProgress,
    int? targetProgress,
    bool? isClaimed,
  }) {
    return HangoutMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'xpReward': xpReward,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'isClaimed': isClaimed,
    };
  }

  factory HangoutMission.fromJson(Map<String, dynamic> json) {
    return HangoutMission(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎯',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetProgress: (json['targetProgress'] as num?)?.toInt() ?? 1,
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}

class SocialBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredLevel;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const SocialBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredLevel,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  SocialBadge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? requiredLevel,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return SocialBadge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'requiredLevel': requiredLevel,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory SocialBadge.fromJson(Map<String, dynamic> json) {
    return SocialBadge(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏅',
      requiredLevel: (json['requiredLevel'] as num?)?.toInt() ?? 1,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'] as String) : null,
    );
  }
}

class HangoutXpRewardModel {
  final String userId;
  final int currentXp;
  final int streakDays;
  final DateTime? lastCheckInDate;
  final List<HangoutMission> missions;
  final List<SocialBadge> badges;

  const HangoutXpRewardModel({
    required this.userId,
    this.currentXp = 0,
    this.streakDays = 1,
    this.lastCheckInDate,
    this.missions = const [],
    this.badges = const [],
  });

  /// Level calculation: 300 XP per level
  int get currentLevel => (currentXp ~/ 300) + 1;

  int get xpForCurrentLevel => (currentLevel - 1) * 300;
  int get xpForNextLevel => currentLevel * 300;
  int get xpInCurrentLevel => currentXp - xpForCurrentLevel;

  double get progressToNextLevel {
    const xpPerLevel = 300;
    return (xpInCurrentLevel / xpPerLevel).clamp(0.0, 1.0);
  }

  String get tierTitle {
    final lvl = currentLevel;
    if (lvl <= 1) return 'Hangout Rookie';
    if (lvl <= 3) return 'Social Butterfly';
    if (lvl <= 5) return 'Party Enthusiast';
    if (lvl <= 8) return 'Hangout Pro';
    if (lvl <= 12) return 'Party Legend';
    return 'Iconic Host';
  }

  String get tierEmoji {
    final lvl = currentLevel;
    if (lvl <= 1) return '🌱';
    if (lvl <= 3) return '🦋';
    if (lvl <= 5) return '🎉';
    if (lvl <= 8) return '⚡';
    if (lvl <= 12) return '👑';
    return '🌟';
  }

  bool get hasCheckedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
        lastCheckInDate!.month == now.month &&
        lastCheckInDate!.day == now.day;
  }

  HangoutXpRewardModel addXp(int amount) {
    final newXp = currentXp + amount;
    final newLevel = (newXp ~/ 300) + 1;
    final now = DateTime.now();

    final updatedBadges = badges.map((badge) {
      if (!badge.isUnlocked && newLevel >= badge.requiredLevel) {
        return badge.copyWith(isUnlocked: true, unlockedAt: now);
      }
      return badge;
    }).toList();

    return copyWith(
      currentXp: newXp,
      badges: updatedBadges,
    );
  }

  HangoutXpRewardModel checkInToday() {
    if (hasCheckedInToday) return this;
    final bonusXp = 20 * (streakDays + 1);
    final now = DateTime.now();
    final updated = addXp(bonusXp);
    return updated.copyWith(
      streakDays: streakDays + 1,
      lastCheckInDate: now,
    );
  }

  HangoutXpRewardModel claimMission(String missionId) {
    HangoutMission? target;
    final updatedMissions = missions.map((m) {
      if (m.id == missionId && m.isCompleted && !m.isClaimed) {
        target = m;
        return m.copyWith(isClaimed: true);
      }
      return m;
    }).toList();

    if (target != null) {
      final withXp = addXp(target!.xpReward);
      return withXp.copyWith(missions: updatedMissions);
    }
    return this;
  }

  HangoutXpRewardModel copyWith({
    String? userId,
    int? currentXp,
    int? streakDays,
    DateTime? lastCheckInDate,
    List<HangoutMission>? missions,
    List<SocialBadge>? badges,
  }) {
    return HangoutXpRewardModel(
      userId: userId ?? this.userId,
      currentXp: currentXp ?? this.currentXp,
      streakDays: streakDays ?? this.streakDays,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      missions: missions ?? this.missions,
      badges: badges ?? this.badges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentXp': currentXp,
      'streakDays': streakDays,
      'lastCheckInDate': lastCheckInDate?.toIso8601String(),
      'missions': missions.map((m) => m.toJson()).toList(),
      'badges': badges.map((b) => b.toJson()).toList(),
    };
  }

  factory HangoutXpRewardModel.fromJson(Map<String, dynamic> json) {
    return HangoutXpRewardModel(
      userId: json['userId'] as String? ?? '',
      currentXp: (json['currentXp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 1,
      lastCheckInDate: json['lastCheckInDate'] != null ? DateTime.tryParse(json['lastCheckInDate'] as String) : null,
      missions: (json['missions'] as List<dynamic>?)
              ?.map((e) => HangoutMission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => SocialBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static HangoutXpRewardModel defaultForUser(String userId) {
    return HangoutXpRewardModel(
      userId: userId,
      currentXp: 420,
      streakDays: 3,
      lastCheckInDate: null,
      missions: [
        const HangoutMission(
          id: 'm1',
          title: 'Hangout Explorer',
          description: 'Spend 10 minutes in any active party or live room',
          icon: '⏱️',
          xpReward: 50,
          currentProgress: 10,
          targetProgress: 10,
          isClaimed: false,
        ),
        const HangoutMission(
          id: 'm2',
          title: 'Icebreaker Champion',
          description: 'Answer 1 icebreaker question with hangout buddies',
          icon: '🧊',
          xpReward: 40,
          currentProgress: 1,
          targetProgress: 1,
          isClaimed: false,
        ),
        const HangoutMission(
          id: 'm3',
          title: 'Party Gamer',
          description: 'Participate in 1 minigame or super wheel spin',
          icon: '🎮',
          xpReward: 60,
          currentProgress: 0,
          targetProgress: 1,
          isClaimed: false,
        ),
        const HangoutMission(
          id: 'm4',
          title: 'Squad Creator',
          description: 'Invite a friend into a room with Bring My Friend',
          icon: '💌',
          xpReward: 80,
          currentProgress: 1,
          targetProgress: 1,
          isClaimed: false,
        ),
      ],
      badges: [
        const SocialBadge(
          id: 'b1',
          name: 'First Handshake',
          description: 'Joined your first live hangout session',
          icon: '🤝',
          requiredLevel: 1,
          isUnlocked: true,
        ),
        const SocialBadge(
          id: 'b2',
          name: 'Social Butterfly',
          description: 'Reached Hangout Level 2',
          icon: '🦋',
          requiredLevel: 2,
          isUnlocked: true,
        ),
        const SocialBadge(
          id: 'b3',
          name: 'Party Spark',
          description: 'Reach Hangout Level 3 and host a 5-person room',
          icon: '✨',
          requiredLevel: 3,
          isUnlocked: false,
        ),
        const SocialBadge(
          id: 'b4',
          name: 'Legendary Host',
          description: 'Achieve Level 6 Hangout Pro milestone',
          icon: '👑',
          requiredLevel: 6,
          isUnlocked: false,
        ),
      ],
    );
  }
}
