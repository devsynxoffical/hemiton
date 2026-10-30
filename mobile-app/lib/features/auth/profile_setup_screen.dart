import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/personal_details_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'auth_screen.dart';
import 'under_age_screen.dart';
import '../main_layout.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? _selectedImagePath;
  final _nicknameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  String _selectedGender = 'Male';
  DateTime? _selectedDob;

  String _location = 'Islamabad, Pakistan';
  bool _isDetectingLocation = false;
  String _selectedHometown = '';

  static const List<String> _popularHometowns = [
    'Islamabad, Pakistan',
    'Lahore, Pakistan',
    'Karachi, Pakistan',
    'Rawalpindi, Pakistan',
    'Faisalabad, Pakistan',
    'Multan, Pakistan',
    'Peshawar, Pakistan',
    'Quetta, Pakistan',
    'Sialkot, Pakistan',
    'Gujranwala, Pakistan',
    'Dubai, UAE',
    'Riyadh, Saudi Arabia',
    'London, UK',
    'New Delhi, India',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nicknameController.text = (currentUser.name.isNotEmpty && currentUser.name != 'Guest')
        ? currentUser.name
        : '';
    _usernameController.text = currentUser.username;
    if (currentUser.bio.isNotEmpty) {
      _bioController.text = currentUser.bio;
    }
    if (currentUser.username.isNotEmpty) {
      _checkUsername(currentUser.username);
    }
    _autoDetectLocation();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nicknameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectLocation() async {
    if (_isDetectingLocation) return;
    setState(() => _isDetectingLocation = true);
    final detected = await PersonalDetailsService.instance.detectCurrentLocation();
    if (mounted) {
      setState(() {
        _location = detected;
        _isDetectingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 85);
      if (image != null && mounted) {
        setState(() => _selectedImagePath = image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showAvatarPickerSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF151226) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoSourceButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: const Color(0xFFFF007F),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              _buildPhotoSourceButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF00E5FF),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkUsername(String username) async {
    if (username.trim().length < 3) {
      setState(() {
        _isUsernameAvailable = false;
      });
      return;
    }
    setState(() => _isCheckingUsername = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final available = await authProvider.checkUsernameAvailable(username);

    if (mounted) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = available;
      });
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() => _selectedDob = picked);
    }
  }

  void _openHometownPicker(bool isDark) {
    final customCtrl = TextEditingController(text: _selectedHometown);
    String tempSelected = _selectedHometown;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141126) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home_work_rounded, color: Color(0xFFFF007F), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Select Hometown',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
                        SizedBox(width: 4),
                        Text(
                          '1-Time',
                          style: TextStyle(color: Colors.amber, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: customCtrl,
                onChanged: (v) => setModalState(() => tempSelected = v.trim()),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search or type city...',
                  prefixIcon: const Icon(Icons.location_city_rounded, size: 18, color: Color(0xFF00E5FF)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1A36) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularHometowns.map((city) {
                      final selected = tempSelected == city;
                      return GestureDetector(
                        onTap: () {
                          customCtrl.text = city;
                          setModalState(() => tempSelected = city);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)])
                                : null,
                            color: selected
                                ? null
                                : (isDark ? const Color(0xFF1E1A36) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : (isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                          child: Text(
                            city,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF007F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (tempSelected.trim().isNotEmpty) {
                      setState(() => _selectedHometown = tempSelected.trim());
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    'Confirm Hometown',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _finishProfileSetup() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Nickname')),
      );
      return;
    }
    if (_isUsernameAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an available Username')),
      );
      return;
    }
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your Date of Birth')),
      );
      return;
    }
    if (_selectedHometown.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your Hometown')),
      );
      return;
    }
    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Bio')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final calculatedAge = _calculateAge(_selectedDob!);

    await PersonalDetailsService.instance.saveDetails(
      authProvider.currentUser.id,
      UserPersonalDetails(
        location: _location.trim(),
        hometown: _selectedHometown.trim(),
        isHometownLocked: true,
      ),
    );

    final success = await authProvider.completeProfileOnboarding(
      name: _nicknameController.text.trim(),
      username: _usernameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob!,
      region: _location.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: _selectedImagePath ?? authProvider.currentUser.avatarUrl,
    );

    if (success && mounted) {
      if (calculatedAge < 18) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UnderAgeScreen()),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _cancelAndAbortAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen(initialMode: AuthMode.signup)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context);
    final int? age = _selectedDob != null ? _calculateAge(_selectedDob!) : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0816) : const Color(0xFFF6F8FC),
        body: Stack(
          children: [
            // Ambient Top Glow
            Positioned(
              top: -80,
              left: -50,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF007F).withValues(alpha: isDark ? 0.18 : 0.08),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8A2BE2).withValues(alpha: isDark ? 0.2 : 0.08),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Minimal Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Complete Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.darkNavy,
                          ),
                        ),
                        GestureDetector(
                          onTap: _cancelAndAbortAccount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Column(
                        children: [
                          // ── 1. Glowing Avatar Picker ───────────────────────
                          GestureDetector(
                            onTap: () => _showAvatarPickerSheet(isDark),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF007F),
                                        Color(0xFF8A2BE2),
                                        Color(0xFF00E5FF),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF007F).withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: isDark ? const Color(0xFF151228) : Colors.white,
                                    backgroundImage: _selectedImagePath != null
                                        ? FileImage(File(_selectedImagePath!)) as ImageProvider
                                        : null,
                                    child: _selectedImagePath == null
                                        ? const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 32,
                                            color: Color(0xFFFF007F),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF0A0816) : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── 2. Nickname & Username Glass Card ──────────────
                          _buildGlassSection(
                            isDark: isDark,
                            child: Column(
                              children: [
                                _buildCleanInputField(
                                  controller: _nicknameController,
                                  hint: 'Nickname',
                                  icon: Icons.person_rounded,
                                  iconColor: const Color(0xFFFF007F),
                                  isDark: isDark,
                                ),
                                Divider(
                                  height: 1,
                                  color: isDark ? Colors.white10 : Colors.black12,
                                ),
                                _buildCleanInputField(
                                  controller: _usernameController,
                                  hint: 'Username',
                                  icon: Icons.alternate_email_rounded,
                                  iconColor: const Color(0xFF00E5FF),
                                  isDark: isDark,
                                  onChanged: _checkUsername,
                                  trailing: _isCheckingUsername
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : (_isUsernameAvailable == true
                                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 20)
                                          : (_isUsernameAvailable == false
                                              ? const Icon(Icons.error_rounded, color: Colors.redAccent, size: 20)
                                              : null)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── 3. Gender Selection Row ────────────────────────
                          Row(
                            children: ['Male', 'Female'].map((gender) {
                              final isSelected = _selectedGender == gender;
                              final isFemale = gender == 'Female';
                              final activeColor = isFemale ? const Color(0xFFFF007F) : const Color(0xFF00E5FF);

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedGender = gender),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: EdgeInsets.only(
                                      right: gender == 'Male' ? 6 : 0,
                                      left: isFemale ? 6 : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                activeColor.withValues(alpha: 0.28),
                                                activeColor.withValues(alpha: 0.1),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (isDark ? const Color(0xFF151228) : Colors.white),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? activeColor
                                            : (isDark ? Colors.white10 : Colors.black12),
                                        width: isSelected ? 1.6 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isFemale ? Icons.female_rounded : Icons.male_rounded,
                                          color: activeColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          gender,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isDark ? Colors.white : AppColors.darkNavy,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // ── 4. DOB, Location & Hometown Interactive Tiles ──
                          _buildGlassSection(
                            isDark: isDark,
                            child: Column(
                              children: [
                                // Date of Birth
                                ListTile(
                                  onTap: () => _selectDateOfBirth(context),
                                  dense: true,
                                  leading: _buildMiniIcon(Icons.cake_rounded, const Color(0xFFFF9800)),
                                  title: Text(
                                    _selectedDob != null
                                        ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
                                        : 'Date of Birth',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: _selectedDob != null ? FontWeight.w600 : FontWeight.w400,
                                      color: _selectedDob != null
                                          ? (isDark ? Colors.white : AppColors.darkNavy)
                                          : (isDark ? Colors.white54 : Colors.grey),
                                    ),
                                  ),
                                  trailing: age != null
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$age yrs',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF00E676),
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                                ),
                                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

                                // Auto-Detected Location
                                ListTile(
                                  onTap: _autoDetectLocation,
                                  dense: true,
                                  leading: _buildMiniIcon(Icons.my_location_rounded, const Color(0xFF00E676)),
                                  title: Text(
                                    _location,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppColors.darkNavy,
                                    ),
                                  ),
                                  trailing: _isDetectingLocation
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF00E676),
                                          ),
                                        )
                                      : const Icon(Icons.gps_fixed_rounded, color: Color(0xFF00E676), size: 18),
                                ),
                                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

                                // One-Time Hometown Selection
                                ListTile(
                                  onTap: () => _openHometownPicker(isDark),
                                  dense: true,
                                  leading: _buildMiniIcon(Icons.home_work_rounded, const Color(0xFFFFB300)),
                                  title: Text(
                                    _selectedHometown.isNotEmpty ? _selectedHometown : 'Select Hometown',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: _selectedHometown.isNotEmpty ? FontWeight.w600 : FontWeight.w400,
                                      color: _selectedHometown.isNotEmpty
                                          ? (isDark ? Colors.white : AppColors.darkNavy)
                                          : (isDark ? Colors.white54 : Colors.grey),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.lock_outline_rounded, size: 11, color: Colors.amber),
                                            SizedBox(width: 3),
                                            Text(
                                              '1x',
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── 5. Bio Card ────────────────────────────────────
                          _buildGlassSection(
                            isDark: isDark,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: _buildMiniIcon(Icons.auto_awesome_rounded, const Color(0xFF8A2BE2)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _bioController,
                                      maxLines: 2,
                                      maxLength: 120,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        color: isDark ? Colors.white : AppColors.darkNavy,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Bio...',
                                        counterText: '',
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: isDark ? Colors.white38 : Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom Gradient Action Button ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    child: GestureDetector(
                      onTap: authProvider.isLoading ? null : _finishProfileSetup,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF007F),
                              Color(0xFF8A2BE2),
                              Color(0xFF00E5FF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007F).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  'Complete Profile',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
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
    );
  }

  Widget _buildGlassSection({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151228) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMiniIcon(IconData icon, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildCleanInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    ValueChanged<String>? onChanged,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          _buildMiniIcon(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
