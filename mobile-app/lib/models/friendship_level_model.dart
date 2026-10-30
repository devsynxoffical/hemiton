import 'package:flutter/material.dart';

/// Friendship tiers representing social milestones between two users
enum FriendshipTier {
  buddy, // Lv 1
  pal, // Lv 2
  closeFriend, // Lv 3
  bestie, // Lv 4
  soulmate, // Lv 5
}

extension FriendshipTierX on FriendshipTier {
  String get title {
    switch (this) {
      case FriendshipTier.buddy:
        return 'Hangout Buddy';
      case FriendshipTier.pal:
        return 'Good Pal';
      case FriendshipTier.closeFriend:
        return 'Close Friend';
      case FriendshipTier.bestie:
        return 'Bestie';
      case FriendshipTier.soulmate:
        return 'Soulmate';
    }
  }

  String get badgeLabel {
    switch (this) {
      case FriendshipTier.buddy:
        return 'Buddy Lv.1';
      case FriendshipTier.pal:
        return 'Pal Lv.2';
      case FriendshipTier.closeFriend:
        return 'Close Lv.3';
      case FriendshipTier.bestie:
        return 'Bestie Lv.4';
      case FriendshipTier.soulmate:
        return 'Soulmate Lv.5';
    }
  }

  String get iconEmoji {
    switch (this) {
      case FriendshipTier.buddy:
        return '🤝';
      case FriendshipTier.pal:
        return '✨';
      case FriendshipTier.closeFriend:
        return '💖';
      case FriendshipTier.bestie:
        return '🔥';
      case FriendshipTier.soulmate:
        return '👑';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case FriendshipTier.buddy:
        return const [Color(0xFF4A90E2), Color(0xFF50E3C2)];
      case FriendshipTier.pal:
        return const [Color(0xFF38EF7D), Color(0xFF11998E)];
      case FriendshipTier.closeFriend:
        return const [Color(0xFFFF007A), Color(0xFF7928CA)];
      case FriendshipTier.bestie:
        return const [Color(0xFFFF8C00), Color(0xFFFF0080)];
      case FriendshipTier.soulmate:
        return const [Color(0xFFFFD700), Color(0xFFFF3366)];
    }
  }

  int get requiredXp {
    switch (this) {
      case FriendshipTier.buddy:
        return 0;
      case FriendshipTier.pal:
        return 100;
      case FriendshipTier.closeFriend:
        return 300;
      case FriendshipTier.bestie:
        return 600;
      case FriendshipTier.soulmate:
        return 1000;
    }
  }

  int get nextLevelXp {
    switch (this) {
      case FriendshipTier.buddy:
        return 100;
      case FriendshipTier.pal:
        return 300;
      case FriendshipTier.closeFriend:
        return 600;
      case FriendshipTier.bestie:
        return 1000;
      case FriendshipTier.soulmate:
        return 2000;
    }
  }
}

/// Feature 5: Friendship Levels Model
/// Tracks dynamic relationship progression, XP milestones, and shared activity history
class FriendshipLevelModel {
  final String userIdA;
  final String userIdB;
  int xp;
  int minutesTogetherInRooms;
  int gamesPlayedTogether;
  int giftsExchanged;
  int messagesExchanged;
  final DateTime establishedAt;

  FriendshipLevelModel({
    required this.userIdA,
    required this.userIdB,
    this.xp = 0,
    this.minutesTogetherInRooms = 0,
    this.gamesPlayedTogether = 0,
    this.giftsExchanged = 0,
    this.messagesExchanged = 0,
    DateTime? establishedAt,
  }) : establishedAt = establishedAt ?? DateTime.now();

  FriendshipTier get tier {
    if (xp >= 1000) return FriendshipTier.soulmate;
    if (xp >= 600) return FriendshipTier.bestie;
    if (xp >= 300) return FriendshipTier.closeFriend;
    if (xp >= 100) return FriendshipTier.pal;
    return FriendshipTier.buddy;
  }

  int get level {
    switch (tier) {
      case FriendshipTier.buddy:
        return 1;
      case FriendshipTier.pal:
        return 2;
      case FriendshipTier.closeFriend:
        return 3;
      case FriendshipTier.bestie:
        return 4;
      case FriendshipTier.soulmate:
        return 5;
    }
  }

  double get hoursTogether => minutesTogetherInRooms / 60.0;

  double get progressToNextTier {
    final curReq = tier.requiredXp;
    final nextReq = tier.nextLevelXp;
    if (nextReq <= curReq) return 1.0;
    final progress = (xp - curReq) / (nextReq - curReq);
    return progress.clamp(0.0, 1.0);
  }

  void addXp(int points) {
    xp += points;
  }

  void recordRoomTime(int minutes) {
    minutesTogetherInRooms += minutes;
    // +1 XP per 5 minutes in a room together
    xp += (minutes ~/ 5);
  }

  void recordGamePlayed() {
    gamesPlayedTogether++;
    xp += 25; // +25 XP per co-played game
  }

  void recordGiftSent() {
    giftsExchanged++;
    xp += 50; // +50 XP per gift sent
  }

  void recordMessage() {
    messagesExchanged++;
    xp += 2; // +2 XP per message
  }

  Map<String, dynamic> toJson() => {
        'userIdA': userIdA,
        'userIdB': userIdB,
        'xp': xp,
        'minutesTogetherInRooms': minutesTogetherInRooms,
        'gamesPlayedTogether': gamesPlayedTogether,
        'giftsExchanged': giftsExchanged,
        'messagesExchanged': messagesExchanged,
        'establishedAt': establishedAt.toIso8601String(),
      };

  factory FriendshipLevelModel.fromJson(Map<String, dynamic> json) {
    return FriendshipLevelModel(
      userIdA: json['userIdA']?.toString() ?? '',
      userIdB: json['userIdB']?.toString() ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      minutesTogetherInRooms:
          (json['minutesTogetherInRooms'] as num?)?.toInt() ?? 0,
      gamesPlayedTogether: (json['gamesPlayedTogether'] as num?)?.toInt() ?? 0,
      giftsExchanged: (json['giftsExchanged'] as num?)?.toInt() ?? 0,
      messagesExchanged: (json['messagesExchanged'] as num?)?.toInt() ?? 0,
      establishedAt: json['establishedAt'] != null
          ? (DateTime.tryParse(json['establishedAt'].toString()) ??
              DateTime.now())
          : DateTime.now(),
    );
  }

  /// Generates a realistic mock friendship for demo or offline preview
  static FriendshipLevelModel sampleBetween(String userA, String userB) {
    return FriendshipLevelModel(
      userIdA: userA,
      userIdB: userB,
      xp: 450, // Close Friend Lv. 3
      minutesTogetherInRooms: 780, // 13 hours
      gamesPlayedTogether: 8,
      giftsExchanged: 12,
      messagesExchanged: 145,
    );
  }
}
