import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zeparty/models/user_model.dart';
import 'package:zeparty/models/store_item_model.dart';
import 'package:zeparty/core/repositories/store_repository.dart';
import 'package:zeparty/providers/backpack_provider.dart';
import 'package:zeparty/providers/recharge_agency_provider.dart';
import 'package:zeparty/providers/auth_provider.dart';
import 'package:zeparty/providers/wallet_provider.dart';
import 'package:zeparty/providers/usd_balance_provider.dart';
import 'package:zeparty/features/recharge_agency/recharge_agency_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Change 23: Store vs Backpack Frame Asset Consistency', () {
    test('Catalog items use stable catalog ID and approved 3 Store assets', () {
      final catalog = StoreRepository.defaultStoreCatalog;
      final zp134 = catalog.firstWhere((i) => i.id == 'frame_zp134');

      expect(zp134.name, equals('Golden Glory Frame'));
      expect(zp134.imageUrl, equals('assets/store/ZP-134_avatar-frames_frame.webp'));
      expect(zp134.categoryId, equals('Frame'));
      expect(zp134.assetType, equals('AVATAR_FRAME'));
    });

    test('Special role items (Official, SVIP, Badges) are restricted from public store', () {
      expect(StoreRepository.isRestrictedSpecialRoleAsset('ZeParty Official Profile Frame'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('Game Master Badge'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('Recharge Merchant'), isTrue);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('SVIP Premier Badge'), isTrue);

      // Allowed store frames are not restricted
      expect(StoreRepository.isRestrictedSpecialRoleAsset('frame_zp134'), isFalse);
      expect(StoreRepository.isRestrictedSpecialRoleAsset('Golden Glory Frame'), isFalse);
    });

    test('Purchasing a store frame preserves exact ID, name, and artwork in Backpack and Equip', () async {
      final backpack = BackpackProvider();
      const storeFrame = StoreItemModel(
        id: 'frame_zp134',
        name: 'Golden Glory Frame',
        categoryId: 'Frame',
        assetType: 'AVATAR_FRAME',
        imageUrl: 'assets/store/ZP-134_avatar-frames_frame.webp',
        priceCoins: 250000,
        durationDays: 30,
      );

      backpack.addPurchasedAsset(storeFrame);

      // Verify ownership in store and backpack
      expect(backpack.isItemOwned(storeFrame), isTrue);
      expect(backpack.userAssets.isNotEmpty, isTrue);

      final ownedAsset = backpack.userAssets.first;
      expect(ownedAsset.assetId, equals('frame_zp134'));
      expect(ownedAsset.asset?.name, equals('Golden Glory Frame'));
      expect(ownedAsset.asset?.imageUrl, equals('assets/store/ZP-134_avatar-frames_frame.webp'));

      // Test equip action applies the exact store asset, not an unrelated fallback
      String? equippedAvatarFrame;
      await backpack.equipAsset(
        ownedAsset.id,
        onAvatarFrameChanged: (frame) => equippedAvatarFrame = frame,
      );

      expect(equippedAvatarFrame, equals('assets/store/ZP-134_avatar-frames_frame.webp'));
      expect(backpack.equippedFrameUrl, equals('assets/store/ZP-134_avatar-frames_frame.webp'));
    });
  });

  group('Change 24: Coins Seller and Owner/Host Coexistence & Recharge Agency', () {
    test('UserModel supports coexistence of Owner/Host and Coins Seller roles', () {
      final javisJson = {
        'id': '9202535',
        'name': 'Javis',
        'username': 'javis_9202535',
        'userType': 'HOST',
        'role': 'host',
        'isHost': true,
        'badge': 'COINS SELLER',
        'roles': ['HOST', 'SELLER'],
        'sellerBalance': 50000,
      };

      final user = UserModel.fromJson(javisJson);

      // Both roles must coexist
      expect(user.isHost, isTrue);
      expect(user.isSeller, isTrue);
      expect(user.id, equals('9202535'));
    });

    test('RechargeAgencyProvider synchronizes current seller data and isolates on switch', () {
      final provider = RechargeAgencyProvider();

      provider.syncForSeller(
        sellerId: '9202535',
        sellerName: 'Javis Recharge Agency',
        countryCode: '🇵🇰 Pakistan',
        initialCoins: 50000,
      );

      expect(provider.sellerId, equals('9202535'));
      expect(provider.sellerName, equals('Javis Recharge Agency'));
      expect(provider.countryCode, equals('🇵🇰 Pakistan'));
      expect(provider.availableCoins, equals(50000));

      // Test reset on account switch or logout
      provider.reset();
      expect(provider.sellerId, isEmpty);
      expect(provider.availableCoins, equals(0));
      expect(provider.transactions, isEmpty);
    });

    testWidgets('RechargeAgencyScreen grants access to authorized seller and displays real seller data', (tester) async {
      final auth = AuthProvider();
      auth.mockSetCurrentUser(const UserModel(
        id: '9202535',
        name: 'Javis',
        username: 'javis',
        avatarUrl: '',
        isHost: true,
        isSeller: true,
        sellerBalance: 50000,
      ));

      final rechargeProv = RechargeAgencyProvider();
      final walletProv = WalletProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: rechargeProv),
            ChangeNotifierProvider.value(value: walletProv),
            ChangeNotifierProvider.value(value: UsdBalanceProvider.instance),
          ],
          child: const MaterialApp(
            home: RechargeAgencyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Javis Recharge Agency'), findsOneWidget);
      expect(find.text('Seller ID: 9202535'), findsOneWidget);
      expect(find.text('Recharge Coins'), findsOneWidget);
      expect(find.text('USD Balance'), findsOneWidget);
    });

    testWidgets('RechargeAgencyScreen denies access to account without active seller role', (tester) async {
      final auth = AuthProvider();
      auth.mockSetCurrentUser(const UserModel(
        id: '10001',
        name: 'Regular User',
        username: 'regular_user',
        avatarUrl: '',
        isHost: false,
        isSeller: false,
      ));

      final rechargeProv = RechargeAgencyProvider();
      final walletProv = WalletProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: rechargeProv),
            ChangeNotifierProvider.value(value: walletProv),
          ],
          child: const MaterialApp(
            home: RechargeAgencyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Back to Profile'), findsOneWidget);
      expect(find.text('Recharge Coins'), findsNothing);
    });

    test('ProfileScreen imports and accesses RechargeAgencyProvider cleanly without error', () {
      final rechargeProv = RechargeAgencyProvider();
      expect(rechargeProv.sellerName, equals('Coin Reseller Agency'));
    });
  });
}
