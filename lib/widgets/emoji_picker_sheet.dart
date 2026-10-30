import 'package:flutter/material.dart';
import '../core/services/api_client.dart';

class EmojiPickerSheet extends StatefulWidget {
  final Function(String emoji) onEmojiSelected;
  final Function(String reactionAsset, String symbol)? onReactionSelected;
  final String? roomId;

  const EmojiPickerSheet({
    super.key,
    required this.onEmojiSelected,
    this.onReactionSelected,
    this.roomId,
  });

  static void show(
    BuildContext context, {
    required Function(String emoji) onEmojiSelected,
    Function(String reactionAsset, String symbol)? onReactionSelected,
    String? roomId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EmojiPickerSheet(
        onEmojiSelected: onEmojiSelected,
        onReactionSelected: onReactionSelected,
        roomId: roomId,
      ),
    );
  }

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dynamicCategories = [];

  static const List<Map<String, dynamic>> _customAssetCategories = [
    {
      'title': 'Live ✨',
      'icon': Icons.auto_awesome_rounded,
      'isCustomAssets': true,
      'items': [
        {
          'name': 'Applaud',
          'icon': 'assets/emojis/panel_icons/emoji_applaud.png',
          'reaction': 'assets/emojis/reactions/emoji_applaud_reaction.webp',
          'symbol': '👏',
        },
        {
          'name': 'Laugh',
          'icon': 'assets/emojis/panel_icons/emoji_laugh.png',
          'reaction': 'assets/emojis/reactions/emoji_laugh_reaction.webp',
          'symbol': '😂',
        },
        {
          'name': 'Show Love',
          'icon': 'assets/emojis/panel_icons/emoji_showlove.png',
          'reaction': 'assets/emojis/reactions/emoji_showlove_reaction.webp',
          'symbol': '💖',
        },
        {
          'name': 'Rich',
          'icon': 'assets/emojis/panel_icons/emoji_rich.png',
          'reaction': 'assets/emojis/reactions/emoji_rich_reaction.webp',
          'symbol': '🤑',
        },
        {
          'name': 'Salute',
          'icon': 'assets/emojis/panel_icons/emoji_salute.png',
          'reaction': 'assets/emojis/reactions/emoji_salute_reaction.webp',
          'symbol': '🫡',
        },
        {
          'name': 'Cool',
          'icon': 'assets/emojis/panel_icons/emoji_smoking.png',
          'reaction': 'assets/emojis/reactions/emoji_smoking_reaction.webp',
          'symbol': '😎',
        },
        {
          'name': 'Music',
          'icon': 'assets/emojis/panel_icons/emoji_music.png',
          'reaction': 'assets/emojis/reactions/emoji_music_reaction.webp',
          'symbol': '🎶',
        },
        {
          'name': 'Cry',
          'icon': 'assets/emojis/panel_icons/emoji_sad.png',
          'reaction': 'assets/emojis/reactions/emoji_sad_reaction.webp',
          'symbol': '😭',
        },
        {
          'name': 'Handclap',
          'icon': 'assets/emojis/panel_icons/emoji_handclap.png',
          'reaction': 'assets/emojis/reactions/emoji_handclap_reaction.webp',
          'symbol': '🙌',
        },
        {
          'name': 'Thumbs Up',
          'icon': 'assets/emojis/panel_icons/emoji_up.png',
          'reaction': 'assets/emojis/reactions/emoji_up_reaction.webp',
          'symbol': '👍',
        },
        {
          'name': 'Thumbs Down',
          'icon': 'assets/emojis/panel_icons/emoji_down.png',
          'reaction': 'assets/emojis/reactions/emoji_down_reaction.webp',
          'symbol': '👎',
        },
        {
          'name': 'Point Left',
          'icon': 'assets/emojis/panel_icons/emoji_left.png',
          'reaction': 'assets/emojis/reactions/emoji_left_reaction.webp',
          'symbol': '👈',
        },
        {
          'name': 'Point Right',
          'icon': 'assets/emojis/panel_icons/emoji_right.png',
          'reaction': 'assets/emojis/reactions/emoji_right_reaction.webp',
          'symbol': '👉',
        },
      ]
    },
    {
      'title': 'Games 🎲',
      'icon': Icons.casino_rounded,
      'isCustomAssets': true,
      'items': [
        {
          'name': 'Roll Dice',
          'icon': 'assets/emojis/panel_icons/emoji_dice.png',
          'reaction': 'assets/emojis/game/dice_roll_loop.webp',
          'symbol': '🎲',
        },
        {
          'name': 'Lucky Digits',
          'icon': 'assets/emojis/panel_icons/emoji_number.png',
          'reaction': 'assets/emojis/game/number_roll_loop.webp',
          'symbol': '🎰',
        },
        {
          'name': 'Dice Face 1',
          'icon': 'assets/emojis/game/dice_face_1.png',
          'reaction': 'assets/emojis/game/dice_land_1.webp',
          'symbol': '⚀',
        },
        {
          'name': 'Dice Face 2',
          'icon': 'assets/emojis/game/dice_face_2.png',
          'reaction': 'assets/emojis/game/dice_land_2.webp',
          'symbol': '⚁',
        },
        {
          'name': 'Dice Face 3',
          'icon': 'assets/emojis/game/dice_face_3.png',
          'reaction': 'assets/emojis/game/dice_land_3.webp',
          'symbol': '⚂',
        },
        {
          'name': 'Dice Face 4',
          'icon': 'assets/emojis/game/dice_face_4.png',
          'reaction': 'assets/emojis/game/dice_land_4.webp',
          'symbol': '⚃',
        },
        {
          'name': 'Dice Face 5',
          'icon': 'assets/emojis/game/dice_face_5.png',
          'reaction': 'assets/emojis/game/dice_land_5.webp',
          'symbol': '⚄',
        },
        {
          'name': 'Dice Face 6',
          'icon': 'assets/emojis/game/dice_face_6.png',
          'reaction': 'assets/emojis/game/dice_land_6.webp',
          'symbol': '⚅',
        },
      ]
    },
  ];

