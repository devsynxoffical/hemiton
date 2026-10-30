class MatchmakingProfile {
  final String userId;
  final String name;
  final String avatarUrl;
  final String gender;
  final int age;
  final String country;
  final String mood;
  final List<String> languages;
  final List<String> interests;
  final bool isOnline;
  final String? activeRoomId;
  final String? bio;

  MatchmakingProfile({
    required this.userId,
    required this.name,
    this.avatarUrl = '',
    this.gender = 'other',
    this.age = 21,
    this.country = 'Global',
    this.mood = 'Chill Vibes ☕',
    List<String>? languages,
    List<String>? interests,
    this.isOnline = true,
    this.activeRoomId,
    this.bio,
  })  : languages = languages ?? ['English'],
        interests = interests ?? [];

  /// Calculates a compatibility score (0-100%) based on shared interests, languages, and mood.
  int calculateCompatibilityWith(MatchmakingProfile other) {
    if (userId == other.userId) return 100;

    int score = 40; // Base baseline compatibility

    // Mood match
    if (mood.toLowerCase() == other.mood.toLowerCase()) {
      score += 20;
    }

    // Shared languages (+10 each, up to 20)
    final sharedLanguages = languages.where((l) => other.languages.contains(l)).length;
    score += (sharedLanguages * 10).clamp(0, 20);

    // Shared interests (+10 each, up to 30)
    final sharedInterests = interests.where((i) => other.interests.contains(i)).length;
    score += (sharedInterests * 10).clamp(0, 30);

    return score.clamp(10, 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'age': age,
      'country': country,
      'mood': mood,
      'languages': languages,
      'interests': interests,
      'isOnline': isOnline,
      'activeRoomId': activeRoomId,
      'bio': bio,
    };
  }

  factory MatchmakingProfile.fromJson(Map<String, dynamic> json) {
    return MatchmakingProfile(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      gender: json['gender'] as String? ?? 'other',
      age: (json['age'] as num?)?.toInt() ?? 21,
      country: json['country'] as String? ?? 'Global',
      mood: json['mood'] as String? ?? 'Chill Vibes ☕',
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['English'],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isOnline: json['isOnline'] as bool? ?? true,
      activeRoomId: json['activeRoomId'] as String?,
      bio: json['bio'] as String?,
    );
  }

  MatchmakingProfile copyWith({
    String? userId,
    String? name,
    String? avatarUrl,
    String? gender,
    int? age,
    String? country,
    String? mood,
    List<String>? languages,
    List<String>? interests,
    bool? isOnline,
    String? activeRoomId,
    String? bio,
  }) {
    return MatchmakingProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      country: country ?? this.country,
      mood: mood ?? this.mood,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      isOnline: isOnline ?? this.isOnline,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      bio: bio ?? this.bio,
    );
  }
}
