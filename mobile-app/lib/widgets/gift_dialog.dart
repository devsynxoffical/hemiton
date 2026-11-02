import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/gift_model.dart';
import '../models/user_model.dart';
import '../providers/live_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/live_party_provider.dart';
import '../providers/live_gift_provider.dart';
import '../widgets/user_avatar.dart';
import '../features/recharge/recharge_screen.dart';

class GiftDialog extends StatefulWidget {
  final String streamerName;
  final UserModel? targetReceiver;
  final List<UserModel>? roomUsers;
  final String? roomId;
  final ValueChanged<GiftModel>? onGiftSent;
  final void Function(GiftModel gift, List<UserModel> recipients)? onGiftSentToUsers;

  const GiftDialog({
    super.key,
    this.streamerName = 'Streamer',
    this.targetReceiver,
    this.roomUsers,
    this.roomId,
    this.onGiftSent,
    this.onGiftSentToUsers,
  });

  @override
  State<GiftDialog> createState() => _GiftDialogState();
}

class _GiftDialogState extends State<GiftDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool recipientIsAllSelected = false;
  String selectedCategory = 'All';
  CatalogTypeFilter selectedCatalogFilter = CatalogTypeFilter.all;

  GiftModel? selectedGift;
  PropItemModel? selectedProp = GiftModel.defaultProps.first;
  int quantity = 1;

  Set<String> _selectedUserIds = {};

  final List<String> categories = [
    'All',
    'Lucky Gift',
    'Classic',
    'Event Gifts',
    'Privileges',
    'Special',
  ];

  static const ColorFilter _nonLuckyIconKeyFilter = ColorFilter.matrix(<double>[
    1.06, 0.0,  0.0,  0.0, -5.0,
    0.0,  1.06, 0.0,  0.0, -5.0,
    0.0,  0.0,  1.06, 0.0, -5.0,
    2.8,  2.8,  2.8,  0.0, -45.0,
  ]);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedCategory = categories[_tabController.index];
          selectedCatalogFilter = CatalogTypeFilter.all;
        });
      }
    });

    if (widget.targetReceiver != null) {
      _selectedUserIds.add(widget.targetReceiver!.id);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveGiftProv = context.read<LiveGiftProvider>();
      if (liveGiftProv.catalogGifts.isNotEmpty && selectedGift == null) {
        setState(() {
          selectedGift = liveGiftProv.catalogGifts.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _calculateTotalPrice(int giftPrice, int recipientCount) {
    return giftPrice * quantity * (recipientCount > 0 ? recipientCount : 1);
  }

  String _formatNumber(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  void _openRechargeScreen(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RechargeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final liveProv = context.watch<LiveProvider>();
    final partyProv = context.watch<LivePartyProvider>();
    final liveGiftProv = context.watch<LiveGiftProvider>();

    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;

    // Available room recipients (deduplicated by stable user ID and username)
    final Map<String, UserModel> recipientsMap = {};

    if (widget.roomUsers != null) {
      for (final u in widget.roomUsers!) {
        final key = u.id.trim().isNotEmpty ? u.id.trim() : u.username.trim().toLowerCase();
        if (key.isNotEmpty && !recipientsMap.containsKey(key)) {
          recipientsMap[key] = u;
        }
      }
    }

    for (final p in partyProv.participants) {
      final u = p.user;
      final key = u.id.trim().isNotEmpty ? u.id.trim() : u.username.trim().toLowerCase();
      if (key.isNotEmpty && !recipientsMap.containsKey(key)) {
        if (u.id == currentUser.id && currentUser.avatarUrl.isNotEmpty) {
          recipientsMap[key] = u.copyWith(avatarUrl: currentUser.avatarUrl, name: currentUser.name);
        } else {
          recipientsMap[key] = u;
        }
      }
    }

    final activeHost = liveProv.activeRoom?.host ?? partyProv.activeRoom?.host;
    if (activeHost != null && activeHost.id.isNotEmpty && !recipientsMap.containsKey(activeHost.id)) {
      recipientsMap[activeHost.id] = activeHost;
    }

    if (widget.targetReceiver != null) {
      final tr = widget.targetReceiver!;
      final trKey = tr.id.trim().isNotEmpty ? tr.id.trim() : tr.username.trim().toLowerCase();
      if (trKey.isNotEmpty && !recipientsMap.containsKey(trKey)) {
        recipientsMap[trKey] = tr;
      }
    }

    if (recipientsMap.isEmpty) {
      if (activeHost != null && activeHost.id.isNotEmpty) {
        recipientsMap[activeHost.id] = activeHost;
      } else {
        final isStreamerMe = widget.streamerName.trim().toLowerCase() == currentUser.name.trim().toLowerCase() ||
            widget.streamerName.trim().toLowerCase() == currentUser.displayName.trim().toLowerCase() ||
            widget.streamerName.trim().toLowerCase() == currentUser.username.trim().toLowerCase();
        if (!isStreamerMe && widget.streamerName.trim().isNotEmpty) {
          final resolvedHostId = liveProv.activeRoom?.creatorUserId ??
              partyProv.activeRoom?.creatorUserId ??
              'host_${widget.streamerName.toLowerCase().replaceAll(' ', '_')}';
          recipientsMap['streamer'] = UserModel(
            id: resolvedHostId,
            username: widget.streamerName,
            name: widget.streamerName,
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
          );
        } else {
          recipientsMap[currentUser.id] = currentUser;
        }
      }
    }

    final List<UserModel> availableRecipients = recipientsMap.values.toList();

    final otherRecipients = availableRecipients.where((u) =>
      u.id != currentUser.id &&
      (currentUser.username.isEmpty || u.username.toLowerCase() != currentUser.username.toLowerCase()) &&
      (currentUser.name.isEmpty || u.name.toLowerCase() != currentUser.name.toLowerCase())
    ).toList();

    if (_selectedUserIds.isEmpty && !recipientIsAllSelected) {
      if (widget.targetReceiver != null && widget.targetReceiver!.id.isNotEmpty) {
        _selectedUserIds.add(widget.targetReceiver!.id);
      } else if (otherRecipients.isNotEmpty) {
        _selectedUserIds.add(otherRecipients.first.id);
      } else if (availableRecipients.isNotEmpty) {
        _selectedUserIds.add(availableRecipients.first.id);
      }
    }

    final effectiveRecipients = recipientIsAllSelected
        ? (otherRecipients.isNotEmpty ? otherRecipients : availableRecipients)
        : availableRecipients.where((u) => _selectedUserIds.contains(u.id)).toList();

    final currentGiftPrice = selectedGift != null
        ? (selectedGift!.priceCoins > 0 ? selectedGift!.priceCoins : selectedGift!.diamondPrice)
        : 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.56,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: const BoxDecoration(
          color: Color(0xFF15161E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(color: Colors.black87, blurRadius: 24, spreadRadius: 4),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // ── 1. TOP EXP LEVEL BAR & "90% OFF >" PROMO CAPSULE ────────────
              Row(
                children: [
                  // Lime-green level badge (🌙 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9BE62B), Color(0xFF66B814)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 13,
                          height: 13,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4E9408),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.nightlight_round,
                            size: 9,
                            color: Color(0xFFE8FF99),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${currentUser.wealthLevel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // EXP Progress Bar
                  Expanded(
                    child: Container(
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2D3A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: ((currentUser.wealthXp % 100) / 100.0).clamp(0.08, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9BE62B), Color(0xFF00E676)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "+1 EXP >"
                  const Text(
                    '+1 EXP',
                    style: TextStyle(
                      color: Color(0xFFB5B8C6),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB5B8C6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),

                  // "🎁 90% OFF >" Golden Promo Capsule
                  GestureDetector(
                    onTap: () => _openRechargeScreen(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D1B0E), Color(0xFF8C4F14), Color(0xFFE58C1E)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFF5A623).withValues(alpha: 0.65),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎁', style: TextStyle(fontSize: 15)),
                          SizedBox(width: 5),
                          Text(
                            '90% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFFFE082),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── 2. RECIPIENT AVATARS ROW + CIRCULAR "All" BUTTON ────────────
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(availableRecipients.length, (idx) {
                          final user = availableRecipients[idx];
                          final isMe = user.id == currentUser.id ||
                              (currentUser.username.isNotEmpty &&
                                  user.username.toLowerCase() == currentUser.username.toLowerCase()) ||
                              (currentUser.name.isNotEmpty &&
                                  user.name.toLowerCase() == currentUser.name.toLowerCase());
                          final isSelected = recipientIsAllSelected ? !isMe : _selectedUserIds.contains(user.id);
                          final isHostSeat = idx == 0;
                          final resolvedAvatarUrl = (isMe && currentUser.avatarUrl.isNotEmpty)
                              ? currentUser.avatarUrl
                              : (user.avatarUrl.isNotEmpty ? user.avatarUrl : null);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                recipientIsAllSelected = false;
                                if (_selectedUserIds.length == 1 && _selectedUserIds.contains(user.id)) {
                                  return;
                                } else if (_selectedUserIds.contains(user.id)) {
                                  _selectedUserIds.remove(user.id);
                                } else {
                                  _selectedUserIds = {user.id};
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                recipientIsAllSelected = false;
                                if (_selectedUserIds.contains(user.id)) {
                                  _selectedUserIds.remove(user.id);
                                } else {
                                  _selectedUserIds.add(user.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 42,
                                height: 44,
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(1.8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFFF2E93)
                                              : const Color(0xFF525566),
                                          width: isSelected ? 2.0 : 1.4,
                                        ),
                                      ),
                                      child: UserAvatar(
                                        imageUrl: resolvedAvatarUrl,
                                        name: user.name,
                                        radius: 17,
                                      ),
                                    ),
                                    // Bottom Host Home Icon or Seat Number Badge
                                    Positioned(
                                      bottom: 0,
                                      child: isHostSeat
                                          ? Container(
                                              width: 15,
                                              height: 15,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFF2E93),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.home_rounded,
                                                size: 10,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 0.5),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFFFF2E93)
                                                    : const Color(0xFF232530),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${idx + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Circular "All" Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        recipientIsAllSelected = !recipientIsAllSelected;
                        if (recipientIsAllSelected) {
                          final targets = otherRecipients.isNotEmpty ? otherRecipients : availableRecipients;
                          _selectedUserIds = targets.map((u) => u.id).toSet();
                        } else if (widget.targetReceiver != null && widget.targetReceiver!.id != currentUser.id) {
                          _selectedUserIds = {widget.targetReceiver!.id};
                        } else if (otherRecipients.isNotEmpty) {
                          _selectedUserIds = {otherRecipients.first.id};
                        } else if (availableRecipients.isNotEmpty) {
                          _selectedUserIds = {availableRecipients.first.id};
                        } else {
                          _selectedUserIds = {};
                        }
                      });
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: recipientIsAllSelected
                            ? const LinearGradient(colors: [Color(0xFFFF2E93), Color(0xFFAB47BC)])
                            : null,
                        color: recipientIsAllSelected ? null : const Color(0xFF424554),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── 3. CATEGORY TABS ROW + BACKPACK ICON ────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        indicatorWeight: 2.5,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF8E92A4),
                        labelPadding: const EdgeInsets.only(right: 16),
                        labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        dividerColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        tabs: categories.map((c) => Tab(text: c)).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCatalogFilter = selectedCatalogFilter == CatalogTypeFilter.props
                            ? CatalogTypeFilter.all
                            : CatalogTypeFilter.props;
                      });
                    },
                    child: Icon(
                      Icons.backpack_outlined,
                      color: selectedCatalogFilter == CatalogTypeFilter.props
                          ? const Color(0xFFF48FB1)
                          : const Color(0xFF9EA2B4),
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ── 4. PURPLE GEM REWARD BANNER ("RTP:98.58%" + "GO") ───────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF311042),
                      Color(0xFF6A1B9A),
                      Color(0xFF8E24AA),
                      Color(0xFF4A148C),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFCE93D8).withValues(alpha: 0.45),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    // Gems + RTP:98.58% Column (prevents vertical/horizontal stack overflow)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💎✨', style: TextStyle(fontSize: 16, height: 1.0)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A0E2E).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFB74D), width: 0.6),
                          ),
                          child: const Text(
                            'RTP:98.58%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Center Banner Text
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                          ),
                          children: [
                            TextSpan(text: 'for every '),
                            TextSpan(
                              text: '100 coins',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(text: ' sent as a gift, the livestreamer receives '),
                            TextSpan(
                              text: '1 gem.',
                              style: TextStyle(
                                color: Color(0xFF80DEEA),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Golden "GO" Button
                    GestureDetector(
                      onTap: () => _openRechargeScreen(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF176), Color(0xFFFFB300)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'GO',
                          style: TextStyle(
                            color: Color(0xFF3E2723),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── 5. 4-COLUMN GIFT GRID / PROPS GRID ──────────────────────────
              Expanded(
                child: selectedCatalogFilter == CatalogTypeFilter.props
                    ? _buildPropsGrid(true, const Color(0xFFF48FB1))
                    : _buildGiftGrid(selectedCategory, liveGiftProv.catalogGifts),
              ),

              const SizedBox(height: 6),

              // ── 6. BOTTOM BAR: COIN BALANCE LEFT + QUANTITY PILLS & SEND RIGHT ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Gold Coin Balance + Pink Chevron (Flexible + scaleDown prevents overflow)
                  Flexible(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _openRechargeScreen(context),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFFE57F), Color(0xFFFFB300)],
                                ),
                              ),
                              child: const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFF8D4E00),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${wallet.coins}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 1),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFF48FB1),
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right: Unified Dark Pill Bar with Quantities + Lilac Send Button
                  Flexible(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0B0F),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4),
                              ...[1, 10, 50, 200, 500].map((q) {
                                final isQtySelected = quantity == q;
                                return GestureDetector(
                                  onTap: () => setState(() => quantity = q),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isQtySelected ? 9 : 6.5,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isQtySelected ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      '$q',
                                      style: TextStyle(
                                        color: isQtySelected
                                            ? const Color(0xFFD56CE0)
                                            : Colors.white,
                                        fontSize: 12,
                                        fontWeight: isQtySelected ? FontWeight.w800 : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 4),

                              // Lilac-Pink "Send" Pill Button
                              GestureDetector(
                                onTap: selectedGift == null || liveGiftProv.isSending
                                    ? null
                              : () async {
                                  final auth = context.read<AuthProvider>();
                                  final liveProv = context.read<LiveProvider>();
                                  final partyLiveProv = context.read<LivePartyProvider>();
                                  final messenger = ScaffoldMessenger.of(context);
                                  final nav = Navigator.of(context);

                                  List<UserModel> validRecipients = effectiveRecipients;
                                  if (validRecipients.isEmpty) {
                                    if (otherRecipients.isNotEmpty) {
                                      validRecipients = [otherRecipients.first];
                                    } else if (availableRecipients.isNotEmpty) {
                                      validRecipients = [availableRecipients.first];
                                    } else {
                                      validRecipients = [
                                        UserModel(
                                          id: 'host_${widget.streamerName.toLowerCase().replaceAll(' ', '_')}',
                                          username: widget.streamerName.isNotEmpty ? widget.streamerName : 'Host',
                                          name: widget.streamerName.isNotEmpty ? widget.streamerName : 'Host',
                                          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                                        )
                                      ];
                                    }
                                  }

                                  final effectiveTotalPrice = _calculateTotalPrice(currentGiftPrice, validRecipients.length);
                                  if (wallet.coins < effectiveTotalPrice) {
                                    showDialog(
                                      context: context,
                                      builder: (dlgCtx) => AlertDialog(
                                        backgroundColor: const Color(0xFF1C1D26),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Row(
                                          children: [
                                            Icon(Icons.monetization_on_rounded, color: AppColors.gold, size: 24),
                                            SizedBox(width: 8),
                                            Text('Insufficient Coins', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          ],
                                        ),
                                        content: Text(
                                          'You need $effectiveTotalPrice 🪙 to send this gift. You currently have ${wallet.coins} 🪙. Would you like to recharge now?',
                                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dlgCtx),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD56CE0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(dlgCtx);
                                              _openRechargeScreen(context);
                                            },
                                            child: const Text('Recharge Now 🪙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }

                                  int totalSuccess = 0;
                                  final roomId = (widget.roomId != null && widget.roomId!.isNotEmpty)
                                      ? widget.roomId!
                                      : (liveGiftProv.activeRoomId ?? liveProv.activeRoom?.id ?? partyLiveProv.activeRoom?.id ?? '');

                                  for (final targetUser in validRecipients) {
                                    final success = await liveGiftProv.sendGift(
                                      walletProvider: wallet,
                                      gift: selectedGift!,
                                      sender: auth.currentUser,
                                      receiver: targetUser,
                                      roomId: roomId,
                                      quantity: quantity,
                                      authProvider: auth,
                                    );

                                    if (success) {
                                      totalSuccess++;
                                      try {
                                        partyLiveProv.sendGiftActivityMessage(
                                          sender: auth.currentUser,
                                          receiver: targetUser,
                                          giftId: selectedGift!.id,
                                          giftName: selectedGift!.name,
                                          giftIcon: selectedGift!.icon,
                                          quantity: quantity,
                                          transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                                        );
                                      } catch (_) {}
                                    }
                                  }

                                  if (totalSuccess > 0) {
                                    widget.onGiftSent?.call(selectedGift!);
                                    widget.onGiftSentToUsers?.call(selectedGift!, validRecipients);

                                    final recipientNames = validRecipients.length == 1
                                        ? validRecipients.first.name
                                        : '${validRecipients.length} users';

                                    int luckyMultiplier = 1;
                                    int coinsWon = 0;
                                    final isLucky = selectedGift!.isLuckyGift || selectedGift!.id.startsWith('lucky_');
                                    if (isLucky) {
                                      final rand = math.Random().nextDouble();
                                      if (rand < 0.02) {
                                        luckyMultiplier = 500;
                                      } else if (rand < 0.08) {
                                        luckyMultiplier = 100;
                                      } else if (rand < 0.20) {
                                        luckyMultiplier = 10;
                                      } else if (rand < 0.45) {
                                        luckyMultiplier = 5;
                                      } else {
                                        luckyMultiplier = 2;
                                      }
                                      coinsWon = currentGiftPrice * quantity * luckyMultiplier;
                                      wallet.spendCoins(-coinsWon);
                                    }

                                    if (mounted) {
                                      nav.pop();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isLucky
                                                ? '🎁 Sent $quantity × ${selectedGift!.name} to $recipientNames!\n🎰 LUCKY WIN: Won $luckyMultiplier× ($coinsWon 🪙 returned to wallet)!'
                                                : '🎁 Sent $quantity × ${selectedGift!.name} to $recipientNames!',
                                          ),
                                          backgroundColor: isLucky ? Colors.amber.shade900 : Colors.green[800],
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  } else if (mounted) {
                                    final cleanError = liveGiftProv.lastError ?? 'Failed to send gift. Please check connection.';
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(cleanError),
                                        backgroundColor: Colors.red[800],
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE589F2), Color(0xFFC86DD7)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: liveGiftProv.isSending
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Send',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
);
  }

  Widget _buildGiftIconWidget(String icon) {
    final isLuckyAsset = icon.contains('/lucky/');
    if (icon.startsWith('assets/')) {
      final img = Image.asset(
        icon,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Text(icon.length < 4 ? icon : '🎁', style: const TextStyle(fontSize: 26)),
      );
      return isLuckyAsset
          ? img
          : ColorFiltered(
              colorFilter: _nonLuckyIconKeyFilter,
              child: img,
            );
    } else if (icon.startsWith('http')) {
      return Image.network(
        icon,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Text('🎁', style: TextStyle(fontSize: 26)),
      );
    }
    return Text(icon, style: const TextStyle(fontSize: 26));
  }

  Widget _buildGiftGrid(String category, List<GiftModel> catalog) {
    List<GiftModel> displayGifts;
    if (category == 'Lucky Gift') {
      displayGifts = catalog.where((g) => g.isLuckyGift).toList();
    } else if (category == 'Classic') {
      displayGifts = catalog.where((g) => g.category == 'Classic' || g.giftCategory == 'POPULAR').toList();
    } else if (category == 'Event Gifts') {
      displayGifts = catalog.where((g) => g.category == 'Event Gifts' || g.giftCategory == 'LUXURY').toList();
    } else if (category == 'Privileges') {
      displayGifts = catalog.where((g) => g.category == 'Privileges' || g.giftCategory == 'VIP').toList();
    } else if (category == 'Special') {
      displayGifts = catalog.where((g) => g.category == 'Special' || g.giftCategory == 'AUDIO').toList();
    } else {
      displayGifts = catalog;
    }

    if (displayGifts.isEmpty) {
      displayGifts = catalog.isNotEmpty ? catalog : GiftModel.defaultCatalog;
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      itemCount: displayGifts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.76,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final gift = displayGifts[index];
        final isSelected = selectedGift?.id == gift.id;
        final coinPrice = gift.priceCoins > 0 ? gift.priceCoins : gift.diamondPrice;

        // Reference-style badge determination ('NEW', 'Game', 'Activity', '?')
        String? badgeText;
        String badgeStyle = 'activity';
        if (gift.isLuckyGift && index % 3 == 2) {
          badgeText = '?';
          badgeStyle = 'question';
        } else if (index == 1 || gift.label == 'NEW') {
          badgeText = 'NEW';
          badgeStyle = 'new';
        } else if (index == 3 || gift.category == 'Privileges') {
          badgeText = 'Game';
          badgeStyle = 'game';
        } else if (gift.category == 'Event Gifts' || gift.label != null) {
          badgeText = 'Activity';
          badgeStyle = 'activity';
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGift = gift;
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E1F29) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF48FB1) : Colors.transparent,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: _buildGiftIconWidget(gift.icon),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gift.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFFC5C8D4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD54F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monetization_on_rounded,
                            color: Color(0xFF9E5800),
                            size: 8.5,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            _formatNumber(coinPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.1,
                              color: Color(0xFF9EA2B2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (badgeText != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: badgeStyle == 'question' ? 5 : 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: badgeStyle == 'game'
                          ? const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFF48FB1)])
                          : null,
                      color: badgeStyle == 'new'
                          ? const Color(0xFFAED581)
                          : (badgeStyle == 'question'
                              ? const Color(0xFFAB47BC)
                              : (badgeStyle == 'activity' ? const Color(0xFFE6B956) : null)),
                      borderRadius: BorderRadius.circular(badgeStyle == 'question' ? 4 : 8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: (badgeStyle == 'new' || badgeStyle == 'activity')
                            ? const Color(0xFF1F222A)
                            : Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropsGrid(bool isDark, Color primaryColor) {
    final props = GiftModel.defaultProps;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 4),
      itemCount: props.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final prop = props[index];
        final isSelected = selectedProp?.id == prop.id;

        return GestureDetector(
          onTap: () => setState(() => selectedProp = prop),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withValues(alpha: 0.15) : const Color(0xFF1E1F29),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSelected ? primaryColor : Colors.white12),
            ),
            child: Row(
              children: [
                Text(prop.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prop.name,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        prop.expiryText ?? 'Owned',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD56CE0),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Equipped ${prop.name}! ✨')),
                    );
                  },
                  child: Text(prop.actionLabel, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
