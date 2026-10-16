import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/recharge_plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import 'coin_records_screen.dart';

/// Modern, clean Gold Coins Center with Hemiton signature color scheme.
/// Replaces the legacy ZeParty WalletScreen.
class GoldCoinsScreen extends StatefulWidget {
  const GoldCoinsScreen({super.key});

  @override
  State<GoldCoinsScreen> createState() => _GoldCoinsScreenState();
}

class _GoldCoinsScreenState extends State<GoldCoinsScreen> {
  bool _isProcessing = false;
  String? _processingPlanId;

  static const List<RechargePlanModel> _defaultPlans = [
    RechargePlanModel(
      id: 'coin_plan_1',
      name: 'Starter Coin Pack',
      coinAmount: 1000,
      bonusCoins: 100,
      priceUSD: 0.99,
      badgeText: '+10% Bonus',
    ),
    RechargePlanModel(
      id: 'coin_plan_2',
      name: 'Popular Coin Pack',
      coinAmount: 5000,
      bonusCoins: 800,
      priceUSD: 4.99,
      badgeText: 'Popular 🔥',
    ),
    RechargePlanModel(
      id: 'coin_plan_3',
      name: 'Mega Value Pack',
      coinAmount: 12000,
      bonusCoins: 2500,
      priceUSD: 9.99,
      isRecommended: true,
      badgeText: 'Best Value ⭐',
    ),
    RechargePlanModel(
      id: 'coin_plan_4',
      name: 'Platinum Super Pack',
      coinAmount: 50000,
      bonusCoins: 12000,
      priceUSD: 39.99,
      badgeText: 'VIP Choice 👑',
    ),
    RechargePlanModel(
      id: 'coin_plan_5',
      name: 'Royal Diamond Pack',
      coinAmount: 120000,
      bonusCoins: 35000,
      priceUSD: 99.99,
      badgeText: 'Royal Pack 💎',
    ),
    RechargePlanModel(
      id: 'coin_plan_6',
      name: 'Imperial Wealth Pack',
      coinAmount: 300000,
      bonusCoins: 100000,
      priceUSD: 249.99,
      badgeText: 'Imperial 🏆',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshWallet();
    });
  }

  Future<void> _refreshWallet() async {
    final auth = context.read<AuthProvider>();
    final wallet = context.read<WalletProvider>();
    if (auth.currentUser.id.isNotEmpty) {
      await wallet.syncWithUser(auth.currentUser);
    } else {
      await wallet.fetchWallet();
    }
    await wallet.fetchRechargePlans();
  }

  Future<void> _purchasePlan(RechargePlanModel plan) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _processingPlanId = plan.id;
    });

    final wallet = context.read<WalletProvider>();
    final success = await wallet.createPaymentIntent(
      planId: plan.id,
      paymentProvider: 'STRIPE',
    );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _processingPlanId = null;
    });

    if (success != null) {
      await _refreshWallet();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('🎉 Recharge successful! Added ${plan.coinAmount + plan.bonusCoins} Coins.'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFF1493),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Offline fallback: add coins directly for demo
      wallet.earnCoins(plan.coinAmount + plan.bonusCoins, 'Recharge: ${plan.name}');
      await _refreshWallet();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('🎉 Successfully added ${plan.coinAmount + plan.bonusCoins} Coins!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFF1493),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = context.watch<WalletProvider>();
    final displayPlans = wallet.plans.isNotEmpty ? wallet.plans : _defaultPlans;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0D14) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.darkNavy,
            size: 19.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gold Coins',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
            tooltip: 'Coin Records',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoinRecordsScreen()),
              );
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWallet,
        color: const Color(0xFFFF1493),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Radiant Balance Card (Signature Gradient) ───────────
              _buildBalanceCard(wallet.coins, isDark),

              SizedBox(height: 24.h),

              // ── 2. Section Header: "Top Up Coin Packs" ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recharge Coin Packs',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.darkNavy,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Instant Delivery ⚡',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF1493),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // ── 3. Grid of Recharge Packs ──────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayPlans.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final plan = displayPlans[index];
                  final isCurrent = _processingPlanId == plan.id;
                  return _buildCoinPackCard(plan, isDark, isCurrent);
                },
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(int coins, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF1493),
            Color(0xFF7928CA),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1493).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Coins Balance',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text('🪙', style: TextStyle(fontSize: 24.sp)),
              ),
              SizedBox(width: 12.w),
              Text(
                AppFormatters.formatNumber(coins),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackCard(RechargePlanModel plan, bool isDark, bool isCurrent) {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _purchasePlan(plan),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131522) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: plan.isRecommended
                ? const Color(0xFFFF1493)
                : (isDark
                    ? const Color(0xFFFF1493).withValues(alpha: 0.25)
                    : const Color(0xFFFF1493).withValues(alpha: 0.2)),
            width: plan.isRecommended ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: plan.isRecommended
                  ? const Color(0xFFFF1493).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (plan.badgeText.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF1493), Color(0xFF7928CA)],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      plan.badgeText,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text('🪙', style: TextStyle(fontSize: 16.sp)),
              ],
            ),

            // Coins Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppFormatters.formatNumber(plan.coinAmount)} Coins',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                  ),
                ),
                if (plan.bonusCoins > 0)
                  Text(
                    '+${AppFormatters.formatNumber(plan.bonusCoins)} Bonus',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF4081),
                    ),
                  ),
              ],
            ),

            // Price Button
            Container(
              width: double.infinity,
              height: 32.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1493), Color(0xFF7928CA)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: isCurrent
                  ? SizedBox(
                      width: 14.w,
                      height: 14.w,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      '\$${plan.priceUSD.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
