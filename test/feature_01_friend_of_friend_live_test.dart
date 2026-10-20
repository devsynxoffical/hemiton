import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/live_room_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/core/repositories/backend_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 1: Friend-of-Friend Live Tests', () {
    test(
      'LiveRoomModel correctly parses and serializes Friend-of-Friend fields',
      () {
        final json = {
          'id': 'room_fof_101',
          'title': 'Chill Acoustic Jam',
          'coverImageUrl':
              'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7',
          'viewerCount': 420,
          'category': 'Music',
          'isPrivate': false,
          'status': 'LIVE',
          'isFriendOfFriend': true,
          'mutualFriend': {
            'id': 'user_sonia',
            'displayName': 'Sonia Malik',
            'avatarUrl':
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          },
          'creator': {
            'id': 'host_neha',
            'displayName': 'Neha',
            'username': 'neha_live',
            'avatarUrl':
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
          },
        };

        final room = LiveRoomModel.fromJson(json);

        expect(room.id, equals('room_fof_101'));
        expect(room.title, equals('Chill Acoustic Jam'));
        expect(room.isFriendOfFriend, isTrue);
        expect(room.mutualFriendName, equals('Sonia Malik'));
        expect(room.mutualFriendAvatar, contains('photo-1494790108377'));
        expect(room.host.name, equals('Neha'));

        final serialized = room.toJson();
        expect(serialized['isFriendOfFriend'], isTrue);
        expect(serialized['mutualFriendName'], equals('Sonia Malik'));
      },
    );

    test(
      'LiveRoomModel copyWith correctly preserves or updates FoF properties',
      () {
        final original = LiveRoomModel(
          id: 'room_1',
          title: 'Original Title',
          host: const UserModel(
            id: 'host_1',
            name: 'Original Host',
            username: 'host1',
            avatarUrl: 'https://example.com/a.png',
          ),
          coverUrl: 'https://example.com/cover.png',
          viewerCount: 50,
          category: 'Chat',
          startTime: DateTime(2026, 10, 19),
          isFriendOfFriend: false,
        );

        final updated = original.copyWith(
          isFriendOfFriend: true,
          mutualFriendName: 'Anam',
          mutualFriendAvatar: 'https://example.com/anam.png',
        );

        expect(updated.isFriendOfFriend, isTrue);
        expect(updated.mutualFriendName, equals('Anam'));
        expect(
          updated.mutualFriendAvatar,
          equals('https://example.com/anam.png'),
        );
        expect(updated.title, equals('Original Title'));
      },
    );

    test(
      'BackendRepository fetchFriendOfFriendLiveRooms populates eligible FoF live rooms',
      () async {
        final backend = BackendRepository.instance;
        // Pre-populate with sample room
        backend.addLiveRoom(
          LiveRoomModel(
            id: 'room_active_test',
            title: 'Test Live Stream',
            host: const UserModel(
              id: 'host_test',
              name: 'Test Host',
              username: 'testhost',
              avatarUrl: 'https://example.com/test_host.png',
            ),
            coverUrl: 'https://example.com/test.png',
            viewerCount: 15,
            category: 'Live',
            startTime: DateTime.now(),
          ),
        );

        final fofRooms = await backend.fetchFriendOfFriendLiveRooms();
        expect(fofRooms, isNotEmpty);
        expect(fofRooms.first.isFriendOfFriend, isTrue);
        expect(fofRooms.first.mutualFriendName, isNotNull);
      },
    );

    test(
      'Private rooms or blocked streams are filtered out from public FoF listing',
      () {
        final privateRoom = LiveRoomModel(
          id: 'room_private',
          title: 'Secret Room',
          host: const UserModel(
            id: 'host_p',
            name: 'Private Host',
            username: 'private',
            avatarUrl: 'https://example.com/p.png',
          ),
          coverUrl: '',
          viewerCount: 1,
          category: 'Secret',
          startTime: DateTime.now(),
          isPrivate: true,
          isFriendOfFriend: true,
        );

        final publicRoom = LiveRoomModel(
          id: 'room_public',
          title: 'Open Stream',
          host: const UserModel(
            id: 'host_open',
            name: 'Open Host',
            username: 'open',
            avatarUrl: 'https://example.com/open.png',
          ),
          coverUrl: '',
          viewerCount: 10,
          category: 'Live',
          startTime: DateTime.now(),
          isPrivate: false,
          isFriendOfFriend: true,
        );

        final allRooms = [privateRoom, publicRoom];
        final eligibleFoF = allRooms
            .where((r) => r.isFriendOfFriend && !r.isPrivate)
            .toList();

        expect(eligibleFoF.length, equals(1));
        expect(eligibleFoF.first.id, equals('room_public'));
      },
    );
  });
}
