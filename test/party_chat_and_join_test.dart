import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Room ID Matching Tests', () {
    bool matchesRoom({
      required String incomingRoomId,
      required String incomingClientRoomId,
      required String primaryRoomId,
      String? secondaryRoomId,
    }) {
      final inRoomId = incomingRoomId.trim().toLowerCase();
      final inClientRoomId = incomingClientRoomId.trim().toLowerCase();
      final primary = primaryRoomId.trim().toLowerCase();
      final secondary = (secondaryRoomId ?? '').trim().toLowerCase();

      final validRoomIds = <String>{
        if (primary.isNotEmpty) primary,
        if (secondary.isNotEmpty) secondary,
      };

      if (validRoomIds.isEmpty) return true;

      return (inRoomId.isNotEmpty && validRoomIds.contains(inRoomId)) ||
          (inClientRoomId.isNotEmpty && validRoomIds.contains(inClientRoomId)) ||
          (inRoomId.isEmpty && inClientRoomId.isEmpty);
    }

    test('matches canonical room ID when client entered with canonical ID', () {
      const canonicalId = '6709f3e4bc8192a00192';
      expect(
        matchesRoom(
          incomingRoomId: canonicalId,
          incomingClientRoomId: '104829',
          primaryRoomId: canonicalId,
        ),
        isTrue,
      );
    });

    test('matches short room ID when client entered with short ID', () {
      const canonicalId = '6709f3e4bc8192a00192';
      const shortId = '104829';
      expect(
        matchesRoom(
          incomingRoomId: canonicalId,
          incomingClientRoomId: shortId,
          primaryRoomId: shortId,
        ),
        isTrue,
      );
    });

    test('matches when both primary and secondary room IDs are supplied', () {
      const canonicalId = '6709f3e4bc8192a00192';
      const shortId = '104829';
      expect(
        matchesRoom(
          incomingRoomId: canonicalId,
          incomingClientRoomId: '',
          primaryRoomId: shortId,
          secondaryRoomId: canonicalId,
        ),
        isTrue,
      );
    });

    test('rejects unrelated room without substring false positives', () {
      // Room 1048 should NOT match room 104829 simply because 104829 starts with 1048
      expect(
        matchesRoom(
          incomingRoomId: '1048',
          incomingClientRoomId: '',
          primaryRoomId: '104829',
          secondaryRoomId: 'canonical_xyz_104829',
        ),
        isFalse,
      );
    });

    test('rejects totally different room IDs', () {
      expect(
        matchesRoom(
          incomingRoomId: 'other_room_999',
          incomingClientRoomId: 'other_short_999',
          primaryRoomId: 'my_room_111',
          secondaryRoomId: 'my_short_111',
        ),
        isFalse,
      );
    });
  });

  group('Join Notification Sliding Deduplication Tests', () {
    late Map<String, int> lastShownUserTimestamp;
    const dedupWindowMs = 8000;

    bool shouldShowJoinBanner(String userId, int nowMs) {
      final key = userId.trim().toLowerCase();
      if (key.isEmpty || key == 'viewer' || key == 'a user') return true;

      // Prune stale timestamps older than 60s
      lastShownUserTimestamp.removeWhere((_, ts) => nowMs - ts > 60000);

      if (lastShownUserTimestamp.containsKey(key)) {
        if (nowMs - lastShownUserTimestamp[key]! < dedupWindowMs) {
          return false; // Suppressed within 8s window
        }
      }

      lastShownUserTimestamp[key] = nowMs;
      return true;
    }

    setUp(() {
      lastShownUserTimestamp = {};
    });

    test('allows initial join notification for a user', () {
      expect(shouldShowJoinBanner('user_alice_1', 1000), isTrue);
    });

    test('suppresses rapid duplicate join / reconnect within 8 seconds', () {
      expect(shouldShowJoinBanner('user_alice_1', 1000), isTrue);
      // Reconnect bounce 2 seconds later
      expect(shouldShowJoinBanner('user_alice_1', 3000), isFalse);
      // Another ping 5 seconds later
      expect(shouldShowJoinBanner('user_alice_1', 6000), isFalse);
    });

    test('allows new join notification after user leaves and rejoins after 8s', () {
      expect(shouldShowJoinBanner('user_alice_1', 1000), isTrue);
      // User returns after 10 seconds (exceeding 8s debounce)
      expect(shouldShowJoinBanner('user_alice_1', 11000), isTrue);
    });

    test('treats distinct guest IDs independently even with similar display names', () {
      // Guest A and Guest B have different guest socket IDs
      expect(shouldShowJoinBanner('guest_S-sit4K8L', 1000), isTrue);
      expect(shouldShowJoinBanner('guest_i79CH2aB', 1500), isTrue);
      expect(shouldShowJoinBanner('guest_9R-tlXyZ', 2000), isTrue);
    });
  });

  group('Chat Message Deduplication Logic Tests', () {
    test('does NOT suppress identical messages from different users', () {
      final messages = <Map<String, dynamic>>[];
      const currentUserId = 'user_local_me';

      bool shouldAddMessage({
        required String senderId,
        required String text,
        required String msgId,
        required int timestampMs,
      }) {
        // Direct ID check
        if (messages.any((m) => m['id'] == msgId)) return false;

        final isCurrentLocalUser = senderId == currentUserId;

        // Deduplication strictly applies to local user's optimistic echoes
        if (isCurrentLocalUser && messages.isNotEmpty) {
          final recentIdx = messages.lastIndexWhere((m) =>
              m['senderId'] == currentUserId &&
              m['text'] == text &&
              (timestampMs - (m['timestampMs'] as int)) < 8000);
          if (recentIdx != -1) return false;
        }

        messages.add({
          'id': msgId,
          'senderId': senderId,
          'text': text,
          'timestampMs': timestampMs,
        });
        return true;
      }

      // User A says "hello"
      expect(
        shouldAddMessage(senderId: 'user_a', text: 'hello', msgId: 'm1', timestampMs: 1000),
        isTrue,
      );

      // User B also says "hello" 1 second later -> MUST NOT BE DROPPED!
      expect(
        shouldAddMessage(senderId: 'user_b', text: 'hello', msgId: 'm2', timestampMs: 2000),
        isTrue,
      );

      // User C posts same emoji "🔥" -> MUST NOT BE DROPPED!
      expect(
        shouldAddMessage(senderId: 'user_c', text: '🔥', msgId: 'm3', timestampMs: 2500),
        isTrue,
      );

      // Total messages should be 3
      expect(messages.length, equals(3));
    });

    test('deduplicates sender optimistic echo cleanly', () {
      final messages = <Map<String, dynamic>>[];
      const currentUserId = 'user_local_me';

      // 1. Local user optimistic send
      messages.add({
        'id': 'client_msg_100',
        'senderId': currentUserId,
        'text': 'great stream!',
        'timestampMs': 1000,
      });

      // 2. Server broadcast arrives for local user
      bool handleIncomingEcho({
        required String senderId,
        required String text,
        required String serverMsgId,
        required int timestampMs,
      }) {
        if (messages.any((m) => m['id'] == serverMsgId)) return false;

        final isCurrentLocalUser = senderId == currentUserId;
        if (isCurrentLocalUser && messages.isNotEmpty) {
          final recentIdx = messages.lastIndexWhere((m) =>
              m['senderId'] == currentUserId &&
              m['text'] == text &&
              (timestampMs - (m['timestampMs'] as int)) < 8000);
          if (recentIdx != -1) {
            // Update optimistic message with authoritative server ID
            messages[recentIdx]['id'] = serverMsgId;
            return false; // Handled as echo, no duplicate item added
          }
        }

        messages.add({
          'id': serverMsgId,
          'senderId': senderId,
          'text': text,
          'timestampMs': timestampMs,
        });
        return true;
      }

      final addedAsNew = handleIncomingEcho(
        senderId: currentUserId,
        text: 'great stream!',
        serverMsgId: 'srv_msg_200',
        timestampMs: 1200,
      );

      expect(addedAsNew, isFalse);
      expect(messages.length, equals(1));
      expect(messages.first['id'], equals('srv_msg_200'));
    });
  });

  group('Change 13: Mic Invitation Protocol & Lifecycle Tests', () {
    bool isTargetUserMatch(String targetUserId, String currentUserId) {
      final t = targetUserId.trim();
      final c = currentUserId.trim();
      if (t.isEmpty || c.isEmpty) return false;
      return t == c ||
          t.toLowerCase() == c.toLowerCase() ||
          t.replaceAll('user_', '') == c.replaceAll('user_', '');
    }

    test('matches target user ID across string, numeric, and user_ prefixed formats', () {
      expect(isTargetUserMatch('9202535', '9202535'), isTrue);
      expect(isTargetUserMatch('user_9202535', '9202535'), isTrue);
      expect(isTargetUserMatch('9202535', 'user_9202535'), isTrue);
      expect(isTargetUserMatch('User_ALICE', 'user_alice'), isTrue);
      expect(isTargetUserMatch('9202535', '9202999'), isFalse);
    });

    test('pending outgoing invite lifecycle expires after 30 seconds', () {
      final pendingInvites = <String, Map<String, dynamic>>{};

      void addInvite(String targetId, int nowMs) {
        pendingInvites[targetId] = {
          'id': 'inv_$targetId',
          'timestamp': nowMs,
        };
      }

      bool isInvitePending(String targetId, int nowMs) {
        final inv = pendingInvites[targetId];
        if (inv == null) return false;
        final ts = inv['timestamp'] as int;
        if (nowMs - ts > 30000) {
          pendingInvites.remove(targetId);
          return false;
        }
        return true;
      }

      addInvite('user_bob', 10000);
      expect(isInvitePending('user_bob', 15000), isTrue); // 5s elapsed
      expect(isInvitePending('user_bob', 39999), isTrue); // 29.9s elapsed
      expect(isInvitePending('user_bob', 40001), isFalse); // >30s expired
      expect(pendingInvites.containsKey('user_bob'), isFalse); // auto-cleaned
    });

    test('pending outgoing invite clears immediately upon accept or decline response', () {
      final pendingInvites = <String, Map<String, dynamic>>{
        'user_carol': {'id': 'inv_101', 'timestamp': 1000},
      };

      void handleInviteResponse(String targetUserId) {
        pendingInvites.remove(targetUserId);
        pendingInvites.remove(targetUserId.replaceAll('user_', ''));
        pendingInvites.remove('user_$targetUserId');
      }

      handleInviteResponse('user_carol');
      expect(pendingInvites.containsKey('user_carol'), isFalse);
    });

    test('pending invite clears when user leaves the room', () {
      final pendingInvites = <String, Map<String, dynamic>>{
        'user_david': {'id': 'inv_102', 'timestamp': 1000},
      };

      void onUserLeft(String leftUserId) {
        pendingInvites.remove(leftUserId);
      }

      onUserLeft('user_david');
      expect(pendingInvites.containsKey('user_david'), isFalse);
    });
  });
}
