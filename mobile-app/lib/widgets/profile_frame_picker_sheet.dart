import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/repositories/store_repository.dart';
import '../core/utils/noble_badge_helper.dart';
import '../features/profile/modules/outfit_screen.dart';
import '../models/store_item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/backpack_provider.dart';

class ProfileFramePickerSheet extends StatefulWidget {
  const ProfileFramePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileFramePickerSheet(),
    );
  }

  @override
  State<ProfileFramePickerSheet> createState() => _ProfileFramePickerSheetState();
}

class _ProfileFramePickerSheetState extends State<ProfileFramePickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BackpackProvider>().fetchBackpack();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final backpackProv = Provider.of<BackpackProvider>(context);
    final currentUser = authProv.currentUser;

    // Avatar frames in store catalog
    final catalogFrames = StoreRepository.defaultStoreCatalog
        .where((i) =>
            i.categoryId.toUpperCase().contains('FRAME') ||
            i.assetType.toUpperCase().contains('FRAME') ||
            i.id.startsWith('frame_'))
        .toList();

    // User's owned assets
    final userAssets = backpackProv.userAssets;

    final String equippedFrame = currentUser.avatarFrame.isNotEmpty && currentUser.avatarFrame != 'none'
        ? currentUser.avatarFrame
        : (backpackProv.equippedFrameUrl ?? '');

    return Container(
      height: 0.72.sh,
      decoration: BoxDecoration(
        color: const Color(0xFF161129),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          SizedBox(height: 10.h),
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header: Laurel Wreath + Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      color: const Color(0xFFFFB300),
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Profile Avatar Frames',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OutfitScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A2BE2).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFF8A2BE2), width: 0.8),
                    ),
                    child: Text(
                      'Full Wardrobe 👑',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00E5FF),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Current User Preview with Equipped Frame
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8A2BE2).withValues(alpha: 0.15),
                  const Color(0xFFFF1493).withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: NetworkImage(
                        currentUser.avatarUrl.isNotEmpty
                            ? currentUser.avatarUrl
                            : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
                      ),
                    ),
                    if (equippedFrame.isNotEmpty && equippedFrame != 'none')
                      Positioned(
                        top: -6.r,
                        left: -6.r,
                        right: -6.r,
                        bottom: -6.r,
                        child: _buildFrameImage(equippedFrame),
                      ),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name.isNotEmpty ? currentUser.name : 'Your Profile',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        equippedFrame.isNotEmpty && equippedFrame != 'none'
                            ? 'Currently wearing custom avatar frame'
                            : 'No avatar frame equipped',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (equippedFrame.isNotEmpty && equippedFrame != 'none')
                  TextButton(
                    onPressed: () {
                      final equippedUa = userAssets.where((a) => a.isEquipped).firstOrNull;
                      if (equippedUa != null) {
                        backpackProv.unequipAsset(
                          equippedUa.id,
                          onAvatarFrameChanged: (f) => authProv.updateAvatarFrame(f),
                        );
                      } else {
                        authProv.updateAvatarFrame('none');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avatar frame unequipped'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Unequip',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Grid of Frames
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.76,
              ),
              itemCount: catalogFrames.length,
              itemBuilder: (context, index) {
                final frameItem = catalogFrames[index];

                // Check if user owns this frame in userAssets
                final cleanId = frameItem.id.toLowerCase().trim();
                final cleanName = frameItem.name.toLowerCase().trim();
                final ownedAsset = userAssets.where((ua) {
                  if (ua.isExpired) return false;
                  final uaId = ua.assetId.toLowerCase().trim();
                  final uaNestedId = (ua.asset?.id ?? '').toLowerCase().trim();
                  final uaName = (ua.asset?.name ?? '').toLowerCase().trim();
                  return uaId == cleanId || uaNestedId == cleanId || (uaName.isNotEmpty && uaName == cleanName);
                }).firstOrNull;

                final bool isOwned = ownedAsset != null;
                final bool isEquipped = isOwned &&
                    (ownedAsset.isEquipped ||
                        equippedFrame == frameItem.imageUrl ||
                        equippedFrame.contains(frameItem.id));

                return _buildFrameGridCard(
                  frameItem: frameItem,
                  isOwned: isOwned,
                  isEquipped: isEquipped,
                  onEquip: () async {
                    if (ownedAsset != null) {
                      if (isEquipped) {
                        await backpackProv.unequipAsset(
                          ownedAsset.id,
                          onAvatarFrameChanged: (f) => authProv.updateAvatarFrame(f),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Avatar frame unequipped'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        await backpackProv.equipAsset(
                          ownedAsset.id,
                          onAvatarFrameChanged: (f) => authProv.updateAvatarFrame(f),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Equipped ${frameItem.name}! ✨'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF00E676),
                          ),
                        );
                      }
                    } else {
                      // Locked / unpurchased item: cannot equip!
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${frameItem.name} is locked 🔒 Purchase it from the Store first!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFFF1744),
                          action: SnackBarAction(
                            label: 'Store',
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const OutfitScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameGridCard({
    required StoreItemModel frameItem,
    required bool isOwned,
    required bool isEquipped,
    required VoidCallback onEquip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEquipped
            ? const Color(0xFF8A2BE2).withValues(alpha: 0.28)
            : const Color(0xFF1E1A34),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isEquipped
              ? const Color(0xFF00E676)
              : (isOwned
                  ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                  : Colors.white10),
          width: isEquipped ? 1.8 : 1.0,
        ),
      ),
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Frame thumbnail preview with Avatar placeholder
          SizedBox(
            width: 58.w,
            height: 58.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, color: Colors.white38, size: 20.sp),
                ),
                Positioned.fill(
                  child: _buildFrameImage(frameItem.imageUrl),
                ),
                if (!isOwned)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.lock_rounded, color: Colors.amber, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Frame name
          Text(
            frameItem.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Equip / Locked action button
          GestureDetector(
            onTap: onEquip,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                gradient: isEquipped
                    ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)])
                    : (isOwned
                        ? const LinearGradient(colors: [Color(0xFF8A2BE2), Color(0xFFFF1493)])
                        : null),
                color: (!isOwned && !isEquipped) ? Colors.white.withValues(alpha: 0.08) : null,
              ),
              child: Center(
                child: Text(
                  isEquipped ? 'Equipped' : (isOwned ? 'Equip' : '🔒 Locked'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else if (pathOrUrl.startsWith('http')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    } else {
      final local = NobleBadgeHelper.getFrameAsset(pathOrUrl);
      if (local != null) {
        return Image.asset(local, fit: BoxFit.contain);
      }
      return const SizedBox.shrink();
    }
  }
}
