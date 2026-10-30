class HangoutCommunity {
  final String id;
  final String name;
  final String category;
  final String description;
  final String icon;
  final String bannerUrl;
  final int memberCount;
  final bool isMember;
  final int activeRoomsCount;
  final List<String> tags;
  final String? featuredRoomId;
  final String? featuredRoomTitle;

  HangoutCommunity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.icon = '🌟',
    this.bannerUrl = '',
    this.memberCount = 10,
    this.isMember = false,
    this.activeRoomsCount = 0,
    List<String>? tags,
    this.featuredRoomId,
    this.featuredRoomTitle,
  }) : tags = tags ?? [];

  bool get hasActiveRooms => activeRoomsCount > 0 || (featuredRoomId != null && featuredRoomId!.isNotEmpty);

  HangoutCommunity toggleMembership() {
    return copyWith(
      isMember: !isMember,
      memberCount: isMember ? (memberCount - 1).clamp(0, 999999) : memberCount + 1,
    );
  }

  HangoutCommunity copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? icon,
    String? bannerUrl,
    int? memberCount,
    bool? isMember,
    int? activeRoomsCount,
    List<String>? tags,
    String? featuredRoomId,
    String? featuredRoomTitle,
  }) {
    return HangoutCommunity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      memberCount: memberCount ?? this.memberCount,
      isMember: isMember ?? this.isMember,
      activeRoomsCount: activeRoomsCount ?? this.activeRoomsCount,
      tags: tags ?? this.tags,
      featuredRoomId: featuredRoomId ?? this.featuredRoomId,
      featuredRoomTitle: featuredRoomTitle ?? this.featuredRoomTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'icon': icon,
      'bannerUrl': bannerUrl,
      'memberCount': memberCount,
      'isMember': isMember,
      'activeRoomsCount': activeRoomsCount,
      'tags': tags,
      'featuredRoomId': featuredRoomId,
      'featuredRoomTitle': featuredRoomTitle,
    };
  }

  factory HangoutCommunity.fromJson(Map<String, dynamic> json) {
    return HangoutCommunity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Community',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🌟',
      bannerUrl: json['bannerUrl'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 10,
      isMember: json['isMember'] == true,
      activeRoomsCount: (json['activeRoomsCount'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      featuredRoomId: json['featuredRoomId'] as String?,
      featuredRoomTitle: json['featuredRoomTitle'] as String?,
    );
  }
}
