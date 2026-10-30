class FriendLiveAlert {
  final String friendId;
  final String friendName;
  final String friendAvatar;
  final String relationshipBadge;
  final String roomId;
  final String roomTitle;
  final String roomCover;
  final int viewerCount;
  final DateTime startedAt;

  FriendLiveAlert({
    required this.friendId,
    required this.friendName,
    this.friendAvatar = '',
    this.relationshipBadge = 'Close Friend 💜',
    required this.roomId,
    required this.roomTitle,
    this.roomCover = '',
    this.viewerCount = 1,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'relationshipBadge': relationshipBadge,
      'roomId': roomId,
      'roomTitle': roomTitle,
      'roomCover': roomCover,
      'viewerCount': viewerCount,
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory FriendLiveAlert.fromJson(Map<String, dynamic> json) {
    return FriendLiveAlert(
      friendId: json['friendId'] as String? ?? '',
      friendName: json['friendName'] as String? ?? 'Friend',
      friendAvatar: json['friendAvatar'] as String? ?? '',
      relationshipBadge: json['relationshipBadge'] as String? ?? 'Friend 👥',
      roomId: json['roomId'] as String? ?? '',
      roomTitle: json['roomTitle'] as String? ?? 'Hangout Room',
      roomCover: json['roomCover'] as String? ?? '',
      viewerCount: (json['viewerCount'] as num?)?.toInt() ?? 1,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
