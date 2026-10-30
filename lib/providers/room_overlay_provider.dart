import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/live_room_model.dart';
import '../features/live/live_room_screen.dart';
import '../features/live/live_broadcast_screen.dart';
import '../features/party_room/live_party_room_screen.dart';
import '../core/repositories/room_repository.dart';
import 'live_provider.dart';
import 'live_party_provider.dart';

class RoomOverlayProvider extends ChangeNotifier {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isMinimized = false;
  String? _roomType; // 'LIVE', 'BROADCAST', or 'PARTY'
  LiveRoomModel? _activeRoom;
  bool _isHost = false;
  bool _isAudioMode = true;
  Offset _position = const Offset(16, 120);

  bool get isMinimized => _isMinimized;
  String? get roomType => _roomType;
  LiveRoomModel? get activeRoom => _activeRoom;
  bool get isHost => _isHost;
  bool get isAudioMode => _isAudioMode;
  Offset get position => _position;

  void minimizeRoom({
    required String roomType,
    required LiveRoomModel room,
    bool isHost = false,
    bool isAudioMode = true,
  }) {
    _isMinimized = true;
    _roomType = roomType;
    _activeRoom = room;
    _isHost = isHost;
    _isAudioMode = isAudioMode;
    notifyListeners();
  }

  void expandRoom([BuildContext? context]) {
    if (_activeRoom == null || _roomType == null) return;

    final targetRoom = _activeRoom!;
    final targetType = _roomType!;
    final host = _isHost;
    final audioMode = _isAudioMode;

    _isMinimized = false;
    notifyListeners();

    final navState = navigatorKey.currentState ?? (context != null ? Navigator.maybeOf(context) : null);

    if (navState != null) {
      if (targetType == 'BROADCAST') {
        navState.push(
          MaterialPageRoute(
            builder: (_) => LiveBroadcastScreen(
              room: targetRoom,
              isHost: host,
              isAudioMode: audioMode,
            ),
          ),
        );
      } else if (targetType == 'LIVE') {
        navState.push(
          MaterialPageRoute(
            builder: (_) => LiveRoomScreen(
              room: targetRoom,
              isHost: host,
            ),
          ),
        );
      } else {
        navState.push(
          MaterialPageRoute(
            builder: (_) => LivePartyRoomScreen(room: targetRoom),
          ),
        );
      }
    } else {
      debugPrint('[RoomOverlayProvider] Error: No NavigatorState found to expand room.');
    }
  }

  Future<void> closeRoom(BuildContext context) async {
    final type = _roomType;
    final host = _isHost;
    final activeId = _activeRoom?.id;
    final liveProvider = Provider.of<LiveProvider>(context, listen: false);
    final partyProvider = Provider.of<LivePartyProvider>(context, listen: false);

    _isMinimized = false;
    _activeRoom = null;
    _roomType = null;
    _isHost = false;
    notifyListeners();

    if (type == 'BROADCAST') {
      if (host && activeId != null) {
        try {
          await RoomRepository.instance.closeRoom(activeId);
        } catch (_) {}
      }
    } else if (type == 'LIVE') {
      if (host && activeId != null) {
        try {
          await RoomRepository.instance.closeRoom(activeId);
        } catch (_) {}
      }
      try {
        await liveProvider.leaveRoom();
      } catch (_) {}
    } else if (type == 'PARTY') {
      try {
        await partyProvider.unjoinCurrentRoom();
      } catch (_) {}
    }
  }

  void updatePosition(Offset delta, Size screenSize) {
    double newX = _position.dx + delta.dx;
    double newY = _position.dy + delta.dy;

    const double cardWidth = 150;
    const double cardHeight = 190;

    newX = newX.clamp(8.0, (screenSize.width - cardWidth - 8.0).clamp(8.0, screenSize.width));
    newY = newY.clamp(40.0, (screenSize.height - cardHeight - 40.0).clamp(40.0, screenSize.height));

    _position = Offset(newX, newY);
    notifyListeners();
  }
}
