import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/core/services/room_lock_manager.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 6: Private Hangout Rooms Tests', () {
    test('RoomPrivacyLevel enum and badge formatting', () {
      expect(RoomPrivacyLevel.public.badgeText, isEmpty);
      expect(RoomPrivacyLevel.friendsOnly.badgeText, equals('Friends'));
      expect(RoomPrivacyLevel.password.badgeText, equals('Password'));
      expect(RoomPrivacyLevel.inviteOnly.badgeText, equals('Invite Only'));
    });

    test('RoomLockState JSON serialization and backward compatibility', () {
      final json = {
        'isLocked': true,
        'lockMode': 'PIN',
        'pinCode': '9876',
        'privacyLevel': 'friendsOnly',
        'allowFriendBypass': true,
      };

      final state = RoomLockState.fromJson(json);
      expect(state.isLocked, isTrue);
      expect(state.lockMode, equals('PIN'));
      expect(state.pinCode, equals('9876'));
      expect(state.privacyLevel, equals(RoomPrivacyLevel.friendsOnly));
      expect(state.allowFriendBypass, isTrue);

      final serialized = state.toJson();
      expect(serialized['privacyLevel'], equals('friendsOnly'));
      expect(serialized['allowFriendBypass'], isTrue);
    });

    test('canUserBypassLock allows host, admin, and friends when friend bypass is active', () {
      final manager = RoomLockManager.instance;
      const hostUser = UserModel(
        id: 'host_danial',
        username: 'danial',
        name: 'Danial',
        avatarUrl: 'https://example.com/danial.png',
      );

      final room = LiveRoomModel(
        id: 'private_room_101',
        title: 'VIP Lounge',
        coverUrl: 'https://example.com/cover.png',
        viewerCount: 15,
        category: 'Hangout',
        startTime: DateTime(2026, 1, 1),
        host: hostUser,
        creatorUserId: 'host_danial',
      );

      manager.saveLockSettings(
        roomId: room.id,
        isLocked: true,
        mode: 'PIN',
        pin: '5555',
        privacyLevel: RoomPrivacyLevel.password,
        allowFriendBypass: true,
      );

      // 1. Host always bypasses
      expect(manager.canUserBypassLock(room: room, user: hostUser), isTrue);

      // 2. Stranger does NOT bypass
      const strangerUser = UserModel(
        id: 'stranger_1',
        username: 'stranger',
        name: 'Stranger',
        avatarUrl: 'https://example.com/stranger.png',
      );
      expect(
        manager.canUserBypassLock(room: room, user: strangerUser, isFriend: false),
        isFalse,
      );

      // 3. Friend DOES bypass because allowFriendBypass is true
      const friendUser = UserModel(
        id: 'friend_sarah',
        username: 'sarah',
        name: 'Sarah',
        avatarUrl: 'https://example.com/sarah.png',
      );
      expect(
        manager.canUserBypassLock(room: room, user: friendUser, isFriend: true),
        isTrue,
      );
    });

    test('canUserBypassLock blocks friends if allowFriendBypass is false', () {
      final manager = RoomLockManager.instance;
      const hostUser = UserModel(
        id: 'host_danial_2',
        username: 'danial2',
        name: 'Danial',
        avatarUrl: '',
      );

      final room = LiveRoomModel(
        id: 'strict_room_202',
        title: 'Strict Confidential Room',
        coverUrl: '',
        viewerCount: 0,
        category: 'Private',
        startTime: DateTime(2026, 1, 1),
        host: hostUser,
        creatorUserId: 'host_danial_2',
      );

      manager.saveLockSettings(
        roomId: room.id,
        isLocked: true,
        mode: 'PIN',
        pin: '9999',
        privacyLevel: RoomPrivacyLevel.password,
        allowFriendBypass: false,
      );

      const friendUser = UserModel(
        id: 'friend_bob',
        username: 'bob',
        name: 'Bob',
        avatarUrl: '',
      );

      // Since allowFriendBypass is false, even friends must enter PIN
      expect(
        manager.canUserBypassLock(room: room, user: friendUser, isFriend: true),
        isFalse,
      );
    });
  });
}
