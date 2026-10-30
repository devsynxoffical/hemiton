class HangoutMediaItem {
  final String id;
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final int durationSeconds;
  final String addedById;
  final String addedByName;
  final String? addedByAvatar;
  final List<String> upvotedByUserIds;
  final DateTime addedAt;

  HangoutMediaItem({
    required this.id,
    required this.videoId,
    required this.title,
    this.thumbnailUrl = '',
    this.durationSeconds = 180,
    required this.addedById,
    required this.addedByName,
    this.addedByAvatar,
    List<String>? upvotedByUserIds,
    DateTime? addedAt,
  })  : upvotedByUserIds = upvotedByUserIds ?? [],
        addedAt = addedAt ?? DateTime.now();

  int get upvoteCount => upvotedByUserIds.length;

  bool isUpvotedBy(String userId) => upvotedByUserIds.contains(userId);

  HangoutMediaItem toggleUpvote(String userId) {
    final updated = List<String>.from(upvotedByUserIds);
    if (updated.contains(userId)) {
      updated.remove(userId);
    } else {
      updated.add(userId);
    }
    return copyWith(upvotedByUserIds: updated);
  }

  HangoutMediaItem copyWith({
    String? id,
    String? videoId,
    String? title,
    String? thumbnailUrl,
    int? durationSeconds,
    String? addedById,
    String? addedByName,
    String? addedByAvatar,
    List<String>? upvotedByUserIds,
    DateTime? addedAt,
  }) {
    return HangoutMediaItem(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      addedById: addedById ?? this.addedById,
      addedByName: addedByName ?? this.addedByName,
      addedByAvatar: addedByAvatar ?? this.addedByAvatar,
      upvotedByUserIds: upvotedByUserIds ?? this.upvotedByUserIds,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'addedById': addedById,
      'addedByName': addedByName,
      'addedByAvatar': addedByAvatar,
      'upvotedByUserIds': upvotedByUserIds,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory HangoutMediaItem.fromJson(Map<String, dynamic> json) {
    return HangoutMediaItem(
      id: json['id'] as String? ?? '',
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Track',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 180,
      addedById: json['addedById'] as String? ?? '',
      addedByName: json['addedByName'] as String? ?? 'Friend',
      addedByAvatar: json['addedByAvatar'] as String?,
      upvotedByUserIds: (json['upvotedByUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
