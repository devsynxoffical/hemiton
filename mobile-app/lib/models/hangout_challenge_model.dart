enum HangoutChallengeStatus {
  active,
  completed,
  expired;

  static HangoutChallengeStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'completed':
        return HangoutChallengeStatus.completed;
      case 'expired':
        return HangoutChallengeStatus.expired;
      case 'active':
      default:
        return HangoutChallengeStatus.active;
    }
  }
}

class HangoutChallenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetCount;
  final int currentProgress;
  final int durationSeconds;
  final int remainingSeconds;
  final String rewardDescription;
  final String rewardBadge;
  final HangoutChallengeStatus status;
  final List<String> contributors;

  HangoutChallenge({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '🎯',
    required this.targetCount,
    this.currentProgress = 0,
    this.durationSeconds = 600,
    int? remainingSeconds,
    required this.rewardDescription,
    this.rewardBadge = '🏆',
    this.status = HangoutChallengeStatus.active,
    List<String>? contributors,
  })  : remainingSeconds = remainingSeconds ?? durationSeconds,
        contributors = contributors ?? [];

  bool get isCompleted => currentProgress >= targetCount || status == HangoutChallengeStatus.completed;
  double get progressRatio => targetCount > 0 ? (currentProgress / targetCount).clamp(0.0, 1.0) : 0.0;
  int get percentComplete => (progressRatio * 100).round();

  HangoutChallenge incrementProgress(int amount, String userId) {
    final newProgress = currentProgress + amount;
    final updatedContributors = List<String>.from(contributors);
    if (!updatedContributors.contains(userId)) {
      updatedContributors.add(userId);
    }

    final newStatus = newProgress >= targetCount
        ? HangoutChallengeStatus.completed
        : status;

    return copyWith(
      currentProgress: newProgress,
      contributors: updatedContributors,
      status: newStatus,
    );
  }

  HangoutChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? targetCount,
    int? currentProgress,
    int? durationSeconds,
    int? remainingSeconds,
    String? rewardDescription,
    String? rewardBadge,
    HangoutChallengeStatus? status,
    List<String>? contributors,
  }) {
    return HangoutChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetCount: targetCount ?? this.targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      rewardBadge: rewardBadge ?? this.rewardBadge,
      status: status ?? this.status,
      contributors: contributors ?? this.contributors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'targetCount': targetCount,
      'currentProgress': currentProgress,
      'durationSeconds': durationSeconds,
      'remainingSeconds': remainingSeconds,
      'rewardDescription': rewardDescription,
      'rewardBadge': rewardBadge,
      'status': status.name,
      'contributors': contributors,
    };
  }

  factory HangoutChallenge.fromJson(Map<String, dynamic> json) {
    return HangoutChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Hangout Challenge',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎯',
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 100,
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 600,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 600,
      rewardDescription: json['rewardDescription'] as String? ?? 'Room Bonus',
      rewardBadge: json['rewardBadge'] as String? ?? '🏆',
      status: HangoutChallengeStatus.fromString(json['status'] as String?),
      contributors: (json['contributors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
