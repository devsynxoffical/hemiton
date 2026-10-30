import '../services/api_client.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';
import '../config/app_config.dart';

class RoomRepository {
  static final RoomRepository instance = RoomRepository._internal();
  final ApiClient _apiClient = ApiClient.instance;

  RoomRepository._internal();

  /// Create a new live party / streaming room on backend
  Future<LiveRoomModel> createRoom({
    required String title,
    String? coverImageUrl,
    String roomType = 'AUDIO_PARTY',
    String category = 'CHAT',
    bool isPrivate = false,
    String? roomPin,
    UserModel? hostUser,
  }) async {
    String normType = 'LIVE_VIDEO';
    final uType = roomType.toUpperCase().trim();
    if (uType == 'GROUP_VIDEO') {
      normType = 'GROUP_VIDEO';
    } else if (uType.contains('AUDIO') ||
        uType.contains('PARTY') ||
        uType.contains('VOICE')) {
      normType = 'AUDIO_PARTY';
    }

    String normCat = 'CHAT';
    final uCat = category.toUpperCase().trim();
    if (uCat.contains('MUSIC')) {
      normCat = 'MUSIC';
    } else if (uCat.contains('GAME') || uCat.contains('GAMING')) {
      normCat = 'GAMING';
    }

    Map<String, dynamic> payload = {
      'title': title,
      'coverImageUrl': coverImageUrl ?? '',
      'roomType': normType,
      'category': normCat,
      'isPrivate': isPrivate,
      if (roomPin != null && roomPin.isNotEmpty) 'roomPin': roomPin,
    };

    if (AppConfig.isBackendDisconnected) {
      return _generateLocalRoom(
        title: title,
        coverImageUrl: coverImageUrl,
        roomType: normType,
        category: normCat,
        isPrivate: isPrivate,
        hostUser: hostUser,
      );
    }

    try {
      final response = await _apiClient.post('/v1/rooms', data: payload);
      final rawData = response.data?['data'];
      if (rawData is Map<String, dynamic>) {
        return LiveRoomModel.fromJson(rawData);
      }
      return _generateLocalRoom(
        title: title,
        coverImageUrl: coverImageUrl,
        roomType: normType,
        category: normCat,
        isPrivate: isPrivate,
        hostUser: hostUser,
      );
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      final isAlreadyActive = errStr.contains('already') ||
          errStr.contains('active') ||
          errStr.contains('exists') ||
          errStr.contains('chal rahi hai');

      if (isAlreadyActive) {
        rethrow;
      }

      bool isUnauthorized = false;
      if (e is ApiException) {
        if (e.statusCode == 401 ||
            e.code == 'UNAUTHORIZED' ||
            (e.message.toLowerCase().contains('unauthorized') ||
                e.message.toLowerCase().contains('jwt expired'))) {
          isUnauthorized = true;
        }
      }

      if (isUnauthorized) {
        // Attempt automatic token refresh retry
        final newToken = await _apiClient.refreshToken();
        if (newToken != null && newToken.isNotEmpty) {
          try {
            final retryResponse = await _apiClient.post(
              '/v1/rooms',
              data: payload,
            );
            final data = retryResponse.data?['data'];
            if (data is Map<String, dynamic>) {
              return LiveRoomModel.fromJson(data);
            }
          } catch (_) {}
        }
      }

      // If backend network call fails or is unreachable, gracefully create room so user is not blocked
      return _generateLocalRoom(
        title: title,
        coverImageUrl: coverImageUrl,
        roomType: normType,
        category: normCat,
        isPrivate: isPrivate,
        hostUser: hostUser,
      );
    }
  }

