import 'user_model.dart';

class ShortVideoModel {
  final String id;
  final UserModel creator;
  final String videoUrl;
  final String caption;
  final String musicTitle;
  final int likes;
  final int comments;
  final int gifts;
  final bool isLiked;

  const ShortVideoModel({
    required this.id,
    required this.creator,
    required this.videoUrl,
    required this.caption,
    required this.musicTitle,
    required this.likes,
    required this.comments,
    required this.gifts,
    this.isLiked = false,
  });

  factory ShortVideoModel.fromJson(Map<String, dynamic> json) {
    final rawCreator = json['creator'] ?? json['user'] ?? json['author'];
    final UserModel creator;
    if (rawCreator is Map<String, dynamic>) {
      creator = UserModel.fromJson(rawCreator);
    } else {
      creator = const UserModel(
        id: 'creator',
        name: 'Creator',
        username: 'creator',
        avatarUrl: '',
      );
    }

    return ShortVideoModel(
      id: json['id']?.toString() ?? '',
      creator: creator,
      videoUrl: json['videoUrl']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      musicTitle: json['musicTitle']?.toString() ?? 'Original Sound',
      likes: json['likes'] is int ? json['likes'] : int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      comments: json['comments'] is int ? json['comments'] : int.tryParse(json['comments']?.toString() ?? '0') ?? 0,
      gifts: json['gifts'] is int ? json['gifts'] : int.tryParse(json['gifts']?.toString() ?? '0') ?? 0,
      isLiked: json['isLiked'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'creator': creator.toJson(),
    'videoUrl': videoUrl,
    'caption': caption,
    'musicTitle': musicTitle,
    'likes': likes,
    'comments': comments,
    'gifts': gifts,
    'isLiked': isLiked,
  };

  ShortVideoModel copyWith({
    String? id,
    UserModel? creator,
    String? videoUrl,
    String? caption,
    String? musicTitle,
    int? likes,
    int? comments,
    int? gifts,
    bool? isLiked,
  }) {
    return ShortVideoModel(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      musicTitle: musicTitle ?? this.musicTitle,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      gifts: gifts ?? this.gifts,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