  static const List<Map<String, dynamic>> _defaultCategories = [
    ..._customAssetCategories,
    {
      'title': 'Popular',
      'icon': Icons.local_fire_department_rounded,
      'emojis': ['❤️', '😂', '😍', '🔥', '👏', '😘', '🎉', '😎', '🥰', '🤣', '👍', '💯', '✨', '🚀', '💎', '👑']
    },
    {
      'title': 'Love',
      'icon': Icons.favorite_rounded,
      'emojis': ['❤️', '💖', '💕', '💗', '💓', '💘', '💙', '💜', '💚', '🧡', '💛', '🤍', '🤎', '❣️', '💔']
    },
    {
      'title': 'Party',
      'icon': Icons.celebration_rounded,
      'emojis': ['🎉', '🥳', '🍾', '🎆', '✨', '🌟', '👑', '🏆', '💎', '🚀', '💣', '💥', '🎶', '🎵', '🎤']
    },
    {
      'title': 'Faces',
      'icon': Icons.sentiment_very_satisfied_rounded,
      'emojis': ['😂', '🤣', '😍', '😎', '🥰', '😘', '🤩', '😜', '😇', '🥳', '🤯', '😏', '🤤', '🤠', '🤡']
    },
    {
      'title': 'Hands',
      'icon': Icons.pan_tool_rounded,
      'emojis': ['👏', '👍', '🙌', '🤝', '👊', '✊', '🤘', '✌️', '🤌', '👈', '👉', '👇', '👆', '👋', '🙏']
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _defaultCategories.length, vsync: this);
    _fetchBackendEmojiTray();
  }

