import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/core/config/app_config.dart';
import 'package:hemiton/core/repositories/gift_repository.dart';
import 'package:hemiton/core/repositories/room_repository.dart';
import 'package:hemiton/core/repositories/backend_repository.dart';
import 'package:hemiton/models/gift_model.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/models/wallet_model.dart';
import 'package:hemiton/providers/live_gift_provider.dart';
import 'package:hemiton/providers/wallet_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.initialize(environment: AppEnvironment.development);
    AppConfig.isBackendDisconnected = true;
  });

  group('Bug 1 Fix Tests: Gift Sending Flow & Initialization', () {
    test('GiftRepository.fetchGifts returns catalog gifts safely without type errors', () async {
      final gifts = await GiftRepository.instance.fetchGifts();
      expect(gifts, isNotEmpty);
      expect(gifts.first.name, isNotEmpty);
    });

    test('GiftRepository.sendGift returns simulated transaction when offline/disconnected', () async {
      final result = await GiftRepository.instance.sendGift(
        giftId: 'rose_1',
        recipientUserId: 'receiver_456',
        quantity: 5,
        roomId: 'room_789',
        idempotencyKey: 'test_key_1',
      );

      expect(result['transactionId'], isNotNull);
      expect(result['giftId'], equals('rose_1'));
      expect(result['recipientUserId'], equals('receiver_456'));
      expect(result['quantity'], equals(5));
      expect(result['roomId'], equals('room_789'));
    });

    test('LiveGiftProvider.sendGift validates coin balance and deducts coins correctly', () async {
      final walletProvider = WalletProvider();
      final liveGiftProvider = LiveGiftProvider();

      // Give wallet known balance
      walletProvider.earnCoins(1000, 'Test credit');
      final initialCoins = walletProvider.coins;
      expect(initialCoins, greaterThanOrEqualTo(1000));

      const sender = UserModel(
        id: 'sender_001',
        username: 'alice',
        name: 'Alice',
        avatarUrl: '',
      );
      const receiver = UserModel(
        id: 'receiver_002',
        username: 'bob',
        name: 'Bob',
        avatarUrl: '',
      );

      final gift = GiftModel(
        id: 'gift_star',
        name: 'Star',
        icon: '⭐',
        diamondPrice: 100,
        priceCoins: 100,
        category: 'Classic',
      );

      final success = await liveGiftProvider.sendGift(
        walletProvider: walletProvider,
        gift: gift,
        sender: sender,
        receiver: receiver,
        roomId: 'room_live_1',
        quantity: 2,
      );

      expect(success, isTrue);
      // Cost was 2 * 100 = 200 coins
      expect(walletProvider.coins, equals(initialCoins - 200));
    });

    test('LiveGiftProvider.sendGift rejects when coins are insufficient without crashing', () async {
      final walletProvider = WalletProvider();
      final liveGiftProvider = LiveGiftProvider();

      // Spend down to 0 coins
      walletProvider.spendCoins(1);
      walletProvider.spendCoins(walletProvider.coins);
      expect(walletProvider.coins, equals(0));

      const sender = UserModel(id: 'sender_001', username: 'alice', name: 'Alice', avatarUrl: '');
      const receiver = UserModel(id: 'receiver_002', username: 'bob', name: 'Bob', avatarUrl: '');
      final gift = GiftModel(
        id: 'luxury_car',
        name: 'Supercar',
        icon: '🏎️',
        diamondPrice: 5000,
        priceCoins: 5000,
        category: 'Luxury',
      );

      final success = await liveGiftProvider.sendGift(
        walletProvider: walletProvider,
        gift: gift,
        sender: sender,
        receiver: receiver,
        roomId: 'room_live_1',
        quantity: 1,
      );

      expect(success, isFalse);
      expect(liveGiftProvider.lastError, contains('Insufficient coin balance'));
    });
  });

  group('Bug 2 Fix Tests: Room Creation & Room Lifecycle Preservation', () {
    test('LiveRoomModel parses MongoDB _id, id, and roomId uniformly', () {
      final jsonWithUnderscore = {
        '_id': 'mongo_obj_id_999',
        'title': 'Party Hangout',
        'roomType': 'AUDIO_PARTY',
        'status': 'LIVE',
      };
      final room1 = LiveRoomModel.fromJson(jsonWithUnderscore);
      expect(room1.id, equals('mongo_obj_id_999'));

      final jsonWithRoomId = {
        'roomId': 'room_id_888',
        'title': 'Video Live',
        'roomType': 'LIVE_VIDEO',
        'status': 'LIVE',
      };
      final room2 = LiveRoomModel.fromJson(jsonWithRoomId);
      expect(room2.id, equals('room_id_888'));
    });

    test('RoomRepository.createRoom returns valid room with valid ID and host details', () async {
      const hostUser = UserModel(
        id: 'host_creator_123',
        username: 'creator_host',
        name: 'Creator Host',
        avatarUrl: 'https://example.com/host.jpg',
      );

      final room = await RoomRepository.instance.createRoom(
        title: 'New Acoustic Chillout',
        roomType: 'AUDIO_PARTY',
        category: 'MUSIC',
        isPrivate: false,
        hostUser: hostUser,
      );

      expect(room.id, isNotEmpty);
      expect(room.title, equals('New Acoustic Chillout'));
      expect(room.roomType, equals('AUDIO_PARTY'));
      expect(room.category, equals('MUSIC'));
      expect(room.host.id, equals('host_creator_123'));
      expect(room.status, equals('LIVE'));
    });

    test('BackendRepository preserves newly created active live rooms across fetchLiveRooms', () async {
      final backend = BackendRepository.instance;
      const host = UserModel(id: 'host_preserve', username: 'host_p', name: 'Preserved Host', avatarUrl: '');

      final newlyCreatedRoom = LiveRoomModel(
        id: 'room_fresh_101',
        title: 'Fresh Room That Should Not Disappear',
        host: host,
        coverUrl: '',
        viewerCount: 1,
        startTime: DateTime.now(),
        category: 'CHAT',
        status: 'LIVE',
        creatorUserId: 'host_preserve',
      );

      backend.addLiveRoom(newlyCreatedRoom);
      expect(backend.liveRooms.any((r) => r.id == 'room_fresh_101'), isTrue);

      // Now simulate what the 4-second background refresh timer executes:
      await backend.fetchLiveRooms();

      // The active room MUST still be retained in _liveRooms
      expect(backend.liveRooms.any((r) => r.id == 'room_fresh_101'), isTrue);
    });

    test('RoomRepository.joinRoom and getRoomDetails handle offline/disconnected gracefully', () async {
      final joinResult = await RoomRepository.instance.joinRoom('room_offline_555');
      expect(joinResult['roomId'], equals('room_offline_555'));

      final details = await RoomRepository.instance.getRoomDetails('room_offline_555');
      expect(details.id, equals('room_offline_555'));
      expect(details.status, equals('LIVE'));
    });
  });
}
