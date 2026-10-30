import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/store_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/backpack_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/wallet_provider.dart';
import '../profile/modules/outfit_screen.dart';
import '../wallet/gold_coins_screen.dart';

/// Luxury Store Screen inspired by Image 1:
/// - Split layout: Left vertical category sidebar + Right 2-column item grid
/// - Top Header: Back button, [Store | Custom] centered tabs with active indicator, Shopping bag icon
/// - 12 Categories: Entry, Frame, Special ID, Chat Bubble, Theme, Entry Strip,
///   Profile Card, Room Frame, CP Theme, CP Profile, CP Token, CP Entry
/// - Clean transparent/isolated item graphics with top-right play preview button
/// - Coin price chip: e.g. 🪙 2,000 /7Day
/// - Vibrant purple capsule [Buy] button with instant functional purchase & equipping
/// - Interactive full preview modal (Test Drive, validity duration, instant buy/equip)
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  int _selectedHeaderTab = 0; // 0 = Store, 1 = Custom
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Entry',
    'Frame',
    'Special ID',
    'Chat Bubble',
    'Theme',
    'Entry Strip',
    'Profile Card',
    'Room Frame',
    'CP Theme',
    'CP Profile',
    'CP Token',
    'CP Entry',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStoreItems();
      final auth = context.read<AuthProvider>();
      context.read<BackpackProvider>().fetchBackpack(currentUser: auth.currentUser);
    });
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OutfitScreen()),
              );
            },
          ),
        ),
      );
      setState(() {});
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase could not be completed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showInsufficientCoinsDialog(int price) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF161824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 24),
            SizedBox(width: 8.w),
            const Text('Insufficient Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'You need ${_formatPrice(price)} Gold Coins for this exclusive item. Would you like to recharge now?',
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
    final isOwned = backpack.userAssets.any((a) => a.assetId == item.id && !a.isExpired);
    final isEquipped = backpack.userAssets.any((a) => a.assetId == item.id && a.isEquipped && !a.isExpired);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF140E24),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.45), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.25),
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

              // Item Big 3D Preview Frame with background vignette
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE040FB).withValues(alpha: 0.3),
                      const Color(0xFF1C1335),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE040FB).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: _buildItemImage(item, size: 100.w),
                ),
              ),

              SizedBox(height: 14.h),

              // Item Name
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),

              // Category & Duration Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF281C48),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE040FB).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${item.categoryId} • ${item.durationDays} Days Duration',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFE1BEE7),
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Coin Price Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1538),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8.w),
                    Text(
                      '${_formatPrice(item.priceCoins)} Gold Coins',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFD700),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),

              // Action Button (Buy Now or Equip)
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  if (isOwned) {
                    final asset = backpack.userAssets.firstWhere((a) => a.assetId == item.id);
                    if (asset.isEquipped) {
                      backpack.unequipAsset(asset.id);
                    } else {
                      backpack.equipAsset(asset.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEquipped ? 'Unequipped ${item.name}' : 'Equipped ${item.name}! ✨'),
                        backgroundColor: const Color(0xFF9C27B0),
                      ),
                    );
                    setState(() {});
                  } else {
                    _handleBuy(item);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOwned
                          ? [const Color(0xFF00E5FF), const Color(0xFF0070F3)]
                          : [const Color(0xFF8A2BE2), const Color(0xFFFF1493)],
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
                    isOwned ? (isEquipped ? 'In Use (Equipped)' : 'Equip Now') : 'Buy (${_formatPrice(item.priceCoins)} Coins)',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
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
    final double imgSize = size ?? 72.w;
    if (item.imageUrl.startsWith('http')) {
      return Image.network(
        item.imageUrl,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.auto_awesome_rounded,
          size: imgSize * 0.7,
          color: const Color(0xFFE040FB),
        ),
      );
    } else if (item.imageUrl.isNotEmpty) {
      return Image.asset(
        item.imageUrl,
        width: imgSize,
        height: imgSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.auto_awesome_rounded,
          size: imgSize * 0.7,
          color: const Color(0xFFE040FB),
        ),
      );
    }
    return Icon(
      Icons.auto_awesome_rounded,
      size: imgSize * 0.7,
      color: const Color(0xFFE040FB),
    );
  }

  String _formatPrice(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(coins % 1000 == 0 ? 0 : 1)}k';
    }
    return coins.toString();
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final backpack = context.watch<BackpackProvider>();

    final selectedCategory = _categories[_selectedCategoryIndex];
    final items = storeProvider.getItemsByCategory(selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFF100A20),
      body: Stack(
        children: [
          // Background Gradient matching Image 1 dark luxury theme
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E1035), // Luxury purple top
                    Color(0xFF120C24),
                    Color(0xFF090714), // Deep dark base
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Column(
              children: [
                // ── 1. Top Header Bar (Back, Store/Custom tabs, Shopping Bag) ──────
                _buildTopHeader(),

                // ── 2. Split Body (Left Category Sidebar + Right 2-Col Grid) ───────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Category Sidebar Rail
                      _buildCategorySidebar(),

                      // Right Content Area (2-Column Grid)
                      Expanded(
                        child: storeProvider.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: Color(0xFFE040FB)),
                              )
                            : _buildItemsGrid(items, backpack),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Top Header Bar
  // ===========================================================================
  Widget _buildTopHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button (<)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),

          // Center Tabs: [ Store | Custom ]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderTab(title: 'Store', index: 0),
              SizedBox(width: 24.w),
              _buildHeaderTab(title: 'Custom', index: 1),
            ],
          ),

          // Shopping Bag Icon (Outfit / Backpack)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OutfitScreen()),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(6.w),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab({required String title, required int index}) {
    final isSelected = _selectedHeaderTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHeaderTab = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 17.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 3.h),
          // Pink active indicator underline
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 22.w : 0,
            height: 3.h,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF007F), Color(0xFFFF1493)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Left Category Sidebar (12 Categories from Image 1)
  // ===========================================================================
  Widget _buildCategorySidebar() {
    return Container(
      width: 98.w,
      decoration: BoxDecoration(
        color: const Color(0xFF17102A).withValues(alpha: 0.65),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1.0,
          ),
        ),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final title = _categories[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFE040FB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF261D3B).withValues(alpha: 0.4),
                borderRadius: isSelected
                    ? BorderRadius.horizontal(right: Radius.circular(12.r))
                    : null,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : const Color(0xFFCE93D8),
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Right 2-Column Grid (Image 1 Exact Layout)
  // ===========================================================================
  Widget _buildItemsGrid(List<StoreItemModel> items, BackpackProvider backpack) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48.w, color: Colors.white30),
            SizedBox(height: 12.h),
            Text(
              'No items in this category yet',
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 12.w, 80.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = backpack.userAssets.any((a) => a.assetId == item.id && !a.isExpired);

        return _buildStoreItemCard(item, isOwned);
      },
    );
  }

  Widget _buildStoreItemCard(StoreItemModel item, bool isOwned) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1433), // Dark luxury theme matching application
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
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
      child: Stack(
        children: [
          // Main Card Content
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Center Visual (Isolated with clean transparent blend)
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _showItemPreviewModal(item),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: _buildItemImage(item, size: 85.w),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),

                // Item Name (e.g. Romantic, Summer Sprite, Gorgeous-Cool)
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),

                // Price Tag: 🪙 2,000 /7Day
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 4.w),
                    Text(
                      '${_formatPrice(item.priceCoins)} /${item.durationDays}Day',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Buy Capsule Gradient Button
                GestureDetector(
                  onTap: () {
                    if (isOwned) {
                      _showItemPreviewModal(item);
                    } else {
                      _handleBuy(item);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 30.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOwned
                            ? [const Color(0xFF00B0FF), const Color(0xFF0081CB)]
                            : [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isOwned ? 'Use' : 'Buy',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top-Right Translucent Play / Preview Button
          Positioned(
            top: 6.h,
            right: 6.w,
            child: GestureDetector(
              onTap: () => _showItemPreviewModal(item),
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white70,
                    size: 15.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
