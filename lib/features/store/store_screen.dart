import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/store_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/backpack_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/wallet_provider.dart';
import '../profile/modules/outfit_screen.dart';
import '../wallet/gold_coins_screen.dart';

/// Luxury Store Screen inspired by Image 1:
/// - Dark luxury golden wave header with user coins balance chip
/// - Important store disclaimer banner
/// - Filter category tabs (All, Cars / Rides, Frame, Special card, Bubble, Background)
/// - 2-Column Luxury Cards with:
///   * SVIP Level pill badge (e.g. SVIP 4, SVIP 3)
///   * Quick Preview / Fullscreen action button
///   * Illuminated circular vignette showcasing 3D rides and gifts
///   * Title, Coin price (🪙 4,000,000), and validity duration (30d / 21d)
/// - Interactive Preview Sheet with Test Drive animation and instant buy
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _displayCategories = [
    'All',
    'Cars',
    'Frame',
    'Special card',
    'Bubble',
    'Background',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _displayCategories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStoreItems();
      final auth = context.read<AuthProvider>();
      context.read<BackpackProvider>().fetchBackpack(currentUser: auth.currentUser);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBuy(StoreItemModel item) async {
    final wallet = context.read<WalletProvider>();
    if (wallet.coins < item.priceCoins) {
      _showInsufficientCoinsDialog(item.priceCoins);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF1493)),
      ),
    );

    final success = await context.read<StoreProvider>().purchaseItem(item, wallet);
    if (mounted) Navigator.pop(context); // dismiss loading

    if (success && mounted) {
      final auth = context.read<AuthProvider>();
      final backpack = context.read<BackpackProvider>();
      backpack.addPurchasedAsset(item);
      await backpack.fetchBackpack(refresh: true, currentUser: auth.currentUser);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('Unlocked ${item.name}! Added to My Outfit.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF161823),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          action: SnackBarAction(
            label: 'MY OUTFIT',
            textColor: const Color(0xFFFF1493),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OutfitScreen()));
            },
          ),
        ),
      );
    } else if (mounted) {
      final error = context.read<StoreProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to purchase item'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInsufficientCoinsDialog(int price) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF181926),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: const Color(0xFFFF1493).withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            const Icon(Icons.monetization_on_rounded, color: Color(0xFFFF1493)),
            SizedBox(width: 8.w),
            const Text(
              'Insufficient Coins',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'You need 🪙 $price coins to purchase this luxury item. Please recharge your wallet.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1493),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () {
              Navigator.pop(c);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoldCoinsScreen()));
            },
            child: const Text('Recharge Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showItemPreviewModal(StoreItemModel item) {
    final backpack = context.read<BackpackProvider>();
    final isOwned = backpack.isItemOwned(item);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12131F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: const Color(0xFFFF1493).withValues(alpha: 0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF1493).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // SVIP Requirement Badge if any
              if (item.minVipLevelRequired > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.minVipLevelRequired >= 4
                          ? [const Color(0xFFFF007F), const Color(0xFF7928CA)]
                          : [const Color(0xFF0070F3), const Color(0xFF00DFD8)],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'SVIP ${item.minVipLevelRequired} Exclusive',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              SizedBox(height: 14.h),

              // Item Big 3D Preview Frame
              Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF1493).withValues(alpha: 0.25),
                      const Color(0xFF1C1D29),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFF1493).withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Center(
                    child: _buildItemImage(item, size: 110.w),
                  ),
                ),
              ),

              SizedBox(height: 14.h),

              // Item Name
              Text(
                item.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 6.h),

              // Duration & Category
              Text(
                '${item.durationDays} Days Duration • ${item.categoryId}',
                style: TextStyle(
                  color: const Color(0xFFFF4081),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 14.h),

              // Price Row
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                    ),
                    Row(
                      children: [
                        Text('🪙 ', style: TextStyle(fontSize: 14.sp)),
                        Text(
                          item.priceCoins.toString(),
                          style: TextStyle(
                            color: const Color(0xFFFF4081),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Buy Now Button
              GestureDetector(
                onTap: isOwned
                    ? () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OutfitScreen()));
                      }
                    : () {
                        Navigator.pop(ctx);
                        _handleBuy(item);
                      },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOwned
                          ? [const Color(0xFF00E5FF), const Color(0xFF0070F3)]
                          : [const Color(0xFFFF1493), const Color(0xFF7928CA)],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: (isOwned ? const Color(0xFF00E5FF) : const Color(0xFFFF1493))
                            .withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isOwned ? 'Equip in My Outfit' : 'Purchase with Coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

  Widget _buildItemImage(StoreItemModel item, {double? size}) {
    final double imgSize = size ?? 75.w;
    if (item.imageUrl.startsWith('http')) {
      return Image.network(
        item.imageUrl,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.stars_rounded,
          size: imgSize * 0.7,
          color: const Color(0xFFFF1493),
        ),
      );
    } else if (item.imageUrl.isNotEmpty) {
      return Image.asset(
        item.imageUrl,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.stars_rounded,
          size: imgSize * 0.7,
          color: const Color(0xFFFF1493),
        ),
      );
    }
    return Icon(
      Icons.stars_rounded,
      size: imgSize * 0.7,
      color: const Color(0xFFFF1493),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D12),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header with Gold Curves & Coin Chip ──────────────────────
            _buildStoreHeader(context, wallet),

            // ── Store Disclaimer Banner ──────────────────────────────────────
            _buildDisclaimerBanner(),

            // ── Category Tabs ────────────────────────────────────────────────
            _buildCategoryTabBar(),

            // ── Grid Content ─────────────────────────────────────────────────
            Expanded(
              child: storeProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: _displayCategories.map((category) {
                        final items = storeProvider.getItemsByCategory(category);
                        return _buildItemsGrid(items);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context, WalletProvider wallet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF22112C),
            Color(0xFF0F1018),
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Title
          Text(
            'Store',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),

          const Spacer(),

          // Coin Balance Chip with tap to recharge
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GoldCoinsScreen()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1428),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Text('🪙 ', style: TextStyle(fontSize: 12.sp)),
                  Text(
                    wallet.coins.toString(),
                    style: TextStyle(
                      color: const Color(0xFFFF4081),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF1493),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 10.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1224),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFF1493).withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: const Color(0xFFFF1493).withValues(alpha: 0.9),
            size: 15.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'The consumption of purchasing the store gifts is only included in the personal consumption and wealth level, and is not included in hosting income and hosting tasks.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.5.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabBar() {
    return Container(
      height: 38.h,
      margin: EdgeInsets.only(bottom: 6.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1493), Color(0xFF7928CA)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF1493).withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w500),
        tabs: _displayCategories.map((c) => Tab(text: c)).toList(),
      ),
    );
  }

  Widget _buildItemsGrid(List<StoreItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 48.sp,
              color: Colors.white24,
            ),
            SizedBox(height: 10.h),
            Text(
              'No items available in this category.',
              style: TextStyle(color: Colors.white38, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildStoreLuxuryCard(item);
      },
    );
  }

  Widget _buildStoreLuxuryCard(StoreItemModel item) {
    final int vipLevel = item.minVipLevelRequired > 0
        ? item.minVipLevelRequired
        : (item.priceCoins >= 3000000 ? 4 : (item.priceCoins >= 1000000 ? 3 : 0));

    return GestureDetector(
      onTap: () => _showItemPreviewModal(item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF13141F),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0xFFFF1493).withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: SVIP Badge & Preview Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (vipLevel > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: vipLevel >= 4
                            ? [const Color(0xFFFF007F), const Color(0xFF7928CA)]
                            : [const Color(0xFF0070F3), const Color(0xFF00DFD8)],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'SVIP $vipLevel',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                
                // Expand / Preview Icon button
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    Icons.crop_free_rounded,
                    color: const Color(0xFFFF1493).withValues(alpha: 0.8),
                    size: 14.sp,
                  ),
                ),
              ],
            ),

            // Center: 3D Item in illuminated circle
            Expanded(
              child: Center(
                child: Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF1493).withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: _buildItemImage(item, size: 75.w),
                  ),
                ),
              ),
            ),

            // Item Name
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6.h),

            // Bottom Row: Price & Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('🪙 ', style: TextStyle(fontSize: 10.sp)),
                    Text(
                      item.priceCoins.toString(),
                      style: TextStyle(
                        color: const Color(0xFFFF4081),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${item.durationDays}d',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
