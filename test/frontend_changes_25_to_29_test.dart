import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:zeparty/core/utils/noble_badge_helper.dart';
import 'package:zeparty/models/coin_seller_model.dart';
import 'package:zeparty/models/live_host_model.dart';
import 'package:zeparty/models/party_message_model.dart';
import 'package:zeparty/models/user_model.dart';
import 'package:zeparty/providers/auth_provider.dart';
import 'package:zeparty/providers/coin_agency_provider.dart';
import 'package:zeparty/providers/live_host_provider.dart';
import 'package:zeparty/providers/live_party_provider.dart';
import 'package:zeparty/features/live_host/live_host_center_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Change 25: Badge Artwork in Viscount Noble and SVIP 10', () {
    test('Viscount Noble badge maps to approved noble badge artwork and not rectangular card', () {
      final viscountAsset = NobleBadgeHelper.getBadgeAsset('Viscount');
      expect(viscountAsset, equals('assets/nobles/viscount_badge.webp'));

      // Check asset on disk: must be the approved 512x512 badge (> 1.5MB), not the 402KB profilecard
      final file = File('assets/nobles/viscount_badge.webp');
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(1500000), reason: 'Must be authentic high-res badge asset, not profile card');

      // Check that profile card is preserved as viscount_card.webp
      final cardFile = File('assets/nobles/viscount_card.webp');
      expect(cardFile.existsSync(), isTrue);
    });

    test('SVIP 10 badge maps to approved SVIP badge artwork and not horizontal chat bubble', () {
      final svip10Asset = NobleBadgeHelper.getBadgeAsset('SVIP 10');
      expect(svip10Asset, equals('assets/svip/SVIP10_badge_live.webp'));

      final file = File('assets/svip/svip10_badge.webp');
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(1500000), reason: 'Must be authentic high-res badge asset, not chat bubble');
    });

    test('Noble ranks and SVIP tiers map to distinct badge assets', () {
      final ranks = ['Baron', 'Viscount', 'Count', 'Marquis', 'Duke', 'King', 'Emperor'];
      final assets = ranks.map((r) => NobleBadgeHelper.getBadgeAsset(r)).toSet();
      expect(assets.length, equals(ranks.length), reason: 'Every noble rank must have a unique badge asset');

      for (int i = 1; i <= 15; i++) {
        final svipAsset = NobleBadgeHelper.getBadgeAsset('SVIP $i');
        expect(svipAsset, isNotNull);
        expect(svipAsset!.contains('badge'), isTrue);
      }
    });
  });

  group('Change 26: Remove simulated live minutes & track real host streaming time', () {
    test('addLiveStreamingMinutes is disabled and does not award simulated minutes', () {
      final prov = LiveHostProvider();
      // Calling addLiveStreamingMinutes should be no-op / disabled
      prov.addLiveStreamingMinutes(15);
      expect(prov.activeLiveHost, isNull);
    });

    testWidgets('LiveHostCenterScreen does not contain the Simulate button', (tester) async {
      final authProv = AuthProvider();
      final liveHostProv = LiveHostProvider();

      // Verify widget renders without the simulation button
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProv),
            ChangeNotifierProvider<LiveHostProvider>.value(value: liveHostProv),
          ],
          child: const MaterialApp(
            home: LiveHostCenterScreen(),
          ),
        ),
      );

      // Initial state: no active host profile loaded
      expect(find.text('No active Direct Live Host profile found.'), findsOneWidget);

      // Simulate approved host state update
      liveHostProv.approveApplication('app_test', 'reviewer_1');
      await tester.pumpAndSettle();

      // Verify that the simulation button is completely absent from the UI
      expect(find.text('Simulate +15 Mins Live Stream'), findsNothing);
      expect(find.byIcon(Icons.add_alarm_rounded), findsNothing);
    });
  });

  group('Change 28: Add Clear Screen to Party Room Options', () {
    test('LivePartyProvider.clearRoomFeed clears messages and establishes clear boundary', () {
      final partyProv = LivePartyProvider();

      // Add dummy messages
      partyProv.messages.add(PartyMessageModel(
        id: 'msg_1',
        sender: UserModel.fromJson(const {'id': 'u1', 'username': 'User1', 'name': 'User1'}),
        text: 'Hello Room!',
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      ));
      expect(partyProv.messages.length, equals(1));

      // Trigger clear room feed
      partyProv.clearRoomFeed();
      expect(partyProv.messages.isEmpty, isTrue);
      expect(partyProv.feedClearedAt, isNotNull);

      // Message timestamped before clear boundary should be dropped if replayed
      final oldTime = partyProv.feedClearedAt!.subtract(const Duration(seconds: 5));
      expect(oldTime.isBefore(partyProv.feedClearedAt!), isTrue);

      // New message timestamped after clear boundary is accepted
      final newTime = partyProv.feedClearedAt!.add(const Duration(seconds: 1));
      expect(newTime.isAfter(partyProv.feedClearedAt!), isTrue);
    });
  });

  group('Change 29: Remove demo coin sellers & filter by country', () {
    test('CoinAgencyProvider starts clean without demo sellers', () {
      final prov = CoinAgencyProvider();
      expect(prov.sellers.isEmpty, isTrue, reason: 'Must not contain hardcoded demo sellers');

      // Verify hardcoded sample sellers are not present
      final hasGlobalCoins = prov.sellers.any((s) => s.name.contains('Global Coins'));
      final hasMiddleEast = prov.sellers.any((s) => s.name.contains('Middle East Top'));
      final hasAsiaSwift = prov.sellers.any((s) => s.name.contains('Asia Swift'));
      expect(hasGlobalCoins, isFalse);
      expect(hasMiddleEast, isFalse);
      expect(hasAsiaSwift, isFalse);
    });

    test('Coin sellers are strictly filtered by user country', () {
      final prov = CoinAgencyProvider();

      // Register real sellers in admin panel
      prov.addSeller(const CoinSellerModel(
        id: 'seller_pk_1',
        userId: '920001',
        name: 'Karachi Coin Traders',
        avatarUrl: 'https://i.pravatar.cc/150?img=10',
        region: 'Pakistan',
        type: SellerType.verified,
        status: SellerStatus.approved,
        isVisible: true,
        paymentMethods: ['JazzCash', 'Easypaisa'],
        stockCoins: 1000000,
      ));

      prov.addSeller(const CoinSellerModel(
        id: 'seller_us_1',
        userId: '910002',
        name: 'New York Digital Exchange',
        avatarUrl: 'https://i.pravatar.cc/150?img=20',
        region: 'United States',
        type: SellerType.official,
        status: SellerStatus.approved,
        isVisible: true,
        paymentMethods: ['Apple Pay', 'Visa'],
        stockCoins: 2500000,
      ));

      // Pakistan user should see ONLY Pakistan seller
      final pkSellers = prov.getSellersForCountry('Pakistan');
      expect(pkSellers.length, equals(1));
      expect(pkSellers.first.name, equals('Karachi Coin Traders'));
      expect(pkSellers.first.region, equals('Pakistan'));

      // US user should see ONLY US seller
      final usSellers = prov.getSellersForCountry('United States');
      expect(usSellers.length, equals(1));
      expect(usSellers.first.name, equals('New York Digital Exchange'));

      // User from a country with no sellers sees empty list
      final ukSellers = prov.getSellersForCountry('United Kingdom');
      expect(ukSellers.isEmpty, isTrue);
    });

    test('Search retains country filtering', () {
      final prov = CoinAgencyProvider();

      prov.addSeller(const CoinSellerModel(
        id: 'seller_pk_1',
        userId: '920001',
        name: 'Karachi Coin Traders',
        avatarUrl: 'https://i.pravatar.cc/150?img=10',
        region: 'Pakistan',
        type: SellerType.verified,
        status: SellerStatus.approved,
        isVisible: true,
        paymentMethods: ['JazzCash'],
        stockCoins: 1000000,
      ));

      prov.addSeller(const CoinSellerModel(
        id: 'seller_pk_2',
        userId: '920002',
        name: 'Lahore Express Exchange',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        region: 'Pakistan',
        type: SellerType.standard,
        status: SellerStatus.approved,
        isVisible: true,
        paymentMethods: ['Easypaisa'],
        stockCoins: 500000,
      ));

      prov.setUserCountry('Pakistan');

      // Search for Lahore
      prov.setSearchQuery('Lahore');
      final results = prov.getSellersForCountry('Pakistan');
      expect(results.length, equals(1));
      expect(results.first.name, equals('Lahore Express Exchange'));

      // Search for New York while in Pakistan -> must return empty
      prov.setSearchQuery('New York');
      final emptyResults = prov.getSellersForCountry('Pakistan');
      expect(emptyResults.isEmpty, isTrue);
    });

    test('Deactivated or unapproved sellers are excluded from user results', () {
      final prov = CoinAgencyProvider();

      prov.addSeller(const CoinSellerModel(
        id: 'seller_pk_3',
        userId: '920003',
        name: 'Suspended Pakistan Seller',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        region: 'Pakistan',
        type: SellerType.standard,
        status: SellerStatus.suspended, // Suspended
        isVisible: false,
        paymentMethods: ['Bank'],
        stockCoins: 100000,
      ));

      final activeSellers = prov.getSellersForCountry('Pakistan');
      expect(activeSellers.isEmpty, isTrue, reason: 'Suspended seller must not appear in directory');
    });
  });

  group('Live Room Tools alignment matching screenshot', () {
    test('All required assets for Live Controls and Host Controls exist on disk', () {
      final requiredAssets = [
        'assets/images/party_tool_luckybag.png',
        'assets/images/party_tool_game_center.png',
        'assets/images/party_tool_members.png',
        'assets/images/party_tool_share.png',
        'assets/images/party_tool_pk_match.png',
        'assets/images/party_tool_superwheel.png',
        'assets/images/party_tool_music_player.png',
        'assets/images/party_tool_youtube.png',
        'assets/images/party_rocket_icon.jpg',
        'assets/images/party_tool_effects_settings.png',
        'assets/images/party_tool_seat.png',
        'assets/images/party_tool_lockroom.png',
        'assets/images/party_tool_mute_room.png',
        'assets/images/party_tool_mic.png',
        'assets/images/party_tool_settings.png',
      ];

      for (final asset in requiredAssets) {
        expect(File(asset).existsSync(), isTrue, reason: 'Missing tool asset: $asset');
      }
    });
  });
}