  LiveRoomModel _generateLocalRoom({
    required String title,
    String? coverImageUrl,
    required String roomType,
    required String category,
    required bool isPrivate,
    UserModel? hostUser,
  }) {
    final host = hostUser ?? UserModel.empty;
    final fallbackHost = host.id.isNotEmpty
        ? host
        : UserModel.empty.copyWith(
            id: 'host_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Room Host',
            username: 'host',
          );

    final cover = (coverImageUrl != null && coverImageUrl.isNotEmpty)
        ? coverImageUrl
        : (fallbackHost.avatarUrl.isNotEmpty
            ? fallbackHost.avatarUrl
            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80');

    return LiveRoomModel(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      host: fallbackHost,
      coverUrl: cover,
      viewerCount: 1,
      category: category,
      isPrivate: isPrivate,
      startTime: DateTime.now(),
      roomType: roomType,
      creatorUserId: fallbackHost.id,
      status: 'LIVE',
      seatCapacity: 8,
    );
  }

  /// Get active live rooms with discovery filtering
  Future<List<LiveRoomModel>> getActiveRooms({
    int page = 1,
    int limit = 20,
    String? category,
    String? roomType,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams['category'] = category;
    }
    if (roomType != null && roomType.isNotEmpty) {
      queryParams['roomType'] = roomType;
    }

    final response = await _apiClient.get(
      '/v1/rooms/active',
      queryParameters: queryParams,
    );

    final roomsList = response.data?['data'] as List? ?? [];
    return roomsList
        .map((r) => LiveRoomModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Feature 1: Get Friend-of-Friend live rooms
  Future<List<LiveRoomModel>> getFriendOfFriendRooms({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/v1/rooms/friend-of-friend',
        queryParameters: {'page': page, 'limit': limit},
      );
      final roomsList = response.data?['data'] as List? ?? [];
      return roomsList
          .map((r) => LiveRoomModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get full room details including current 8-seat state and participants
  Future<LiveRoomModel> getRoomDetails(String roomId) async {
    try {
      final response = await _apiClient.get('/v1/rooms/$roomId');
      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LiveRoomModel.fromJson(data);
      }
    } catch (e) {
      if (!AppConfig.isBackendDisconnected) rethrow;
    }
    return LiveRoomModel(
      id: roomId,
      title: 'Live Room',
      host: UserModel.empty,
      coverUrl: '',
      viewerCount: 1,
      category: 'CHAT',
      startTime: DateTime.now(),
      status: 'LIVE',
    );
  }

  /// Join a room as viewer / audience
  Future<Map<String, dynamic>> joinRoom(
    String roomId, {
    String? password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/v1/rooms/$roomId/join',
        data: password != null && password.isNotEmpty
            ? {'password': password, 'pin': password}
            : null,
      );
      final rawData = response.data?['data'];
      if (rawData is Map<String, dynamic>) {
        return rawData;
      }
      return {'roomId': roomId, 'status': 'LIVE'};
    } catch (e) {
      if (AppConfig.isBackendDisconnected) {
        return {'roomId': roomId, 'status': 'LIVE'};
      }
      rethrow;
    }
  }

  /// Leave a room cleanly on backend
  Future<void> leaveRoom(String roomId) async {
    try {
      await _apiClient.post('/v1/rooms/$roomId/leave');
    } catch (_) {
      // Best-effort departure
    }
  }

  /// Terminate and close a live room (Host only)
  Future<void> closeRoom(String roomId) async {
    try {
      await _apiClient.post('/v1/rooms/$roomId/close');
    } catch (e) {
      // Best-effort closure if network interrupted or already closed
    }
  }

  /// Occupy a specific mic seat index (0..7)
  Future<Map<String, dynamic>> occupySeat(String roomId, int seatIndex) async {
    final response = await _apiClient.post(
      '/v1/rooms/$roomId/seats/$seatIndex/occupy',
    );
    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// Release/leave a mic seat index (0..7)
  Future<void> leaveSeat(String roomId, int seatIndex) async {
    await _apiClient.post('/v1/rooms/$roomId/seats/$seatIndex/leave');
  }

  /// Fetch Agora RTC token generated for the user's current room role
  Future<Map<String, dynamic>> getAgoraToken(String roomId) async {
    final response = await _apiClient.post('/v1/rooms/$roomId/agora-token');
    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// Refresh an existing Agora RTC token
  Future<Map<String, dynamic>> refreshAgoraToken(String roomId) async {
    final response = await _apiClient.post(
      '/v1/rooms/$roomId/agora-token/refresh',
    );
    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// Get room members with optional search filtering
  Future<Map<String, dynamic>> getRoomMembers(
    String roomId, {
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    final response = await _apiClient.get(
      '/v1/rooms/$roomId/members',
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>? ?? {};
  }

  /// Update a room member's role (Host or Admin only)
  Future<Map<String, dynamic>> updateMemberRole(
    String roomId,
    String targetUserId,
    String role,
  ) async {
    final response = await _apiClient.put(
      '/v1/rooms/$roomId/members/$targetUserId/role',
      data: {'role': role},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// Get Room Sending Rankings (Daily, Weekly, Monthly)
  Future<Map<String, dynamic>> getRoomSendingRankings(
    String roomId, {
    String period = 'daily',
  }) async {
    final response = await _apiClient.get(
      '/v1/rooms/$roomId/rankings',
      queryParameters: {'period': period},
    );
    return response.data?['data'] as Map<String, dynamic>? ?? {};
  }

  /// Clear lower room feed (Owner or Room Admin only)
  Future<void> clearRoomFeed(String roomId) async {
    try {
      await _apiClient.post(
        '/v1/rooms/$roomId/clear-feed',
        data: {'clearedAt': DateTime.now().toIso8601String()},
      );
    } catch (_) {}
  }
}
