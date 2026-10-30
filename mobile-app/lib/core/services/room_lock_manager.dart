import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/live_room_model.dart';
import '../../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Item 07: Room Lock Manager & Access Enforcement
// ─────────────────────────────────────────────────────────────────────────────

enum RoomPrivacyLevel {
  public,
  friendsOnly,
  password,
  inviteOnly,
}

extension RoomPrivacyLevelX on RoomPrivacyLevel {
  String get label {
    switch (this) {
      case RoomPrivacyLevel.public:
        return 'Public';
      case RoomPrivacyLevel.friendsOnly:
        return 'Friends Only';
      case RoomPrivacyLevel.password:
        return 'Password Protected';
      case RoomPrivacyLevel.inviteOnly:
        return 'Invite Only';
    }
  }

  String get badgeText {
    switch (this) {
      case RoomPrivacyLevel.public:
        return '';
      case RoomPrivacyLevel.friendsOnly:
        return 'Friends';
      case RoomPrivacyLevel.password:
        return 'Password';
      case RoomPrivacyLevel.inviteOnly:
        return 'Invite Only';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomPrivacyLevel.public:
        return Icons.public_rounded;
      case RoomPrivacyLevel.friendsOnly:
        return Icons.people_alt_rounded;
      case RoomPrivacyLevel.password:
        return Icons.lock_rounded;
      case RoomPrivacyLevel.inviteOnly:
        return Icons.mail_lock_rounded;
    }
  }
}

class RoomLockState {
  bool isLocked;
  String lockMode; // 'PIN' or 'Approval'
  String pinCode;
  RoomPrivacyLevel privacyLevel;
  bool allowFriendBypass;
  final Set<String> admittedUserIds;
  final Set<String> pendingApprovalUserIds;

  RoomLockState({
    this.isLocked = false,
    this.lockMode = 'PIN',
    this.pinCode = '1234',
    this.privacyLevel = RoomPrivacyLevel.public,
    this.allowFriendBypass = true,
    Set<String>? admittedUserIds,
    Set<String>? pendingApprovalUserIds,
  })  : admittedUserIds = admittedUserIds ?? {},
        pendingApprovalUserIds = pendingApprovalUserIds ?? {};

  Map<String, dynamic> toJson() => {
        'isLocked': isLocked,
        'lockMode': lockMode,
        'pinCode': pinCode,
        'privacyLevel': privacyLevel.name,
        'allowFriendBypass': allowFriendBypass,
      };

  factory RoomLockState.fromJson(Map<String, dynamic> json) {
    final privName = json['privacyLevel']?.toString();
    final priv = RoomPrivacyLevel.values.firstWhere(
      (e) => e.name == privName,
      orElse: () => json['isLocked'] == true
          ? (json['lockMode'] == 'Approval'
              ? RoomPrivacyLevel.inviteOnly
              : RoomPrivacyLevel.password)
          : RoomPrivacyLevel.public,
    );
    return RoomLockState(
      isLocked: json['isLocked'] == true,
      lockMode: json['lockMode']?.toString() ?? 'PIN',
      pinCode: json['pinCode']?.toString() ?? '1234',
      privacyLevel: priv,
      allowFriendBypass: json['allowFriendBypass'] != false,
    );
  }
}

class RoomLockManager extends ChangeNotifier {
  static final RoomLockManager instance = RoomLockManager._internal();
  RoomLockManager._internal() {
    _loadFromPrefs();
  }

