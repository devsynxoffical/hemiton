enum SocialCirclePrivacy {
  open,
  inviteOnly,
  secret;

  String get label {
    switch (this) {
      case SocialCirclePrivacy.open:
        return 'Public Circle';
      case SocialCirclePrivacy.inviteOnly:
        return 'Invite Only';
      case SocialCirclePrivacy.secret:
        return 'Secret Squad';
    }
  }

  static SocialCirclePrivacy fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'invite_only':
      case 'inviteonly':
        return SocialCirclePrivacy.inviteOnly;
      case 'secret':
        return SocialCirclePrivacy.secret;
      case 'open':
      default:
        return SocialCirclePrivacy.open;
    }
  }
}

class SocialCircleMember {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String role; // 'owner', 'admin', 'member'
  final DateTime joinedAt;

  SocialCircleMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.role = 'member',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin' || role == 'owner';

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory SocialCircleMember.fromJson(Map<String, dynamic> json) {
    return SocialCircleMember(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Member',
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SocialCircleModel {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String bannerUrl;
  final String creatorId;
  final String creatorName;
  final SocialCirclePrivacy privacy;
  final int memberCount;
  final List<SocialCircleMember> members;
  final List<String> tags;
  final String? activeRoomId;
  final String? activeRoomTitle;
  final DateTime createdAt;

  SocialCircleModel({
    required this.id,
    required this.name,
    this.description = '',
    this.avatarUrl = '',
    this.bannerUrl = '',
    required this.creatorId,
    required this.creatorName,
    this.privacy = SocialCirclePrivacy.open,
    int? memberCount,
    List<SocialCircleMember>? members,
    List<String>? tags,
    this.activeRoomId,
    this.activeRoomTitle,
    DateTime? createdAt,
  })  : members = members ?? [],
        memberCount = memberCount ?? (members?.length ?? 1),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get hasActiveHangout => activeRoomId != null && activeRoomId!.isNotEmpty;

  bool isUserMember(String userId) {
    return members.any((m) => m.userId == userId) || creatorId == userId;
  }

  bool isUserOwner(String userId) {
    return creatorId == userId || members.any((m) => m.userId == userId && m.isOwner);
  }

  bool isUserAdmin(String userId) {
    return isUserOwner(userId) || members.any((m) => m.userId == userId && m.isAdmin);
  }

  SocialCircleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? bannerUrl,
    String? creatorId,
    String? creatorName,
    SocialCirclePrivacy? privacy,
    int? memberCount,
    List<SocialCircleMember>? members,
    List<String>? tags,
    String? activeRoomId,
    String? activeRoomTitle,
    DateTime? createdAt,
  }) {
    return SocialCircleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      privacy: privacy ?? this.privacy,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      tags: tags ?? this.tags,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      activeRoomTitle: activeRoomTitle ?? this.activeRoomTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'privacy': privacy.name,
      'memberCount': memberCount,
      'members': members.map((m) => m.toJson()).toList(),
      'tags': tags,
      'activeRoomId': activeRoomId,
      'activeRoomTitle': activeRoomTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SocialCircleModel.fromJson(Map<String, dynamic> json) {
    final membersList = (json['members'] as List<dynamic>?)
            ?.map((m) => SocialCircleMember.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return SocialCircleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Social Circle',
      description: json['description'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      creatorName: json['creatorName'] as String? ?? 'Host',
      privacy: SocialCirclePrivacy.fromString(json['privacy'] as String?),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? membersList.length,
      members: membersList,
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      activeRoomId: json['activeRoomId'] as String?,
      activeRoomTitle: json['activeRoomTitle'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
