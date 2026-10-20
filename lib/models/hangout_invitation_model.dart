enum HangoutInvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
}

/// Model representing a friend hangout or live session invitation (Feature 2: Bring My Friend)
class HangoutInvitationModel {
  final String id;
  final String roomId;
  final String roomTitle;
  final String inviterUserId;
  final String inviterName;
  final String inviterAvatar;
  final String invitedUserId;
  final String invitedUserName;
  final String invitedUserAvatar;
  final HangoutInvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const HangoutInvitationModel({
    required this.id,
    required this.roomId,
    required this.roomTitle,
    required this.inviterUserId,
    required this.inviterName,
    required this.inviterAvatar,
    required this.invitedUserId,
    required this.invitedUserName,
    required this.invitedUserAvatar,
    this.status = HangoutInvitationStatus.pending,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt) || status == HangoutInvitationStatus.expired;
  bool get isPending => status == HangoutInvitationStatus.pending && !isExpired;
  bool get isAccepted => status == HangoutInvitationStatus.accepted;
  bool get isDeclined => status == HangoutInvitationStatus.declined;

  HangoutInvitationModel copyWith({
    String? id,
    String? roomId,
    String? roomTitle,
    String? inviterUserId,
    String? inviterName,
    String? inviterAvatar,
    String? invitedUserId,
    String? invitedUserName,
    String? invitedUserAvatar,
    HangoutInvitationStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return HangoutInvitationModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomTitle: roomTitle ?? this.roomTitle,
      inviterUserId: inviterUserId ?? this.inviterUserId,
      inviterName: inviterName ?? this.inviterName,
      inviterAvatar: inviterAvatar ?? this.inviterAvatar,
      invitedUserId: invitedUserId ?? this.invitedUserId,
      invitedUserName: invitedUserName ?? this.invitedUserName,
      invitedUserAvatar: invitedUserAvatar ?? this.invitedUserAvatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'roomTitle': roomTitle,
        'inviterUserId': inviterUserId,
        'inviterName': inviterName,
        'inviterAvatar': inviterAvatar,
        'invitedUserId': invitedUserId,
        'invitedUserName': invitedUserName,
        'invitedUserAvatar': invitedUserAvatar,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory HangoutInvitationModel.fromJson(Map<String, dynamic> json) {
    return HangoutInvitationModel(
      id: json['id']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? json['room_id']?.toString() ?? '',
      roomTitle: json['roomTitle']?.toString() ?? json['room_title']?.toString() ?? 'Hangout Room',
      inviterUserId: json['inviterUserId']?.toString() ?? json['inviter_id']?.toString() ?? '',
      inviterName: json['inviterName']?.toString() ?? json['inviter_name']?.toString() ?? 'Host',
      inviterAvatar: json['inviterAvatar']?.toString() ?? json['inviter_avatar']?.toString() ?? '',
      invitedUserId: json['invitedUserId']?.toString() ?? json['invited_id']?.toString() ?? '',
      invitedUserName: json['invitedUserName']?.toString() ?? json['invited_name']?.toString() ?? 'Friend',
      invitedUserAvatar: json['invitedUserAvatar']?.toString() ?? json['invited_avatar']?.toString() ?? '',
      status: parseStatus(json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? (DateTime.tryParse(json['expiresAt'].toString()) ?? DateTime.now().add(const Duration(minutes: 10)))
          : DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  static HangoutInvitationStatus parseStatus(String? status) {
    return HangoutInvitationStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => HangoutInvitationStatus.pending,
    );
  }
}
