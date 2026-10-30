class FriendshipMilestoneEvent {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime achievedAt;
  final String category; // 'meet', 'game', 'gift', 'room', 'special'

  FriendshipMilestoneEvent({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '⭐',
    required this.achievedAt,
    this.category = 'special',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'achievedAt': achievedAt.toIso8601String(),
      'category': category,
    };
  }

  factory FriendshipMilestoneEvent.fromJson(Map<String, dynamic> json) {
    return FriendshipMilestoneEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '⭐',
      achievedAt: json['achievedAt'] != null
          ? DateTime.tryParse(json['achievedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'] as String? ?? 'special',
    );
  }
}

class FriendshipJourney {
  final String userId1;
  final String userId2;
  final String friendName;
  final String friendAvatar;
  final DateTime startedAt;
  final double totalHoursTogether;
  final int totalGiftsExchanged;
  final int gamesPlayed;
  final List<FriendshipMilestoneEvent> milestones;

  FriendshipJourney({
    required this.userId1,
    required this.userId2,
    required this.friendName,
    this.friendAvatar = '',
    required this.startedAt,
    this.totalHoursTogether = 0.0,
    this.totalGiftsExchanged = 0,
    this.gamesPlayed = 0,
    List<FriendshipMilestoneEvent>? milestones,
  }) : milestones = milestones ?? [];

  int get daysTogether => DateTime.now().difference(startedAt).inDays.clamp(1, 99999);

  Map<String, dynamic> toJson() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'startedAt': startedAt.toIso8601String(),
      'totalHoursTogether': totalHoursTogether,
      'totalGiftsExchanged': totalGiftsExchanged,
      'gamesPlayed': gamesPlayed,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  factory FriendshipJourney.fromJson(Map<String, dynamic> json) {
    return FriendshipJourney(
      userId1: json['userId1'] as String? ?? '',
      userId2: json['userId2'] as String? ?? '',
      friendName: json['friendName'] as String? ?? 'Friend',
      friendAvatar: json['friendAvatar'] as String? ?? '',
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      totalHoursTogether: (json['totalHoursTogether'] as num?)?.toDouble() ?? 0.0,
      totalGiftsExchanged: (json['totalGiftsExchanged'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => FriendshipMilestoneEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory FriendshipJourney.sample(String userA, String userB, String friendName, String friendAvatar) {
    final now = DateTime.now();
    return FriendshipJourney(
      userId1: userA,
      userId2: userB,
      friendName: friendName,
      friendAvatar: friendAvatar,
      startedAt: now.subtract(const Duration(days: 45)),
      totalHoursTogether: 38.5,
      totalGiftsExchanged: 24,
      gamesPlayed: 16,
      milestones: [
        FriendshipMilestoneEvent(
          id: 'm_01',
          title: 'First Hangout Room Encounter 🎙️',
          description: 'Met in "Midnight Lofi Vibes" and shared the open mic.',
          icon: '✨',
          achievedAt: now.subtract(const Duration(days: 45)),
          category: 'meet',
        ),
        FriendshipMilestoneEvent(
          id: 'm_02',
          title: 'First Gift Sent 🎁',
          description: 'Sent a "Sparkle Rose" during an interactive game.',
          icon: '🌹',
          achievedAt: now.subtract(const Duration(days: 35)),
          category: 'gift',
        ),
        FriendshipMilestoneEvent(
          id: 'm_03',
          title: 'Hangout Trivia Duo 🧠',
          description: 'Won 5 minigames back-to-back as a team.',
          icon: '🏆',
          achievedAt: now.subtract(const Duration(days: 20)),
          category: 'game',
        ),
        FriendshipMilestoneEvent(
          id: 'm_04',
          title: 'Close Friends Milestone 💜',
          description: 'Reached Tier 3: Close Friends with 30+ room hours!',
          icon: '💎',
          achievedAt: now.subtract(const Duration(days: 5)),
          category: 'special',
        ),
      ],
    );
  }
}