  final Map<String, RoomLockState> _states = {};
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('HEMI TON_room_lock_'));
      for (final key in keys) {
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          final roomId = key.replaceFirst('HEMI TON_room_lock_', '');
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _states[roomId] = RoomLockState.fromJson(map);
        }
      }
      _isLoaded = true;
      notifyListeners();
    } catch (_) {}
  }

  RoomLockState getRoomState(String roomId) {
    return _states.putIfAbsent(roomId, () => RoomLockState());
  }

  bool isRoomLocked(String roomId) {
    return _states[roomId]?.isLocked ?? false;
  }

  String getRoomLockMode(String roomId) {
    return _states[roomId]?.lockMode ?? 'PIN';
  }

  String getRoomPin(String roomId) {
    return _states[roomId]?.pinCode ?? '1234';
  }

  bool isUserAdmitted(String roomId, String userId) {
    return _states[roomId]?.admittedUserIds.contains(userId) ?? false;
  }

  void admitUser(String roomId, String userId) {
    final state = getRoomState(roomId);
    state.admittedUserIds.add(userId);
    state.pendingApprovalUserIds.remove(userId);
    notifyListeners();
  }

  void requestApproval(String roomId, String userId) {
    final state = getRoomState(roomId);
    state.pendingApprovalUserIds.add(userId);
    notifyListeners();
  }

  bool isUserPendingApproval(String roomId, String userId) {
    return _states[roomId]?.pendingApprovalUserIds.contains(userId) ?? false;
  }

  RoomPrivacyLevel getRoomPrivacyLevel(String roomId) {
    return _states[roomId]?.privacyLevel ?? RoomPrivacyLevel.public;
  }

  bool doesAllowFriendBypass(String roomId) {
    return _states[roomId]?.allowFriendBypass ?? true;
  }

  Future<void> saveLockSettings({
    required String roomId,
    required bool isLocked,
    required String mode,
    required String pin,
    RoomPrivacyLevel? privacyLevel,
    bool? allowFriendBypass,
  }) async {
    final state = getRoomState(roomId);
    state.isLocked = isLocked;
    state.lockMode = mode;
    state.pinCode = pin.trim().isEmpty ? '1234' : pin.trim();
    if (privacyLevel != null) {
      state.privacyLevel = privacyLevel;
    } else {
      state.privacyLevel = isLocked
          ? (mode == 'Approval'
              ? RoomPrivacyLevel.inviteOnly
              : RoomPrivacyLevel.password)
          : RoomPrivacyLevel.public;
    }
    if (allowFriendBypass != null) {
      state.allowFriendBypass = allowFriendBypass;
    }

    if (!isLocked && state.privacyLevel == RoomPrivacyLevel.public) {
      state.admittedUserIds.clear();
      state.pendingApprovalUserIds.clear();
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'HEMI TON_room_lock_$roomId',
        jsonEncode(state.toJson()),
      );
    } catch (_) {}
  }

  bool canUserBypassLock({
    required LiveRoomModel room,
    required UserModel user,
    bool isFriend = false,
  }) {
    if (user.id.isEmpty) return false;
    // Host / Creator always has access
    if (user.id == room.host.id || user.id == room.creatorUserId) return true;
    // Admin role has access
    if (user.role == UserRole.admin) return true;

    // Feature 6: Friend bypass check
    final state = getRoomState(room.id);
    final isMutualOrFriend = isFriend || room.isFriendOfFriend;
    if (state.allowFriendBypass && isMutualOrFriend) {
      return true;
    }
    if (state.privacyLevel == RoomPrivacyLevel.friendsOnly && isMutualOrFriend) {
      return true;
    }

    return false;
  }

  /// Master gatekeeper check before opening room
  void checkAndEnterRoom(
    BuildContext context, {
    required LiveRoomModel room,
    required UserModel currentUser,
    required VoidCallback onAdmitted,
  }) {
    // 1. Bypass check (Host / Admin)
    if (canUserBypassLock(room: room, user: currentUser)) {
      onAdmitted();
      return;
    }

    // 2. Lock state check (from manager or room model)
    final locked = isRoomLocked(room.id) || room.isPrivate || room.roomMode == 'Lock mode';
    if (!locked) {
      onAdmitted();
      return;
    }

    // 3. User already admitted
    if (isUserAdmitted(room.id, currentUser.id)) {
      onAdmitted();
      return;
    }

    final mode = getRoomLockMode(room.id);

    // 4. Mode-specific challenge
    if (mode == 'Approval') {
      showDialog(
        context: context,
        builder: (_) => RoomApprovalDialog(
          room: room,
          currentUser: currentUser,
          onApproved: () {
            admitUser(room.id, currentUser.id);
            onAdmitted();
          },
        ),
      );
    } else {
      // PIN Mode
      showDialog(
        context: context,
        builder: (_) => RoomPinEntryDialog(
          room: room,
          onCorrectPin: () {
            admitUser(room.id, currentUser.id);
            onAdmitted();
          },
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN Entry Dialog
// ─────────────────────────────────────────────────────────────────────────────

class RoomPinEntryDialog extends StatefulWidget {
  final LiveRoomModel room;
  final VoidCallback onCorrectPin;

  const RoomPinEntryDialog({
    super.key,
    required this.room,
    required this.onCorrectPin,
  });

  @override
  State<RoomPinEntryDialog> createState() => _RoomPinEntryDialogState();
}

class _RoomPinEntryDialogState extends State<RoomPinEntryDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final entered = _pinController.text.trim();
    final actualPin = RoomLockManager.instance.getRoomPin(widget.room.id);

    if (entered == actualPin) {
      Navigator.pop(context);
      widget.onCorrectPin();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN! Please enter the correct 4-digit PIN.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1B2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.lock_rounded, color: Colors.cyanAccent),
          SizedBox(width: 8),
          Text(
            'Room is Protected',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter the 4-digit PIN to access "${widget.room.title}".',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            autofocus: true,
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              hintStyle: const TextStyle(color: Colors.white30, letterSpacing: 8),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.cyanAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
              ),
            ),
            onSubmitted: (_) => _verifyPin(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: _verifyPin,
          child: const Text('Enter Room', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Approval Request Dialog
// ─────────────────────────────────────────────────────────────────────────────

class RoomApprovalDialog extends StatefulWidget {
  final LiveRoomModel room;
  final UserModel currentUser;
  final VoidCallback onApproved;

  const RoomApprovalDialog({
    super.key,
    required this.room,
    required this.currentUser,
    required this.onApproved,
  });

  @override
  State<RoomApprovalDialog> createState() => _RoomApprovalDialogState();
}

class _RoomApprovalDialogState extends State<RoomApprovalDialog> {
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    _hasRequested = RoomLockManager.instance.isUserPendingApproval(widget.room.id, widget.currentUser.id);
  }

  void _sendRequest() {
    RoomLockManager.instance.requestApproval(widget.room.id, widget.currentUser.id);
    setState(() => _hasRequested = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📩 Entry request submitted to Host!'),
        backgroundColor: Colors.cyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1B2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.admin_panel_settings_rounded, color: Colors.cyanAccent),
          SizedBox(width: 8),
          Text(
            'Approval Required',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This room is in Approval Mode. You must request entry from the host before entering "${widget.room.title}".',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_hasRequested)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Request sent! Waiting for Host approval...',
                      style: TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white60)),
        ),
        if (!_hasRequested)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: _sendRequest,
            child: const Text('Request Entry 📩', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}
