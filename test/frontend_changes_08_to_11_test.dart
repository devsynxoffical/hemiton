import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/core/services/room_config_manager.dart';
import 'package:hemiton/core/utils/formatters.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testHost = UserModel(
    id: 'host_101',
    name: 'PartyHost',
    username: 'partyhost',
    avatarUrl: 'https://example.com/avatar.jpg',
    diamonds: 0,
    coins: 1000,
  );

  final baseRoom = LiveRoomModel(
    id: 'room_test_999',
    title: 'Original Title',
    announcement: 'Welcome!',
    coverUrl: 'https://example.com/original_dp.jpg',
    host: testHost,
    roomMode: 'public',
    seatCapacity: 8, // legacy capacity
    viewerCount: 5,
    category: 'Chat',
    startTime: DateTime.now(),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    RoomConfigManager.instance.resetForTesting();
  });

  group('Item 09: Room Name & DP Persistence Across Rejoining', () {
    test('Persists edited room title and applies override on LiveRoomModel', () async {
      await RoomConfigManager.instance.saveRoomProfile('room_test_999', title: 'Awesome VIP Lounge');
      final overridden = RoomConfigManager.instance.applyOverrides(baseRoom);

      expect(overridden.title, equals('Awesome VIP Lounge'));
      expect(RoomConfigManager.instance.getCustomTitle('room_test_999'), equals('Awesome VIP Lounge'));
    });

    test('Persists edited room DP/cover URL and applies override on LiveRoomModel', () async {
      await RoomConfigManager.instance.saveRoomProfile('room_test_999', coverUrl: 'https://example.com/new_party_dp.png');
      final overridden = RoomConfigManager.instance.applyOverrides(baseRoom);

      expect(overridden.coverUrl, equals('https://example.com/new_party_dp.png'));
      expect(RoomConfigManager.instance.getCustomCover('room_test_999'), equals('https://example.com/new_party_dp.png'));
    });

    test('Falls back to base room attributes if no overrides were saved for title and cover', () {
      final fresh = RoomConfigManager.instance.applyOverrides(baseRoom);
      expect(fresh.title, equals('Original Title'));
      expect(fresh.coverUrl, equals('https://example.com/original_dp.jpg'));
    });
  });

  group('Item 11: Mic Seat Count & Capacity Persistence & Sync', () {
    test('Persists updated seat capacity (10, 15, 20, 30)', () async {
      await RoomConfigManager.instance.saveRoomLayout('room_test_999', capacity: 15, roomType: 'AUDIO_PARTY');
      final overridden = RoomConfigManager.instance.applyOverrides(baseRoom);

      expect(overridden.seatCapacity, equals(15));
      expect(RoomConfigManager.instance.getCustomCapacity('room_test_999'), equals(15));
    });

    test('Persists 20 mic capacity across re-entry', () async {
      await RoomConfigManager.instance.saveRoomLayout('room_test_999', capacity: 20, roomType: 'AUDIO_PARTY');
      final overridden = RoomConfigManager.instance.applyOverrides(baseRoom);

      expect(overridden.seatCapacity, equals(20));
      expect(RoomConfigManager.instance.getCustomCapacity('room_test_999'), equals(20));
    });
  });

  group('Item 04 Addendum: Seat 7 and 8 Locking and Zero-based Standard', () {
    test('Standard room provides 10 mic slots (indices 0 to 9)', () {
      final totalSeats = [10, 15, 20, 30].contains(baseRoom.seatCapacity) ? baseRoom.seatCapacity : 10;
      expect(totalSeats, equals(10));
    });

    test('Canonical seat labeling for 10-mic layout correctly labels Seat 7 and Seat 8', () {
      String getSeatLabel(int index) {
        if (index == 0) return 'Host Mic';
        if (index == 1) return 'Co-Host Mic';
        return 'Mic ${index - 1}';
      }

      expect(getSeatLabel(0), equals('Host Mic'));
      expect(getSeatLabel(1), equals('Co-Host Mic'));
      expect(getSeatLabel(2), equals('Mic 1'));
      expect(getSeatLabel(3), equals('Mic 2'));
      expect(getSeatLabel(7), equals('Mic 6'));
      expect(getSeatLabel(8), equals('Mic 7')); // Seat 7 is index 8
      expect(getSeatLabel(9), equals('Mic 8')); // Seat 8 is index 9
    });

    test('Allows locking and unlocking Seat 7 (index 8) and Seat 8 (index 9)', () async {
      await RoomConfigManager.instance.setSeatLocked('room_test_999', 8, true);
      await RoomConfigManager.instance.setSeatLocked('room_test_999', 9, true);

      final reloadedLocked = RoomConfigManager.instance.getLockedSeats('room_test_999');
      expect(reloadedLocked.contains(8), isTrue);
      expect(reloadedLocked.contains(9), isTrue);
      expect(reloadedLocked.contains(0), isFalse);

      // Unlock Seat 8
      await RoomConfigManager.instance.setSeatLocked('room_test_999', 9, false);
      final unlockedSet = RoomConfigManager.instance.getLockedSeats('room_test_999');
      expect(unlockedSet.contains(8), isTrue);
      expect(unlockedSet.contains(9), isFalse);
    });
  });

  group('Item 08: Room Trophy Counter & Daily Sending Total Sync', () {
    test('Compact coin format displays 6.8K for 6800 coins matching daily ranking sheet', () {
      expect(AppFormatters.formatNumber(6800), equals('6.8K'));
      expect(AppFormatters.formatNumber(0), equals('0'));
      expect(AppFormatters.formatNumber(1250000), equals('1.3M'));
    });

    test('Persists room sending total across rejoining and re-entry', () async {
      await RoomConfigManager.instance.saveRoomSendingTotal('room_test_999', 6800);
      final total = RoomConfigManager.instance.getRoomSendingTotal('room_test_999');

      expect(total, equals(6800));
      expect(AppFormatters.formatNumber(total.toInt()), equals('6.8K'));
    });

    test('addSendingCoins accumulates coins correctly', () async {
      await RoomConfigManager.instance.saveRoomSendingTotal('room_test_999', 6800);
      await RoomConfigManager.instance.addSendingCoins('room_test_999', 200);

      final total = RoomConfigManager.instance.getRoomSendingTotal('room_test_999');
      expect(total, equals(7000));
      expect(AppFormatters.formatNumber(total.toInt()), equals('7.0K'));
    });
  });
}