  Future<void> _fetchBackendEmojiTray() async {
    try {
      final response = await ApiClient.instance.get('/v1/emojis/tray');
      if (response.statusCode == 200 && response.data?['success'] == true) {
        final List dynamicList = response.data['data'] as List? ?? [];
        if (dynamicList.isNotEmpty) {
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (final item in dynamicList) {
            if (item is Map<String, dynamic>) {
              final cat = item['category']?.toString() ?? 'Custom';
              grouped.putIfAbsent(cat, () => []).add(item);
            }
          }

          final List<Map<String, dynamic>> loadedCategories = [];
          grouped.forEach((catName, emojiItems) {
            loadedCategories.add({
              'title': catName,
              'icon': _getCategoryIcon(catName),
              'items': emojiItems,
            });
          });

          if (mounted && loadedCategories.isNotEmpty) {
            setState(() {
              _dynamicCategories = [
                ..._customAssetCategories,
                ...loadedCategories,
              ];
              _tabController.dispose();
              _tabController = TabController(length: _dynamicCategories.length, vsync: this);
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('vip') || lower.contains('svip')) return Icons.workspace_premium_rounded;
    if (lower.contains('noble')) return Icons.shield_rounded;
    if (lower.contains('animated') || lower.contains('motion')) return Icons.auto_awesome_rounded;
    if (lower.contains('love') || lower.contains('heart')) return Icons.favorite_rounded;
    if (lower.contains('party') || lower.contains('fire')) return Icons.local_fire_department_rounded;
    return Icons.emoji_emotions_rounded;
  }

  void _onSelectAssetEmoji(Map<String, dynamic> item) {
    final reaction = item['reaction']?.toString() ?? item['icon']?.toString() ?? '';
    final symbol = item['symbol']?.toString() ?? '✨';

    if (widget.onReactionSelected != null) {
      widget.onReactionSelected!(reaction, symbol);
    } else {
      widget.onEmojiSelected(symbol);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _onSelectCustomEmoji(Map<String, dynamic> item) async {
    final symbol = item['symbol']?.toString() ?? item['code']?.toString() ?? '✨';
    final emojiId = item['id']?.toString();

    if (emojiId != null && widget.roomId != null) {
      try {
        await ApiClient.instance.post('/v1/emojis/send', data: {
          'emojiId': emojiId,
          'roomId': widget.roomId,
        });
      } catch (_) {}
    }

    if (widget.onReactionSelected != null) {
      widget.onReactionSelected!(symbol, symbol);
    }
    widget.onEmojiSelected(symbol);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCategories = _dynamicCategories.isNotEmpty ? _dynamicCategories : _defaultCategories;

    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFF2B243B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: const Color(0xFFFF1493),
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: const Color(0xFFFF1493),
            unselectedLabelColor: Colors.white54,
            tabs: activeCategories.map((c) => Tab(
              icon: Icon(c['icon'] as IconData, size: 20),
              text: c['title'] as String?,
            )).toList(),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Emojis Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF1493)))
                : TabBarView(
                    controller: _tabController,
                    children: activeCategories.map((cat) {
                      // 1. Custom Asset Emojis (Live Reactions & Games)
                      if (cat['isCustomAssets'] == true) {
                        final List items = cat['items'] as List? ?? [];
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.92,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index] as Map<String, dynamic>;
                            final iconPath = item['icon'] as String;
                            final name = item['name'] as String;

                            return GestureDetector(
                              onTap: () => _onSelectAssetEmoji(item),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      iconPath,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Text('✨', style: TextStyle(fontSize: 26)),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      // 2. Dynamic Backend Items
                      if (cat['items'] != null) {
                        final List items = cat['items'] as List? ?? [];
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index] as Map<String, dynamic>;
                            final symbol = item['symbol']?.toString() ?? item['icon']?.toString() ?? '✨';
                            final isLocked = item['isLocked'] == true;

                            return GestureDetector(
                              onTap: isLocked ? null : () => _onSelectCustomEmoji(item),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? Colors.white.withValues(alpha: 0.02)
                                      : Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: isLocked
                                      ? Border.all(color: Colors.white12)
                                      : null,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      symbol,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: isLocked ? Colors.white38 : Colors.white,
                                      ),
                                    ),
                                    if (isLocked)
                                      const Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Icon(Icons.lock_rounded, size: 12, color: Colors.amber),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      // 3. Default static fallback unicode emojis
                      final List<String> emojis = (cat['emojis'] as List?)?.cast<String>() ?? [];
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          return GestureDetector(
                            onTap: () {
                              widget.onEmojiSelected(emoji);
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
