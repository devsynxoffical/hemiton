import 'package:flutter_test/flutter_test.dart';
import 'package:hemiton/models/hangout_invitation_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 2: Bring My Friend - Invitation Model Tests', () {
    test('HangoutInvitationModel JSON serialization and deserialization', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 5));

      final json = {
        'id': 'inv_1001',
        'roomId': 'room_party_42',
        'roomTitle': 'Midnight Acoustic Jam',
        'inviterUserId': 'user_danial',
        'inviterName': 'Danial',
        'inviterAvatar': 'https://example.com/avatar_danial.png',
        'invitedUserId': 'user_sarah',
        'invitedUserName': 'Sarah K.',
        'invitedUserAvatar': 'https://example.com/avatar_sarah.png',
        'status': 'pending',
        'createdAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

      final invitation = HangoutInvitationModel.fromJson(json);

      expect(invitation.id, equals('inv_1001'));
      expect(invitation.roomId, equals('room_party_42'));
      expect(invitation.roomTitle, equals('Midnight Acoustic Jam'));
      expect(invitation.inviterName, equals('Danial'));
      expect(invitation.invitedUserName, equals('Sarah K.'));
      expect(invitation.status, equals(HangoutInvitationStatus.pending));
      expect(invitation.isPending, isTrue);
      expect(invitation.isAccepted, isFalse);
      expect(invitation.isDeclined, isFalse);
      expect(invitation.isExpired, isFalse);

      final serialized = invitation.toJson();
      expect(serialized['id'], equals('inv_1001'));
      expect(serialized['status'], equals('pending'));
      expect(serialized['inviterUserId'], equals('user_danial'));
      expect(serialized['invitedUserId'], equals('user_sarah'));
    });

    test('HangoutInvitationModel copyWith updates status and timestamps', () {
      final now = DateTime.now();
      final original = HangoutInvitationModel(
        id: 'inv_1002',
        roomId: 'room_party_99',
        roomTitle: 'Lofi Lounge',
        inviterUserId: 'user_a',
        inviterName: 'Alice',
        inviterAvatar: '',
        invitedUserId: 'user_b',
        invitedUserName: 'Bob',
        invitedUserAvatar: '',
        status: HangoutInvitationStatus.pending,
        createdAt: now,
        expiresAt: now.add(const Duration(minutes: 10)),
      );

      final updated = original.copyWith(
        status: HangoutInvitationStatus.accepted,
      );

      expect(updated.id, equals('inv_1002'));
      expect(updated.status, equals(HangoutInvitationStatus.accepted));
      expect(updated.isAccepted, isTrue);
      expect(updated.isPending, isFalse);
      expect(original.isPending, isTrue); // immutability preserved
    });

    test('HangoutInvitationModel correctly detects expired status by date', () {
      final pastDate = DateTime.now().subtract(const Duration(minutes: 10));
      final expiredInv = HangoutInvitationModel(
        id: 'inv_past',
        roomId: 'room_1',
        roomTitle: 'Past Hangout',
        inviterUserId: 'inviter',
        inviterName: 'Inviter',
        inviterAvatar: '',
        invitedUserId: 'invitee',
        invitedUserName: 'Invitee',
        invitedUserAvatar: '',
        status: HangoutInvitationStatus.pending,
        createdAt: pastDate.subtract(const Duration(minutes: 5)),
        expiresAt: pastDate,
      );

      expect(expiredInv.isExpired, isTrue);
    });

    test('HangoutInvitationStatus enum parses from string with fallback', () {
      expect(
        HangoutInvitationModel.parseStatus('accepted'),
        equals(HangoutInvitationStatus.accepted),
      );
      expect(
        HangoutInvitationModel.parseStatus('declined'),
        equals(HangoutInvitationStatus.declined),
      );
      expect(
        HangoutInvitationModel.parseStatus('expired'),
        equals(HangoutInvitationStatus.expired),
      );
      expect(
        HangoutInvitationModel.parseStatus('cancelled'),
        equals(HangoutInvitationStatus.cancelled),
      );
      expect(
        HangoutInvitationModel.parseStatus('unknown_status'),
        equals(HangoutInvitationStatus.pending),
      );
    });
  });
}
