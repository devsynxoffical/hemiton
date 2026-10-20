import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/core/repositories/store_repository.dart';
import 'package:hemiton/models/agency_application_model.dart';
import 'package:hemiton/models/store_item_model.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/providers/agency_provider.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/providers/store_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Change 16: Store Catalog & Role Asset Security Tests', () {
    test('Public defaultStoreCatalog contains only 3 Store items and public mounts', () {
      final catalog = StoreRepository.defaultStoreCatalog;

      // Verify no role badges exist in default catalog
      final hasRoleBadge = catalog.any((item) =>
          item.id.startsWith('badge_role_') ||
          item.categoryId.toLowerCase() == 'badges' ||
          item.imageUrl.contains('assets/roles/'));
      expect(hasRoleBadge, isFalse, reason: 'Public store must not contain role badges');

      // Verify no SVIP badges exist in default catalog
      final hasSvipBadge = catalog.any((item) =>
          item.id.startsWith('badge_zp') ||
          item.imageUrl.contains('assets/svip/'));
      expect(hasSvipBadge, isFalse, reason: 'Public store must not contain SVIP badges');

      // Verify no Noble mounts exist in default catalog
      final hasNobleMount = catalog.any((item) =>
          item.id == 'car_astral' ||
          item.id == 'car_royal' ||
          item.imageUrl.contains('assets/nobles/'));
      expect(hasNobleMount, isFalse, reason: 'Public store must not contain Noble mounts');

      // Verify 3 Store items exist
      final has3StoreFrames = catalog.any((item) => item.id == 'frame_zp134');
      final has3StoreBubbles = catalog.any((item) => item.id == 'bubble_zp144');
      final has3StoreBgs = catalog.any((item) => item.id == 'bg_zp159');
      final has3StoreCards = catalog.any((item) => item.id == 'card_zp165');
      expect(has3StoreFrames, isTrue);
      expect(has3StoreBubbles, isTrue);
      expect(has3StoreBgs, isTrue);
      expect(has3StoreCards, isTrue);
    });

    test('StoreRepository.isRestrictedSpecialRoleAsset correctly detects all role, SVIP, and noble assets', () {
      // Role Badges
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_top_fan'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_agency'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_assistant'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_bd'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_official'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_role_game_master'), isTrue);

      // SVIP Assets
      expect(StoreRepository.isRestrictedSpecialRoleAsset('badge_zp054'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('assets/svip/svip1_badge.webp'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('car_cyber_jet'), isTrue);

      // Noble Assets
      expect(StoreRepository.isRestrictedSpecialRoleAsset('car_astral'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('car_royal'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('assets/nobles/emperor_entrance.webp'), isTrue);

      // Regular 3 Store items must NOT be restricted
      expect(StoreRepository.isRestrictedSpecialRoleAsset('frame_zp134'), isFalse);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('bubble_zp144'), isFalse);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('bg_zp159'), isFalse);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('card_zp165'), isFalse);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('car_supercar'), isFalse);
    });

    test('StoreProvider categories strictly exclude Badges', () {
      final storeProvider = StoreProvider();
      final categories = storeProvider.categories;

      expect(categories.contains('Badges'), isFalse, reason: 'Badges tab must be removed from public store');
      expect(categories, equals(['All', 'Cars', 'Frame', 'Special card', 'Bubble', 'Background']));
    });

    test('StoreRepository.purchaseAsset throws exception on restricted role asset purchase attempt', () async {
      final repo = StoreRepository.instance;
      expect(
        () => repo.purchaseAsset(assetId: 'badge_role_top_fan'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repo.purchaseAsset(assetId: 'badge_zp054'),
        throwsA(isA<Exception>()),
      );
      expect(
        () => repo.purchaseAsset(assetId: 'car_astral'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Change 17: Agency Application & 5 External Host IDs Tests', () {
    test('AgencyApplicationModel serializes and deserializes 5 external host IDs correctly', () {
      final app = AgencyApplicationModel(
        id: 'test_app_1',
        applicantUserId: 'user_1001',
        applicantHemitonId: '1001',
        applicantName: 'Sarah Jenkins',
        applicantAvatar: 'https://example.com/avatar.png',
        agencyName: 'Star Talent Agency',
        description: 'Elite gaming and music streaming agency',
        phoneNumber: '+1 555 123 4567',
        externalHostIds: ['ext_host_1', 'ext_host_2', 'ext_host_3', 'ext_host_4', 'ext_host_5'],
        status: 'Pending',
        submittedAt: DateTime(2026, 10, 14, 12, 0),
      );

      final json = app.toJson();
      expect(json['externalHostIds'], hasLength(5));
      expect(json['status'], equals('Pending'));

      final fromJson = AgencyApplicationModel.fromJson(json);
      expect(fromJson.externalHostIds, equals(['ext_host_1', 'ext_host_2', 'ext_host_3', 'ext_host_4', 'ext_host_5']));
      expect(fromJson.isPending, isTrue);
      expect(fromJson.isApproved, isFalse);
    });

    test('submitAgencyApplication rejects if host IDs count is not exactly 5', () async {
      final agencyProvider = AgencyProvider();
      final result = await agencyProvider.submitAgencyApplication(
        applicantUserId: 'user_1',
        applicantHemitonId: '1',
        applicantName: 'Test Applicant',
        applicantAvatar: '',
        agencyName: 'Test Agency',
        description: 'Testing agency',
        phoneNumber: '+1 234 5678',
        externalHostIds: ['host_1', 'host_2', 'host_3'], // Only 3 IDs
      );

      expect(result, isFalse, reason: 'Must require exactly 5 host IDs');
      expect(agencyProvider.myApplication, isNull);
    });

    test('submitAgencyApplication rejects if duplicate host IDs exist among the 5', () async {
      final agencyProvider = AgencyProvider();
      final result = await agencyProvider.submitAgencyApplication(
        applicantUserId: 'user_1',
        applicantHemitonId: '1',
        applicantName: 'Test Applicant',
        applicantAvatar: '',
        agencyName: 'Test Agency',
        description: 'Testing agency',
        phoneNumber: '+1 234 5678',
        externalHostIds: ['host_1', 'host_2', 'host_3', 'host_4', 'host_1'], // host_1 duplicated!
      );

      expect(result, isFalse, reason: 'Duplicate host IDs must be rejected');
      expect(agencyProvider.myApplication, isNull);
    });

    test('submitAgencyApplication sets status to Pending without granting owner privileges', () async {
      final agencyProvider = AgencyProvider();
      final result = await agencyProvider.submitAgencyApplication(
        applicantUserId: 'user_1',
        applicantHemitonId: '10001',
        applicantName: 'Test Applicant',
        applicantAvatar: '',
        agencyName: 'Phoenix Agency',
        description: 'Official Agency Application',
        phoneNumber: '+1 555 987 6543',
        externalHostIds: ['h1', 'h2', 'h3', 'h4', 'h5'],
      );

      expect(result, isTrue);
      expect(agencyProvider.myApplication, isNotNull);
      expect(agencyProvider.myApplication!.status, equals('Pending'));
      expect(agencyProvider.myApplication!.isPending, isTrue);
      // Ensure user agency is NOT activated immediately upon submission
      expect(agencyProvider.userAgency, isNull, reason: 'Pending application must not activate agency');
    });

    test('Admin approval activates agency and designates applicant as owner', () async {
      final agencyProvider = AgencyProvider();
      await agencyProvider.submitAgencyApplication(
        applicantUserId: 'user_2',
        applicantHemitonId: '10002',
        applicantName: 'Applicant 2',
        applicantAvatar: '',
        agencyName: 'Apex Agency',
        description: 'Apex description',
        phoneNumber: '+44 7911 123456',
        externalHostIds: ['ext1', 'ext2', 'ext3', 'ext4', 'ext5'],
      );

      final appId = agencyProvider.myApplication!.id;
      final approved = await agencyProvider.approveAgencyApplication(
        applicationId: appId,
        adminUserId: 'admin_99',
      );

      expect(approved, isTrue);
      expect(agencyProvider.myApplication!.status, equals('Approved'));
      expect(agencyProvider.userAgency, isNotNull, reason: 'Approved application must activate agency');
      expect(agencyProvider.userAgency!.name, equals('Apex Agency'));
      expect(agencyProvider.userAgency!.ownerUserId, equals('user_2'));
    });

    test('Admin rejection leaves agency inactive with rejection reason recorded', () async {
      final agencyProvider = AgencyProvider();
      await agencyProvider.submitAgencyApplication(
        applicantUserId: 'user_3',
        applicantHemitonId: '10003',
        applicantName: 'Applicant 3',
        applicantAvatar: '',
        agencyName: 'Rejected Agency',
        description: 'Rejected description',
        phoneNumber: '+92 300 1234567',
        externalHostIds: ['ext_a', 'ext_b', 'ext_c', 'ext_d', 'ext_e'],
      );

      final appId = agencyProvider.myApplication!.id;
      final rejected = await agencyProvider.rejectAgencyApplication(
        applicationId: appId,
        adminUserId: 'admin_99',
        rejectionReason: 'Invalid documentation provided for external hosts.',
      );

      expect(rejected, isTrue);
      expect(agencyProvider.myApplication!.status, equals('Rejected'));
      expect(agencyProvider.myApplication!.rejectionReason, equals('Invalid documentation provided for external hosts.'));
      expect(agencyProvider.userAgency, isNull, reason: 'Rejected application must not activate agency');
    });
  });

  group('Change 18: Wealth XP Progression & Level Calculation Tests', () {
    test('Wealth XP level and progress calculation formula tests', () {
      // 0 XP -> Lv. 0, Current: 0
      final user0 = UserModel.empty.copyWith(wealthXp: 0);
      expect(user0.computedWealthLevel, equals(0));
      expect(user0.wealthLevelXp, equals(0));

      // 5,000 XP -> Lv. 0, Current: 5000 (Target: 10,000)
      final user5k = UserModel.empty.copyWith(wealthXp: 5000);
      expect(user5k.computedWealthLevel, equals(0));
      expect(user5k.wealthLevelXp, equals(5000));

      // 9,999 XP -> Lv. 0, Current: 9999
      final user9999 = UserModel.empty.copyWith(wealthXp: 9999);
      expect(user9999.computedWealthLevel, equals(0));
      expect(user9999.wealthLevelXp, equals(9999));

      // 10,000 XP -> Lv. 1, Current: 0
      final user10k = UserModel.empty.copyWith(wealthXp: 10000);
      expect(user10k.computedWealthLevel, equals(1));
      expect(user10k.wealthLevelXp, equals(0));

      // 25,500 XP -> Lv. 2, Current: 5500
      final user25k = UserModel.empty.copyWith(wealthXp: 25500);
      expect(user25k.computedWealthLevel, equals(2));
      expect(user25k.wealthLevelXp, equals(5500));
    });

    test('addWealthXp increments XP and updates level in AuthProvider', () {
      final authProvider = AuthProvider();
      expect(authProvider.currentUser.wealthXp, equals(0));
      expect(authProvider.currentUser.computedWealthLevel, equals(0));

      // Sending gift worth 3,500 coins
      authProvider.addWealthXp(3500);
      expect(authProvider.currentUser.wealthXp, equals(3500));
      expect(authProvider.currentUser.computedWealthLevel, equals(0));
      expect(authProvider.currentUser.wealthLevelXp, equals(3500));

      // Sending gift worth 7,000 coins (total = 10,500) -> Crosses Lv. 1 threshold!
      authProvider.addWealthXp(7000);
      expect(authProvider.currentUser.wealthXp, equals(10500));
      expect(authProvider.currentUser.computedWealthLevel, equals(1));
      expect(authProvider.currentUser.wealthLevelXp, equals(500));
    });

    test('UserModel.toJson preserves wealthXp, charmXp, gameXp across app restart', () {
      final user = UserModel.empty.copyWith(
        id: 'u_test_99',
        name: 'Gamer Pro',
        wealthXp: 45000,
        wealthLevel: 4,
        charmXp: 12000,
        charmLevel: 1,
        gameXp: 8000,
      );

      final json = user.toJson();
      expect(json['wealthXp'], equals(45000));
      expect(json['charmXp'], equals(12000));
      expect(json['gameXp'], equals(8000));

      final restored = UserModel.fromJson(json);
      expect(restored.wealthXp, equals(45000));
      expect(restored.computedWealthLevel, equals(4));
      expect(restored.wealthLevelXp, equals(5000));
      expect(restored.charmXp, equals(12000));
    });
  });
}
