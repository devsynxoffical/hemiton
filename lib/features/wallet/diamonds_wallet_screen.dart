import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/wallet_details_provider.dart';
import 'wallet_details_screen.dart';

/// Attractive Diamonds Screen inspired by Image 2:
/// - Header: `< Diamonds` with `Records` action on right
/// - Top Card: Radiant Cyan-to-Emerald gradient with glowing diamond & balance
/// - Section: "Diamond equivalent to gold"
/// - 2-Column Grid of 6 packages:
///   1. 🪙 20 Gold Coins    / 💎 100 Diamonds
///   2. 🪙 200 Gold Coins   / 💎 1,000 Diamonds
///   3. 🪙 2,000 Gold Coins / 💎 10,000 Diamonds
///   4. 🪙 10,000 Gold Coins/ 💎 50,000 Diamonds
///   5. 🪙 20,000 Gold Coins/ 💎 100,000 Diamonds
///   6. 🪙 100,000 Gold Coins/ 💎 500,000 Diamonds
/// - Interactive exchange confirmation with live wallet updates and celebratory animation
class DiamondsWalletScreen extends StatefulWidget {
  const DiamondsWalletScreen({super.key});

  @override
  State<DiamondsWalletScreen> createState() => _DiamondsWalletScreenState();
}

class _DiamondsWalletScreenState extends State<DiamondsWalletScreen> {
  final List<_DiamondPackage> _packages = const [
    _DiamondPackage(coins: 20, diamonds: 100),
    _DiamondPackage(coins: 200, diamonds: 1000),
    _DiamondPackage(coins: 2000, diamonds: 10000),
    _DiamondPackage(coins: 10000, diamonds: 50000),
    _DiamondPackage(coins: 20000, diamonds: 100000),
    _DiamondPackage(coins: 100000, diamonds: 500000),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAuthoritativeWallet();
    });
  }

  Future<void> _refreshAuthoritativeWallet() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser.id.isNotEmpty) {
      await context.read<WalletProvider>().syncWithUser(auth.currentUser);
    } else {
      await context.read<WalletProvider>().fetchWallet();
    }
    if (mounted) {
      context.read<WalletDetailsProvider>().refreshData();
    }
  }

  void _showExchangeDialog(_DiamondPackage package) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = context.read<WalletProvider>();
    final hasEnough = wallet.diamonds >= package.diamonds;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131520) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 18.h),

              // Title
              Text(
                'Exchange Diamonds to Gold Coins',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkNavy,
                ),
              ),
              SizedBox(height: 16.h),

              // Conversion Preview Card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // You Spend
                    Column(
                      children: [
                        Text('Spend', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11.sp)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text('💎 ', style: TextStyle(fontSize: 16.sp)),
                            Text(
                              package.diamonds.toString(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF9C27B0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Icon(Icons.arrow_forward_rounded, color: const Color(0xFF00E676), size: 22.sp),

                    // You Receive
                    Column(
                      children: [
                        Text('Receive', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11.sp)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text('🪙 ', style: TextStyle(fontSize: 16.sp)),
                            Text(
                              package.coins.toString(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFB300),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // User Balance Notice
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Current Balance:',
                    style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  Text(
                    '💎 ${wallet.diamonds}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: hasEnough ? const Color(0xFF00E676) : Colors.redAccent,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 22.h),

              // Action Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  if (!hasEnough) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent),
                            SizedBox(width: 8.w),
                            const Expanded(
                              child: Text('Insufficient diamonds. Earn more in live rooms or gifts!'),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1E1E28),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final success = wallet.exchangeDiamondsToCoins(package.diamonds, package.coins);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Exchange successful! Added 🪙 ${package.coins} Coins.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF131520),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: hasEnough
                          ? [const Color(0xFF00B0FF), const Color(0xFF00E676)]
                          : [Colors.grey.shade600, Colors.grey.shade700],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: hasEnough
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00E676).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hasEnough ? 'Confirm Exchange' : 'Insufficient Diamonds',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C11) : const Color(0xFFF7F9FC),
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
          'Diamonds',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletDetailsScreen()),
              );
            },
            child: Text(
              'Records',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAuthoritativeWallet,
        color: const Color(0xFF00E676),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Radiant Balance Card (Cyan-to-Emerald) ──────────────
              _buildRadiantBalanceCard(wallet.diamonds),

              SizedBox(height: 24.h),

              // ── 2. Section Header: "Diamond equivalent to gold" ───────────
              Center(
                child: Text(
                  'Diamond equivalent to gold',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkNavy,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // ── 3. 2-Column Grid of 6 Packages ─────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _packages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.65,
                ),
                itemBuilder: (context, index) {
                  final pkg = _packages[index];
                  return _buildPackageCard(pkg, isDark);
                },
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadiantBalanceCard(int diamonds) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00B0FF),
            Color(0xFF00E676),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text('💎', style: TextStyle(fontSize: 24.sp)),
              ),
              SizedBox(width: 12.w),
              Text(
                diamonds.toString(),
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

  Widget _buildPackageCard(_DiamondPackage package, bool isDark) {
    return GestureDetector(
      onTap: () => _showExchangeDialog(package),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141622) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? const Color(0xFFFFD700).withValues(alpha: 0.22)
                : const Color(0xFFFFD700).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Half: Gold Coins
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🪙 ', style: TextStyle(fontSize: 14.sp)),
                    Text(
                      package.coins.toString(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
            ),

            // Bottom Half: Diamonds
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💎 ', style: TextStyle(fontSize: 13.sp)),
                    Text(
                      package.diamonds.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondPackage {
  final int coins;
  final int diamonds;

  const _DiamondPackage({
    required this.coins,
    required this.diamonds,
  });
}
