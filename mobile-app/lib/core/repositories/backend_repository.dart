import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/live_room_model.dart';

import '../../models/gift_model.dart';
import '../../models/post_model.dart';
import '../../models/short_video_model.dart';
import '../../models/transaction_model.dart';
import '../../models/notification_model.dart';
import '../../models/message_model.dart';
import '../services/socket_service.dart';
import 'room_repository.dart';
import '../config/app_config.dart';

/// Production-ready Reactive Backend Repository Service
class BackendRepository extends ChangeNotifier {
  static final BackendRepository instance = BackendRepository._internal();

  static const String _prefsVideosKey = 'hemiton_local_short_videos_v1';

  Timer? _autoRefreshTimer;
  StreamSubscription? _socketRoomCreatedSub;
  StreamSubscription? _socketRoomClosedSub;

  BackendRepository._internal() {
    _loadPersistedVideos();
    if (!AppConfig.isBackendDisconnected) {
      SocketService.instance.connect();
      fetchLiveRooms();
      _startAutoRefresh();
      _initSocketSubscriptions();
    }
  }

  void _startAutoRefresh() {
    if (AppConfig.isBackendDisconnected) return;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      fetchLiveRooms();
    });
  }

  void _initSocketSubscriptions() {
    final socket = SocketService.instance;
    socket.connect();
    _socketRoomCreatedSub?.cancel();
    _socketRoomCreatedSub = socket.roomCreatedStream.listen((data) {
      try {
        final room = LiveRoomModel.fromJson(data);
        if (room.id.isNotEmpty) {
          addLiveRoom(room);
        }
        fetchLiveRooms();
      } catch (_) {
        fetchLiveRooms();
      }
    });

    _socketRoomClosedSub?.cancel();
    _socketRoomClosedSub = socket.roomClosedStream.listen((data) {
      final roomId = data['roomId']?.toString() ?? data['id']?.toString();
      if (roomId != null) {
        removeLiveRoom(roomId);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _socketRoomCreatedSub?.cancel();
    _socketRoomClosedSub?.cancel();
    super.dispose();
  }

  final List<ShortVideoModel> _shortVideos = [];
  final List<LiveRoomModel> _liveRooms = [];
  final List<LiveRoomModel> _friendOfFriendLiveRooms = [];
  final List<PostModel> _posts = [];
  final List<AppNotificationModel> _notifications = [];
  final List<TransactionModel> _transactions = [];
  final List<GiftModel> _gifts = List.from(GiftModel.defaultCatalog);
  final List<MessageModel> _messages = [];
  final List<UserModel> _popularUsers = [];

  List<ShortVideoModel> get shortVideos => List.unmodifiable(_shortVideos);
  List<LiveRoomModel> get liveRooms => List.unmodifiable(_liveRooms);
  List<LiveRoomModel> get friendOfFriendLiveRooms =>
      List.unmodifiable(_friendOfFriendLiveRooms);
  List<PostModel> get posts => List.unmodifiable(_posts);
  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<GiftModel> get gifts => List.unmodifiable(_gifts);
  List<MessageModel> get messages => List.unmodifiable(_messages);
  List<UserModel> get popularUsers => List.unmodifiable(_popularUsers);

  UserModel getUserById(String userId) {
    return _popularUsers.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel(
        id: userId,
        name: userId.length > 5
            ? 'User ${userId.substring(userId.length - 4)}'
            : userId,
        username: 'user_$userId',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
        followers: 0,
        following: 0,
      ),
    );
  }

  Future<void> _loadPersistedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsVideosKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              try {
                final video = ShortVideoModel.fromJson(item);
                if (!_shortVideos.any((v) => v.id == video.id)) {
                  _shortVideos.add(video);
                }
              } catch (_) {}
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[BackendRepository] Error loading persisted videos: $e');
    }
  }

  Future<void> _savePersistedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _shortVideos.map((v) => v.toJson()).toList();
      await prefs.setString(_prefsVideosKey, jsonEncode(data));
    } catch (e) {
      debugPrint('[BackendRepository] Error saving persisted videos: $e');
    }
  }

  // Dynamic Video Upload
  Future<ShortVideoModel> publishVideo({
    String? id,
    required UserModel creator,
    required String videoUrl,
    required String caption,
    required String musicTitle,
    String? coverUrl,
  }) async {
    final newVideo = ShortVideoModel(
      id: id ?? 'video_${DateTime.now().millisecondsSinceEpoch}',
      creator: creator,
      videoUrl: videoUrl,
      caption: caption,
      musicTitle: musicTitle,
      likes: 0,
      comments: 0,
      gifts: 0,
      isLiked: false,
    );
    _shortVideos.removeWhere((v) => v.id == newVideo.id);
    _shortVideos.insert(0, newVideo);
    await _savePersistedVideos();
    notifyListeners();
    return newVideo;
  }

  // Toggle Video Like
  void toggleVideoLike(String videoId) {
    final index = _shortVideos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      final v = _shortVideos[index];
      final newLiked = !v.isLiked;
      final newLikes = newLiked ? v.likes + 1 : (v.likes > 0 ? v.likes - 1 : 0);
      _shortVideos[index] = v.copyWith(isLiked: newLiked, likes: newLikes);
      _savePersistedVideos();
      notifyListeners();
    }
  }

  LiveRoomModel? getExistingRoomForHost(String hostId) {
    return _liveRooms.where((r) => r.host.id == hostId).firstOrNull;
  }

  // Dynamic Room Management
  void addLiveRoom(LiveRoomModel room) {
    // Enforce 1 active room per owner: remove existing room for host
    _liveRooms.removeWhere((r) => r.id == room.id || r.host.id == room.host.id);
    _liveRooms.insert(0, room);
    notifyListeners();
  }

  void updateLiveRoom(LiveRoomModel updatedRoom) {
    final index = _liveRooms.indexWhere((r) => r.id == updatedRoom.id);
    if (index != -1) {
      _liveRooms[index] = updatedRoom;
      notifyListeners();
    }
  }

  void removeLiveRoom(String roomId) {
    _liveRooms.removeWhere((r) => r.id == roomId);
    notifyListeners();
  }

  List<LiveRoomModel> getMyRooms(String userId) {
    if (userId.isEmpty) return [];
    return _liveRooms
        .where((r) => r.host.id == userId || r.creatorUserId == userId)
        .toList();
  }

  List<LiveRoomModel> getPartyRooms() {
    return _liveRooms.where((r) {
      final t = r.roomType.toUpperCase();
      return t.contains('AUDIO') ||
          t.contains('PARTY') ||
          t.contains('VOICE') ||
          r.category.toLowerCase() == 'party' ||
          r.id.startsWith('party_');
    }).toList();
  }

  List<LiveRoomModel> getActiveLiveStreams() {
    return _liveRooms.where((r) {
      final t = r.roomType.toUpperCase();
      return t.contains('VIDEO') || t == 'LIVE_VIDEO' || t == 'VIDEO ROOM';
    }).toList();
  }

  /// Real Backend Room Discovery Integration
  Future<List<LiveRoomModel>> fetchLiveRooms({
    String? category,
    int limit = 50,
  }) async {
    try {
      final remoteRooms = await RoomRepository.instance.getActiveRooms(
        category: category,
        limit: limit,
      );
      final seenIds = <String>{};
      final uniqueRooms = <LiveRoomModel>[];
      for (final r in remoteRooms) {
        if (r.id.isNotEmpty && !seenIds.contains(r.id)) {
          seenIds.add(r.id);
          uniqueRooms.add(r);
        }
      }

      // Preserve active rooms (such as newly created rooms) not yet returned in remote query
      final preservedRooms = _liveRooms
          .where((r) => r.status.toUpperCase() == 'LIVE' && !seenIds.contains(r.id))
          .toList();

      _liveRooms.clear();
      _liveRooms.addAll(preservedRooms);
      _liveRooms.addAll(uniqueRooms);
      notifyListeners();
      return _liveRooms;
    } catch (_) {
      return _liveRooms;
    }
  }

  /// Feature 1: Fetch Friend-of-Friend live rooms
  Future<List<LiveRoomModel>> fetchFriendOfFriendLiveRooms({
    int limit = 50,
  }) async {
    try {
      final remoteFoFRooms = await RoomRepository.instance
          .getFriendOfFriendRooms(limit: limit);
      if (remoteFoFRooms.isNotEmpty) {
        _friendOfFriendLiveRooms.clear();
        _friendOfFriendLiveRooms.addAll(remoteFoFRooms);
      } else {
        // Fallback or demo friend-of-friend live streams: enrich active rooms
        _friendOfFriendLiveRooms.clear();
        _friendOfFriendLiveRooms.addAll(
          _liveRooms
              .map(
                (r) => r.copyWith(
                  isFriendOfFriend: true,
                  mutualFriendName: r.host.name.isNotEmpty
                      ? r.host.name
                      : 'Sonia',
                ),
              )
              .toList(),
        );
      }
      notifyListeners();
      return _friendOfFriendLiveRooms;
    } catch (_) {
      return _friendOfFriendLiveRooms;
    }
  }

  // Dynamic Go Live Stream Creation
  Future<LiveRoomModel> createLiveStream({
    required UserModel host,
    required String title,
    required String category,
    required String coverUrl,
    bool isPrivate = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newRoom = LiveRoomModel(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      host: host,
      coverUrl: coverUrl.isNotEmpty
          ? coverUrl
          : 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=600&q=80',
      viewerCount: 1,
      category: category,
      isPrivate: isPrivate,
      startTime: DateTime.now(),
    );
    addLiveRoom(newRoom);
    return newRoom;
  }

  // Dynamic Transaction Logging
  void logTransaction({
    required String title,
    required String type,
    required double amount,
    required String currency,
  }) {
    final tx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      amount: amount,
      currency: currency,
      status: 'Completed',
      date: DateTime.now(),
    );
    _transactions.insert(0, tx);
    notifyListeners();
  }

  // Dynamic Notifications
  void sendNotification({
    required String title,
    required String message,
    required String category,
  }) {
    final notif = AppNotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      category: category,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notif);
    notifyListeners();
  }

  // Private Chat Message Dispatch
  void sendMessage(String receiverId, String text) {
    final msg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
    );
    _messages.add(msg);
    notifyListeners();
  }

  // Global Follower Count Sync
  void updateUserFollowers(String userId, int delta) {
    final idx = _popularUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final u = _popularUsers[idx];
      final newFollowers = (u.followers + delta) >= 0 ? u.followers + delta : 0;
      _popularUsers[idx] = u.copyWith(followers: newFollowers);
      notifyListeners();
    }
  }
}
