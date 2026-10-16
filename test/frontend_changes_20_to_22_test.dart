import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemiton/models/user_model.dart';
import 'package:hemiton/models/cumulative_recharge_model.dart';
import 'package:hemiton/providers/wallet_provider.dart';
import 'package:hemiton/providers/cumulative_recharge_provider.dart';
import 'package:hemiton/features/wallet/wallet_screen.dart';
import 'package:hemiton/features/wallet/diamonds_wallet_screen.dart';
import 'package:hemiton/features/wallet/coin_exchange_screen.dart';
import 'package:hemiton/features/wallet/diamond_exchange_screen.dart';
import 'package:hemiton/features/host/host_dashboard_screen.dart';
import 'package:hemiton/features/recharge/cumulative_recharge_screen.dart';
import 'package:hemiton/providers/auth_provider.dart';
import 'package:hemiton/core/theme/theme_provider.dart';
import 'package:hemiton/providers/wallet_details_provider.dart';
import 'package:hemiton/core/utils/formatters.dart';

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  static final _kTransparentImage = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44,
    0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F,
    0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00,
    0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(_kTransparentImage).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('Change 20: Diamond Balance Consistency & Authoritative Wallet', () {
    test('WalletProvider synchronizes with UserModel balance and isolates cache on account switch', () async {
      final wallet = WalletProvider();

      // Simulated user Alexa (ID: 3122996) with 5100 diamonds
      const alexa = UserModel(
        id: '3122996',
        username: 'ayankhanttt7hhg_886',
        name: 'Alexa',
        avatarUrl: '',
        diamonds: 5100,
        coins: 0,
      );

      await wallet.syncWithUser(alexa);

      expect(wallet.diamonds, 5100);
      expect(wallet.coins, 0);
      // Compact formatting on profile equals exact underlying integer
      expect(AppFormatters.formatNumber(wallet.diamonds), '5.1K');

      // Clear wallet on account switch / logout
      wallet.clearWallet();
      expect(wallet.wallet, isNull);
      expect(wallet.diamonds, 0);

      // New account with 0 diamonds
      const bob = UserModel(
        id: '4001234',
        username: 'bob_streamer',
        name: 'Bob',
        avatarUrl: '',
        diamonds: 0,
        coins: 100,
      );

      await wallet.syncWithUser(bob);
      expect(wallet.diamonds, 0);
      expect(wallet.coins, 100);
      expect(AppFormatters.formatNumber(wallet.diamonds), '0');
    });

    testWidgets('DiamondsWalletScreen displays authoritative balance accurately and genuine zero', (tester) async {
      final wallet = WalletProvider();
      final auth = AuthProvider();

      const alexa = UserModel(
        id: '3122996',
        username: 'alexa',
        name: 'Alexa',
        avatarUrl: '',
        diamonds: 5100,
      );

      await wallet.syncWithUser(alexa);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WalletProvider>.value(value: wallet),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<WalletDetailsProvider>(create: (_) => WalletDetailsProvider()),
          ],
          child: _wrapWithScreenUtil(const DiamondsWalletScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 5));

      // Check header and balance
      expect(find.text('My Balance'), findsOneWidget);
      expect(find.text('5.1K'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
    });
  });

  group('Change 21: Removal of Coins and Diamonds Exchange', () {
    test('WalletProvider.exchangeDiamondsToCoins strictly rejects conversion and preserves balances', () {
      final wallet = WalletProvider();

      final result = wallet.exchangeDiamondsToCoins(1000, 255);
      expect(result, isFalse);
    });

    testWidgets('WalletScreen has NO currency exchange icon in AppBar', (tester) async {
      final wallet = WalletProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WalletProvider>.value(value: wallet),
          ],
          child: _wrapWithScreenUtil(const WalletScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Verify exchange icon is NOT present
      expect(find.byIcon(Icons.currency_exchange_rounded), findsNothing);
      expect(find.byTooltip('Exchange Coins'), findsNothing);

      // Verify other standard actions remain intact
      expect(find.byIcon(Icons.history_rounded), findsWidgets);
      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('HostDashboardScreen has NO currency exchange icon and NO exchange button', (tester) async {
      final auth = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ],
          child: _wrapWithScreenUtil(const HostDashboardScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 5));

      // Verify exchange action is NOT in header
      expect(find.byIcon(Icons.currency_exchange_rounded), findsNothing);

      // Verify "Exchange Gold Coins" button is removed
      expect(find.text('Exchange Gold Coins'), findsNothing);

      // Verify Transfer to Authorized Seller is present
      expect(find.text('Transfer to Authorized Seller'), findsOneWidget);
    });

    testWidgets('CoinExchangeScreen and DiamondExchangeScreen show prohibited notice and no converter inputs', (tester) async {
      await tester.pumpWidget(
        _wrapWithScreenUtil(const CoinExchangeScreen()),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Exchange Feature Removed'), findsOneWidget);
      expect(find.text('Instant Currency Converter'), findsNothing);
      expect(find.text('Confirm Exchange Now'), findsNothing);

      await tester.pumpWidget(
        _wrapWithScreenUtil(const DiamondExchangeScreen()),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Diamond Exchange Prohibited'), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });
  });

  group('Change 22: Recharge Rewards Zero Start State', () {
    test('CumulativeRechargeProvider initializes at \$0.00 USD and all milestones locked', () {
      final recharge = CumulativeRechargeProvider();

      expect(recharge.cumulativeRechargeUsd, 0.00);

      final event = recharge.currentEvent;
      expect(event.currentRechargeUsd, 0.00);
      expect(event.overallProgress, 0.00);

      // All milestones must be locked
      for (final milestone in event.milestones) {
        expect(milestone.status, MilestoneClaimStatus.locked,
            reason: 'Milestone \$${milestone.thresholdUsd} should be locked at 0 recharge');
      }
    });

    test('addRechargeAmount increases cumulative progress and unlocks milestones dynamically', () async {
      final recharge = CumulativeRechargeProvider();
      final wallet = WalletProvider();

      expect(recharge.cumulativeRechargeUsd, 0.00);

      // Add real $10 recharge
      recharge.addRechargeAmount(10.00);
      expect(recharge.cumulativeRechargeUsd, 10.00);

      // Milestone 1 ($10) should now be eligible
      final m1 = recharge.currentEvent.milestones.firstWhere((m) => m.level == 1);
      expect(m1.status, MilestoneClaimStatus.eligible);

      // Milestone 2 ($50) remains locked
      final m2 = recharge.currentEvent.milestones.firstWhere((m) => m.level == 2);
      expect(m2.status, MilestoneClaimStatus.locked);

      // Claim milestone 1
      final claimResult = await recharge.claimMilestone(1, wallet);
      expect(claimResult, isTrue);

      final m1Claimed = recharge.currentEvent.milestones.firstWhere((m) => m.level == 1);
      expect(m1Claimed.status, MilestoneClaimStatus.claimed);

      // Second claim attempt should fail
      final duplicate = await recharge.claimMilestone(1, wallet);
      expect(duplicate, isFalse);
    });

    testWidgets('CumulativeRechargeScreen displays \$0.00 USD and positive amounts left with no default claims', (tester) async {
      final recharge = CumulativeRechargeProvider();
      final wallet = WalletProvider();
      final auth = AuthProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CumulativeRechargeProvider>.value(value: recharge),
            ChangeNotifierProvider<WalletProvider>.value(value: wallet),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ],
          child: _wrapWithScreenUtil(const CumulativeRechargeScreen()),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 5));

      // Check zero start values
      expect(find.text('\$0.00 USD'), findsOneWidget);
      expect(find.text('Recharge \$10.00 more to unlock next milestone reward!'), findsOneWidget);

      // Verify no CLAIMED labels exist at zero start
      expect(find.text('CLAIMED ✓'), findsNothing);

      // Verify remaining amounts calculated from zero
      expect(find.text('\$10 left'), findsOneWidget);
      expect(find.text('\$50 left'), findsOneWidget);
      expect(find.text('\$100 left'), findsOneWidget);
      expect(find.text('\$300 left'), findsOneWidget);
      expect(find.text('\$1000 left'), findsOneWidget);
      expect(find.text('\$3000 left'), findsOneWidget);
    });
  });
}
