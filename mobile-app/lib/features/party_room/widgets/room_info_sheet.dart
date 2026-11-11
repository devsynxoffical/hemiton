import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/live_room_model.dart';
import '../../../../models/user_model.dart';
import '../../../../models/party_participant_model.dart';
import '../../../../providers/live_party_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../core/services/media_upload_service.dart';
import '../../recharge/recharge_screen.dart';
import '../room_settings_screen.dart';

class RoomInfoSheet extends StatefulWidget {
  final LiveRoomModel room;
  final bool canManage;
  final bool isDark;
  final List<PartyParticipantModel>? participants;

  const RoomInfoSheet({
    super.key,
    required this.room,
    required this.canManage,
    required this.isDark,
    this.participants,
  });

  @override
  State<RoomInfoSheet> createState() => _RoomInfoSheetState();
}

class _RoomInfoSheetState extends State<RoomInfoSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentTitle;
  late String _currentCoverUrl;
  String _memberSearchQuery = '';
  final TextEditingController _memberSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentTitle = widget.room.title;
    _currentCoverUrl = widget.room.coverUrl;
  }

  @override
  void didUpdateWidget(covariant RoomInfoSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.room.title != oldWidget.room.title) {
      _currentTitle = widget.room.title;
    }
    if (widget.room.coverUrl != oldWidget.room.coverUrl) {
      _currentCoverUrl = widget.room.coverUrl;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.room.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onChangeCoverPhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Change Room Cover', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.pinkAccent),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final authUser = context.read<AuthProvider>().currentUser;
                  final isHost = widget.room.host.id == authUser.id;
                  final isAdmin = authUser.role == UserRole.admin || authUser.id == 'admin';
                  final isAuthorized = widget.canManage || isHost || isAdmin;

                  if (!isAuthorized) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You don't have permission to change this room.")),
                    );
                    return;
                  }

                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (picked != null) {
                      String publicUrl = picked.path;
                      try {
                        final uploadRes = await MediaUploadService.instance.uploadFile(
                          filePath: picked.path,
                          folder: 'banners',
                        );
                        if (uploadRes.url.isNotEmpty) {
                          publicUrl = uploadRes.url;
                        }
                      } catch (uploadErr) {
                        debugPrint('[RoomInfoSheet] Upload error: $uploadErr');
                      }

                      setState(() {
                        _currentCoverUrl = publicUrl;
                      });
                      if (mounted) {
                        Provider.of<LivePartyProvider>(context, listen: false).updateRoomDetails(coverUrl: publicUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Room cover updated successfully!'),
                            backgroundColor: Colors.pinkAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error selecting cover image: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Colors.purpleAccent),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                    if (picked != null) {
                      setState(() {
                        _currentCoverUrl = picked.path;
                      });
                      if (mounted) {
                        Provider.of<LivePartyProvider>(context, listen: false).updateRoomDetails(coverUrl: picked.path);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Room cover updated successfully!'),
                            backgroundColor: Colors.pinkAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error taking photo: $e')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
                title: const Text('Choose Curated Room Avatar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPresetAvatarsDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetAvatarsDialog() {
    final presets = [
      'assets/images/party_gift_box.jpg',
      'assets/images/game_treasure_chest.jpg',
      'assets/images/gift_supercar.jpg',
      'assets/images/party_rocket_icon.jpg',
      'assets/images/party_games_icon.jpg',
      'assets/images/gift_gold_crown.jpg',
    ];

    showDialog(
      context: context,
      builder: (pCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Preset Room Cover', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: presets.length,
            itemBuilder: (context, idx) {
              final url = presets[idx];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentCoverUrl = url;
                  });
                  Provider.of<LivePartyProvider>(context, listen: false).updateRoomDetails(coverUrl: url);
                  Navigator.pop(pCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Room cover updated!'),
                      backgroundColor: Colors.pinkAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: url.startsWith('assets')
                      ? Image.asset(url, fit: BoxFit.cover)
                      : Image.network(url, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onEditRoomName() {
    final nameController = TextEditingController(text: _currentTitle);

    showDialog(
      context: context,
      builder: (eCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Room Name', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter a catchy title for your room:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              autofocus: true,
              maxLength: 35,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Room Name',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                counterStyle: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(eCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getPrimary(widget.isDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _currentTitle = newName;
                });
                Provider.of<LivePartyProvider>(context, listen: false).updateRoomDetails(title: newName);
                Navigator.pop(eCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✨ Room name updated to "$newName"!'),
                    backgroundColor: Colors.purpleAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Color primaryColor) {
    if (_currentCoverUrl.startsWith('http')) {
      return Image.network(
        _currentCoverUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _coverFallback(primaryColor);
        },
        errorBuilder: (_, _, _) => _coverFallback(primaryColor),
      );
    } else if (_currentCoverUrl.startsWith('assets')) {
      return Image.asset(
        _currentCoverUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _coverFallback(primaryColor),
      );
    } else {
      if (_currentCoverUrl.isNotEmpty) {
        final file = File(_currentCoverUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _coverFallback(primaryColor),
          );
        }
      }
      return _coverFallback(primaryColor);
    }
  }

  Widget _coverFallback(Color primaryColor) {
    final initial = _currentTitle.trim().isNotEmpty ? _currentTitle.trim()[0].toUpperCase() : 'H';
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF007F), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white.withValues(alpha: 0.18),
              size: 64,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.podcasts_rounded, color: Colors.white, size: 30),
              const SizedBox(height: 2),
              Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    final secondaryColor = Colors.white.withValues(alpha: 0.68);
    const primaryColor = Color(0xFFFF007F);
    const cardColor = Color(0xFF1B1033);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF21123E),
            Color(0xFF130B26),
            Color(0xFF0A0614),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFF007F).withValues(alpha: 0.45),
            width: 1.3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF007F).withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 24,
            spreadRadius: 5,
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.74,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing Drag Handle
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF007F), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF007F), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Room Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 19),
                  ),
                ),
              ],
            ),
          ),

          // Segmented Glass Pill Tabs (Profile | Member)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
            padding: const EdgeInsets.all(4),
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF140B29),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: secondaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Member'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(textColor, secondaryColor, primaryColor, cardColor),
                _buildMemberTab(textColor, secondaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Color textColor, Color secondaryColor, Color primaryColor, Color cardColor) {
    final memberCount = widget.participants?.length ?? 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cover & Floating Glass Action Icons
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: widget.canManage ? _onChangeCoverPhoto : null,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF007F), Color(0xFF8A2BE2), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007F).withValues(alpha: 0.38),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23.5),
                    child: _buildCoverImage(primaryColor),
                  ),
                ),
              ),
              if (widget.canManage)
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: _onChangeCoverPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF130B26), width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF007F).withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              Positioned(
                right: -54,
                top: 4,
                child: Column(
                  children: [
                    if (widget.canManage)
                      _buildActionIcon(Icons.settings_outlined, const Color(0xFF00E5FF), () async {
                        final updated = await Navigator.push<LiveRoomModel>(
                          context,
                          MaterialPageRoute(builder: (_) => RoomSettingsScreen(room: widget.room)),
                        );
                        if (updated != null && mounted) {
                          setState(() {
                            _currentTitle = updated.title;
                            _currentCoverUrl = updated.coverUrl;
                          });
                        }
                      }),
                    if (widget.canManage) const SizedBox(height: 10),
                    _buildActionIcon(Icons.star_rounded, const Color(0xFFFFD54F), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✨ Added to Favorites')),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Room Name + Diamond + Edit Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _currentTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.diamond_rounded, color: Color(0xFFFF007F), size: 18),
              if (widget.canManage) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _onEditRoomName,
                  child: Container(
                    padding: const EdgeInsets.all(4.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, color: Color(0xFF00E5FF), size: 14),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Room ID Glass Pill
          GestureDetector(
            onTap: _copyRoomId,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Room ID: ${widget.room.id.length > 8 ? widget.room.id.substring(0, 8) : widget.room.id}',
                    style: TextStyle(fontSize: 12, color: secondaryColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.copy_rounded, color: Color(0xFF00E5FF), size: 12.5),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Details List wrapped in a sleek HemiTon Cyber-Glass Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF231442).withValues(alpha: 0.85),
                  const Color(0xFF150C2A).withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFF007F).withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Country',
                  '🇵🇰 Pakistan',
                  textColor,
                  secondaryColor,
                  leadingIcon: Icons.public_rounded,
                  iconColor: const Color(0xFF00E5FF),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 0.6, color: Colors.white.withValues(alpha: 0.08)),
                ),
                _buildLevelRow(textColor, secondaryColor, primaryColor),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 0.6, color: Colors.white.withValues(alpha: 0.08)),
                ),
                _buildDetailRow(
                  'Member',
                  '$memberCount/200',
                  textColor,
                  secondaryColor,
                  highlightValue: '$memberCount',
                  highlightColor: const Color(0xFFFF007F),
                  leadingIcon: Icons.groups_rounded,
                  iconColor: const Color(0xFFB388FF),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 0.6, color: Colors.white.withValues(alpha: 0.08)),
                ),
                _buildDetailRow(
                  'Room mode',
                  widget.room.roomMode.isNotEmpty ? widget.room.roomMode : 'Friend mode',
                  textColor,
                  secondaryColor,
                  showArrow: widget.canManage,
                  leadingIcon: Icons.tune_rounded,
                  iconColor: const Color(0xFFFFD54F),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // CR 36 Side-by-Side Follow & Join / Room Owner Bottom Actions
          _buildFollowAndJoinSection(textColor, primaryColor),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF231442),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.0),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color secondaryColor, {
    String? highlightValue,
    Color? highlightColor,
    bool showArrow = false,
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (iconColor ?? const Color(0xFFFF007F)).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(leadingIcon, color: iconColor ?? const Color(0xFFFF007F), size: 15),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (highlightValue != null && highlightColor != null) ...[
              Text(
                highlightValue,
                style: TextStyle(
                  color: highlightColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                value.replaceAll(highlightValue, ''),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: secondaryColor, size: 16),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildLevelRow(Color textColor, Color secondaryColor, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF007F).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.bolt_rounded, color: Color(0xFFFF007F), size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          'Level',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'LV.8',
          style: TextStyle(
            color: Color(0xFFFF007F),
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.54,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF007F), Color(0xFF00E5FF)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '5,422 / 10k EXP',
                style: TextStyle(color: secondaryColor, fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'LV.9',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }



  Widget _buildMemberTab(Color textColor, Color secondaryColor) {
    final livePartyProv = Provider.of<LivePartyProvider>(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProv.currentUser;

    final roomHostId = widget.room.host.id;
    final isOwner = currentUser.id == roomHostId || widget.room.creatorUserId == currentUser.id;

    // Check if viewer is an admin
    final isViewerAdmin = livePartyProv.participants.any(
      (p) => p.user.id == currentUser.id && p.role == ParticipantRole.moderator,
    );
    final canManageRoles = isOwner || isViewerAdmin;

    final allMembers = livePartyProv.participants.isNotEmpty
        ? livePartyProv.participants
        : (widget.participants ?? []);

    // Deduplicate members by unique user ID/username so each user only appears once
    final seenIds = <String>{};
    final uniqueMembers = <PartyParticipantModel>[];
    for (final p in allMembers) {
      final key = p.user.id.isNotEmpty
          ? p.user.id
          : (p.user.username.isNotEmpty ? p.user.username.toLowerCase() : p.user.name.toLowerCase());
      if (key.isNotEmpty && seenIds.add(key)) {
        uniqueMembers.add(p);
      }
    }

    final filteredMembers = uniqueMembers.where((p) {
      if (_memberSearchQuery.trim().isEmpty) return true;
      final q = _memberSearchQuery.trim().toLowerCase();
      final name = p.user.name.toLowerCase();
      final username = p.user.username.toLowerCase();
      final userId = p.user.id.toLowerCase();
      return name.contains(q) || username.contains(q) || userId.contains(q);
    }).toList();

    return Column(
      children: [
        // Search & Counter Header Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Member: ${uniqueMembers.length}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.info_outline, color: secondaryColor, size: 16),
                ],
              ),
              const SizedBox(height: 8),
              // Search Field matching reference
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF252136) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.getPrimary(widget.isDark).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: secondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _memberSearchController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        onChanged: (val) {
                          setState(() {
                            _memberSearchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'User ID',
                          hintStyle: TextStyle(color: secondaryColor.withValues(alpha: 0.6), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_memberSearchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _memberSearchController.clear();
                          setState(() {
                            _memberSearchQuery = '';
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(Icons.clear_rounded, color: secondaryColor, size: 18),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Color(0xFFB524E4),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of Members
        Expanded(
          child: filteredMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, color: secondaryColor.withValues(alpha: 0.5), size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'No room members match your search.',
                        style: TextStyle(color: secondaryColor, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredMembers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.3, color: Colors.white10),
                  itemBuilder: (context, index) {
                    final participant = filteredMembers[index];
                    final targetUser = participant.user;

                    final isTargetHost = targetUser.id == roomHostId || participant.role == ParticipantRole.host;
                    final isTargetAdmin = participant.role == ParticipantRole.moderator;

                    String roleLabel = 'Member';
                    Color roleColor = secondaryColor;
                    if (isTargetHost) {
                      roleLabel = 'Host';
                      roleColor = Colors.amber;
                    } else if (isTargetAdmin) {
                      roleLabel = 'Admin';
                      roleColor = Colors.cyanAccent;
                    }

                    final canPerformAction = canManageRoles &&
                        !isTargetHost &&
                        targetUser.id != currentUser.id &&
                        (isOwner || (!isTargetAdmin));

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.getPrimary(widget.isDark).withValues(alpha: 0.2),
                            backgroundImage: targetUser.avatarUrl.isNotEmpty ? NetworkImage(targetUser.avatarUrl) : null,
                            child: targetUser.avatarUrl.isEmpty
                                ? Text(
                                    targetUser.name.isNotEmpty ? targetUser.name[0].toUpperCase() : 'U',
                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          if (isTargetHost)
                            const Positioned(
                              top: -4,
                              right: -4,
                              child: Text('👑', style: TextStyle(fontSize: 12)),
                            )
                          else if (isTargetAdmin)
                            const Positioned(
                              top: -4,
                              right: -4,
                              child: Text('🛡️', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              targetUser.name.isNotEmpty ? targetUser.name : targetUser.username,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: roleColor.withValues(alpha: 0.4), width: 0.5),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                color: roleColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Flexible(
                            child: Text(
                              'ID: ${targetUser.id.length > 8 ? targetUser.id.substring(0, 8) : targetUser.id}',
                              style: TextStyle(color: secondaryColor, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 3, height: 3, decoration: BoxDecoration(color: secondaryColor, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            'active today',
                            style: TextStyle(color: secondaryColor, fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: canPerformAction
                          ? PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, color: secondaryColor, size: 20),
                              color: const Color(0xFF1E1B2E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              onSelected: (action) async {
                                if (action == 'appoint_admin') {
                                  _showAdminRoleConfirmDialog(context, livePartyProv, targetUser, 'ADMIN');
                                } else if (action == 'remove_admin') {
                                  _showAdminRoleConfirmDialog(context, livePartyProv, targetUser, 'MEMBER');
                                } else if (action == 'kick') {
                                  _showKickConfirmDialog(context, livePartyProv, targetUser);
                                }
                              },
                              itemBuilder: (ctx) => [
                                if (!isTargetAdmin)
                                  const PopupMenuItem(
                                    value: 'appoint_admin',
                                    child: Row(
                                      children: [
                                        Icon(Icons.shield_outlined, color: Colors.cyanAccent, size: 18),
                                        SizedBox(width: 10),
                                        Text('Appoint as Admin', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ],
                                    ),
                                  )
                                else
                                  const PopupMenuItem(
                                    value: 'remove_admin',
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_moderator_outlined, color: Colors.amber, size: 18),
                                        SizedBox(width: 10),
                                        Text('Remove Admin Role', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'kick',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 18),
                                      SizedBox(width: 10),
                                      Text('Remove from Room', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
        ),

        // Leave / Unjoin Room Button Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF191627) : const Color(0xFFF9FAFB),
            border: Border(top: BorderSide(color: secondaryColor.withValues(alpha: 0.1))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.exit_to_app_rounded, size: 20),
              label: const Text(
                'Leave / Unjoin Room',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () => _showUnjoinConfirmDialog(context, livePartyProv),
            ),
          ),
        ),
      ],
    );
  }

  void _showAdminRoleConfirmDialog(BuildContext context, LivePartyProvider provider, UserModel targetUser, String newRole) {
    final isAppoint = newRole == 'ADMIN';
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAppoint ? 'Appoint Room Admin' : 'Remove Admin Role',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAppoint
              ? 'Are you sure you want to appoint ${targetUser.name} as a Room Admin?'
              : 'Are you sure you want to remove the Admin role from ${targetUser.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAppoint ? Colors.cyan : Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(d);
              try {
                await provider.updateMemberRoleOnBackend(targetUser.id, newRole);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAppoint ? '✨ Appointed ${targetUser.name} as Admin!' : 'ℹ️ Removed Admin role from ${targetUser.name}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update role: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: Text(isAppoint ? 'Appoint' : 'Remove Role', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showKickConfirmDialog(BuildContext context, LivePartyProvider provider, UserModel targetUser) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove from Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${targetUser.name} from this party room?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(d);
              provider.removeParticipant(targetUser.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🚫 Removed ${targetUser.name} from room.')),
                );
              }
            },
            child: const Text('Remove User'),
          ),
        ],
      ),
    );
  }

  void _showUnjoinConfirmDialog(BuildContext context, LivePartyProvider provider) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unjoin Party Room?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Leaving will remove your membership from this room and release any occupied mic seat.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Stay', style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(d);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              await provider.unjoinCurrentRoom();
            },
            child: const Text('Leave Room'),
          ),
        ],
      ),
    );
  }

  // CR 36 Side-by-Side Follow & Join Action Bar
  Widget _buildFollowAndJoinSection(Color textColor, Color primaryColor) {
    final authProv = Provider.of<AuthProvider>(context);
    final walletProv = Provider.of<WalletProvider>(context);
    final currentUser = authProv.currentUser;
    final isOwner = widget.canManage || currentUser.id == widget.room.host.id;

    if (isOwner) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3A1858), Color(0xFF7B1FA2), Color(0xFFFF007F)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF80AB).withValues(alpha: 0.6), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF007F).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 20),
            SizedBox(width: 8),
            Text(
              'Room Owner',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    }

    final isFollowing = authProv.isFollowing(widget.room.host.id);
    final fee = widget.room.membershipFee;
    final isJoined = widget.participants?.any((p) => p.user.id == currentUser.id) ?? false;

    return Row(
      children: [
        // Follow / Following Button (Left Side)
        Expanded(
          child: GestureDetector(
            onTap: () {
              authProv.toggleFollow(widget.room.host.id);
              final newStatus = authProv.isFollowing(widget.room.host.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(newStatus ? '💖 Following ${widget.room.host.name}!' : 'Unfollowed ${widget.room.host.name}.'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFollowing
                      ? [const Color(0xFF4A4458), const Color(0xFF332D42)]
                      : [const Color(0xFFFF4081), const Color(0xFFE91E63)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: isFollowing
                    ? []
                    : [BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFollowing ? Icons.check_rounded : Icons.favorite_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Join / Joined Button (Right Side)
        Expanded(
          child: GestureDetector(
            onTap: () async {
              if (isJoined) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ You are already a member of this party room.')),
                );
                return;
              }

              if (fee > 0) {
                // Paid Membership Join Confirmation Flow
                final confirmJoin = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1B2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Join Room Membership', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Membership Fee: $fee Coins', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Your Coin Balance: ${walletProv.coins} Coins', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),
                        const Text(
                          'Joining gives you full access to member chat, mic priority, and exclusive room perks.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );

                if (confirmJoin != true) return;

                if (walletProv.coins < fee) {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (d) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1B2E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Insufficient Coins', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        content: Text('Required: $fee Coins\nYour Balance: ${walletProv.coins} Coins'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                            onPressed: () {
                              Navigator.pop(d);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RechargeScreen()));
                            },
                            child: const Text('Recharge Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                }

                // Deduct fee exactly once
                walletProv.spendCoins(fee);
              }

              // Update room membership state
              if (mounted) {
                final partyProv = Provider.of<LivePartyProvider>(context, listen: false);
                partyProv.joinParty(widget.room, currentUser);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(fee > 0 ? '🎉 Paid $fee coins & joined room membership!' : '🎉 Joined party room!'),
                    backgroundColor: Colors.cyan,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                setState(() {});
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isJoined
                      ? [const Color(0xFF00B0FF), const Color(0xFF00838F)]
                      : [const Color(0xFF00E5FF), const Color(0xFF00B0FF)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isJoined
                          ? 'Joined'
                          : (fee > 0 ? 'Join ($fee 🪙)' : 'Join'),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
